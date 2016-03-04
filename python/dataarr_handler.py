# dataarr handling modules -> reads and handles dataarr structures
import numpy as np
from mpl_toolkits.basemap import Basemap

class dataarr_handler:
#    import numpy as np

    np.seterr(divide='ignore')
    def __init__(self):
        from matplotlib.colors import LinearSegmentedColormap

        self.nx   = 0
        self.ny   = 0
        self.nch  = 0
        self.ndat = 0
        self.lats = []
        self.lons = []
        self.xarr = np.array(1)
        self.yarr = []
        self.m    = self.set_projection()

        self.cjcdict = {'blue': ((0.0, 1, 1),
                                 (0.001, 0.5, 0.5), 
                                 (0.11, 1, 1), 
                                 (0.34, 1, 1), 
                                 (0.65, 0, 0), 
                                 (1, 0, 0)),
                       'green': ((0.0, 1, 1),
                                 (0.001, 0, 0),
                                 (0.125, 0, 0),
                                 (0.375, 1, 1),
                                 (0.64, 1, 1),
                                 (0.91, 0, 0),
                                 (1, 0, 0)),
                         'red': ((0.0,  1, 1),
                                 (0.001, 0, 0), 
                                 (0.35, 0, 0), 
                                 (0.66, 1, 1), 
                                 (0.89, 1, 1), 
                                 (1, 0.5, 0.5))}


        self.njcdict = {'blue': ((0.0, 0.53,0.53),
                               (0.126,0.51,0.51),
                               (0.20, 1.0, 1.0),
                               (0.30, 1, 1),
                               (0.45, 0, 1),
                               (0.55, 1, 0.03),
                               (0.61, 0, 0),
                               (0.87,  0, 0),
                               (1.0, 1, 1)),            
                     'green': ((0.0, 0, 0),
                               (0.20, 0, 0),
                               (0.30, 1, 1),
                               (0.45, 1, 1),
                               (0.55, 1, 1),
                               (0.75, 0.04, 0.04),
                               (1.0, 0, 0) ),
                      'red':  ((0.0, 0.55, 0.55),
                               (0.13, 0, 0),
                               (0.30, 0, 0),
                               (0.45,0.78,1.0),
                               (0.55,1.0,0.97),
                               (0.63, 1, 1),
                               (0.75, 1, 1),
                               (0.88, 0.6,0.6),
                               (1, 1.0, 1.0))     }
        self.newjet = LinearSegmentedColormap('NewJet',self.njcdict)
        self.custjet= LinearSegmentedColormap('CustJet',self.cjcdict)

    def set_projection(self):
        m = Basemap(projection='mill',
            llcrnrlon=0. ,llcrnrlat=-90,
            urcrnrlon=360. ,urcrnrlat=90.)
        return m

    def read_dataarr(self, fn):#, nch=nch, ndat=ndat):   # reads dataarr or agg files
        import fortranfile as ff

        file = ff.FortranFile(fn, endian='>')
    
        dim = file.readInts()
    
        self.nx   = dim[0]
        self.ny   = dim[1]
        self.nch  = dim[2]
        self.ndat = dim[3]
    
        ndim = [self.nx,self.ny,self.nch,self.ndat]
        print self.nch

        rawdat = file.readReals('d')
        dat = np.reshape(rawdat,ndim,order='F')

        return dat
    
    def gen_latlons(self, nx, ny):

        m = self.set_projection()

        clons = np.arange(nx)*5.0 + 2.5 #- 180.0
        clats = np.arange(ny)*5.0 + 2.5 - 90.0

        lons = np.zeros((nx,ny))
        lats = np.zeros((nx,ny))

        for i in range(nx):
            lons[i,:] = clons[i]# % (i)
        
        for j in range(ny):
            lats[:,j] = clats[j]# % (j)

        self.lats = lats
        self.lons = lons

        self.xarr, self.yarr = self.m(lons,lats)

        return (lats, lons)

    def get_range(self, dat):
#        mx = np.nanmax(dat)
#        if mx > 1e99:
#            mx = np.nanmax(dat[np.where(dat < mx)])
#        mn = np.nanmin(dat)
#        if mn < -1e99:
#            mn = np.nanmax(dat[np.where(dat > mn)])
#        rng = np.array([mx, mn])
#        mx = np.max(np.abs(rng))
        mx = dat[np.isfinite(dat)]
        mx = np.percentile(np.abs(dat),99.0)
        return mx

    def plot_field(self,dat,ich,ifield,inorm,field="",title="",cmap="",fn="",pltmn=-9e99,pltmx=-9e99,irealmin=0):
        import matplotlib.pyplot as plt

        cdat = np.zeros([self.nx,self.ny])
        if type(ifield) == type(int()):
            ifield = [ifield]
        for i in ifield:
            cdat = cdat + dat[:,:,i]
        if (inorm >= 0):
            cdat = cdat / dat[:,:,inorm]

        cdat = np.nan_to_num(cdat)

        rng = self.get_range(cdat)

        if (cmap == "newjet"):
            mn = rng * (-1.0)
            mx = rng
            cm = self.newjet
        elif (cmap == "jet"):
            mn = 0
            mx = rng
            cm = self.custjet
        else:
            mn = np.nanmin(cdat)
            mx = np.nanmax(cdat)
            cm = plt.cm.jet
        if (irealmin == 1):
            mn = np.nanmin(cdat[np.where(cdat > 0 )])
            mn = mn - 0.01*mn
        if pltmn > -9e99:
            mn = pltmn
        if pltmx > -9e99:
            mx = pltmx
#        print mn
#        print mx
#        print "0"
        fig = plt.figure(figsize=(7,4))

#        print "1"
        x=self.xarr
        y=self.yarr
        cs = plt.pcolormesh(self.xarr,self.yarr,cdat, vmin=mn, vmax=mx, cmap=cm)
#        print "2"
        cbar = plt.colorbar()
        cbar.set_label(title)
        self.m.drawcoastlines()
        chstr = str(ich + 1)
        print 'Saving figure: '+fn+'.'+chstr+'.'+field+'.png'
        fig.savefig(fn+'.'+chstr+'.'+field+'.png')
        plt.close(fig)
        return cdat
#def query_dat(dat,
