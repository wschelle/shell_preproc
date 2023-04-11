#! /bin/bash

## Who is this?
sub='V10141'
ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

## What did (s)he do?
declare -a fnr=("func1" "func2" "func3" "func4")

fdir=$sdir'func/'
adir=$sdir'anat/'

## where are the functional files?
fdirz=()
ffile=()
ffile_ph=()
ffile2=()
nses=${#fnr[@]}

for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
ffile[i]=${fdirz[$i]}${fnr[$i]}'.nii.gz'
ffile_ph[i]=${fdirz[$i]}${fnr[$i]}'_ph.nii.gz'
ffile2[i]=${fdirz[$i]}${fnr[$i]}'-nordic.nii'
done

for (( i=0; i<nses; i++ ));
do
matlab -batch "apply_NORDIC('${ffile[$i]}','${ffile_ph[$i]}')"
done

for (( i=0; i<nses; i++ ));
do
gzip ${ffile2[$i]}
done

