#!/bin/bash
# Fills the guide template with the real files so the guide can never drift from them.
T=$1; OUT=$2
awk -v M="$HOME/.claude/rules/pstack-models.md" -v A="$HOME/.codex/pstack/codex-adapter.md" \
    -v S="$HOME/.codex/pstack/sync-pstack.ps1" -v D="$HOME/.codex/pstack/pstack-delegate.ps1" -v G="$3" '
function dump(f,  l) { while ((getline l < f) > 0) print l; close(f) }
/^\{\{MODELS\}\}/ { dump(M); sub(/^\{\{MODELS\}\}/, ""); print; next }
/^\{\{ADAPTER\}\}/ { dump(A); sub(/^\{\{ADAPTER\}\}/, ""); print; next }
/^\{\{SYNC\}\}/ { dump(S); sub(/^\{\{SYNC\}\}/, ""); print; next }
/^\{\{DELEGATE\}\}/ { dump(D); sub(/^\{\{DELEGATE\}\}/, ""); print; next }
/^\{\{AGENTS\}\}/ { dump(G); sub(/^\{\{AGENTS\}\}/, ""); print; next }
{ print }' "$T" | sed 's/\r$//' > "$OUT"
