; Copyright CoWare, Inc. 2001. All rights reserved.
;
; Author   : CoWare
; 
; Filename : boot.s
; 
; Purpose  : ARM Bootcode.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        PRESERVE8
        AREA    |_CWR_BOOT_CODE|, CODE, READONLY

	ENTRY
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; handlers imported from handler_*.s file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_vector_table
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This is the vector table.
						
|__cwr_vector_table|
	LDR	PC, =|__cwr_reset_handler|	; Reset vector
	LDR	PC, =|__cwr_undef_handler|	; Undefined vector
	LDR	PC, =|__cwr_swi_handler|	; Software Interrupt vector
	LDR	PC, =|__cwr_prefetch_handler|	; Prefetch vector
	LDR	PC, =|__cwr_abort_handler|	; Abort vector
	NOP					                    ; -- Reserved vector --
	LDR	PC, =|__cwr_irq_handler|	; Interrupt ReQuest vector
	LDR	PC, =|__cwr_fiq_handler|      	; Fast Interrupt ReQuest vector

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_reset_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This is the reset handler.
;
; This exception handler is called in SVC mode and will perform the 
; following tasks:
;   - Disable hardware interrupts IRQ and FIQ.
;   - Copy load view to execution view.
;   - Zero initialize ZI data.
;   - Setting up the stacks in each mode.
;   - Call "__main" in System mode.

        IMPORT	|Image$$RO$$Base|
        IMPORT	|Image$$RO$$Limit|
        IMPORT	|Image$$RW$$Base|
        IMPORT	|Image$$RW$$Limit|
        IMPORT	|Image$$ZI$$Base|
        IMPORT	|Image$$ZI$$Limit|
							
|__cwr_reset_handler|
	NOP

	;Disable the Interrupts. 
	MRS a1, cpsr
	ORR a1, a1, #0x00C0
	MSR cpsr_c, a1

       	IF :DEF:RESETTRAP
	;Call the reset trap routine defined by the user
		IMPORT |__reset_trap|
		B |__reset_trap|

		EXPORT |__reset_trap_end|
|__reset_trap_end|
	ENDIF
 
;
; Copy load view to execution view of initialized RW data.
|__cwr_data_move|	
        LDR     a1, =|Image$$RO$$Limit| 
        LDR     a2, =|Image$$RW$$Base| 
        CMP     a1, a2                 
        BEQ     |__cwr_zero_init|
        LDR     a4, =|Image$$ZI$$Base|	 
|__cwr_data_move_loop|
        CMP	a2, a4                  
        LDRCC	a3, [a1], #4
        STRCC   a3, [a2], #4
        BCC	|__cwr_data_move_loop|

; Zero initialize ZI data.
|__cwr_zero_init|	

	LDR	a1, =|Image$$ZI$$Base|
	LDR	a2, =|Image$$ZI$$Limit|
	MOV     a3, #0

|__cwr_zero_init_loop|
	CMP	a1, a2              
	STRCC	a3, [a1], #4
	BCC	|__cwr_zero_init_loop|

; Setting up the stacks in each mode.       
|__cwr_stack_setup|			
	; Currently we are in Supervisor mode.	
	; Setup the stackpointer.
 	LDR	a1, =|__cwr_supervisor_stack_base| 
 	LDR	a1, [a1]
 	MOV	SP, a1

	; Go to FIQ mode.
	MRS	a1, cpsr
	AND	a1, a1, #~0x001F
	ORR	a1, a1, #0x0011	
	MSR	cpsr_c, a1

	; Setup stack in FIQ mode.
  LDR	a1, =|__cwr_fiq_stack_base|		
  LDR	a1, [a1]
  MOV	SP, a1

	; Go to IRQ mode.
  MRS	a1, cpsr		 
  AND	a1, a1, #~0x001F
  ORR	a1, a1, #0x0012
	MSR	cpsr_c, a1

	; Setup stack in IRQ mode.
	LDR	a1, =|__cwr_irq_stack_base|
	LDR	a1, [a1]
	MOV	SP, a1

	; Go to Abort mode.
	MRS	a1, cpsr      
	AND	a1, a1, #~0x001F
	ORR	a1, a1, #0x0017
	MSR	cpsr_c, a1

	; Setup stack in Abort mode.
	LDR	a1, =|__cwr_abort_stack_base|
	LDR	a1, [a1]                   
	MOV	SP, a1                    

	; Go to Undef mode.
	MRS	a1, cpsr 
	AND	a1, a1, #~0x001F
	ORR	a1, a1, #0x001b
	MSR	cpsr_c, a1

	; Setup stack in Undef mode.
	LDR	a1, =|__cwr_undef_stack_base|
	LDR	a1, [a1]                  
	MOV	SP, a1                  

	; Go to System mode.
	MRS	a1, cpsr     
	AND	a1, a1, #~0x001F
	ORR	a1, a1, #0x001F
	MSR	cpsr_c, a1

	; Setup stack in System mode.
	; Same stack as in User mode.
	LDR	a1, =|__cwr_user_stack_base|
	LDR	a1, [a1]              
	MOV	SP, a1	

	; Flag to check whether to enable or disable the interrupts
	; The default value of the flag is true means interrupts 
	; will be enable by default.

	IF :DEF:INTENABLEFLAG
	;Enable the Interrupts. 
		MRS a1, cpsr
		AND a1, a1, #~0x00C0
		MSR cpsr_c, a1
	ENDIF

	; Device Initialization
	; If the User wants to have the device initialization before
	; going to main (means in supervisory mode), first switch to
	; supervisory mode and call the user's device init routine.
	; Once, user has done the required initialization, continue 
	; as usual.
	IF :DEF:DEVICEINITROUTINE

	;Go to Supervisory mode
		MRS a1, cpsr
		AND a1, a1, #~0x001F
		ORR a1, a1, #0x0013
		MSR cpsr_c, a1

	;Call the user's routine

		BL |__user_device_init|
	ENDIF
		
	
  ; Mode setting to enter main function.
	IF :DEF:SUPERVISORYMODEFLAG 
		; The control can come here in either in supervisory
		; mode or in system mode. So, first switch to Supervisory 
		; mode and then call main routine.
		MRS a1, cpsr
		AND a1, a1, #~0x001F
		ORR a1, a1, #0x0013
		MSR cpsr_c, a1

		; Bootcode is finished, call __main.
	ELSE
		; Switch to User mode.
		MRS	a1, cpsr
		AND	a1, a1, #~0x001F
		ORR	a1, a1, #0x0010
		MSR	cpsr_c, a1
	ENDIF

	;Check if RT Library support is required or not
	;If required, then call rt_entry otherwise call the
	;user-defined main function.
	IF :DEF:RTLIBRARYREQUIRED
		B |__main|
	ELSE
		IMPORT |main|
		B |main|
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_undef_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
; This is the undefined instruction handler.
;
; This exception handler is called in Undef mode and results in an endless
; loop. In the software debugger you can see this handler is called, when
; it is looping in this	function. If the user specifies a different handler
; than the default one, that will be called. The registers are saved before 
; calling the user handler.
;
								
|__cwr_undef_handler|
	IF :DEF:UNDEFINTHANDLER
		NOP
		B	|__cwr_undef_handler|	
	ELSE
		STMFD sp!,{r0-r11,lr}
  	B |__user_undef_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_swi_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
; This is the softwar interrupt handler.
;
; This exception handler is called and results in an endless
; loop. In the software debugger you can see this handler is called, when
; it is looping in this	function. If the user specifies a different handler
; than the default one, that will be called. The registers are saved before 
; calling the user handler.
;
								
|__cwr_swi_handler|
	IF :DEF:SWIINTHANDLER
		B |__cwr_swi_handler|
	ELSE
		STMFD sp!,{r0-r11,lr}
		B |__user_swi_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_prefetch_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
; This is the prefetch  abort handle (instruction fetch memory fault).
;
; This exeption handler is called in Abort mode. The handler is implement that
; it will try to refetch the instruction. So, it has to return one instruction
; early to execute the instruction that has caused a memory fault when
; requested. If the user specifies a different handler
; than the default one, that will be called. The registers are saved before 
; calling the user handler.
		
|__cwr_prefetch_handler|
	IF :DEF:PREFETCHINTHANDLER
		; Retry the instruction fetch.
		SUBS	PC, LR, #0x4
	ELSE
		STMFD sp!,{r0-r11,lr}
		B |__user_prefetch_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_abort_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
; This is the data abort handle (data access memory fault).
;
; This exeption handler is called in Abort mode. The handler is implemented so that
; it will try to redo the data access. So, it has to return two instructions
; early to retry the data transfer instruction, which was the instruction
; before the one usurped for exception entry.

|__cwr_abort_handler|
	IF :DEF:ABORTINTHANDLER
  	; Retry the data access.
	  SUBS  PC, LR, #0x8
	ELSE
		STMFD sp!,{r0-r11,lr}
		B |__user_abort_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_irq_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
; This is the IRQ handle (interrupt service request).
;
; This exeption handler is called in IRQ mode. The handler is implement that
; it will go into a loop. If the user specifies a different handler
; than the default one, that will be called. The registers are saved before 
; calling the user handler.

|__cwr_irq_handler|
	IF :DEF:IRQINTHANDLER
		B |__cwr_irq_handler|
	ELSE
		STMFD sp!,{r0-r11,lr}
		B |__user_irq_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __cwr_fiq_handler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;
; This is the FIQ handle (fast interrupt request).
;
; This exeption handler is called in FIQ mode. The handler is implement that
; it will go into a loop. If the user specifies a different handler
; than the default one, that will be called. The registers are saved before 
; calling the user handler.

|__cwr_fiq_handler|
	IF :DEF:FIQINTHANDLER
		B |__cwr_fiq_handler|
	ELSE
		STMFD sp!,{r0-r11,lr}
		B |__user_fiq_handler|
		LDMFD sp!,{r0-r11,pc}
	ENDIF

	IF :DEF:RTLIBRARYREQUIRED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __rt_stackheap_init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function is called by the ARM C library and should be responsible to 
; initialize the heap and stack.
;
; We already have initialized the stack in the reset handler. So, we will only
; allocate and setup the heap space in this function. Heap will be allocated
; between the end of the last data symbol in the RAM and the end pointer of
; the lowest stack region.
;
; We will calculate all end pointers of each stack. This means that the 
; lowest end pointer is the end pointer of the lowest stack region.
	
	EXPORT	|__rt_stackheap_init|
		
|__rt_stackheap_init|
	
	; end pointer = base pointer - size
	
	; Calculate the end pointer of the User/System mode stack.
	; We will store the end pointer in a1.
|__cwr_stackheap_init_user|	
	LDR	a2, =|__cwr_user_stack_base|
	LDR	a2, [a2]	
	LDR	a3, =|__cwr_user_stack_size|
	LDR	a3, [a3]
	SUB	a1, a2, a3
	
	; Calculate the end pointer of the Undef mode stack.
	; Store the end pointer in a2.
|__cwr_stackheap_init_undef|	
	LDR	a2, =|__cwr_undef_stack_base|
	LDR	a2, [a2]
	LDR	a3, =|__cwr_undef_stack_size|
	LDR	a3, [a3]
	SUB	a2, a2, a3
	
	; Compare the end pointer of Undef mode stack with the one in a1.
	; If smaller, update a1.
	CMP	a2, a1
	MOVMI	a1, a2
	
	; Calculate the end pointer of the Abort mode stack.
|__cwr_stackheap_init_abort|		
	LDR	a2, =|__cwr_abort_stack_base|
	LDR	a2, [a2]
	LDR	a3, =|__cwr_abort_stack_size|
	LDR	a3, [a3]
	SUB	a2, a2, a3

	; Store end pointer of Abort mode stack in a1, if smaller.
	CMP	a2, a1
	MOVMI	a1, a2	

	; Calculate the end pointer of the FIQ mode stack.
|__cwr_stackheap_init_fiq|	
	LDR	a2, =|__cwr_fiq_stack_base|
	LDR	a2, [a2]	
	LDR	a3, =|__cwr_fiq_stack_size|
	LDR	a3, [a3]
	SUB	a2, a2, a3

	; Store end pointer of the the FIQ mode stack in a1, if smaller.
	CMP	a2, a1
	MOVMI	a1, a2	

	; Calculate the end pointer of the IRQ mode stack.
|__cwr_stackheap_init_irq|	
	LDR	a2, =|__cwr_irq_stack_base|
	LDR	a2, [a2]
	LDR	a3, =|__cwr_irq_stack_size|
	LDR	a3, [a3]
	SUB	a2, a2, a3

	; Store end pointer of the the IRQ mode stack in a1, if smaller.	
	CMP	a2, a1
	MOVMI	a1, a2			

	; Calculate the end pointer of the Supervisor mode stack.
|__cwr_stackheap_init_svc|	
	LDR	a2, =|__cwr_supervisor_stack_base|
	LDR	a2, [a2]
	LDR	a3, =|__cwr_supervisor_stack_size|
	LDR	a3, [a3]
	SUB	a2, a2, a3

	; Store end pointer of the the Supervisor mode stack in a1, 
	; if smaller.
	CMP	a2, a1
	MOVMI	a1, a2

|__cwr_heap_init|
	; Store end pointer in stack limit register. 
	MOV	SL, a1
	
	; Store end pointer in a2.
	MOV	a2, a1	
	
	; Store base pointer in a1.
	LDR	a1, =|Image$$ZI$$Limit|

	; Return.
	MOV	PC, LR
	
	      		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __rt_heap_extend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This function is called when there is more heap requested than availible.
; If there is more heap availible, it should return a new 8-byte aligned block
; of memory to add to the heap. If no more heap is availible, it should return
; zero.
;
; We already allocated all the heap availible. So, this function will always
; return zero. To make more heap availible for your design, you have to 
; extend the RAM size. This way, more heap will allocated in the 
; __rt_stackheap_init() function.
	
	EXPORT	|__rt_heap_extend|
		
|__rt_heap_extend|	
	; We will refuse all new heap requests.
	MOV	a1, #0
	MOV	PC, LR
		
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __rt_stack_overflow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This function is called if a stack overflow occurs.
;
; When this function is called, we get into an endless loop. This is usefull
; for debugging the software. A breakpoint at this function should never been
; triggered.

	EXPORT	|__rt_stack_overflow|
			
|__rt_stack_overflow|
	; Endless loop.
	B	|__rt_stack_overflow|
		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __rt_stack_postlongjmp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This function sets sp and sl to correct values after a call to longjmp().
;
; Register a1 contains the pre-setjmp() value for SL and a2 contains the
; pre-setjmp() value for PC.
				
	EXPORT	|__rt_stack_postlongjmp|		
	
|__rt_stack_postlongjmp|
	STMFD   SP!, {a1,a2}
	LDMIA	SP, {SL,SP}
	MOV	PC, LR


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; __main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;
; This is the entry point of the software.
;
; We will branch to  entry point of the ARM C libray. This libray will 
; initialize itself and call the user entry point "main" afterwards.
	IMPORT	|__rt_entry|
	EXPORT	|__main|
	
|__main|
	; Branch to  entry point of the ARM C libray.
	B	|__rt_entry|

	ENDIF

	INCLUDE bootinclude.s

	END


