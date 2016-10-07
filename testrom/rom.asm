; Compile with BRASS
; http://www.benryves.com/bin/brass/

#include "m5bios.inc"
#include "einsdein.inc"

#include "../commandids.h"

; todo:
;  kb buffer flush

DST .equ    $7800

    .org    $2000

    ; cart header
    .db     0               ; cart identifier
    .dw     main_start      ; start address
    .dw     $2e             ; IPL address (wassat?)

;----------------------------------------------------------------

main_start:
    ; test left shift
    in      a,($30)
    and     4
    jr      z,{+}

    ; left shift is pressed, upload ROM copy of util
    ; make background green to distinguish from sd card version
    ld      hl,bin_d
    ld      de,DST
    ld      bc,bin_d_end-bin_d
    ldir

    ld      b,COL_DGREEN
    call    STBCOL
    jp      DST
    
+:  ; test for einSDein - error 1 if not found
    ld      ix,E1
    in      a,(IOP_DETECT)
    cp      42
    jr      nz,error

    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd
    ld      hl,fnna
    ld      bc,$4000+IOP_WRITEDAT
    otir

    ; open file - error 2 if open fails
    ld      ix,E2
    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd
    jp      nz,error

    ; load at most 2k (4*512b) to DST
    ld      b,4
    ld      hl,DST

    di

ld_main:
    ; prepare next 512 bytes - error 3 on failure
    ld      ix,E3
    ld      a,CMD_FILE_READ_512
    call    sendcmd

    cp      $40
    jr      z,ld_done

    or      a
    jp      nz,error

    push    bc
    push    hl

    ; read next 512 bytes
    ; for some reason INIR instruction doesn't work when run in ROM. Timing?
    ld      bc,$0000+IOP_READ
-:  in      a,(c)
    ld      (hl),a
    inc     hl
    djnz    {-}
-:  in      a,(c)
    ld      (hl),a
    inc     hl
    djnz    {-}

    pop     de
    push    hl

    ; checksum the loaded data
    ld      bc,$200
    call    crc16

    ; check CRC. error 4 if sum doesn't match
    ld      ix,E4
    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd
    ld      a,l
    out     (IOP_WRITEDAT),a
    ld      a,h
    out     (IOP_WRITEDAT),a
    ld      a,CMD_FILE_VERIFYCRC
    call    sendcmd
    jp      nz,error

    pop     hl
    pop     bc
    djnz    ld_main

ld_done:
    ei

    jp      DST

;----------------------------------------------------------------

sendcmd:
    ; initiate command
    out     (IOP_WRITECMD),a

-:  ; wait for command status bit to clear
    in      a,(IOP_STATUS)
    and     4
    jr      nz,{-}

    ; collect return code
    in      a,(IOP_READ)
    and     a
    ret

;----------------------------------------------------------------

error:
    ; red bg
    ld      b,COL_DRED
    call    STBCOL

    ; error header + crlf
    ld      hl,E0
    call    DSPLTA
    call    CRLF

    ; error message
    push    ix
    pop     hl
    call    DSPLTA
    call    CRLF

    ; error footer
    ld      hl,EX
    call    DSPLTA

    ; wait key press
    call    ACECHI

    ; reset
    jp      0


CRLF:
    ld      a,13
    jp      DSPCH


E0: .byte   "Error:",13
E1: .byte   " SD-X not found.",13
E2: .byte   " Secondary loader missing.",13
E3: .byte   " Loader read error.",13
E4: .byte   " Loader checksum error.",13
EX: .byte   "Press a key ",13

;----------------------------------------------------------------

crc16:
	ld	    hl,FFFFh
--:
    push    bc
	ld	    a,(de)
	inc	    de
	xor	    h
	ld	    h,a
	ld	    b,8
-:
	add	    hl,hl
	jr	    nc,{+}

	ld	    a,h
	xor	    10h
	ld	    h,a
	ld	    a,l
	xor	    21h
	ld      l,a
+:
	djnz	{-}

    pop     bc
	dec	    bc
    ld      a,b
    or      c
	jr	    nz,{--}

    ret

;----------------------------------------------------------------

fnna:
    .db     "ram7800.bin",0

bin_d:
    #incbin "ram7800.bin"
bin_d_end:
