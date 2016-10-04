;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

mod_test:
    ld      b,COL_DRED
    call    STBCOL
    call    CLRSC

    rst     20h
    .db     "Key / Function",13
    .db     "---   -----------------",13
    .db     "1.    IOP_DETECT",13
    .db     "2.    IOP_VERSION",13
    .db     "3.    CMD_INTERFACE_STATUS",13
    .db     "4.    CMD_BUFFER_PTR_RESET",13
    .db     "5.    Put",13
    .db     "6.    CMD_BUFFER_READ",13
    .db     "7.    Get",13
    .db     "8.    CMD_DBG_SHOW_BP",13
    .db     "Q.    Return",13
    .db     "---   -----------------",13
    .db     0

test_loop:
    call    specialjump
    .dw     '1',mod_iopdetect
    .dw     '2',mod_iopversion
    .dw     '3',mod_cmd_interface_status
    .dw     '4',mod_cmd_buffer_ptr_reset
    .dw     '5',mod_put
    .dw     '6',mod_cmd_buffer_read
    .dw     '7',mod_get
    .dw     '8',mod_cmd_dbg_show_bp
    .dw     'q',main_setup
    .dw     $ff
    jr      test_loop

mod_iopdetect:
    in      a,(IOP_DETECT)
    call    PRHEXA
    ld      a,32
    call    DSPCHA
    jp      test_loop

mod_iopversion:
    in      a,(IOP_VERSION)
    call    PRHEXA
    ld      a,32
    call    DSPCHA
    jp      test_loop

mod_cmd_interface_status:
    ld      a,CMD_INTERFACE_STATUS
    call    sendcmd
    call    PRHEXA
    ld      a,32
    call    DSPCHA
    jp      test_loop

mod_cmd_buffer_ptr_reset:
    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd
    jp      test_loop

mod_cmd_dbg_show_bp:
    ld      a,CMD_DBG_SHOW_BP
    call    sendcmd
    jp      test_loop

mod_cmd_buffer_read:
    ld      a,CMD_BUFFER_READ
    call    sendcmd
    jp      test_loop

mod_put:
    ld      a,r
    out     (IOP_WRITEDAT),a
    jp      test_loop

mod_get:
    in      a,(IOP_READ)
    call    PRHEXA
    ld      a,32
    call    DSPCHA
    jp      test_loop
