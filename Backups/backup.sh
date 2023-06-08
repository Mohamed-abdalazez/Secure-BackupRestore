#!/bin/bash

TargetDir=$1
TargetBackup=$2
EncryptionKey=$3
days=$4

source ../backup_restore_lib.sh

validate_backup_params ${@}
backup ${TargetDir} ${TargetBackup}
