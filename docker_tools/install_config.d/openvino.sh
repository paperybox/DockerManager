#! /bin/bash

Pwd=$( readlink -f "$( dirname $0 )" )
source $Pwd/ysu.env

openvino_src_root=$thirdparty_root_dir/openvino
openvino_install_root=$install_root/openvino

cd $thirdparty_root_dir
checkCmdWarn git clone -b 2022.3.1 https://gitlab.com/paperybox/openvino.git

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
