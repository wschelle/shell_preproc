#! /bin/bash

## Who is this?
sub='V10141'
ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

## What did (s)he do?
declare -a anat=("T1")
declare -a fnr=("func1" "func2" "func3" "func4")
declare -a tu=("topup")

fdir=$sdir'func/'
adir=$sdir'anat/'

## Doing T2star anatomy stuff first. Because why not.
declare -a t2=("T2s")
t2dirz=$adir$t2'/'
t2file=$t2dirz$t2'.nii.gz'

## T2s Motion correction
t2file_mc=$t2dirz$t2'-mc.nii.gz'
if ( [ ! -f $t2file_mc ] ); then
3dvolreg -prefix $t2file_mc \
-base 0 \
-edging 5 \
$t2file
fi

## Average the scans
t2file_mc_avg=$t2dirz$t2'-mc-avg.nii.gz'
if ( [ ! -f $t2file_mc_avg ] ); then
3dTstat -mean \
-prefix $t2file_mc_avg \
$t2file_mc
fi

## Upsampling to 0.5mm isotropic!
t2file_hr=$t2dirz$t2'-mcavg-0.5iso.nii.gz'
newpixdim=0.5x0.5x0.5
if ( [ ! -f $t2file_hr ] ); then
ResampleImage 3 $t2file_mc_avg $t2file_hr $newpixdim 0 3'l' 6
fi

## Moving to T1
adirz=$adir$anat'/'

mp2rage="'T1_real_t1008.nii.gz'"
afile=$adirz'iT1_real_t1008.nii.gz'
afile_hr=$adirz$anat'-0.5iso.nii.gz'

mfile=$adirz'mask-iT1_real_t1008.nii.gz'
mfile_hr=$adirz$anat'_mask-0.5iso.nii.gz'

sfile=$adirz'segt1.nii'
sfile_hr=$adirz'segt1-highres.nii.gz'


##Adjust MP2Rage scan file
cd /home/wouter/
python3 -c'from Python.python_scripts.wauwterpreproc import mp2rage_norm; mp2rage_norm('"'"$adirz"'"','$mp2rage')'


if ( [ ! -f $afile_hr ] ); then
ResampleImage 3 $afile $afile_hr $newpixdim 0 3'l' 6
fi

if ( [ ! -f $mfile_hr ] ); then
ResampleImage 3 $mfile $mfile_hr $newpixdim 0 0 6
fi

## Make a segmentation file first! Ya Lazy bum.

## Run segmentation (takes forever. grab six million coffees in the meantime)
an4dir=$adir'AN4/'
if ( [ ! -d $an4dir ] ); then
cd $adir
antsAtroposN4.sh -d 3 \
-a $afile_hr \
-c 20 \
-g 1 \
-o AN4
fi
mv $adir'AN4Segmentation'* $an4dir
cp $an4dir'AN4Segmentation0N4.nii.gz' $adirz'AN4T1-0.5iso.nii.gz'

## Make a segmatation file for laynii
cd /home/wouter/
python3 -c'from Python.python_scripts.wauwterpreproc import atropos_seg; atropos_seg('"'"$an4dir"'"',gmin=8,gmax=14)'
mv $an4dir'segt1.nii' $sfile

echo 'INTERACTION REQUIRED!'
echo 'check the segt1.nii'

## open /anat/T1/AN4T1-0.5iso.nii.gz and overlay anat/T1/segt1.nii (set scale to 1(min) to 3(max))
## check if it covers grey matter nicely.
## if not: change gmin and gmax values in previous lines.
## lower gmin will push border towards CSF and higher gmax will push border towards white matter (and vice versa vice versa)
## if you're happy with the results, proceed to the next step.


