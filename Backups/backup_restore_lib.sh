#!/bin/bash

<<validation
validate if the two directories :  
1) directory to be backed up.
2) directory which should store eventually the backup.
are correct or not
validation

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

  if [ $# -eq 4 ]; then
    echo "ok 4 parameters!"
  else
    echo "To be able to use the script, you should do the following:"
    echo "1) directory to be backed up."
    echo "2) directory which should store eventually the backup."
    echo "3) encryption key that you should use to encrypt your backup."
    echo "4) number of days (n) that the script should use to backup only the changed files during the last n days."
    exit 0
  fi
  re='^[0-9]+$'
  if ! [[ $days =~ $re ]]; then
    echo "${days}: not a number try again with a correct data!"
    exit 0
  fi
}

backup() {

  # check if already taken a backup
  testFile=${TargetBackup}/".testFile.txt"
  if [ -f "$testFile" ]; then
    echo "You've already taken a backup. If anything changes to the original files, will be modified immediately when you run the script again."
    exit 0
  fi

  cp -r ${TargetDir} ${TargetBackup}
  data=${TargetBackup}/$(basename $TargetDir)
  # echo ${data}
  cd ${data}
  files=$(ls ${data})

  for i in $files; do
    # echo ${i}
    fullDate=$(echo $(date) | sed 'y/ /_/')
    fullDate=$(echo ${fullDate} | sed 'y/:/_/')ls-
    tar -czvf ${i}.tar.gz ./${i}
    rm -rf ${i}

  done

  $(cd .. && mkdir ${fullDate} && touch .testFile.txt)
  # changed=$(ls ${TargetDir})
  # echo ${changed}
  # for i in ${changed}; do
  #   echo $(find ${TargetDir}/${i} -mtime -${days})
  #   tar -czvf ${i}.tar.gz $(find ${TargetDir}/${i} -mtime -${days})
  #   mv ${i}.tar.gz ${data}
  # done

  # changedFiles=$(find ${TargetDir} -mtime -${days})
  # echo ${changedFiles}

  # tar -czvf ${data}.tar.gz ./$(basename $TargetDir) --remove-files
  # cd ..
  # scp -i EC2Naruto.pem -r Data ubuntu@ec2-54-165-173-161.compute-1.amazonaws.com:backup
  # echo $(pwd)

}

validate_restore_params() {

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

restore() {

  # echo ${TargetBackup} # /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups/Data
  # echo ${TargetDir}
  # echo ${EncryptionKey}
  # echo `pwd`

  files=$(ls ${TargetBackup})
  # echo ${files}
  cd ${TargetBackup}
  echo $(pwd)
  for i in $files; do
    echo ${i}
    tar -xf ${i} -C ${TargetDir}
  done
  echo $(pwd)
}

# ./restore.sh /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Backups/Data /home/mohamed/Desktop/Safrot/Projects/Secure-BackupRestore/Data_Restored mohamed
