#!/bin/bash

# reading the target directory 
# read -p "Please Enter the path of the target directory: " Target

TargetDir=$1
TargetBackup=$2

echo $#

if [ $# -eq 2 ]
then
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

data=${TargetBackup}/Data

echo ${data}
files=`ls ${data}`
# echo ${files}
for i in $files
do
 echo ${i}
  tar -czvf ${i}.tar.gz ./Data/${i} --remove-files
  cp -r ${i}.tar.gz ./Data
  rm  ${i}.tar.gz
done

tar -czvf ${data}.tar.gz ./Data --remove-files

