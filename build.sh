#!/usr/bin/env bash
# build.sh — 把当前 skill 打包为可分发的 zip 包
#
# 用法：
#   ./build.sh            # 打包到 dist/qiq-tech-review-v<version>.zip
#                         # 版本号取自 SKILL.md frontmatter 的 version 字段（单一版本来源）
#   ./build.sh -o foo.zip # 自定义输出路径
#
# 设计要点：
# - 只打包 skill 运行所需内容：SKILL.md / references/ / templates/
# - 排除 VCS、IDE、系统、license、构建产物等无关文件
# - 失败立即退出，输出可读的产物信息

set -euo pipefail

# 切到脚本所在目录，保证相对路径稳定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SKILL_NAME="qiq-tech-review"
OUT_DIR="dist"

# 从 SKILL.md frontmatter 解析 version（单一版本来源），失败则回退为 0.0.0
VERSION="$(awk -F': *' '/^---$/{f=!f; next} f && $1=="version"{print $2; exit}' SKILL.md | tr -d '"'"'"' \r')"
VERSION="${VERSION:-0.0.0}"

OUT_FILE="${OUT_DIR}/${SKILL_NAME}-v${VERSION}.zip"
CUSTOM_OUTPUT=0

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      OUT_FILE="$2"; CUSTOM_OUTPUT=1; shift 2 ;;
    -h|--help)
      sed -n '2,10p' "$0"; exit 0 ;;
    *)
      echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

# 必须存在的内容
REQUIRED=(SKILL.md references templates)
for p in "${REQUIRED[@]}"; do
  if [[ ! -e "$p" ]]; then
    echo "❌ 缺少必需路径: $p" >&2
    exit 1
  fi
done

# 依赖检查
if ! command -v zip >/dev/null 2>&1; then
  echo "❌ 未找到 zip 命令，请先安装 zip" >&2
  exit 1
fi

# 准备输出目录 & 清理旧产物
mkdir -p "$(dirname "$OUT_FILE")"
rm -f "$OUT_FILE"

# 仅保留最新版本：清理 dist/ 下同 skill 名的历史 zip
# - 默认输出场景（未传 -o）：清理所有匹配 ${SKILL_NAME}-v*.zip 与 ${SKILL_NAME}.zip 的历史产物
# - 自定义输出场景（传了 -o）：跳过清理，避免在用户指定的临时目录里误删用户的其它 zip
if [[ "$CUSTOM_OUTPUT" -eq 0 ]]; then
  shopt -s nullglob
  # 严格匹配两类历史命名：v 后跟版本号、或无版本号
  OLD_ZIPS=("${OUT_DIR}/${SKILL_NAME}-v"*.zip "${OUT_DIR}/${SKILL_NAME}.zip")
  shopt -u nullglob
  CLEANED=0
  if [[ ${#OLD_ZIPS[@]} -gt 0 ]]; then
    for f in "${OLD_ZIPS[@]}"; do
      # 跳过本次将要写入的目标（虽然上面 rm -f 已删，但防御式判定）
      [[ "$f" == "$OUT_FILE" ]] && continue
      [[ -f "$f" ]] || continue
      rm -f "$f"
      echo "🧹 已清理旧版本: $f"
      CLEANED=$((CLEANED + 1))
    done
  fi
  if [[ "$CLEANED" -eq 0 ]]; then
    echo "ℹ️  无需清理（dist/ 下无历史 zip）"
  fi
fi

# 排除规则（相对仓库根的 glob，zip -x 语法）
EXCLUDES=(
  '*.DS_Store'
  '__MACOSX/*'
  '.git/*'
  '.gitignore'
  '.github/*'
  '.vscode/*'
  '.idea/*'
  '.qiqskills/*'
  'dist/*'
  'build.sh'
  'LICENSE'
  '*.zip'
  '*.log'
  '*.tmp'
  '*.bak'
  '*.swp'
)

echo "📦 打包 skill: $SKILL_NAME"
echo "   输出: $OUT_FILE"

# -r 递归 / -q 静默（避免冗长输出） / -X 不写入额外的本地属性
zip -rqX "$OUT_FILE" "${REQUIRED[@]}" -x "${EXCLUDES[@]}"

# 产物信息（只统计文件，排除目录条目）
SIZE_HUMAN=$(ls -lh "$OUT_FILE" | awk '{print $5}')
FILE_LIST=$(unzip -Z1 "$OUT_FILE" | grep -v '/$' || true)
FILE_COUNT=$(printf '%s\n' "$FILE_LIST" | sed '/^$/d' | wc -l | tr -d ' ')

echo "✅ 打包完成"
echo "   大小: $SIZE_HUMAN"
echo "   文件数: $FILE_COUNT"
echo ""
echo "📂 内容预览:"
printf '%s\n' "$FILE_LIST" | sed '/^$/d' | awk '{print "   " $0}'
