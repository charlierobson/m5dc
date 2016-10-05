;----------------------------------------------------------------
;----------------------------------------------------------------

#include "commandIDs.h"
#include "einsdein.inc"

mod_mem:
    ld      b,COL_DYELLOW
    call    STBCOL
    call    CLRSC

mem_main:
    call    drawscreen
    .db     "1. Upload code to E000",13
    .db     "2. Run code at E000",13
    .db     "3. Zero E000-F000",13
    .db     "4. Fill E000-E100",13
    .db     "5.  XOR E000-E100",13
    .db     "6. Dump E000-E100",13
    .db     0

mem_loop:
    call    specialjump
    .dw     '1',mem_upload
    .dw     '2',$E000
    .dw     '3',mem_zero
    .dw     '4',mem_fill
    .dw     '5',mem_xor
    .dw     '6',mem_dump
    .dw     'q',main_setup
    .dw     'm',mem_main
    jr      mem_loop

    ; =====================

mem_upload:
    ld      hl,testprog
    ld      de,$E000
    ld      bc,testprogend-testprog
    ldir
    jp      mem_loop


mem_zero:
    ld      hl,$e000
    ld      de,$e001
    xor     a
    ld      (hl),a
    ld      bc,$fff
    ldir
    jp      mem_loop


mem_fill:
    ld      hl,$E000
    xor     a
    ld      b,a
-:
    ld      (hl),a
    inc     a
    inc     hl
    djnz    {-}
    jp      mem_loop


mem_xor:
    ld      hl,$E000
    ld      b,0
-:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    {-}
    jp      mem_loop


mem_dump:
    ld      hl,$E000
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

    ; ======================

testprog:
    nop
;;;    #incbin "ram-e000.bin"
testprogend: