# CI/CD 操作文档

## 项目概述

Python MCP Server 项目，使用 GitHub Actions 实现自动化 CI/CD 流水线，Docker 镜像推送至 GitHub Container Registry (ghcr.io)，通过 Self-hosted Runner 自动部署到本地 Windows 机器。

---

## 一、架构图

```
git push (master)
      │
      ▼
┌─────────────────────────────────────────┐
│          GitHub Actions (远程)           │
│                                         │
│  lint (ruff) → test (pytest) → docker   │
│  ─────────────────────────────────────  │
│  1. ruff check .   代码风格检查          │
│  2. pip install -e . + pytest 测试       │
│  3. docker build + push ghcr.io         │
└─────────────────────────────────────────┘
                                   
           你点 "Run workflow" 按钮
                   │
                   ▼
┌──────────────────────────────────────────┐
│  Manual Deploy (手动触发, self-hosted)   │
│                                          │
│  docker pull ghcr.io/.../latest         │
│  → docker rm -f → docker run           │
│  → health check → 清理旧镜像            │
└──────────────────────────────────────────┘
                   │
                   ▼
           http://localhost:8000
           → MCP Server (SSE mode)
```

---

## 二、项目文件结构

```
E:\Project\mcp_server/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # CI 流水线（自动触发）
│   │   └── deploy.yml          # 手动部署（workflow_dispatch）
├── .dockerignore               # Docker 构建忽略规则
├── .gitignore                  # Git 忽略规则
├── Dockerfile                  # Docker 镜像构建文件
├── pyproject.toml              # Python 项目配置
├── uv.lock                     # 依赖锁文件
├── mcp_server.py               # MCP 服务入口
└── src/
    └── ...                     # 应用代码
```

---

## 三、流水线详解

### CI Pipeline (ci.yml)

| Job | 触发条件 | 运行环境 | 作用 |
|-----|---------|---------|------|
| **lint** | push/PR 自动 | ubuntu-latest | Ruff 代码风格检查 |
| **test** | lint 通过 | ubuntu-latest | pytest 单元测试（无测试则跳过） |
| **docker** | master 分支, test通过 | ubuntu-latest | 构建 Docker 镜像，推送到 ghcr.io |

### Manual Deploy (deploy.yml)

| Job | 触发条件 | 运行环境 | 作用 |
|-----|---------|---------|------|
| **deploy** | 手动点击 Run workflow | self-hosted (Windows) | 拉取镜像 → 重启容器 → 健康检查 |

---

## 四、环境要求

### 本地开发环境

| 工具 | 用途 |
|-----|------|
| Python 3.12+ | 本地运行开发 |
| uv | 依赖管理 |
| Docker Desktop | 本地运行容器 |

### 生产环境 (Self-hosted Runner)

| 工具 | 用途 |
|-----|------|
| Windows | Runner 宿主机 |
| Docker Desktop | 运行应用容器 |
| GitHub Actions Runner | 接收 CI 任务 |

---

## 五、操作指南

### 日常工作流程

```bash
# 1. 修改代码
vi mcp_server.py

# 2. 本地测试
uv run pytest

# 3. 提交并推送
git add -A
git commit -m "feat: 修改服务逻辑"
git push
```

**推送后自动完成：** lint → test → docker（镜像推送到 ghcr.io）

**手动部署：** 去 GitHub Actions → **Manual Deploy** → **Run workflow**

### 验证部署结果

```bash
curl http://localhost:8000/
```

如果 MCP SSE 端点返回 200 或 404，说明服务正常运行。

### 容器管理

```powershell
# 查看运行状态
docker ps | findstr mcp-server

# 查看日志
docker logs mcp-server

# 紧急重启
docker restart mcp-server
```

---

## 六、Self-hosted Runner 管理

### 配置 Runner

```powershell
# 在项目根目录
mkdir runner && cd runner

# 从 GitHub 获取 token 后配置（必须用 Administrator 账号）
.\config.cmd --url https://github.com/{owner}/{repo} --token {TOKEN} --runasservice --windowslogonaccount Administrator

# 验证服务运行
Get-Service "actions.runner.*"
```

> ⚠️ **必须使用 Administrator 账号**，否则 Docker Desktop 权限不足。

---

## 七、Docker 镜像管理

镜像存储在 GitHub Container Registry：

```
ghcr.io/{owner}/mcp_server:latest
```

```powershell
# 手动拉取
docker pull ghcr.io/{owner}/mcp_server:latest

# 查看构建时间
docker inspect ghcr.io/{owner}/mcp_server:latest --format "{{.Created}}"
```

---

## 八、常见问题

| 问题 | 原因 | 解决 |
|-----|------|------|
| Docker 权限不足 | Runner 不是 Administrator | 重新配置 Runner |
| 端口被占用 | 旧容器未释放 | 流水线已自动处理 |
| ghcr.io 标签错误 | 大写字母 | 自动小写化处理 |
| MCP 健康检查失败 | SSE 模式下 HTTP 响应不同 | 检查端口监听状态 |
