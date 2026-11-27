# OpenList 飞牛 fnOS 安装包

飞牛 fnOS 1.2.0 及以上的第三方适配。FPK 使用 OpenList 正式版的上游二进制和内置 Web 界面，随上游正式版更新。程序和打包脚本使用 [AGPL-3.0](../../LICENSE)，图标适用 [CC BY-NC-SA 4.0](logo/NOTICE.md)。[上游程序版本](https://github.com/OpenListTeam/OpenList/releases) · [Web 界面源码](https://github.com/OpenListTeam/OpenList-Frontend)

## 安装和访问

1. 在飞牛应用中心选择「手动安装」，选择对应架构的 FPK。Intel 和 AMD 设备选 `amd64`，64 位 ARM 设备选 `arm64`。
2. 安装向导中设置 OpenList 管理员密码。登录用户名为 `admin`。
3. 从飞牛桌面打开 OpenList，或访问 `http://<NAS 地址>:5244/`。应用使用独立的 OpenList 账号。安装前确保 TCP `5244` 可用。
4. 需要挂载 NAS 本地文件时，在飞牛应用中心的 OpenList 应用设置中授权目录，再将该目录添加到 OpenList 的本机存储。服务以飞牛为应用创建的专用账号运行。

配置文件位于应用的 `etc/config.json`，数据库和日志位于应用的 `var` 目录，缓存位于应用的临时目录。配置和数据库与程序目录分开，升级时由飞牛应用中心管理数据目录。

## 每日同步

[GitHub Actions](https://github.com/frilxy/OpenList-fnos/actions/workflows/fnos-sync.yml) 每天北京时间 03:23 检查上游。源码快进同步至 [`upstream-main`](https://github.com/frilxy/OpenList-fnos/tree/upstream-main)，飞牛封装由本仓库的 `main` 分支维护。检测到新正式版时，工作流会校验上游发布资产的 SHA-256，生成两种架构的 FPK，并把它们连同校验清单上传到该次运行的 Artifacts。预发布版跳过。Artifact 保留 90 天，到期后下一轮检查会重建当前版。也可以在工作流页面选择 **Run workflow** 立即同步并重新打包。

GitHub 内置令牌对新增或修改上游工作流文件的提交可能拒绝快进。遇到这种情况，源码同步任务会报错，正式版打包任务仍独立运行。

## 构建

在 Linux 上准备 Bash、tar、curl、jq、sha256sum 和 [fnpack 1.3.3](https://developer.fnnas.com/docs/cli/fnpack/)。从仓库根目录运行：

```bash
./packaging/fnos/build.sh amd64 dist/fnos
./packaging/fnos/build.sh arm64 dist/fnos
```

脚本默认查询上游最新正式版。可将同一份 GitHub Release API 响应 JSON 作为第三个参数传给两次构建，以锁定版本。可通过 `FNPACK` 指定 fnpack 路径，通过 `OPENLIST_ASSET_DIR` 提供指定版本已下载的上游资产。产物为用于手动安装测试的未签名 FPK。
