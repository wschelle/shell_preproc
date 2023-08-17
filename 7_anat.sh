#! /bin/bash

## As soon has freesurfer has created something acceptable, we can do this part! Yay.

## Who is this?
sub='V9934'
ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

fdir=$sdir'func/'
adir=$sdir'anat/'
fsdir='/Fridge/users/wouter/fs/'$sub'/'

sbdir=$sdir'anat/SB/'
sbfile=$sbdir'mSB.nii'
balh=$sbdir'BA.lh.nii.gz'
barh=$sbdir'BA.rh.nii.gz'

mri_label2vol --new-aseg2vol --subject $sub --annot $fsdir'label/rh.BA_exvivo.annot' --hemi rh --surf pial --proj abs -3.5 0 0.1 --regheader $fsdir'mri/brainmask.mgz' --temp $sbfile --o $barh
mri_label2vol --new-aseg2vol --subject $sub --annot $fsdir'label/lh.BA_exvivo.annot' --hemi lh --surf pial --proj abs -3.5 0 0.1 --regheader $fsdir'mri/brainmask.mgz' --temp $sbfile --o $balh


##Fill gaps in varea. Like a dentist.
balh2=$sbdir'fill_BA.lh.nii.gz'
barh2=$sbdir'fill_BA.rh.nii.gz'
cd /home/wouter/
if ( [ ! -f $balh2 ] ); then
python3 -c'from Python.python_scripts.wauwterpreproc import fillgaps; fillgaps('"'"$sbdir"'"',"'"BA.lh.nii.gz"'")'
fi
if ( [ ! -f $barh2 ] ); then
python3 -c'from Python.python_scripts.wauwterpreproc import fillgaps; fillgaps('"'"$sbdir"'"',"'"BA.rh.nii.gz"'")'
fi

##Realign local T1 to SB
t1='T1'
t1dir=$adir$t1'/'
t1file=$t1dir'AN4T1-0.5iso.nii.gz'
t1file2=$t1dir'T1-2-SB.nii.gz'
if ( [ ! -f $t1file2 ] ); then
antsRegistration --dimensionality 3 \
--output [$t1dir,$t1file2] \
--float \
--use-histogram-matching 0 \
--transform Rigid[0.1] \
--metric MI[$sbfile,$t1file, 1, 32, Regular, 0.5 ] \
--convergence [ 1000x500x200,1e-6,12 ] \
--smoothing-sigmas 2x1x0mm \
--shrink-factors 3x2x1 \
--transform Affine[0.1] \
--metric MI[$sbfile,$t1file, 1, 32, Regular, 0.25 ] \
--convergence [ 500x200,1e-6,8 ] \
--smoothing-sigmas 1x0mm \
--shrink-factors 2x1 \
--verbose

mv -f $t1dir'0GenericAffine.mat' $t1dir'T1-2-SB.mat'
fi

##Push segmentations+atlas to local T1 space
balh3=$t1dir'BA.lh.nii.gz'
barh3=$t1dir'BA.rh.nii.gz'
if ( [ ! -f $balh3 ] ); then
antsApplyTransforms -d 3 \
-r $t1file \
-t [$t1dir'T1-2-SB.mat', 1] \
-i $balh2 \
-o $balh3 \
-n NearestNeighbor \
-v 1 \
--float
fi

##It should be relevant for left hemi only, but if not then here's for right hemi:
#if ( [ ! -f $barh3 ] ); then
#antsApplyTransforms -d 3 \
#-r $t1file \
#-t [$t1dir'T1-2-SB.mat', 1] \
#-i $barh2 \
#-o $barh3 \
#-n NearestNeighbor \
#-v 1 \
#--float
#fi

##Push layers to func space
declare -a fnr=("func1" "func2" "func3" "func4")
fdir=$sdir'func/'
fdirz=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
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


funcBA=${fdirz[0]}'BA.lh.nii.gz'
if ( [ ! -f $funcBA ] ); then
antsApplyTransforms -d 3 \
-r ${fdirz[0]}${fnr[0]}'-prepavg.nii.gz' \
-t [$T1WARP, 1] \
-t [$T2WARPb, 0] \
-t [$T2WARPa, 1] \
-i $balh3 \
-o $funcBA \
-n NearestNeighbor \
-v 1 \
--float
fi






