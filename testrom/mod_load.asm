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
    out     (IOP_WRITECMD),a

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

-:
    push    bc

    ; prepare next 512 bytes
    ld      a,CMD_FILE_READ_512
    call    sendcmd
    jp      nz,error

    ; read next 512 bytes
    ld      bc,$0000+IOP_READ
    inir
    inir

    push    hl
    ld      a,'*'
    call    DSPCHA
    pop     hl

    pop     bc
    djnz    {-}

    jp      $8000




noeinsdein:
    rst     20h
    .db     "No einSDein found",0
    jp      keyandback
