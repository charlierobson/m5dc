; Compile with BRASS
; http://www.benryves.com/bin/brass/
; > brass m5menu.asm m5menu.bin 

    ; remaps string data so that spaces are mapped to 0 in the binary,
    ; which is what the m5 recognises as a space character
    .asciimap ' ',0

#include "m5bios.inc"

; ram based variables
jumper      .equ $7600
linebuf     .equ $7780
curpage     .equ $77f0
curline     .equ $77f2
prevkey     .equ $77f4
iteminfo    .equ $7800

    .org    $8000

;----------------------------------------------------------------


main_setup:
    call    processrominfo

    xor     a
    ld      (curpage),a
    ld      (prevkey),a

	ld		hl,gopX
	ld		de,jumper
	ld		bc,$10
	ldir

    ld      b,12
    call    $0C97

main_main:
    call drawscreen
	;        --------========--------========
    .db     "M5-Multi II  By Sir Morris & Ola",$ff     ; <-- feel free to change this!
    .db     $ff

    call    printpage

    ld      hl,footer
    ld      de,linebuf
    ld      bc,33
    ldir
    ld      a,(curpage)
    add     a,'1'
    ld      (linebuf+29),a

    ld      hl,linebuf
    call println

    ld      ix,prevkey

-:
    ld      a,($702b)
    cp      (ix)
    jr      z,{-}

    ld      (ix),a

    ld      h,keyxlat/256
    ld      l,a
    ld      a,(hl)
    and     a
    jr      z,{-}

    cp      128
    jr      z,prevpage
    cp      129
    jr      z,nextpage

    dec     a
    ld      b,a				; 1
    sla     b				; 2
    sla     b				; 4
    ld      a,(curpage)		; 3
    call    x40				; 120
    add     a,2				; 122
    add     a,b				; 126
    ld      hl,iteminfo
    ld      l,a
    ld      a,(hl)

	ld		(jumper+1),a
	jp		jumper


prevpage:
    ld      a,(curpage)
    dec     a
    jr      {+}
nextpage:
    ld      a,(curpage)
    inc     a
+:
    and     3
    ld      (curpage),a
-:
    jp      main_main
    

printpage:
    ld      a,(curpage)
    call    x40
    ld      hl,iteminfo
    ld      l,a

    ld      b,10

-:
    ld      de,itemkeytab
    ld      e,b
    ld      a,(de)
    ld      (linebuf),a
    xor     a
    ld      (linebuf+1),a

    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl

    push    hl
    ld      hl,linebuf + 2
    call    copystring

    ld      hl,linebuf
    call println

    pop     hl
    inc     hl
    inc     hl
    djnz    {-}
    ret

copystring:
    ld      a,(de)
    ld      (hl),a
    cp      $ff
    ret     z
    inc     hl
    inc     de
    jr      copystring


footer:
    .db     "Press < and > to change page 1/4"
    .db     $ff


gopX:
    ; stub code which is copied into RAM.
    ; the value in A is modified as the rom bank number
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

; RST 28h

println:
    push    hl
    ld      de,(curline)
    ex      de,hl
    call    SETWRT
    ld      de,$40
    add     hl,de
    ex      de,hl
    ld      (curline),de
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
    ld      (curline),de
    pop     hl
-:
    call    println
    ld      a,(hl)
    bit     7,a
    jr      z,{-}

    inc     hl
    jp      (hl)


;----------------------------------------------------------------

; Set up a table of pointers to ROM info.
;
; Each rom is represented by 4 bytes,
;  .word pointer_to_description_string
;  .byte rom bank number
;  .byte unused
;
; This makes it easy to draw the menu items.
; item-description = iteminfo + curpage * 40 + item * 4
; 
processrominfo:
    ld      de,rominfo
    ld      hl,iteminfo
-:
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl

    call    findff
    inc     de
    ld      a,(de)
    inc     de
    cp      $ff
    ret     z

    ld      (hl),a
    inc     hl
    inc     hl
    jr      {-}

findff:
    ld      a,(de)
    cp      $ff
    ret     z
    inc     de
    jr      findff



; multiply A by 40 (a * 8 + a * 32)

x40:
    push    bc
    ld      b,a
    sla     b
    sla     b
    sla     b
    ld      a,b     ; a * 8
    sla     b
    sla     b
    add     a,b     ; + a * 32
    pop     bc
    ret


rominfo:
    ; 4 pages of 10 roms
    ; text description as it is to appear in the menu terminated by $FF, then the starting bank offset

    ; this menu data is generated along with the ROM binary using the 'mkcart' tool.

#include "../../m5multi/cart-binaries/big.asm"
    .db     $ff,$ff ; end of menu data

    .align  256
itemkeytab:
    .db     ' ','0','9','8','7','6','5','4','3','2','1'

    .align  256
keyxlat:
    .db     0,
    .db     0,0,0,0,0,0,0,0
    .db     1,2,3,4,5,6,7,8
    .db     0,0,0,0,0,0,0,0
    .db     0,0,0,0,0,0,0,0
    .db     0,0,0,0,0,0,0,128
    .db     9,10,0,0,129,0,0,0
    .db     0,0,0,0,0,0,0,0

    .asciimap ' ',' '

	.fill $4000-$
