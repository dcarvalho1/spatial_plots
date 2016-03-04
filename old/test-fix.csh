#!/bin/csh -fx

#if ( $#argv > 1 || $#argv < 1 ) then
#    echo "usage: determine_inst.csh <directory with diags>"
#    exit 99
#endif

#set dir=$argv[1]

source ../esmadir.config
echo ESMADIR: $ESMADIR

unset argv
setenv argv
source $ESMADIR/src/g5_modules 
echo BASEDIR: $BASEDIR

