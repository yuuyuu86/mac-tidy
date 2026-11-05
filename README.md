# mac-tidy

Mac のホームフォルダを「用途 → 種類 → git 管理の有無」で整理し、その状態を保つためのツールです。

- **auto-sort**: Downloads に入ったファイルを、種類ごとに自動で振り分けます(Desktop で動かすのはスクショだけ)
- **folder-style**: Finder のカラータグと、絵文字付きのフォルダアイコンを付けます
- **PROMPT.md**: Claude Code や Codex に、フォルダの整理そのものを頼むためのプロンプトです
- **rewrite-agent-paths.py**: フォルダを移動したあと、Claude Code と Codex の会話履歴に残る古いパスを書き換えます

## フォルダ構成

```
~/
├── Dev/
│   ├── Apps/<種類>/{git,local}/   iOS-macOS, Web, Flutter, Unity, Python-AI, IoT …
│   ├── Portfolio/  School/  Contests/  Clones/  Sandbox/
├── Work/<クライアント>/            仕事・チーム開発
├── Assets/                        Images, Videos, Audio, Design, Screenshots, 3DPrint
├── Documents/{Files,Notes,School}/
├── Secrets/                       鍵・証明書・リカバリーコード(chmod 700)
└── _不要候補/                      削除するか本人が決めるもの
```

## auto-sort のしくみ

1. launchd が `~/Downloads` と `~/Desktop` の変化を監視します。念のため 60 秒ごとにも起動します。
2. `auto-sort.sh` がファイルの拡張子と名前から行き先を決め、`mv -n` で移動します。
3. ダウンロード中のファイル(`.crdownload` など、または最後の更新から 10 秒以内のファイル)には触りません。
4. 同じ名前のファイルがあるときは、上書きせずに ` (1)` を付けます。

ファイルが振り分けられるまでの時間は、10 秒から 1 分ほどです。

### インストール

```bash
./install.sh
```

そのあと、**システム設定 → プライバシーとセキュリティ → フルディスクアクセス** に `/bin/zsh` を追加してください(追加画面で ⌘⇧G を押すとパスを入力できます)。これがないと、バックグラウンドで起動したときに Downloads を読めません。

- 解除するとき: `./install.sh --uninstall`
- エラーのログ: `~/Library/Logs/auto-sort.log`
- 振り分けのルールを変えるとき: `~/.local/bin/auto-sort.sh` の `dest()` を編集してください

## folder-style

`folder-style.swift` の `rules` を自分のフォルダに合わせて書き換えてから、次のコマンドで実行します。

```bash
swift folder-style.swift
```

`Dev/Apps/*/git` の中のプロジェクトには緑の `git` タグ、`local` の中には黄色の `local` タグが付きます。
各プロジェクトのフォルダ自体のアイコンは変えません。カスタムアイコンを付けると `Icon\r` という隠しファイルが作られ、git の差分に出てしまうためです。

自分のクライアント名などを入れたルールは `folder-style.local.swift` という名前でコピーして使うと、`.gitignore` の対象になるので公開されません。

## 注意

- 移動の対応表(`*.tsv`)には個人のパスが入るので、`.gitignore` で除外しています。
- `rewrite-agent-paths.py` は AI エージェントの会話履歴を書き換えます。Claude Code の自動モードでは安全チェックで止められるので、**自分のターミナルで**実行してください。実行前に `~/.claude` と `~/.codex` のバックアップを取ってください。
