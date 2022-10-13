#! /usr/bin/python

import re,os,subprocess,glob
import shutil
import numpy as np
import math
import statistics



#outdir="/home/gmeneses/local/compearth-master/surfacevel2strain/matlab_output/current_test_results" 
#veldir="/home/gmeneses/local/compearth-master/surfacevel2strain/data/ITALY"
#velfile=veldir+"/original_velfiles/cGPS_italy_compearth_more2.5y_EU_mm_noislands.dat"
        

localdir=os.getcwd()

strainfile = "italy_d02_q03_q08_b1_3D_s1_u0_strain.dat"
tensorfile = "italy_d02_q03_q08_b1_3D_s1_u0_Dtensor_6entries.dat"
#it = 3
it = int(input("Enter number of iterations (folders): ") or "3")
n = int(input("Enter number of solutions (gridpoints): ") or "8800")
SRmag = np.zeros((n,), dtype=(float,it))
SRdil = np.zeros((n,), dtype=(float,it))


def get_num(fp):
    num = fp.split("_")[1][0:-1]
    return int(num)

k = 0
firstdir=""
for d in sorted(glob.glob("it*/"),key=get_num):
    i=0
    print("\n---------------------------------------------------\n")
    print("Working in directory "+d+"...\n")
    if i == 0:
        firstdir=d
    with open(localdir+"/"+d+tensorfile) as sfile:
        for lin in sfile:
            if "Drr" not in lin:
              if lin:  
                  
                Drr=float(lin.split()[0])
                Drth=float(lin.split()[1])
                Drph=float(lin.split()[2])
                Dthr=float(lin.split()[1])
                Dthth=float(lin.split()[3])
                Dthph=float(lin.split()[4])
                Dphr=float(lin.split()[2])
                Dphth=float(lin.split()[4])
                Dphph=float(lin.split()[5])
                mag=math.sqrt((Drr*Drr)+(Dthth*Dthth)+(Dphph*Dphph)+2*(Drth*Drth)+2*(Drph*Drph)+2*(Dphth*Dphth))
                dil=Drr + Dthth +  Dphph
                #print(i,k)
                SRmag[i,][k] = mag
                SRdil[i,][k] = dil
                #print(Drr,Drth,Dthth)
                i += 1
    k += 1
j = 0
with open("error_mag_dil_strainrate_it"+str(it)+".dat","w") as outfile:
    with open(localdir+"/"+firstdir+"/"+strainfile) as strain:
        for l in strain:
            if l:
                lon = l.split()[0]
                lat = l.split()[1]
                mmag = statistics.mean(SRmag[j,])
                smag = statistics.stdev(SRmag[j,])
                mdil = statistics.mean(SRdil[j,])
                sdil = statistics.stdev(SRdil[j,])
                print(lon,lat,mmag,smag,mdil,sdil,file=outfile)
                j += 1
                
    

    
    


#it = 50
#for i in range(0,it):
#    ofile=open("test.dat","w")
#    with open(velfile,"r") as orig:
#        for line in orig:
#            l = line.rstrip()
#            lon=l.split()[0]
#            lat=l.split()[1]
#            ve=l.split()[2]
#            vn=l.split()[3]
#            vu=l.split()[4]
#            ee=l.split()[5]
#            en=l.split()[6]
#            eu=l.split()[7]
#            di=l.split()[-3]
#            df=l.split()[-2]
#            sta=l.split()[-1]
#            mue, sigmae = float(ve),float(ee)
#            mun, sigman = float(vn),float(en)
#            muu, sigmau = float(vu),float(eu)
#            se = np.random.normal(mue, sigmae, size=None)
#            sn = np.random.normal(mun, sigman, size=None)
#            su = np.random.normal(muu, sigmau, size=None)
#            print(lon,lat,se,sn,su,ee,en,eu,"0 0 0",di,df,sta,file=ofile)
#        ofile.close()    
#        shutil.move(localdir+"/test.dat",veldir+"/cGPS_italy_compearth_more2.5y_EU_mm_noislands.dat")
#    
#        eng.surfacevel2strain(nargout=0)
#        source = outdir + "/"
#        dest = localdir+ "/it_" +str(i) + "/"
#        os.makedirs(dest,exist_ok=True)
#        shutil.move(veldir+"/cGPS_italy_compearth_more2.5y_EU_mm_noislands.dat",dest)
#        allfiles = os.listdir(source)
#        for f in allfiles:
#            shutil.move(source + f, dest + f)
#             

        
        
    
    
  

  


