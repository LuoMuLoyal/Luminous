import re, sys

with open('coverage/lcov.info', 'r', encoding='utf-8') as f:
    content = f.read()

files = []
current = {}
for line in content.split('\n'):
    if line.startswith('SF:'):
        current = {'file': line[3:], 'total': 0, 'hit': 0}
    elif line.startswith('DA:'):
        parts = line[3:].split(',')
        if len(parts) >= 2:
            current['total'] += 1
            if int(parts[1]) > 0:
                current['hit'] += 1
    elif line == 'end_of_record':
        if current:
            files.append(current)
        current = {}

results = []
for f in files:
    path = f.get('file', '')
    short = path.replace('\\', '/')
    if 'lib/' in short:
        short = short.split('lib/')[-1]
    else:
        continue
    lf = f.get('total', 0)
    lh = f.get('hit', 0)
    pct = (lh / lf * 100) if lf > 0 else 100
    results.append((pct, lh, lf, short))

results.sort(key=lambda x: x[0])

# Filter out generated files (.g.dart, .freezed.dart)
manual = [r for r in results if not r[3].endswith('.g.dart') and not r[3].endswith('.freezed.dart') and not r[3].startswith('l10n/')]

print('=== Low coverage manual files (< 50%) ===')
for pct, lh, lf, short in manual:
    if pct < 50:
        print(f'{pct:5.1f}%  {lh:4d}/{lf:4d}  {short}')

print()
print('=== Medium coverage manual files (50%-80%) ===')
for pct, lh, lf, short in manual:
    if 50 <= pct < 80:
        print(f'{pct:5.1f}%  {lh:4d}/{lf:4d}  {short}')

print()
print('=== Summary (manual files only) ===')
total_lf = sum(r[2] for r in manual)
total_lh = sum(r[1] for r in manual)
if total_lf > 0:
    print(f'Total: {total_lh}/{total_lf} = {total_lh/total_lf*100:.1f}%')
print(f'Files under 50%: {sum(1 for r in manual if r[0] < 50)}')
print(f'Files 50-80%: {sum(1 for r in manual if 50 <= r[0] < 80)}')
print(f'Files 80%+: {sum(1 for r in manual if r[0] >= 80)}')
