#!/bin/sh
trap "/bin/rm -f /net/user/r1/unix/jung/projects/labor/demo.vhdl.cache/vp/.clean_up.sh" 0
sleep 5
exec $COWAREHOME/common/bin/process_cleanup 22864 22864 > /dev/null 2>&1
