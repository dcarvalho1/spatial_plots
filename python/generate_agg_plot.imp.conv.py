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


ict      = 1  - 1#must match process_ods.f90 indices 
iimp  = 2  - 1
iomf  = 3  - 1

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
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iimp,-1,field="imp",title="Total Impact",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iimp,ict,field="imppo",title="Impact Per Observation",cmap="newjet",fn=fn )
    dummymp.run(dh.plot_field, dat[:,:,ch,:],ch,iomf,ict,field="omfnbc",title="Mean O-F (K)",cmap="newjet",fn=fn )

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
