#!/bin/sh -xe

UBUNTU=ubuntu-20.04.1-preinstalled-server-arm64+raspi
LAVA=ubuntu-20.04.1-lava-worker-arm64+raspi
UBUNTU_URL=https://cdimage.ubuntu.com/releases/20.04.1/release/

# download and uncompress
wget -q $UBUNTU_URL/$UBUNTU.img.xz
unxz -v $UBUNTU.img.xz
cp $UBUNTU.img $LAVA.img

SANDBOX=$(mktemp -d -t guestfish-sandbox-XXXXXX)

sudo guestfish -a $LAVA.img --rw << __EOF__

# start the guestfs VM
run

# upload cloud-init config
mount /dev/sda1 /
upload assets/user-data /user-data
umount /dev/sda1

__EOF__

rm -rf $SANDBOX

xz -fv $LAVA.img