;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

lineCount   .equ    $C000

rootstr:
    .db     "/",0

mod_dir:
    ld      b,COL_DBLUE
    call    STBCOL
    call    CLRSC

	ld	    a,CMD_BUFFER_PTR_RESET
	call	sendcmd

    ld      hl,rootstr
	ld	    bc,$C000+IOP_WRITEDAT
	otir

	ld	    a,CMD_DIR_READ_BEGIN
	call	sendcmd
	jp	    z,error

	; sink the confusing drive spec '0:'
	in	    a,(IOP_READ)
	in	    a,(IOP_READ)

	rst     28h
	.db	    "DIR OF: ", 0

	call	printEntry
	call	newline

	ld	    a,2
	ld	    (lineCount),a	; #lines of listing already on the screen

nextEntry:
	ld	    a,CMD_DIR_READ_NEXT
	call	sendcmd
    cp      $40
    jp      z,keyandback
    and     a
	jp      nz,error

	; there's one in the pipe - is there room to print it tho?
	ld	    a,(lineCount)
	cp	    15
	jr	    nz,theresSpace

	rst     28h
	.db		"PRESS A KEY", 0

	call	ACECHI
    or      32
	cp		'Q'
	jp		z,main_setup

	xor		a
	ld		(lineCount),a

	; erase the 'press a key' message (11 chars) using 11 backspaces, 11 spaces then another 11 backspaces
	rst     28h
	.fill	11,8
	.fill	11,' '
	.fill	11,8
	.db		0

theresSpace:
	call	printEntry
	ld		hl,lineCount
	inc		(hl)
	jr		nextEntry


; pull an ASCIIZ directory entry from the einSDein and print it
printEntry:
	; grab $20 characters 
	ld		bc,$2000+IOP_READ
	ld		hl,$c010
	push	hl
	inir
	pop		hl
	call	DSPLTA
	; falls through to newline

newline:
	ld		a,13
	jp		DSPCHA