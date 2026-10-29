#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1
flutter test 2>&1 > /tmp/test-out.txt
echo "结果尾部:"
tail -3 /tmp/test-out.txt
echo
echo "== 失败用例所在的测试文件（按数量）=="
grep -E '^D:/.*_test\.dart:' /tmp/test-out.txt | sed 's|.*Luminous/||;s|:.*||' | sort | uniq -c | sort -rn | head -20
