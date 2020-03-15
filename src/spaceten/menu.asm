;==============================================================
; GAMEPLAY FUNCTIONS
;==============================================================

; Selector constants
select_pos_x		equ vdp_sprite_border_x+vdp_screen_width/2-0x30
select_pos_1_y		equ vdp_sprite_border_y+vdp_screen_height/2+0x04
select_pos_2_y		equ vdp_sprite_border_y+vdp_screen_height/2+0x24

palette_menu:
	dc.w	0x0000
	dc.w	0x0EEE
	dc.w	0x0E00
	dc.w	0x0900
	dc.w	0x0EE0
	dc.w	0x00EE
	dc.w	0x0008
	dc.w	0x000C
	dc.w	0x000A
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000

	dc.w	0x0300
	dc.w	0x0610
	dc.w	0x0810
	dc.w	0x0A20
	dc.w	0x0C30
	dc.w	0x0C50
	dc.w	0x0C70
	dc.w	0x0C90
	dc.w	0x0CB0
	dc.w	0x0CC0
	dc.w	0x0CCC
	dc.w	0x0888
	dc.w	0x0333
	dc.w	0x0000
	dc.w	0x0EEE
	dc.w	0x0000

;palette_space:
	dc.w	0x0C0D
	dc.w	0x09A1
	dc.w	0x06A3
	dc.w	0x06A6
	dc.w	0x06B9
	dc.w	0x0261
	dc.w	0x059D
	dc.w	0x0EEE
	dc.w	0x0EE5
	dc.w	0x0ADE
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000
	dc.w	0x0000

; Number of palettes to write to CRAM
menu_palette_count	equ 0x2

;==============================================================
; MEMORY MAP
;==============================================================
ram_current_select			rs.w 1	; Selected game mode in main menu

;==============================================================
; INITAILIZE GAME
;==============================================================
InitMenu:
	;==============================================================
	; Write the palettes to CRAM (colour memory)
	;==============================================================
	VDP_SetCRAMData palette_menu,menu_palette_count

	;==============================================================
	; Set up the scroll planes (nametables)
	;==============================================================

	; Fill plane A tiles
	VDP_SetVRAMWrite vram_addr_plane_a
	move.w #(vdp_plane_height*vdp_plane_width), d0
	lea map_menu, a0
	@PlaneALp:
	move.w (a0)+, d1
	add.w #(tile_id_menu+0x2000), d1
	move.w d1, vdp_data
	dbra d0, @PlaneALp

	; Fill plane B tiles
	VDP_SetVRAMWrite vram_addr_plane_b
	move.w #(vdp_plane_height*vdp_plane_width), d0
	lea map_stars, a0
	@PlaneBLp:
	move.w (a0)+, d1
	add.w #(tile_id_stars+0x2000), d1
	move.w d1, vdp_data
	dbra d0, @PlaneBLp

	; Reset plane scroll positions
	VDP_SetVRAMWrite vram_addr_hscroll
	move.w #0x01A0, vdp_data	; Plane A v-scroll ; Oops, not centered
	move.w #0x0000, vdp_data	; Plane B h-scroll

	VDP_SetVSRAMWrite 0x0000
	move.w #0x0210, vdp_data	; Plane A v-scroll ; Oops, not centered
	move.w #0x0000, vdp_data	; Plane B v-scroll

	;==============================================================
	; Set up the Sprite Attribute Tables (SAT)
	;==============================================================

	; Sprite attribute table addresses.
select_sprite_addr		equ vram_addr_sprite_table

	; Start writing to the sprite attribute table in VRAM
	VDP_SetVRAMWrite vram_addr_sprite_table
	VDP_SetSprite select_pos_x,select_pos_1_y,%0101,0x0,0x0,0x0,0x0,0x0,tile_id_ball

	;==============================================================
	; Intitialise variables in RAM
	;==============================================================
	move.w #0, ram_current_select

	; Start music
    AUDIO_PlayBGM content_bgm_music

	rts

;==============================================================
; UPDATE MAIN MENU
;==============================================================
; Called from the main game code every frame.
VUpdateMenu:
	move.w ram_gamepad_a_state, d0   ; Get button down states
	move.w ram_gamepad_a_toggled, d1 ; Get toggled states
	and.w d1, d0                     ; Was the button newly pressed this frame?

	; Check for A or Start pressed to select menu option
	btst   #pad_button_start, d0
	bne    @Select
	btst   #pad_button_a, d0
	bne    @Select
	bra @NoSelect
	@Select:
	move.w ram_current_select, ram_player_count
	jsr InitGame
	move.w #scene_game, ram_current_scene
	@NoSelect:

	; Check for dpad presses to change selection. Since there are only two
	; selections we treat up and down the same and just toggle between them.
	btst   #pad_button_up, d0
	bne    @SelectChange
	btst   #pad_button_down, d0
	bne    @SelectChange
	bra @NoSelectChange
	@SelectChange:
	AUDIO_PlaySFX content_sfx_bounce_paddle
	move.w ram_current_select, d1
	eor.b #1, d1
	move.w d1, ram_current_select
	cmp.b #1, d1
	bne @Selection1
	move.w #(select_pos_2_y), d2
	bra @SelectionProcess
	@Selection1:
	move.w #(select_pos_1_y), d2
	@SelectionProcess:
	move.w #(select_pos_x), d3
	VDP_SetSpritePos select_sprite_addr,d3,d2
	@NoSelectChange:

	; Update star field scroll plane
	move.w ram_plane_a_scroll_x, d1
	addi.w #1, d1
	move.w d1, ram_plane_a_scroll_x
	lsr.w #$02, d1
	VDP_SetVRAMWrite vram_addr_hscroll+size_word
	move.w d1, vdp_data

	rts
