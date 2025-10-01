* Start-up Routine

;VBlankFrequency equ 530      ;NB - Old include files ( 1.2 ) don't
;AFB_68010  equ   0     ;have all these equates in.
;AFB_68020  equ   1                        
;AFB_68030  equ   2     ;If you get an error when assembling
;AFB_68040  equ   3     ;then uncomment these lines


***********************************************************
* Other Structs
***********************************************************

      rsreset
gfx_base rs.l  1     ; pointer to graphics base
OldView     rs.l    1      ; old Work Bench view addr.
VectorBase: rs.l  1     ; pointer to the Vector Base
Old_irq6c   rs.l  1     ; In case we run an IRQ
Old_irq70   rs.l  1
Old_irq68   rs.l  1
Chipsize rs.l  1     ; Store for amount of Chip-Ram
Fastsize rs.l  1     ; Store for amount of Fast-Ram
OldDMACon:  rs.w  1     ; old dmacon bits
OldINTEna:  rs.w  1     ; old intena bits
ntsc_mode:  rs.b  1     ; 0 = pal, 1 = ntsc
AGA:     rs.b  1     ; 0 = ESC/standard, 1 = AGA
CPU:     rs.b  1     ; 00 = 68000, 10 = 68010 etc.
SYS_SIZE rs.b  0     ; size of the struct

***********************************************************

TakeSystem:
;*+*+*+  Set up constants...
   movea.l  4.w,a6         ; exec base
   lea   $dff000,a5     ; custom chip base
   lea   SystemSave,a4     ; where to save everything

   move.l   #0,chipsize(a4)   
   move.l   #0,fastsize(a4)   

;*+*+*+  Check for memory...
   move.l   322(a6),a0     ;MemList
.check_node
   move.w   14(a0),d0      ;mem type
   move.l   20(a0),d1      ;lower address
   move.l   24(a0),d2      ;upper address
   and.l #$fffff000,d1     ;mask off lower bits because
               ;normally the first few bytes
               ;of the memory are occupied
   sub.l d1,d2                   ;get length of memory section
   and.w #4,d0                   ;is the memory chip?
   beq.s .chip_node          
   add.l d2,fastsize(a4)      ;add to fastmem size
   bra.s .next_node          
.chip_node
   add.l   d2,chipsize(a4)    ;add to chipmem size
.next_node
   move.l  0(a0),a0     ;get next memory node
   tst.l   (a0)         ;if the next node is zero
   bne.s .check_node    ;then its the end.

;*+*+*+  Check which CPU we've got under the hood...
   move  AttnFlags(a6),d0
                                        
   btst  #AFB_68040,d0       
   bne.s .68040
   btst  #AFB_68030,d0       
   bne.s .68030              
   btst  #AFB_68020,d0       
   bne.s .68020              
   btst  #AFB_68010,d0       
   bne.s .68010              
   bra.s .CPU_Check_end    ;Don't set flag, running a 68000
.68040
   move.b   #40,CPU(a4)
   bra.s .CPU_Check_end
.68030
   move.b   #30,CPU(a4)
   bra.s .CPU_Check_end
.68020
   move.b   #20,CPU(a4)
   bra.s .CPU_Check_end
.68010
   move.b   #10,CPU(a4)
.CPU_Check_end

;*+*+*+  Open graphics library...
   lea   GraphicsName,a1      ; "graphics.library"
   moveq #0,d0       ; any version
   CALL  OpenLibrary    ; open it.
   move.l   d0,gfx_base(a4)      ; save pointer to gfx base
   beq   .erexit        ; if we got a NULL, then exit
   movea.l  d0,a6       ; for later callls...

;*+*+*+  Clear all the view stuff...
   move.l  gb_ActiView(a6),OldView(a4) ; save old view

   sub.l a1,a1       ; clears full long-word
   CALL  LoadView    ; Open a NULL view (resets display
               ;   on any Amiga)

   CALL  WaitTOF        ; Wait twice so that an interlace
   CALL  WaitTOF        ;   display can reset.

   CALL  OwnBlitter     ; take over the blitter and...
   CALL  WaitBlit    ;   wait for it to finish so we can
               		;   safely use it as we please.

;*+*+*+  Now kill the multitasking...
   movea.l  4.w,a6         ; exec base
   CALL  Forbid         ; kill multitasking

;*+*+*+  Check for PAL/NTSC modes...
   cmpi.b   #50,VBlankFrequency(a6) ; is vblank rate PAL ?
   beq.b .pal        ; yup.
   st ntsc_mode(a4)     ; set NTSC flag.
.pal

;*+*+*+  Check for AGA chipset...
   move.w   $7c(a5),d0     ; AGA register...
   cmpi.b   #$f8,d0        ; are we AGA?
   bne.b .not_aga    ; nope.
   st AGA(a4)        ; set the AGA flag.
   move.w   #0,$1fc(a5)    ; reset AGA sprites to normal mode
.not_aga

;*+*+*+  Get the VBR, and store it...
   bsr   GetVBR         ; get the vector base pointer
   move.l   d0,VectorBase(a4) ; save it for later.
   move.l   d0,a0
   move.l   $68(a0),Old_irq68(a4)
   move.l   $6c(a0),Old_irq6c(a4)   ; Store the old irq
   move.l   $70(a0),Old_irq70(a4)

;*+*+*+  Now, save all the OS related stuff, and we're done.
   move.w   dmaconr(a5),d0    ; old DMACON bits
   ori.w #$8000,d0      ; or it set bit for restore
   move.w   d0,OldDMACon(a4)  ; save it

   move.w   intenar(a5),d0    ; old INTEna bits
   ori.w #$c000,d0      ; or it set bit for restore
   move.w   d0,OldINTEna(a4)  ; save it

	;( looks like library functions... ENABLE & DISABLE could of been used! )

   move.l   #$7fff7fff,intena(a5)   ; kill all ints
   move.w   #$7fff,dmacon(a5) ; kill all dma
   moveq #0,d0       ; return no error code
   rts

.erexit
   moveq #-1,d0         ; error, don't run demo.
   rts

***********************************************************

RestoreSystem: 

	BLTWAIT

	lea   $dff000,a5  ; custom chip base
	lea   SystemSave,a4  ; where it's all at

   ; You must do these in this order or you're asking for trouble!
      move.l   #$7fff7fff,intena(a5)   ; kill all ints
      move.w   #$7fff,dmacon(a5) ; kill all dma
      move.l   Vectorbase(a4),a0 ; Restore the IRQ pointer
      move.l   Old_irq68(a4),$68(a0)
      move.l   Old_irq6c(a4),$6c(a0)
      move.l   Old_irq70(a4),$70(a0)
      move.w   OldDMACon(a4),dmacon(a5); restore old dma bits
      move.w   OldINTEna(a4),intena(a5); restore old int bits

      movea.l  OldView(a4),a1 ; old Work Bench view
      movea.l  gfx_base(a4),a6   ; gfx base
      CALL  LoadView ; Restore the view
      CALL  DisownBlitter  ; give blitter back to the system.
  
      move.l   gb_copinit(a6),$80(a5) ; restore system clist
      
      ;This was missing, took a while for w/b to appear on exit!!!
      clr.w 	copjmp1(a5) ; activate it. jump to copper-list-1

      movea.l  a6,a1
      movea.l  4.w,a6      ; exec base
      CALL  CloseLibrary

      movea.l  4.w,a6      ; exec base
      CALL  Permit      ; Restore multitasking
      
      rts

***********************************************************
* This function provides a method of obtaining a pointer to the base of the
* interrupt vector table on all Amigas.  After getting this pointer, use
* the vector address as an offset.  For example, to install a level three
* interrupt you would do the following:
*
*     bsr   _GetVBR
*     move.l   d0,a0
*     move.l   $6c(a0),OldIntSave
*     move.l   #MyIntCode,$6c(a0)
*
***********************************************************
* Inputs: none
* Output: d0 contains vbr.

GetVBR:     move.l   a5,-(sp)    ; save it.
      moveq #0,d0       ; clear
      movea.l  4.w,a6         ; exec base
      btst.b   #AFB_68010,AttnFlags+1(a6); are we at least a 68010?
      beq.b .1       ; nope.
      lea.l vbr_exception(pc),a5 ; addr of function to get VBR
      CALL  Supervisor     ; supervisor state
.1:      move.l   (sp)+,a5    ; restore it.
      rts            ; return

vbr_exception:
   ; movec vbr,Xn is a priv. instr.  You must be supervisor to execute!
;     movec   vbr,d0
   ; many assemblers don't know the VBR, if yours doesn't, then use this
   ; line instead.
      dc.l  $4e7a0801
      rte            ; back to user state code

***********************************************************

GraphicsName:  dc.b  "graphics.library",0 ; name of gfx library
      EVEN

      CNOP  0,4
doslib      dc.b  "dos.library",0     
      EVEN

***********************************************************

SystemSave: ds.b  SYS_SIZE
      even
      
      
      
