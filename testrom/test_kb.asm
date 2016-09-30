;----------------------------------------------------------------
;----------------------------------------------------------------

test_kb_setup:
    rst     20h
    .db     "Press keys, or RESET",$ff
    .db     "Port / 7......0",$ff
    .db     $ff

test_kb_main:
    ld      de,$38C0
    ld      b,8

-:
    push    bc
    push    de

    ld      de,$7226

    ld      a,'$'
    ld      (de),a
    inc     de
    ld      a,'3'
    ld      (de),a
    inc     de

    ld      a,'8'
    sub     b
    ld      (de),a
    inc     de
    ld      a, ':'
    ld      (de),a
    inc     de
    xor     a
    ld      (de),a
    inc     de
    ld      (de),a
    inc     de
    ld      (de),a
    inc     de

    ld      a,$38
    sub     b
    ld      c,a
    in      a,(c)
    call    binout

    pop     de
    push    de
    ld      hl,$7226
    ld      b,15
    call    $1460

    pop     hl
    ld      de,$40
    add     hl,de
    ex      de,hl
    pop     bc
    djnz    {-}

    in      a,($50)
    and     a
    jp      p,test_kb_main

    jp      main_setup


;----------------------------------------------------------------


binout:
    push    bc
    ld      c,a
    ld      b,8

-:
    ld      a,'0'
    rl      c
    adc     a,0
    ld      (de),a
    inc     de
    djnz    {-}

    pop     bc
    ret

