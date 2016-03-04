#!/bin/csh

if ( $#argv > 1 || $#argv < 1 ) then
    echo "usage: determine_inst.csh <directory with diags>"
    exit 99
endif

set dir=$argv[1]

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

set workbase=$dir/work

mkdir -p $workbase

#gen_webpage-hdrftr.py $dir

set instlist="conv"

set init='T'
foreach inst ( $instlist )
#    ./gen_webpage-tbl.py $dir $inst
    set init='T'
    set workdir=$workbase/$inst
    mkdir -p $workdir

    if (-e $workdir/$inst.process.log) rm -f $workdir/$inst.process.log
    find $dir |grep 'ods$' |grep $inst > $workdir/$inst.all.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _00z.ods > $workdir/$inst.00z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _06z.ods > $workdir/$inst.06z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _12z.ods > $workdir/$inst.12z.ges.txt
    cat $workdir/$inst.all.ges.txt |grep _18z.ods > $workdir/$inst.18z.ges.txt
    foreach file (`cat $workdir/$inst.all.ges.txt`)
        if (-e $file.dataarr) then
            echo File Exists: $file.dataarr SKIPPING
        else
            $BINPATH/process_ods.conv.x $file >> $workdir/$inst.process.log
        endif
        echo BINPATH/aggregate_dataarr $workdir/$inst.all.agg $file.dataarr $init
        $BINPATH/aggregate_dataarr.x $workdir/$inst.all.agg $file.dataarr $init
        set init='F'
    end
    $BINPATH/split_dataarr_by_kt.x $workdir/$inst.all.agg
    foreach file ($workdir/$inst.all.agg.*)
       set cval = `echo $file | grep -o '..$'`
       mkdir -p $workdir\_$cval
       mv $file $workdir\_$cval/$inst\_$cval.all.agg
       $BINPATH/generate_agg_plot.imp.conv.py $workdir\_$cval/$inst\_$cval.all.agg   
    end

#    ./generate_agg_plot.imp.py $workdir/$inst.all.agg
#    echo COMPLETE: $inst.all.agg
#    foreach tHH ( 00 06 12 18 )
#        set init='T'
#        foreach file (`cat $workdir/$inst.$tHH\z.ges.txt`)
#            echo ./aggregate_dataarr $workdir/$inst.$tHH\z.agg $file.dataarr $init
#            ./aggregate_dataarr $workdir/$inst.$tHH\z.agg $file.dataarr $init
#            set init='F'
#        end
#        ./generate_agg_plot.imp.py $workdir/$inst.$tHH\z.agg
#        echo COMPLETE: $inst.$tHH\z.agg
#    end

#    find $dir |grep bin |grep ges |grep $inst |grep dataarr > $workdir/$inst.all.ges.txt
#    set dates=`./determine_startdate_enddate.csh $dir $inst`
#    ./gen_weeklist_inputs.csh $dir $inst ${dates[2]} ${dates[1]}
end

#if (-e $dir/index.html) rm $dir/index.html

#cat $dir/$dir.html.hdr >> $dir/index.html

#foreach file (`find $dir |grep .html.tbl`)
#    cat $file >> $dir/index.html
#end

#cat $dir/$dir.html.hdr >> $dir/index.html


tar cvf $dir.tar `find $dir |grep 'png'` # $dir/index.html



