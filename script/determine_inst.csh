#!/bin/csh

if ( $#argv > 1 || $#argv < 1 ) then
    echo "usage: determine_inst.csh <directory with diags>"
    exit 99
endif

set dir=$argv[1]

set init=1
set cinst=""

foreach file (`find $dir |grep ges |grep bin`)
    if ($init == 1) then
        set cfile=`basename $file`
        set dat = `echo $cfile | perl -wlne 'print "$1 $2 $3 $4" if  /^(\w+)\.diag_([\w\-]+)_ges\.(\d{8})_(\d{2})z.bin/'`
        set exp        = ${dat[1]}
        set inst       = ${dat[2]}
        set yyyymmdd   = ${dat[3]}
        set hh         = ${dat[4]}
        set yyyymmddhh = $yyyymmdd$hh
        set cinst      = $inst
        set init       = 0
#        echo $cinst
    else
        set cfile=`basename $file`
        set dat = `echo $cfile | perl -wlne 'print "$1 $2 $3 $4" if  /^(\w+)\.diag_([\w\-]+)_ges\.(\d{8})_(\d{2})z.bin/'`
        set exp        = ${dat[1]}
        set cinst       = ${dat[2]}
        set yyyymmdd   = ${dat[3]}
        set hh         = ${dat[4]}
        set yyyymmddhh = $yyyymmdd$hh
#        echo $cinst  $inst
        set listcheck = 0
        foreach iinst ( $inst )
            if ($cinst == $iinst) then
                set listcheck = 1 
            endif
        end
        if ($listcheck == 0) then
           set inst = ($cinst $inst)
        endif
   endif
end


echo $inst | sed 's/ /\n/g' |grep -v conv



