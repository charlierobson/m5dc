; Compile with BRASS
; http://www.benryves.com/bin/brass/

    .asciimap ' ',0

#include "m5bios.inc"

    .org    $2000

    ; cart header
    .db     0               ; cart identifier
    .dw     main_setup      ; start address
    .dw     $2e             ; IPL address
    jp      drawscreen      ; RST 20h (RST 4)
    jp      specialjump     ; RST 28h (RST 5)

;----------------------------------------------------------------


main_setup:
    rst     20h
    .db     "Key / Function",$ff
    .db     "---   -----------------",$ff
    .db     "1.    Load",$ff
    .db     "---   -----------------",$ff
    .db     $ff

main_main:
    rst     28h
    .dw     '1',mod_load
    .dw     $ff
    jr      main_main

;----------------------------------------------------------------

cls:
    xor     a

clstochar:
    ld      hl,$3800
    ld      de,$40
    ld      b,11
-:
    call    clearline
    add     hl,de
    djnz    {-}

    ; fall through

clearline:
    push    bc
    push    af
    call    SETWRT
    pop     af
    ld      b,$20
-:
    out     ($10),a
    djnz    {-}
    pop     bc
    ret


;----------------------------------------------------------------


println:
    push    hl
    ex      de,hl
    call    SETWRT
    ld      de,$40
    add     hl,de
    ex      de,hl
    pop     hl
    jr      {+}
-:    
    out     ($10),a
    inc     hl
+:
    ld      a,(hl)
    cp      $ff
    jr      nz,{-}
    inc     hl
    ret    


;----------------------------------------------------------------

; RST 20h

drawscreen:
    call    cls
    ld      de,$3800
    pop     hl
-:
    call    println
    ld      a,(hl)
    bit     7,a
    jr      z,{-}

    inc     hl
    jp      (hl)



;----------------------------------------------------------------

; RST 28h

specialjump:
    call    WTKDTC          ; read key
    pop     hl              ; get pointer to key/jump table
-:
    cp      (hl)            ; matched key?
    inc     hl              ; (skip key def)
    inc     hl
    jr      nz,{+}

    ld      a,(hl)          ; jey is matched, retrieve jump address
    inc     hl
    ld      h,(hl)
    ld      l,a
    jp      (hl)

+:
    inc     hl              ; skip jump address
    inc     hl   
    bit     7,(hl)          ; table end?
    jr      z,{-}

    inc     hl
    jp      (hl)


;----------------------------------------------------------------

    .asciimap ' ',' '

#include "mod_load.asm"

	.fill $4000-$
