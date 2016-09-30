;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

fnna:
    .db     "game.rom",0

mod_load:
    call    cls
    
    ; send filename
    ld      hl,fnna
    ld      a,CMD_BUFFER_PTR_RESET
    out     (IOP_WRITECMD),a
    ld      bc,$4000|IOP_WRITEDAT
    otir

    ; open file
    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd

    ; load 8k to $8000 (512b x 16)

    ld      b,16
    ld      hl,$8000

-:
    push    bc

    ; prepare next 512 bytes
    ld      a,CMD_FILE_READ_512
    call    sendcmd

    ; read next 512 bytes
    ld      bc,IOP_READ
    inir
    inir

    pop     bc
    djnz    {-}

    jp      $8000


sendcmd:
    out     (IOP_WRITECMD),a
-:
    in      a,(IOP_STATUS)
    and     2
    jr      nz,{-}

    in      a,(IOP_READ)
    and     a
    ret
