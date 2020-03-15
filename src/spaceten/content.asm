;==============================================================
; All game content goes here. Be aware of data alignment.
;==============================================================

;==============================================================
; Sound FX and Music
;==============================================================
	include "src/spaceten/audio/instru.asm"		; Instruments for sound and music

; Sound Effects
content_sfx_bounce_wall:
    dc.b    $EA,$1A,$4A,$01,$2A,$04 ; Lock PSG Ch3; Note Off PSG Ch3; Set Instr PSG Chn3; Set Vol PSG Chn3
    dc.b    $0A,1*36,$FE,2 ; Note on PSG channel #3 ; Delay ticks
    dc.b    $FF ; Stop playback

content_sfx_bounce_paddle:
    dc.b    $EA,$1A,$4A,$01,$2A,$04 ; Lock PSG Ch3; Note Off PSG Ch3; Set Instr PSG Chn3; Set Vol PSG Chn3
    dc.b    $0A,2*36,$FE,2 ; Note on PSG channel #3 ; Delay ticks
    dc.b    $FF ; Stop playback

content_sfx_score:
    dc.b    $EA,$1A,$4A,$01,$2A,$04 ; Lock PSG Ch3; Note Off PSG Ch3; Set Instr PSG Chn3; Set Vol PSG Chn3
    dc.b    $0A,1*48,$FE,4 ; Note on PSG channel #3 ; Delay ticks
    dc.b    $FF ; Stop playback

; Background music
content_bgm_music:
	incbin  "src/spaceten/audio/stbgm.esf"

;==============================================================
; The sprite graphics tiles.
;==============================================================

content_tiles:
	include "src/spaceten/tiles/paddle.asm"		; Player paddle (2 sprites 2x4 each)
	include "src/spaceten/tiles/ball.asm"		; Game ball
	include "src/spaceten/tiles/numbers.asm"	; Numbers used for score
	include "src/shared/tiles/shane.asm"		; Shane logo from intro
	include "src/spaceten/tiles/menutile.asm"	; Main menu
	include "src/spaceten/tiles/planet.asm"		; Space background Plane A with stars and planet
	include "src/spaceten/tiles/stars.asm"		; Space background Plane B with stars
	include "src/spaceten/tiles/p1wins.asm"		; Text shown when player 1 wins
	include "src/spaceten/tiles/p2wins.asm"		; Text shown when player 2 wins
	include "src/spaceten/tiles/paused.asm"		; Text shown when game is paused

;==============================================================
; Map data for scroll planes.
;==============================================================
content_maps:
	include "src/shared/maps/shanemap.asm"		; Shane logo from intro
	include "src/spaceten/maps/menumap.asm"		; Map for Plane A for main menu
	include "src/spaceten/maps/spacemap.asm"	; Map for Plane A for gameplay background
	include "src/spaceten/maps/starsmap.asm"	; Map for Plane B for gameplay background
