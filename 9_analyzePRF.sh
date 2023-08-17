#! /bin/bash

## Who is this?
sub='V9934'
ses='data'
rdir='/Fridge/users/wouter/Laminar/VTS/'
sdir=$rdir$sub'/'$ses'/'

## What did (s)he do?
declare -a fnr=("func1")

fdir=$sdir'func/'
adir=$sdir'anat/'

## where are the functional files?
fdirz=()
ffile=()
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
ffile[i]=${fdirz[$i]}${fnr[$i]}'-prep-ls.nii.gz'
done

layfile=${fdirz[0]}'-lay-equidist.nii.gz'
parcfile=${fdirz[0]}'BA.lh.nii.gz'
logfile=$rdir$sub'/log/design_rand_csv.txt'

export PYTHONPATH="/home/wouter/Python/python_scripts/"
cd $PYTHONPATH
for (( i=0; i<nses; i++ ));
do
python3 $PYTHONPATH'VTS_PRF.py' ${ffile[$i]} $layfile $parcfile $logfile
done
python3 $PYTHONPATH'VTS_PRF_VISUALIZE.py' $layfile $parcfile

