/* -------------------------------------------------------------------------
 *
 * This is based on the linker command file which dld uses by default if no
 * linker command file is specified.
 *
 * It specifies how the object files in a build will be linked and located.
 * Combined with other linker command files provided with the compiler, it
 * provides a base to build your own file for your particular system.
 *
 * For a description of the different statements in this file, please refer
 * to the GNU linker user guide
 * ------------------------------------------------------------------------ */


/* The MEMORY command defines a single memory area using a name intended
 * to suggest its purpose:
 * ------------------------------------------------------------------------ */
MEMORY
{
	rom   (R) : org = 0x00000000, len = 0x00024fff
	rami  (WX): org = 0x04000000, len = 0x000a0000 
}


/* The SECTIONS command specifies where and how the linker should locate
 * different modules of the system.
 * ------------------------------------------------------------------------ */
SECTIONS
{
	/* Take all code from all objects and libraries and put into ROM */
	.text : {
		boot.o(.text)         /* Boot code */
		*(.text)              /* The rest of the code: wherever... */
                . = . + 8;
		*(.rodata);
		_etext = . ;
	}>rom


	__exidx_start = .;
	.ARM.exidx : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) }
	__exidx_end = .;

	
	/* Allocate space for the rest of the initialized data */
	.data : {  _data = .;   *(.data);           _edata = .;
                   _bstart = .; *(.bss)*(COMMON) ;  _bend = . ;
                   _end  = . ;
 	}>rami


        .stack 0x00008000 - 4 : {
                _int_stack = . - 0x100;  /* int stack sits "below" main stack*/
                _stack     = .;          /* main stack... */
        }

  PROVIDE (end = .);

        /* DWARF 2 */
        .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
        .debug_abbrev   0 : { *(.debug_abbrev) }
        .debug_line     0 : { *(.debug_line) }
        .debug_frame    0 : { *(.debug_frame) }
        .debug_str      0 : { *(.debug_str) }
        .debug_loc      0 : { *(.debug_loc) }
        .debug_macinfo  0 : { *(.debug_macinfo) }
}
			

