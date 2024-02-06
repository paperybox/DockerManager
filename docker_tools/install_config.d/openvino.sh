#! /bin/bash

Pwd=$( readlink -f "$( dirname $0 )" )
source $Pwd/../ysu.env

pkg-config openvino --modversion 
if [ $? -eq 0 ]; then
    echo_info "openvino $(pkg-config openvino --modversion) has been installed, skiped install"
    exit 0
fi

openvino_src_root=$thirdparty_root_dir/openvino
openvino_install_root=$install_root/openvino

cd $thirdparty_root_dir
checkCmdWarn git clone -j $cpus -b 2022.3.1 https://gitlab.com/paperybox/openvino.git

cd $openvino_src_root
chmod +x scripts/submodule_update_with_gitee.sh
num=0
while true; do
    checkCmdWarn ./scripts/submodule_update_with_gitee.sh
    if [ $? -eq 0 ]; then
        break 1
    fi
    ((num++))
    if [ $num -gt 5 ]; then
        echo_error "retry num > 5, please check net set!"
        exit 1
    fi
    echo_warn "./scripts/submodule_update_with_gitee.sh failed $num, retry!"
done

chmod +x install_build_dependencies.sh
num=0
while true; do
    checkCmdWarn ./install_build_dependencies.sh
    if [ $? -eq 0 ]; then
        break 1
    fi
    ((num++))
    if [ $num -gt 5 ]; then
        echo_error "retry num > 5, please check net set!"
        exit 1
    fi
    echo_warn "./install_build_dependencies.sh failed $num, retry!"
done

checkCmdError pip install -r $openvino_src_root/src/bindings/python/wheel/requirements-dev.txt
checkCmdError pip install cython==0.29.22


mkdir -p build && cd build

checkCmdError cmake -DCMAKE_BUILD_TYPE=Release \
                    -DCMAKE_INSTALL_PREFIX=$openvino_install_root \
                    -DENABLE_PYTHON=OFF \
                    -DENABLE_WHEEL=OFF \
                    ..

checkCmdError make -j$cpus

# real    56m37.317s
# user    312m40.370s
# sys     14m25.537s
checkCmdError make install

echo "
export PYTHONPATH=$openvino_src_root/bin/intel64/Release/python:\$PYTHONPATH 
export LD_LIBRARY_PATH=$openvino_src_root/bin/intel64/Release:\$LD_LIBRARY_PATH
" >> ~/.bashrc
source ~/.bashrc

checkCmdError pip install openvino==2022.3.1

mkdir -p /usr/local/lib/pkgconfig
cp $openvino_src_root/build/share/openvino.pc /usr/local/lib/pkgconfig
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

pkg-config openvino --modversion
if [ $? -ne 0 ]; then
    echo_error "================================= MODULE OPENVINO-"$(pkg-config openvino --modversion)" INIT FAILED ================================="
else
    echo_info "================================= MODULE OPENVINO-"$(pkg-config openvino --modversion)" INIT SUCCESSFUL ================================="
fi