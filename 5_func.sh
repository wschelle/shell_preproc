#! /bin/bash

## Who is this?
sub='V10141'
ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

## What did (s)he do?
declare -a fnr=("func1" "func2" "func3" "func4")
declare -a tu=("topup")

fdir=$sdir'func/'
adir=$sdir'anat/'

## where are the functional files?
fdirz=()
ffile=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
ffile[i]=${fdirz[$i]}${fnr[$i]}'-prep.nii.gz'
done

t2='T2s'
t2dirz=$adir$t2'/'
t2file_hr=$t2dirz$t2'-mcavg-0.5iso.nii.gz'
t2file_hr_T1=$t2dirz$t2'-mcavg-0.5iso-T1.nii.gz'
T2WARP=()
for (( i=0; i<nses; i++ ));
do
T2WARP[i]=${fdirz[$i]}${fnr[$i]}'-T2.1D'
done

t1='T1'
t1dirz=$adir$t1'/'
t1file_hr=$t1dirz'AN4T1-0.5iso.nii.gz'
T1WARP=$t2dirz$t2'-T1.1D'


## Calculate mean timeseries
ffile2=()
for (( i=0; i<nses; i++ ));
do
ffile2[i]=${fdirz[$i]}${fnr[$i]}'-prepavg.nii.gz'
if ( [ ! -f ${ffile2[$i]} ] ); then
3dTstat -mean \
-prefix ${ffile2[$i]} \
${ffile[$i]} 
fi
done

## Lets register stuff to T2*
ffile3=${fdirz[0]}${fnr[0]}'-2T2.nii.gz'
if ( [ ! -f $ffile3 ] ); then
antsRegistration --dimensionality 3 \
--output [${fdirz[0]}${fnr[0]}'-T2-',${ffile3[0]}] \
--float \
--use-histogram-matching 1 \
--initial-moving-transform [$t2file_hr,${ffile2[0]},1] \
--transform Rigid[0.2] \
--metric MI[$t2file_hr,${ffile2[0]}, 1, 32, Regular, 0.5 ] \
--convergence [ 1000x800x500x400,1e-8,10 ] \
--smoothing-sigmas 4x2x1x0vox \
--shrink-factors 8x5x2x1 \
--transform Affine[0.1] \
--metric MI[$t2file_hr,${ffile2[0]}, 1, 32, Regular, 0.25 ] \
--convergence [ 500x200,1e-6,8 ] \
--smoothing-sigmas 1x0vox \
--shrink-factors 2x1 \
--transform SyN[0.1,2,0] \
--metric CC[$t2file_hr,${ffile2[0]}, 1, 3 ] \
--convergence [ 500x200,1e-4,6 ] \
--smoothing-sigmas 2x0vox \
--shrink-factors 3x1 \
--verbose
fi

#ffile4=${fdirz[0]}${fnr[0]}'-2T1.nii.gz'
#if ( [ ! -f $ffile4 ] ); then
#antsRegistration --dimensionality 3 \
#--output [${fdirz[0]}${fnr[0]}'-2T1-',$ffile4] \
#--float \
#--use-histogram-matching 0 \
#--winsorize-image-intensities [0.001,0.99] \
#--transform Rigid[0.1] \
#--metric MI[$t1file_hr, $ffile3, 1, 32, Regular, 0.5 ] \
#--convergence [ 800x400,1e-6,10 ] \
#--smoothing-sigmas 2x0vox \
#--shrink-factors 2x1 \
#--transform Affine[0.1] \
#--metric MI[$t1file_hr, $ffile3, 1, 32, Regular, 0.5 ] \
#--convergence [ 800x400,1e-6,10 ] \
#--smoothing-sigmas 2x1vox \
#--shrink-factors 2x1 \
#--verbose
#fi

## If the previous lines didn't work, try the next few. Takes forever.


if ( [ ! -f $t2file_hr_T1 ] ); then
antsRegistration --dimensionality 3 \
--output [$t2dirz$t2'-T1-',$t2file_hr_T1] \
--float \
--use-histogram-matching 0 \
--transform Rigid[0.1] \
--metric CC[$t1file_hr, $t2file_hr, 1, 3, Regular, 0.25 ] \
--convergence [ 800x400,1e-6,10 ] \
--smoothing-sigmas 2x1vox \
--shrink-factors 2x1 \
--verbose
fi


