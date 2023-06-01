#!/bin/bash

<<validation
validate if the two directories :  
1) directory to be backed up.
2) directory which should store eventually the backup.
are correct or not
validation

validate_backup_params() {

  if [[ -d ${TargetDir} ]]; then
    echo "done"
  else
    echo "$TargetDir is not valid please try again!"
    exit 0
  fi

  if [[ -d ${TargetBackup} ]]; then
    echo "done"
  else
    echo "$TargetBackup is not valid please try again!"
    exit 0
  fi

  if [ $# -eq 3 ]; then
    echo "ok"
  else
    echo "To be able to use the script, you should do the following:"
    echo "1) directory to be backed up."
    echo "2) directory which should store eventually the backup."
    echo "3) encryption key that you should use to encrypt your backup."
    echo "4) number of days (n) that the script should use to backup only the changed files during the last n days."
    exit 0
  fi
}

<<backup
validate if the two directories :  
1) directory to be backed up.
2) directory which should store eventually the backup.
are correct or not
backup

backup() {
  cp -r ${TargetDir} ${TargetBackup}

  data=${TargetBackup}/$(basename $TargetDir)

  # echo ${data}
  cd ${data}
  files=$(ls ${data})
  # echo ${files}
  for i in $files; do
    # echo ${i}
    date=$(date '+%Y_%m_%d')
    tar -czvf ${i}_${date}.tar.gz ./${i}
    rm -rf ${i}
  done

  # tar -czvf ${data}.tar.gz ./$(basename $TargetDir) --remove-files
  cd ..
  scp -i EC2Naruto.pem -r Data ubuntu@ec2-54-165-173-161.compute-1.amazonaws.com:backup
  echo $(pwd)

}
