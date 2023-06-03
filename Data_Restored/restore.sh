#!/bin/bash

TargetBackup=$1
TargetDir=$2
DecryptionKey=$3

source ../backup_restore_lib.sh

validate_restore_params ${TargetBackup} ${TargetDir} ${DecryptionKey}

restore ${TargetBackup} ${TargetDir} ${DecryptionKey}
