# フォルダ整理プロンプト

Claude Code や Codex に、下のプロンプトをそのまま渡してください。`<...>` の部分は自分に合わせて書き換えてください。

---

ホームフォルダの中身をすべて整理してください。フォルダ名だけで判断せず、**中身を見て**分類してください。

## 目標の構成
- `~/Dev/Apps/<種類>/git/` と `~/Dev/Apps/<種類>/local/`: 自作アプリ。種類は iOS-macOS / Web / Flutter / Unity / Python-AI / IoT などで、中身から判断する(`.xcodeproj`、`Package.swift`、`package.json`、`pubspec.yaml`、`ProjectSettings/ProjectVersion.txt`、`requirements.txt`、firmware など)。`.git` があれば `git/`、なければ `local/` に入れる
- `~/Dev/{Portfolio,School,Contests,Clones,Sandbox}`: Clones は remote が他人のリポジトリ、Sandbox は試作や中身がはっきりしないもの
- `~/Work/<クライアント>/`: 仕事・チーム開発。git の有無では分けない。素材は `assets/`、書類は `docs/` に入れる
- `~/Assets/{Images,Videos,Audio,Design,Screenshots,3DPrint}`: コード以外の素材
- `~/Documents/{Files,Notes,School}`
- `~/Secrets/`(chmod 700): `.p8`、`.jks`、`.cer`、`.p12`、秘密鍵、リカバリーコード
- 動かさないもの: `Library`、`Applications`、`Movies`、`Music`、`Pictures`、`Public`、ドットファイル、PATH や設定から参照されているツール(例: `~/development/flutter`)、アプリが場所を決めて使うフォルダ(Obsidian の Vault、Codex、Processing など)

## 手順
1. ホーム、Desktop、Downloads、Documents を一覧にして、それぞれの中身(README、プロジェクトファイル、git remote)を確認する
2. `旧パス<TAB>新パス` の対応表(movemap.tsv)を作り、移動の前に見せる。迷うものは質問する
3. 移動の前にバックアップを取る: `~/.claude/projects`、`~/.claude.json`、`~/.codex/sessions`、`~/.codex/config.toml`、`~/Library/Application Support/Claude/claude-code-sessions`
4. `mv -n` で移動し、移動元が消えて移動先があることを 1 件ずつ確かめる
5. **git worktree**: 本体と worktree を動かしたら、`git worktree repair <新しいパス...>` でつながりを直す。`~/.codex/worktrees` や `.claude/worktrees` の中にある worktree も対象にする
6. **絶対パスで参照している設定を探して直す**: Android の `key.properties`(`storeFile`)、Unity Hub の `projects-v1.json` と `projectDir.json`、`~/.codex/config.toml`、シェルの rc ファイル、`.env` など
7. **Claude と Codex の履歴**: `python3 -I rewrite-agent-paths.py movemap.tsv` を実行する。これは AI の履歴を書き換える操作なので、エージェントからは実行せず、ユーザーにターミナルで実行してもらう(Claude と Codex は終了してから)
8. **不要そうなものは削除しない**: 空のフォルダ、インストーラ(dmg / iso)、ホーム直下の `node_modules`、壊れたプロジェクトなどは `~/_不要候補/` に移し、理由とサイズを書いた `一覧.md` を付ける。動かすと壊れるもの(push 済みの worktree など)は一覧に書くだけにする
9. 最後に、git の状態、Claude と Codex の履歴、参照していた設定が新しいパスで動くことを確認して報告する

## 注意
- 実行中のアプリ(Xcode、Unity、dev サーバー)が使っているフォルダは動かさない
- iCloud で同期しているデスクトップは移動が遅いので、長い処理はバックグラウンドで実行する
- 最後に、このリポジトリの `install.sh`(自動振り分け)と `folder-style.swift`(色とアイコン)を入れるか、ユーザーに確認する
