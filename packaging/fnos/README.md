# OpenList 飞牛 fnOS 安装包

基于 [OpenList v4.2.10](https://github.com/OpenListTeam/OpenList/releases/tag/v4.2.10) 的第三方适配。FPK 直接运行上游 OpenList 二进制，包含上游 Web 界面。上游程序和本目录的封装使用 [AGPL-3.0](../../LICENSE)。[Web 界面对应源码](https://github.com/OpenListTeam/OpenList-Frontend/tree/v4.2.10)。

## 安装和访问

1. 在飞牛应用中心选择「手动安装」，选择对应架构的 FPK。Intel 和 AMD 设备选 `amd64`，64 位 ARM 设备选 `arm64`。
2. 安装向导中设置 OpenList 管理员密码。登录用户名为 `admin`。
3. 从飞牛桌面打开 OpenList，或访问 `http://<NAS 地址>:5244/`。应用使用独立的 OpenList 账号。安装前确保 TCP `5244` 可用。
4. 需要挂载 NAS 本地文件时，在飞牛应用中心的 OpenList 应用设置中授权目录，再将该目录添加到 OpenList 的本机存储。服务以飞牛为应用创建的专用账号运行。

配置文件位于应用的 `etc/config.json`，数据库和日志位于应用的 `var` 目录，缓存位于应用的临时目录。配置和数据库与程序目录分开，升级时由飞牛应用中心管理数据目录。

## 构建

在 Linux 上准备 Bash、tar、curl、sha256sum 和 [fnpack 1.3.3](https://developer.fnnas.com/docs/cli/fnpack/)，从仓库根目录运行：

```bash
./packaging/fnos/build.sh amd64 dist/fnos
./packaging/fnos/build.sh arm64 dist/fnos
```

可通过 `FNPACK` 指定 fnpack 路径，通过 `OPENLIST_ASSET_DIR` 提供已下载的上游发布资产。脚本校验上游资产的 SHA-256，生成用于手动安装测试的未签名 FPK。
