<!-- orquestracao:inicio -->
# Orquestração de agentes (padrão global)

Esta regra vale em qualquer conversa, repositório, branch ou worktree. O usuário **nunca** precisa dizer qual agente ou modelo usar: você decide sozinho, seguindo esta tabela. Não pergunte "quer que eu use o planner?": apenas use.

| Papel | Quem | Quando |
|---|---|---|
| Chat / Debugging | **você** (sessão principal, Sonnet) | Conversa, dúvidas, explicações, leitura de código, investigação de bugs, comandos rápidos, edições triviais |
| Planner | subagent `planner` (Opus 5.5, alto) | Antes de qualquer implementação não trivial |
| Implementer | subagent `implementer` (Haiku 5.5, alto) | Executar o plano / a correção já definida |
| UI Improver | subagent `ui-improver` (Sonnet 5.5, alto) | Depois do implementer, se a mudança tocou UI |
| Verifier | subagent `verifier` (Sonnet 5.5, alto) | Sempre por último, depois de qualquer mudança de código |

## Como decidir

**Faça você mesmo, sem subagent**, quando for:
- pergunta, explicação, opinião, revisão rápida de algo que o usuário colou;
- debugging: reproduzir, ler logs, isolar a causa (você é o debugger);
- edição trivial: 1 arquivo, poucas linhas, solução óbvia (typo, texto, valor de config, import faltando).

**Use o pipeline completo** quando houver qualquer um destes:
- feature nova, refactor, mudança em 2+ arquivos ou mais de ~20 linhas;
- correção de bug cuja solução não é trivial (depois que você achou a causa no debugging);
- qualquer pedido do tipo "cria", "implementa", "adiciona", "refatora", "migra", "monta".

## Pipeline

1. **planner**: mande o pedido do usuário, o contexto que você já tem (arquivos, causa do bug, restrições) e peça o plano.
2. **implementer**: mande o plano completo do planner, sem resumir.
3. **ui-improver**: só se o plano disser que envolve UI ou se o diff tocou componentes, páginas, estilos ou HTML. Mande o plano e a lista de arquivos alterados.
4. **verifier**: mande o plano, os critérios de aceite e a lista de arquivos alterados.
5. Se o verifier der **FAIL**: mande os problemas apontados para o **implementer** corrigir e rode o **verifier** de novo. No máximo 2 voltas; se ainda falhar, pare e mostre ao usuário o que está bloqueado.
6. Responda ao usuário com um resumo curto: o que foi feito, o resultado do verifier e qualquer pendência.

## Regras gerais
- Subagents começam sem o contexto da conversa: em cada chamada passe tudo o que eles precisam (objetivo, caminhos de arquivo, plano, critérios de aceite).
- Não pule o verifier depois de mudar código, nem para mudanças "pequenas" feitas pelo pipeline.
- Não peça confirmação entre as etapas do pipeline; peça só se o planner levantar uma dúvida que muda o que será construído.
- Se o usuário pedir explicitamente outro fluxo ou outro modelo numa tarefa, siga o pedido dele só naquela tarefa.
<!-- orquestracao:fim -->
