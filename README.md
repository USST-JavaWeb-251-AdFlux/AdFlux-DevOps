# AdFlux DevOps

AdFlux 项目的自动化运维与部署工具集。本项目旨在通过自动化脚本简化 AdFlux 系统的部署流程，涵盖前端、后端及 Tracker 模块。

## 1. 项目架构

AdFlux 系统由以下三个核心模块组成：

| 模块         | 技术栈        | 构建工具 | 仓库地址                                                                      |
| :----------- | :------------ | :------- | :---------------------------------------------------------------------------- |
| **Frontend** | Vue 3         | Vite     | [AdFlux-Frontend](https://github.com/USST-JavaWeb-251-AdFlux/AdFlux-Frontend) |
| **Backend**  | Spring Boot 2 | Maven    | [AdFlux-Backend](https://github.com/USST-JavaWeb-251-AdFlux/AdFlux-Backend)   |
| **Tracker**  | Vanilla JS    | Vite     | [AdFlux-Tracker](https://github.com/USST-JavaWeb-251-AdFlux/AdFlux-Tracker)   |

### 1.1 Web 服务器配置

系统采用 **Nginx** 作为统一入口，实现全站 HTTPS 访问。根据请求路径分发至不同模块：

-   `/`：前端页面 (Frontend)
-   `/api/`：后端接口 (Backend)
-   `/ads/`：追踪服务 (Tracker)

后端接口 (`/api/`) 和追踪服务 (`/ads/`) 的路径需分别在 **Frontend** 和 **Tracker** 仓库的 `.env` 文件中进行配置。

路径配置支持相对路径（如 `/api/`）及绝对路径（如 `https://adflux.bobliu.tech/api/`）。

生产环境下，由于 Nginx 已处理路由转发，推荐使用相对路径；开发环境下，若使用绝对路径，Vite 会通过内置的 proxy 代理请求，从而有效避免跨域问题。

具体的 Nginx 配置示例可参考本仓库中的 [nginx.conf](nginx.conf)。

## 2. 部署流程

### 2.1. 持续集成 (CI)

各模块仓库均配置了 GitHub Actions 工作流。当代码合并至主分支 (`main`/`master`) 时，会自动触发构建流程：

-   **前端/Tracker**：构建产物打包为 `dist.zip`。
-   **后端**：构建产物打包为 `app.jar`。
-   构建产物将自动上传至对应仓库的 **GitHub Release**。

### 2.2. 自动化部署 (CD)

本仓库提供的 `.sh` 脚本用于在服务器上执行自动化部署：

-   自动从 GitHub Release 获取最新的构建产物。
-   自动完成解压、目录清理及权限设置。
-   **后端**：自动管理 `screen` 会话，实现平滑重启。

## 3. 环境要求

在运行部署脚本前，请确保服务器已安装以下软件：

-   **基础工具**：`curl`, `unzip`, `jq`, `screen`
-   **运行时**：[Microsoft OpenJDK 17](https://learn.microsoft.com/en-us/java/openjdk/install)
-   **Web 服务器**：Nginx

## 4. 使用指南

### 4.1 脚本说明

-   [frontend.sh](frontend.sh)：部署前端静态资源。
-   [backend.sh](backend.sh)：部署后端 Jar 包并启动服务。
-   [tracker.sh](tracker.sh)：部署 Tracker 静态资源。
-   [utils.sh](utils.sh)：通用工具函数库。

### 4.2 部署步骤

1. **克隆本仓库**：
    ```bash
    git clone https://github.com/USST-JavaWeb-251-AdFlux/AdFlux-DevOps.git
    cd AdFlux-DevOps
    ```
2. **配置参数**：
   编辑各脚本顶部的 `Configuration` 区域，根据实际环境修改 `TARGET_DIR`、`LOG_FILE` 等路径。
3. **后端配置**：
   在后端目标目录下放置 `application.yml` 或 `application-prod.yml` 配置文件。配置项请参照 [后端仓库](https://github.com/USST-JavaWeb-251-AdFlux/AdFlux-Backend) 的 README。
4. **执行部署**：
    ```bash
    chmod +x *.sh
    ./frontend.sh
    ./backend.sh
    ./tracker.sh
    ```

## 5. 注意事项

-   **权限要求**：脚本会自动尝试获取 `sudo` 权限，请确保当前用户在 sudoers 列表中，或使用 root 进行操作。
-   **日志路径**：后端的日志默认位于 `/var/log/AdFlux/app.log`，每次重启后端服务后会清空重新生成。
-   **配置验证**：脚本目前较为精简，未对配置项进行严格验证。在执行前请务必确认路径及参数正确，以免造成**不可逆的严重后果**。
-   **网络环境**：脚本使用 `ghfast.top` 作为 GitHub 下载加速镜像，如有需要可修改 [utils.sh](utils.sh) 中的下载逻辑。
