#!/bin/bash
set -e -x

# Install v4l2 support

# Only from 20.10 onwards, GitHub Actions is at 20.04 LTS.
#sudo apt-get install -y linux-modules-extra-azure

# Temporary:
sudo apt-get install -y patchutils libproc-processtable-perl
git clone --depth=1 git://linuxtv.org/media_build.git
cd media_build 
# disable some kernel options that cause build failures
disable=(
    "VIDEO_VIA_CAMERA"
    "VIDEO_OV9650"
    "VIDEO_OV772X"
    "SOC_CAMERA"
)
after_line="# These options should default to off"
for opt in "${disable[@]}"; do
    sed -i "/^$after_line/a disable_config('$opt');" v4l/scripts/make_kconfig.pl
done
tail -n 100 v4l/scripts/make_kconfig.pl
./build
sudo make install

sudo modprobe videodev

# Install v4l2loopback kernel module
sudo apt-get install -y v4l2loopback-dkms

# Create a virtual camera device for the tests
sudo modprobe v4l2loopback devices=2