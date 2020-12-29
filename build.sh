#!/bin/sh -xe

UBUNTU=ubuntu-20.04.1-preinstalled-server-arm64+raspi
LAVA=ubuntu-20.04.1-lava-worker-arm64+raspi
UBUNTU_URL=https://cdimage.ubuntu.com/releases/20.04.1/release/

# download and uncompress
wget -q $UBUNTU_URL/$UBUNTU.img.xz
unxz -v $UBUNTU.img.xz
mkdir -p out
cp $UBUNTU.img out/$LAVA.img

SANDBOX=$(mktemp -d -t guestfish-sandbox-XXXXXX)

sudo guestfish -a out/$LAVA.img --rw << __EOF__

# start the guestfs VM
run

# upload cloud-init config
mount /dev/sda1 /
upload assets/user-data /user-data
mkdir-p /cloud-init/lava
upload assets/set_hostname.py /cloud-init/lava/set_hostname.py
upload assets/lava-worker.service /cloud-init/lava/lava-worker.service
upload assets/lava-worker.config.template /cloud-init/lava/lava-worker.config.template
copy-in assets/overlays /cloud-init/lava
umount /dev/sda1

__EOF__

rm -rf $SANDBOX
rm -rf *.img *.img.xz

xz -fv out/$LAVA.img