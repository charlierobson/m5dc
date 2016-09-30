;----------------------------------------------------------------
;----------------------------------------------------------------

test_io_setup:
    rst     20h
    .db     "Choose an option",$ff
    .db     "--------------------------",$ff
    .db     "1. Exercise nEXIOA ($60)",$ff
    .db     "2. Exercise nEXIOB ($70)",$ff
    .db     "--------------------------",$ff
    .db     "Q. Return to main menu",$ff
    .db     $ff

test_io_main:
    rst     28h
    .dw     '1',test_exioa
    .dw     '2',test_exiob
    .dw     'q',main_setup
    .dw     $ff
    jr      test_io_main


test_exioa:
    rst     20h
    .db     "Exercising nEXIOA",$ff
    .db     "Press space...",$ff
    .db     $ff

    ld      bc,$6060
    jr      test_exioX

test_exiob:
    rst     20h
    .db     "Exercising nEXIOB",$ff
    .db     "Press space...",$ff
    .db     $ff

    ld      bc,$7070

test_exioX:
    in      a,(c)
    out     (c),a

    inc     c
    ld      a,c
    and     $0f
    or      b
    ld      c,a

    in      a,($30)
    bit     6,a
    jr      z,test_exioX

    jp      test_io_setup
