#!/bin/zsh
# ~/Downloads と ~/Desktop に置かれたファイルを種類別に自動振り分けする (launchd から呼ばれる)
# 行き先を変えたいときは dest() の case を編集する
H=$HOME; A=$H/Assets
dest(){ local l=${1:l}
  case $l in
    *.crdownload|*.download|*.part|*.tmp|.*|desktop.ini) return 1;;
    *.p8|*.jks|*.keystore|*.cer|*.p12|*.mobileprovision|*.certsigningrequest|*recovery\ codes*) echo $H/Secrets;;
    screenshot*|スクリーンショット*|画面収録*|simulator\ screenshot*|screen\ recording*) echo $A/Screenshots;;
    *.png|*.jpg|*.jpeg|*.heic|*.gif|*.webp) echo $A/Images;;
    *.mp4|*.mov|*.webm|*.mkv) echo $A/Videos;;
    *.mp3|*.wav|*.m4a|*.aac) echo $A/Audio;;
    *.ai|*.psd|*.svg|*.fig|*.sketch) echo $A/Design;;
    *.3mf|*.stl|*.gcode) echo $A/3DPrint;;
    *.pdf|*.docx|*.xlsx|*.pptx|*.csv|*.key|*.pages|*.numbers) echo $H/Documents/Files;;
    *.dmg|*.pkg|*.iso) echo $H/Downloads/Installers;;
    *.zip|*.tar.gz|*.tgz|*.7z|*.rar) echo $H/Downloads/Archives;;
    *) return 1;;
  esac; }
for src in $H/Downloads $H/Desktop; do
  for f in $src/*(N.); do
    # 書き込み中のファイルは触らない (10秒以上更新がないものだけ)
    (( $(date +%s) - $(stat -f %m "$f") < 10 )) && continue
    d=$(dest "${f:t}") || continue
    [[ $src == $H/Desktop && $d != $A/Screenshots ]] && continue  # Desktop はスクショだけ
    mkdir -p "$d"; t="$d/${f:t}"; n=1
    while [[ -e $t ]]; do t="$d/${f:t:r} ($n).${f:e}"; ((n++)); done
    mv -n "$f" "$t"
    [[ $d == $H/Secrets ]] && chmod 700 "$d"
  done
done
