#!/usr/bin/env bash
# 在 Linux 桌面上安装 Luminous release 包（Flutter Linux bundle，非 .deb）。
#
# 用法：
#   bash scripts/desktop/install_linux.sh <luminous-linux-x64.tar.gz>
#   bash scripts/desktop/install_linux.sh <bundle.tar.gz> --impeller
#   bash scripts/desktop/install_linux.sh <bundle.tar.gz> --no-deps
#
# 产物来源：`.github/workflows/deploy-linux.yml`（手动 dispatch）上传的
# `luminous-linux-x64` artifact 解压后得到的 `luminous-linux-x64.tar.gz`。
#
# 前置：
#   - x86-64 的 Linux 桌面（Ubuntu 24.04 / 26.04 实测过），图形会话里运行；
#   - 首次安装需要 sudo 装 GTK3 运行库（只装运行库，不改系统其它部分）。
#     没有 sudo 或想自己装时用 --no-deps 跳过这一步。
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
#   ~/.local/share/applications/com.devluo.luminous.desktop   桌面启动器
#   ~/.local/share/luminous        数据目录：kv/preferences 与 luminous.db
#
# 数据目录说明：2026-11-03 之前的构建把偏好库与本地库放在 `$HOME/Documents`，
# 那是 XDG 的用户共享目录而不是应用私有目录，两份安装会争同一把 Hive 锁、
# 第二次启动直接以 `errno 11` 退出。本脚本安装前会把那里的历史数据搬到
# `~/.local/share/luminous`，让旧构建与新构建读到同一份偏好。
set -euo pipefail

ARCHIVE=""
IMPELLER=0
SKIP_DEPS=0

usage() {
  sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --impeller) IMPELLER=1; shift ;;
    --no-deps) SKIP_DEPS=1; shift ;;
    -h|--help) usage ;;
    -*) echo "未知参数: $1" >&2; usage ;;
    *) ARCHIVE="$1"; shift ;;
  esac
done

if [[ -z "$ARCHIVE" || ! -f "$ARCHIVE" ]]; then
  echo "用法: bash $0 /path/to/luminous-linux-x64.tar.gz [--impeller] [--no-deps]" >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "错误：这个包是 x86-64 的，当前架构是 $(uname -m)。" >&2
  exit 1
fi

ARCHIVE="$(cd "$(dirname "$ARCHIVE")" && pwd)/$(basename "$ARCHIVE")"

APP_DIR="${HOME}/.local/opt/luminous"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
STATE_DIR="${HOME}/.local/share/luminous"
DESKTOP_ID="com.devluo.luminous"

if [[ "$IMPELLER" -eq 1 ]]; then
  echo "==> 渲染后端：Impeller（Flutter 默认后端，不注入 LUMINOUS_SOFTWARE_RENDER）"
  # 空串 = 包装器里只留一行注释，不导出任何变量。
  RENDER_EXPORT=""
  DESKTOP_EXEC="${APP_DIR}/bundle/luminous"
else
  echo "==> 渲染后端：Skia（注入 LUMINOUS_SOFTWARE_RENDER=1；无可用 GPU 驱动的虚拟机必需）"
  RENDER_EXPORT="export LUMINOUS_SOFTWARE_RENDER=1"
  DESKTOP_EXEC="env LUMINOUS_SOFTWARE_RENDER=1 ${APP_DIR}/bundle/luminous"
fi

# 运行库候选名。Ubuntu 的包名会跟着 soname 走（24.04 的 libjsoncpp25 → 26.04 的
# libjsoncpp26，gtk3/ssl 同理），写死一个名字必然在某个版本上失败，所以每个槽位
# 给多个候选，装其中能装上的第一个。
DEP_SLOTS=(
  "libgtk-3-0t64 libgtk-3-0"
  "libssl3t64 libssl3"
  "libsecret-1-0"
  "libjsoncpp26 libjsoncpp25"
  "libsqlite3-0"
  "libstdc++6"
  "zlib1g"
  "libgcc-s1"
)
OPTIONAL_PKGS=("ca-certificates" "fonts-noto-cjk")

install_deps() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "    非 apt 系统，跳过自动装库。请自行确认下列共享库存在：" >&2
    echo "    libgtk-3, libsecret-1, libjsoncpp, libsqlite3, libssl, libstdc++, zlib, libgcc_s" >&2
    return 0
  fi

  if ! sudo -n true 2>/dev/null; then
    echo "==> 需要 sudo 安装运行库（可能会提示输入密码）"
  fi
  sudo apt-get update -qq || echo "    警告：apt-get update 失败，继续用现有索引"

  local missing=() slot pkg
  for slot in "${DEP_SLOTS[@]}"; do
    for pkg in $slot; do
      if apt-cache show "$pkg" >/dev/null 2>&1; then
        missing+=("$pkg")
        break
      fi
    done
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "    未在索引里找到任何候选包，跳过"
    return 0
  fi

  echo "    安装：${missing[*]} ${OPTIONAL_PKGS[*]}"
  sudo apt-get install -y --no-install-recommends "${missing[@]}" "${OPTIONAL_PKGS[@]}" \
    || echo "    警告：运行库安装未全部成功，若启动报缺库请手工补齐"
}

if [[ "$SKIP_DEPS" -eq 1 ]]; then
  echo "==> 跳过运行库安装（--no-deps）"
else
  echo "==> 安装 GTK3 运行库（只装运行库，不改系统其它部分）"
  install_deps
fi

echo "==> 解压到 ${APP_DIR}"
rm -rf "${APP_DIR}.new"
mkdir -p "${APP_DIR}.new" "${BIN_DIR}" "${DESKTOP_DIR}"
tar -xzf "$ARCHIVE" -C "${APP_DIR}.new"

BUNDLE="${APP_DIR}.new/bundle"
if [[ ! -f "${BUNDLE}/luminous" ]]; then
  echo "错误：压缩包内缺少 bundle/luminous，这不是 Luminous 的 Linux 包" >&2
  exit 1
fi

# `flutter build` 不保证拷进来的辅助二进制带执行位；crashpad_handler 缺 +x 会让
# Sentry 崩溃上报在启动时 `posix_spawn ... 权限不够 (13)`。打包流程已经修了源头，
# 这里再兜一次，历史包也能装。
chmod +x "${BUNDLE}/luminous" "${BUNDLE}/lib/crashpad_handler" 2>/dev/null || true

echo "==> 校验运行库"
if command -v ldd >/dev/null 2>&1; then
  MISSING_LIBS="$(ldd "${BUNDLE}/luminous" 2>/dev/null | grep 'not found' || true)"
  if [[ -n "$MISSING_LIBS" ]]; then
    echo "    缺少以下共享库：" >&2
    echo "$MISSING_LIBS" | sed 's/^/      /' >&2
    echo "    可先试：sudo apt-get install -y libgtk-3-0t64 libsecret-1-0 libjsoncpp26" >&2
  else
    echo "    全部满足"
  fi
fi

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
{
  echo '#!/usr/bin/env bash'
  echo '# 由 scripts/desktop/install_linux.sh 生成。想临时换后端就覆盖同名变量再执行。'
  if [[ -n "$RENDER_EXPORT" ]]; then
    echo "$RENDER_EXPORT"
  else
    echo '# --impeller：使用 Flutter 默认后端，不注入 LUMINOUS_SOFTWARE_RENDER'
  fi
  printf 'exec "%s" "$@"\n' "${APP_DIR}/bundle/luminous"
} > "${BIN_DIR}/luminous"
chmod +x "${BIN_DIR}/luminous"

cat > "${DESKTOP_DIR}/${DESKTOP_ID}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Luminous
Comment=Luminous desktop client
Exec=${DESKTOP_EXEC}
Path=${APP_DIR}/bundle
Icon=${APP_DIR}/bundle/data/flutter_assets/assets/icon/app_icon.png
Terminal=false
Categories=Utility;
StartupWMClass=${DESKTOP_ID}
EOF
chmod +x "${DESKTOP_DIR}/${DESKTOP_ID}.desktop"
command -v update-desktop-database >/dev/null 2>&1 \
  && update-desktop-database "${DESKTOP_DIR}" >/dev/null 2>&1 || true

echo
echo "安装完成："
echo "  程序目录   ${APP_DIR}/bundle"
echo "  数据目录   ${STATE_DIR}"
echo "  命令行启动 ${BIN_DIR}/luminous"
echo "  图形启动   App 网格里搜索 Luminous（没有就注销重登一次）"

case ":$PATH:" in
  *":${BIN_DIR}:"*) ;;
  *)
    echo
    echo "提示：${BIN_DIR} 不在 PATH 中。把下面一行加进 ~/.bashrc 后重开终端："
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
echo "单实例：应用 ID 是 ${DESKTOP_ID}。已经开着一个实例时再启动会直接转发给"
echo "运行中的那个并退出，不会去抢 Hive 锁。"
echo
echo "首次建议在终端里跑一次看日志："
echo "  ${BIN_DIR}/luminous"
