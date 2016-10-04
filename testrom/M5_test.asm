; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

    .org    $2000

    ; cart header
    .db     0               ; cart identifier
    .dw     main_setup      ; start address
    .dw     $2e             ; IPL address
    jp      drawscreen      ; RST 20h (RST 4)
    jp      drawtext        ; RST 28h (RST 5)

;----------------------------------------------------------------


main_setup:
    rst     20h
    .db     "Key / Function",13
    .db     "---   -----------------",13
    .db     "1.    Load",13
    .db     "2.    Dir",13
    .db     "3.    Test",13
    .db     "---   -----------------",13
    .db     0
    ld      b,1
    call    STBCOL

main_main:
    call    specialjump
    .dw     '1',mod_load
    .dw     '2',mod_dir
    .dw     '3',mod_test
    .dw     $ff
    jr      main_main


;----------------------------------------------------------------


;----------------------------------------------------------------

; RST 20h

drawscreen:
    call    CLRSC

drawtext:
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

;----------------------------------------------------------------

PRHEX:
    push    hl
    ld      a,h
    call    PRHEXA
    pop     hl
    ld      a,l

PRHEXA:
    push    af
    srl     a
    srl     a
    srl     a
    srl     a
    call    {+}
    pop     af
+:
    and     15
    add     a,$90
    daa
    adc     a,$40
    daa
+:
    jp    DSPCHA

PRDECA:
    ld      l,a
    ld      h,0
    jr      prdec8bit

PRDECHL:
	ld	    bc,-10000
	call	{+}
	ld	    bc,-1000
	call	{+}
prdec8bit:
	ld	    bc,-100
	call	{+}
	ld	    bc,-10
	call	{+}
	ld	    bc,-1
+:
    ld	    a,'0'-1
-:	inc	    a
	add	    hl,bc
	jr	    c,{-}
	sbc	    hl,bc
    jp      DSPCHA

;----------------------------------------------------------------

specialjump:
    call    ACECHI          ; read key
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

sendcmd:
    out     (IOP_WRITECMD),a
-:
    in      a,(IOP_STATUS)
    and     4
    jr      nz,{-}

    in      a,(IOP_READ)
    and     a
    ret

;----------------------------------------------------------------


error:
    push    af
    rst     28h
    .db     13,"Error: ",0
    pop     af
    call    PRDECA

keyandback:
    rst     28h
    .db     13,"[press a key]",0
    call    ACECHI
    jp      main_setup

;----------------------------------------------------------------


#include "mod_load.asm"
#include "mod_dir.asm"
#include "mod_test.asm"

	.fill $4000-$
