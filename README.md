# caddy-custom-build

为 M+H 部署构建精简版 Caddy，仅包含官方模块、`github.com/mholt/caddy-l4` 和 `github.com/caddyserver/jsonc-adapter`。

仓库不保存生产环境的 `caddy.jsonc`、域名、证书或私钥。

## 流程

1. 每天检查 Caddy 与两个 Go 模块的上游版本。
2. 有更新时自动创建 `update-dependencies` Pull Request。
3. PR 自动触发构建、模块检查、漏洞扫描和 SHA-256 生成。
4. 人工审核并合并。
5. 维护者创建 `v*` 标签后，生成 GitHub Release。

`caddy-l4` 上游仍处于开发状态。不要把未经测试的新版本直接部署到生产 VPS。

## 首次使用

1. 将仓库内容推送到自己的 GitHub 仓库。
2. 在 Settings → Actions → General 中允许 Actions 运行。
3. 检查 `versions.env.example`，复制为 `versions.env`，填入已审核的固定版本。
4. 提交 `versions.env` 后运行 Actions。
5. 建议将工作流 Actions 固定到完整 commit SHA；Dependabot 会定期提出 Actions 更新。

## 本地构建

需要 Go 稳定版和网络访问 Go module proxy：

```bash
cp versions.env.example versions.env
# 编辑 versions.env，填入已审核的固定版本
./build.sh
```

## 安全边界

- 工作流采用最小化 `GITHUB_TOKEN` 权限。
- 依赖更新只创建 PR，不自动发布或部署。
- Release 由 `v*` 标签触发。
- 二进制附带 SHA-256 和 Go build metadata。
- `govulncheck` 用于发现已知漏洞，不代表程序绝对安全。
- 不在仓库中存放生产配置、域名、证书或私钥。
