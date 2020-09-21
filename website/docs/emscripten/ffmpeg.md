---
id: ffmpeg
title: Emscripten编译ffmpeg+libx264
sidebar_label: Emscripten编译ffmpeg+libx264
---

## 第一步：搭建Emscripten编译环境（建议使用linux环境）
### 首先安装依赖包
```
# Install Python
sudo apt-get install python3

# Install CMake (optional, only needed for tests and building Binaryen)
sudo apt-get install cmake

# Install Java (optional, only needed for Closure Compiler minification)
sudo apt-get install default-jre
```

### 然后获取emsdk
```
下载地址：
git clone https://github.com/emscripten-core/emsdk.git
```

### 配置emsdk
```
# 进入emsdk目录
cd emsdk

# 下载依赖工具.
./emsdk install latest

# 激活sdk（感觉就是生成一下环境变量）
./emsdk activate latest

# 激活环境变量，使当前用户可以通过终端使用
source ./emsdk_env.sh

# 如果需要打开终端自动加载环境变量
vim ~/.bashrc
在最后一行添加
source path_to_emsdk/emsdk_env.sh
```

### 验证一下
```
# 编辑test.c文件
vim test.c

# 输入
#include <stdio.h>

int main() {
  printf("hello, world!\n");
  return 0;
}

# 执行编译
emcc test.c -o test.html

# 生成三个文件
test.html --- 测试页面
test.js --- 调用js
test.wasm --- 二进制库

# 执行
## 方法一：使用npm的static-server
npm install -g static-server
static-server

然后通过web浏览器访问http://127.0.0.1:9080/test.html

## 方法二：
使用node直接执行
node test.js
```
### 方法一
![test1](assets/emscripten/test1.png)

### 方法二
![test2](assets/emscripten/test2.png)


## 第二步，编译libx264
### 下载源码
```
下载地址：
https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.bz2
```

### 编译
```
# 解压
tar xvjf x264-master.tar.bz2

# 进入目录
cd x264-master

# 配置Makefile
emconfigure ./configure --prefix=~/libs/  --enable-static --disable-asm \
--host=i686-gnu --disable-cli --extra-cflags="-s USE_PTHREADS=1"

# 编译
emake make

# 安装，会安装到--prefix指定的目录
emmake install

# 在--prefix目录下会有include和lib目录
include----- 头文件目录
    |---x264.h
    |---x264_config.h
lib---------库目录
    |---libx264.a 
    |---pkgconfig 

```

## 第三步，编译ffmpeg
### 下载源码
```
下载地址：
https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
```

### 编译
```
# 解压
tar xvjf ffmpeg-snapshot.tar.bz2

# 进入目录
cd ffmpeg-snapshot

# 配置Makefile
emconfigure ./configure --prefix=/home/gxk527/libs --enable-gpl \
--enable-libx264 --enable-cross-compile --target-os=none --arch=x86_64 \
--cpu=generic --disable-ffplay --disable-ffprobe --disable-asm --disable-doc \
--disable-devices --disable-pthreads --disable-w32threads --disable-network \
--disable-hwaccels --disable-parsers --disable-bsfs --disable-debug \
--disable-protocols  --disable-indevs --disable-outdevs --enable-protocol=file \
--cc="emcc" --cxx="em++" --ar="emar" --ranlib="emranlib" \
--extra-cflags="-I/home/gxk527/libs/include" \
--extra-cxxflags="-I/home/gxk527/libs/include" \
--extra-ldflags="-L/home/gxk527/libs/lib -s USE_PTHREADS=1 -s PTHREAD_POOL_SIZE=2"

# 编译
emake make
```

### 编译过程中遇到的问题
#### 问题一：ERROR: libx264 not found
该问题是由于ffmpeg无法找到libx264库，网上很多问答都只说添加--extra-cflags就可以了，但是实际操作的时候仍然会报错；
其实还需要增加--extra-cxxflags和--extra-ldflags，即：
--extra-cflags和--extra-cxxflags使用-I指定头文件目录
--extra-ldflags使用-L指定库文件目录

#### 问题二：wasm-ld: error: libavdevice/libavdevice.a: archive has no index; run ranlib to add one
该问题是由于没有指定ranlib工具的问题，需要在配置的时候添加--ranlib="emranlib"

#### 注意
configure的时候出问题一定要记得看ffbuild/config.log，不要只看终端返回内容，那个很模糊，config.log里面会写的很细。


