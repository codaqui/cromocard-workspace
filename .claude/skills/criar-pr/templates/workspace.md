## O que foi feito
<!-- Resumo em 1 a 3 frases. Que documento, diagrama ou decisão muda? -->

## Card do Azure Boards
<!-- Ex.: AB#270 — Documentação das decisões de arquitetura (ADR) -->
AB#

## Tipo de mudança
- [ ] `docs` — casos de uso, diagramas, ADRs, READMEs
- [ ] `refactor` — reorganização sem mudar conteúdo
- [ ] `chore` — configuração do workspace, submódulos, Claude Code

## Checklist
- [ ] DER alterado nos três formatos (DBML, SQL do chartdb e PlantUML), a partir do `03-der-completo.dbml`
- [ ] Diagrama de classes continua 1:1 com o DER; rastreabilidade do `README.md` do DER atualizada
- [ ] ADR novo com o próximo número, status `Proposto` e linha no índice `docs/ADR/README.md`
- [ ] Caso de uso novo no formato padrão e na `user-stories.md`
- [ ] Spec nova ou alterada (`specs/`): todo requisito com origem, status certo (`Aprovada` só com o PO) e linha no índice do `README.md`
- [ ] `.puml` alterado com o `.svg` exportado (SVG, não PNG)
- [ ] Ponteiro de submódulo (`apps/*`) alterado só de propósito
- [ ] Nenhum token ou segredo nos arquivos (`.mcp.json`, `.claude/`)

## Observações para o revisor
<!-- O que olhar com mais atenção, decisões que ainda dependem do PO. -->
