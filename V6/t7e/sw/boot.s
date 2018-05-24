
@ Enumerate the processor modes
#define ARM_USER_MODE       0x10
#define ARM_FIQ_MODE        0x11
#define ARM_IRQ_MODE        0x12
#define ARM_SUPERVISOR_MODE 0x13
#define ARM_ABORT_MODE      0x17
#define ARM_UNDEF_MODE      0x1B
#define ARM_SYSTEM_MODE     0x1F
#define ARM_MODE_BITS       0x1F

#define ARM_FIQ_DISABLE     0x40
#define ARM_IRQ_DISABLE     0x80

        .text
        .global _syscall
        .global handle_fast_interrupt
   
     
reset_vector:   b _start
undef_instr:    b unrecov_error_handler
swi_vector:     b _syscall
prefetch_abort: b unrecov_error_handler
data_abort:     b unrecov_error_handler
rsvd_vector:    b unrecov_error_handler
irq_vector:     b fiq_handler
fiq_vector:     b fiq_handler       @ fast interrupt handler.


@ Handle the interrupt.
fiq_handler:
        sub     r14, r14, #4
        stmfd   sp!, {r0-r12,lr}	@ save regs on the stack
        bl      handle_interrupt
        ldmfd   sp!, {r0-r12,pc}^	@ Return

        
unrecov_error_handler:
        b unrecov_error_handler



	.global _start
_start:	
        @ Set up the memory pointers to init the stack and heap.
#ifdef ARMMP
	@ Disable interrupts
	cpsid	i	

	.global _check_cpu	
_checkcpu:
	mrc	p15, 0, r0, c0, c0, 5	@ get the processor id into r0
	and	r0, r0, #3
	subs	r0, r0, #0
	beq	1f			@ if id = 0 -> go
	.global _wait_here	
_wait_here:	
	wfe 
	b	_wait_here
	
1:
#endif

	
        @ Initialize the "regular mode" stack pointer (top of data space)
        ldr	r13,=_stack

        @ Initialize the heap pointer (bottom of data space)
        ldr     r1, =_end
        ldr     r2, =brk_value
        str     r1, [r2]        @ brk_value = _end: build up from there.

        @ Initialize the intertupt mode
        ldr     r0, =_int_stack		@ initialize the int stack
	

	 msr     cpsr_c, #ARM_IRQ_MODE
        mov     r13, r0         	@ Move stack addr to IRQ-SP

        @ Go to Supervisor mode, and enable the IRQ and FIQ
        mrs     r0, cpsr
        bic     r0, r0, # ARM_MODE_BITS 
	//| ARM_IRQ_DISABLE | ARM_FIQ_DISABLE
        orr     r0, r0, # ARM_SUPERVISOR_MODE 
        msr     cpsr_c, r0



	
        b       main
_exit:	
	b	_exit
#ifdef ARMMP
	.global gic_irq_enable
gic_irq_enable:		
	@ Enable interrupts
	cpsie	i
	bx lr
	.global gic_irq_disable
gic_irq_disable:		
	@ Disable interrupts
	cpsid	i
	bx lr
	.global a9_wait_for_interrupt
a9_wait_for_interrupt:	
	@ Wait for interrupt
	wfi
	bx lr
#endif
	@  Local data storage 
	.data
        .global brk_value
brk_value:	.long 0	@ process' brk value.
old_brk:	.long 0	@ used as temp holder for return value
      


        .global _end
        .global main

	.text


        .global _syscall
        .global _intstack
        .global brk_value
_syscall:
        ldr	r13,=_int_stack         @ initialize int stack pointer
        movs    PC, lr
	cmpeq	r8,#0x45		@ Grab the sbrk system call's id #
	beq	_sbrk			@ If not-not one, then it is one...so, do sbrk.
	b	.			@ if not, rot here...FOREVER!  Bwa-ha-ha!!!

_sbrk:	ldr	r1,=brk_value

        movs    PC, lr

