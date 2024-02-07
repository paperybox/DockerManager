#! /bin/bash

Pwd=$( readlink -f "$( dirname $0 )" )
source $Pwd/../ysu.env

echo_info "================================= INIT MODULE CAMERA_DRIVER ================================="

cd $thirdparty_root_dir
checkCmdWarn wget https://gitlab.com/paperybox/cameradriver/-/archive/tag_release_v0.1/cameradriver-tag_release_v0.1.tar.gz

checkCmdError tar xvf ./cameradriver-tag_release_v0.1.tar.gz
cameradriver_src_root=$thirdparty_root_dir/cameradriver-tag_release_v0.1

cd $cameradriver_src_root
checkCmdError mkdir -p /etc/udev/rules.d/
chmod a+x $cameradriver_src_root/install.sh
checkCmdError $cameradriver_src_root/install.sh

rm $thirdparty_root_dir/cameradriver-tag_release_v0.1.tar.gz*


 echo_info "================================= MODULE CAMERA_DRIVER INIT SUCCESSFUL ================================="





