#!/usr/bin/env bash
set -ex

# deps: c3d

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/ICBMBrainMaskForClassification.nii
input_mask=$frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii # TODO: should be generated

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d

tempdir=temp
outdir=output

#rm -rf $outdir $tempdir
mkdir -p $outdir #$tempdir

# convert combined labels to one label
final_out=$outdir/ICBMBrainMaskForClassification.nii
#$c3d ${input_mask} -sdt -thresh -inf 2.80 1 0 -type uchar -o ${final_out}
$c3d ${input_mask} -erode 1 3x3x3vox -dilate 1 5x5x5vox -type uchar -o ${final_out}
# cut using:
#cutting_mask=$frameofreference/IntracranialVolume.nii
#$c3d ${input_mask} -erode 1 3x3x3vox -dilate 1 5x5x5vox ${cutting_mask} -add -replace 1 0 -binarize -type uchar -o ${final_out}


echo

# compare dimensions, bounding box, voxel size, and range
#$c3d ${pipeline_img} -info
#$c3d ${final_out} -info
#echo

# compare output with original
#ls -al ${pipeline_img} ${final_out}  # compare file size
#md5sum ${pipeline_img} ${final_out}
$c3d ${pipeline_img} ${final_out} -ncor
#echo

$c3d ${pipeline_img} -replace 1 -1 ${final_out} -add -replace -1 2 -o $tempdir/ICBMBrainMaskForClassification_difference.nii

#diff -s ${pipeline_img} ${final_out}
