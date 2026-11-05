#!/bin/zsh
# auto-sort を ~/.local/bin に置いて launchd に登録する。 ./install.sh --uninstall で解除
set -e
cd "${0:A:h}"
P=$HOME/Library/LaunchAgents/local.mac-tidy.auto-sort.plist
if [[ $1 == --uninstall ]]; then
  launchctl unload "$P" 2>/dev/null || true; rm -f "$P" "$HOME/.local/bin/auto-sort.sh"; echo "解除しました"; exit
fi
mkdir -p ~/.local/bin ~/Library/LaunchAgents
cp auto-sort.sh ~/.local/bin/ && chmod +x ~/.local/bin/auto-sort.sh
sed "s#__HOME__#$HOME#g" auto-sort.plist.template > "$P"
launchctl unload "$P" 2>/dev/null || true; launchctl load "$P"
echo "登録しました。システム設定 → プライバシーとセキュリティ → フルディスクアクセス に /bin/zsh を追加してください"
