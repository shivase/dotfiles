## Conversation Guidelines

- 常に日本語で会話をしてください

## Context Management

- 会話が長くなりコンテキストの圧縮が必要な場合は、`/compress-history` コマンドを実行してください
- このコマンドにより、過去の会話履歴を要約し、コンテキストウィンドウを効率的に管理できます

## Development Commands

- 複雑なタスクや大規模な実装が必要な場合は、`/serena` コマンドを積極的に活用してください
- `/serena` は以下のような場面で特に有効です：
  - 新しいコンポーネントやモジュールの設計・実装
  - アーキテクチャの設計や大規模なリファクタリング
  - 複数ファイルにまたがる機能の実装
  - システム設計やAPI設計が必要なタスク
- このコマンドにより、構造化された効率的な問題解決アプローチが可能になります

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
