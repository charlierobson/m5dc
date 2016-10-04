; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

    .org    $8000

main_setup:
    ld      b,1
    call    STBCOL
    call    CLRSC
    call    STRPRT
    .db     "Hello, world!",13,0

    call    ACECHI
    jp      0

STRPRT:
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



