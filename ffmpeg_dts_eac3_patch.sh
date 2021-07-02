#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
# VAR 	******************************************************************
vAction=$1
# Function List	*******************************************************************************
function install() {
    #备份 VideoStation's ffmpeg
    mv -n /var/packages/VideoStation/target/bin/ffmpeg /var/packages/VideoStation/target/bin/ffmpeg.orig
    # 生成 ffmpeg 脚本
    #下载ffmpeg脚本  
    #wget -O - https://raw.githubusercontent.com/songwqs/Synology-DSM/main/ffmpeg > /var/packages/VideoStation/target/bin/ffmpeg
    wget -O - https://raw.githubusercontent.com/songwqs/Synology-DSM/b2070dfeabfb901e743f48df797d2ee7cee4f50c/ffmpeg > /var/packages/VideoStation/target/bin/ffmpeg
    # 去Advanced Media Extensions冲突补丁
    if [ -f "/var/packages/CodecPack/target/bin/ffmpeg33" ]; then
        mv -n /var/packages/CodecPack/target/bin/ffmpeg33 /var/packages/CodecPack/target/bin/ffmpeg33.orig
        cp -n /var/packages/VideoStation/target/bin/ffmpeg /var/packages/CodecPack/target/bin/ffmpeg33
    fi
    if [ -f "/var/packages/CodecPack/target/bin/ffmpeg41" ]; then
        mv -n /var/packages/CodecPack/target/bin/ffmpeg41 /var/packages/CodecPack/target/bin/ffmpeg41.orig
        cp -n /var/packages/VideoStation/target/bin/ffmpeg /var/packages/CodecPack/target/bin/ffmpeg41
    fi
    #设置脚本相应权限
    chown root:VideoStation /var/packages/VideoStation/target/bin/ffmpeg
    chmod 750 /var/packages/VideoStation/target/bin/ffmpeg
    chmod u+s /var/packages/VideoStation/target/bin/ffmpeg
    # 备份VideoStation's libsynovte.so
    cp -n /var/packages/VideoStation/target/lib/libsynovte.so /var/packages/VideoStation/target/lib/libsynovte.so.orig
    chown VideoStation:VideoStation /var/packages/VideoStation/target/lib/libsynovte.so.orig
    # 为libsynovte.so 添加 DTS, EAC3 and TrueHD支持
    sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/VideoStation/target/lib/libsynovte.so
    echo '请重新启动Video Station，并测试FFMPEG是否正常工作'
}
function uninstall() {
    #恢复之前备份的 VideoStation's ffmpeg, libsynovte.so文件
    mv -f /var/packages/VideoStation/target/bin/ffmpeg.orig /var/packages/VideoStation/target/bin/ffmpeg
    mv -f /var/packages/VideoStation/target/lib/libsynovte.so.orig /var/packages/VideoStation/target/lib/libsynovte.so
    if [ -f "/var/packages/CodecPack/target/bin/ffmpeg33.orig" ]; then
        mv -f /var/packages/CodecPack/target/bin/ffmpeg33.orig /var/packages/CodecPack/target/bin/ffmpeg33
    fi
    if [ -f "/var/packages/CodecPack/target/bin/ffmpeg41.orig" ]; then
        mv -f /var/packages/CodecPack/target/bin/ffmpeg41.orig /var/packages/CodecPack/target/bin/ffmpeg41
    fi
}
# SHELL 	******************************************************************
if [ "$vAction" == 'install' ]; then
    if [ ! -f "/var/packages/VideoStation/target/bin/ffmpeg.orig" ]; then
        install
        echo '成功安装 DTS 支持补丁'
    else
        echo '你已经添加过DTS支持'
        echo '=========================================================================='
        exit 1
    fi
elif [ "$vAction" == 'uninstall' ]; then
    if [ ! -f "/var/packages/VideoStation/target/bin/ffmpeg.orig" ]; then
        echo '你还没安装过 FFMPEG DTS支持补丁'
        echo '=========================================================================='
        exit 1
    else
        uninstall
        echo '成功卸载 DTS 支持补丁'
    fi
else
    echo '错误的命令'
    echo '=========================================================================='
    exit 1
fi
