#!/usr/bin/env bash
set -ex

# deps: wget unzip minc-tools c3d OrientScalarVolume_new

dwndir=downloads
if [[ ! -f $dwndir/mni_icbm152_nlin_sym_09c_minc2.zip ]]; then
 mkdir -p $dwndir
 wget https://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_sym_09c_minc2.zip -O $dwndir/mni_icbm152_nlin_sym_09c_minc2.zip
fi

tempdir=temp
if [[ ! -d $tempdir/mni_icbm152_nlin_sym_09c_minc2 ]]; then
 mkdir -p $tempdir
 unzip $dwndir/mni_icbm152_nlin_sym_09c_minc2.zip -d $tempdir/mni_icbm152_nlin_sym_09c_minc2
fi

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/ICBM152LobeAtlasWM.nii

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d
orient=./deps/pkg-slicer-cli/output/debian/usr/bin/OrientScalarVolume_new

outdir=output

mkdir -p $outdir

# convert image from minc2 to nifti format
# using mnc2nii from the minc-tools package
mnc2nii $tempdir/mni_icbm152_nlin_sym_09c_minc2/mni_icbm152_t1_tal_nlin_sym_09c_atlas/AtlasWhite.mnc $tempdir/ICBM152LobeAtlasWM_nii.nii
rm -rf $dwndir/mni_icbm152_nlin_sym_09c_minc2

# convert orientation from LPI to RAI,
# and from type uchar to short, changing file size from 8675641 to 17350930
$orient $tempdir/ICBM152LobeAtlasWM_nii.nii $tempdir/ICBM152LobeAtlasWM_nii_rai.nii -o RAI

$c3d $tempdir/ICBM152LobeAtlasWM_nii_rai.nii -replace 30 312 57 314 73 316 83 318 17 313 105 315 45 317 59 319  -shift -299 -clip 0 255 -shift 299 -replace 299 0 -type ushort -o $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled.nii
# omitted: 67 300 76 301


# remove surrounding empty space
#$c3d $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled.nii -trim 0vox -type ushort -o $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled_trimmed.nii

# pad image to get same resolution as old image: [197, 233, 189]
#$c3d $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled_trimmed.nii -pad 16x16x17vox 16x20x23vox 0 -type ushort -o $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled_trimmed_padded.nii


#$c3d $tempdir/ICBM152LobeAtlasWM_nii.nii -flip xy -o $tempdir/ICBM152LobeAtlasWM_nii_flipxy.nii


final_out=$outdir/ICBM152LobeAtlasWM.nii
cp $tempdir/ICBM152LobeAtlasWM_nii_rai_labeled.nii ${final_out}
#rm -rf $tempdir

# compare dimensions, bounding box, voxel size, and range
#$c3d ${pipeline_img} -info
#$c3d ${final_out} -info

# compare output with original
#ls -al ${pipeline_img} ${final_out}  # compare file size
#md5sum ${pipeline_img} ${final_out}
#$c3d ${pipeline_img} ${final_out} -ncor

diff -s ${pipeline_img} ${final_out}
