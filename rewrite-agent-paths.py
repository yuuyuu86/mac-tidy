"""移動の対応表 (旧パス<TAB>新パス) をもとに Claude Code / Codex の履歴と設定のパスを書き換える。
実行前に Claude と Codex を終了し、~/.claude と ~/.codex をバックアップしておくこと。"""
import json, os, re, sys, glob

H = os.path.expanduser("~")
import sys
MAP = sys.argv[1] if len(sys.argv) > 1 else sys.exit("usage: python3 -I rewrite-agent-paths.py movemap.tsv")
pairs = [l.rstrip("\n").split("\t") for l in open(MAP, encoding="utf-8")]
pairs.sort(key=lambda p: -len(p[0]))
# old path followed by end-of-path boundary
rx = re.compile("(" + "|".join(re.escape(o) for o, _ in pairs) + r')(?=["/\\\s\'\]`),:]|$)')
newof = dict(pairs)
sub = lambda s: rx.sub(lambda m: newof[m.group(1)], s)
needles = [o.encode() for o, _ in pairs]

def rewrite(path):
    with open(path, "rb") as f:
        data = f.read()
    if not any(n in data for n in needles):
        return False
    text = data.decode("utf-8", errors="surrogateescape")
    new = sub(text)
    if new == text:
        return False
    tmp = path + ".reorg-tmp"
    with open(tmp, "w", encoding="utf-8", errors="surrogateescape") as f:
        f.write(new)
    os.replace(tmp, path)
    return True

def encode(p):
    return re.sub(r"[^A-Za-z0-9]", "-", p)

stats = {}
# 1. Claude CLI project dirs: rename by the cwd recorded inside
proj = f"{H}/.claude/projects"
renamed = 0
for d in sorted(os.listdir(proj)):
    full = os.path.join(proj, d)
    if not os.path.isdir(full):
        continue
    cwd = None
    for j in glob.glob(f"{full}/*.jsonl"):
        with open(j, encoding="utf-8", errors="ignore") as f:
            for line in f:
                m = re.search(r'"cwd":"((?:[^"\\]|\\.)*)"', line)
                if m:
                    cwd = json.loads('"' + m.group(1) + '"')
                    break
        if cwd:
            break
    if not cwd or encode(cwd) != d:
        continue
    nc = sub(cwd)
    if nc == cwd:
        continue
    target = os.path.join(proj, encode(nc))
    if os.path.exists(target):
        for x in os.listdir(full):
            if not os.path.exists(os.path.join(target, x)):
                os.rename(os.path.join(full, x), os.path.join(target, x))
        if not os.listdir(full):
            os.rmdir(full)
    else:
        os.rename(full, target)
    renamed += 1
stats["claude project dirs renamed"] = renamed

# 2. rewrite path strings in history/config files
groups = {
    "claude jsonl": glob.glob(f"{proj}/**/*.jsonl", recursive=True),
    "claude.json": [f"{H}/.claude.json"],
    "desktop sessions": glob.glob(f"{H}/Library/Application Support/Claude/claude-code-sessions/**/*.json", recursive=True),
    "codex sessions": glob.glob(f"{H}/.codex/sessions/**/*.jsonl", recursive=True),
    "codex config": [f"{H}/.codex/config.toml"],
}
for k, files in groups.items():
    stats[k] = sum(rewrite(p) for p in files if os.path.isfile(p))
for k, v in stats.items():
    print(f"{k}: {v}")
