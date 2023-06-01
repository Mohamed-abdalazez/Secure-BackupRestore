#!/bin/bash

# reading the target directory
# read -p "Please Enter the path of the target directory: " Target

TargetDir=$1
TargetBackup=$2
EncryptionKey=$3
days=$4

# echo $#

# TargetDir=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data
# TargetBackup=/home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups

source ./backup_restore_lib.sh

validate_backup_params ${TargetDir} ${TargetBackup} ${EncryptionKey} ${days}

backup ${TargetDir} ${TargetBackup}
