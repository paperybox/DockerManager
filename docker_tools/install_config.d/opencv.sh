#! /bin/bash

Pwd=$( readlink -f "$( dirname $0 )" )
source $Pwd/ysu.env

network()
{
    local timeout=1
    local target=www.baidu.com
    local ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n 1`
    if [ "$ret_code" -eq "200" ]; then
    	echo_info "net work pass"
	    return 0
    else
        return 1
    fi
}

checkCmdError network

echo_info "================================= INIT MODULE OPENCV-3.4.9 ================================="
Codename=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F'=' '{print $2}')
sourceweb='http://mirrors.aliyun.com'
checkCmdError echo "
deb-src $sourceweb/ubuntu/ $Codename main restricted universe multiverse
deb-src $sourceweb/ubuntu/ $Codename-security main restricted universe multiverse
deb-src $sourceweb/ubuntu/ $Codename-updates main restricted universe multiverse
deb-src $sourceweb/ubuntu/ $Codename-proposed main restricted universe multiverse
deb-src $sourceweb/ubuntu/ $Codename-backports main restricted universe multiverse
" > /etc/apt/sources.list.d/opencv-depency.list

checkCmdError apt update
checkCmdError apt-get install -y openssh-client ssh vim make cmake gcc g++ curl git python3 git-lfs libgtk-3-dev libgtk2.0-dev pkg-config build-essential libavcodec-dev libavformat-dev libswscale-dev wget ca-certificates python3-dev python3-numpy python-dev python-numpy libpython3-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff5-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev liblapacke-dev libopenexr-dev libxvidcore-dev libx264-dev libatlas-base-dev gfortran libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev libavresample-dev libgphoto2-dev libopenblas-dev



#定义安装路径

install_dir="$install_root/opencv-3.4.9"
src_root=$thirdparty_root_dir
mkdir -p $src_root && cd $src_root

opencv_src_dir="$src_root/opencv"
checkCmdWarn git clone -b 3.4.9 https://gitlab.com/immersaview/public/remotes/opencv.git


opencv_contribut_dir="$src_root/opencv_contrib"
checkCmdWarn git clone -b master https://gitlab.com/gawainsciencer/opencv_contrib.git


ippicv_src_dir="$src_root/ippicv"
checkCmdWarn git clone -b tag_build_for_opencv_3.4.9 https://gitlab.com/paperybox/ippicv.git

cd $ippicv_src_dir && git lfs pull
sed -i 's!https://raw.githubusercontent.com/opencv/opencv_3rdparty/${IPPICV_COMMIT}/ippicv/!/workspace/3rdparty/opencv_src/ippicv!g' $opencv_src_dir/3rdparty/ippicv/ippicv.cmake

cd $opencv_src_dir && mkdir -p build && cd build

checkCmdError cmake -DCMAKE_BUILD_TYPE=RELEASE \
      -DOPENCV_EXTRA_MODULES_PATH=$opencv_contribut_dir/modules \
      -DBUILD_opencv_face=OFF \
      -DBUILD_opencv_xobjdetect=OFF \
      -DBUILD_opencv_xfeatures2d=OFF \
      -DPYTHON_DEFAULT_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") \
      -DPYTHON3_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") \
      -DPYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
      -DPYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
      -DOPENCV_GENERATE_PKGCONFIG=YES \
      -DCMAKE_INSTALL_PREFIX=$install_dir \
      -DOPENCV_IPPICV_URL=$ippicv_src_dir \
      ..

checkCmdError make -j$cpus
checkCmdError make install


cd $install_root
ln -s opencv-3.4.9 opencv-3
ln -s opencv-3 opencv
install_dir="$install_root/opencv"
checkCmdError echo "$install_dir/lib" > /etc/ld.so.conf.d/opencv.conf
ldconfig

mkdir -p /usr/local/lib/pkgconfig
cp $opencv_src_dir/build/unix-install/opencv.pc /usr/local/lib/pkgconfig
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

pkg-config opencv --modversion
if [ $? -ne 0 ]; then
    echo_error "================================= MODULE OPENCV-"$(pkg-config opencv --modversion)" INIT FAILED ================================="
else
    echo_info "================================= MODULE OPENCV-"$(pkg-config opencv --modversion)" INIT SUCCESSFUL ================================="
fi


