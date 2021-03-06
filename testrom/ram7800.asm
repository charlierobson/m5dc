; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

#include "../commandids.h"

MNKJST  .equ    $7300
DIRLC   .equ    $7302
SDIOB   .equ    $7304

    .org    $7800

main:
    ld      hl,mainmenu
	call	TXTA
    call    specialjump
    jr      main

mainmenu:
    .db     12
    .db     "1.    Load",13
    .db     "2.    Dir",13
    .db     "3.    Mem",13
    .db     "4.    Test",13
    .db     0
    .dw     '1',mod_load
    .dw     '2',mod_dir
    .dw     '3',mod_mem
    .dw     '4',mod_test
    .dw     $ff


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
    jp      DSPCHA

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

sendcmd:
#ifdef USEIO
    out     (IOP_WRITECMD),a
-:
    in      a,(IOP_STATUS)
    and     4
    jr      nz,{-}

    in      a,(IOP_READ)
    and     a
#else
    xor     a
#endif
    ret

;----------------------------------------------------------------

-:
    call    DSPCHA
    inc     hl
TXTA:
    ld      a,(hl)
    or      a
    jr      nz,{-}
    inc     hl

    ld      (MNKJST),hl
    ret

;----------------------------------------------------------------

specialjump:
    call    ACECHI          ; read key
    ld      hl,(MNKJST)
-:
    cp      (hl)            ; matched key?
    inc     hl              ; (skip key def)
    inc     hl
    jr      nz,{+}

    ld      a,(hl)          ; key is matched, retrieve jump address
    inc     hl
    ld      h,(hl)
    ld      l,a
    jp      (hl)

+:
    inc     hl              ; skip jump address
    inc     hl   
    bit     7,(hl)          ; table end?
    jr      z,{-}
    jr      specialjump

;----------------------------------------------------------------

error:
    push    af
    ld      hl,msg_error
	call	TXTA
    pop     af
    call    PRDECA
    jr      keyandbacktomm

noeinsdein:
    ld      hl,msg_noeinsdein
    call    TXTA

    ; fall through

keyandbacktomm:
    ld      hl,msg_pressakey
	call	TXTA
    call    ACECHI

    ; fall through

retmm:
    pop     hl
    jp      main



msg_error:
    .db     13,"Error: ",0

msg_noeinsdein:
    .db     "No einSDein found",0

msg_pressakey:
    .db     13,"[press a key]",0

;----------------------------------------------------------------

#include "mod_load.asm"
#include "mod_mem.asm"
#include "mod_dir.asm"
#include "mod_test.asm"
