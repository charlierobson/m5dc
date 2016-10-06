
mod_mem:
    ld      b,COL_DGREEN
    call    STBCOL
    call    CLRSC

mem_main:
    ld      hl,mem_mainmenu
	call	TXTA
-:  call    specialjump
    jr      {-}

mem_mainmenu:
    .db     12
    .db     "1. Upload code to E000",13
    .db     "2. Run code at E000",13
    .db     "3. Zero E000-F000",13
    .db     "4. Fill E000-E100",13
    .db     "5.  XOR E000-E100",13
    .db     "6. Dump E000-E100",13
    .db     0
    .dw     '1',mem_upload
    .dw     '2',$E000
    .dw     '3',mem_zero
    .dw     '4',mem_fill
    .dw     '5',mem_xor
    .dw     '6',mem_dump
    .dw     'm',mem_main
    .dw     'q',retmm
    .db     $ff

    ; =====================

mem_upload:
    ld      hl,testprog
    ld      de,$E000
    ld      bc,testprogend-testprog
    ldir
    ret


mem_zero:
    ld      hl,$e000
    ld      de,$e001
    xor     a
    ld      (hl),a
    ld      bc,$fff
    ldir
    ret


mem_fill:
    ld      hl,$E000
    xor     a
    ld      b,a
-:
    ld      (hl),a
    inc     a
    inc     hl
    djnz    {-}
    ret


mem_xor:
    ld      hl,$E000
    ld      b,0
-:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    {-}
    ret


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
    #incbin "ramE000.bin"
testprogend:
