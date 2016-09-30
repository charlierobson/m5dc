;----------------------------------------------------------------
;----------------------------------------------------------------

test_mem_setup:
    rst     20h
    .db     "Choose an option",$ff
    .db     "--------------------------",$ff
    .db     "1. Exercise nROM2",$ff
    .db     "2. Exercise nEXTROM",$ff
    .db     "3. Test RAM at 32k",$ff
    .db     "--------------------------",$ff
    .db     "Q. Return to main menu",$ff
    .db     $ff

test_mem_main:
    rst     28h
    .dw     '1',test_rom2
    .dw     '2',test_romext
    .dw     '3',test_ram
    .dw     'q',main_setup
    .dw     $ff
    jr      test_mem_main


test_rom2:
    rst     20h
    .db     "Exercising nROM2",$ff
    .db     "Press space...",$ff
    .db     $ff

    ld      hl,$5000        ; rom2 from $4000-$5fff
    jr      test_romX

test_romext:
    rst     20h
    .db     "Exercising nROMEXT",$ff
    .db     "Press space...",$ff
    .db     $ff

    ld      hl,$6800        ; romext from $6000-$6fff

test_romX:
    ld      a,(hl)
    in      a,($30)
    bit     6,a
    jr      z,test_romX

    jp      test_mem_setup



test_ram:
    rst     20h
    .db     "Testing RAM at $8000..$FFFF",$ff
    .db     $ff

    ld      hl,$8000        ; ram

-:
    ld      a,$aa
    ld      (hl),a
    cp      (hl)
    jr      nz,ram_error
    xor     $ff
    ld      (hl),a
    cp      (hl)
    jr      nz,ram_error
    
    inc     hl
    ld      a,h
    or      l
    jr      nz,{-}

    rst     20h
    .db     "RAM OK, exercising RAMCS.",$ff
    .db     "Press space...",$ff
    .db     $ff

-:
    ld      a,(hl)
    inc     hl
    ld      a,h
    or      $80
    ld      h,a

    in      a,($30)
    bit     6,a
    jr      z,{-}

    jp      test_mem_setup


ram_error:
    ld      a,h
    or      l
    cp      $80
    jr      z,ram_notfound

    rst     20h
    .db     "RAM faulty",$ff
    .db     "Press space...",$ff
    .db     $ff

-:
    in      a,($30)
    bit     6,a
    jr      z,{-}

    jp      test_mem_setup


ram_notfound:
    rst     20h
    .db     "RAM not found",$ff
    .db     "Press space...",$ff
    .db     $ff

    jr      {-}
