#!/bin/bash
#SBATCH -J QSIPREP_SSST_HSVS
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu 8000
#SBATCH -p q_cn

module load singularity/3.7.0

#User inputs:
subj=$1
bids_root_dir=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/data2/data/  #site
bids_root_dir_output=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/data2/data/ #site
#bids_root_dir=/GPFS/cuizaixu_lab_permanent/wangmiao/ABCD_dMRI_Result/GE/${subj:0:6}  #site
#bids_root_dir_output=/GPFS/cuizaixu_lab_permanent/wangmiao/ABCD_dMRI_Result/GE/${subj:0:6} #site
bids_root_dir_output_wd4singularity=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/WD2/
nthreads=8

#Run qsiprep
echo ""
echo "Running qsiprep on participant: $subj"
echo ""

#Make qsiprep directory and participant directory in derivatives folder
if [ ! -d $bids_root_dir_output/derivatives ]; then
    mkdir $bids_root_dir_output/derivatives
fi
if [ ! -d $bids_root_dir_output/derivatives/qsiprep ]; then
    mkdir $bids_root_dir_output/derivatives/qsiprep
fi

#${subj:7}
if [ ! -d $bids_root_dir_output/derivatives/qsiprep/$subj ]; then
    mkdir $bids_root_dir_output/derivatives/qsiprep/$subj
fi
if [ ! -d $bids_root_dir_output_wd4singularity/derivatives ]; then
    mkdir $bids_root_dir_output_wd4singularity/derivatives
fi
if [ ! -d $bids_root_dir_output_wd4singularity/derivatives/qsiprep ]; then
    mkdir $bids_root_dir_output_wd4singularity/derivatives/qsiprep
fi
if [ ! -d $bids_root_dir_output_wd4singularity/derivatives/qsiprep/$subj ]; then
    mkdir $bids_root_dir_output_wd4singularity/derivatives/qsiprep/$subj
fi

#Run qsiprep_prep
export SINGULARITYENV_TEMPLATEFLOW_HOME=/GPFS/cuizaixu_lab_permanent/Public_Data/HBN/code/rsfMRI/templateflow
unset PYTHONPATH; singularity run --cleanenv -B $bids_root_dir_output_wd4singularity/derivatives/qsiprep/$subj:/wd \
    -B $bids_root_dir:/inputbids \
    -B $bids_root_dir_output/derivatives/qsiprep/$subj:/output \
    -B $bids_root_dir_output/derivatives/qsiprep:/recon_input \
    -B $bids_root_dir_output/derivatives/fastcsr/sub-001:/freesurfer \
    -B /GPFS/cuizaixu_lab_permanent/wangmiao:/freesurfer_license \
    /GPFS/cuizaixu_lab_permanent/wuguowei/app_packages/qsiprep.sif\
    /inputbids /output \
    participant \
    --participant_label $subj \
    --unringing-method mrdegibbs \
    --output-resolution 2.0 \
    --freesurfer-input /freesurfer \
    --recon_input /recon_input \
    --recon_spec mrtrix_singleshell_ss3t_ACT-hsvs \
    --skip-bids-validation \
    -w /wd \
    --verbose \
    --notrack \
    --nthreads $nthreads \
    --mem-mb 32000 \
    --fs-license-file /freesurfer_license/license.txt
