//LAB THREE PART ONE

.global _start
.equ KEY_BASE, 0xFF200050
.equ HEX30, 0xFF200020

_start:   		LDR R0, =KEY_BASE	// R0 <- base address of KEY	
		  	LDR R4, =HEX30		// R4 <- base address of HEX
		  	MOV R2, #0 
		  	MOV R3, #0
		  	MOV R5, #9 
		  	MOV R6, #0 

POLL_INPUT:  		LDR R1, [R0]		// R1 <- state of KEY
			ANDS R1, #15		// check if any key is pressed (0b1111)		
	         	BEQ POLL_INPUT		// repeat loop until key pressed	
	  
CHECK_ZERO:  		CMP R1, #0x1		// check if KEY0 is pressed, if not branch to next case
		     	BNE CHECK_ONE
			PUSH {LR}
			BL CHECK_RELEASE		// if yes, check for button release
			POP {LR}
			B ZERO_EXECUTE		// once released display 0 on hex0
				   
CHECK_ONE:  	    	CMP R1, #0x2		// check if KEY1 is pressed, if not branch to next case
		    	BNE  CHECK_TWO
		    	PUSH {LR}
		    	BL CHECK_RELEASE		// if yes, check of button realize
		    	POP {LR}
		    	B  ONE_EXECUTE   	// after released, execute function

CHECK_TWO:  		CMP R1, #0x4		// check if KEY1 is pressed, if not branch to next case
		    	BNE  CHECK_THREE
		    	PUSH {LR}	
		    	BL CHECK_RELEASE		// check release
		    	POP {LR}
		    	B  TWO_EXECUTE		// once released, execute function
		    
CHECK_THREE: 		CMP R1, #0x8		// check if KEY3 is pressed
			PUSH {LR}
		     	BL CHECK_RELEASE		// check release
		     	POP {LR}
			B THREE_EXECUTE		// after release, execute function
			 
CHECK_RELEASE: 		LDR R1, [R0]		// load state of key from data reg
			ANDS R1, #15		// if key realized, this will return 0
			BGT CHECK_RELEASE	// until then, continue loop as result will be > 0
			MOV PC, LR
			 
ZERO_EXECUTE: 		MOV R2, #0 		// R2 is the register that will hold the number we want to display
			MOV R3, #0 
			PUSH {LR}
			BL  SEG7_CODE		 
			POP {LR}
			STR R2, [R4] 
			B POLL_INPUT		// return to poll to loop
			 
ONE_EXECUTE: 		CMP R5, R3 		// check if R3 > 9 (9 - R3)
             		BEQ POLL_INPUT		// if yes, return to loop 
			ADD R3, #1 		// if not add 1 to R3
			MOV R2, R3		// move value from R3 to R2, so it can be displayed
			 
			PUSH {LR}
			BL SEG7_CODE
             		POP {LR} 
			 
			STR  R2,[R4] 
			B POLL_INPUT

TWO_EXECUTE: 		CMP R3, R6 		// check if R3 = 0 (r3 - 0) 	
             		BEQ POLL_INPUT 		// if yes, return to loop
			SUB R3, #1		// if not, sub 1 from R3
			MOV R2, R3 		// move value from R3 to R2, so it can be displayed
			 
			PUSH {LR}
			BL SEG7_CODE 
			POP {LR}
			 
			STR R2, [R4] 
			B POLL_INPUT 

THREE_EXECUTE: 		MOV R2, #0 		// R2 <- 0, so 0 can be displayed on hex
			STR R2, [R4]		 
               		LDR R1, [R0]		// re-load state of KEYS into R1
			ANDS R1, #15		// check if R1 = 0000
	           	BEQ THREE_EXECUTE	// if so, continue to display 0 (base case)
			PUSH {LR}
			BL CHECK_RELEASE		// if not, check when key3 is released
			POP  {LR}
			B ZERO_EXECUTE 		// after releases, display 0
//SEG7CODE
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R2         // index into the BIT_CODES "array"
            LDRB    R2, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
//SEG7CODE 
	
	