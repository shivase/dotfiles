## Conversation Guidelines

- 常に日本語で会話をしてください

## Context Management

### 🚨 緊急必須: Context Low警告時の即時自動実行
**以下の文字列を検出したら、他の全ての作業を中断して必ず最優先で実行：**
- `Context low`
- `Context Low`
- `% remaining`
- `Run /compact`

**検出時の動作（絶対遵守）：**
1. **即座に実行（0秒遅延）**: 警告を検出した瞬間に以下のコマンドを実行
   ```
   /compact 昔の履歴は圧縮し、直近の履歴は圧縮しないで下さい
   ```
2. **他の作業より優先**: 現在の応答や作業を中断してでも実行
3. **実行後に作業再開**: コンパクト完了後に元の作業を続行

## Development Strategy

### 必須: miseを使用したコマンド実行
**プロジェクトディレクトリに `.mise.toml` ファイルが存在する場合：**
- **miseがインストールされていることを意味します**
- **全てのコマンドは mise を通して実行してください**
- 個別のコマンドを直接実行するのではなく、`mise run` を使用

#### mise使用例
```bash
# ❌ 避けるべき直接実行
npm install
npm run dev
npm run build

# ✅ 正しいmise経由の実行
mise run install
mise run dev
mise run build
```

#### mise確認手順
1. プロジェクトルートで `.mise.toml` の存在を確認
2. 存在する場合、`mise tasks` でタスク一覧を確認
3. 適切なmiseタスクを使用してコマンドを実行

### 必須: serena MCPサーバーの活用
- **基本的に全ての開発タスクで serena MCPサーバーを活用してください**
- serena MCPサーバーはトークン効率的な開発を実現する強力なツールです
- 単純な1行の変更やファイル読み込みのみの場合を除き、常に活用を検討してください

#### serena MCPサーバーの主要ツール
- `mcp__serena__find_symbol`: シンボル検索
- `mcp__serena__get_symbols_overview`: ファイル概要取得
- `mcp__serena__search_for_pattern`: パターン検索
- `mcp__serena__replace_symbol_body`: シンボル置換
- `mcp__serena__insert_before_symbol`: シンボル前挿入
- `mcp__serena__insert_after_symbol`: シンボル後挿入

## Agent System Usage

### 必須: 階層的Agent管理システムの使用
**基本的に全てのプロジェクトで PO→Manager→Developer の階層的Agentシステムを使用してください。**

#### 重要: 実行順序の厳守
**必ず以下の順序でAgentを起動してください：**

1. **最初に必ずPO Agentを起動**
   - ユーザーの要求を受け取ったら、まずPO Agentを起動
   - POが戦略を決定し、Managerへの指示を作成
   - serena MCPで俯瞰的にプロジェクトを分析
   
2. **POの指示を受けてManager Agentを起動**
   - POからの戦略的指示をManagerに伝達
   - Managerがタスクを分析し、Developer用の具体的指示を作成
   - serena MCPで詳細な依存関係を分析
   - **重要**: Manager Agentはタスク配分計画のみを返す（Developerは起動しない）
   
3. **Managerの指示に基づきDeveloper Agentsを並列起動**
   - Managerが作成した各タスクを、複数のDeveloperに同時配布
   - Task toolを使って最大4つのDeveloperを同時に起動
   - 各Developerがserena MCPを活用して効率的に実装

#### 並列実行の原則
**エージェント起動時は常に最大限の並列実行を心がけてください：**
- 複数のサブエージェントを起動する際は、**必ず1つのメッセージで同時起動**
- 依存関係のないタスクは**絶対に並列実行**
- 起動漏れを発見したら**即座に追加並列起動**

#### Manager指示の解釈方法
**Manager Agentはタスク配分計画を返すだけで、実際のDeveloper起動はClaude Codeが行います。**

1. **【並列実行可能】** ← 最優先で適用
   - Claude Codeが全てのDeveloperを**必ず1つのメッセージで**同時に起動
   - 例: Manager Agentから「dev1〜dev4を並列実行」という計画を受け取り、Claude Codeが4つを同時にTask起動

2. **【段階的実行】**
   - Claude CodeがManager Agentの段階計画に従って起動
   - **各段階内では必ず並列実行**: 第1段階でdev1,dev2が指定されたら同時起動
   - 第1段階のDeveloper完了後、第2段階を起動

3. **【順次実行】**
   - Claude CodeがManager Agentの順序計画に従って1つずつ起動
   - 前のDeveloper完了を待って次を起動

#### 例外（直接実装してもよい場合）
- 単純なファイル読み込みのみ
- 1行程度の簡単な修正
- 単純な質問への回答
- ファイル一覧の表示

#### Agent起動時の命名規則
```python
# PO Agent起動
Task(
    subagent_type="general-purpose",
    description="PO Agent - 戦略決定",
    prompt="..."
)

# Manager Agent起動
Task(
    subagent_type="general-purpose",
    description="Manager Agent - タスク配分",
    prompt="..."
)

# Developer Agent起動（Managerの計画に基づいてClaude Codeが実行）
Task(
    subagent_type="general-purpose",
    description="Developer1 - フロントエンド実装",
    prompt="..."
)
```

### プロジェクト完了後のクリーンアップ処理
**全てのプロジェクト完了後、必ず以下のクリーンアップ処理を実行してください：**

1. **一時ファイルの削除**
   - Agentが作成した指示書ファイル（*.md、*.txt）
   - 作業中のメモやドラフト
   - 計画書や設計書の下書き

2. **保護すべきファイル**
   - Agent定義ファイル（po-agent.md、manager-agent.md、developer-agent.md）
   - 最終成果物
   - ユーザーが明示的に残すよう指示したファイル

## MCP Servers Usage

### serena（最重要）
- **コードベース分析と操作のための高度なMCPサーバー**
- シンボル検索、パターンマッチング、効率的なコード編集
- `mcp__serena__`プレフィックスで各種ツールを利用

### その他のMCPサーバー
- **context7**: ライブラリドキュメントの取得
- **playwright**: ブラウザ自動操作
- **github**: GitHubリポジトリ操作
- **kagi**: Web検索と要約
- **deepwiki**: GitHubリポジトリのドキュメント理解

## Task Management

### TodoWrite使用時の階層順序
**必ず正しい階層順序でタスクを記録してください：**
1. PO Agentで戦略決定と要件定義
2. Manager Agentでタスク分析と配分計画
3. Developer Agentで具体的な実装作業

#### 間違った例（絶対に避ける）
❌ Developerから直接開始
❌ Manager → PO の逆順

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files.
