;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

fnna:
    .db     "game.rom",0
fnnb:
    .db     "drops.bin",0
    
mod_load:
    ld      b,COL_DGREEN
    call    STBCOL
    call    CLRSC

    in      a,(IOP_DETECT)
    cp      42
    jr      z,{+}

    rst     20h
    .db     "No einSDein found",0
    jp      ld_post

+:
    rst     28h
    .db     "einSDein CPLD version ",0
    in      a,(IOP_VERSION)
    call    PRHEXA

    rst 20h
    .db     "1. DROPS",13
    .db     "2. TEST",13
    .db     "q. abort",13
    .db     0

    call    specialjump
    .dw     '1',ld_drops
    .dw     '2',ld_test
    .dw     'q',main_setup

ld_drops:
    ld      hl,fnnb
    push    hl
    jr      {+}

ld_test:
    ld      hl,fnna
    push    hl

+:
    rst     28h
    .db     13,"Sending filename...",0

    ; send filename
    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd

    pop     hl
    ld      bc,$4000+IOP_WRITEDAT
    otir

    rst     28h
    .db     13,"opening file...",0

    ; open file
    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd
    jp      nz,error

    ; load 8k to $E000 (512b x 16)

    rst     28h
    .db     13,"loading...",13,0

    ld      b,16
    ld      hl,$E000

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

    ;

ld_post:
    call    drawtext
    .db     13
    .db     "q - return",13
    .db     "E - execute code at $E000",13
    .db     "D - execute DROPS",13
    .db     "u - upload test code to $E000",13
    .db     "d - dump $E000",13
    .db     "f - fill $E000",13
    .db     "x - xor $E000",13
    .db     0

-:
    call    specialjump
    .dw     'E',$E000
    .dw     'D',gdrops
    .dw     'd',dumpE000
    .dw     'f',fillE000
    .dw     'x',xorE000
    .dw     'q',main_setup
    .dw     'u',uploader
    .dw     $ff
    jr      {-}

gdrops:
    ld      sp,0
    jp      $E88E

uploader:
    ld      hl,testprog
    ld      de,$E000
    ld      bc,$100
    ldir
    jp      ld_post


fillE000:
    ld      hl,$E000
    xor     a
    ld      b,a
-:
    ld      (hl),a
    inc     a
    inc     hl
    djnz    {-}
    jp      ld_post
    
xorE000:
    ld      hl,$E000
    xor     a
    ld      b,a
-:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    {-}
    jp      ld_post

dumpE000:
    ld      hl,$E000

    ld      b,16
--:
    push    bc
    ld      b,16
-:
    ld      a,(hl)
    inc     hl
    push    bc
    push    hl
    call    PRHEXA
    pop     hl
    pop     bc
    djnz    {-}

    pop     bc
    djnz    {--}

    jp      ld_post







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


testprog:
    #incbin "game.rom"