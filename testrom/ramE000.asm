; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

    .org    $E000

main_setup:
	ld      hl,msg
    call    DSPLTA
    ld      b,COL_BLACK
    call    STBCOL
    call    ACECHI          ; read key
    jp      0

msg:
    .db     "Hello, world!",13,0
