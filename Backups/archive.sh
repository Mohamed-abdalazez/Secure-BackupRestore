#!/bin/bash

TargetBackup=$1

source ../backup_restore_lib.sh

validate_archive_params ${@}
archive ${@}
