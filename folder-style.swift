// フォルダに Finder のカラータグと絵文字付きアイコンを付ける
// 使い方: swift folder-style.swift  (下の rules を編集して再実行すれば反映し直せる)
import AppKit


// 引数でルートを渡すと、そのフォルダを基準に適用する(試すとき用)
let H = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : NSHomeDirectory()
// (パス, タグ, 絵文字)  タグ名は Finder 標準色: Red Orange Yellow Green Blue Purple Gray
// 自分のフォルダ構成に合わせて編集する (例: ("Work/client-a", ["Orange"], "🏢"))
let rules: [(String, [String], String)] = [
  ("Dev", ["Blue"], "💻"),
  ("Dev/Apps", ["Blue"], "📱"),
  ("Dev/Apps/iOS-macOS", ["Blue"], "🍎"),
  ("Dev/Apps/Web", ["Blue"], "🌐"),
  ("Dev/Apps/Flutter", ["Blue"], "🦋"),
  ("Dev/Apps/Unity", ["Blue"], "🎮"),
  ("Dev/Apps/Python-AI", ["Blue"], "🐍"),
  ("Dev/Apps/IoT", ["Blue"], "🔌"),
  ("Dev/Portfolio", ["Blue"], "✨"),
  ("Dev/School", ["Yellow"], "🎓"),
  ("Dev/Contests", ["Yellow"], "🏆"),
  ("Dev/Clones", ["Gray"], "📥"),
  ("Dev/Sandbox", ["Gray"], "🧪"),
  ("Work", ["Orange"], "💼"),
  ("Assets", ["Purple"], "🎨"),
  ("Assets/Images", ["Purple"], "🖼️"),
  ("Assets/Videos", ["Purple"], "🎬"),
  ("Assets/Audio", ["Purple"], "🎵"),
  ("Assets/Design", ["Purple"], "✏️"),
  ("Assets/Screenshots", ["Purple"], "📸"),
  ("Assets/3DPrint", ["Purple"], "🧊"),
  ("Documents/Files", ["Green"], "📄"),
  ("Documents/School", ["Yellow"], "🎓"),
  ("Documents/Notes", ["Green"], "📝"),
  ("Secrets", ["Red"], "🔑"),
  ("_不要候補", ["Gray"], "🗑️"),
  ("Backups", ["Gray"], "🗄️"),
]
func icon(_ emoji: String) -> NSImage {
  let size = NSSize(width: 512, height: 512)
  let folder = NSWorkspace.shared.icon(for: .folder)
  folder.size = size
  return NSImage(size: size, flipped: false) { r in
    folder.draw(in: r)
    let s = NSAttributedString(string: emoji, attributes: [.font: NSFont.systemFont(ofSize: 200)])
    let b = s.size()
    s.draw(at: NSPoint(x: (r.width - b.width) / 2, y: r.height * 0.40 - b.height / 2))
    return true
  }
}

func style(_ path: String, _ tags: [String], _ emoji: String) {
  var url = URL(fileURLWithPath: path)
  guard FileManager.default.fileExists(atPath: path) else { return }
  var v = URLResourceValues(); v.tagNames = tags
  try? url.setResourceValues(v)
  NSWorkspace.shared.setIcon(icon(emoji), forFile: path)
  print("✓ \(emoji) \(path.replacingOccurrences(of: H, with: "~"))")
}

for (p, t, e) in rules { style("\(H)/\(p)", t, e) }

// git 管理か: git/ は緑の「git」、local/ は黄色の「local」タグ (アイコンはそのまま)
for base in ["iOS-macOS", "Web", "Flutter", "Unity", "Python-AI", "IoT"] {
  for (sub, tags, e) in [("git", ["Green", "git"], "🌿"), ("local", ["Yellow", "local"], "📦")] {
    let dir = "\(H)/Dev/Apps/\(base)/\(sub)"
    style(dir, tags, e)
    for name in (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? [] where !name.hasPrefix(".") {
      var u = URL(fileURLWithPath: "\(dir)/\(name)")
      var v = URLResourceValues(); v.tagNames = tags
      try? u.setResourceValues(v)
    }
  }
}
