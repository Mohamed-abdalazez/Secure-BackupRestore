#!/bin/bash

# reading the target directory
# read -p "Please Enter the path of the target directory: " Target

TargetDir=$1
TargetBackup=$2

# echo $#

# TargetDir=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data
# TargetBackup=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups

source ./backup_restore_lib.sh

validate_backup_params ${TargetDir} ${TargetBackup}

cp -r ${TargetDir} ${TargetBackup}

data=${TargetBackup}/$(basename $TargetDir)

echo ${data}
files=$(ls ${data})
# echo ${files}
for i in $files; do
  echo ${i}

  tar -czvf ${i}.tar.gz ./$(basename $TargetDir)/${i} --remove-files
  cp -r ${i}.tar.gz ./$(basename $TargetDir)
  rm ${i}.tar.gz
done

tar -czvf ${data}.tar.gz ./$(basename $TargetDir) --remove-files
