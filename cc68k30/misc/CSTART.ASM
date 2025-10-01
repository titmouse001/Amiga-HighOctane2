; STARTC.ASM  -  C startup-code for SIM68k

lomem     equ     $400             ; Lowest user RAM location
himem     equ     $10000           ; Highest memory + 1
stklen    equ     $1000            ; Default stacksize

          org.s   lomem
start:
          move.w   #-1,__ungetbuf
          clr.l    __allocp
          move.l   #freemem,__heap
          jsr      _main
          bra      __exit
__ungetbuf: 
          dc.w    0                ; ungetbuffer for stdio functions
__allocp:
          dc.l    0                ; start of allocation units
__heap:                             
          dc.l    0                ; pointers for malloc functions
__himem:
          dc.l    himem            ; highest memory location + 1
__stklen:
          dc.l    stklen           ; default stack size
__putch:                           ; Basic character output routine
          link    A6,#0
          move.w  8(A6),D0
          trap    #14
          dc.w    1
          unlk    A6
          rts
__getch:                           ; Basic character input routine
          trap    #14
          dc.w    3
          ext.w   D0
          rts
_exit:                             ; exit() function
          link    A6,#0
          move.w  8(A6),D0
          unlk    A6
          add.l   #10,A7           ; pop arg & r/a from stack
__exit:                            ; exit program
          trap     #14
          dc.w     0
          bra     start            ; restart

