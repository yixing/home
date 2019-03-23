# QUIC demo安装笔记

文档：
* https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions.md#Setting-up-the-build
* https://www.chromium.org/quic/playing-with-quic

首先获取所需要的工具

```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

添加到$PATH路径

```bash
export PATH="$PATH:${HOME}/depot_tools"
```

获取源码

```bash
mkdir ~/chromium && cd ~/chromium
fetch --nohooks --no-history chromium
```

编译依赖

```bash
cd src
sh  build/install-build-deps.sh
gclient runhooks
```

准备产出环境

```bash
gn gen out/Default
gn gen out/Debug
```

编译

```bash
ninja -C out/Debug quic_server quic_client
```

设置测试页面

```bash
mkdir /tmp/quic-data
cd /tmp/quic-data
wget -p --save-headers https://www.example.org
```
给自己签发一个证书

```bash
cd chromium/src/net/tools/quic/certs; ./generate-certs.sh
```

![img](https://yixing.github.io/img/quic-gen-cert.png)

添加CA证书到系统信任列表

```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "TestRoot" -i 2048-sha256-root.pem
certutil -d sql:$HOME/.pki/nssdb -L
```

![img](https://yixing.github.io/img/quic-add-cert.png)

启动server

```bash
out/Debug$ ./quic_server --certificate_file=/home/yixing/dev/chromium/www/cert/leaf_cert.pem --key_file=/home/yixing/dev/chromium/www/cert/leaf_cert.pkcs8 --quic_response_cache_dir=/home/yixing/dev/chromium/www/www.example.org
```

启动client

```bash
./quic_client --host=127.0.0.1 --port=6121 https://www.example.org/
```

响应内容：

![img](https://yixing.github.io/img/quic-demo-response.png)

