# CCD102 — Exportar Log de Auditoria

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #606 `CCD102-Exportar Log de Auditoria` · responsável Gabriel Nascimento · Sprint 06
- **Caso de uso:** [102-exportar-log-de-auditoria.md](../../docs/Casos-De-Uso/102-exportar-log-de-auditoria.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin

## Objetivo

> Como Administrador eu quero baixar em arquivo os registros filtrados do log de auditoria para guardar ou analisar fora da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `102`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Extrair Logs" gera o arquivo com os registros filtrados: data e hora, responsável, ação, alvo e justificativa | Ação | `102`, FP 3–4 |
| R3 | O arquivo é baixado direto, sem confirmação, com o aviso "Arquivo CSV gerado com N registros" | Ação | `102`, FP 5 (L7) |
| R4 | A exportação é registrada no log de auditoria | Regra | `102`, FP 6 |
| R5 | Filtros sem registros: informa e não gera o arquivo; mais de 10.000 registros: pede para refinar os filtros | Regra | `102`, FA 1–4 |
| R6 | A tabela do log mostra a justificativa de cada ação | Campo | EA-065-01 |
| R7 | Total de ações em 30 dias, com a média diária e a variação em relação aos 30 dias anteriores | Campo | EA-065-02 |
| R8 | Filtros rápidos "Banimentos", "Remoção de grupos" e "Mudança de papel" | Campo | EA-065-03 (L5) |
| R9 | O log grava o IP de quem fez a ação, mostra o IP na linha e no detalhe e permite filtrar por ele (campo "IP") | Regra | EA-065-04 (L6); ADR-053, item 8 |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** registros filtrados por "Usuário suspenso", **quando** o admin clica em "Extrair Logs", **então** baixa um CSV só com esses registros, e a exportação aparece no log.
- **CA2** (R5) — **Dado** filtros sem resultado, **quando** o admin clica em "Extrair Logs", **então** a tela informa que não há registros e nada é baixado.
- **CA3** (R7) — **Dado** 1.284 ações em 30 dias, **quando** o admin abre Logs, **então** vê o total, a variação e a média diária.
- **CA4** (R8) — **Dado** o filtro rápido "Banimentos", **quando** o admin clica nele, **então** a lista mostra só as ações de banimento.
- **CA5** (R9) — **Dado** uma ação feita de um IP conhecido, **quando** o admin busca pelo IP, **então** a lista mostra essa ação.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `audit_logs` | todas, mais `ip_address` | coluna nova (ADR-053) |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Logs do sistema | `228-2395` | R2, R6–R9 | ✅ Bate |
| Logs extraídos | `849-852` | R3, R4 | ✅ Bate |
| Nada para exportar | `849-2265` | R5 | ✅ Bate |
| Limite de exportação | `849-1794` | R5 | ✅ Bate |

- "Ledger imutável", "Bloco atual", "HSM online" e o cargo do responsável não estão no Figma desde 12/11/2026.

## Fora do escopo

- Cargos de administrador (EA-065-05) — L4.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Em quais ações a justificativa é obrigatória? (proposta: nas que mudam status ou excluem; nas demais, opcional) | Nas que mudam status ou excluem; nas demais, opcional | `escopo-adicional.md`, EA-065-01 |
| L2 | Formato do arquivo (proposta: CSV, como no ADR-050, item 3) | CSV, como no ADR-050, item 3 | `102`, FP 4; ADR-050, item 3 |
| L3 | Limite de linhas (proposta: 10.000, com aviso para refinar os filtros) | 10.000, com aviso para refinar os filtros | `102`, FA 3–4 |
| L4 | Cargo do responsável (EA-065-05) (proposta: não entra; o DER só tem o papel ADMIN) | Não entra; o DER só tem o papel ADMIN | esta spec (Fora do escopo); `escopo-adicional.md`, EA-065-05 |
| L5 | Filtros rápidos (proposta: Banimentos, Remoção de grupos e Mudança de papel) | Banimentos, Remoção de grupos e Mudança de papel | `escopo-adicional.md`, EA-065-03 |
| L6 | Como buscar e mostrar o IP? | Campo "IP" nos filtros, IP embaixo do responsável na linha e no painel de detalhes. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `65`, FP 2–3 e FP 7; `escopo-adicional.md`, EA-065-04 |
| L7 | "Extrair Logs" pede confirmação? | Não: baixa direto e avisa quantos registros foram exportados; os bloqueios (sem registros e acima de 10.000) aparecem como aviso. Decisão do PO (Daniel, 12/11/2026) | `102`, FP 5 |
