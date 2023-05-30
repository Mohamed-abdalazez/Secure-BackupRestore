#!/bin/bash

# reading the target directory 
# read -p "Please Enter the path of the target directory: " Target

TargetDir=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data
TargetBackup=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups

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

