## Conversation Guidelines

- 常に日本語で会話をしてください

## Context Management

- 会話が長くなりコンテキストの圧縮が必要な場合は、`/compact 昔の履歴は圧縮し、直近の履歴は圧縮しないで下さい` コマンドを実行してください
- このコマンドはClaude Codeの組み込みコマンドで、古い会話履歴を圧縮しながら最近の会話は詳細を保持します
- Context Lowの警告が表示された場合は、すぐに実行することを推奨します

## Development Strategy

### 必須: serena-expert エージェントの活用
- **基本的に全ての開発タスクで `serena-expert` エージェントを Task ツールで起動してください**
- `serena-expert` は `/serena` コマンドを内部的に使用し、トークン効率的な開発を実現します
- 以下のような場面では特に必須です：
  - 新しいコンポーネントやモジュールの設計・実装
  - アーキテクチャの設計や大規模なリファクタリング
  - 複数ファイルにまたがる機能の実装
  - システム設計やAPI設計が必要なタスク
  - コードの調査や理解が必要なタスク
- **単純な1行の変更やファイル読み込みのみの場合を除き、常に `serena-expert` エージェントを活用してください**

## Agent System Usage

### 必須: 階層的Agent管理システムの使用
**基本的に全てのプロジェクトで PO→Manager→Developer→serena-expert の階層的Agentシステムを使用してください。**

#### 重要: 実行順序の厳守
**必ず以下の順序でAgentを起動してください：**

1. **最初に必ずPO Agentを起動**
   - ユーザーの要求を受け取ったら、まずPO Agentを起動
   - POが戦略を決定し、Managerへの指示を作成
   
2. **POの指示を受けてManager Agentを起動**
   - POからの戦略的指示をManagerに伝達
   - Managerがタスクを分析し、Developer用の具体的指示を作成
   
3. **Managerの指示に基づきDeveloper Agentsを並列起動**
   - Managerが作成した各タスクを、複数のDeveloperに同時配布
   - Task toolを使って最大4つのDeveloperを同時に起動

#### 必ず使用する場面
- **全ての開発プロジェクト**: 規模に関わらず階層的管理を適用
- **複数の要素がある作業**: 2つ以上の独立した要素がある場合
- **調査・分析・実装の組み合わせ**: 異なる性質のタスクが混在する場合
- **品質が重要な作業**: テストやレビューを含む作業

#### 例外（直接実装してもよい場合）
- 単純なファイル読み込みのみ
- 1行程度の簡単な修正
- 単純な質問への回答
- ファイル一覧の表示

#### 実行フロー（厳守）
1. **戦略決定フェーズ**: 最初にPOエージェントを起動し、プロジェクト全体の戦略を決定
2. **タスク配分フェーズ**: POの出力を受けてManagerエージェントを起動、依存関係を分析
3. **実行フェーズ**: Managerの指示に従って適切にDeveloperエージェントを起動
   - **【並列実行可能】の場合**: 指定された全Developerを同時起動
   - **【段階的実行】の場合**: 各段階ごとに指定されたDeveloperを起動
   - **【順次実行】の場合**: 1つずつ順番にDeveloperを起動
4. **統合フェーズ**: 完了報告を収集し、必要に応じて次段階のタスクを実行

#### Developerの役割分担パターン
- **開発プロジェクト**: フロントエンド、バックエンド、テスト、インフラ（各Developerがserena-expertエージェントを起動）
- **マーケティング**: 市場調査、競合分析、コンテンツ戦略、予算計画（必要に応じてserena-expertを活用）
- **データ分析**: データ収集、前処理、分析、可視化（各Developerがserena-expertエージェントを起動）
- **コンテンツ制作**: 企画、執筆、デザイン、レビュー（必要に応じてserena-expertを活用）
- **単一タスクでも4分割**: 1つのタスクも可能な限り4つの観点に分割して並列処理

#### 効果的な活用例
- **Webアプリ開発**: UI、API、DB、テストを並列開発
- **マーケティング企画**: 市場調査、競合分析、戦略立案、予算計画を並列実行
- **データ分析**: データ収集、前処理、分析、可視化を段階的に実行
- **ドキュメント作成**: 調査、執筆、レビュー、整形を役割分担

#### 実装方針
- **起動順序の絶対厳守**: 必ず PO → Manager → Developer の順序で起動
- **POを最初に起動**: ユーザーの要求を受けたら、まず必ずPO Agentを起動
- **Managerの指示に従う**: Managerが出力する実行戦略（並列/段階的/順次）に必ず従う
- **依存関係の尊重**: テストは実装後、ドキュメントは完成後など、論理的な順序を守る
- **serena-expert エージェントの活用**: 各Developerが必要に応じて serena-expert エージェントを起動
- **直接実装は最小限**: よほど単純な作業（1行修正、ファイル表示等）以外は必ずAgentシステムを使用

#### Manager指示の解釈方法
Managerは以下の3種類の実行戦略を返します：

1. **【並列実行可能】**
   - 全てのDeveloperを同時に起動
   - 例: dev1〜dev4を1つのメッセージで同時にTask起動

2. **【段階的実行】**
   - 各段階の指示に従って起動
   - 第1段階のDeveloper完了後、第2段階を起動
   - 例: 第1段階でdev1,dev2を並列起動 → 完了後に第2段階でdev3,dev4を起動

3. **【順次実行】**
   - 指定された順序で1つずつ起動
   - 前のDeveloper完了を待って次を起動
   - 例: dev1完了 → dev2起動 → dev2完了 → dev3起動

#### システムの特徴
- **自動的な依存関係管理**: Managerが自動でタスクの依存関係を分析
- **動的な役割割り当て**: プロジェクトの性質に応じてDeveloperの役割を柔軟に変更
- **並列処理の最適化**: 独立したタスクを自動識別し、最大4つまで同時実行
- **serena-expert による開発効率化**: 各Developerが serena-expert を起動してトークン効率的な実装を実現

#### コンテキスト管理の重要性
**各Agentは状態を持たないため、必ず前回のコンテキストを含めて起動してください：**

1. **PO Agent起動時**
   - 初回：ユーザーの要求のみを渡す
   - 2回目以降：前回のPO指示 + Managerの実行結果を渡す

2. **Manager Agent起動時**
   - 初回：POの指示を渡す
   - Developer完了後：POの元指示 + 各Developerの完了状況を渡す

3. **Developer Agent起動時**
   - 常にManagerからのタスク指示全体を渡す
   - 段階的実行の場合：前段階の完了内容も含める

#### コンテキスト伝達の例
```
# PO再起動時のプロンプト例
前回のPO指示：
[プロジェクト開始指示の内容]

Managerからの実行結果：
[プロジェクト完了報告の内容]

この結果を確認して承認または修正指示を出してください。
```

#### Agent起動時の命名規則
**各Agentを明確に識別できるように、descriptionを適切に設定してください：**

```python
# PO Agent起動
Task(
    subagent_type="general-purpose",  # serena-expertではなくgeneral-purpose
    description="PO Agent - 戦略決定",  # "PO Agent"を必ず含める
    prompt="..."
)

# Manager Agent起動
Task(
    subagent_type="general-purpose",
    description="Manager Agent - タスク配分",  # "Manager Agent"を必ず含める
    prompt="..."
)

# Developer Agent起動
Task(
    subagent_type="general-purpose",
    description="Developer1 - フロントエンド実装",  # Developer番号を明記
    prompt="..."
)
Task(
    subagent_type="general-purpose",
    description="Developer2 - バックエンド実装",
    prompt="..."
)
```

**重要：**
- PO、Manager、Developerは `general-purpose` を使用
- `serena-expert` は各Developer内部で必要時のみ使用
- descriptionに役割名を必ず含める（PO Agent、Manager Agent、Developer1-4）

### serena-expert エージェントの特徴
- **自動 /serena 使用**: 開発タスクを認識して自動的に /serena コマンドを活用
- **トークン最適化**: テンプレートベースの開発で最小限のトークンで最大の成果
- **品質保証**: エラーハンドリング、テスト、セキュリティを標準装備
- **フレームワーク専門知識**: React、Next.js、Node.js、Python等の深い知識

## MCP Servers Usage

以下のMCPサーバーを状況に応じて積極的に活用してください：

### context7
- ライブラリやフレームワークの最新ドキュメントが必要な場合に使用
- 実装前に`resolve-library-id`でライブラリIDを解決してから`get-library-docs`でドキュメントを取得

### playwright
- Webアプリケーションのテストやスクレイピングが必要な場合に使用
- ブラウザ操作の自動化、UIテスト、スクリーンショット取得などに活用

### github
- GitHubリポジトリの操作、Issue/PR管理、コード検索が必要な場合に使用
- `search_code`でコード検索、`create_pull_request`でPR作成など
- Copilotレビューの依頼も`request_copilot_review`で可能

### kagi
- Web検索や情報収集が必要な場合に使用
- `kagi_search_fetch`で検索、`kagi_summarizer`でWebページの要約を取得

### deepwiki
- GitHubリポジトリのドキュメントや仕様を理解する必要がある場合に使用
- `read_wiki_structure`で構造確認、`ask_question`で質問による情報取得

### jetbrains (IDE連携)
- JetBrains IDEと連携している場合、IDE内のコンテキストを活用

これらのツールを組み合わせることで、より効率的で正確な開発支援が可能になります。
