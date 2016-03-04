#!/bin/csh

source esmadir.config
setenv GSIDIR $ESMADIR/src/GEOSgcs_GridComp/GEOSana_GridComp/GEOSaana_GridComp/GSI_GridComp


if ($#argv > 0) then
   if ($argv[1] == "clean") then
     rm src/*.o src/*.mod src/*.x
     rm -rf bin
     rm experiments/*.csh
     rm -rf experiments/*/*.dataarr experiments/*/work experiments/*/diff-*
     rm experiments/*.tar
     rm `find python |grep pyc$`
   else 
     echo Unknown option, exiting...
     exit 99
   endif
else
   source $ESMADIR/src/g5_modules

   set odsinc="-I $ESMADIR/Linux/include/GMAO_ods/"
   set odscomplib="$ESMADIR/Linux/lib/libGMAO_ods.a  $ESMADIR/Linux/lib/libGMAO_eu.a"
   set odslibpath="-L $BASEDIR/Linux/lib -L $ESMADIR/Linux/lib -L /usr/local/intel/Composer/composer_xe_2013.1.117/mkl/lib/intel64 -L -L/gpfsm/dnb32/mbhat/GCC/install/gcc-4.6.3/lib/gcc/x86_64-unknown-linux-gnu/4.6.3"
   set odslibs="  -lnetcdff -lnetcdf -lmfhdf -ldf -lhdf5_hl -lhdf5 -lm -lcurl  -lz -lrt -lm -lmfhdf -ldf -lsz -ljpeg -lgpfs  -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lirc -ldl -lc -lpthread -lrt  -lstdc++ -lssl"

   cd src

   ifort -c $GSIDIR/kinds.F90 -D_REAL8_ -r8
   #ifort -c ../bias_spatial_plots/read_diag.f90 -D_REAL8_ -r8
   ifort -c $GSIDIR/read_diag.f90 -D_REAL8_ -r8
   ifort -c process_diag.f90 -D_REAL8_ -r8

   ifort -o process_diag.x process_diag.o kinds.o read_diag.o -D_REAL8_ -r8

   ifort -o aggregate_dataarr.x aggregate_dataarr.f90  -D_REAL8_ -r8

   mpiifort  -o process_ods.conv.x process_ods.conv.f90 $odsinc $odscomplib $odslibpath $odslibs

   ifort -o split_dataarr_by_kt.x split_dataarr_by_kt.f90 -D_REAL8_ -r8
   
   mkdir -p ../bin

   cp *.x ../bin

   cd ../python

   cp generate_agg_plot.py ../bin
   cp generate_agg_plot.diff.py ../bin
   cp generate_agg_plot.imp.conv.py ../bin

   cd ../bin

   cp ../script/* .

   cd ../experiments

   ln -sf ../bin/gen_bias_spatial_plots.csh .
   ln -sf ../bin/gen_imp_spatial_plots.conv.csh .
   ln -sf ../bin/gen_bias_spatial_plots.differences.csh

endif

