#!/bin/bash

TargetBackup=$1
TargetDir=$2
EncryptionKey=$3

source ../Backups/backup_restore_lib.sh

validate_restore_params ${TargetBackup} ${TargetDir} ${EncryptionKey}

restore ${TargetBackup} ${TargetDir} ${EncryptionKey}

# ./restore.sh /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups/Data /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data_Restored mohamed
