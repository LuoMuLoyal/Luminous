#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 回退到 arch/data（已含 dirs/presentation/core 合并结果）=="
git reset --hard arch/data >/dev/null
git log --oneline -1
git status --porcelain | grep -v 'pubspec.yaml\|generated_plugin_registrant\|scripts/arch' | head -5

echo
echo "== 合并 arch/domain =="
git merge --no-ff --no-commit arch/domain >/dev/null 2>&1
echo "冲突: $(git diff --name-only --diff-filter=U | wc -l)"
git diff --name-only --diff-filter=U
