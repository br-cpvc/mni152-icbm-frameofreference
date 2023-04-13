#!/usr/bin/env bash
set -ex

# deps: wget unzip minc-tools c3d OrientScalarVolume_new

dwndir=downloads
# from: http://nist.mni.mcgill.ca/?p=858
if [[ ! -f $dwndir/mni_icbm152_nl_VI_minc2.zip ]]; then
 mkdir -p $dwndir
 wget http://packages.bic.mni.mcgill.ca/mni-models/icbm152/mni_icbm152_nl_VI_minc2.zip -O $dwndir/mni_icbm152_nl_VI_minc2.zip
fi

tempdir=temp
if [[ ! -d $tempdir/mni_icbm152_nl_VI_minc2 ]]; then
 mkdir -p $tempdir
 unzip $dwndir/mni_icbm152_nl_VI_minc2.zip -d $tempdir/mni_icbm152_nl_VI_minc2
fi

frameofreference=data/mni152-icbm-frameofreference
pipeline_img=$frameofreference/icbm_avg_152_t1_tal_nlin_symmetric_VI.nii

c3d=./downloads/c3d-1.0.0-Linux-x86_64/bin/c3d
orient=./deps/pkg-slicer-cli/output/debian/usr/bin/OrientScalarVolume_new

outdir=output

mkdir -p $outdir

# convert image from minc2 to nifti format
# using mnc2nii from the minc-tools package
mnc2nii $tempdir/mni_icbm152_nl_VI_minc2/icbm_avg_152_t1_tal_nlin_symmetric_VI.mnc $tempdir/vi_from_minc2.nii
rm -rf mni_icbm152_nl_VI_minc2

# changing range from [-7.43239e-08, 90.0346] to [0, 90]
$c3d $tempdir/vi_from_minc2.nii -type uchar -o $tempdir/vi_from_minc2_uchar.nii


# compare voxels with original
# $c3d ${pipeline_img} $tempdir/vi_from_minc2_uchar.nii -ncor

# remove surrounding empty space
$c3d $tempdir/vi_from_minc2_uchar.nii -trim 0vox -type uchar -o $tempdir/vi_from_minc2_uchar_trimmed.nii

# pad image to get same resolution as old image: [197, 233, 189]
$c3d $tempdir/vi_from_minc2_uchar_trimmed.nii -pad 8x8x0vox 8x8x9vox 0 -type ushort -o $tempdir/vi_from_minc2_uchar_trimmed_padded.nii

# convert orientation from LPI to RAI,
# and from type uchar to short, changing file size from 8675641 to 17350930
$orient $tempdir/vi_from_minc2_uchar_trimmed_padded.nii $tempdir/vi_from_minc2_uchar_trimmed_padded_rai.nii -o RAI

final_out=$outdir/icbm_avg_152_t1_tal_nlin_symmetric_VI.nii
cp $tempdir/vi_from_minc2_uchar_trimmed_padded_rai.nii ${final_out}
#rm -rf $tempdir

# compare dimensions, bounding box, voxel size, and range
#$c3d ${pipeline_img} -info
#$c3d ${final_out} -info

# compare output with original
#ls -al ${pipeline_img} ${final_out}  # compare file size
#md5sum ${pipeline_img} ${final_out}
#$c3d ${pipeline_img} ${final_out} -ncor

diff -s ${pipeline_img} ${final_out}
