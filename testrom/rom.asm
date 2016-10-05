; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"
#include "commandids.h"

FLG	.equ	$77ff
DST .equ    $7800

    .org    $2000

    ; cart header
    .db     0               ; cart identifier
    .dw     main_start      ; start address
    .dw     $2e             ; IPL address

;----------------------------------------------------------------

main_start:
	xor		a
    ld      hl,FLG
    bit     7,(hl)
    ld      (hl),a
    jr      z,{+}

    ld      sp,0
    dec     hl
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    jp      (hl)

fnna:
    .db     "util.rom",0

+:
    in      a,(IOP_DETECT)
    cp      42
    jr      nz,error

    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd

    ld      hl,fnna
    ld      bc,$4000+IOP_WRITEDAT
    otir

    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd
    jp      nz,error

    ; load 2k to DST

    ld      b,4
    ld      hl,DST

ld_main:
    push    bc

    ; prepare next 512 bytes
    ld      a,CMD_FILE_READ_512
    call    sendcmd
    jp      nz,error

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

    pop     bc
    djnz   ld_main

    ei

    jp      DST

;----------------------------------------------------------------

sendcmd:
    out     (IOP_WRITECMD),a
-:
    in      a,(IOP_STATUS)
    and     4
    jr      nz,{-}

    in      a,(IOP_READ)
    and     a
    ret

;----------------------------------------------------------------


error:
    ld      b,COL_DRED
    call    STBCOL
-:  jr      {-}
