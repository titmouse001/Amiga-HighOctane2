; This functions looks at the car structures for any 
; samples to play or turn off.
; Needs to be called on each Screen Blank.
                                                                        
Process_Sounds:                                                        
                                                                        
	move.w	#MAX_CARS-1,D7                                          
	lea	CarList,a3                                              
LoopPlayChan:                                                           
	move.w	CAR_PLAY_SND_NUM(a3),d0
	move.w	d0,d6                                 
	and.w	#SAM_SOUNDS_MASK,d0
	beq.s	NextItem          ; Is it "SAM_NONE"?
	                                                                
	cmp.w	#SAM_STOP,d0                                     
	beq.s	StopSamplePlaying                                       
	   
	moveq	#0,d4                                                             
	move.w	CAR_SNDCHANBIT(a3),d1	;play mask          
	and.w	#SAM_LOOP,d6
	beq.s	DontLoopIt
	move.w	d1,d4			;D4 -> Playsample, loop mask
DontLoopIt
	move.w	#64,d3			;vol                            
	move.w	#$100,d2		;freq                           
	                                                                
	bsr	PlaySample 		;takes D0..D4
	move.w	CAR_PLAY_SND_NUM(a3),CAR_PLAY_SND_LASTNUM(a3)	
	move.w	#0,CAR_PLAY_SND_NUM(a3)			;clear  
	bra.s	NextItem
	                                                                
StopSamplePlaying:                                                      
	move.w	CAR_SNDCHANBIT(a3),CUSTOM+dmacon	;audio off    
	move.w	#0,CAR_PLAY_SND_NUM(a3)			;clear      
	move.w	#-1,CAR_PLAY_SND_LASTNUM(a3)	
NextItem:                                                          
                                                                        
	lea	CAR_SIZEOF(a3),a3                                       
	dbra	d7,LoopPlayChan                                         
	                                                                
	RTS                                                             
                                          
;----------------------------------------------------------------------                                          
ProcessWaitingSounds:
                         
        move.w	LastChanPlayedMask,d6
	beq	.SkipStartSound
	or.w	#$8200,d6		;start sound		 
	move.w	d6,CUSTOM+dmacon	;audio on            
.SkipStartSound:
	rts
                       
;----------------------------------------------------------------------
; Turns on the Sample DMA channles.
; Then puts blank samples in all the channels for the H/W to play instead of looping.
; Samples would loop without this.
; Call every Vertical screen BLank (VBL)

ProcessSound_MuteLooping:
	move.w	LastChanPlayedMask,d6
	beq	.NoProcessSound

	move.w	LastChanLoopMask,d4
	move.l	#CUSTOM+aud0,a1
	moveq	#4-1,d7
.snd_blankloop
	lsr.w	#1,d4
	bcc.s	.skipblank1		; carry clear 
	move.l	#BlankSound,ac_ptr(a1) 	;Used by H/W when sample finnished
	move.w	#8/2,ac_len(a1)		; ""
	;move.w	#222,ac_per(a1)		; 
	;move.w	#64,ac_vol(a1)		; 
.skipblank1
	lea	ac_SIZEOF(a1),a1
	dbra	d7,.snd_blankloop
	move.w	#0,LastChanPlayedMask
.NoProcessSound
	move.w	#0,LastChanLoopMask
	
	rts
	
;--------------------------------------------------------------------

PlaySample:	;INPUTS:- d0: Samp No
		;	  d1: Chan mask
		;	  d2: Freq
		;	  d3: Vol
		;	  d4: Loop Mask
		
	movem.l	d0-7/a0-6,-(sp)
	
	move.l	#CUSTOM+aud0,a1
	lea	AllSamples,a0	
	moveq	#0,d6
	moveq	#4-1,d7
	moveq	#%1,d5

	and.w	#%1111,d1
	and.w	#%1111,d4

	move.w	d1,LastChanPlayedMask
	not.w	d4
	move.w	d4,LastChanLoopMask
	
	subq	#1,d0	;USE ZERO FOR NONE (never used)
	lsl.w	#3,d0

snd_loop:
	lsr.w	#1,d1
	bcc	.DontSetAudioChannel
	move.l	0(a0,d0),ac_ptr(a1)	;Sample Start Data
	move.w	4(a0,d0),ac_len(a1)	;Sample Length
	move.w	d2,ac_per(a1)		;Sample Freq
	move.w	d3,ac_vol(a1)		;Sample Volume
	or.w	d5,d6  			;Remember used channels
.DontSetAudioChannel
	lsl.w	#1,d5
	lea	ac_SIZEOF(a1),a1
	dbra	d7,snd_loop

	tst.w	d6
	beq.s	.DontClearAudioDma
	move.w	d6,CUSTOM+dmacon	;audio off fist. MUST reset for new sound
.DontClearAudioDma
		
	movem.l	(sp)+,d0-7/a0-6
	RTS
	
;--------------------------------------------------------------------------------
	
ChangeChanVol:	;INPUTS:-
			;  d0: Chan mask
			;  d1: Vol
	
	movem.w	d0-2,-(sp)
	movem.l	  a0,-(sp)
		
	move.l	#CUSTOM+aud0,a0
	moveq	#4-1,d2
	and.w	#%1111,d0

snd_VolLoop:
	lsr.w	#1,d0
	bcc	.skip1
	move.w	d1,ac_vol(a0)		;Sample Volume
.skip1
	lea	ac_SIZEOF(a0),a0
	dbra	d2,snd_VolLoop

	movem.l	(sp)+,a0
	movem.w	(sp)+,d0-2

	RTS


; code snip
;
;	move.w	#$fff,$dff180
;
;---
;CIAAPRA         EQU     $bfe001
;CIABTALO        EQU     $bfd400
;CIABTAHI        EQU     $bfd500
;CIABICR         EQU     $bfdd00
;CIABCRA         EQU     $bfde00
;
;CIABTBLO        EQU     $bfd600
;CIABTBHI        EQU     $bfd700
;CIABCRB         EQU     $bfdf00
;
;        move.b  CIABCRA,d1              ; wait loop
;        move.b  d1,d0
;        and.b   #%11000000,d0
;        or.b    #%00001000,d0
;        move.b  d0,CIABCRA
;        move.b  #$2f,CIABTALO
;        move.b  #1,CIABTAHI
;.PlayDelay1:
;        btst.b  #0,CIABCRA
;        bne.s   .PlayDelay1
;        move.b  d1,CIABCRA
;        move.b  #%00000001,CIABICR
;---
;
;	move.w	#0,$dff180