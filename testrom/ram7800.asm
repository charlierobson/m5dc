; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

FLG	.equ	$72ff

    .org    $7800

main_setup:
	call	drawscreen
    .db     "1.    Load",13
    .db     "2.    Dir",13
    .db     "3.    Mem",13
    .db     "4.    Test",13
    .db     0
    ld      b,COL_BLACK
    call    STBCOL

main_main:
    call    specialjump
    .dw     '1',mod_load
    .dw     '2',mod_dir
    .dw     '3',mod_mem
    .dw     '4',mod_test
    .dw     $ff
    jr      main_main

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

PRSPC:
    ld      a,32
    jp      DSPCHA

PRCRLF:
    ld      a,13
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

error:
    push    af
	call	drawtext
    .db     13,"Error: ",0
    pop     af
    call    PRDECA

keyandback:
	call	drawtext
    .db     13,"[press a key]",0
    call    ACECHI
    jp      main_setup

;----------------------------------------------------------------

#include "mod_load.asm"
#include "mod_mem.asm"
#include "mod_dir.asm"
#include "mod_test.asm"
