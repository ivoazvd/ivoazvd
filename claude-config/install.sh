#!/usr/bin/env bash
# Instala a orquestração de agentes como padrão global do Claude Code (~/.claude).
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/backups/orquestracao-$STAMP"

mkdir -p "$DEST/agents" "$BACKUP"

# 1) Agents: faz backup dos que já existem com o mesmo nome e copia os novos
for f in "$SRC"/agents/*.md; do
  name="$(basename "$f")"
  [ -f "$DEST/agents/$name" ] && cp "$DEST/agents/$name" "$BACKUP/$name"
  cp "$f" "$DEST/agents/$name"
  echo "agent instalado: $name"
done

# 2) CLAUDE.md global: troca só o bloco entre os marcadores, preserva o resto
CLAUDE_MD="$DEST/CLAUDE.md"
touch "$CLAUDE_MD"
cp "$CLAUDE_MD" "$BACKUP/CLAUDE.md"
awk '/<!-- orquestracao:inicio -->/{skip=1} !skip{print} /<!-- orquestracao:fim -->/{skip=0}' \
  "$BACKUP/CLAUDE.md" > "$CLAUDE_MD.tmp"
{ [ -s "$CLAUDE_MD.tmp" ] && { cat "$CLAUDE_MD.tmp"; echo; }; cat "$SRC/CLAUDE.md"; } > "$CLAUDE_MD"
rm -f "$CLAUDE_MD.tmp"
echo "CLAUDE.md atualizado: $CLAUDE_MD"

# 3) settings.json: modelo padrão da sessão principal = Sonnet 5.5
SETTINGS="$DEST/settings.json"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$BACKUP/settings.json"
if command -v jq >/dev/null 2>&1; then
  jq '.model = "claude-sonnet-5-5"' "$BACKUP/settings.json" > "$SETTINGS"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$BACKUP/settings.json" "$SETTINGS" <<'PY'
import json, sys
src, dst = sys.argv[1], sys.argv[2]
data = json.load(open(src)) if open(src).read().strip() else {}
data["model"] = "claude-sonnet-5-5"
json.dump(data, open(dst, "w"), indent=2)
PY
else
  echo "AVISO: sem jq nem python3; adicione \"model\": \"claude-sonnet-5-5\" em $SETTINGS manualmente."
fi
echo "settings.json: model = claude-sonnet-5-5"

echo "Backup do que existia antes: $BACKUP"
echo "Pronto. Abra uma nova sessão do Claude Code e rode /agents para conferir."
