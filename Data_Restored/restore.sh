#!/bin/bash

TargetBackup=$1
TargetDir=$2
DecryptionKey=$3

source ../backup_restore_lib.sh

validate_restore_params ${@}

restore ${TargetBackup} ${TargetDir} ${DecryptionKey}
