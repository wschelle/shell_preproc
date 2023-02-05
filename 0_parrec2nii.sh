#!/bin/bash

# Fill out subject specs here
sub='V10141'
year='2022'
parrecdir='/Library/MR-PARREC/'$year'/'$sub'/'

ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

declare -a anat=("MP2RAGE_080_localFOV_11_1" "3DviewSmartBrain_7T_2_1" "SmartBrain_7T_SCoil_1_1" "T2sfMRIFOVAnatomy_12_1" "WIP_-_MP2RAGE_11_4")
declare -a anatnew=("MP2R" "SB" "SBsc" "T2s" "T1")
declare -a fnr=("PSFpRFfmri_.7TR4_24mmSF1.3_7_1" "3DpRFS1fmri_.7TR4_24mmSF1.3_9_1" "3DpRFS1fmri_.7TR4_24mmSF1.3_10_1" "3DpRFS1fmri_.7TR4_24mmSF1.3_13_1" "TopUpPSFpRFfmri_.7TR4_24mmSF1.3_8_1")
declare -a fnrnew=("func1" "func2" "func3" "func4" "topup")

fdir=$sdir'func/'
adir=$sdir'anat/'
mkdir $fdir
mkdir $adir

fdirz=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnrnew[$i]}'/'
mkdir ${fdirz[$i]}
done

adirz=()
nanat=${#anat[@]}
for (( i=0; i<nanat; i++ ));
do
adirz[i]=$adir${anatnew[$i]}'/'
mkdir ${adirz[$i]}
done

for (( i=0; i<nses; i++ ));
do
dcm2niix -o ${fdirz[$i]} -f ${fnrnew[$i]} -z y -p n $parrecdir$sub'_'${fnr[$i]}'.PAR'
done

for (( i=0; i<nanat; i++ ));
do
dcm2niix -o ${adirz[$i]} -f ${anatnew[$i]} -z y -p n $parrecdir$sub'_'${anat[$i]}'.PAR'
done


