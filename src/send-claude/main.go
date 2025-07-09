package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"sort"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

// 定数定義
const (
	// セッション関連
	IntegratedSessionPaneCount = 6
	LogDir                     = "logs"
	LogFile                    = "communication.log"

	// メッセージ送信での待機時間（ミリ秒）
	ClearDelay           = 400
	AdditionalClearDelay = 200
	MessageDelay         = 300
	ExecuteDelay         = 500

	// エージェント名
	AgentCEO     = "ceo"
	AgentManager = "manager"
	AgentDev1    = "dev1"
	AgentDev2    = "dev2"
	AgentDev3    = "dev3"
	AgentDev4    = "dev4"
)

// データ構造
type Agent struct {
	Name        string
	Description string
}

type Session struct {
	Name  string
	Type  string
	Panes int
}

type SessionManager struct {
	sessions []Session
}

type MessageSender struct {
	sessionName string
	agent       string
	message     string
}

// グローバル変数
var availableAgents = []Agent{
	{AgentCEO, "最高経営責任者（全体統括）"},
	{AgentManager, "プロジェクトマネージャー（柔軟なチーム管理）"},
	{AgentDev1, "実行エージェント1（柔軟な役割対応）"},
	{AgentDev2, "実行エージェント2（柔軟な役割対応）"},
	{AgentDev3, "実行エージェント3（柔軟な役割対応）"},
	{AgentDev4, "実行エージェント4（柔軟な役割対応）"},
}

var validAgentNames = map[string]bool{
	AgentCEO: true, AgentManager: true, AgentDev1: true,
	AgentDev2: true, AgentDev3: true, AgentDev4: true,
}

// コマンド定義
var (
	rootCmd = &cobra.Command{
		Use:   "send-ai-team [agent] [message]",
		Short: "🚀 AIチーム メッセージ送信システム",
		Long: `🚀 AIチーム メッセージ送信システム

tmuxセッション上のAIエージェントにメッセージを送信するツールです。
統合監視画面および個別セッション方式の両方に対応しています。

利用可能エージェント:
  ceo     - 最高経営責任者（全体統括）
  manager - プロジェクトマネージャー（柔軟なチーム管理）
  dev1    - 実行エージェント1（柔軟な役割対応）
  dev2    - 実行エージェント2（柔軟な役割対応）
  dev3    - 実行エージェント3（柔軟な役割対応）
  dev4    - 実行エージェント4（柔軟な役割対応）`,
		Example: `  send-ai-team --session myproject manager "新しいプロジェクトを開始してください"
  send-ai-team --session ai-team dev1 "【マーケティング担当として】市場調査を実施してください"
  send-ai-team manager "メッセージ"  (デフォルトセッション使用)
  send-ai-team list myproject      (myprojectセッションのエージェント一覧)
  send-ai-team list-sessions       (全セッション一覧表示)`,
		Args: cobra.ExactArgs(2),
		RunE: executeMainCommand,
	}

	listCmd = &cobra.Command{
		Use:   "list [session-name]",
		Short: "指定したセッションのエージェント一覧を表示",
		Args:  cobra.ExactArgs(1),
		RunE:  executeListCommand,
	}

	listSessionsCmd = &cobra.Command{
		Use:   "list-sessions",
		Short: "利用可能な全セッション一覧を表示",
		RunE:  executeListSessionsCommand,
	}
)

func init() {
	rootCmd.Flags().StringP("session", "s", "", "指定したセッション名を使用")
	rootCmd.AddCommand(listCmd)
	rootCmd.AddCommand(listSessionsCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Printf("❌ エラー: %v\n", err)
		os.Exit(1)
	}
}

// コマンド実行関数
func executeMainCommand(cmd *cobra.Command, args []string) error {
	agent := args[0]
	message := args[1]
	sessionName, _ := cmd.Flags().GetString("session")

	if !isValidAgent(agent) {
		return fmt.Errorf("無効なエージェント名 '%s'", agent)
	}

	if sessionName == "" {
		detectedSession, err := detectDefaultSession()
		if err != nil {
			return fmt.Errorf("利用可能なAIチームセッションが見つかりません\n💡 セッション一覧: %s list-sessions\n💡 新しいセッション作成: start-ai-team [セッション名]", cmd.Root().Name())
		}
		sessionName = detectedSession
		fmt.Printf("🔍 デフォルトセッション '%s' を使用します\n", sessionName)
	}

	sender := &MessageSender{
		sessionName: sessionName,
		agent:       agent,
		message:     message,
	}

	return sender.Send()
}

func executeListCommand(cmd *cobra.Command, args []string) error {
	sessionName := args[0]
	manager := &SessionManager{}
	return manager.ShowAgentsForSession(sessionName)
}

func executeListSessionsCommand(cmd *cobra.Command, args []string) error {
	manager := &SessionManager{}
	return manager.ListAllSessions()
}

// セッション管理関数
func (sm *SessionManager) ListAllSessions() error {
	fmt.Println("📋 利用可能なAIチームセッション一覧:")
	fmt.Println("==================================")

	sessions, err := getTmuxSessions()
	if err != nil {
		return fmt.Errorf("tmuxセッションの取得に失敗しました: %v", err)
	}

	if len(sessions) == 0 {
		fmt.Println("❌ 起動中のtmuxセッションがありません")
		return nil
	}

	integratedSessions, individualSessions := sm.categorizeSession(sessions)

	sm.displayIntegratedSessions(integratedSessions)
	sm.displayIndividualSessions(individualSessions)

	if len(integratedSessions) == 0 && len(individualSessions) == 0 {
		fmt.Println()
		fmt.Println("ℹ️ AIチーム関連のセッションが見つかりませんでした")
		fmt.Println("💡 新しいセッションを作成: start-ai-team [セッション名]")
	}

	return nil
}

func (sm *SessionManager) categorizeSession(sessions []Session) ([]Session, map[string]bool) {
	integratedSessions := []Session{}
	individualSessions := map[string]bool{}

	for _, session := range sessions {
		paneCount, err := getPaneCount(session.Name)
		if err != nil {
			continue
		}

		if paneCount == IntegratedSessionPaneCount {
			integratedSessions = append(integratedSessions, Session{
				Name:  session.Name,
				Type:  "integrated",
				Panes: paneCount,
			})
		} else if sm.isIndividualSession(session.Name) {
			baseName := sm.extractBaseName(session.Name)
			individualSessions[baseName] = true
		}
	}

	return integratedSessions, individualSessions
}

func (sm *SessionManager) isIndividualSession(sessionName string) bool {
	re := regexp.MustCompile(`-(ceo|manager|dev[1-4])$`)
	return re.MatchString(sessionName)
}

func (sm *SessionManager) extractBaseName(sessionName string) string {
	re := regexp.MustCompile(`-(ceo|manager|dev[1-4])$`)
	return re.ReplaceAllString(sessionName, "")
}

func (sm *SessionManager) displayIntegratedSessions(sessions []Session) {
	if len(sessions) > 0 {
		fmt.Println()
		fmt.Println("📺 統合監視画面セッション:")
		for _, session := range sessions {
			fmt.Printf("  🎯 %s (6ペイン統合画面)\n", session.Name)
			fmt.Printf("    使用例: %s --session %s ceo \"メッセージ\"\n", rootCmd.Name(), session.Name)
		}
	}
}

func (sm *SessionManager) displayIndividualSessions(sessions map[string]bool) {
	if len(sessions) > 0 {
		fmt.Println()
		fmt.Println("🔄 個別セッション方式:")
		var baseNames []string
		for baseName := range sessions {
			baseNames = append(baseNames, baseName)
		}
		sort.Strings(baseNames)
		for _, baseName := range baseNames {
			fmt.Printf("  📋 %s グループ\n", baseName)
			fmt.Printf("    使用例: %s --session %s manager \"メッセージ\"\n", rootCmd.Name(), baseName)
		}
	}
}

func (sm *SessionManager) ShowAgentsForSession(sessionName string) error {
	fmt.Printf("📋 AIチームメンバー一覧 (セッション: %s):\n", sessionName)
	fmt.Println("==================================================")

	if hasSession(sessionName) {
		return sm.showIntegratedSessionAgents(sessionName)
	}

	return sm.showIndividualSessionAgents(sessionName)
}

func (sm *SessionManager) showIntegratedSessionAgents(sessionName string) error {
	paneCount, err := getPaneCount(sessionName)
	if err != nil {
		return fmt.Errorf("セッション '%s' の情報取得に失敗しました: %v", sessionName, err)
	}

	if paneCount == IntegratedSessionPaneCount {
		fmt.Printf("🎯 統合監視画面（%s）使用中:\n", sessionName)
		sm.displayAgentPaneMapping()
		fmt.Println()
		fmt.Println("現在のペイン状態:")
		return showPanes(sessionName)
	}

	return fmt.Errorf("セッション '%s' は統合監視画面形式ではありません", sessionName)
}

func (sm *SessionManager) showIndividualSessionAgents(sessionName string) error {
	foundSessions := []string{}
	for _, agent := range availableAgents {
		fullSession := sessionName + "-" + agent.Name
		if hasSession(fullSession) {
			foundSessions = append(foundSessions, agent.Name)
		}
	}

	if len(foundSessions) > 0 {
		fmt.Printf("🔄 個別セッション方式（%s）:\n", sessionName)
		for _, agentName := range foundSessions {
			agent := findAgentByName(agentName)
			if agent != nil {
				fmt.Printf("  %s → %s-%s (%s)\n",
					agentName, sessionName, agentName, agent.Description)
			}
		}
		return nil
	}

	return fmt.Errorf("セッション '%s' に関連するAIチームセッションが見つかりません\n💡 利用可能なセッション一覧: %s list-sessions", sessionName, rootCmd.Name())
}

func (sm *SessionManager) displayAgentPaneMapping() {
	agentPaneMap := map[string]int{
		AgentCEO: 0, AgentManager: 1, AgentDev1: 2,
		AgentDev2: 3, AgentDev3: 4, AgentDev4: 5,
	}

	for _, agent := range availableAgents {
		paneIndex := agentPaneMap[agent.Name]
		fmt.Printf("  %s → ペイン%d (%s)\n", agent.Name, paneIndex, agent.Description)
	}
}

// メッセージ送信関数
func (ms *MessageSender) Send() error {
	target, err := ms.determineTarget()
	if err != nil {
		return err
	}

	if err := ms.sendEnhancedMessage(target); err != nil {
		return err
	}

	if err := ms.logMessage(); err != nil {
		fmt.Printf("⚠️ ログの記録に失敗しました: %v\n", err)
	}

	ms.displaySummary(target)
	return nil
}

func (ms *MessageSender) determineTarget() (string, error) {
	if hasSession(ms.sessionName) {
		return ms.determineIntegratedTarget()
	}
	return ms.determineIndividualTarget()
}

func (ms *MessageSender) determineIntegratedTarget() (string, error) {
	paneCount, err := getPaneCount(ms.sessionName)
	if err != nil {
		return "", fmt.Errorf("セッション '%s' の情報取得に失敗しました: %v", ms.sessionName, err)
	}

	if paneCount != IntegratedSessionPaneCount {
		return "", fmt.Errorf("セッション '%s' は統合監視画面形式ではありません", ms.sessionName)
	}

	fmt.Printf("🎯 統合監視画面（%s）を使用してメッセージを送信します\n", ms.sessionName)

	paneIndex := ms.getAgentPaneIndex()
	panes, err := getPanes(ms.sessionName)
	if err != nil {
		return "", fmt.Errorf("ペイン情報の取得に失敗しました: %v", err)
	}

	if paneIndex < len(panes) {
		target := fmt.Sprintf("%s.%s", ms.sessionName, panes[paneIndex])
		fmt.Printf("📍 %sペイン（ペイン%s）にメッセージを送信\n", ms.agent, panes[paneIndex])
		return target, nil
	}

	target := fmt.Sprintf("%s.%d", ms.sessionName, paneIndex)
	fmt.Printf("📍 %sペイン（ペイン%d - フォールバック）にメッセージを送信\n", ms.agent, paneIndex)
	return target, nil
}

func (ms *MessageSender) determineIndividualTarget() (string, error) {
	fmt.Printf("🔄 個別セッション方式（%s）を使用してメッセージを送信します\n", ms.sessionName)

	fullSession := ms.sessionName + "-" + ms.agent
	if !hasSession(fullSession) {
		return "", fmt.Errorf("セッション '%s' が見つかりません", fullSession)
	}

	return fullSession, nil
}

func (ms *MessageSender) getAgentPaneIndex() int {
	agentPaneMap := map[string]int{
		AgentCEO: 0, AgentManager: 1, AgentDev1: 2,
		AgentDev2: 3, AgentDev3: 4, AgentDev4: 5,
	}
	return agentPaneMap[ms.agent]
}

func (ms *MessageSender) sendEnhancedMessage(target string) error {
	fmt.Printf("📤 送信中: %s へメッセージを送信...\n", ms.agent)

	// プロンプトクリア
	if err := tmuxSendKeys(target, "C-c"); err != nil {
		return fmt.Errorf("プロンプトクリアに失敗しました: %v", err)
	}
	time.Sleep(time.Duration(ClearDelay) * time.Millisecond)

	// 追加のクリア
	if err := tmuxSendKeys(target, "C-u"); err != nil {
		return fmt.Errorf("追加クリアに失敗しました: %v", err)
	}
	time.Sleep(time.Duration(AdditionalClearDelay) * time.Millisecond)

	// メッセージ送信
	if err := tmuxSendKeys(target, ms.message); err != nil {
		return fmt.Errorf("メッセージ送信に失敗しました: %v", err)
	}
	time.Sleep(time.Duration(MessageDelay) * time.Millisecond)

	// Enter押下
	if err := tmuxSendKeys(target, "C-m"); err != nil {
		return fmt.Errorf("実行に失敗しました: %v", err)
	}
	time.Sleep(time.Duration(ExecuteDelay) * time.Millisecond)

	fmt.Printf("✅ 送信完了: %s に自動実行されました\n", ms.agent)
	return nil
}

func (ms *MessageSender) logMessage() error {
	if err := os.MkdirAll(LogDir, 0755); err != nil {
		return fmt.Errorf("ログディレクトリの作成に失敗しました: %v", err)
	}

	timestamp := time.Now().Format("2006-01-02 15:04:05")
	logEntry := fmt.Sprintf("[%s] → %s: \"%s\"\n", timestamp, ms.agent, ms.message)

	file, err := os.OpenFile(LogDir+"/"+LogFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("ログファイルのオープンに失敗しました: %v", err)
	}
	defer file.Close()

	if _, err = file.WriteString(logEntry); err != nil {
		return fmt.Errorf("ログの書き込みに失敗しました: %v", err)
	}

	return nil
}

func (ms *MessageSender) displaySummary(target string) {
	fmt.Println()
	fmt.Println("🎯 メッセージ詳細:")
	fmt.Printf("   セッション: %s\n", ms.sessionName)
	fmt.Printf("   宛先: %s (%s)\n", ms.agent, target)
	fmt.Printf("   内容: \"%s\"\n", ms.message)
	fmt.Printf("   ログ: %s/%s に記録済み\n", LogDir, LogFile)
}

// ユーティリティ関数
func isValidAgent(agent string) bool {
	return validAgentNames[agent]
}

func findAgentByName(name string) *Agent {
	for _, agent := range availableAgents {
		if agent.Name == name {
			return &agent
		}
	}
	return nil
}

func getTmuxSessions() ([]Session, error) {
	cmd := exec.Command("tmux", "list-sessions", "-F", "#{session_name}")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("tmuxセッション一覧の取得に失敗しました: %v", err)
	}

	var sessions []Session
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			sessions = append(sessions, Session{Name: line})
		}
	}

	return sessions, nil
}

func hasSession(sessionName string) bool {
	cmd := exec.Command("tmux", "has-session", "-t", sessionName)
	return cmd.Run() == nil
}

func getPaneCount(sessionName string) (int, error) {
	cmd := exec.Command("tmux", "list-panes", "-t", sessionName)
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("ペイン数の取得に失敗しました: %v", err)
	}
	return len(strings.Split(strings.TrimSpace(string(output)), "\n")), nil
}

func getPanes(sessionName string) ([]string, error) {
	cmd := exec.Command("tmux", "list-panes", "-t", sessionName, "-F", "#{pane_index}")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("ペイン一覧の取得に失敗しました: %v", err)
	}

	var panes []string
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			panes = append(panes, line)
		}
	}
	return panes, nil
}

func showPanes(sessionName string) error {
	cmd := exec.Command("tmux", "list-panes", "-t", sessionName, "-F", "  ペイン#{pane_index}: #{pane_title}")
	output, err := cmd.Output()
	if err != nil {
		return fmt.Errorf("ペイン状態の表示に失敗しました: %v", err)
	}
	fmt.Print(string(output))
	return nil
}

func tmuxSendKeys(target, keys string) error {
	cmd := exec.Command("tmux", "send-keys", "-t", target, keys)
	return cmd.Run()
}

func detectDefaultSession() (string, error) {
	sessions, err := getTmuxSessions()
	if err != nil || len(sessions) == 0 {
		return "", fmt.Errorf("tmuxセッションが見つかりません")
	}

	// 統合監視画面セッション（6ペイン）を優先
	for _, session := range sessions {
		paneCount, err := getPaneCount(session.Name)
		if err != nil {
			continue
		}
		if paneCount == IntegratedSessionPaneCount {
			return session.Name, nil
		}
	}

	// 個別セッション方式のベース名を探す
	individualSessions := map[string]bool{}
	re := regexp.MustCompile(`-(ceo|manager|dev[1-4])$`)
	for _, session := range sessions {
		if re.MatchString(session.Name) {
			baseName := re.ReplaceAllString(session.Name, "")
			individualSessions[baseName] = true
		}
	}

	if len(individualSessions) > 0 {
		var baseNames []string
		for baseName := range individualSessions {
			baseNames = append(baseNames, baseName)
		}
		sort.Strings(baseNames)
		return baseNames[0], nil
	}

	return "", fmt.Errorf("AIチーム関連のセッションが見つかりません")
}
