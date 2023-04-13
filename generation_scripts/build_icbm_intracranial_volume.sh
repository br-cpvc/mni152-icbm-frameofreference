#!/usr/bin/env bash
set -ex

# deps: c3d

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/IntracranialVolume.nii
input_mask=$frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii
input_img=$frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI.nii

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d

tempdir=temp
outdir=output

#rm -rf $outdir $tempdir
mkdir -p $outdir #$tempdir

# convert combined labels to one label
final_out=$outdir/IntracranialVolume.nii
#$c3d ${input_mask} -erode 1 3x3x3vox -dilate 1 6x10x6vox -type uchar -o ${final_out}
# NCOR = -0.9528

#$c3d ${input_mask} -sdt -thresh -inf 5.95 1 0 -type uchar -o ${final_out}
# NCOR = -0.961714

#time $c3d $input_img -erf 20 100 ${input_mask} -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.845893

#time $c3d $input_img -erf 30 100 ${input_mask} -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.965091

#time $c3d $input_img ${input_mask} -as MASK -erode 1 3x3x3vox -dilate 1 5x5x5vox -replace 0 1 1 0 -times -o tmp.nii -erf 20 100 -push MASK -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.971762

#time $c3d $input_img ${input_mask} -as MASK -erode 1 3x3x3vox -dilate 1 5x5x5vox -replace 0 1 1 0 -times -o tmp.nii -erf 30 100 -push MASK -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.978952

# time $c3d $input_img ${input_mask} -as MASK -erode 1 3x3x3vox -dilate 1 5x5x5vox -replace 0 1 1 0 -times -o tmp.nii -erf 26 100 -push MASK -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.980703

# tried to use the csf proberbility mask as velocity field in the level set segmentation
# python3=/opt/miniconda/miniconda3/bin/python3
# orient="$python3 debian/usr/bin/OrientScalarVolume.py"
# $orient mni_icbm152_nlin_sym_09c_minc2/mni_icbm152_csf_tal_nlin_sym_09c.mnc.nii $tempdir/mni_icbm152_csf_tal_nlin_sym_09c_rai.nii RAI
# time $c3d $tempdir/mni_icbm152_csf_tal_nlin_sym_09c_rai.nii -trim 0vox -pad 23x21x-1vox 23x24x30vox 0 -o $tempdir/mni_icbm152_csf_tal_nlin_sym_09c_rai_padded.nii
# time $c3d $tempdir/mni_icbm152_csf_tal_nlin_sym_09c_rai_padded.nii -scale -1 -shift 1 -scale 0.38 -o velocity2.nii ${input_mask} -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}

./generation_scripts/build_icbm_mask_original.sh

# time $c3d $input_img -erf 26 100 output/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask_original.nii -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 100 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.985839

# time $c3d $input_img -erf 26 100 output/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask_original.nii -as ORIG -threshold 1 inf 1 -1 -levelset-curvature 0.2 -levelset 200 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.985847

time $c3d $input_img -erf 26 100 output/icbm_avg_152_t1_tal_nlin_symmetric_VI_mask_original.nii -as ORIG -threshold 1 inf 1 -1 -levelset-curvature 0.25 -levelset 200 -thresh 0 inf 1 0 -o ${final_out}
# NCOR = -0.985886

echo

$c3d ${pipeline_img} ${final_out} -ncor

$c3d ${pipeline_img} -replace 1 -1 ${final_out} -add -replace -1 2 -o $tempdir/IntracranialVolume_difference.nii

diff -s ${pipeline_img} ${final_out}
