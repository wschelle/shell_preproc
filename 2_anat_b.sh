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

## Moving to T1
adirz=$adir$anat'/'

mp2rage="'T1_real_t1008.nii.gz'"
afile=$adirz'iT1_real_t1008.nii.gz'
afile_hr=$adirz$anat'-0.5iso.nii.gz'

mfile=$adirz'mask-iT1_real_t1008.nii.gz'
mfile_hr=$adirz$anat'_mask-0.5iso.nii.gz'

sfile=$adirz'segt1.nii'
sfile_hr=$adirz'segt1-highres.nii.gz'

newpixdim=0.5x0.5x0.5

##Upsample baby
ultrahighdim=0.2x0.2x0.2
if ( [ ! -f $sfile_hr ] ); then
ResampleImage 3 $sfile $sfile_hr $ultrahighdim 0 1 2
fi

## Run LAYNII
if ( [ ! -f $adirz'layers.nii' ] ); then
cd /home/wouter/LAYNII-master/
./LN2_LAYERS -rim $sfile_hr -nr_layers 20 -equivol
fi


lay_eqvol=$adirz'layers_equivol-0.5mm.nii.gz'
if ( [ ! -f $lay_eqvol ] ); then
ResampleImage 3 $adirz'segt1-highres_layers_equivol.nii.gz' $lay_eqvol $newpixdim 0 1 4
fi
lay_eqdis=$adirz'layers_equidist-0.5mm.nii.gz'
if ( [ ! -f $lay_eqdis ] ); then
ResampleImage 3 $adirz'segt1-highres_layers_equidist.nii.gz' $lay_eqdis $newpixdim 0 1 4
fi
met_eqvol=$adirz'metric_equivol-0.5mm.nii.gz'
if ( [ ! -f $met_eqvol ] ); then
ResampleImage 3 $adirz'segt1-highres_metric_equivol.nii.gz' $met_eqvol $newpixdim 0 3'l' 6
fi
met_eqdis=$adirz'metric_equidist-0.5mm.nii.gz'
if ( [ ! -f $met_eqdis ] ); then
ResampleImage 3 $adirz'segt1-highres_metric_equidist.nii.gz' $met_eqdis $newpixdim 0 1 6
fi
gm_eqvol=$adirz'midGM_equivol-0.5mm.nii.gz'
if ( [ ! -f $gm_eqvol ] ); then
ResampleImage 3 $adirz'segt1-highres_midGM_equivol.nii.gz' $gm_eqvol $newpixdim 0 1 6
fi
gm_eqdis=$adirz'midGM_equidist-0.5mm.nii.gz'
if ( [ ! -f $gm_eqdis ] ); then
ResampleImage 3 $adirz'segt1-highres_midGM_equidist.nii.gz' $gm_eqdis $newpixdim 0 1 6
fi
thickness=$adirz'thickness-0.5mm.nii.gz'
if ( [ ! -f $thickness ] ); then
ResampleImage 3 $adirz'segt1-highres_thickness.nii.gz' $thickness $newpixdim 0 1 6
fi

