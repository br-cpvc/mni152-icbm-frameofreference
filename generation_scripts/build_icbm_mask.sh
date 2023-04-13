#!/usr/bin/env bash
set -ex

# deps: c3d

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii
combinedlabels=$frameofreference/CombinedModelLabels.nii # TODO: should be generated

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d

tempdir=temp
outdir=output

#rm -rf $outdir $tempdir
mkdir -p $outdir $tempdir

# convert combined labels to one label
final_out=$outdir/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii
$c3d $combinedlabels -binarize -type uchar -o ${final_out}
# TODO: int 0,1,3 when smoothing
# TODO: try asymetric erode / dilate combos

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

$c3d ${pipeline_img} -replace 1 -1 ${final_out} -add -replace -1 2 -o $tempdir/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask_difference.nii
#exit 0

#diff -s ${pipeline_img} ${final_out}

echo " ----------------  NEW  ------------------"


CombinedModelLabelsOfficialConvention=$tempdir/CombinedModelLabelsOfficialConvention.nii
combinedlabels=$outdir/CombinedModelLabels.nii

CombinedModelLabelsOfficialConvention_wo=$tempdir/CombinedModelLabelsOfficialConvention_wo.nii
#CombinedModelLabelsOfficialConvention_rpi=$tempdir/CombinedModelLabelsOfficialConvention_rpi.nii

fwo=generation_scripts/old_data/frameofreference_wrong_orientation
combined_masks=$fwo/combined_masks.nii.gz

$c3d $combined_masks -flip xy -type uchar -o $tempdir/combined_masks_ro.nii.gz

# during the creation of combined_masks.nii.gz 'add' was used to combine labels into one mask, as some of the structures are overlapping this created problems in the final mask. Where structures where overlapping the label ids were added, moving there voxels into a third other structure. The following 3 structure overlaps have been identified:
# * label 6 in the left part of the image which in CombinedModelLabelsOfficialConvention have label id: 255 and should therefore be empty so that it will be filled in by the brain mask
# * label 2,5,6,8 right
# * label 12, left
# maybe this is caused be the overwriting of a single structure, e.g. hippocampus? TODO investigate this.

# the labels listed above are used for more than one structures in combined_masks.nii.gz

# use c3d left right subdivision to make a cutout mask that can be used to remove the left part of label 6 from the combined_mask
$c3d $combined_masks -flip xy -thresh 6 6 1 0 -as SEG -cmv -pop -pop -thresh 50% inf 0 1 -as MASK -push SEG -times -flip xy -replace 0 1 1 0 -o $tempdir/label_6_noise_cutout.nii.gz

$c3d $combined_masks \
-replace 9 4  8 5  5 10  7 11  6 12  11 6  10 7  4 8  3 9  2 2  1 3   13 2 15 12 \
$tempdir/label_6_noise_cutout.nii.gz -times \
-flip xy -o $tempdir/combined_masks_not_left_label_6.nii -flip xy \
-as STRUCTS -binarize \
-replace 0 1 1 0 -as INV_MASK $frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii -flip xy -times -push STRUCTS -add \
-type uchar -o $CombinedModelLabelsOfficialConvention_wo
# old method without label_6_noise_cutout
#$c3d $combined_masks -replace 1 3  6 12  3 9  7 11 11 6  8 5  9 4  10 7  5 10  4 8  13 2 -as STRUCTS -binarize -replace 0 1 1 0 -as INV_MASK $frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii -flip xy -times -push STRUCTS -add -type uchar -o $CombinedModelLabelsOfficialConvention_wo

CombinedModelLabelsOfficialConvention_fwo=$fwo/CombinedModelLabelsNeuroReaderConvention.nii
$c3d $CombinedModelLabelsOfficialConvention_wo $CombinedModelLabelsOfficialConvention_fwo -ncor
# NCOR = -0.999989


# debuging output
#$c3d $combinedlabels -thresh 255 255 1 0 $frameofreference/CombinedModelLabels.nii -thresh 255 255 1 0 -subtract -replace -1 2 -o $tempdir/diff_255.nii

$c3d $CombinedModelLabelsOfficialConvention_wo $CombinedModelLabelsOfficialConvention_fwo -subtract -flip xy -o $tempdir/CombinedModelLabelsOfficialConvention_subtract.nii

# if this is enabled, then all ncor below are -1
# CombinedModelLabelsOfficialConvention_wo=$fwo/CombinedModelLabelsOfficialConvention.nii

$c3d $CombinedModelLabelsOfficialConvention_wo -flip xy -type uchar -o $CombinedModelLabelsOfficialConvention
#exit 0


combinedlabels_wo=$tempdir/CombinedModelLabels_wo.nii

$c3d $CombinedModelLabelsOfficialConvention_wo -replace 8 43 9 4 7 9 6 48 2 53 3 17  1 255 13 255 12 255 11 255 5 255 4 255 10 255 -type uchar -o $combinedlabels_wo

$c3d $combinedlabels_wo $fwo/CombinedModelLabels.nii -ncor
# NCOR = -0.999997

$c3d $combinedlabels_wo -flip xy -type uchar -o $combinedlabels

$c3d $combinedlabels $frameofreference/CombinedModelLabels.nii -ncor
# NCOR = -0.999997

diff -s $combinedlabels $frameofreference/CombinedModelLabels.nii
