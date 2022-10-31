#!/bin/bash
#SBATCH -J QSIPREP_SS3T_ACT
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu 16000
#SBATCH -p q_cn

module load singularity/3.7.0

#User inputs:
subj=$1
bids_root_dir=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/data  #site
bids_root_dir_output=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/data #site
#bids_root_dir=/GPFS/cuizaixu_lab_permanent/wangmiao/ABCD_dMRI_Result/GE/${subj:0:6}  #site
#bids_root_dir_output=/GPFS/cuizaixu_lab_permanent/wangmiao/ABCD_dMRI_Result/GE/${subj:0:6} #site
bids_root_dir_output_wd4singularity=/GPFS/cuizaixu_lab_permanent/wangmiao/SHIT/tumor/WD
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
if [ ! -d $bids_root_dir_output_wd4singularity/derivatives/qsiprep ]; then
    mkdir $bids_root_dir_output_wd4singularity/derivatives/
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
    -B /GPFS/cuizaixu_lab_permanent/wangmiao:/freesurfer_license \
    /GPFS/cuizaixu_lab_permanent/wuguowei/app_packages/qsiprep.sif\
    /inputbids /output \
    participant \
    --participant_label $subj \
    --unringing-method mrdegibbs \
    --output-resolution 2.0 \
    --recon_input /recon_input \
    --recon_spec mrtrix_singleshell_ss3t_noACT \
    --skip-bids-validation \
    -w /wd \
    --verbose \
    --notrack \
    --nthreads $nthreads \
    --mem-mb 32000 \
    --fs-license-file /freesurfer_license/license.txt
