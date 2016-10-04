; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

    .org    $8000


main_setup:
    rst     20h
    .db     "Hello, world!",13,0
    ld      b,1
    call    STBCOL

-:  jr      {-}