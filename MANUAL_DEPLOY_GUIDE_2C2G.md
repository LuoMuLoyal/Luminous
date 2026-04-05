# Luminous 2C2G 云服务器手动部署与内存测试指南

这份文档专为配置较小（2核2G）的云服务器编写。为了直观且安全地控制宿主机的内存，我们将采用 **“自定义 Docker Network + 单条 docker run 命令限制资源”** 的渐进部署方案。你的所有服务依然跑在 Docker 环境内保障隔离，但会附加上“紧箍咒”。

---

luminousmysql

## 步骤一：登录服务器并配置 Swap (极其重要！防止 2G 内存爆炸)

使用终端登录你的云服务器：
```bash
ssh root@<你的服务器IP地址>
```

**配置 2GB 的虚拟内存 (Swap)：**
2G物理内存难以同时承受 MySQL 8 + MongoDB + Node，这一步是防止机器宕机的硬要求。
```bash
# 1. 创建一个 2GB 的交换文件
sudo fallocate -l 2G /swapfile

# 2. 设置正确的权限
sudo chmod 600 /swapfile

# 3. 格式化并启用 Swap
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 步骤二：创建独立 Docker 网络

有了独立的 Docker 网络，所有的容器就不用写死 IP，可以直接用如 `mysql` 这样的名字互相访问（类似于 docker-compose 的表现）。

```bash
docker network create luminous-net
```

---

## 步骤三：启动带内存限制的数据库

我们在跑下面命令时，统一加上 `--network luminous-net`。

### 1. 启动 Redis (消耗小)
```bash
docker run -d --name redis --network luminous-net -p 6379:6379 \
  --restart always \
  redis:7-alpine
```

### 2. 启动 MongoDB (限制引擎缓存为 250MB)
设置 `--wiredTigerCacheSizeGB 0.25` 限制其贪婪吞噬内存的行为。
```bash
docker run -d --name mongodb --network luminous-net -p 27017:27017 \
  --restart always \
  mongo:7 --wiredTigerCacheSizeGB 0.25
```

### 3. 启动 MySQL 8.0 (硬核压制内存参数)
配置 `--innodb-buffer-pool-size=128M` 控制 MySQL 启动即占几百兆的缺陷。
*(注意：务必将 123456 换成你的服务器真实强密码)*

```bash
docker run -d --name mysql --network luminous-net -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD="123456" \
  --restart always \
  mysql:8.0 \
  --default-authentication-plugin=mysql_native_password \
  --innodb-buffer-pool-size=128M \
  --max-connections=50
```

可以看到上面这些容器的名字直接叫 `redis`, `mongodb`, `mysql`。

---

## 步骤四：上传代码，编写后端配置并构建

将项目代码丢到 `/opt/luminous` 下：

```bash
cd /opt/luminous/backend
```

**准备配置文件：**
```bash
nano .env.production
```
内容完全和你在 `docker-compose` 里的习惯一样，把 Host 填为容器名即可（它们现在处于同一网络内）：
```env
NODE_ENV=production
HOST=0.0.0.0
PORT=8787
CORS_ORIGIN=*

MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=123456
MYSQL_DATABASE=medicine_db
MYSQL_TABLE=StandardCode

MONGODB_URI=mongodb://mongodb:27017/luminous
REDIS_URL=redis://redis:6379

AUTH_CODE_DELIVERY_MODE=email
# 其余密钥跟你的线上需求走...
```

**将 Node 后端打包成 Docker 镜像：**
```bash
docker build -t luminous-backend:latest .
```

---

## 步骤五：启动并在 Docker 中运行 Node 后端

通过将后端也连入 `luminous-net` 网络中，并加载我们准备的配置文件。

```bash
docker run -d --name backend --network luminous-net \
  -p 8787:8787 \
  --env-file .env.production \
  --restart always \
  luminous-backend:latest
```

### 检查是否成功：
查看此时后端的实时日志，确认它通过网络找到了 MySQL 和 Mongo 等容器：
```bash
docker logs -f backend
```

---

## 步骤六：配置 Nginx 反向代理与 HTTPS (可选但推荐)

在此步骤中我们用 Nginx 代理 Node 后端，以便对外暴露 80 / 443（并配置 SSL 证书）。

### 1. 准备挂载目录与配置文件
```bash
mkdir -p /opt/luminous/nginx/conf.d
mkdir -p /opt/luminous/nginx/certs
nano /opt/luminous/nginx/conf.d/default.conf
```

填入以下代理配置：
```nginx
server {
    listen 80;
    server_name your-domain.com; # 换成你的域名

    location / {
        # 容器间可以通过域名 backend 通信
        proxy_pass http://backend:8787;
        
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. 启动 Nginx 容器（同样加入网络）
确保 Nginx 和 Backend 同属 `luminous-net`：
```bash
docker run -d --name nginx --network luminous-net \
  -p 80:80 -p 443:443 \
  -v /opt/luminous/nginx/conf.d:/etc/nginx/conf.d \
  -v /opt/luminous/nginx/certs:/etc/nginx/certs \
  --restart always \
  nginx:1.25-alpine
```

---

## 总结：看看你的服务器还好吗？

至此，你的服务器已经使用全套纯正的 Docker（没有额外挂靠 PM2 裸机软件）成功跑通了整个后端+数据库+Nginx工作流。

你可以使用 `docker stats` 看下这 5 个容器当前的精确占用的 CPU 和可用内存！只要没溢出、各项安稳，这就是完美的长期部署状态了。
