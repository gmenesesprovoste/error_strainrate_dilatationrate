#! /usr/bin/python

import re,os,subprocess,glob
import shutil
import numpy as np
import math
import matlab.engine

# create here velocity random file from cGPS_italy_compearth_more2.5y_EU_mm_noislands.dat


outdir="/home/gmeneses/local/compearth-master/surfacevel2strain/matlab_output/current_test_results" 
veldir="/home/gmeneses/local/compearth-master/surfacevel2strain/data/ITALY"
velfile="cGPS_GrAtSiD_velocities_IGS14_italy_2010.0_2010.11_compearth_format.vel"
velfilepath="/home/gmeneses/Documents/RUB/Research/Jon_scripts/Italy_NGL_decomposition_Gianina/test_20100_201011/"+velfile


# =============================================================================
#         if i % 100 == 0:
#             print("values for the east:\n")
#             print("original: ",ve,ee)
#             print("borders: ",mue-sigmae,mue+sigmae)
#             print("aleatorio: ",se)            
# ============================================================================= 
                
        
        
localdir=os.getcwd()
eng = matlab.engine.start_matlab()
s = eng.genpath('/home/gmeneses/local/compearth-master/surfacevel2strain')
eng.addpath(s, nargout=0)

 
it = 100
for i in range(0,it):
    ofile=open("test.dat","w")
    with open(velfilepath,"r") as orig:
        for line in orig:
            l = line.rstrip()
            lon=l.split()[0]
            lat=l.split()[1]
            ve=l.split()[2]
            vn=l.split()[3]
            vu=l.split()[4]
            ee=l.split()[5]
            en=l.split()[6]
            eu=l.split()[7]
            di=l.split()[-3]
            df=l.split()[-2]
            sta=l.split()[-1]
            mue, sigmae = float(ve),float(ee)
            mun, sigman = float(vn),float(en)
            muu, sigmau = float(vu),float(eu)
            se = np.random.normal(mue, sigmae, size=None)
            sn = np.random.normal(mun, sigman, size=None)
            su = np.random.normal(muu, sigmau, size=None)
            print(lon,lat,se,sn,su,ee,en,eu,"0 0 0",di,df,sta,file=ofile)
        ofile.close()    
        shutil.move(localdir+"/test.dat",veldir+"/italy.vel")
    
        eng.surfacevel2strain(nargout=0)

        source = outdir + "/"
        dest = localdir+ "/it_" +str(i) + "/"
        
        os.makedirs(dest,exist_ok=True)
        shutil.move(veldir+"/italy.vel",dest+velfile)
        allfiles = os.listdir(source)
        for f in allfiles:
            shutil.move(source + f, dest + f)
             

        
        
    
    
  

  


