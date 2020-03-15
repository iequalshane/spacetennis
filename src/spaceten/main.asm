;==============================================================
; Space Tennis for the SEGA MEGA DRIVE/GENESIS
;==============================================================
; by iEqualShane
;==============================================================

; Scenes
scene_intro				equ 0x00
scene_menu				equ 0x01
scene_game				equ 0x02

;==============================================================
; MEMORY MAP
;==============================================================
ram_player_count		rs.w 1	; 0x0 = 1 player, 0x1 = 2 player
ram_current_scene		rs.w 1  ; Current scene [0 = intro, 1 = menu, 2 = game] (word)
ram_frame_count			rs.w 1	; Number of frame since intro started

;==============================================================
; TILE IDs
;==============================================================
tile_id_blank			equ 0x00	; The blank tile at index 0
tile_id_paddle_top		equ 0x01	; Paddle top (8 tiles)
tile_id_paddle_bottom	equ 0x09	; Paddle bottom (8 tiles)
tile_id_ball			equ 0x11	; Ball (4 tiles)
tile_id_numbers			equ 0x15	; Numbers (40 tiles)
tile_id_shane			equ 0x3D	; "SHANE" logo tile for background
tile_id_menu			equ (tile_id_shane+tiles_shane_size_t)	; Planet tile for background
tile_id_planet			equ (tile_id_menu+tiles_menu_size_t)	; Planet tile for background
tile_id_stars			equ (tile_id_planet+tiles_planet_size_t)	; Stars tile for background
tile_id_p1wins			equ (tile_id_stars+tiles_stars_size_t)	; Player 1 wins text
tile_id_p2wins			equ (tile_id_p1wins+tiles_p1wins_size_t)	; Player 2 wins text
tile_id_paused			equ (tile_id_p2wins+tiles_p2wins_size_t)	; Player 2 wins text
tile_count				equ (tile_id_paused+tiles_paused_size_t)	; Total tiles to load (excl. blank)

;==============================================================
; CODE ENTRY POINT
;==============================================================
CPU_EntryPoint:
	;==============================================================
	; Initialise the Mega Drive
	;==============================================================

	VDP_Init

	; Initialise gamepad input
	PAD_Init

	; Initialize the audio system (ECHO)
	AUDIO_Init

	;==============================================================
	; Write the sprite tiles to VRAM
	;==============================================================
	
	; Setup the VDP to write to VRAM address 0x0020 (skips the first
	; tile, leaving it blank).
	VDP_SetVRAMWrite vram_addr_tiles+size_tile_b
	
	; Write all graphics tiles to VRAM
	lea    content_tiles, a0					; Move the address of the first graphics tile into a0
	move.w #(tile_count*size_tile_l)-1, d0		; Loop counter = 8 longwords per tile * num tiles (-1 for DBRA loop)
	@CharLp:									; Start of loop
	move.l (a0)+, vdp_data						; Write tile line (4 bytes per line), and post-increment address
	dbra d0, @CharLp							; Decrement d0 and loop until finished (when d0 reaches -1)

	;==============================================================
	; Intitialise variables in RAM
	;==============================================================
	move.w #0, ram_frame_count
	move.w #0, ram_player_count
	move.w #0, ram_gamepad_a_state
	move.w #0, ram_gamepad_b_state
	move.w #0, ram_gamepad_a_toggled
	move.w #0, ram_gamepad_b_toggled
	move.w #0, ram_current_scene

	;==============================================================
	; Initialise intro scene
	;==============================================================
    jsr InitIntro

	;==============================================================
	; Initialise status register and set interrupt level.
	;==============================================================
	move.w #0x2300, sr

	; Finished!
	
	;==============================================================
	; Loop forever
	;==============================================================
	; This loops forever, effectively ending our main routine,
	; but the VDP will continue to run of its own accord and
	; will still fire vertical and horizontal interrupts (which is
	; where our update code is), so the demo continues to run.
	;
	; For a game, it would be better to use this loop for processing
	; input and game code, and wait here until next vblank before
	; looping again. We only use vinterrupt for updates in this demo
	; for simplicity (because we don't yet have any timing code).
	@InfiniteLp:
	bra @InfiniteLp
	
;==============================================================
; INTERRUPT ROUTINES
;==============================================================

; Vertical interrupt - run once per frame (50hz in PAL, 60hz in NTSC)
INT_VInterrupt:

	; Read pad A state, result in format: 00SA0000 00CBRLDU
	PAD_ReadPad pad_data_a,ram_gamepad_a_state,ram_gamepad_a_toggled
	PAD_ReadPad pad_data_b,ram_gamepad_b_state,ram_gamepad_b_toggled

	; Select scene to update
	move.w ram_current_scene, d1
	cmp #scene_intro, d1
	beq @SCENE_INTRO
	cmp #scene_menu, d1
	beq @SCENE_MENU
	cmp #scene_game, d1
	beq @SCENE_GAME

	@SCENE_INTRO:
	; Run intro updates
	jsr VUpdateIntro
	bra @SCENE_DONE

	@SCENE_MENU:
	; Run menu updates
	jsr VUpdateMenu
	bra @SCENE_DONE

	@SCENE_GAME:
	; Run game upates
	jsr VUpdateGame

	@SCENE_DONE:
	rte

; Horizontal interrupt - run once per N scanlines (N = specified in VDP register 0xA)
INT_HInterrupt:

	move.w ram_current_scene, d1
	cmp #scene_intro, d1
	bne @HINT_DONE
	jsr HUpdateIntro

	@HINT_DONE:
	rte

; NULL interrupt - for interrupts we don't care about
INT_Null:
	rte

; Exception interrupt - called if an error has occured
CPU_Exception:
	; Just halt the CPU if an error occurred
	stop   #0x2700
	rte
