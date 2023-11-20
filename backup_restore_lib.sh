#!/bin/bash


validate_backup_params() {

  if [[ -d ${TargetDir} ]]; then
    echo "TargetDir is correct!"
  else
    echo "$TargetDir is not valid please try again!"
    exit 0
  fi

  if [[ -d ${TargetBackup} ]]; then
    echo "TargetBackup is correct!"
  else
    echo "$TargetBackup is not valid please try again!"
    exit 0
  fi

  if [ $# -eq 2 ]; then
    echo "ok 2 parameters!"
  else
    echo "To be able to use the script, you should do the following:"
    echo "1) directory to be backed up."
    echo "2) directory which should store eventually the backup."
    exit 0
  fi
}

who_backup() {

  cd "$TargetBackup"
  unique_identifier=$(date +"%Y%m%d")
  hash=$(echo -n "$unique_identifier" | shasum | awk '{print $1}')

  # Output file
  output_file="backup_metadata.json"

  # Backup information
  date_time=$(date +"%Y-%m-%d %H:%M:%S")
  user_info=$(id)
  backup_start_time=$(date +"%Y-%m-%d %H:%M:%S")
  backup_source="$TargetDir"
  backup_destination="$TargetBackup${hash}"


  backup_command="rsync -av "$TargetDir" "$backup_destination""

  # Run the backup command
  $backup_command

  # Backup end time
  backup_end_time=$(date +"%Y-%m-%d %H:%M:%S")

  # Save metadata to the output file in JSON format
  echo "{" >>"$output_file"
  echo '  "Date and Time": "'"$date_time"'",' >>"$output_file"
  echo '  "SHA-1": "'"$hash"'",' >>"$output_file"
  echo '  "User Information": "'"$user_info"'",' >>"$output_file"
  echo '  "Backup Start Time": "'"$backup_start_time"'",' >>"$output_file"
  echo '  "Backup End Time": "'"$backup_end_time"'",' >>"$output_file"
  echo '  "Backup Source": "'"$backup_source"'",' >>"$output_file"
  echo '  "Backup Destination": "'"$backup_destination.tar.gz"'",' >>"$output_file"
  echo '  "Backup Command": "'"$backup_command"'"' >>"$output_file"
  echo "}" >>"$output_file"

  echo "Backup Done :)"
}

backup() {
  who_backup "$TargetBackup" "$TargetDir" # backup and metadata about this backup
}

validate_archive_params() {
  echo ${TargetBackup}
  if [[ -d ${TargetBackup} ]]; then
    echo "Target Backup is correct!"
  else
    echo "${TargetBackup} is not valid please try again!"
    exit 0
  fi
  if [ $# -eq 1 ]; then
    echo "ok 1 parameters!"
  else
    echo "something worng try again!"
  fi
}

archive() { # This function will be scheduled to be executed daily at 12:01 AM - ./archive.sh /path/to/target/directories

  Target_directory="$TargetBackup"
  # SHA-1 hash of the current date (YYYYMMDD)
  unique_identifier=$(date +"%Y%m%d")
  # echo "$unique_identifier"
  get_directory=$(echo -n "$unique_identifier" | shasum | awk '{print $1}')
  echo "$get_directory"

  for dir in "$Target_directory"/*/; do
    dir_name=$(basename "$dir")

    if [ "$dir_name" != "$get_directory" ]; then
      # Create a compressed tar archive for each directory, excluding JSON files
      tar czf "$Target_directory/$dir_name.tar.gz" --exclude="*.json" -C "$Target_directory" "$dir_name"
      # Remove the original directory
      rm -r "$dir"
    fi
  done

}

validate_restore_params() {

  # Validate SHA-1 format
  if [[ ! "$user_input_sha1" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo "Invalid SHA-1 format:("
    exit 1
  fi

  # Parse the JSON file and extract the Backup Destination based on the SHA-1 input
  backup_destination=$(jq -r --arg sha1 "$user_input_sha1" '. | select(.["SHA-1"] == $sha1) | .["Backup Destination"]' "$json_file")

  # Check if the backup_destination is not empty
  if [ -z "$backup_destination" ]; then
    echo "Backup not found for SHA-1: $user_input_sha1"
    exit 1
  fi

  # Determine the type of archive 
  if [[ "$backup_destination" =~ \.tar\.gz$ ]]; then
    echo "Ok"
  else
  echo "$backup_destination"
    echo "Unsupported archive format. Please adjust the extraction command."
    exit 1
  fi

  if [ $# -eq 3 ]; then
    echo "OK"
  else
    echo "To be able to use the script, you should do the following:"
    echo "1) /path/to/backup_metadata.json."
    echo "2) user_input_sha1."
    echo "3) /path/to/destination/to/restore/the/backup."
    exit 0
  fi
}

restore() {

  json_file="$1"
  user_input_sha1="$2"
  restore_directory="$3"
  # Parse the JSON file and extract the Backup Destination based on the SHA-1 input
  backup_destination=$(jq -r --arg sha1 "$user_input_sha1" '. | select(.["SHA-1"] == $sha1) | .["Backup Destination"]' "$json_file")
  echo "$backup_destination"
  tar -xzvf "$backup_destination" -C "$restore_directory"
}
