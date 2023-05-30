#!/bin/bash

# reading the target directory 
# read -p "Please Enter the path of the target directory: " Target

TargetDir=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data
TargetBackup=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups

cp -r ${TargetDir} ${TargetBackup}

data=${TargetBackup}/Data
echo ${data}

tar -czvf ${data}.tar.gz ./Data --remove-files

# files=`ls ${data}`
# # echo ${files}
# for i in $files
# do
# # echo ${i}
# # tar -czvf ${i}.tar.gz ${data}/${i}
# done



# echo ${data}