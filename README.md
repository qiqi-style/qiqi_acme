# qiqi-acme (基于 acme.sh 的中文一键脚本)

### 本项目是基于官方著名的开源项目 [acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh) 进行的中文汉化与自动化交互改造版。

主要为了方便习惯使用中文界面的开发者和 VPS 用户，提供全中文、交互式的 SSL 证书申请体验。

-------------------------------------

### 🚀 一键安装脚本

您可以选择以下任意一种命令直接运行脚本：

**使用 curl 一键运行:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/qiqi-style/qiqi_acme/main/qiqi_acme.sh)
```

**使用 wget 一键运行:**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/qiqi-style/qiqi_acme/main/qiqi_acme.sh)
```

-------------------------------------

### 🛠 后期如何管理

脚本安装后会持久保留在 `/root/qiqi_acme.sh`。下次需要管理证书（如查看续期时间、手动续期或卸载 acme.sh 程序）时，只需在 SSH 终端输入：

```bash
bash /root/qiqi_acme.sh
```

---------------------------------------

### 🌟 功能与特点

1. **多网络环境支持**：支持纯 IPV4、纯 IPV6、双栈 VPS 运行。
2. **多模式智能申请**：支持 80 端口模式与 DNS API 模式，无缝支持单域名与泛域名证书的申请。
3. **国内 DNS 服务商友好**：深度集成了针对 Cloudflare、腾讯云 DNSPod、阿里云 Aliyun 托管解析平台的 DNS API 一键式申请。
4. **智能管理**：脚本首页用表格显示证书记录、创建时间、到期时间和剩余天数，卸载 acme.sh 程序时会保留 `/root/qiqi_acme.sh` 管理脚本和已有证书文件。
5. **灵活续期**：支持按编号手动续期单个证书，或输入 `99` 一键续期全部证书。
6. **证书独立存储**：申请的证书文件将自动保存在 `/root/qiqissl/你的域名/` 文件夹中，完美支持多域名管理。
7. **自动防呆**：智能释放被占用的 80 端口，智能校对域名解析与当前机器 IP 是否匹配。

---------------------------------------

### 📂 证书存储路径

申请成功后，证书会存放在以下位置：
- **公钥文件 (CRT):** `/root/qiqissl/你的域名/cert.crt`
- **密钥文件 (KEY):** `/root/qiqissl/你的域名/private.key`
- **泛域名证书：** 输入 `*.example.com` 时，会把 `example.com` 和 `*.example.com` 放进同一张证书、同一个密钥，并保存到 `/root/qiqissl/*.example.com/`。

---------------------------------------

### ⚠️ 注意事项

* **Root 权限**：请确保以 `root` 用户身份运行脚本。
* **80 端口冲突**：使用“独立 80 端口模式”时，脚本会暂时强制停止并释放 80 端口。如果您正在运行 Nginx 等占用 80 端口的服务，请知晓或优先选择 **DNS API 模式**。
* **解析检查**：独立 80 端口模式需要域名解析到当前 VPS 的公网 IP；DNS API 模式使用 DNS 验证，不强制要求域名 IP 指向当前 VPS。如果是泛域名申请，请务必先在域名后台添加一条 `*` 的解析记录。
* **泛域名覆盖范围**：`*.example.com` 只覆盖 `a.example.com` 这一层，不覆盖 `example.com` 本身；脚本会在 DNS API 模式下自动把裸域一起放入同一张证书和同一个密钥。
* **CDN 限制**：如果使用 Cloudflare，请在申请期间暂时关闭“小黄云”（即设为 DNS Only 模式），否则验证可能失败。
* **自动续期**：证书申请成功后，脚本会写入 root 用户 crontab：`0 0 * * * bash /root/.acme.sh/acme.sh --cron`。它会每天按服务器本地时间 00:00 检查一次；首页只显示证书到期时间和剩余天数。
* **频率限制**：如果 acme.sh 输出 `rateLimited`、`429`、`too many certificates` 或 `retry after`，表示 Let's Encrypt 限制了同一组域名在短时间内重复签发。请等待输出里的 `retry after` 时间后再申请，不要连续强制重试。
* **失败保护**：申请失败时不会把失败生成的空证书写入 `/root/qiqissl/`，也不会覆盖已有可用证书。脚本会先写入临时目录，确认新证书和密钥都有效后才替换正式文件。

### 🔁 自动续期测试

查看自动续期任务是否已写入：

```bash
crontab -l
```

不想等到 00:00，可以手动执行一次普通检查：

```bash
bash /root/.acme.sh/acme.sh --cron --debug 2
```

如需强制测试续期流程，可在脚本里进入“手动续期证书”，选择指定证书编号或输入 `99`。强制续期不要频繁重复执行，避免触发 Let's Encrypt 频率限制。

---------------------------------------

### 📜 声明

核心证书申请功能源自原版官方项目 [acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)。本脚本在原有基础上，对交互逻辑进行了封装修改和中文翻译。
