
msg_dirof:
	.db	    "DIR OF: ", 0

msg_pressakeydone:
	.db		"DONE - ", 0

msg_pressakeydir:
	.db		"PRESS SPACE", 0

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
	#ifdef USEIO
    cp      42
    jp      nz,noEinsdein
	#endif

+:
	ld	    a,CMD_BUFFER_FLUSH
	call	sendcmd

	ld	    a,CMD_DIR_READ_BEGIN
	call	sendcmd
	jp	    nz,error

	ld		hl,msg_dirof
	call	TXTA
	call	printEntry
	call	PRCRLF

	ld	    a,2
	ld	    (DIRLC),a	; #lines of listing already on the screen

nextEntry:
	ld	    a,CMD_DIR_READ_NEXT
	call	sendcmd

	ld		ix,msg_pressakeydone
    cp      $40
    jr		z,activechoose

    and     a
	jp      nz,error

	; there's one in the pipe - is there room to print it tho?
	ld	    a,(DIRLC)
	cp	    23
	jr	    nz,theresSpace

	ld		ix,msg_pressakeydir
	call	activechoose

	xor		a
	ld		(DIRLC),a

	; erase the 'press a key' message (11 chars) using 11 backspaces, 11 spaces then another 11 backspaces
	ld		hl,msg_erasepak
	call	TXTA

theresSpace:
	call	printEntry
	ld		hl,DIRLC
	inc		(hl)
	jr		nextEntry

; -----------------------------------------------------------------------------
CURPS	.equ	$70a6
CURPSCP	.equ	$7340

activechoose:
	push	ix
	pop		hl
	call	TXTA
	ld		hl,(CURPS)
	ld		(CURPSCP),hl

-:	call	ACECHI
	cp		$1e
	jr		z,{+}
	cp		$1f
	jr		z,{+}
	cp		13
	jr		z,{++}
	cp		' '
	jr		nz,{-}
	ld		hl,(CURPSCP)
;	ld		(CURPS),hl
	ret

+:	call	DSPCHA
	jr		{-}

++:	ld		de,(CURPS)
	ld		d,0
	ld		hl,SDIOB
	call	RDSTM
	dec		hl
	xor		a
	ld		(hl),a
	jr		{-}

; -----------------------------------------------------------------------------

; pull an ASCIIZ directory entry from the einSDein and print it
printEntry:
	; grab $20 characters 
	ld		bc,$2000+IOP_READ
	ld		hl,SDIOB
	push	hl

	di
	#ifdef USEIO
	inir
	#else
	push de
	push bc
	ld hl,fakedirent
	ld de,SDIOB
	ld bc,10
	ldir
	ld a,($7400)
	inc a
	and 31
	ld ($7400),a
	add a,'0'
	ld (SDIOB),a
	ex de,hl
	pop bc
	pop de
	#endif
	ei

	xor		a
	ld		(hl),a

	pop		hl
	call	DSPLTA
	jp		PRCRLF


#ifndef USEIO
fakedirent:
	.byte "-FAKE.BIN",0
#endif
