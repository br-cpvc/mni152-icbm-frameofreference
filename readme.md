# Documentation

This document describes how the icbm/mni152 model files have been created.

original model files are located here: https://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/

The lobe labels are defined in the file: https://www.bic.mni.mcgill.ca/~vfonov/icbm/icbm2009_lobe_defs.txt

See also: https://www.bic.mni.mcgill.ca/~vfonov/icbm/ and for software: https://www.bic.mni.mcgill.ca/~vfonov/software/

## status

### used in segmentation

#### binary equal

* ICBM152LobeAtlasGM.nii, deps: none
* icbm_avg_152_t1_tal_nlin_symmetric_VI.nii, deps: none
* IntracranialVolumeExpanded.nii, deps: IntracranialVolume.nii

#### not binary equal yet

* NCOR = -0.999423, icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii, deps: CombinedModelLabels.nii
* NCOR = -0.993187, ICBMBrainMaskForClassification.nii, deps: icbm_avg_152_t1_tal_nlin_symmetric_VI_mask.nii
* NCOR = -0.985886, IntracranialVolume.nii, deps: ./generation_scripts/build_icbm_mask_original.sh

### not used in segmentation

* NCOR = -0.999997, CombinedModelLabels.nii, has been used in segmentation previously
binary equal, ICBM152LobeAtlasWM.nii, deps: none

## take a look at

* https://github.com/miykael/atlasreader/blob/master/atlasreader/data/README.md

## References

* [original ICBM article](https://pubmed.ncbi.nlm.nih.gov/11545704/)
* [download ICBM atlases](http://www.bmap.ucla.edu/portfolio/atlases/ICBM_Probabilistic_Atlases/)
