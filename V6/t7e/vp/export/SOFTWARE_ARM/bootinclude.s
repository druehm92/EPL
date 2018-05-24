;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright CoWare, Inc. 1996-2004. All rights reserved.           ;
;                                                                  ;
; Author : CoWare                                                  ;
;                                                                  ;
; Filename : bootinclude.s                                         ;
;                                                                  ;
; Purpose : this file is included in the main boot.s file.The      ;
;           contents depend on the inputs given by the user. The  ;
;           file can be empty also.                                ;
;                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PRESERVE8
	AREA 		 |__CWR_BOOT_CODE|, CODE, READONLY

	IMPORT  |__cwr_supervisor_stack_base|
	IMPORT  |__cwr_supervisor_stack_size|
	IMPORT  |__cwr_fiq_stack_base|
	IMPORT  |__cwr_fiq_stack_size|
	IMPORT  |__cwr_irq_stack_base|
	IMPORT  |__cwr_irq_stack_size|
	IMPORT  |__cwr_abort_stack_base|
	IMPORT  |__cwr_abort_stack_size|
	IMPORT  |__cwr_undef_stack_base|
	IMPORT  |__cwr_undef_stack_size|
	IMPORT  |__cwr_user_stack_base|
	IMPORT  |__cwr_user_stack_size|

;ReadOnly Data Section

	AREA 		 |_CWR_BOOT_DATA|, DATA, READONLY


	END
