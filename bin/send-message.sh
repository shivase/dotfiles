#!/bin/bash

# 🤖 AI並列開発チーム - メッセージ送信システム

# 使用方法表示
show_usage() {
    cat << EOF
🚀 AIチーム メッセージ送信システム

使用方法:
  $0 --session [セッション名] [エージェント名] [メッセージ]
  $0 [エージェント名] [メッセージ]  (デフォルトセッション使用)
  $0 --list [セッション名]
  $0 --list-sessions

オプション:
  --session [名前]  指定したセッション名を使用
  --list [名前]     指定したセッションのエージェント一覧を表示
  --list-sessions   利用可能な全セッション一覧を表示

利用可能エージェント:
  ceo     - 最高経営責任者（全体統括）
  manager - プロジェクトマネージャー（柔軟なチーム管理）
  dev1    - 実行エージェント1（柔軟な役割対応）
  dev2    - 実行エージェント2（柔軟な役割対応）
  dev3    - 実行エージェント3（柔軟な役割対応）
  dev4    - 実行エージェント4（柔軟な役割対応）

使用例:
  $0 --session myproject manager "新しいプロジェクトを開始してください"
  $0 --session ai-team dev1 "【マーケティング担当として】市場調査を実施してください"
  $0 manager "メッセージ"  (デフォルトセッション使用)
  $0 --list myproject      (myprojectセッションのエージェント一覧)
  $0 --list-sessions       (全セッション一覧表示)
EOF
}

# セッション一覧表示
list_all_sessions() {
    echo "📋 利用可能なAIチームセッション一覧:"
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
    
    while read -r session; do
        if [[ -n "$session" ]]; then
            # 統合監視画面の判定（6ペイン構成）
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            if [ "$pane_count" -eq 6 ]; then
                integrated_sessions+=("$session")
            # 個別セッション方式の判定（-ceo, -manager, -dev1-4 で終わる）
            elif [[ "$session" =~ -(ceo|manager|dev[1-4])$ ]]; then
                local base_name="${session%-*}"
                if [[ ! " ${individual_sessions[@]} " =~ " ${base_name} " ]]; then
                    individual_sessions+=("$base_name")
                fi
            fi
        fi
    done <<< "$all_sessions"
    
    # 統合監視画面セッション表示
    if [ ${#integrated_sessions[@]} -gt 0 ]; then
        echo ""
        echo "📺 統合監視画面セッション:"
        for session in "${integrated_sessions[@]}"; do
            echo "  🎯 $session (6ペイン統合画面)"
            echo "    使用例: $0 --session $session ceo \"メッセージ\""
        done
    fi
    
    # 個別セッション方式表示
    if [ ${#individual_sessions[@]} -gt 0 ]; then
        echo ""
        echo "🔄 個別セッション方式:"
        for base_name in "${individual_sessions[@]}"; do
            echo "  📋 $base_name グループ"
            echo "    使用例: $0 --session $base_name manager \"メッセージ\""
        done
    fi
    
    if [ ${#integrated_sessions[@]} -eq 0 ] && [ ${#individual_sessions[@]} -eq 0 ]; then
        echo ""
        echo "ℹ️ AIチーム関連のセッションが見つかりませんでした"
        echo "💡 新しいセッションを作成: ./start-claude.sh [セッション名]"
    fi
}

# 特定セッションのエージェント一覧表示
show_agents() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "❌ エラー: セッション名を指定してください"
        echo "使用方法: $0 --list [セッション名]"
        echo "セッション一覧: $0 --list-sessions"
        return 1
    fi
    
    echo "📋 AIチームメンバー一覧 (セッション: $session_name):"
    echo "=================================================="
    
    # 統合監視画面の状態を確認
    if tmux has-session -t "$session_name" 2>/dev/null; then
        local pane_count=$(tmux list-panes -t "$session_name" 2>/dev/null | wc -l)
        if [ "$pane_count" -eq 6 ]; then
            echo "🎯 統合監視画面（$session_name）使用中:"
            echo "  ceo     → ペイン0    (最高経営責任者)"
            echo "  manager → ペイン1    (プロジェクトマネージャー)"
            echo "  dev1    → ペイン2    (実行エージェント1)"
            echo "  dev2    → ペイン3    (実行エージェント2)"
            echo "  dev3    → ペイン4    (実行エージェント3)"
            echo "  dev4    → ペイン5    (実行エージェント4)"
            echo ""
            echo "現在のペイン状態:"
            tmux list-panes -t "$session_name" -F "  ペイン#{pane_index}: #{pane_title}" 2>/dev/null
        else
            echo "❌ セッション '$session_name' は統合監視画面形式ではありません"
            return 1
        fi
    else
        # 個別セッション方式の確認
        local agents=("ceo" "manager" "dev1" "dev2" "dev3" "dev4")
        local found_sessions=()
        
        for agent in "${agents[@]}"; do
            local full_session="${session_name}-${agent}"
            if tmux has-session -t "$full_session" 2>/dev/null; then
                found_sessions+=("$agent")
            fi
        done
        
        if [ ${#found_sessions[@]} -gt 0 ]; then
            echo "🔄 個別セッション方式（$session_name）:"
            for agent in "${found_sessions[@]}"; do
                case $agent in
                    "ceo") echo "  ceo     → ${session_name}-ceo        (最高経営責任者)" ;;
                    "manager") echo "  manager → ${session_name}-manager    (プロジェクトマネージャー)" ;;
                    "dev1") echo "  dev1    → ${session_name}-dev1       (実行エージェント1)" ;;
                    "dev2") echo "  dev2    → ${session_name}-dev2       (実行エージェント2)" ;;
                    "dev3") echo "  dev3    → ${session_name}-dev3       (実行エージェント3)" ;;
                    "dev4") echo "  dev4    → ${session_name}-dev4       (実行エージェント4)" ;;
                esac
            done
        else
            echo "❌ セッション '$session_name' に関連するAIチームセッションが見つかりません"
            echo "💡 利用可能なセッション一覧: $0 --list-sessions"
            return 1
        fi
    fi
}

# ログ機能
log_message() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] → $agent: \"$message\"" >> logs/communication.log
}

# セッション存在確認
check_session() {
    local session_name="$1"
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ エラー: セッション '$session_name' が見つかりません"
        echo "先に ./start-ai-team.sh を実行してください"
        return 1
    fi
    return 0
}

# 改良版メッセージ送信
send_enhanced_message() {
    local target="$1"
    local message="$2"
    local agent_name="$3"
    
    echo "📤 送信中: $agent_name へメッセージを送信..."
    
    # 1. プロンプトクリア（より確実に）
    tmux send-keys -t "$target" C-c
    sleep 0.4
    
    # 2. 追加のクリア（念のため）
    tmux send-keys -t "$target" C-u
    sleep 0.2
    
    # 3. メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.3
    
    # 4. Enter押下（自動実行）
    tmux send-keys -t "$target" C-m
    sleep 0.5
    
    echo "✅ 送信完了: $agent_name に自動実行されました"
}

# デフォルトセッションを自動検出
detect_default_session() {
    # tmuxセッション一覧を取得
    local all_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "")
    
    if [ -z "$all_sessions" ]; then
        return 1
    fi
    
    # 統合監視画面セッション（6ペイン）を優先
    while read -r session; do
        if [[ -n "$session" ]]; then
            local pane_count=$(tmux list-panes -t "$session" 2>/dev/null | wc -l)
            if [ "$pane_count" -eq 6 ]; then
                echo "$session"
                return 0
            fi
        fi
    done <<< "$all_sessions"
    
    # 個別セッション方式のベース名を探す
    local individual_sessions=()
    while read -r session; do
        if [[ -n "$session" && "$session" =~ -(ceo|manager|dev[1-4])$ ]]; then
            local base_name="${session%-*}"
            if [[ ! " ${individual_sessions[@]} " =~ " ${base_name} " ]]; then
                individual_sessions+=("$base_name")
            fi
        fi
    done <<< "$all_sessions"
    
    if [ ${#individual_sessions[@]} -gt 0 ]; then
        echo "${individual_sessions[0]}"
        return 0
    fi
    
    return 1
}

# メイン処理
main() {
    local session_name=""
    local agent=""
    local message=""
    
    # 引数解析
    while [[ $# -gt 0 ]]; do
        case $1 in
            --session)
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    session_name="$2"
                    shift 2
                else
                    echo "❌ エラー: --session にはセッション名が必要です"
                    show_usage
                    exit 1
                fi
                ;;
            --list)
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    show_agents "$2"
                    exit 0
                else
                    echo "❌ エラー: --list にはセッション名が必要です"
                    echo "使用方法: $0 --list [セッション名]"
                    echo "セッション一覧: $0 --list-sessions"
                    exit 1
                fi
                ;;
            --list-sessions)
                list_all_sessions
                exit 0
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            --*)
                echo "❌ エラー: 不明なオプション $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$agent" ]]; then
                    agent="$1"
                elif [[ -z "$message" ]]; then
                    message="$1"
                else
                    echo "❌ エラー: 引数が多すぎます"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # 引数チェック
    if [[ -z "$agent" ]]; then
        show_usage
        exit 1
    fi
    
    if [[ -z "$message" ]]; then
        echo "❌ エラー: メッセージを指定してください"
        show_usage
        exit 1
    fi
    
    # セッション名が指定されていない場合はデフォルトセッションを検出
    if [[ -z "$session_name" ]]; then
        session_name=$(detect_default_session)
        if [[ -z "$session_name" ]]; then
            echo "❌ エラー: 利用可能なAIチームセッションが見つかりません"
            echo "💡 セッション一覧: $0 --list-sessions"
            echo "💡 新しいセッション作成: ./start-claude.sh [セッション名]"
            exit 1
        fi
        echo "🔍 デフォルトセッション '$session_name' を使用します"
    fi
    
    # 送信先の決定
    local target=""
    
    # 統合監視画面の場合
    if tmux has-session -t "$session_name" 2>/dev/null; then
        local pane_count=$(tmux list-panes -t "$session_name" 2>/dev/null | wc -l)
        if [ "$pane_count" -eq 6 ]; then
            echo "🎯 統合監視画面（$session_name）を使用してメッセージを送信します"
            
            # 固定ペインタイトルを使用したルーティング
            local pane_list=$(tmux list-panes -t "$session_name" -F "#{pane_id}:#{pane_title}" 2>/dev/null)
            
            case $agent in
                "ceo")
                    local ceo_pane=$(echo "$pane_list" | grep ":CEO$" | cut -d: -f1 | head -1)
                    if [[ -n "$ceo_pane" ]]; then
                        target="$session_name.$ceo_pane"
                        echo "📍 CEOペイン（タイトル: CEO）にメッセージを送信"
                    else
                        target="$session_name.0"
                        echo "📍 CEOペイン（ペイン0 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                "manager")
                    local manager_pane=$(echo "$pane_list" | grep ":Manager$" | cut -d: -f1 | head -1)
                    if [[ -n "$manager_pane" ]]; then
                        target="$session_name.$manager_pane"
                        echo "📍 Managerペイン（タイトル: Manager）にメッセージを送信"
                    else
                        target="$session_name.1"
                        echo "📍 Managerペイン（ペイン1 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                "dev1")
                    local dev1_pane=$(echo "$pane_list" | grep ":Dev1$" | cut -d: -f1 | head -1)
                    if [[ -n "$dev1_pane" ]]; then
                        target="$session_name.$dev1_pane"
                        echo "📍 Dev1ペイン（タイトル: Dev1）にメッセージを送信"
                    else
                        target="$session_name.2"
                        echo "📍 Dev1ペイン（ペイン2 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                "dev2")
                    local dev2_pane=$(echo "$pane_list" | grep ":Dev2$" | cut -d: -f1 | head -1)
                    if [[ -n "$dev2_pane" ]]; then
                        target="$session_name.$dev2_pane"
                        echo "📍 Dev2ペイン（タイトル: Dev2）にメッセージを送信"
                    else
                        target="$session_name.3"
                        echo "📍 Dev2ペイン（ペイン3 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                "dev3")
                    local dev3_pane=$(echo "$pane_list" | grep ":Dev3$" | cut -d: -f1 | head -1)
                    if [[ -n "$dev3_pane" ]]; then
                        target="$session_name.$dev3_pane"
                        echo "📍 Dev3ペイン（タイトル: Dev3）にメッセージを送信"
                    else
                        target="$session_name.4"
                        echo "📍 Dev3ペイン（ペイン4 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                "dev4")
                    local dev4_pane=$(echo "$pane_list" | grep ":Dev4$" | cut -d: -f1 | head -1)
                    if [[ -n "$dev4_pane" ]]; then
                        target="$session_name.$dev4_pane"
                        echo "📍 Dev4ペイン（タイトル: Dev4）にメッセージを送信"
                    else
                        target="$session_name.5"
                        echo "📍 Dev4ペイン（ペイン5 - フォールバック）にメッセージを送信"
                    fi
                    ;;
                *)
                    echo "❌ エラー: 無効なエージェント名 '$agent'"
                    echo "利用可能エージェント: $0 --list $session_name"
                    exit 1
                    ;;
            esac
        else
            echo "❌ エラー: セッション '$session_name' は統合監視画面形式ではありません"
            exit 1
        fi
    else
        # 個別セッション方式を使用
        echo "🔄 個別セッション方式（$session_name）を使用してメッセージを送信します"
        
        case $agent in
            "ceo"|"manager"|"dev1"|"dev2"|"dev3"|"dev4")
                local full_session="${session_name}-${agent}"
                if ! check_session "$full_session"; then
                    exit 1
                fi
                target="$full_session"
                ;;
            *)
                echo "❌ エラー: 無効なエージェント名 '$agent'"
                echo "利用可能エージェント: $0 --list $session_name"
                exit 1
                ;;
        esac
    fi
    
    # メッセージ送信
    send_enhanced_message "$target" "$message" "$agent"
    
    # ログ記録
    log_message "$agent" "$message"
    
    echo ""
    echo "🎯 メッセージ詳細:"
    echo "   セッション: $session_name"
    echo "   宛先: $agent ($target)"
    echo "   内容: \"$message\""
    echo "   ログ: logs/communication.log に記録済み"
    
    return 0
}

main "$@" 
