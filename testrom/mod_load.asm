;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

fnna:
    .db     "game.rom",0

mod_load:
    ld      b,COL_DGREEN
    call    STBCOL
    call    CLRSC

    in      a,(IOP_DETECT)
    cp      42
    jp      nz,noeinsdein

    rst     28h
    .db     "einSDein CPLD version ",0
    in      a,(IOP_VERSION)
    call    PRHEXA

    rst     28h
    .db     13,"Sending filename...",0

    ; send filename
    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd

    ld      hl,fnna
    ld      bc,$4000+IOP_WRITEDAT
    otir

    rst     28h
    .db     13,"opening file...",0

    ; open file
    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd
    jp      nz,error

    ; load 8k to $8000 (512b x 16)

    rst     28h
    .db     13,"loading...",13,0

    ld      b,16
    ld      hl,$8000

ld_main:
    push    bc

    ; prepare next 512 bytes
    ld      a,CMD_FILE_READ_512
    call    sendcmd
    jp      nz,error

    push    hl

    di

    ; read next 512 bytes
    ld      bc,$0000+IOP_READ
-:  in      a,(IOP_READ)
    ld      (hl),a
    inc     hl
    djnz    {-}
-:  in      a,(IOP_READ)
    ld      (hl),a
    inc     hl
    djnz    {-}

    ei

    pop     de
    push    hl

    ld      bc,$200
    call    crc16

    call    PRHEX
    ld      a,32
    call    DSPCHA

    pop     hl

    pop     bc
    djnz   ld_main

    rst     28h
    .db     13,"[press a key to execute]",0
    call    ACECHI

    jp      $8000




noeinsdein:
    rst     20h
    .db     "No einSDein found",0
    jp      keyandback





	; in: de = data ptr, bc = data length
	; out: hl = crc16-ccitt (poly 1021)

crc16:
	ld	    hl,FFFFh
--:
    push    bc
	ld	    a,(de)
	inc	    de
	xor	    h
	ld	    h,a
	ld	    b,8
-:
	add	    hl,hl
	jr	    nc,{+}

	ld	    a,h
	xor	    10h
	ld	    h,a
	ld	    a,l
	xor	    21h
	ld      l,a
+:
	djnz	{-}

    pop     bc
	dec	    bc
    ld      a,b
    or      c
	jr	    nz,{--}

    ret
