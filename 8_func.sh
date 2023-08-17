#! /bin/bash

## Who is this?
sub='V9934'
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
nses=${#fnr[@]}
for (( i=0; i<nses; i++ ));
do
fdirz[i]=$fdir${fnr[$i]}'/'
ffile[i]=${fdirz[$i]}${fnr[$i]}'-prep.nii.gz'
done

t1='T1'
t1dir=$adir$t1'/'
layfile=${fdirz[0]}'-lay-equidist.nii.gz'
parcfile=${fdirz[0]}'BA.lh.nii.gz'

export PYTHONPATH="$PYTHONPATH:/home/wouter"
ffile2=()
for (( i=0; i<nses; i++ ));
do
ffile2[i]=${fdirz[$i]}${fnr[$i]}'-prep-ls.nii.gz'
if ( [ ! -f ${ffile2[$i]} ] ); then
python3 -c'from Python.python_scripts.wauwterpreproc import laysmo; laysmo('"'"${ffile[$i]}"'"',"'"$layfile"'",layedge=1,kernelsize=9,fwhm=3.5,parcfile="'"$parcfile"'",maxparc=6)'
fi
done


