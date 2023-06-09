#!/bin/bash

<<validation
1) Check whether the directory to be backed up exists or not, 
as well as the directory where the backup should eventually be stored.
2) Verifying that the number of parameters is 4
3) Verifying that the number of days is an integer number and nothing else
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

Encryption() {
  tarFiles=$(ls ${data})
  for i in ${tarFiles}; do
    tar -cvzf - ${i} | gpg -c --batch --passphrase ${EncryptionKey} >${i}.gpg
    mv ${i}.gpg ${TargetBackup}/$(basename $TargetDir)_${fullDate}
  done
}

Decryption() {
  cd ${name}
  for i in ${files}; do
    # echo hi += ${i}
    gpg -d --batch --passphrase ${DecryptionKey} ${i} | tar -xvzf -
    rm ${i}
  done

  files=$(ls)
  for i in ${files}; do
    tar -xf ${i}
    rm ${i}
  done
}

remote_server() {
  backup=$(find ${target} -name "*.tar.gz" -maxdepth 1 -type f)
  for i in ${backup}; do
    scp -i naruto.pem ${i} ubuntu@ec2-54-209-139-74.compute-1.amazonaws.com:backups
  done
}

backup() {

  changedFiles=$(find ${TargetDir} -maxdepth 1 -mindepth 1 -mtime -${days})
  $(mkdir temp)
  for i in ${changedFiles}; do
    cp -r ${i} ${TargetBackup}/temp
  done

  # A new path directory to be backed up in the backup area.
  data=${TargetBackup}/temp
  cd ${data}
  files=$(ls ${data})

  # Compress all files inside the directory using tar.
  for i in ${files[@]}; do
    fullDate=$(echo $(date) | sed 'y/ /_/')
    fullDate=$(echo ${fullDate} | sed 'y/:/_/')
    tar -czvf ${i}.tar.gz ./${i}
    rm -rf ${i}
  done

  # creating a directory whose name is equivalent to the date taken in the compression process
  # creating a Heddin .testFile.txt file to use it to check if already taken a backup or not.
  $(cd .. && mkdir $(basename $TargetDir)_${fullDate})

  ## Encryption
  Encryption ${data}

  # compress <original directory name>_<date> to <original directory name>_<date>.tgz which is contain the final "name".tar.gz.gpg and remove the original one.
  tar -czvf ${TargetBackup}/$(basename $TargetDir)_${fullDate}.tar.gz ../$(basename $TargetDir)_${fullDate} --remove-files
  rm -rf ${TargetBackup}/temp

  # Push Encrypted backup to a remote server (EC2 instance)
  <<PushToEC2
    cd ..
    target=$(pwd)
    remote_server ${target}
PushToEC2

}

<<validation
1) Check whether the directory that contains the backup exists or not, 
as well as the directory that the backup should be restored to.
2) Verifying that the number of parameters is 3
validation

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
    echo "1) the directory that contains the backup."
    echo "2) the directory that the backup should be restored to."
    echo "3) DecryptionKey key that you should use to Decrypt your data."
    exit 0
  fi
}

restore() {

  # Extracting the backup file, which is <original directory name>_<date>.tar.gz

  cd ${TargetBackup}
  gpgFilesTar=$(find -maxdepth 1 -name '*.tar.gz')
  echo ${gpgFilesTar}

  for i in ${gpgFilesTar}; do
    tar -xf ${i} -C ${TargetDir}
  done

  for i in ${gpgFilesTar}; do
    name=${i}
    name=$(echo ${name} | cut -c 3- | rev | cut -c8- | rev)
    cd ..
    cd $(basename ${TargetDir})

    # Decryption, Files are Decrypted using the Decryption Key provided on the command line

    files=$(ls ${name})
    Decryption ${files}

  done
}
