#!/usr/bin/env python

#import fortranfile
import matplotlib
matplotlib.use('Agg')
import numpy as np
import gc 
from numpy import ma
import sys
from mpl_toolkits.basemap import Basemap
from scipy.ndimage.interpolation import rotate
import matplotlib.pyplot as plt
#import matplotlib.cm as cm 
from matplotlib.colors import LinearSegmentedColormap
from dataarr_handler import dataarr_handler

import dummymp

def report_status(total_completed, total_running, total_procs):
    print("[%.2f%%] %i/%i completed (%i running)" % ((total_completed / (total_procs + 0.0)) * 100, total_completed, total_procs, total_running))


ict      = 1  - 1#must match process_diag.f90 indices 
iomfbbc  = 2  - 1
iomfbnbc = 3  - 1
ipr1     = 4  - 1
ipr2     = 5  - 1
ipr3     = 6  - 1
ipr4     = 7  - 1
ipr5     = 8  - 1
ipr6     = 9  - 1
isigo    = 10 - 1


fn = sys.argv[1]
dh = dataarr_handler()

dat = dh.read_dataarr(fn)

ch = 0

#cdat = dat[:,:,ch,ict]
lats, lons = dh.gen_latlons(dh.nx,dh.ny)
dummymp.set_priority_mode(dummymp.DUMMYMP_AGGRESSIVE)
#dummymp.set_max_processes(1)
counter = 0
for ch in range(dh.nch):
  if (np.sum(dat[:,:,ch,ict]) > 0):
    counter = counter + 1
    print "Queueing",ch
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ict,-1,field="count",title="Count",cmap="jet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iomfbbc,ict,field="omfbc",title="Mean O-F w/ BC (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iomfbnbc,ict,field="omfnbc",title="Mean O-F w/o BC (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr1,ict,field="pr1",title="Mean Constant Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr2,ict,field="pr2",title="Mean Fixed Position Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr3,ict,field="pr3",title="Mean ScanAng(var) Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr4,ict,field="pr4",title="Mean Lapse Rate Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr5,ict,field="pr5",title="Mean Lapse Rate**2 Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr6,ict,field="pr6",title="Mean CLW Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,[ipr4,ipr5],ict,field="prlapse",title="Mean Total Lapse Rate Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,[ipr1,ipr2,ipr3,ipr4,ipr5,ipr6],ict,field="prall",title="Mean Total Bias Correction (K)",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,isigo,ict,field="sigo",title="Mean SigO (K)",cmap="jet",fn=fn )
#    if (counter % 4 == 0):
#      while not (dummymp.process_process()):
#         dummymp.process_queue()
#    dummymp.process_process()


dummymp.set_end_callback(report_status)
ncpus = dummymp.getCPUAvail()
dummymp.set_max_processes(16)
dummymp.process_until_done()

gc.disable()
print 'Finished: '+fn

####################################################################
