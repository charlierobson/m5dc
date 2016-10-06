
fnna:
    .db     "ramE000.bin",0
fnnb:
    .db     "drops.bin",0

msg_escpldv:
    .db     "einSDein CPLD version ",0

msg_openingfile:
    .db     13,"opening file...",0

msg_loading:
    .db     13,"loading...",13,0

msg_sendingfn:
    .db     13,"Sending filename...",0



mod_load:
    ld      b,COL_BLACK
    call    STBCOL
    call    CLRSC

    in      a,(IOP_DETECT)
    cp      42
    jp      nz,noeinsdein

    ld      hl,msg_escpldv
	call	TXTA
    in      a,(IOP_VERSION)
    call    PRHEXA

    ld      hl,ld_menu
	call	TXTA
-:  call    specialjump
    jr      {-}

ld_menu:
    .db     12
    .db     "1. DROPS",13
    .db     "2. TEST",13
    .db     0
    .dw     '1',ld_drops
    .dw     '2',ld_test
    .dw     'q',retmm
    .db     $ff

ld_drops:
    ld      hl,fnnb
    push    hl
    jr      {+}

ld_test:
    ld      hl,fnna
    push    hl

+:
    ld      hl,msg_sendingfn
	call	TXTA

    ; send filename
    ld      a,CMD_BUFFER_PTR_RESET
    call    sendcmd

    pop     hl
    ld      bc,$4000+IOP_WRITEDAT
    otir

    ld      hl,msg_openingfile
	call	TXTA

    ld      a,CMD_FILE_OPEN_READ
    call    sendcmd
    jp      nz,error

    ; load 8k to $E000 (512b x 16)

    ld      hl,msg_loading
	call	TXTA

    ld      b,16
    ld      hl,$E000

ld_main:
    push    bc

    ; prepare next 512 bytes
    ld      a,CMD_FILE_READ_512
    call    sendcmd
    jp      nz,error

    push    hl

    di

    ; read next 512 bytes
    ld      bc,$0000+IOP_READ
-:  in      a,(IOP_READ)
    ld      (hl),a
    inc     hl
    djnz    {-}
-:  in      a,(IOP_READ)
    ld      (hl),a
    inc     hl
    djnz    {-}

    ei

    pop     de
    push    hl

    ld      bc,$200
    call    crc16
    call    PRHEX
    call    PRSPC

    pop     hl

    pop     bc
    djnz   ld_main

    ;

ld_post:
    ld      hl,ld_exmenu
	call	TXTA
-:  call    specialjump
    jr      {-}

ld_exmenu:
    .db     13
    .db     "e - execute code at $E000",13
    .db     "d - execute DROPS",13
    .db     0
    .dw     'e',$E000
    .dw     'd',gdrops
    .dw     'q',retmm
    .dw     $ff



gdrops:
    ld      sp,0
    jp      $E88E

uploader:
    ld      hl,testprog
    ld      de,$E000
    ld      bc,$100
    ldir
    jp      ld_post



	; in: de = data ptr, bc = data length
	; out: hl = crc16-ccitt (poly 1021)

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
