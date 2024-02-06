#! /bin/bash
Pwd=$( readlink -f "$( dirname $0 )" )
source $Pwd/ysu.env


RootDir=$( readlink -f $( dirname $0 )/../ )
echo $RootDir
if [ $RootDir != "/workspace" ]; then
    echo "not in docker, ln -s $RootDir /workspace"
    sudo ln -s $RootDir /workspace
fi

Pwd=$( readlink -f "$( dirname $0 )" )
script_folder="${Pwd}/install_config.d"
script_files=$( realpath `ls $script_folder/*.sh` | tr '\n' ' ' )
echo "Init env script list: $script_files"
read -r -a script_files_list <<< "$script_files"
# 循环遍历并执行每个脚本
for script_file in "${script_files_list[@]}"; do
    echo_info "Executing script: $script_file"
    chmod a+x $script_file
    $script_file
done


