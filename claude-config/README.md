# Orquestração de agentes do Claude Code

| Papel | Agent | Modelo | Esforço |
|---|---|---|---|
| Chat / Debugging | sessão principal | Sonnet 5.5 | padrão |
| Planner | `planner` | Opus 5.5 | alto |
| Implementer | `implementer` | Haiku 5.5 | alto |
| UI Improver | `ui-improver` | Sonnet 5.5 | alto |
| Verifier | `verifier` | Sonnet 5.5 | alto |

Fluxo: planner → implementer → ui-improver (só se tocou UI) → verifier → (FAIL? volta pro implementer, até 2x).

## Instalar (na sua máquina)

```bash
git clone https://github.com/ivoazvd/ivoazvd.git && ./ivoazvd/claude-config/install.sh
```

Instala em `~/.claude/` (nível de usuário), então vale para todo repositório, branch e worktree:
- `~/.claude/agents/*.md`: os 4 subagents
- `~/.claude/CLAUDE.md`: regras de quando usar cada um (só o bloco entre os marcadores é substituído)
- `~/.claude/settings.json`: `"model": "claude-sonnet-5-5"` para a sessão principal

Antes de mexer, faz backup em `~/.claude/backups/orquestracao-<data>/`. Rodar de novo é seguro.
