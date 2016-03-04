#!/bin/csh 

if ( $#argv > 1 || $#argv < 1 ) then
    echo "usage: determine_inst.csh <directory with diags>"
    exit 99
endif

setenv BINPATH ../bin

source ../esmadir.config
echo ESMADIR: $ESMADIR

set dir=$argv[1]

unset argv
setenv argv
source $ESMADIR/src/g5_modules

if ($?PYTHONPATH) then
   setenv PYTHONPATH ../python:$PYTHONPATH
else
   setenv PYTHONPATH ../python
endif


echo BASEDIR: $BASEDIR

echo this is for 5.12/5.13 and is using a namelist

echo ln -sf ../fix/process_diag.513.nl  process_diag.nl

ln -sf ../fix/process_diag.513.nl  process_diag.nl

set workbase=$dir/work

mkdir -p $workbase

set instlist=`$BINPATH/determine_inst.csh $dir`

set init='T'
foreach inst ( $instlist )
    set init='T'
    set workdir=$workbase/$inst
    mkdir -p $workdir

    if (-e $workdir/$inst.process.log) rm -f $workdir/$inst.process.log
    find $dir |grep 'bin$' |grep ges |grep $inst > $workdir/$inst.all.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _00z.bin > $workdir/$inst.00z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _06z.bin > $workdir/$inst.06z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _12z.bin > $workdir/$inst.12z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _18z.bin > $workdir/$inst.18z.ges.txt
    foreach file (`cat $workdir/$inst.all.ges.txt`)
        if (-e $file.dataarr) then
            echo File Exists: $file.dataarr SKIPPING
        else
            $BINPATH/process_diag.x $file >> $workdir/$inst.process.log
        endif
        echo BINPATH/aggregate_dataarr.x $workdir/$inst.all.agg $file.dataarr $init
        $BINPATH/aggregate_dataarr.x $workdir/$inst.all.agg $file.dataarr $init
        set init='F'
    end
    $BINPATH/generate_agg_plot.py $workdir/$inst.all.agg
    echo COMPLETE: $inst.all.agg
    foreach tHH ( 00 06 12 18 )
        set init='T'
        foreach file (`cat $workdir/$inst.$tHH\z.ges.txt`)
            echo BINPATH/aggregate_dataarr.x $workdir/$inst.$tHH\z.agg $file.dataarr $init
            $BINPATH/aggregate_dataarr.x $workdir/$inst.$tHH\z.agg $file.dataarr $init
            set init='F'
        end
        $BINPATH/generate_agg_plot.py $workdir/$inst.$tHH\z.agg
        echo COMPLETE: $inst.$tHH\z.agg
    end

#    find $dir |grep bin |grep ges |grep $inst |grep dataarr > $workdir/$inst.all.ges.txt
#    set dates=`./determine_startdate_enddate.csh $dir $inst`
#    ./gen_weeklist_inputs.csh $dir $inst ${dates[2]} ${dates[1]}
end


tar cvf $dir.tar `find $dir |grep 'png'` 

if (-e process_diag.nl) rm process_diag.nl

