#! /bin/bash

## MAKE SURE YOU HAVE RUN SPM SEGMENT ON SB.NII.GZ FIRST!!!!

## Who is this?
sub='V9934'
ses='data'
rdir='/Fridge/users/wouter/'
tdir=$rdir'Laminar/VTS/'
fsdir=$rdir'fs/'
sdir=$tdir$sub'/'$ses'/'
adir=$sdir'anat/'

sbdir=$sdir'anat/SB/'
sbdir_str="'"$sbdir"'"
sbfile0='SB.nii.gz'
sbfile_str="'"$sbfile0"'"
sbfile=$sbdir'mSB.nii'


#sbfile1=$sbdir'iSB.nii.gz'
#sbfile2=$sbdir'aiSB.nii.gz'
#sbfile3=$sbdir'maiSB.nii.gz'
#sbfile4=$sbdir'maiSB_mask.nii.gz'
#sbfile5=$sbdir'amaiSB.nii.gz'

##Normalize SB file
#python3 -c'from Python.python_scripts.wauwterpreproc import survey_norm; survey_norm('$sbdir_str','$sbfile_str')'

## Run segmentation
## This takes ~10min. Snack time!
#an4dir=$sbdir'AN4/'
#if ( [ ! -d $an4dir ] ); then
#cd $sbdir
#antsAtroposN4.sh -d 3 \
#-a $sbfile1 \
#-c 4 \
#-g 1 \
#-o AN4
#fi
#mv $sbdir'AN4Segmentation'* $an4dir
#cp -f $an4dir'AN4Segmentation0N4.nii.gz' $sbfile2

##Skullstrip it
#bet $sbfile2 $sbfile3 -m -f 0.05

## Run segmentation
## This takes ~10min. Snack time!
#an4dir2=$sbdir'AN4A/'
#if ( [ ! -d $an4dir2 ] ); then
#mkdir $an4dir2
#cd $an4dir2
#antsAtroposN4.sh -d 3 \
#-a $sbfile2 \
#-x $sbfile4 \
#-c 5 \
#-g 1 \
#-o AN4
#fi
#cp -f $an4dir2'AN4Segmentation0N4.nii.gz' $sbfile5


## Freesurfer surface reconstruction
## This will take a considerable portion of your life. Continue living!
recon-all -all -s $sub -i $sbfile -parallel -openmp 8

# Check the results in freeview: terminal -> freeview -> open /freesurfer_directory/mri/brainmask.mgz
# If too much skull has been removed, increase the -wsthresh number by one in the next line and run it:
#
# recon-all -skullstrip -wsthresh 28 -clean-bm -subjid $sub
#
# keep doing that, until brainmask.mgz looks good. Then, run the following line:
# recon-all -autorecon2 -autorecon3 -s $sub


