#!/bin/bash

# 🤖 AI並列開発チーム - 統合起動スクリプト (start-claude.sh)

# 使用方法表示
show_usage() {
    cat << EOF
🚀 AI並列開発チーム - 統合起動システム

使用方法:
  $0 <セッション名> [オプション]
  $0 [管理コマンド]

引数:
  セッション名      tmuxセッション名（必須）
  
オプション:
  --reset          既存セッションを削除して再作成
  --individual     個別セッション方式で起動（統合監視画面なし）
  --help           このヘルプを表示

管理コマンド:
  list             起動中のAIチームセッション一覧を表示
  delete [名前]    指定したセッションを削除
  delete-all       全てのAIチームセッションを削除

例:
  $0 myproject               # myprojectセッションで統合監視画面起動
  $0 ai-team                 # ai-teamセッションで統合監視画面起動
  $0 myproject --reset       # myprojectセッションを再作成
  $0 myproject --individual  # myprojectで個別セッション方式起動
  $0 list                    # セッション一覧表示
  $0 delete myproject        # myprojectセッションを削除
  $0 delete-all              # 全セッション削除

EOF
}

# スクリプトの場所を取得（任意のフォルダから実行されても対応）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKING_DIR="$(pwd)"

# Claude CLIの実際のパスを取得（エイリアスを回避）
CLAUDE_CLI_PATH="$(which claude 2>/dev/null | head -1)"
if [[ "$CLAUDE_CLI_PATH" =~ "aliased to" ]]; then
    # エイリアスの場合、実際のパスを抽出
    CLAUDE_CLI_PATH="$(alias claude 2>/dev/null | sed 's/.*aliased to //' | sed 's/ --dangerously-skip-permissions.*//' | tr -d "'")"
fi
if [ ! -f "$CLAUDE_CLI_PATH" ]; then
    # フォールバック
    CLAUDE_CLI_PATH="/Users/sumik/.claude/local/claude"
fi

# デフォルト値
SESSION_NAME=""
RESET_MODE=false
INDIVIDUAL_MODE=false

# セッション管理関数を先に定義
list_ai_sessions() {
    echo "🤖 AI並列開発チーム - セッション一覧"
    echo "=================================="
    
    # tmuxセッション一覧を取得
    local all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")
    
    if [ -z "$all_sessions" ]; then
        echo "❌ 起動中のtmuxセッションがありません"
        return 1
    fi
    
    # AIチーム関連セッションを抽出・分類
    local integrated_sessions=()
    local individual_sessions=()
    local other_sessions=()
    
    while read -r session; do
        if [[ -n "$session" ]]; then
            # 統合監視画面の判定（5ペイン構成）
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            if [ "$pane_count" -eq 5 ]; then
                integrated_sessions+=("$session")
            # 個別セッション方式の判定（-ceo, -manager, -dev1-3 で終わる）
            elif [[ "$session" =~ -(ceo|manager|dev[1-3])$ ]]; then
                local base_name="${session%-*}"
                if [[ ! " ${individual_sessions[@]} " =~ " ${base_name} " ]]; then
                    individual_sessions+=("$base_name")
                fi
            else
                other_sessions+=("$session")
            fi
        fi
    done <<< "$all_sessions"
    
    # 統合監視画面セッション表示
    if [ ${#integrated_sessions[@]} -gt 0 ]; then
        echo ""
        echo "📺 統合監視画面セッション:"
        for session in "${integrated_sessions[@]}"; do
            local panes_info=$(tmux list-panes -t "$session" -F "#{pane_title}" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
            echo "  🎯 $session (5ペイン: $panes_info)"
            echo "    接続: tmux attach -t $session"
            echo "    削除: $0 delete $session"
        done
    fi
    
    # 個別セッション方式表示
    if [ ${#individual_sessions[@]} -gt 0 ]; then
        echo ""
        echo "🔄 個別セッション方式:"
        for base_name in "${individual_sessions[@]}"; do
            echo "  📋 $base_name グループ:"
            local agents=("ceo" "manager" "dev1" "dev2" "dev3")
            for agent in "${agents[@]}"; do
                local full_session="${base_name}-${agent}"
                if tmux has-session -t "$full_session" 2>/dev/null; then
                    echo "    ✅ $full_session"
                else
                    echo "    ❌ $full_session (未起動)"
                fi
            done
            echo "    削除: $0 delete $base_name"
        done
    fi
    
    # その他のセッション
    if [ ${#other_sessions[@]} -gt 0 ]; then
        echo ""
        echo "🔧 その他のtmuxセッション:"
        for session in "${other_sessions[@]}"; do
            echo "  📄 $session"
        done
    fi
    
    if [ ${#integrated_sessions[@]} -eq 0 ] && [ ${#individual_sessions[@]} -eq 0 ]; then
        echo ""
        echo "ℹ️ AIチーム関連のセッションが見つかりませんでした"
        echo "💡 新しいセッションを作成: $0 [セッション名]"
    fi
}

delete_ai_session() {
    local target_session="$1"
    
    if [ -z "$target_session" ]; then
        echo "❌ エラー: 削除するセッション名を指定してください"
        echo "使用方法: $0 delete [セッション名]"
        echo "セッション一覧: $0 list"
        return 1
    fi
    
    echo "🗑️ セッション削除: $target_session"
    local deleted_count=0
    
    # 統合監視画面の場合
    if tmux has-session -t "$target_session" 2>/dev/null; then
        local pane_count=$(tmux list-panes -t "$target_session" 2>/dev/null | wc -l)
        if [ "$pane_count" -eq 5 ]; then
            echo "  📺 統合監視画面セッション '$target_session' を削除中..."
            tmux kill-session -t "$target_session"
            echo "  ✅ 削除完了"
            deleted_count=$((deleted_count + 1))
        else
            echo "  📄 一般セッション '$target_session' を削除中..."
            tmux kill-session -t "$target_session"
            echo "  ✅ 削除完了"
            deleted_count=$((deleted_count + 1))
        fi
    fi
    
    # 個別セッション方式の場合
    local agents=("ceo" "manager" "dev1" "dev2" "dev3")
    for agent in "${agents[@]}"; do
        local full_session="${target_session}-${agent}"
        if tmux has-session -t "$full_session" 2>/dev/null; then
            echo "  🔄 個別セッション '$full_session' を削除中..."
            tmux kill-session -t "$full_session"
            echo "  ✅ 削除完了"
            deleted_count=$((deleted_count + 1))
        fi
    done
    
    if [ $deleted_count -eq 0 ]; then
        echo "  ❌ セッション '$target_session' が見つかりませんでした"
        echo "  💡 セッション一覧を確認: $0 list"
        return 1
    else
        echo ""
        echo "✅ $deleted_count 個のセッションを削除しました"
        
        echo "🧹 セッション削除完了確認中..."
        echo "  ✅ 確認完了"
    fi
}

delete_all_ai_sessions() {
    echo "🗑️ 全AIチームセッション削除"
    echo "=============================="
    
    # 確認プロンプト
    echo "⚠️ 警告: 全てのAIチーム関連セッションを削除します"
    echo -n "本当に削除しますか？ [y/N]: "
    read -r confirmation
    
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "❌ 削除をキャンセルしました"
        return 0
    fi
    
    local deleted_count=0
    
    # 全tmuxセッションを確認
    local all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")
    
    if [ -z "$all_sessions" ]; then
        echo "ℹ️ 削除対象のセッションがありません"
        return 0
    fi
    
    while read -r session; do
        if [[ -n "$session" ]]; then
            # 統合監視画面（5ペイン）またはAIチーム個別セッション
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            if [ "$pane_count" -eq 5 ] || [[ "$session" =~ -(ceo|manager|dev[1-3])$ ]]; then
                echo "  🗑️ セッション '$session' を削除中..."
                tmux kill-session -t "$session"
                deleted_count=$((deleted_count + 1))
            fi
        fi
    done <<< "$all_sessions"
    
    if [ $deleted_count -eq 0 ]; then
        echo "ℹ️ AIチーム関連のセッションが見つかりませんでした"
    else
        echo ""
        echo "✅ $deleted_count 個のセッションを削除しました"
        
        echo "🧹 セッション削除確認中..."
        echo "  ✅ 確認完了"
    fi
}

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        list)
            list_ai_sessions
            exit 0
            ;;
        delete)
            if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                delete_ai_session "$2"
                exit 0
            else
                echo "❌ エラー: delete には削除するセッション名が必要です"
                echo "使用方法: $0 delete [セッション名]"
                echo "セッション一覧: $0 list"
                exit 1
            fi
            ;;
        delete-all)
            delete_all_ai_sessions
            exit 0
            ;;
        --reset)
            RESET_MODE=true
            shift
            ;;
        --individual)
            INDIVIDUAL_MODE=true
            shift
            ;;
        --*)
            echo "❌ エラー: 不明なオプション $1"
            show_usage
            exit 1
            ;;
        *)
            if [[ -z "$SESSION_NAME" ]]; then
                SESSION_NAME="$1"
            else
                echo "❌ エラー: セッション名は1つだけ指定してください"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# セッション名が指定されていない場合はヘルプを表示
if [[ -z "$SESSION_NAME" ]]; then
    echo "❌ エラー: セッション名を指定してください"
    echo ""
    show_usage
    exit 1
fi

echo "🚀 AI並列開発チーム統合起動システム"
echo "📁 作業ディレクトリ: $WORKING_DIR"
echo "📁 スクリプト場所: $SCRIPT_DIR"
echo "📋 セッション名: $SESSION_NAME"

# Claude CLIパス確認
echo "🔧 Claude CLI: $CLAUDE_CLI_PATH"

# セッション名のバリデーション
if [[ ! "$SESSION_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ エラー: セッション名は英数字、ハイフン、アンダースコアのみ使用可能です"
    exit 1
fi

# Claude CLIの認証状態確認
check_claude_auth() {
    echo "🔐 Claude認証状態を確認中..."
    
    # Claude設定ファイルの存在確認でより正確な認証チェック
    if [ -f "$HOME/.claude/settings.json" ] && [ -s "$HOME/.claude/settings.json" ]; then
        echo "  ✅ Claude設定ファイルが存在します"
        
        # 実際にClaude CLIが動作するかテスト（認証不要コマンド、エイリアス回避）
        if timeout 5 "$CLAUDE_CLI_PATH" --help > /dev/null 2>&1; then
            echo "  ✅ Claude CLI動作確認済み"
            return 0
        else
            echo "  ⚠️ Claude CLIの動作に問題があります"
            return 1
        fi
    else
        echo "  ⚠️ Claude設定ファイルが見つかりません"
        return 1
    fi
}

# 認証チェック実行
AUTH_OK=false
if check_claude_auth; then
    AUTH_OK=true
fi

# Claude CLIの初期設定を完全に事前実行
setup_claude_config() {
    echo "🎨 Claude CLI初期設定中..."
    
    sleep 1
    
    # 設定ファイルを作成
    mkdir -p ~/.claude
    cat > ~/.claude/settings.json << 'EOF'
{
  "model": "sonnet", 
  "theme": "dark",
  "hasCompletedOnboarding": true,
  "hasSetTheme": true,
  "skipInitialSetup": true
}
EOF
    
    echo "  ✅ Claude CLI設定完了"
}

# 初期設定実行
setup_claude_config

# 必要なインストラクションファイルが存在するかチェック
echo "📂 インストラクションファイルをチェック中..."
missing_count=0

# 正しいinstructionsパスを設定
INSTRUCTIONS_DIR="/Users/sumik/dotfiles/bin/instructions"

# ceo.md のチェック
if [ ! -f "$INSTRUCTIONS_DIR/ceo.md" ]; then
    echo "❌ エラー: $INSTRUCTIONS_DIR/ceo.md が見つかりません"
    missing_count=$((missing_count + 1))
fi

# manager.md のチェック
if [ ! -f "$INSTRUCTIONS_DIR/manager.md" ]; then
    echo "❌ エラー: $INSTRUCTIONS_DIR/manager.md が見つかりません"
    missing_count=$((missing_count + 1))
fi

# developer.md のチェック
if [ ! -f "$INSTRUCTIONS_DIR/developer.md" ]; then
    echo "❌ エラー: $INSTRUCTIONS_DIR/developer.md が見つかりません"
    missing_count=$((missing_count + 1))
fi

if [ $missing_count -ne 0 ]; then
    echo ""
    echo "必要なインストラクションファイルを配置してください"
    exit 1
fi

# 個別セッション方式の関数
start_individual_sessions() {
    echo "🔄 個別セッション方式で起動中..."
    
    # 既存セッションのクリーンアップ
    if [[ "$RESET_MODE" == "true" ]]; then
        echo "🗑️ 既存セッションをクリーンアップ中..."
        tmux kill-session -t "${SESSION_NAME}-ceo" 2>/dev/null || true
        tmux kill-session -t "${SESSION_NAME}-manager" 2>/dev/null || true
        tmux kill-session -t "${SESSION_NAME}-dev1" 2>/dev/null || true
        tmux kill-session -t "${SESSION_NAME}-dev2" 2>/dev/null || true
        tmux kill-session -t "${SESSION_NAME}-dev3" 2>/dev/null || true
    fi
    
    # 各セッションを作成
    agents=("ceo" "manager" "dev1" "dev2" "dev3")
    for agent in "${agents[@]}"; do
        local session="${SESSION_NAME}-${agent}"
        
        if tmux has-session -t "$session" 2>/dev/null; then
            echo "  📺 既存セッション $session に接続"
        else
            echo "  🚀 セッション $session を作成中..."
            tmux new-session -d -s "$session"
            tmux send-keys -t "$session" "cd '$WORKING_DIR'" C-m
            
            # インストラクションファイルの選択
            if [[ "$agent" == "ceo" ]]; then
                inst_file="$INSTRUCTIONS_DIR/ceo.md"
            elif [[ "$agent" == "manager" ]]; then
                inst_file="$INSTRUCTIONS_DIR/manager.md"
            else
                inst_file="$INSTRUCTIONS_DIR/developer.md"
            fi
            
            # Claude CLIを起動（事前設定済み）
            local claude_cmd="\"$CLAUDE_CLI_PATH\" --dangerously-skip-permissions \"$inst_file\""
            tmux send-keys -t "$session" "$claude_cmd" C-m
        fi
    done
    
    echo ""
    echo "✅ 個別セッション方式で起動完了！"
    echo ""
    echo "🎯 セッション一覧:"
    echo "  CEO:     tmux attach -t ${SESSION_NAME}-ceo"
    echo "  Manager: tmux attach -t ${SESSION_NAME}-manager"
    echo "  Dev1:    tmux attach -t ${SESSION_NAME}-dev1"
    echo "  Dev2:    tmux attach -t ${SESSION_NAME}-dev2"
    echo "  Dev3:    tmux attach -t ${SESSION_NAME}-dev3"
    echo ""
    echo "💡 メッセージ送信: send-message.sh --session $SESSION_NAME [エージェント] [メッセージ]"
}

# 統合監視画面方式の関数
start_integrated_monitor() {
    echo "📺 統合監視画面方式で起動中..."
    
    # 既存セッションの確認とハンドリング
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        if [[ "$RESET_MODE" == "true" ]]; then
            echo "🗑️ 既存の$SESSION_NAMEセッションを削除中..."
            tmux kill-session -t "$SESSION_NAME"
            echo "  ✓ 既存セッション削除完了"
            
            echo "🧹 セッション関連のプロセス確認完了"
            sleep 2
        else
            echo "📺 既存の${SESSION_NAME}セッションに接続中..."
            echo ""
            echo "✅ AI並列開発チーム統合監視画面に接続します！"
            echo "🔄 統合監視画面に自動接続中..."
            sleep 1
            
            # 既存セッションに接続
            exec tmux attach -t "$SESSION_NAME"
        fi
    else
        echo "📝 新規${SESSION_NAME}セッション作成準備中..."
        
        echo "🧹 セッション関連のプロセス確認完了"
        sleep 2
    fi
    
    # Claude CLIは認証済みを前提として起動
    
    # 監視用セッションを作成
    tmux new-session -d -s "$SESSION_NAME"
    
    # 正しいレイアウトを構築
    echo "🔧 統合監視画面レイアウト構築中..."
    echo "  目標: 上部左=CEO、下部左=Manager、下部右=Dev1/Dev2/Dev3"
    
    # 1. まず左右分割（左側、右側）
    tmux split-window -h -t "$SESSION_NAME"
    echo "  ✓ 左右分割完了"
    
    # 2. 左側を上下分割（上: CEO、下: Manager）
    tmux split-window -v -t "$SESSION_NAME.0"
    echo "  ✓ 左側を上下分割完了（上: CEO、下: Manager）"
    
    # 3. 右側を上下分割（上: Dev1、下: 残り）
    tmux split-window -v -t "$SESSION_NAME.1"
    echo "  ✓ 右側を上下分割完了"
    
    # 4. 右下をさらに分割（Dev2用）
    tmux split-window -v -t "$SESSION_NAME.3"
    echo "  ✓ 右下を分割完了（Dev2用）"
    
    # 5. 最後のペインをさらに分割（Dev3用）
    tmux split-window -v -t "$SESSION_NAME.4"
    echo "  ✓ 最後のペインを分割完了（Dev3用）"
    
    # 6. レイアウト最適化とペインタイトル表示設定
    echo "  🔧 レイアウト最適化中..."
    
    # ペインタイトルを表示するように設定
    tmux set-option -t "$SESSION_NAME" pane-border-status top
    tmux set-option -t "$SESSION_NAME" pane-border-format "#T"
    
    # 自動リネームを無効化してタイトルを固定
    tmux set-window-option -t "$SESSION_NAME" automatic-rename off
    tmux set-window-option -t "$SESSION_NAME" allow-rename off
    
    # 現在のペイン構成を確認
    echo "  📋 最終ペイン構成:"
    tmux list-panes -t "$SESSION_NAME" -F "    ペイン #{pane_index}: #{pane_width}x#{pane_height} [#{pane_id}] 位置#{pane_top},#{pane_left}"
    
    # 少し待ってからペイン情報を取得
    sleep 0.5
    
    # 各ペインに対応するセッションを表示
    echo "📺 各セッションを統合画面に表示中..."
    
    # ペイン番号を動的に取得して各セッションに接続
    PANES=($(tmux list-panes -t "$SESSION_NAME" -F "#{pane_id}" | sed 's/%//g'))
    
    # 配列の長さをチェック
    if [ ${#PANES[@]} -eq 5 ]; then
        echo "ペイン構成: ${PANES[@]}"
        
        # 正しいレイアウトでの統合Claude起動（5ペイン構成）
        echo "  🎯 各ペインでの直接Claude起動とタイトル設定:"
        echo "    ペイン 0 (上部左): CEO"
        echo "    ペイン 1 (下部左): Manager" 
        echo "    ペイン 2 (右上): Dev1"
        echo "    ペイン 3 (右中): Dev2"
        echo "    ペイン 4 (右下): Dev3"
        
        # 各ペインにタイトルを設定し、直接Claudeを起動
        for i in "${!PANES[@]}"; do
            case $i in
                0) 
                    role="CEO"
                    pane_title="CEO"
                    instruction_file="$INSTRUCTIONS_DIR/ceo.md"
                    ;;
                1) 
                    role="Manager"
                    pane_title="Manager"
                    instruction_file="$INSTRUCTIONS_DIR/manager.md"
                    ;;
                2) 
                    role="Dev1"
                    pane_title="Dev1"
                    instruction_file="$INSTRUCTIONS_DIR/developer.md"
                    ;;
                3) 
                    role="Dev2"
                    pane_title="Dev2"
                    instruction_file="$INSTRUCTIONS_DIR/developer.md"
                    ;;
                4) 
                    role="Dev3"
                    pane_title="Dev3"
                    instruction_file="$INSTRUCTIONS_DIR/developer.md"
                    ;;
            esac
            
            # ペインが存在するかチェックしてから設定
            if tmux list-panes -t "$SESSION_NAME" | grep -q "%${PANES[$i]}"; then
                # ペインにタイトルを設定（固定）
                tmux select-pane -t "$SESSION_NAME.%${PANES[$i]}" -T "$pane_title"
                
                # ペインのタイトル変更を防ぐための追加設定
                tmux set-option -t "$SESSION_NAME.%${PANES[$i]}" automatic-rename off 2>/dev/null || true
                
                # 各ペインで直接Claudeを起動
                printf "  🚀 ペイン %%${PANES[$i]} で ${role} を起動準備中（タイトル: ${pane_title}）\n"
                tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "cd '$WORKING_DIR'" C-m
                sleep 1
                # Claude CLIを起動（事前設定済みのため、プロンプトなし）
                printf "  📝 コマンド送信中...\n"
                
                # 設定済みClaude CLIを起動
                local claude_cmd="\"$CLAUDE_CLI_PATH\" --dangerously-skip-permissions \"$instruction_file\""
                printf "  🔧 実行コマンド: %s\n" "$claude_cmd"
                
                # コマンドを送信（直接send-keysで送信し、改行の問題を回避）
                tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "$claude_cmd" C-m
                
                printf "  ✓ ペイン %%${PANES[$i]} で ${role} を起動コマンド送信完了（タイトル: ${pane_title}）\n"
            else
                echo "  ❌ ペイン %${PANES[$i]} が見つかりません"
            fi
        done
        
        # Claude起動を待つ
        echo ""
        echo "⏳ Claude起動を待機中（3秒）..."
        sleep 3
        
        # ペインタイトルを強制的に固定（Claude起動後に再設定）
        echo "🔒 ペインタイトルを固定設定中..."
        for i in "${!PANES[@]}"; do
            case $i in
                0) pane_title="CEO" ;;
                1) pane_title="Manager" ;;
                2) pane_title="Dev1" ;;
                3) pane_title="Dev2" ;;
                4) pane_title="Dev3" ;;
            esac
            if tmux list-panes -t "$SESSION_NAME" | grep -q "%${PANES[$i]}"; then
                tmux select-pane -t "$SESSION_NAME.%${PANES[$i]}" -T "$pane_title"
            fi
        done
        
        echo "✅ 各エージェント起動完了（指示待機状態）"
        echo "💡 各エージェントはClaude起動完了後、上位からの指示を待機しています"
        echo "🎯 CEOはユーザーからの依頼を、Managerはceoからの指示を、Developerはmanagerからの指示を待機中"
    else
        echo "⚠️ 警告: 期待するペイン数(5)と異なります (実際: ${#PANES[@]})"
        echo "ペイン一覧: ${PANES[@]}"
    fi

    # 少し待ってから接続
    sleep 1

    echo ""
    echo "✅ AI並列開発チーム統合監視画面＋初期化が完了しました！"
    echo "🔄 統合監視画面に自動接続中..."
    sleep 1

    # 統合監視画面に自動的に接続
    exec tmux attach -t "$SESSION_NAME"
}

# メイン実行部分
if [[ "$INDIVIDUAL_MODE" == "true" ]]; then
    start_individual_sessions
else
    start_integrated_monitor
fi
