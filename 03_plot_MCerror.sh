#!/bin/bash

#################--------------------------------------------------------------------------------------------------

#This script produces 4 figures: Mean strain rate magnitude + error and mean dilatation rate + error
#The script is not too optimized. It needs to be modified to be less specific.
#Change coordinates, color directories, dir0, seism, faults, label file names, and many of the variables 
#in the item map parameters.
#uncomment seismicity and faults in plot item if needed.

#USE: plot_MCerror.sh 4_columns_error_file.dat iter_number

###############-----------------------------------------------------------------------------------------------------

#CHANGE HERE
west=8
east=19
south=36
north=46.5
#
R1="-R$west/$east/$south/$north"
wid=4.5
J1="-JM"$wid"i"
#
frame=1
PAPER_SIZE="a4"
gmt gmtset DIR_GSHHG ~/local/gshhg-gmt-2.3.7
gmt gmtset MAP_FRAME_TYPE fancy
gmt gmtset PS_PAGE_ORIENTATION portrait
gmt gmtset FONT_ANNOT_PRIMARY 15 FONT_LABEL 15 MAP_FRAME_WIDTH 0.15c FONT_TITLE 15p,Arial
gmt gmtset PS_MEDIA ${PAPER_SIZE}
gmt gmtset COLOR_MODEL hsv

interp="-I0.1"

origin="-X1.5 -Y1.75"

#color
colorbar="/home/gmeneses/Documents/RUB/Research/GMT/ScientificColourMaps7/lajolla/lajolla.cpt"
colorbarerror="/home/gmeneses/Documents/RUB/Research/GMT/ScientificColourMaps7/hawaii/hawaii.cpt"
colorbardil="/home/gmeneses/Documents/RUB/Research/GMT/ScientificColourMaps7/vik/vik.cpt"
colorbarseism="/home/gmeneses/Documents/RUB/Research/GMT/ScientificColourMaps7/batlow/batlow.cpt"

dir0="/home/gmeneses/local/compearth-master/surfacevel2strain"
vel_dir0=$(pwd)
#seismicity
seism=/home/gmeneses/local/compearth-master/surfacevel2strain/matlab_output/ITALY/seismicity/sismos_decyearformat.dat
#faults
faults=/home/gmeneses/local/compearth-master/surfacevel2strain/matlab_output/ITALY/faults/Faults/active_faults.gmt
error=$1

#--------------------------------------------------------------------------------------------------------------------
psfile1=$vel_dir0"/mean_mag.ps"
psfile2=$vel_dir0"/std_dev_mag.ps"
psfile3=$vel_dir0"/mean_dil.ps"
psfile4=$vel_dir0"/std_dev_dil.ps"
grdfile=$vel_dir0"/mean_mag.grd"
grdfile2=$vel_dir0"/std_dev_mag.grd"
grdfile3=$vel_dir0"/mean_dil.grd"
grdfile4=$vel_dir0"/std_dev_dil.grd"


#label file names
itag="italy"
dlab="d02"
qlab="q03_q08"
blab="b1"
nlab="3D"
slab="s1"
ulab="u0"
name=$itag"_"$dlab"_"$qlab"_"$blab"_"$nlab"_"$slab"_"$ulab

############### MAP PARAMETERS########################################
#min max values
#verify here with gmt grdinfo the min and max of the *grd files
cminstrain=$(echo 0 | bc -l)
cmaxstrain=$(echo 120 | bc -l)
cpwr3=$(echo -9 | bc -l)
norm3=$(echo 10 ^ $cpwr3 | bc -l)
cran=`echo $cmaxstrain - $cminstrain | bc -l`
dc=`echo $cran / 100 | bc -l`
Tstrain="-T"$cminstrain"/"$cmaxstrain"/"$dc

cminstrain2=$(echo 0 | bc -l)
cmaxstrain2=$(echo 20 | bc -l)
cran2=`echo $cmaxstrain2 - $cminstrain2 | bc -l`
dc2=`echo $cran2 / 100 | bc -l`
Tstrain2="-T"$cminstrain2"/"$cmaxstrain2"/"$dc2

cminstrain3=$(echo -90 | bc -l)
cmaxstrain3=$(echo 90 | bc -l)
cran3=`echo $cmaxstrain3 - $cminstrain3 | bc -l`
dc3=`echo $cran3 / 100 | bc -l`
Tstrain3="-T"$cminstrain3"/"$cmaxstrain3"/"$dc3

cptstrain="strain.cpt"
strain_mag=$vel_dir0"/"$name"_strain.dat"
strain_tensor=$vel_dir0"/"$name"_Dtensor_6entries.dat"
#mask_file=$vel_dir0"/"$name"_masked_pts.dat"
mask_info="-I0.1 -G200 -S0.2"
interp_surf="-I0.05 -T0"

# color bar
Dlen=9.5
xlegend=5.5
ylegend=4

Dx=`echo $xlegend + 2.7 + $Dlen/2 | bc -l`
Dy=`echo $ylegend + 0.5 | bc -l`
Dscale="-Dx"$Dx"/"$Dy"/"$Dlen"/0.35"
Bscale1="-Bx10+lSecInvStrainRate"
Bscale2="-By+lnstrain/y"
Bscale1b="-Bx1+lStd.Dev."
Bscale1c="-Bx10+lDilat.Rate"
#pscoast parameters
coast_res="-A500 -Di"
coast_infoW="$coast_res -W1 -N1"
xtick1=2 
xtick2=0.25
#B0="-Ba"$xtick1"f"$xtick2"d::"
#B=$B0

# both strain rate calculation must use the same group of velocities
mask=$vel_dir0"/it_2/"$name"_masked_pts.dat"
####################### END MAP PARAMETERS #############################################################




##### PLOTS############################################################################################ 
#strain rate
#gmt psbasemap $J1 $R1 -B -K -V -P $origin > $psfile1
awk '{print $1,$2,$3}' $error > mean.temp
awk '{print $1,$2,$4}' $error > std.temp
awk -v var=$norm3 '{print $1,$2,$3/var}'  mean.temp| gmt surface -G$grdfile $interp_surf $R1
gmt makecpt -C$colorbar $Tstrain -D > $cptstrain
gmt grdimage $grdfile $R1 $J1 -C$cptstrain -n+c -K  -V > $psfile1

gmt psmask $mask $R1 $J1 $mask_info -K -O -V >> $psfile1
gmt psmask -C -K -O -V >> $psfile1

#seismicity
#awk '{print $1, $2,$3, $4*$4/140}' $seism > seis.temp
#gmt makecpt  -C$colorbarseism -T2010/2022/2 -Z > fechaseism.cpt
#gmt psxy seis.temp  $R1 $J1 -Sc -Cfechaseism.cpt -K  -O -V  >> $psfile1
#gmt psscale  -Cfechaseism.cpt -I -O -Dx15.5c/0.5c+w1.7i/0.1i  -Bx10+lTime -K -V >> $psfile1

#-W0.3p
## ppal strain rates
#ppal_strain=$vel_dir0"/ppal_strain_rate_masked.gmt"
##echo $ppal_strain
#awk -v var=$norm3 '{print $1,$2,$3/var}' $ppal_strain > e1.dat
#awk -v var=$norm3 '{print $1,$2,$4/var}' $ppal_strain > e2.dat
#awk '{print $1,$2,$5}' $ppal_strain > phi.dat
#gmt xyz2grd e1.dat -Ge1.grd -I0.1 $R1 -NNaN -V
#gmt xyz2grd e2.dat -Ge2.grd -I0.1 $R1 -NNaN -V
#gmt xyz2grd phi.dat -Gphi.grd -I0.1 $R1 -NNaN -V
#gmt grd2xyz e1.grd > e1Down.dat
#gmt grd2xyz e2.grd | awk '{print $3}' > e2Down.dat
#gmt grd2xyz phi.grd | awk '{print $3}' > phiDown.dat
#paste e1Down.dat e2Down.dat phiDown.dat > ppalDown.dat
#awk '{print $1,$2,$3,0,$5}' ppalDown.dat > e1.gmt
#awk '{print $1,$2,0,$4,$5}' ppalDown.dat > e2.gmt
#
#
#gmt psvelo e1.gmt  $J1 $R1 -Sx0.005  -A5p+e -Gred -W1p,red -O -K -V >>$psfile1
#gmt psvelo e2.gmt  $J1 $R1 -Sx0.005  -A5p+e -Gblue3 -W1p,blue3 -O -K -V >>$psfile1

# faults
#gmt psxy $faults $R1 $J1 -Sf0.2/1.5p+l+t -Wthinner,black -O -K >> $psfile1

gmt psscale -C$cptstrain $Dscale $Bscale1 $Bscale2 -K -O -V >> $psfile1
gmt pscoast $J1 $R1 -Ba2f1g0WSen:."Mean value mag. strain rate it="$2: $coast_infoW  -O -V >> $psfile1

awk -v var=$norm3 '{print $1,$2,$3/var}' std.temp| gmt surface -G$grdfile2 $interp_surf $R1
gmt makecpt -C$colorbarerror $Tstrain2 -D > $cptstrain
gmt grdimage $grdfile2 $R1 $J1 -C$cptstrain -n+c -K  -V > $psfile2
gmt psmask $mask $R1 $J1 $mask_info -K -O -V >> $psfile2
gmt psmask -C -K -O -V >> $psfile2
gmt psscale -C$cptstrain $Dscale $Bscale1b $Bscale2 -K -O -V >> $psfile2
gmt pscoast $J1 $R1 -Ba2f1g0WSen:."Std. deviation mag. strain rate it="$2: $coast_infoW  -O -V >> $psfile2

##############  dilatation plots ####################################
awk '{print $1,$2,$5}' $error > mean.temp
awk '{print $1,$2,$6}' $error > std.temp
awk -v var=$norm3 '{print $1,$2,$3/var}'  mean.temp| gmt surface -G$grdfile3 $interp_surf $R1
gmt makecpt -C$colorbardil $Tstrain3 -D > $cptstrain
gmt grdimage $grdfile3 $R1 $J1 -C$cptstrain -n+c -K  -V > $psfile3

gmt psmask $mask $R1 $J1 $mask_info -K -O -V >> $psfile3
gmt psmask -C -K -O -V >> $psfile3

gmt psscale -C$cptstrain $Dscale $Bscale1c $Bscale2 -K -O -V >> $psfile3
gmt pscoast $J1 $R1 -Ba2f1g0WSen:."Mean value dilatation rate it="$2: $coast_infoW  -O -V >> $psfile3

awk -v var=$norm3 '{print $1,$2,$3/var}' std.temp| gmt surface -G$grdfile4 $interp_surf $R1
gmt makecpt -C$colorbarerror $Tstrain2 -D > $cptstrain
gmt grdimage $grdfile4 $R1 $J1 -C$cptstrain -n+c -K  -V > $psfile4
gmt psmask $mask $R1 $J1 $mask_info -K -O -V >> $psfile4
gmt psmask -C -K -O -V >> $psfile4
gmt psscale -C$cptstrain $Dscale $Bscale1b $Bscale2 -K -O -V >> $psfile4
gmt pscoast $J1 $R1 -Ba2f1g0WSen:."Std. deviation dilatation rate it="$2: $coast_infoW  -O -V >> $psfile4
##########################################################################

gmt psconvert $psfile1 -A -Tf
rm $psfile1
gmt psconvert $psfile2 -A -Tf
rm $psfile2
gmt psconvert $psfile3 -A -Tf
rm $psfile3
gmt psconvert $psfile4 -A -Tf
rm $psfile4






