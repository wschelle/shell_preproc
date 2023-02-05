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

T2WARPa=${fdirz[0]}${fnr[0]}'-T2-0GenericAffine.mat'
T2WARPb=${fdirz[0]}${fnr[0]}'-T2-1InverseWarp.nii.gz'

t1='T1'
t1dirz=$adir$t1'/'
t1file_hr=$t1dirz'AN4T1-0.5iso.nii.gz'
T1WARP=$t2dirz$t2'-T1-0GenericAffine.mat'

T1lay=()
T1lay[0]=$t1dirz'layers_equivol-0.5mm.nii.gz'
T1lay[1]=$t1dirz'layers_equidist-0.5mm.nii.gz'
T1lay[2]=$t1dirz'metric_equivol-0.5mm.nii.gz'
T1lay[3]=$t1dirz'metric_equidist-0.5mm.nii.gz'
T1lay[4]=$t1dirz'midGM_equivol-0.5mm.nii.gz'
T1lay[5]=$t1dirz'midGM_equidist-0.5mm.nii.gz'
T1lay[6]=$t1dirz'thickness-0.5mm.nii.gz'

funclay=()
funclay[0]=${fdirz[0]}'-lay-equivol.nii.gz'
funclay[1]=${fdirz[0]}'-lay-equidist.nii.gz'
funclay[2]=${fdirz[0]}'-metric-equivol.nii.gz'
funclay[3]=${fdirz[0]}'-metric-equidist.nii.gz'
funclay[4]=${fdirz[0]}'-gm-equivol.nii.gz'
funclay[5]=${fdirz[0]}'-gm-equidist.nii.gz'
funclay[6]=${fdirz[0]}'-thickness.nii.gz'

##Push layers to func space
for (( i=0; i<7; i++ ));
do
antsApplyTransforms -d 3 \
-r ${fdirz[0]}${fnr[0]}'-prepavg.nii.gz' \
-t [$T1WARP, 1] \
-t [$T2WARPb, 0] \
-t [$T2WARPa, 1] \
-i ${T1lay[$i]} \
-o ${funclay[$i]} \
-n NearestNeighbor \
-v 1 \
--float
done


