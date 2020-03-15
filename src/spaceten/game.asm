;==============================================================
; GAMEPLAY FUNCTIONS
;==============================================================

; Paddle constants
paddle_height			equ 0x40
paddle_width			equ 0x10
paddle1_start_pos_x		equ vdp_sprite_border_x
paddle1_start_pos_y		equ vdp_sprite_border_y+vdp_screen_height/2-paddle_height/2
paddle2_start_pos_x		equ vdp_screen_width+vdp_sprite_border_x-paddle_width
paddle2_start_pos_y		equ vdp_sprite_border_y+vdp_screen_height/2-paddle_height/2
; Speed (in pixels per frame) to move the paddle
paddle_move_speed_x		equ 0x1
paddle_move_speed_y		equ 0x2

; Ball constants
ball_height				equ 0x10
ball_width				equ 0x10
ball_start_pos_x		equ vdp_sprite_border_x+vdp_screen_width/2-ball_width/2
ball_start_pos_y		equ vdp_sprite_border_y+vdp_screen_height/2-ball_height/2
ball_start_vel_x		equ 0x4
ball_start_vel_y		equ 0x0

; Player score sprite positons
score_to_win			equ 0xB
player1_score_x			equ vdp_sprite_border_x+vdp_screen_width/2-48
player1_score_y			equ vdp_sprite_border_y+16
player2_score_x			equ vdp_sprite_border_x+vdp_screen_width/2+16
player2_score_y			equ vdp_sprite_border_y+16

; Paused text sprite positions
paused_x				equ vdp_sprite_border_x+vdp_screen_width/2-68
paused_y				equ vdp_sprite_border_y+96

; Player wins text sprite positons
pwins_x					equ vdp_sprite_border_x+vdp_screen_width/2-60
pwins_y					equ vdp_sprite_border_y+96

; Palette for sprite 1
palette_game:
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
game_palette_count	equ 0x2

;==============================================================
; MEMORY MAP
;==============================================================
ram_player1_paddle_pos_y	rs.w 1	; Paddle 1 y pos (word)
ram_player2_paddle_pos_y	rs.w 1	; Paddle 2 y pos (word)
ram_ball_pos_x				rs.w 1	; Ball x pos (word)
ram_ball_pos_y				rs.w 1	; Ball y pos (word)
ram_ball_vel_x				rs.w 1	; Ball x velocity (word)
ram_ball_vel_y				rs.w 1	; Ball y velocity (word)
ram_player1_score			rs.w 1	; Player 1 score (word)
ram_player2_score			rs.w 1	; Player 2 score (word)
ram_plane_a_scroll_x		rs.w 1	; Plane A X pos (word)
ram_plane_a_scroll_y		rs.w 1	; Plane A Y pos (word)
ram_paused					rs.w 1  ; Indicates if game is currently paused
ram_gamewon					rs.w 1	; Indicates if a player won

;==============================================================
; INITAILIZE GAME
;==============================================================
InitGame:

	;==============================================================
	; Write the palettes to CRAM (colour memory)
	;==============================================================
	VDP_SetCRAMData palette_game,game_palette_count

	;==============================================================
	; Set up the scroll planes (nametables)
	;==============================================================

	; Fill plane A tiles
	VDP_SetVRAMWrite vram_addr_plane_a
	move.w #(vdp_plane_height*vdp_plane_width), d0
	lea map_planet, a0
	@PlaneALp:
	move.w (a0)+, d1
	add.w #(tile_id_planet+0x2000), d1
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
	move.w #0x0000, vdp_data	; Plane A h-scroll
	move.w #0x0000, vdp_data	; Plane B h-scroll

	VDP_SetVSRAMWrite 0x0000
	move.w #0x0000, vdp_data	; Plane A v-scroll
	move.w #0x0000, vdp_data	; Plane B v-scroll

	;==============================================================
	; Set up the Sprite Attribute Tables (SAT)
	;==============================================================

	; Sprite attribute table addresses.
paddle1_top_sprite_addr		equ vram_addr_sprite_table
paddle1_bottom_sprite_addr	equ vram_addr_sprite_table+size_sprite_attribute_b
paddle2_top_sprite_addr		equ vram_addr_sprite_table+size_sprite_attribute_b*2
paddle2_bottom_sprite_addr	equ vram_addr_sprite_table+size_sprite_attribute_b*3
ball_sprite_addr			equ vram_addr_sprite_table+size_sprite_attribute_b*4
player1_score1_addr			equ vram_addr_sprite_table+size_sprite_attribute_b*5
player1_score2_addr			equ vram_addr_sprite_table+size_sprite_attribute_b*6
player2_score1_addr			equ vram_addr_sprite_table+size_sprite_attribute_b*7
player2_score2_addr			equ vram_addr_sprite_table+size_sprite_attribute_b*8
paused_addr					equ vram_addr_sprite_table+size_sprite_attribute_b*9 // 4 sprites
p1win_addr					equ vram_addr_sprite_table+size_sprite_attribute_b*13 // 4 sprites
p2win_addr					equ vram_addr_sprite_table+size_sprite_attribute_b*17 // 4 sprites

	; Start writing to the sprite attribute table in VRAM
	VDP_SetVRAMWrite vram_addr_sprite_table

	; Paddle 1 top sprite
	VDP_SetSprite paddle1_start_pos_x,paddle1_start_pos_y,%0111,0x1,0x0,0x0,0x0,0x0,tile_id_paddle_top

	; Paddle 1 bottom sprite
	VDP_SetSprite paddle1_start_pos_x,paddle1_start_pos_y+paddle_height/2,%0111,0x2,0x0,0x0,0x0,0x0,tile_id_paddle_bottom

	; Paddle 2 top sprite
	VDP_SetSprite paddle2_start_pos_x,paddle2_start_pos_y,%0111,0x3,0x0,0x0,0x0,0x0,tile_id_paddle_top

	; Paddle 2 bottom sprite
	VDP_SetSprite paddle2_start_pos_x,paddle2_start_pos_y+paddle_height/2,%0111,0x4,0x0,0x0,0x0,0x0,tile_id_paddle_bottom

	; Ball sprite
	VDP_SetSprite ball_start_pos_x,ball_start_pos_y,%0101,0x5,0x0,0x0,0x0,0x0,tile_id_ball

	; Player score sprites
	VDP_SetSprite player1_score_x,player1_score_y,%0101,0x6,0x0,0x0,0x0,0x0,tile_id_numbers
	VDP_SetSprite player1_score_x+16,player1_score_y,%0101,0x7,0x0,0x0,0x0,0x0,tile_id_numbers
	VDP_SetSprite player2_score_x,player2_score_y,%0101,0x8,0x0,0x0,0x0,0x0,tile_id_numbers
	VDP_SetSprite player2_score_x+16,player2_score_y,%0101,0x0,0x0,0x0,0x0,0x0,tile_id_numbers

	; Paused text sprites
	VDP_SetSprite paused_x,paused_y,%1111,0xA,0x0,0x0,0x0,0x0,tile_id_paused
	VDP_SetSprite paused_x+32,paused_y,%1111,0xB,0x0,0x0,0x0,0x0,tile_id_paused+16
	VDP_SetSprite paused_x+64,paused_y,%1111,0xC,0x0,0x0,0x0,0x0,tile_id_paused+32
	VDP_SetSprite paused_x+96,paused_y,%1011,0x0,0x0,0x0,0x0,0x0,tile_id_paused+48

	; P1 Wins text sprites
	VDP_SetSprite pwins_x,pwins_y,%1111,0xE,0x0,0x0,0x0,0x0,tile_id_p1wins
	VDP_SetSprite pwins_x+32,pwins_y,%1111,0xF,0x0,0x0,0x0,0x0,tile_id_p1wins+16
	VDP_SetSprite pwins_x+64,pwins_y,%1111,0x10,0x0,0x0,0x0,0x0,tile_id_p1wins+32
	VDP_SetSprite pwins_x+96,pwins_y,%1111,0x0,0x0,0x0,0x0,0x0,tile_id_p1wins+48

	; P2 Wins text sprites
	VDP_SetSprite pwins_x,pwins_y,%1111,0x12,0x0,0x0,0x0,0x0,tile_id_p2wins
	VDP_SetSprite pwins_x+32,pwins_y,%1111,0x13,0x0,0x0,0x0,0x0,tile_id_p2wins+16
	VDP_SetSprite pwins_x+64,pwins_y,%1111,0x14,0x0,0x0,0x0,0x0,tile_id_p2wins+32
	VDP_SetSprite pwins_x+96,pwins_y,%1111,0x0,0x0,0x0,0x0,0x0,tile_id_p2wins+48

	;==============================================================
	; Intitialise variables in RAM
	;==============================================================
	move.w #paddle1_start_pos_y, ram_player1_paddle_pos_y
	move.w #paddle2_start_pos_y, ram_player2_paddle_pos_y
	move.w #ball_start_pos_x, ram_ball_pos_x
	move.w #ball_start_pos_y, ram_ball_pos_y
	move.w #ball_start_vel_x, ram_ball_vel_x
	move.w #ball_start_vel_y, ram_ball_vel_y
	move.w #0, ram_player1_score
	move.w #0, ram_player2_score
	move.w #0, ram_plane_a_scroll_x
	move.w #0, ram_plane_a_scroll_y
	move.w #0, ram_paused
	move.w #0, ram_gamewon

	; Start music
    ; AUDIO_PlayBGM content_bgm_music

	rts

;==============================================================
; UPDATE GAME
;==============================================================
; Called from the main game code every frame.
VUpdateGame:
	move.w ram_gamepad_a_state, d0
	move.w ram_gamepad_b_state, d1
	move.w ram_gamepad_a_toggled, d2
	move.w ram_gamepad_b_toggled, d3
	move.w ram_paused, d4
	move.w ram_gamewon, d5

	; Check for start press to pause/unpause game
	and.w d2, d0
	and.w d3, d1
	or.w d1, d2
	btst   #pad_button_start, d0
	beq    @NoStartPressed
	AUDIO_PlaySFX content_sfx_bounce_paddle
	cmp #1, d5 ; Are we in the game win screen?
	bne @GameOn
	jsr InitMenu ; Return to menu when start is pressed after a game is won/lost
	move.w #scene_menu, ram_current_scene
	bra @GamePaused
	@GameOn:
	eor.w #1, d4 ; Toggle pause
	move.w d4, ram_paused
	cmp.w #1, d4
	bne @PausedStopped
	jsr Echo_PauseBGM
	VDP_SetSpriteLinkedTile paddle2_bottom_sprite_addr,%0111,0x5 ; Skip rendering ball
	VDP_SetSpriteLinkedTile player2_score2_addr,%0101,0x9 ; Enable rendering pause text
	bra @NoStartPressed
	@PausedStopped:
	jsr Echo_ResumeBGM
	VDP_SetSpriteLinkedTile paddle2_bottom_sprite_addr,%0111,0x4 ; Render ball again
	VDP_SetSpriteLinkedTile player2_score2_addr,%0101,0
	@NoStartPressed:

	; Skip updating paddles/ball if game is paused or on win/loss screen
	cmp #1, d4
	beq @GamePaused
	cmp #1, d5
	beq @GamePaused

	; Run game upates
	jsr UpdatePaddles
	jsr UpdateBall

	; Update scroll planes
	move.w ram_plane_a_scroll_x, d0
	;move.w ram_plane_a_scroll_y, d1

	addi.w #1, d0
	;addi.w #1, d1

	move.w d0, ram_plane_a_scroll_x
	;move.w d1, ram_plane_a_Scroll_y

	lsr.w #$01, d0
	lsr.w #$03, d1 ; d1 is the ball Y position that came from UpdateBall.
	VDP_SetVRAMWrite vram_addr_hscroll
	move.w d0, vdp_data
	VDP_SetVSRAMWrite 0x0000
	move.w d1, vdp_data
	lsr.w #$01, d0
	lsr.w #$01, d1
	VDP_SetVRAMWrite vram_addr_hscroll+size_word
	move.w d0, vdp_data
	VDP_SetVSRAMWrite 0x0000+size_word
	move.w d1, vdp_data
	@GamePaused:

	rts

;==============================================================
; UPDATE PADDLES
;==============================================================
UpdatePaddles:
	; Fetch current player 1 paddle coordinate from RAM
	move.w #paddle1_start_pos_x, d1
	move.w ram_player1_paddle_pos_y, d2

	; If UP button held, move sprite up
	move.w ram_gamepad_a_state, d0
	btst   #pad_button_up, d0
	beq    @NoUp
	subi.w #paddle_move_speed_y, d2
	; Stop paddle going off top of screen
	cmp.w #(vdp_sprite_border_y), d2
	bgt @NoUp
	move.w #(vdp_sprite_border_y), d2
	@NoUp:

	; If DOWN button held, move sprite down
	btst   #pad_button_down, d0
	beq    @NoDown
	addi.w #paddle_move_speed_y, d2
	; Stop paddle going off bottom of screen
	cmp.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	blt @NoDown
	move.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	@NoDown:

	; Store updated position back in RAM
	move.w d2, ram_player1_paddle_pos_y

	; Set the positions for the top and bottom sprites of the paddle
	VDP_SetSpritePos paddle1_top_sprite_addr,d1,d2
	addi.w #(paddle_height/2), d2 ; Bottom sprite offset
	VDP_SetSpritePos paddle1_bottom_sprite_addr,d1,d2

	; Fetch current player 2 paddle coordinate from RAM
	move.w #paddle2_start_pos_x, d1
	move.w ram_player2_paddle_pos_y, d2
	move.w ram_player_count, d0
	cmp #0, d0
	beq @Paddle2AI
	; Paddle 2 is a real player. Get input.
	; Fetch current player 1 paddle coordinate from RAM
	move.w #paddle2_start_pos_x, d1
	move.w ram_player2_paddle_pos_y, d2

	; If UP button held, move sprite up
	move.w ram_gamepad_b_state, d0
	btst   #pad_button_up, d0
	beq    @NoUpB
	subi.w #paddle_move_speed_y, d2
	; Stop paddle going off top of screen
	cmp.w #(vdp_sprite_border_y), d2
	bgt @NoUpB
	move.w #(vdp_sprite_border_y), d2
	@NoUpB:

	; If DOWN button held, move sprite down
	btst   #pad_button_down, d0
	beq    @Paddle2Done
	addi.w #paddle_move_speed_y, d2
	; Stop paddle going off bottom of screen
	cmp.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	blt @Paddle2Done
	move.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	bra @Paddle2Done

	@Paddle2AI:
	; Paddle 2 is a computer AI
	; Fetch ball Y coordinate
	move.w ram_ball_pos_y, d3
	cmp.w d2, d3
	bgt @BallNotAbovePaddle2
	subi.w #paddle_move_speed_y, d2
	; Stop paddle going off top of screen
	cmp.w #(vdp_sprite_border_y), d2
	bgt @BallNotAbovePaddle2
	move.w #(vdp_sprite_border_y), d2
	bra @Paddle2Done
	@BallNotAbovePaddle2:
	subi.w #paddle_height, d3
	cmp.w d2, d3
	blt @Paddle2Done
	addi.w #paddle_move_speed_y, d2
	cmp.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	blt @Paddle2Done
	move.w #(vdp_screen_height+vdp_sprite_border_y-paddle_height), d2
	@Paddle2Done:

	; Store updated position back in RAM
	move.w d2, ram_player2_paddle_pos_y

	; Set the positions for the top and bottom sprites of the paddle
	VDP_SetSpritePos paddle2_top_sprite_addr,d1,d2
	addi.w #(paddle_height/2), d2 ; Bottom sprite offset
	VDP_SetSpritePos paddle2_bottom_sprite_addr,d1,d2

	rts

;==============================================================
; CHECK PADDLE COLLISION MACRO
;==============================================================
; Writes a sprite attribute structure to VRAM
;CheckPaddleCollision:
;	paddle_pos_x,		; X pos of paddle
;	ram_paddle_pos_y,	; Y pos of paddle (RAM)
;	ball_bounce_vel,	; New velocity of the ball if it collides
;	ball_pos_x_reg,		; X pos of ball (register)
;	ball_pos_y_reg,		; Y pos of ball (register)
;	ball_vel_x_reg,		; X velocity of ball (register)
; 	ball_vel_y_reg,		; Y velocity of ball (register)
;	reg1				; Register to use for collision calculations
;	reg2				; Register to use for collision calculations
CheckPaddleCollision: macro paddle_pos_x,ram_paddle_pos_y,ball_bounce_vel,ball_pos_x_reg,ball_pos_y_reg,ball_vel_x_reg,ball_vel_y_reg,reg1,reg2
	; Check x boundary
	move.w #(paddle_pos_x), \reg1
	sub.w #(ball_width), \reg1
	cmp.w \reg1, \ball_pos_x_reg
	blt \@NoPaddleBounce
	addi.w #(paddle_width+ball_width), \reg1
	cmp.w \reg1, \ball_pos_x_reg
	bgt \@NoPaddleBounce
	; Check y boundary
	move.w ram_paddle_pos_y, \reg1
	sub.w #(ball_height), \reg1
	cmp.w \reg1, \ball_pos_y_reg
	blt \@NoPaddleBounce
	addi.w #(paddle_height+ball_height), \reg1
	cmp.w \reg1, \ball_pos_y_reg
	bgt \@NoPaddleBounce
	; Collision!
	move.w #(ball_bounce_vel), \ball_vel_x_reg
	AUDIO_PlaySFX content_sfx_bounce_paddle
	;  _ Paddle bounce regions:
	; |_| - bounce up 3x
	; |_| - bounce up 2x
	; |_| - bounce up 1x
	; |_| - bounce straight out
	; |_| - bounce down 1x
	; |_| - bounce down 2x
	; |_| - bounce down 3x
	subi.w #(paddle_height+ball_height/2), \reg1
	move.w \ball_pos_y_reg, \reg2
	sub.w \reg1, \reg2
	move.w #(-6), \ball_vel_y_reg
	cmp.w #(paddle_height/14), \reg2
	blt \@NoPaddleBounce
	move.w #(-4), \ball_vel_y_reg
	cmp.w #(paddle_height/7*2), \reg2
	blt \@NoPaddleBounce
	move.w #(-2), \ball_vel_y_reg
	cmp.w #(paddle_height/7*3), \reg2
	blt \@NoPaddleBounce
	move.w #(0), \ball_vel_y_reg
	cmp.w #(paddle_height/7*4), \reg2
	blt \@NoPaddleBounce
	move.w #(2), \ball_vel_y_reg
	cmp.w #(paddle_height/7*5), \reg2
	blt \@NoPaddleBounce
	move.w #(4), \ball_vel_y_reg
	cmp.w #(paddle_height/14*13), \reg2
	blt \@NoPaddleBounce
	move.w #(6), \ball_vel_y_reg
	\@NoPaddleBounce:

	endm

;==============================================================
; UPDATE BALL
;==============================================================
UpdateBall:
	; Fetch ball position, velocity and direction from RAM
	move.w ram_ball_pos_x, d0
	move.w ram_ball_pos_y, d1
	move.w ram_ball_vel_x, d2
	move.w ram_ball_vel_y, d3
	move.w ram_player1_score, d4
	move.w ram_player2_score, d5

	; Move the ball based on velocity
	add.w d2, d0
	add.w d3, d1

	; Bounce the ball off the walls
	cmp.w #(vdp_screen_width+vdp_sprite_border_x-ball_width), d0
	blt @NoBounceRight
	move.w #(-1*ball_start_vel_x), d2
	add.w #1, d4
	AUDIO_PlaySFX content_sfx_score
	@NoBounceRight:
	cmp.w #vdp_sprite_border_x, d0
	bgt @NoBounceLeft
	move.w #(ball_start_vel_x), d2
	add.w #1, d5
	AUDIO_PlaySFX content_sfx_score
	@NoBounceLeft:

	cmp.w #(vdp_screen_height+vdp_sprite_border_y-ball_height), d1
	blt @NoBounceBottom
	cmp.w #0, d3
	blt @NoBounceBottom
	muls.w #-1, d3
	AUDIO_PlaySFX content_sfx_bounce_wall
	@NoBounceBottom:
	cmp.w #vdp_sprite_border_y, d1
	bgt @NoBounceTop
	cmp.w #0, d3
	bgt @NoBounceTop
	muls.w #-1, d3
	AUDIO_PlaySFX content_sfx_bounce_wall
	@NoBounceTop:

	; Bounce the ball off the paddles
	CheckPaddleCollision paddle1_start_pos_x,ram_player1_paddle_pos_y,ball_start_vel_x,d0,d1,d2,d3,d6,d7
	CheckPaddleCollision paddle2_start_pos_x,ram_player2_paddle_pos_y,(-1*ball_start_vel_x),d0,d1,d2,d3,d6,d7

	; Store updated ball position, velocity and direction in RAM
	move.w d0, ram_ball_pos_x
	move.w d1, ram_ball_pos_y
	move.w d2, ram_ball_vel_x
	move.w d3, ram_ball_vel_y

	; Update score and check for win/loss
	move.w d4, ram_player1_score
	move.w d5, ram_player2_score
	cmp #score_to_win, d4
	bne @P1NoWin
	VDP_SetSpriteLinkedTile player2_score2_addr,%0101,0xD ; Enable rendering p1 win text
	move.w #1, ram_gamewon
	bra @P2NoWin
	@P1NoWin:
	cmp #score_to_win, d5
	bne @P2NoWin
	VDP_SetSpriteLinkedTile player2_score2_addr,%0101,0x11 ; Enable rendering p1 win text
	move.w #1, ram_gamewon
	@P2NoWin:

	; Write updated coordinates to the Sprite Attribute Table in VRAM.
	VDP_SetSpritePos ball_sprite_addr,d0,d1

	; Update the score sprites
	move.w d4, d6
	move.w d5, d7
	divs.w #10, d6
	divs.w #10, d7
	muls.w #10, d6
	muls.w #10, d7
	sub.w d6, d4
	sub.w d7, d5
	divs.w #10, d6
	divs.w #10, d7
	muls.w #4, d4
	muls.w #4, d5
	muls.w #4, d6
	muls.w #4, d7
	add.w #tile_id_numbers, d4
	add.w #tile_id_numbers, d5
	add.w #tile_id_numbers, d6
	add.w #tile_id_numbers, d7

	VDP_SetSpriteTile player1_score2_addr, d4
	VDP_SetSpriteTile player2_score2_addr, d5
	VDP_SetSpriteTile player1_score1_addr, d6
	VDP_SetSpriteTile player2_score1_addr, d7

	rts