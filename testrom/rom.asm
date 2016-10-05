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
    in      a,(IOP_DETECT)
    cp      42
    jr      nz,uploadDefault

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

;----------------------------------------------------------------

uploadDefault:
    ld      hl,bin_d
    ld      de,DST
    ld      bc,bin_d_end-bin_d
    ldir
    jp      DST

;----------------------------------------------------------------

drawscreen:
    call    CLRSC

drawtext:
    pop     hl
    jr      {+}
-:
    call    DSPCHA
    inc     hl
+:
    ld      a,(hl)
    or      a
    jr      nz,{-}
    inc     hl
    jp      (hl)

;----------------------------------------------------------------

fnna:
    .db     "util.rom",0

bin_d:
    #incbin "ram7800.bin"
bin_d_end:
