#!/usr/bin/env bash
set -ex

# deps: c3d

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/IntracranialVolumeExpanded.nii
input_mask=$frameofreference/IntracranialVolume.nii # TODO: should be generated

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d

tempdir=temp
outdir=output

#rm -rf $outdir $tempdir
mkdir -p $outdir #$tempdir

# convert combined labels to one label
final_out=$outdir/IntracranialVolumeExpanded.nii
$c3d ${input_mask} -dilate 1 5x5x5vox -type uchar -o ${final_out}

echo

# compare dimensions, bounding box, voxel size, and range
#$c3d ${pipeline_img} -info
#$c3d ${final_out} -info
#echo

# compare output with original
#ls -al ${pipeline_img} ${final_out}  # compare file size
#md5sum ${pipeline_img} ${final_out}
#$c3d ${pipeline_img} ${final_out} -ncor
#echo

diff -s ${pipeline_img} ${final_out}
