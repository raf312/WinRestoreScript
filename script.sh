#!/bin/bash
#:Title             : Restore script for Windows
#:Date              : jul 28 2022
#:Author            : raf312
#:Version           : 2.0.0
#:Description       : Windows image restore script

clear

_repeat() {
    #@ USAGE: _repeat string number
    _REPEAT=$1
    while ((${#_REPEAT} < $2)); do       ## Loop until string exceeds desired length
        _REPEAT=$_REPEAT$_REPEAT$_REPEAT ## 3 seems to be the optimum number
    done
    _REPEAT=${_REPEAT:0:$2} ## Trim to desired length
}

repeat() {
    _repeat "$@"
    printf "%s\n" "$_REPEAT"
}

alert() {
    _repeat "${2:-#}" $((${#1} + 6))
    printf '\a%s\n' "$_REPEAT" ## \a = BEL
    printf '%2.2s %s %2.2s\n' "$_REPEAT" "$1" "$_REPEAT"
    printf '%s\n' "$_REPEAT"
}

alert "WINDOWS 10 RESTORE SYSTEM - LINUX"

printf "\nType 'y' to start the restore process.\n"
read resp
if [[ ${resp} = [yY] ]]; then
    for i in sda sdb sdc sdd sde sdf; do
        hd_model=$(cat /sys/block/$i/device/model)
        hd_name='SAMSUNG HD322HJ'

        if [[ $hd_model == *"$hd_name"* ]]; then
            echo "/dev/${i}1 /mnt/${i}1 ntfs-3g ro 0 0" >> /etc/fstab
            mkdir /mnt/${i}1
            mount /dev/${i}1
            img=/mnt/${i}1/img
            recycle="\$RECYCLE.BIN"
            systeminfo="System Volume Information"
            cd /mnt/${i}1/
            # rm -fr $recycle
            # rm -fr "$systeminfo"
            echo $PWD
            # SLEEP
            sleep 1

            while true; do
                clear
                printf "\n - Backup list:"
                ls $img
                printf "\n - Enter date of the backup to be restored: "
                read dataBackup

                if [[ -d $img/$dataBackup ]]; then
                    partimage restore /dev/sda1 $img/$dataBackup/win10sda1.000 -b -e
                    partimage restore /dev/sda3 $img/$dataBackup/win10sda3.000 -b -e
                    partimage restore /dev/sda2 $img/$dataBackup/win10sda2.000 -b

                    cd $HOME
                    umount /dev/${i}1
                    break
                else
                    echo ''
                    printf " - Invalid backup folder."
                fi
            done
        fi
    done
else
    exit 0
fi

alert "SYSTEM REBOOT"
printf "\nType 'y' to reboot your computer...\n"
read resp
if [[ ${resp} = [yY] ]]; then
    printf "Rebooting...\n"
    printf "\a3\n"
    sleep 1
    printf "\a2\n"
    sleep 1
    printf "\a1...\n"
    sleep 1

    init 6
else
    exit 0
fi
