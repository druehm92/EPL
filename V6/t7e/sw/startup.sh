##!/bin/sh
#
#clear
#
#export PLATFORM_TOP=`pwd`
#
#echo "╭───────────────────────────────────────────╮"
#echo "│ MICROELECTRONIC SYSTEM                    │"
#echo "│ SYSTEM DESIGN                             │"
#echo "│ RESEARCH GROUP                            │"
#echo "├───────────────────────────────────────────┤"
#echo "│ de.uni-kl.ems.vp.singlearm9               │"
#echo "├───────────────────────────────────────────┤"
#echo "│ Start PCT:                                │"
#echo "│ Which Software for the Core(s)?           │"
#echo "│ 1 plain c                                 │"
#echo "│ 2 LINUX (Not yet implemented)!            │"  
#echo "│ 3 last saved                              │"              
#echo "├───────────────────────────────────────────┤"
#echo "│Debugger:                                  │"
#echo "│ 4 VPA (Choose in VPA the software image!) │"
#echo "│ 5 CGDB: plain c software                  │"
#echo "│ 6 CGDB: LINUX (Not yet implemented)!      │"
#echo "├───────────────────────────────────────────┤"
#echo "│ 7 Remove all generated stuff              │"
#echo "├───────────────────────────────────────────┤"
#echo "│ q Quit                                    │"
#echo "╰───────────────────────────────────────────╯"
#
#read -s -n 1 KEY
##read KEY
#
#case $KEY in
#	1*) pct singlearm9.xml scripts/plain.tcl & ;;
#	2*) pct singlearm9.xml scripts/os.tcl & ;;
#	3*) pct singlearm9.xml & ;;
#	4*) vpa -s scripts/vpa.tcl & ;;
#	5*) xterm -bg black -fg white -e 'cgdb -d arm-none-eabi-gdb ../sw/main.elf' &;;
#	6*) xterm -bg black -fg white -e 'cgdb -d arm-none-eabi-gdb ../sw/main.elf' &;;
#	7*) rm -rf export/* cwr ;;
#esac
