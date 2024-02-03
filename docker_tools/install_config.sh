#! /bin/bash

RootDir=$( readlink -f $( dirname $0 )/../ )
echo $RootDir
if [ $RootDir != "/workspace" ]; then
    echo "not in docker, ln -s $RootDir /workspace"
    sudo ln -s $RootDir /workspace
fi

Pwd=$( readlink -f "$( dirname $0 )" )
script_folder="${Pwd}/install_config.d"
script_files="$( ls $script_folder/*.sh )"

echo "init env script list: $script_files"
# 循环遍历并执行每个脚本
for script_file in "${script_files[@]}"; do
    echo "Executing script: $script_file"
    chmod a+x $script_file
    $script_file
done


