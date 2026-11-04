#!/usr/bin/env bash
# 在 Linux 桌面上安装 Luminous release 包（Flutter Linux bundle，非 .deb）。
#
# 用法：
#   bash scripts/desktop/install_linux.sh <luminous-linux-x64.tar.gz>
#   bash scripts/desktop/install_linux.sh <bundle.tar.gz> --impeller
#
# 产物来源：`.github/workflows/deploy-linux.yml`（手动 dispatch）上传的
# `luminous-linux-x64` artifact 解压后得到的 `luminous-linux-x64.tar.gz`。
#
# 前置：
#   - x86-64 的 Linux 桌面（Ubuntu 24.04 / 26.04 实测过），图形会话里运行；
#   - 首次安装需要 sudo 装 GTK3 运行库（只装运行库，不改系统其它部分）。
#
# 默认走 Skia 渲染（`LUMINOUS_SOFTWARE_RENDER=1`）。Impeller 自 Flutter 3.47 起是
# Linux 默认后端，但在没有可用 GPU 驱动的机器（VMware/VirtualBox 客户机、只有
# Mesa llvmpipe 的环境）上会初始化完引擎却永远不出首帧——进程活着、没窗口。
# 传 `--impeller` 可保持 Impeller，见 README 的
# "Process environment variables (desktop)"。变量是**进程级**的，任何构建都认，
# 不需要重新编译。
#
# 安装布局：
#   ~/.local/opt/luminous/bundle   程序本体（解压出来的 bundle/）
#   ~/.local/bin/luminous          命令行包装器（默认注入渲染后端选择）
#   ~/.local/share/applications    桌面启动器
#   ~/.local/share/luminous        数据目录：kv/preferences 与 luminous.db
#
# 数据目录说明：2026-11-03 之前的构建把偏好库与本地库放在 `$HOME/Documents`，
# 那是 XDG 的用户共享目录而不是应用私有目录，两份安装会争同一把 Hive 锁、
# 第二次启动直接以 `errno 11` 退出。本脚本安装前会把那里的历史数据搬到
# `~/.local/share/luminous`，让旧构建与新构建读到同一份偏好。
set -euo pipefail

ARCHIVE=""
IMPELLER=0

usage() {
  sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --impeller) IMPELLER=1; shift ;;
    -h|--help) usage ;;
    -*) echo "未知参数: $1" >&2; usage ;;
    *) ARCHIVE="$1"; shift ;;
  esac
done

if [[ -z "$ARCHIVE" || ! -f "$ARCHIVE" ]]; then
  echo "用法: bash $0 /path/to/luminous-linux-x64.tar.gz [--impeller]" >&2
  exit 1
fi

APP_DIR="${HOME}/.local/opt/luminous"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
STATE_DIR="${HOME}/.local/share/luminous"
DESKTOP_ID="com.devluo.luminous"

if [[ "$IMPELLER" -eq 1 ]]; then
  echo "==> 渲染后端：Impeller（默认后端，不注入 LUMINOUS_SOFTWARE_RENDER）"
  RENDER_ENV="# --impeller：使用 Flutter 默认后端"
else
  echo "==> 渲染后端：Skia（注入 LUMINOUS_SOFTWARE_RENDER=1，虚拟机/无 GPU 环境必需）"
  RENDER_ENV="export LUMINOUS_SOFTWARE_RENDER=1"
fi

echo "==> 安装 GTK3 运行库（只装运行库，不改系统其它部分）"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  libgtk-3-0t64 libssl3t64 libsecret-1-0 libjsoncpp25 libsqlite3-0 \
  libstdc++6 zlib1g libgcc-s1 ca-certificates fonts-noto-cjk || {
  echo "    t64 包名不存在，回退到 24.04 之前的包名"
  sudo apt-get install -y --no-install-recommends \
    libgtk-3-0 libssl3 libsecret-1-0 libjsoncpp25 libsqlite3-0 \
    libstdc++6 zlib1g libgcc-s1 ca-certificates fonts-noto-cjk
}

echo "==> 解压到 ${APP_DIR}"
rm -rf "${APP_DIR}.new"
mkdir -p "${APP_DIR}.new" "${BIN_DIR}" "${DESKTOP_DIR}"
tar -xzf "$ARCHIVE" -C "${APP_DIR}.new"

BUNDLE="${APP_DIR}.new/bundle"
if [[ ! -x "${BUNDLE}/luminous" ]]; then
  echo "错误：压缩包内缺少可执行的 bundle/luminous" >&2
  exit 1
fi

# `flutter build` 不保证拷进来的辅助二进制带执行位；crashpad_handler 缺 +x 会让
# Sentry 崩溃上报在启动时 `posix_spawn ... 权限不够 (13)`。打包脚本已经修了源头，
# 这里再兜一次，历史包也能装。
chmod +x "${BUNDLE}/luminous" "${BUNDLE}/lib/crashpad_handler"
rm -rf "${APP_DIR}"
mv "${APP_DIR}.new" "${APP_DIR}"

echo "==> 迁移历史存储到 ${STATE_DIR}"
mkdir -p "${STATE_DIR}/kv"
if [[ -d "${HOME}/Documents/kv" ]]; then
  cp -an "${HOME}/Documents/kv/." "${STATE_DIR}/kv/" || true
fi
if [[ -f "${HOME}/Documents/luminous.db" && ! -f "${STATE_DIR}/luminous.db" ]]; then
  cp -a "${HOME}/Documents/luminous.db" "${STATE_DIR}/luminous.db"
fi

echo "==> 安装启动器"
cat > "${BIN_DIR}/luminous" <<EOF
#!/usr/bin/env bash
# 由 scripts/desktop/install_linux.sh 生成。想临时改后端就覆盖同名变量。
${RENDER_ENV}
exec "${APP_DIR}/bundle/luminous" "\$@"
EOF
chmod +x "${BIN_DIR}/luminous"

cat > "${DESKTOP_DIR}/${DESKTOP_ID}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Luminous
Comment=Luminous desktop client
Exec=env ${RENDER_ENV#export } ${APP_DIR}/bundle/luminous
Path=${APP_DIR}/bundle
Icon=${APP_DIR}/bundle/data/flutter_assets/assets/icon/app_icon.png
Terminal=false
Categories=Utility;
StartupWMClass=${DESKTOP_ID}
EOF
if [[ "$IMPELLER" -eq 1 ]]; then
  # --impeller 时不注入变量，避免桌面启动器里留下空的 "env  " 前缀。
  sed -i "s|^Exec=env  |Exec=|" "${DESKTOP_DIR}/${DESKTOP_ID}.desktop"
fi
chmod +x "${DESKTOP_DIR}/${DESKTOP_ID}.desktop"
update-desktop-database "${DESKTOP_DIR}" >/dev/null 2>&1 || true

case ":$PATH:" in
  *":${BIN_DIR}:"*) ;;
  *)
    echo "提示：${BIN_DIR} 不在 PATH 中，把下面一行加进 ~/.bashrc：" >&2
    echo 'export PATH="$HOME/.local/bin:$PATH"' >&2
    ;;
esac

echo
echo "安装完成："
echo "  程序目录   ${APP_DIR}/bundle"
echo "  数据目录   ${STATE_DIR}"
echo "  命令行启动 luminous"
echo "  图形启动   App 网格里搜索 Luminous（没有就注销重登一次）"
echo "  直接启动   ${APP_DIR}/bundle/luminous"
echo
echo "单实例：应用 ID 是 ${DESKTOP_ID}。已经开着一个实例时再启动会直接转发给"
echo "运行中的那个并退出，不会去抢 Hive 锁。"
echo
echo "首次直接运行一次看日志："
echo "  ${APP_DIR}/bundle/luminous"
