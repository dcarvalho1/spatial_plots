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
iprlap   = 11 - 1
iprall   = 12 - 1

fn1 = sys.argv[1]
fn2 = sys.argv[2]

dh = dataarr_handler()

dat1 = dh.read_dataarr(fn1)
dat2 = dh.read_dataarr(fn2)

shape = np.shape(dat1)

print shape
print shape[0],shape[1],shape[2],iprall
dat = np.zeros([shape[0],shape[1],shape[2],iprall+1])

for ch in range(dh.nch):
  if (np.sum(dat1[:,:,ch,ict]) > 0):
    dat[:,:,ch,ict]     = dat1[:,:,ch,ict] - dat2[:,:,ch,ict] 
    dat[:,:,ch,iomfbbc] = (dat1[:,:,ch,iomfbbc]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,iomfbbc]/dat2[:,:,ch,ict])
    dat[:,:,ch,iomfbnbc] = (dat1[:,:,ch,iomfbnbc]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,iomfbnbc]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr1] = (dat1[:,:,ch,ipr1]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr1]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr1] = (dat1[:,:,ch,ipr1]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr1]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr3] = (dat1[:,:,ch,ipr3]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr3]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr4] = (dat1[:,:,ch,ipr4]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr4]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr5] = (dat1[:,:,ch,ipr5]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr5]/dat2[:,:,ch,ict])
    dat[:,:,ch,ipr6] = (dat1[:,:,ch,ipr6]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,ipr6]/dat2[:,:,ch,ict])
    dat[:,:,ch,iprlap] = ( ( dat1[:,:,ch,ipr4] + dat1[:,:,ch,ipr5] ) /dat1[:,:,ch,ict] ) - ( ( dat2[:,:,ch,ipr4] + dat2[:,:,ch,ipr5] ) / dat2[:,:,ch,ict] )
    dat[:,:,ch,iprall] = ( ( ( dat1[:,:,ch,ipr1] + dat1[:,:,ch,ipr2] + dat1[:,:,ch,ipr3] + dat1[:,:,ch,ipr4] + dat1[:,:,ch,ipr5] + dat1[:,:,ch,ipr6] ) /dat1[:,:,ch,ict] ) 
                         - ( ( dat2[:,:,ch,ipr1] + dat2[:,:,ch,ipr2] + dat2[:,:,ch,ipr3] + dat2[:,:,ch,ipr4] + dat2[:,:,ch,ipr5] + dat2[:,:,ch,ipr6] ) /dat2[:,:,ch,ict] )  ) 
    dat[:,:,ch,isigo] = (dat1[:,:,ch,isigo]/dat1[:,:,ch,ict]) - (dat2[:,:,ch,isigo]/dat2[:,:,ch,ict])


#cdat = dat[:,:,ch,ict]
lats, lons = dh.gen_latlons(dh.nx,dh.ny)
dummymp.set_priority_mode(dummymp.DUMMYMP_AGGRESSIVE)
#dummymp.set_max_processes(1)
counter = 0
for ch in range(dh.nch):
  if (np.sum(dat1[:,:,ch,ict]) > 0):
    counter = counter + 1
    print "Queueing",ch
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ict,-1,field="count",title="Count",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iomfbbc,-1,field="omfbc",title="Mean O-F w/ BC (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iomfbnbc,-1,field="omfnbc",title="Mean O-F w/o BC (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr1,-1,field="pr1",title="Mean Constant Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr2,-1,field="pr2",title="Mean Fixed Position Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr3,-1,field="pr3",title="Mean ScanAng(var) Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr4,-1,field="pr4",title="Mean Lapse Rate Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr5,-1,field="pr5",title="Mean Lapse Rate**2 Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,ipr6,-1,field="pr6",title="Mean CLW Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iprlap,-1,field="prlapse",title="Mean Total Lapse Rate Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iprall,-1,field="prall",title="Mean Total Bias Correction (K)",cmap="newjet",fn=fn1 )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,isigo,-1,field="sigo",title="Mean SigO (K)",cmap="newjet",fn=fn1 )
#    if (counter % 4 == 0):
#      while not (dummymp.process_process()):
#         dummymp.process_queue()
#    dummymp.process_process()


dummymp.set_end_callback(report_status)
ncpus = dummymp.getCPUAvail()
dummymp.set_max_processes(16)
dummymp.process_until_done()

gc.disable()
print 'Finished: '+fn1

####################################################################
