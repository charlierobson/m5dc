;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

fnna:
    .db     "game.rom",0

mod_load:
    ld      de,tv1
    ld      bc,9
    call    crc16

    ld      de,tv2
    ld      bc,256
    call    crc16

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

ld_post:
    call    drawtext
    .db     13
    .db     "x - execute code at $8000",13
    .db     "1 - dump $8000",13
    .db     "2 - dump $8200",13
    .db     "3 - fill $8000",13
    .db     "4 - xor $8000",13
    .db     "q - return",13
    .db     0

-:
    call    specialjump
    .dw     'x',$8000
    .dw     '1',dump8000
    .dw     '2',dump8100
    .dw     '3',fill8000
    .dw     '4',xor8000
    .dw     'q',main_setup
    .dw     $ff
    jr      {-}

    jp      $8000

fill8000:
    ld      hl,$8000
    xor     a
    ld      b,a
-:
    ld      (hl),a
    inc     a
    inc     hl
    djnz    {-}
    jp      ld_post
    
xor8000:
    ld      hl,$8000
    xor     a
    ld      b,a
-:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    {-}
    jp      ld_post

dump8000:
    ld      hl,$8000
    jr      dump256
dump8100:
    ld      hl,$8100
    jr      dump256

dump256:
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

tv1:
    .byte   "123456789",0,0,0,0,0,0,0

tv2:
	.byte   $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B
	.byte   $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17
	.byte   $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23
	.byte   $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
	.byte   $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B
	.byte   $3C, $3D, $3E, $3F, $40, $41, $42, $43, $44, $45, $46, $47
	.byte   $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53
	.byte   $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
	.byte   $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B
	.byte   $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77
	.byte   $78, $79, $7A, $7B, $7C, $7D, $7E, $7F, $80, $81, $82, $83
	.byte   $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
	.byte   $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B
	.byte   $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7
	.byte   $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1, $B2, $B3
	.byte   $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
	.byte   $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB
	.byte   $CC, $CD, $CE, $CF, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7
	.byte   $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF, $E0, $E1, $E2, $E3
	.byte   $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
	.byte   $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB
	.byte   $FC, $FD, $FE, $FF
