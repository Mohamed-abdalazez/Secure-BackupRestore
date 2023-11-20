#!/bin/bash

json_file="$1"
user_input_sha1="$2"
restore_directory="$3"


source ../backup_restore_lib.sh

validate_restore_params ${@}

restore ${json_file} ${user_input_sha1} ${restore_directory}
