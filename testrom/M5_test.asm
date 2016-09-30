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
    .db     "1.    Keyboard test",$ff
    .db     "2.    Memory test",$ff
    .db     "3.    IO test",$ff
    .db     "4.    Page 1",$ff
    .db     "5.    Page 2",$ff
    .db     "---   -----------------",$ff
    .db     $ff

main_main:
    rst     28h
    .dw     '1',test_kb_setup
    .dw     '2',test_mem_setup
    .dw     '3',test_io_setup
    .dw     '4',gop1
    .dw     '5',gop2
    .dw     $ff
    jr      main_main

gop1:
	ld		a,1
	jr		{+}

gop2:
	ld		a,2
+:
	ld		hl,gopX
	ld		de,$7ff0
	ld		bc,$10
	ldir
	ld		($7ff1),a
	jp		$7ff0

gopX:
	ld		a,0
	out		($7f),a
	jp		0

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


#include "test_mem.asm"
#include "test_kb.asm"
#include "test_io.asm"


    .asciimap ' ',' '

	.fill $4000-$
