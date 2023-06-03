#!/bin/bash

TargetBackup=$1
TargetDir=$2
DecryptionKey=$3

source ../Backups/backup_restore_lib.sh

validate_restore_params ${TargetBackup} ${TargetDir} ${DecryptionKey}

restore ${TargetBackup} ${TargetDir} ${DecryptionKey}

# ./restore.sh /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups/Data /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data_Restored mohamed
