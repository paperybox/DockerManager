# YsuRmEnv
YSU-Eagle 统一视觉开发环境，基于Ubuntu20.04开发验证，仅用于学习交流。

## 使用
将`docker_tools`目录放在工作目录下并初始化环境。

### 初始化方法1：(推荐用于个人开发)
使用docker统一管理。

安装docker并设置不需要root权限启动。
```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
sudo usermod -aG docker ${USER}
su - ${USER}
id -nG
sudo service docker restart
```


拉起环境，并初始化安装一些必要的工具。
依次调用`docker_tools/install_config.d/`中所有的自定义*.sh脚本。

由于网络原因，有概率失败，可以docker_into.sh进入容器后，手动`sudo /workspace/docker_tools/install_config.sh`继续安装。
```bash
./docker_tools/docker_start.sh #拉起容器，提供一些可自定义的参数， 详见 -h
./docker_tools/docker_into.sh #进入拉起的容器
```

### 初始化方法2:（推荐用于实车部署）
```bash
sudo ./docker_tools/install_config.sh #直接初始化自定义环境,通过软链接保持路径与使用docker一致。
```

### Tips:
***无论何种初始化方式，下载 和 编译过程非常耗时 ，实测100M家庭宽带+8代i5笔记本 整个流程需要约2小时。服务器集群则多取决于网速，编译时间较短，共计耗时22m28.440s。在多机部署时，建议在足够强悍的机器上进行首次部署，后续机器将3rdparty_root_dir完整cp，可有效减少等待时间。***

### 开发环境
为了保证广泛兼容性，建议使用 CMake 工具链。
编译器建议使用CLion / Vscode  Remote-SSH可以非常方便的与Docker搭配使用。
调试工具建议使用gdb，perf等
可视化界面建议通过 rclpy 订阅相关 topic 进行可视化

## 维护
脚本调用关系：docker_start.sh -> docker_adduser.sh -> install_config.sh -> install_config.d/*.sh
如需新增环境配置，只需在install_config.d中新增一个安装脚本即可。

## 一些功能说明
#### docker_start.sh 
1) 默认挂载 上一级目录 到 /workspace。

2) 挂载/dev路径，可访问硬件。

3) 挂载核显，可在镜像内运行可视化界面，方便调试。

4) -p <Port num> | 默认使用本机网络，-p参数改为桥接模式，可使用ssh直接登录容器，可远程登录，或pycharm-profession，clion等更方便的调试。

5) -g | 可在容器内使用本机的nvidia gpu，需要 [安装nvidia-docker2](https://zhuanlan.zhihu.com/p/361934132)。

6) -n <Name> | 可自定义容器名,而实现多开容器。

7) -i <Image> | 可自定义使用镜像。(漫长的安装编译过程，只需一次即可)

#### docker_into.sh
1) -n <Name> | 进入指定名称的容器。

#### docker_adduser.sh
1) 初始化容器内基本配置，容器内当前默认用户密码/root密码：ysu

#### install_config.sh && install_config.d/
1) 自定义环境，便利调用install_config.d中的sh脚本。




