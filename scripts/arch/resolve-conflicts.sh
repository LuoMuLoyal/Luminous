#!/usr/bin/env bash
# 解决当前 merge 的冲突：import 冲突取并集，其余取主干侧并记入待确认清单。
set -u
REPO=${1:-/d/25080/Documents/VSCodeProject/Lumos/Luminous}
cd "$REPO" || exit 1
mkdir -p scripts/arch
REVIEW=/tmp/merge-review.txt
: > "$REVIEW"

for f in $(git diff --name-only --diff-filter=U); do
  case "$f" in
    *.md) git checkout --ours -- "$f" 2>/dev/null; echo "ours: $f"; continue ;;
    *.dart) ;;
    *) echo "SKIP: $f"; continue ;;
  esac
  python - "$f" "$REVIEW" <<'PY'
import sys
path, review = sys.argv[1], sys.argv[2]
lines = open(path, encoding='utf-8').read().split('\n')
out, i, needs_review = [], 0, False
while i < len(lines):
    if lines[i].startswith('<<<<<<<'):
        i += 1
        ours = []
        while i < len(lines) and not lines[i].startswith('======='):
            ours.append(lines[i]); i += 1
        i += 1
        theirs = []
        while i < len(lines) and not lines[i].startswith('>>>>>>>'):
            theirs.append(lines[i]); i += 1
        i += 1
        pure = all(l.startswith('import ') or l.strip() == '' for l in ours + theirs)
        if pure:
            merged = [l for l in ours if l.strip()]
            for l in theirs:
                if l.strip() and l not in merged:
                    merged.append(l)
            out.extend(sorted(set(merged)))
        else:
            needs_review = True
            out.extend(ours)
    else:
        out.append(lines[i]); i += 1
open(path, 'w', encoding='utf-8', newline='').write('\n'.join(out))
if needs_review:
    open(review, 'a', encoding='utf-8').write(path + '\n')
PY
  echo "resolved: $f"
done

echo
if [ -s "$REVIEW" ]; then echo "待人工确认:"; sort -u "$REVIEW"; else echo "全部为 import 级冲突"; fi
