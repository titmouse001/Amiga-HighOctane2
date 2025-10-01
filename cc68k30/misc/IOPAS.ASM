; IOPASCAL.ASM  (c) 1993  P.J.Fondse
; Input and Output functions for PAS68K
__INCHAR:
        link    A6,#0
        move.l  8(A6),A0
        jsr     getch
        move.w  D0,(A0)
        unlk    A6
        move.l  (A7)+,A0
        addq.l  #4,A7
        jmp     (A0)
__ININT:
        link    A6,#0
        move.l  D2,-(A7)
        move.l  8(A6),A0
        moveq   #0,D1
        moveq   #0,D2
inint1:
        jsr     getch
        cmp.b   #' ',D0
        ble.s   inint1
        jsr     ungetch
inint2:
        jsr     getch
        cmp.b   #'+',D0
        beq.s   inint4
        cmp.b   #'-',D0
        bne.s   inint3
        moveq   #1,D2
        bra.s   inint4
inint3:
        jsr     ungetch
inint4:
        jsr     getch
        cmp.b   #'0',D0
        blt.s   inint5
        cmp.b   #'9',D0
        bgt.s   inint5
        and.l   #$000000FF,D0
        sub.b   #'0',D0
        move.l  #10,-(A7)
        move.l  D1,-(A7)
        jsr     __LMUL
        move.l  (A7),D1
        addq.l  #8,A7
        add.l   D0,D1
        bra.s   inint4
inint5:
        jsr     ungetch
        tst.l   D2
        beq.s   inint6
        neg.l   D1
inint6:
        move.l  D1,(A0)
        move.l  (A7)+,D2
        unlk    A6
        move.l  (A7)+,A0
        addq.l   #4,A7
        jmp     (A0)
__INREAL:
        move.l  (A7)+,A0
        addq    #4,A7
        jmp     (A0)
__INCRLF:
        jsr     getch
        cmp.b   #$0D,D0
        bne.s   __INCRLF
        rts
__OUTBOOL:
        link    A6,#0
        movem.l D0/D1/D2,-(A7)
        move.l  10(A6),D1
        tst.w   8(A6)
        bne.s   outb1
        move.l  #outb5,A0
        move.l  #5,D2
        bra.s   outb2
outb1:
        move.l  #outb6,A0
        move.l  #4,D2
outb2:
        tst.l   D2
        ble.s   outb3
        move.b  (A0)+,D0
        jsr     putch
        subq.l  #1,D1
        subq.l  #1,D2
        bra     outb2
outb3:
        tst.l   D1
        ble.s   outb4
        move.b  #' ',D0
        jsr     putch
        subq.l  #1,D1
        bra     outb3
outb4:
        movem.l (A7)+,D0/D1/D2
        unlk    A6
        move.l  (A7)+,A0
        addq    #6,A7
        jmp     (A0)
outb5:
        dc.b    'FALSE'
outb6:
        dc.b    'TRUE'
__OUTCHAR:
        link    A6,#0
        movem.l D0/D1,-(A7)
        move.l  10(A6),D1
        move.w  8(A6),D0
        jsr     putch
        subq.l  #1,D1
outch1:
        tst.l   D1
        ble.s   outch2
        move.b  #' ',D0
        jsr     putch
        subq.l  #1,D1
        bra.s   outch1
 outch2:
        movem.l (A7)+,D0/D1
        unlk    A6
        move.l  (A7)+,A0
        addq    #6,A7
        jmp     (A0)
__OUTINT:
        link    A6,#-20
        movem.l D0/D1/D2,-(A7)
        move.l  A6,A0
        move.l  8(A6),D1
        moveq   #0,D2
        tst.l   D1
        bpl.s   outint1
        moveq   #1,D2
        neg.l   D1
outint1:
        cmp.l   #9,D1
        ble.s   outint2
        move.l  #10,-(A7)
        move.l  D1,-(A7)
        jsr     __LDIV
        move.l  (A7),D1
        move.l  4(A7),D0
        addq.l  #8,A7
        add.b   #'0',D0
        move.b  D0,-(A0)
        bra     outint1
outint2:
        move.b  D1,D0
        add.b   #'0',D0
        move.b  D0,-(A0)
        tst.l   D2
        beq.s   outint3
        move.b  #'-',-(A0)
outint3:
        move.l  A6,D1
        sub.l   A0,D1
        move.l  12(A6),D2
        sub.l   D1,D2
outint4:
        tst.l   D2
        ble.s   outint5
        move.b  #' ',D0
        jsr     putch
        subq.l   #1,D2
        bra     outint4
outint5:
        tst.l   D1
        ble.s   outint6
        move.b  (A0)+,D0
        jsr     putch
        subq.l  #1,D1
        bra     outint5
outint6
        movem.l  (A7)+,D0/D1/D2
        unlk     A6
        move.l  (A7)+,A0
        addq.l   #8,A7
        jmp     (A0)
__OUTREAL:
        move.l  (A7)+,A0
        addq    #8,A7
        jmp     (A0)
__OUTSTR:
        link     A6,#0
        movem.l  D0/D1/D2,-(A7)
        move.l   8(A6),A0
        move.l   12(A6),D1
        move.l   16(A6),D2
outstr1:
        tst.l    D2
        ble.s    outstr2
        move.b   (A0)+,D0
        jsr      putch
        subq.l   #1,D1
        subq.l   #1,D2
        bra.s    outstr1
outstr2:
        tst.l    D1
        ble.s    outstr3
        move.b   #' ',D0
        jsr      putch
        subq.l   #1,D1
        bra      outstr2
outstr3:
        movem.l  (A7)+,D0/D1/D2
        unlk     A6
        move.l  (A7)+,A0
        addq.l   #12,A7
        jmp     (A0)
__OUTCRLF:
        move.b  #$0D,D0
        jsr     putch
        move.b  #$0A,D0
        jsr     putch
        rts
__EOLN:
        link    A6,#0
        move.l  D0,-(A7)
        jsr     getch
        jsr     ungetch
        cmp.b   #$0D,D0
        seq     D0
        and.w   #1,D0
        move.w  D0,8(A6)
        move.l  (A7)+,D0
        unlk    A6
        rts
__EOF:
        link    A6,#0
        move.l  D0,-(A7)
        jsr     getch
        cmp.b   #$1A,D0
        seq     D0
        and.w   #1,D0
        move.w  D0,8(A6)
        move.l  (A7)+,D0
        unlk    A6
        rts

