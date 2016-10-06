;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

lineCount   .equ    $7302

msg_dirof:
	.db	    "DIR OF: ", 0

msg_pressakeydir:
	.db		"PRESS A KEY", 0

msg_erasepak:
	.fill	11,8
	.fill	11,' '
	.fill	11,8
	.db		0

mod_dir:
    ld      b,COL_DBLUE
    call    STBCOL
    call    CLRSC

    in      a,(IOP_DETECT)
    cp      42
    jp      nz,noEinsdein

+:
	ld	    a,CMD_BUFFER_PTR_RESET
	call	sendcmd

	ld		a,0
	out		(IOP_WRITEDAT),a

	ld	    a,CMD_DIR_READ_BEGIN
	call	sendcmd
	jp	    nz,error

	; sink the confusing drive spec '0:'
	in	    a,(IOP_READ)
	in	    a,(IOP_READ)

	ld		hl,msg_dirof
	call	TXTA
	call	printEntry
	call	PRCRLF

	ld	    a,2
	ld	    (lineCount),a	; #lines of listing already on the screen

nextEntry:
	ld	    a,CMD_DIR_READ_NEXT
	call	sendcmd

    cp      $40
    ret		z

    and     a
	jp      nz,error

	; there's one in the pipe - is there room to print it tho?
	ld	    a,(lineCount)
	cp	    15
	jr	    nz,theresSpace

	ld		hl,msg_pressakeydir
	call	TXTA
	call	ACECHI
	cp		'q'
	ret		z

	xor		a
	ld		(lineCount),a

	; erase the 'press a key' message (11 chars) using 11 backspaces, 11 spaces then another 11 backspaces
	ld		hl,msg_erasepak
	call	TXTA

theresSpace:
	call	printEntry
	ld		hl,lineCount
	inc		(hl)
	jr		nextEntry


; pull an ASCIIZ directory entry from the einSDein and print it
printEntry:
	; grab $20 characters 
	ld		bc,$2000+IOP_READ
	ld		hl,$7380
	push	hl

	di

-:  in      a,(IOP_READ)
	or		a
	jr		z,{+}
	or		32
	and		127
    ld      (hl),a
    inc     hl
    djnz    {-}
+:
	ei

	xor		a
	ld		(hl),a

	pop		hl
	call	DSPLTA
	jp		PRCRLF
