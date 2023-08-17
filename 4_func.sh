#! /bin/bash

## Who is this?
sub='V9934'
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
ffile0=()
ffile=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
ffile0[i]=${fdirz[$i]}${fnr[$i]}'-nordic.nii.gz'
ffile[i]=${fdirz[$i]}${fnr[$i]}'-ndeo.nii.gz'
done

## Prepping the topup
tudirz=$fdir$tu'/'
tufile0=$tudirz$tu'.nii.gz'
tufile=$tudirz$tu'-deo.nii.gz'

if ( [ ! -f $tufile ] ); then
cp $tufile0 $tufile
3drefit -deoblique $tufile
fi

tufile2=$tudirz$tu'-mc.nii.gz'
if ( [ ! -f $tufile2 ] ); then
3dvolreg -prefix $tufile2 \
-base 0 \
-edging 4 \
$tufile
fi

tufile3=$tudirz$tu'-mcavg.nii.gz'
if ( [ ! -f $tufile3 ] ); then
3dTstat -mean \
-prefix $tufile3 \
$tufile2
fi


## Alright! Lets motion correction the shit outta these data
for (( i=0; i<nses; i++ ));
do
if ( [ ! -f ${ffile[$i]} ] ); then
cp ${ffile0[$i]} ${ffile[$i]}
3drefit -deoblique ${ffile[$i]}
fi
done


declare -a refscan=("81" "46" "46" "46")
ffile2=()
AWARP=()

for (( i=0; i<nses; i++ ));
do
ffile2[i]=${fdirz[$i]}${fnr[$i]}'-mc.nii.gz'
AWARP[i]=${fdirz[$i]}${fnr[$i]}'-mp.1D'

if ( [ ! -f ${ffile2[$i]} ] ); then
3dvolreg -prefix ${ffile2[$i]} \
-1Dfile ${fdirz[$i]}${fnr[$i]}'-mp' \
-maxdisp1D ${fdirz[$i]}${fnr[$i]}'-mp_maxdisp' \
-1Dmatrix_save ${AWARP[$i]} \
-base ${refscan[$i]} \
-edging 4 \
${ffile[$i]}
fi

done


## Calculate mean timeseries
ffile3=()
for (( i=0; i<nses; i++ ));
do
ffile3[i]=${fdirz[$i]}${fnr[$i]}'-mcavg.nii.gz'
if ( [ ! -f ${ffile3[$i]} ] ); then
3dTstat -mean \
-prefix ${ffile3[$i]} \
${ffile2[$i]} 
fi
done

## Align funcs with AP
tufile4=()
for (( i=0; i<nses; i++ ));
do
tufile4[i]=$tudirz$tu'-tu_2_f'$i'.nii.gz'
if ( [ ! -f ${tufile4[$i]} ] ); then
antsRegistration --dimensionality 3 \
--output [$tudirz${fnr[$i]}$tu'-tu_2_f'$i,${tufile4[$i]}] \
--float \
--use-histogram-matching 1 \
--transform Rigid[0.1] \
--metric CC[${ffile3[$i]},$tufile3, 1, 3, Regular, 0.25 ] \
--convergence [ 1000x800x500,1e-6,10 ] \
--smoothing-sigmas 3x2x1vox \
--shrink-factors 4x2x1 \
--verbose
fi
done

## Calculating EPI phase acquisition distortion warp (or EPAD warp, because that's less letters)
ffile4=()
for (( i=0; i<nses; i++ ));
do
ffile4[i]=${fdirz[$i]}${fnr[$i]}'-mcavgw.nii.gz'
if ( [ ! -f ${ffile4[$i]} ] ); then
3dQwarp -base ${ffile3[$i]} \
-source ${tufile4[$i]} \
-prefix ${ffile4[$i]} \
-plusminus \
-pmNAMES ap pa
fi
done

ffile4=()
ffile5=()
for (( i=0; i<nses; i++ ));
do
ffile4[i]=${fdirz[$i]}${fnr[$i]}'-mcavgw_pa.nii.gz'
ffile5[i]=${fdirz[$i]}${fnr[$i]}'-mcavgwr.nii.gz'
done
if ( [ ! -f ${ffile5[0]} ] ); then
cp ${ffile4[0]} ${ffile5[0]}
fi

CWARP=()
for (( i=1; i<nses; i++ ));
do
CWARP[i]=${fdirz[$i]}${fnr[$i]}'-2f1.1D'
if ( [ ! -f ${ffile5[$i]} ] ); then
3dAllineate -base ${ffile5[0]} \
-source ${ffile4[$i]} \
-prefix ${ffile5[$i]} \
-1Dmatrix_save ${CWARP[$i]} \
-nmi \
-master BASE \
-warp shift_rotate
fi
done

## Apply transformations to original dataset (like Rihanna ft. Drake - "warp warp warp")
BWARP=()
ffile6=()
for (( i=0; i<nses; i++ ));
do
BWARP[i]=${fdirz[$i]}${fnr[$i]}'-mcavgw_pa_WARP.nii.gz'
ffile6[i]=${fdirz[$i]}${fnr[$i]}'-prep.nii.gz'
if (( i == 0 )); then
3dNwarpApply -nwarp "${BWARP[$i]} ${AWARP[$i]}" \
-source ${ffile[$i]} \
-master ${ffile5[0]} \
-prefix ${ffile6[$i]} \
-newgrid 0.5

else
3dNwarpApply -nwarp "${CWARP[$i]} ${BWARP[$i]} ${AWARP[$i]}" \
-source ${ffile[$i]} \
-master ${ffile5[0]} \
-prefix ${ffile6[$i]} \
-newgrid 0.5
fi
done

## Cleaning up all the in-between steps
rm -f ${ffile[@]}
rm -f ${ffile2[@]}
rm -f ${ffile3[@]}
rm -f ${ffile4[@]}
rm -f ${ffile5[@]}
for (( i=0; i<nses; i++ ));
do
rm -f ${fdirz[$i]}${fnr[$i]}'-mcavgw_ap.nii.gz'
rm -f ${fdirz[$i]}${fnr[$i]}'-mcavgw_ap_WARP.nii.gz'
done





