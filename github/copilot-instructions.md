# GitHub Copilot グローバル設定

## 基本設定

### 会話言語
- 常に日本語で会話をしてください

## 開発戦略 - 3層思考プロセス

### 🎯 PO（プロダクトオーナー）視点での戦略立案

プロジェクト開始時は、まずPO視点で戦略的に考えてください：

1. **プロジェクト全体の俯瞰的分析**
   - serena MCPツール（`mcp__serena__list_dir`、`mcp__serena__get_symbols_overview`）でプロジェクト構造を把握
   - 技術スタック、アーキテクチャの理解
   - ビジネス要件と技術的制約の把握

2. **戦略決定**
   - プロジェクトの最終ゴールを明確化
   - 成功基準と品質基準の設定
   - リスクと制約事項の特定

3. **実行方針の策定**
   - 大まかな実行フェーズの定義
   - 優先順位の決定
   - 期待される成果物の明確化

### 📋 Manager視点でのタスク分解と計画

戦略が決まったら、Manager視点でタスクを分解してください：

1. **詳細な依存関係分析**
   - serena MCPツール（`mcp__serena__find_symbol`、`mcp__serena__find_referencing_symbols`）で依存関係を調査
   - タスク間の前後関係を明確化
   - ボトルネックとなる箇所の特定

2. **実行計画の作成**
   ```
   【実行計画】
   第1段階（並列実行可能）：
   - タスク1: [詳細内容]
   - タスク2: [詳細内容]

   第2段階（第1段階完了後）：
   - タスク3: [詳細内容]

   第3段階（テスト・検証）：
   - タスク4: [詳細内容]
   ```

3. **タスクの優先度と順序**
   - **並列実行可能**: 独立したタスク（調査、別コンポーネント開発など）
   - **段階的実行**: 依存関係のあるタスク（実装→テスト→ドキュメント）
   - **順次実行**: 強い依存関係（要件定義→設計→実装）

### 🔧 Developer視点での実装

各タスクを実行する際は、Developer視点で実装してください：

1. **実装前の準備**
   - serena MCPで既存コードの理解（`mcp__serena__get_symbols_overview`）
   - 必要なライブラリ・フレームワークの確認
   - コーディング規約の確認

2. **効率的な実装**
   - serenaツールで効率的にコード操作：
     - `mcp__serena__find_symbol`: シンボル検索
     - `mcp__serena__replace_symbol_body`: シンボル置換
     - `mcp__serena__insert_before_symbol`: インポート追加
     - `mcp__serena__insert_after_symbol`: 新規関数追加
   - 既存パターンとライブラリを活用
   - エラーハンドリングの適切な実装

3. **品質確保**
   - テストの実行（npm run test、pytestなど）
   - Lint実行（npm run lint、ruffなど）
   - 型チェック（npm run typecheckなど）

## MCPサーバーの活用

### serena（最重要 - トークン効率的な開発）
**基本的にすべての開発タスクでserena MCPサーバーを活用してください。**

#### 主要コマンド
- `mcp__serena__list_dir`: ディレクトリ構造の把握
- `mcp__serena__get_symbols_overview`: ファイル概要取得
- `mcp__serena__find_symbol`: シンボル検索（関数、クラス、変数）
- `mcp__serena__search_for_pattern`: パターン検索
- `mcp__serena__find_referencing_symbols`: 依存関係分析
- `mcp__serena__replace_symbol_body`: シンボル本体置換
- `mcp__serena__insert_before_symbol`: シンボル前挿入
- `mcp__serena__insert_after_symbol`: シンボル後挿入

#### 使用例
```python
# プロジェクト構造の把握
mcp__serena__list_dir(relative_path=".", recursive=True)

# クラス定義の検索
mcp__serena__find_symbol(name_path="UserController", include_body=True)

# 依存関係の調査
mcp__serena__find_referencing_symbols(
    name_path="authenticate",
    relative_path="src/auth.py"
)

# 関数の効率的な置換
mcp__serena__replace_symbol_body(
    name_path="process_data",
    relative_path="src/processor.py",
    body="def process_data(data):\n    # 新しい実装\n    return data"
)
```

### その他のMCPサーバー

#### context7（ライブラリドキュメント）
- `mcp__context7__resolve-library-id`: ライブラリID検索
- `mcp__context7__get-library-docs`: ドキュメント取得

#### playwright（ブラウザ自動化）
- `mcp__playwright__browser_navigate`: URL遷移
- `mcp__playwright__browser_snapshot`: ページスナップショット
- `mcp__playwright__browser_click`: 要素クリック
- `mcp__playwright__browser_type`: テキスト入力

#### github（GitHubリポジトリ操作）
- `mcp__github__search_repositories`: リポジトリ検索
- `mcp__github__get_file_contents`: ファイル内容取得
- `mcp__github__create_pull_request`: PR作成
- `mcp__github__list_issues`: Issue一覧

#### kagi（Web検索・要約）
- `mcp__kagi__kagi_search_fetch`: Web検索
- `mcp__kagi__kagi_summarizer`: URL要約

#### deepwiki（GitHubドキュメント）
- `mcp__deepwiki__read_wiki_structure`: Wiki構造取得
- `mcp__deepwiki__ask_question`: リポジトリに関する質問

## 作業フローの例

### 新機能実装の場合
```markdown
1. PO視点：要件分析と戦略決定
   - プロジェクト構造の把握（serena）
   - 影響範囲の特定
   - 実装方針の決定

2. Manager視点：タスク分解
   - データベーススキーマ設計
   - API実装
   - フロントエンド実装
   - テスト作成
   - ドキュメント更新

3. Developer視点：順次実装
   - 第1段階：DB設計とAPI実装（並列可能）
   - 第2段階：フロントエンド実装
   - 第3段階：テストとドキュメント（並列可能）
```

### バグ修正の場合
```markdown
1. PO視点：問題分析
   - バグの影響範囲確認
   - 修正優先度の決定

2. Manager視点：調査と計画
   - serenaで関連コード検索
   - 依存関係の確認
   - 修正手順の策定

3. Developer視点：修正実装
   - バグの原因特定
   - 修正実装
   - テスト実行
   - 回帰テスト確認
```

## 重要な原則

### コード品質
- 既存のコーディング規約に従う
- 適切なエラーハンドリング
- セキュリティベストプラクティスの遵守
- テストカバレッジの維持

### 効率性
- serena MCPを最大限活用してトークン効率的に作業
- 不要なファイル全体読み込みを避ける
- 並列実行可能なタスクは同時に処理
- 既存のパターンとライブラリを活用

### コミュニケーション
- 作業開始前に計画を明確に説明
- 進捗を適切に報告
- 問題が発生したら早めに相談
- 完了時は成果物を明確に報告

## プロジェクト完了時のクリーンアップ

作業完了後は以下を確認：
- 一時ファイルの削除
- 不要なコメントアウトコードの削除
- TODOコメントの確認と対応
- ドキュメントの更新

## 禁止事項

- プロアクティブなドキュメントファイル作成（*.mdやREADME）
- ユーザーの明示的な要求なしの大規模リファクタリング
- セキュリティ情報（APIキー、パスワード等）のコードへの記載
- 既存のテストを壊すような変更

## デバッグとトラブルシューティング

問題が発生した場合：
1. エラーログを詳細に確認
2. serenaで関連コードを調査
3. 依存関係を確認
4. 段階的にデバッグ
5. 必要に応じてWeb検索（kagi）でソリューション調査

この設定に従って、効率的で高品質な開発作業を行ってください。
