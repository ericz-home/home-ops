#!/bin/bash -e

DATE=$(date +%Y-%m-%d-%H-%M-%S-%Z)

backup_dir() {
    echo "Creating tarball $1.tar.gz"
    tar -czf $1.tar.gz -C $(dirname $1) $(basename $1) --remove-files

    OLD=$(ls $(dirname $1)/* | sort -n | head -n -3) 
    for d in $OLD;
    do
        echo "Deleting old backup $d"
        rm $d
    done
}

########################
##        k3s         ##
########################

backup_k3s() {
    DIR=/mnt/backups/k3s/k3s_$DATE
    echo "Creating backup $DIR"
    mkdir $DIR
    rclone copy /home/home/.rancher/k3s/server/db $DIR
    rclone copy /home/home/.rancher/k3s/server/token $DIR

    backup_dir $DIR
}


########################
##        z2m         ##
########################

backup_z2m() {
    DIR=/mnt/backups/zigbee2mqtt/z2m_$DATE
    echo "Creating backup $DIR"
    mkdir $DIR
    rclone copy --exclude certs /home/home/Documents/work/k3s/storage/zigbee2mqtt $DIR

    backup_dir $DIR
}


########################
##       vault        ##
########################

backup_vault() {
    DIR=/mnt/backups/vault/vault_$DATE
    echo "Creating backup $DIR"
    mkdir $DIR
    # run as rootlesskit because the sub-directories use subuids from rootless containers
    rootlesskit rclone copy /home/home/Documents/work/k3s/storage/vault $DIR

    backup_dir $DIR
}


if [[ "$1" == "all" || "$1" == "k3s" ]];
then
    backup_k3s
fi

if [[ "$1" == "all" || "$1" == "z2m" ]];
then
    backup_z2m
fi

if [[ "$1" == "all" || "$1" == "vault" ]];
then
    backup_vault
fi
