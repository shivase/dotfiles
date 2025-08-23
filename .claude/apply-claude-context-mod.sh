#!/bin/bash

# Claude Code Context Display Modification Script
# 1. 常にコンテクスト表示を有効化
# 2. トークン数とパーセンテージを表示

#CLAUDE_DIR="/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code"
CLAUDE_DIR="/Users/sumik/.claude/local/node_modules/@anthropic-ai/claude-code"
CLI_FILE="$CLAUDE_DIR/cli.js"

echo "Applying context display modifications..."

# 1. 表示を隠す条件をコメントアウト
echo "  - Always show context display"
sed -i '' 's/if (!Q || Z) return null;/\/\/ if (!Q || Z) return null;/' "$CLI_FILE"

# 2. 残トークン数を計算する処理を追加
echo "  - Adding token calculation"
sed -i '' '/let G = wZ1();/a\
  // Ym関数と同じ計算ロジックを使用\
  let maxTokens = G ? cqB() * 0.92 : cqB();\
  let tokensRemaining = maxTokens - A;' "$CLI_FILE"

# 3. auto-compact有効時のテキストを更新
echo "  - Updating auto-compact display text"
sed -i '' 's/"Context left until auto-compact: "/"Context tokens remaining: "/' "$CLI_FILE"

# 4. auto-compact有効時の表示を「トークン数 (%)」形式に変更
echo "  - Adding token count with percentage for auto-compact mode"
sed -i '' '/Context tokens remaining: /,/}/ s/B,/tokensRemaining.toLocaleString(), " (", B, "%)",/' "$CLI_FILE"

# 5. コンテクスト低下時の表示も同様に更新
echo "  - Updating low context display"
sed -i '' 's/"Context low ("/"Context low ("/' "$CLI_FILE"
sed -i '' '/Context low (/,/}/ s/B,/tokensRemaining.toLocaleString(), " tokens remaining, ", B,/' "$CLI_FILE"
sed -i '' 's/"% remaining) · Run/"%) · Run/' "$CLI_FILE"

echo "Modifications applied successfully!"
echo "Please restart your claude-code session to see the changes."
