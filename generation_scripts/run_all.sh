#!/usr/bin/env bash
set -ex

scriptsdir=./generation_scripts
$scriptsdir/get_needed_tools.sh

$scriptsdir/build_icbm.sh
$scriptsdir/build_icbm_lobe_atlas_gm.sh
$scriptsdir/build_icbm_lobe_atlas_wm.sh  # not currently used
$scriptsdir/build_icbm_intracranial_volume.sh  # uses: build_icbm_mask_original.sh
$scriptsdir/build_icbm_intracranial_volume_expanded.sh  # depends in IntracranialVolume

$scriptsdir/build_icbm_brain_mask_for_classification.sh
$scriptsdir/build_icbm_mask.sh  # depends on CombinedModelLabels

# Binary Equal:
# - ICBM152LobeAtlasGM.nii
# - ICBM152LobeAtlasWM.nii
# - IntracranialVolumeExpanded.nii
# - icbm_avg_152_t1_tal_nlin_symmetric_VI.nii
# Not completely binary identical:
# - ICBMBrainMaskForClassification.nii NCOR = -0.993187
# - icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii NCOR = -0.999423
# Missing:
# - IntracranialVolume.nii
# - CombinedModelLabels.nii
# how is the CombinedModelLabels and IntracranialVolume original created?

frameofreference=data/mni152-icbm-frameofreference
diff -rqs $frameofreference output

# is IntracranialVolume = csf + vm from lobe atlas?
# has the CombinedModelLabels and IntracranialVolume been generated using free surfer?
# or is it skull in: https://www.bic.mni.mcgill.ca/~vfonov/icbm/icbm2009_lobe_defs.txt

# good documentation about mni space: https://www.lead-dbs.org/about-the-mni-spaces/
