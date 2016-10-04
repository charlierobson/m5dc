; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

    .org    $E000

main_setup:
    ld      b,1
    call    STBCOL
    call    CLRSC
    call    STRPRT
	;        --------------------------------
    .db     13,13,"Hello, world! I was loaded from SD card!",13,13
	.db		"Press a key to return to ROM "
	.db		0

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



