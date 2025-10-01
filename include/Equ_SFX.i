;------------------------------
TOTAL_SAMPLES	EQU	32	
;------------------------------
SAM_NONE        EQU	 0 	; DO NOT pass "SAM_NONE" to PlaySample

SAM_MUDDY       EQU	 1 
SAM_SEA         EQU	 2
SAM_PULP        EQU	 3
SAM_RATDTH1     EQU	 4
SAM_SLOP        EQU	 5
SAM_SURVDETH    EQU	 6
SAM_GOODCAR     EQU	 7
SAM_LANDSKID    EQU	 8
SAM_ESTART      EQU	 9
SAM_CAR2CAR     EQU	10
SAM_FENDER      EQU	11
SAM_FENDER2     EQU	12
SAM_HITMETAL    EQU	13
SAM_KCHNK       EQU	14
SAM_WALL        EQU	15
SAM_BOOST       EQU	16
SAM_SCREECH1    EQU	17
SAM_SCREECH2    EQU	18
SAM_SKID1       EQU	19
SAM_SKID113     EQU	20
SAM_STRESS1     EQU	21
SAM_STRESS2     EQU	22
SAM_RICO10      EQU	23
SAM_BITS        EQU	24
SAM_DROPMINE    EQU	25
SAM_EXPLODE     EQU	26
SAM_GUN         EQU	27
SAM_MISSILE     EQU	28
SAM_EXPLODE2    EQU	29
SAM_RICO13      EQU	30
SAM_RICO12      EQU	31
SAM_RICO9       EQU	32

SAM_STOP	EQU     TOTAL_SAMPLES+1 	; Make sure I use a number outside the range
						; Again DO NOT pas this to "PlaySample"
			
SAM_SOUNDS_MASK	EQU	$FF		
SAM_LOOP	EQU	1<<9	; for looping sample... 
				; eg.  move.w	#SAM_BOOST|SAM_LOOP,CAR_PLAY_SND_NUM(a3)
					
;------------------------------
SAM_SIZE0      EQU	0			
SAM_SIZE1      EQU	25961           ;SAM_MUDDY      
SAM_SIZE2      EQU	24050           ;SAM_SEA        
SAM_SIZE3      EQU 	5450            ;SAM_PULP       
SAM_SIZE4      EQU 	9741            ;SAM_RATDTH1    
SAM_SIZE5      EQU	11118           ;SAM_SLOP       
SAM_SIZE6      EQU	12820           ;SAM_SURVDETH   
SAM_SIZE7      EQU 	9566            ;SAM_GOODCAR    
SAM_SIZE8      EQU 	6732            ;SAM_LANDSKID   
SAM_SIZE9      EQU	26884           ;SAM_ESTART     
SAM_SIZE10     EQU 	5308            ;SAM_CAR2CAR    
SAM_SIZE11     EQU  	4368            ;SAM_FENDER     
SAM_SIZE12     EQU  	6987            ;SAM_FENDER2    
SAM_SIZE13     EQU  	2972            ;SAM_HITMETAL   
SAM_SIZE14     EQU  	5620            ;SAM_KCHNK      
SAM_SIZE15     EQU 	13453           ;SAM_WALL       
SAM_SIZE16     EQU 	33752           ;SAM_BOOST      
SAM_SIZE17     EQU  	8076            ;SAM_SCREECH1   
SAM_SIZE18     EQU  	8688            ;SAM_SCREECH2   
SAM_SIZE19     EQU  	1474            ;SAM_SKID1      
SAM_SIZE20     EQU 	12476           ;SAM_SKID113    
SAM_SIZE21     EQU  	9206            ;SAM_STRESS1    
SAM_SIZE22     EQU 	10340           ;SAM_STRESS2    
SAM_SIZE23     EQU  	3172            ;SAM_RICO10     
SAM_SIZE24     EQU  	4111            ;SAM_BITS       
SAM_SIZE25     EQU  	6844            ;SAM_DROPMINE   
SAM_SIZE26     EQU 	27406           ;SAM_EXPLODE    
SAM_SIZE27     EQU  	2960            ;SAM_GUN        
SAM_SIZE28     EQU  	7512            ;SAM_MISSILE    
SAM_SIZE29     EQU 	17947  		;SAM_EXPLODE2   
SAM_SIZE30     EQU  	5244            ;SAM_RICO13     
SAM_SIZE31     EQU  	4444            ;SAM_RICO12     
SAM_SIZE32     EQU  	2497            ;SAM_RICO9      
