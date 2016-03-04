#!/bin/csh

if ( $#argv > 2 || $#argv < 2 ) then
    echo "usage: determine_inst.csh <directory with diags>"
    exit 99
endif

set dir1=$argv[1]
set dir2=$argv[2]

setenv BINPATH ../bin

source ../esmadir.config
echo ESMADIR: $ESMADIR

unset argv
setenv argv
source $ESMADIR/src/g5_modules

if ($?PYTHONPATH) then
   setenv PYTHONPATH ../python:$PYTHONPATH
else
   setenv PYTHONPATH ../python
endif


echo BASEDIR: $BASEDIR


set workbase=$dir1/diff-$dir2

mkdir -p $workbase

set instlist=`ls $dir1/work/ |grep -v txt |grep -v conv`
set init='T'
foreach inst ( $instlist )
    set init='T'
    set dir1work=$dir1/work/$inst
    set dir2work=$dir2/work/$inst
    set workdir=$workbase/$inst
    mkdir -p $workdir

    cp $dir1work/$inst.all.agg $workdir/$inst.all.agg

    echo $workdir/$inst.all.agg $dir2work/$inst.all.agg
    $BINPATH/generate_agg_plot.diff.py $workdir/$inst.all.agg $dir2work/$inst.all.agg 

    foreach tHH ( 00 06 12 18 )
        cp $dir1work/$inst.$tHH\z.agg $workdir/$inst.$tHH\z.agg 
        $BINPATH/generate_agg_plot.diff.py $workdir/$inst.$tHH\z.agg $dir2work/$inst.$tHH\z.agg
        echo COMPLETE: $inst.$tHH\z.agg
    end

end



tar cvf $dir1.diff-$dir2.tar `find  $workbase/ |grep png` 
# tar cvf $dir.tar `find $workdir |grep 'png'` $dir/index.html

if (-e process_diag.nl) rm process_diag.nl

