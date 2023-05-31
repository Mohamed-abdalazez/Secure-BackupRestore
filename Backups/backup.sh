#!/bin/bash

# reading the target directory
# read -p "Please Enter the path of the target directory: " Target

TargetDir=$1
TargetBackup=$2

# echo $#

<<validation
validate if the two directories :  
1) directory to be backed up.
2) directory which should store eventually the backup.
are correct or not
validation

if [[ -d ${TargetDir} ]]; then
  echo "done"
else
  echo "$TargetDir is not valid please try again!"
  exit 0
fi

if [[ -d ${TargetBackup} ]]; then
  echo "done"
else
  echo "$TargetBackup is not valid please try again!"
  exit 0
fi

if [ $# -eq 2 ]; then
  echo "ok"
else
  echo "To be able to use the script, you should do the following:"
  echo "1) directory to be backed up."
  echo "2) directory which should store eventually the backup."
  echo "3) encryption key that you should use to encrypt your backup."
  echo "4) number of days (n) that the script should use to backup only the changed files during the last n days."
  exit 0
fi

# TargetDir=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data
# TargetBackup=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups

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
