; Start of ROM
ROM_Start:

;==============================================================
; CPU VECTOR TABLE
;==============================================================
	dc.l	0x00FFE000			; Initial stack pointer value
	dc.l	CPU_EntryPoint		; Start of program
	dc.l	CPU_Exception 		; Bus error
	dc.l	CPU_Exception 		; Address error
	dc.l	CPU_Exception 		; Illegal instruction
	dc.l	CPU_Exception 		; Division by zero
	dc.l	CPU_Exception 		; CHK CPU_Exception
	dc.l	CPU_Exception 		; TRAPV CPU_Exception
	dc.l	CPU_Exception 		; Privilege violation
	dc.l	INT_Null			; TRACE exception
	dc.l	INT_Null			; Line-A emulator
	dc.l	INT_Null			; Line-F emulator
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Spurious exception
	dc.l	INT_Null			; IRQ level 1
	dc.l	INT_Null			; IRQ level 2
	dc.l	INT_Null			; IRQ level 3
	dc.l	INT_HInterrupt		; IRQ level 4 (horizontal retrace interrupt)
	dc.l	INT_Null  			; IRQ level 5
	dc.l	INT_VInterrupt		; IRQ level 6 (vertical retrace interrupt)
	dc.l	INT_Null			; IRQ level 7
	dc.l	INT_Null			; TRAP #00 exception
	dc.l	INT_Null			; TRAP #01 exception
	dc.l	INT_Null			; TRAP #02 exception
	dc.l	INT_Null			; TRAP #03 exception
	dc.l	INT_Null			; TRAP #04 exception
	dc.l	INT_Null			; TRAP #05 exception
	dc.l	INT_Null			; TRAP #06 exception
	dc.l	INT_Null			; TRAP #07 exception
	dc.l	INT_Null			; TRAP #08 exception
	dc.l	INT_Null			; TRAP #09 exception
	dc.l	INT_Null			; TRAP #10 exception
	dc.l	INT_Null			; TRAP #11 exception
	dc.l	INT_Null			; TRAP #12 exception
	dc.l	INT_Null			; TRAP #13 exception
	dc.l	INT_Null			; TRAP #14 exception
	dc.l	INT_Null			; TRAP #15 exception
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	dc.l	INT_Null			; Unused (reserved)
	
;==============================================================
; SEGA MEGA DRIVE ROM HEADER
;==============================================================
	dc.b	"SEGA MEGA DRIVE "                                 ; Console name
	dc.b	"IEQUALSHANE.    "                                 ; Copyright holder and release date
	dc.b	"SPACE TENNIS                                    " ; Domestic name
	dc.b	"SPACE TENNIS                                    " ; International name
	dc.b	"GM XXXXXXXX-XX"                                   ; Version number
	dc.w	0x0000                                             ; Checksum
	dc.b	"J               "                                 ; I/O support
	dc.l	ROM_Start                                          ; Start address of ROM
	dc.l	ROM_End-1                                          ; End address of ROM
	dc.l	0x00FF0000                                         ; Start address of RAM
	dc.l	0x00FF0000+0x0000FFFF                              ; End address of RAM
	dc.l	0x00000000                                         ; SRAM enabled
	dc.l	0x00000000                                         ; Unused
	dc.l	0x00000000                                         ; Start address of SRAM
	dc.l	0x00000000                                         ; End address of SRAM
	dc.l	0x00000000                                         ; Unused
	dc.l	0x00000000                                         ; Unused
	dc.b	"                                        "         ; Notes (unused)
	dc.b	"  E             "                                 ; Country codes

; Map from start of RAM
	RSSET 0x00FF0000

;==============================================================
; Source files.
;==============================================================

	; Library of re-usable code used by the game
	include "src/genlib/genlib.asm"

	; Game sources
	include "src/spaceten/main.asm"		; Entry point into the program
	include "src/shared/intro.asm"		; The first scene with Shane logo
	include "src/spaceten/menu.asm"		; The main meny
	include "src/spaceten/game.asm"		; The actual gameplay

	; Content. Best at end of file due to the large content size.
	include "src/spaceten/content.asm"

; The end of ROM
ROM_End: