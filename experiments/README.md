How to process experiments
==========================

Simply create a subdirectory with the experiment name (e.g. test_exp) and copy the binary diags (generally from /archive/u/userid/test_exp/obs/Yyyyy/Mmm/Ddd/Hhh/*ges*bin) for satellite radiance data, or the ods files for conventional data (generally from /archive/u/userid/test_exp/obs/Yyyyy/Mmm/Ddd/Hhh/*conv*ods). 

Look at the test_exp and test_exp2 experiments for simplified examples.  Note that the radiance scripts (gen_bias_spatial_plots.csh  gen_bias_spatial_plots.differences.csh) can handle multiple instruments at once.  They will also exclude conventional data.  The conventional script (gen_imp_spatial_plots.conv.csh) will only work on conventional files.  Ozone and precipitation files should be excluded by hand as there is no infrastructure to use and they may make the scripts break.  

It should also be noted that I would only copy either all *ges* or all *anl* files - do not mix them as they will (i think) be processed together into the same aggregate plots - which I think has little scientific value.

So step by step for radiances:

1.  Make directory in experiments/ subdirectory
  * mkdir x0016_ctl
2.  Copy the binary diag files into the directory
  * cp /archive/u/wrmccart/x0016_ctl/obs/Y2015/M09/D*/H*/*ges*bin /discover/nobackup/wrmccart/spatial_plots/experiments/x0016_ctl/
3.  Remove by hand the ozone (e.g. *sbuv* *omi*), conventional binary (*conv*.bin) 
  * rm x0016_ctl/*sbuv* x0016_ctl/*conv*bin x0016_ctl/*pcp*
4.  Trigger the script
  * ./gen_bias_spatial_plots.csh x0016_ctl
5.  If the web interface is set up, copy the resulting tarball to the spatial/spatial_data/ directory and untar it
  * scp x0016_ctl.tar polar:/www/html/intranet/personnel/wmccarty/spatial/spatial_data
  * ssh polar 
  * cd polar:/www/html/intranet/personnel/wmccarty/spatial/spatial_data ; tar xvf x0016_ctl.tar


For the comparison plots, you simply need to run two experiments using the methodology above, then run
  * ./gen_bias_spatial_plots.csh x0016_ctl second_exp

Step by step for conventional data:

1.  Make directory in experiments/ subdirectory
  * mkdir x0016_ctl
2.  Copy the conventional ods files into the directory
  * cp /archive/u/wrmccart/x0016_ctl/obs/Y2015/M09/D*/H*/*conv*ods /discover/nobackup/wrmccart/spatial_plots/experiments/x0016_ctl/
3.  Trigger the script
  * ./gen_imp_spatial_plots.conv.csh x0016_ctl
4.  If the web interface is set up, copy the resulting tarball to the spatial/spatial_data/ directory and untar it
  * scp x0016_ctl.tar polar:/www/html/intranet/personnel/wmccarty/spatial/spatial_data
  * ssh polar ; cd polar:/www/html/intranet/personnel/wmccarty/spatial/spatial_data ; tar xvf x0016_ctl.tar


