#!/bin/csh 

#if ( $#argv > 1 || $#argv < 1 ) then
#    echo "usage: determine_inst.csh <directory with diags>"
#    exit 99
#endif

#set dir=$argv[1]

source ../esmadir.config
echo ESMADIR: $ESMADIR

setenv BASEDIR `$ESMADIR/src/g5_modules basedir`
setenv MODINIT `$ESMADIR/src/g5_modules modinit`
setenv G5MOD `$ESMADIR/src/g5_modules modules`

echo BASEDIR: $BASEDIR
echo MODULES: $G5MOD

foreach mod ($G5MOD)
   module load $mod
end
