# Secure-BackupRestore

### Overview 

<img alt="Overview" src="Drafts/1_Overview.png" />

### How to use your backup tool

To use Secure-BackupRestore tool, you have to pass the parameters correctly on the command line which is:

-  4 parameters in the backup case.
    - directory to be backed up.
    - directory which should store eventually the backup.
    - encryption key that you should use to encrypt your backup.
    - number of days (n) that the script should use to backup only the changed files during the last n days.
    - eg. ```./backup.sh /Secure-BackupRestore/Data /Secure-BackupRestore/Backups MOAEMo 13```
-  3 parameters in the restore case.
    - the directory that contains the backup.
    - the directory that the backup should be restored to.
    - Decryption Key key that you should use to Decrypt your data.
    - eg. ``` ./restore.sh /Secure-BackupRestore/Backups/Data /Secure-BackupRestore/Data_Restored MOAEMo```


### Structure of the script

-  ```backup_restore_lib.sh``` that includes 7 functions:
  
    - validate_backup_params() {...}
    - Encryption() {...}
    - Decryption() {...}
    - remote_server() {...}
    - backup() {...}
    - validate_restore_params() {...}
    - restore() {...}
    
-  The two scripts ```backup.sh``` and ```restore.sh``` source ```backup_restore_lib.sh``` and invoke the corresponding functions.


### You have to edit the script to fit your needs as follows

- When copying the backup to a remote server, in my case, ```AWS EC2 instance```.
- so you have to set up yours in this part.
- eg. ```scp -i EC2Naruto.pem ${backup} ubuntu@ec2-54-197-112-106.compute-1.amazonaws.com:backup```
- Data directory, my own directory, I want to backup. It is yours to backup any directory on your machine.
- Setting up GPG in your machine.
- you have to install rename on your machine first
    - ```sudo apt install rename``` 
- If you want to take a backup of a particular directory, regardless of the backup of the changed files during the last n days only. use this code in ```buckup()``` function.
     ```bash
    # get the directory to be backed up to the backup area.
    cp -r ${TargetDir} ${TargetBackup}

    # A new path directory to be backed up in the backup area.
    data=${TargetBackup}/$(basename $TargetDir)
    cd ${data}
    files=$(ls ${data})
     ```


### crontab

- You have to enable cron on your machine.
  ```console
  moabdelaziz@pop-os:~$ sudo systemctl enable cron
  ```
- then type this command in your terminal to configure the scheduled task.
  ```console
  moabdelaziz@pop-os:~$ crontab -e
  ```
- Now Edit this file to introduce tasks to be run by cron.There is some default information, as you see.
  ```console
      GNU nano 6.2                                                                   /tmp/crontab.ZwipWk/crontab                                                                             
    # Edit this file to introduce tasks to be run by cron.
    # 
    # Each task to run has to be defined through a single line
    # indicating with different fields when the task will be run
    # and what command to run for the task
    # 
    # To define the time you can provide concrete values for
    # minute (m), hour (h), day of month (dom), month (mon),
    # and day of week (dow) or use '*' in these fields (for 'any').
    # 
    # Notice that tasks will be started based on the cron's system
    # daemon's notion of time and timezones.
    # 
    # Output of the crontab jobs (including errors) is sent through
    # email to the user the crontab file belongs to (unless redirected).
    # 
    # For example, you can run a backup of all your user accounts
    # at 5 a.m every week with:
    # 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
    # 
    # For more information see the manual pages of crontab(5) and cron(8)
    # 
    # m h  dom mon dow   command


    * * * * * /bin/bash /home/moabdelaziz/Secure-BackupRestore/Backups/backup.sh >> /home/moabdelaziz/output.txt
  ```

- BTW, if you run ```cat /etc/crontab``` You will find more information, as you see.

   ```console
  moabdelaziz@pop-os:~$ cat /etc/crontab
  # /etc/crontab: system-wide crontab
  # Unlike any other crontab you don't have to run the `crontab'
  # command to install the new version when you edit this file
  # and files in /etc/cron.d. These files also have username fields,
  # that none of the other crontabs do.

  SHELL=/bin/sh
  # You can also override PATH, but by default, newer versions inherit it from the environment
  #PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    
  # Example of job definition:
  # .---------------- minute (0 - 59)
  # |  .------------- hour (0 - 23)
  # |  |  .---------- day of month (1 - 31)
  # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
  # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
  # |  |  |  |  |
  # *  *  *  *  * user-name command to be executed
  17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
  25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
  47 6	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
  52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
  
  ```
- You can use [crontab.guru](https://crontab.guru/#*_*_*_*_*) it will be useful.
- When you source from ```backup_restore_lib.sh``` in ```backup.sh```, you have to use the absolute path.
- In this case, I put the parameters in the ```.env``` file and referenced it in buckup.sh with an absolute path, but you can do whatever you want. ex.
  - ```.env```
    
      ```txt
       TargetDir=/home/moabdelaziz/Secure-BackupRestore/Data
       TargetBackup=/home/moabdelaziz/Secure-BackupRestore/Backups
       EncryptionKey=PASS
       days=12
      ```
  - ```backup.sh```
    
      ```bash
        #!/bin/bash
      
        source /home/moabdelaziz/Secure-BackupRestore/backup_restore_lib.sh
        source /home/moabdelaziz/Secure-BackupRestore/Backups/.env
      
        TargetDir=$TargetDir
        TargetBackup=$TargetBackup
        EncryptionKey=$EncryptionKey
        days=$days

        validate_backup_params ${TargetDir} ${TargetBackup} ${EncryptionKey} ${days}
        backup ${TargetDir} ${TargetBackup}
      
      ```
- For more information about cron, I recommend:
    - [Scheduling Tasks with Cron](https://www.youtube.com/watch?v=7cbP7fzn0D8)
### Finally 

- Under improvement.
- Feel free to contribute, Have fun:).
