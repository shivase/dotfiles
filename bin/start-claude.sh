#!/bin/bash

# 🤖 AI並列開発チーム - 統合起動スクリプト (start-claude.sh)

# 使用方法表示
show_usage() {
    cat << EOF
🚀 AI並列開発チーム - 統合起動システム

使用方法:
  $0 [セッション名] [オプション]

引数:
  セッション名      tmuxセッション名（デフォルト: ai-team）
  
オプション:
  --reset          既存セッションを削除して再作成
  --individual     個別セッション方式で起動（統合監視画面なし）
  --help           このヘルプを表示

例:
  $0                          # ai-teamセッションで統合監視画面起動
  $0 myproject               # myprojectセッションで統合監視画面起動
  $0 myproject --reset       # myprojectセッションを再作成
  $0 myproject --individual  # myprojectで個別セッション方式起動

EOF
}

# スクリプトの場所を取得（任意のフォルダから実行されても対応）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKING_DIR="$(pwd)"

# デフォルト値
SESSION_NAME="ai-team"
RESET_MODE=false
INDIVIDUAL_MODE=false

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
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
            if [[ -z "$SESSION_NAME" || "$SESSION_NAME" == "ai-team" ]]; then
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

echo "🚀 AI並列開発チーム統合起動システム"
echo "📁 作業ディレクトリ: $WORKING_DIR"
echo "📁 スクリプト場所: $SCRIPT_DIR"
echo "📋 セッション名: $SESSION_NAME"

# セッション名のバリデーション
if [[ ! "$SESSION_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ エラー: セッション名は英数字、ハイフン、アンダースコアのみ使用可能です"
    exit 1
fi

# Claude CLIの認証状態確認
check_claude_auth() {
    echo "🔐 Claude認証状態を確認中..."
    
    # claude --version を実行して認証状態を確認
    if timeout 3 claude --version > /dev/null 2>&1; then
        echo "  ✅ Claude認証済み"
        return 0
    else
        echo "  ⚠️ Claude認証が必要な可能性があります"
        return 1
    fi
}

# 認証チェック実行
AUTH_OK=false
if check_claude_auth; then
    AUTH_OK=true
fi

# 必要なインストラクションファイルが存在するかチェック
echo "📂 インストラクションファイルをチェック中..."
missing_count=0

# ceo.md のチェック
if [ ! -f "$SCRIPT_DIR/instructions/ceo.md" ]; then
    echo "❌ エラー: $SCRIPT_DIR/instructions/ceo.md が見つかりません"
    missing_count=$((missing_count + 1))
fi

# manager.md のチェック
if [ ! -f "$SCRIPT_DIR/instructions/manager.md" ]; then
    echo "❌ エラー: $SCRIPT_DIR/instructions/manager.md が見つかりません"
    missing_count=$((missing_count + 1))
fi

# developer.md のチェック
if [ ! -f "$SCRIPT_DIR/instructions/developer.md" ]; then
    echo "❌ エラー: $SCRIPT_DIR/instructions/developer.md が見つかりません"
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
                inst_file="$SCRIPT_DIR/instructions/ceo.md"
            elif [[ "$agent" == "manager" ]]; then
                inst_file="$SCRIPT_DIR/instructions/manager.md"
            else
                inst_file="$SCRIPT_DIR/instructions/developer.md"
            fi
            
            if [[ "$AUTH_OK" == "true" ]]; then
                tmux send-keys -t "$session" "claude --dangerously-skip-permissions '$inst_file'" C-m
            else
                tmux send-keys -t "$session" "claude --dangerously-skip-permissions '$inst_file'" C-m
                sleep 2
                # 認証プロンプト処理
                tmux send-keys -t "$session" "1" C-m
                sleep 1
                tmux send-keys -t "$session" "1" C-m
                sleep 1
                tmux send-keys -t "$session" C-m
            fi
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
    echo "💡 メッセージ送信: ./send-message.sh --session $SESSION_NAME [エージェント] [メッセージ]"
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
            
            # 既存のClaude CLIプロセスをクリーンアップ
            echo "🧹 既存のClaude CLIプロセスをクリーンアップ中..."
            pkill -f "claude.*--dangerously-skip-permissions" 2>/dev/null || true
            sleep 2
        else
            echo "📺 既存の${SESSION_NAME}セッションに接続中..."
            echo ""
            echo "✅ AI並列開発チーム統合監視画面に接続します！"
            echo ""
            echo "🎯 操作方法:"
            echo "・各ペインでの操作: Ctrl+B → ↑↓←→ で移動"
            echo "・ペインタイトルが上部に表示されます"
            echo "・各ペインで直接Claudeと対話可能"
            echo "・監視画面終了: Ctrl+B → d (デタッチ)"
            echo "・完全終了: tmux kill-session -t $SESSION_NAME"
            echo ""
            echo "💡 ヒント: セッションを作り直したい場合は '$0 $SESSION_NAME --reset' を実行してください"
            echo "💡 メッセージ送信: ./send-message.sh --session $SESSION_NAME [エージェント] [メッセージ]"
            echo ""
            echo "🔄 統合監視画面に自動接続中..."
            sleep 1
            
            # 既存セッションに接続
            exec tmux attach -t "$SESSION_NAME"
        fi
    else
        echo "📝 新規${SESSION_NAME}セッション作成準備中..."
        
        # 既存のClaude CLIプロセスをクリーンアップ
        echo "🧹 既存のClaude CLIプロセスをクリーンアップ中..."
        pkill -f "claude.*--dangerously-skip-permissions" 2>/dev/null || true
        sleep 2
    fi
    
    # テーマを事前設定（プロンプトを回避）
    if [[ "$AUTH_OK" == "false" ]]; then
        echo "🎨 Claudeテーマを事前設定中..."
        claude config set -g theme dark 2>/dev/null || true
    fi
    
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
    
    # 4. 右下を上下分割（Dev2、Dev3）
    tmux split-window -v -t "$SESSION_NAME.3"
    echo "  ✓ 右下を上下分割完了（Dev2、Dev3）"
    
    # 5. 右下下部をさらに分割（Dev3のため）
    tmux split-window -v -t "$SESSION_NAME.4"
    echo "  ✓ Dev3用の分割完了"
    
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
                    instruction_file="$SCRIPT_DIR/instructions/ceo.md"
                    ;;
                1) 
                    role="Manager"
                    pane_title="Manager"
                    instruction_file="$SCRIPT_DIR/instructions/manager.md"
                    ;;
                2) 
                    role="Dev1"
                    pane_title="Dev1"
                    instruction_file="$SCRIPT_DIR/instructions/developer.md"
                    ;;
                3) 
                    role="Dev2"
                    pane_title="Dev2"
                    instruction_file="$SCRIPT_DIR/instructions/developer.md"
                    ;;
                4) 
                    role="Dev3"
                    pane_title="Dev3"
                    instruction_file="$SCRIPT_DIR/instructions/developer.md"
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
                tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "claude --dangerously-skip-permissions '$instruction_file'" C-m
                
                if [[ "$AUTH_OK" == "false" ]]; then
                    # プロンプトを自動で処理するために少し待ってからキーを送信
                    sleep 3
                    # アカウント選択: 1を選択（Claude account with subscription）
                    tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "1" C-m
                    sleep 2
                    # テーマ選択: 1を選択（Dark mode）
                    tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "1" C-m
                    sleep 1
                    # ログイン確認: Enterを押す
                    tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" C-m
                    sleep 1
                fi
                
                printf "  ✓ ペイン %%${PANES[$i]} で ${role} を起動コマンド送信完了（タイトル: ${pane_title}）\n"
            else
                echo "  ❌ ペイン %${PANES[$i]} が見つかりません"
            fi
        done
        
        # Claude起動を待ってから初期化メッセージを送信
        echo ""
        if [[ "$AUTH_OK" == "true" ]]; then
            echo "⏳ Claude起動を待機中（10秒）..."
            sleep 10
        else
            echo "⏳ Claude起動とプロンプト処理を待機中（15秒）..."
            sleep 15
        fi
        
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
        
        echo "🎯 各エージェントを初期化中..."
        
        # 各ペインに初期化メッセージを送信
        for i in "${!PANES[@]}"; do
            case $i in
                0) # CEO
                    init_message="あなたは最高経営責任者（CEO）です。$SCRIPT_DIR/instructions/ceo.mdの内容に従って動作してください。

⚠️ 絶対に守るべき原則：
- 自分で直接作業やコーディングを行ってはいけません
- 全ての実行作業は必ずmanagerに委任してください
- 一人で問題解決しようとせず、チームを活用してください

あなたの役割：
- 戦略決定と方針策定
- managerへの明確な指示
- 最終成果物の承認

ユーザーからの依頼を待っています。"
                    ;;
                1) # Manager
                    init_message="あなたは柔軟なプロジェクトマネージャーです。$SCRIPT_DIR/instructions/manager.mdの内容に従って動作してください。

⚠️ 重要な役割認識：
- あなたはプロジェクトマネージャーであり、CEOではありません
- CEOからの指示を受けて行動する立場です
- 最終決定権はCEOにあります

重要なポイント：
- プロジェクトの性質に応じて各エージェントに最適な役割を動的に配分する
- エージェントからの完了報告を受けたら必ず次のアクションを実行する
- 開発からマーケティング、企画まで幅広いプロジェクトに対応

CEOからの指示を待っています。"
                    ;;
                2) # Dev1
                    init_message="あなたは柔軟な実行エージェントです。$SCRIPT_DIR/instructions/developer.mdの内容に従って動作してください。

重要なポイント：
- managerから割り当てられた役割に応じて専門性を発揮する
- 開発、マーケティング、企画など様々な役割に適応可能
- タスク完了時は必ずmanagerに「【完了報告】」を送信する

managerからの役割割り当てを待っています。"
                    ;;
                3) # Dev2
                    init_message="あなたは柔軟な実行エージェントです。$SCRIPT_DIR/instructions/developer.mdの内容に従って動作してください。

重要なポイント：
- managerから割り当てられた役割に応じて専門性を発揮する
- 開発、データ分析、戦略立案など様々な役割に適応可能
- タスク完了時は必ずmanagerに「【完了報告】」を送信する

managerからの役割割り当てを待っています。"
                    ;;
                4) # Dev3
                    init_message="あなたは柔軟な実行エージェントです。$SCRIPT_DIR/instructions/developer.mdの内容に従って動作してください。

重要なポイント：
- managerから割り当てられた役割に応じて専門性を発揮する
- 品質管理、リサーチ、運営管理など様々な役割に適応可能
- タスク完了時は必ずmanagerに「【完了報告】」を送信する

managerからの役割割り当てを待っています。"
                    ;;
            esac
            
            # 初期化メッセージを送信
            if tmux list-panes -t "$SESSION_NAME" | grep -q "%${PANES[$i]}"; then
                tmux send-keys -t "$SESSION_NAME.%${PANES[$i]}" "$init_message" C-m
                echo "  ✓ ペイン %${PANES[$i]} の初期化完了"
            fi
        done
    else
        echo "⚠️ 警告: 期待するペイン数(5)と異なります (実際: ${#PANES[@]})"
        echo "ペイン一覧: ${PANES[@]}"
    fi
    
    # 少し待ってから接続
    sleep 1
    
    echo ""
    echo "✅ AI並列開発チーム統合監視画面＋初期化が完了しました！"
    echo ""
    echo "📊 レイアウト構成（各ペインにタイトル表示）:"
    echo "┌─────────────────────┬───────────────────────────────┐"
    echo "│         CEO         │           Dev1                │"
    echo "├─────────────────────┼───────────────────────────────┤"
    echo "│                     │           Dev2                │"
    echo "│       Manager       ├───────────────────────────────┤"
    echo "│                     │           Dev3                │"
    echo "└─────────────────────┴───────────────────────────────┘"
    echo ""
    echo "🎯 操作方法:"
    echo "・各ペインでの操作: Ctrl+B → ↑↓←→ で移動"
    echo "・ペインタイトルが上部に表示されます"
    echo "・各ペインで直接Claudeと対話可能"
    echo "・監視画面終了: Ctrl+B → d (デタッチ)"
    echo "・完全終了: tmux kill-session -t $SESSION_NAME"
    echo ""
    echo "✨ 特徴:"
    echo "・一つのtmuxセッション内で5つのAIエージェントが動作"
    echo "・各ペインに役割名（CEO、Manager、Dev1、Dev2、Dev3）が表示"
    echo "・tmuxのネストなし、直接操作可能"
    echo "・各エージェントは自動的に初期化済み"
    echo ""
    echo "💡 メッセージ送信: ./send-message.sh --session $SESSION_NAME [エージェント] [メッセージ]"
    echo ""
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