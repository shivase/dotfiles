#!/bin/bash

# This script creates symbolic links from dotfiles/claude-code to ~/.claude

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude"

# Parse command line arguments
FORCE_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            FORCE_YES=true
            shift
            ;;
        -h|--help)
            echo "使用方法: $0 [-y|--yes] [-h|--help]"
            echo "  -y, --yes    すべてのプロンプトに自動的にyesと答える"
            echo "  -h, --help   このヘルプメッセージを表示"
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "-h または --help で使用方法を確認してください"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}$SCRIPT_DIR から $TARGET_DIR へのシンボリックリンクを作成します${NC}"
if [ "$FORCE_YES" = true ]; then
    echo -e "${YELLOW}自動承認モードが有効です (-y フラグ)${NC}"
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}$TARGET_DIR ディレクトリを作成しています...${NC}"
    mkdir -p "$TARGET_DIR"
fi

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$(basename "$source")"
    
    if [ -L "$target" ]; then
        # If it's already a symlink
        local current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
            # Even if already correctly linked, ask for confirmation
            echo -e "${BLUE}?${NC} $name は既に正しい場所にリンクされています"
            if [ "$FORCE_YES" = true ]; then
                echo -e "    ${GREEN}✓${NC} 既存のリンクを維持 (自動承認)"
            else
                read -p "    再作成しますか？ (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$target"
                    ln -s "$source" "$target"
                    echo -e "    ${GREEN}✓${NC} $name (再作成しました)"
                else
                    echo -e "    ${GREEN}✓${NC} $name (既存のまま維持)"
                fi
            fi
        else
            echo -e "${YELLOW}⚠${NC} $name は存在しますが、異なる場所を指しています:"
            echo "    現在: $current_target"
            echo "    期待: $source"
            if [ "$FORCE_YES" = true ]; then
                rm "$target"
                ln -s "$source" "$target"
                echo -e "    ${GREEN}✓${NC} $name (更新しました - 自動承認)"
            else
                read -p "    更新しますか？ (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm "$target"
                    ln -s "$source" "$target"
                    echo -e "    ${GREEN}✓${NC} $name (更新しました)"
                else
                    echo -e "    ${YELLOW}⚠${NC} $name (スキップしました)"
                fi
            fi
        fi
    elif [ -e "$target" ]; then
        # If file/directory exists but is not a symlink
        echo -e "${RED}✗${NC} $name は存在しますが、シンボリックリンクではありません"
        if [ "$FORCE_YES" = true ]; then
            mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
            ln -s "$source" "$target"
            echo -e "    ${GREEN}✓${NC} $name (バックアップ後、リンクを作成 - 自動承認)"
        else
            read -p "    バックアップして置き換えますか？ (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
                ln -s "$source" "$target"
                echo -e "    ${GREEN}✓${NC} $name (バックアップ後、リンクを作成)"
            else
                echo -e "    ${YELLOW}⚠${NC} $name (スキップしました)"
            fi
        fi
    else
        # Create new symlink
        echo -e "${BLUE}?${NC} $name はまだ存在しません"
        if [ "$FORCE_YES" = true ]; then
            ln -s "$source" "$target"
            echo -e "    ${GREEN}✓${NC} $name (作成しました - 自動承認)"
        else
            read -p "    シンボリックリンクを作成しますか？ (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ln -s "$source" "$target"
                echo -e "    ${GREEN}✓${NC} $name (作成しました)"
            else
                echo -e "    ${YELLOW}⚠${NC} $name (スキップしました)"
            fi
        fi
    fi
}

# Create symlinks for all items in claude-code directory
echo -e "\n${BLUE}claude-code内のすべてのアイテムを処理中:${NC}"
for item in "$SCRIPT_DIR"/*; do
    # Skip this script itself
    if [ "$(basename "$item")" = "make-symlink.sh" ]; then
        echo -e "${YELLOW}⚠${NC} make-symlink.sh をスキップ (このスクリプト自身)"
        continue
    fi
    
    create_symlink "$item" "$TARGET_DIR/$(basename "$item")"
done

echo -e "\n${GREEN}シンボリックリンクの作成処理が完了しました！${NC}"
echo -e "${BLUE}ヒント:${NC}"
echo -e "  • ${YELLOW}-y${NC} フラグを使用すると、すべてのプロンプトに自動的に承認します"
echo -e "  • いつでも再実行してリンクを確認・更新できます"
echo -e "  • claude-code内の新しいファイル/フォルダは自動的に検出されます"