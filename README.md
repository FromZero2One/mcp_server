# MCP Server Demo

这是一个MCP（Model Context Protocol）服务器示例，提供多种工具和资源供AI模型调用。

## 项目简介

本项目是一个基于FastMCP框架构建的MCP服务器，提供了基础的数学计算工具、个性化问候资源和用户问候提示等功能。

## 功能特性

- **加法工具**：执行两个整数的加法运算
- **乘法工具**：执行两个整数的乘法运算
- **个性化问候资源**：根据姓名生成个性化问候语
- **用户问候提示**：根据指定风格生成问候提示

## 依赖要求

- Python >= 3.12
- mcp[cli] >= 1.12.2

## 安装步骤

1. 确保已安装Python 3.12或更高版本
2. 安装依赖：
   ```bash
   pip install mcp[cli]>=1.12.2
   ```

## 启动服务

运行以下命令启动MCP服务器：

```bash
uv run server fastmcp_quickstart stdio
```

或者直接运行Python文件：

```bash
python mcp_server.py
```

## 魔搭社区部署说明

### 部署准备

1. 确保项目根目录包含以下文件：
   - [mcp_server.py](file:///E%3A/code/mcp_server/mcp_server.py) - 主服务文件
   - [pyproject.toml](file:///E%3A/code/mcp_server/pyproject.toml) - 项目配置文件
   - [README.md](file:///E%3A/code/mcp_server/README.md) - 项目说明文件

### 部署步骤

1. 将项目代码上传至魔搭社区环境
2. 在魔搭环境中安装依赖：
   ```bash
   pip install -r requirements.txt
   # 或者直接安装pyproject.toml中的依赖
   pip install .
   ```
3. 启动服务：
   ```bash
   uv run server fastmcp_quickstart stdio
   ```

### 服务配置

- 服务名称：Demo
- 通信方式：stdio
- 支持的工具：
  - `add`: 两数相加
  - `multi`: 两数相乘
  - `get_greeting`: 获取个性化问候
  - `greet_user`: 生成用户问候提示

### 使用示例

- 加法工具：输入两个整数，返回它们的和
- 乘法工具：输入两个整数，返回它们的积
- 问候资源：输入姓名，返回个性化问候语（格式：greeting://{name}）
- 问候提示：输入姓名和风格（友好/正式/随意），返回相应风格的问候

## 注意事项

- 确保在魔搭社区环境中正确配置了Python运行环境
- 检查依赖包是否正确安装
- 服务启动后会监听stdio进行MCP协议通信

## 许可证

请在此处添加许可证信息（如适用）