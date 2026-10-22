# CCD102 — Exportar Log de Auditoria

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #606 `CCD102-Exportar Log de Auditoria` · responsável Gabriel Nascimento · Sprint 06
- **Caso de uso:** [102-exportar-log-de-auditoria.md](../../docs/Casos-De-Uso/102-exportar-log-de-auditoria.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero baixar em arquivo os registros filtrados do log de auditoria para guardar ou analisar fora da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `102`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Extrair Logs" gera o arquivo com os registros filtrados: data e hora, responsável, ação, alvo e justificativa | Ação | `102`, FP 3–4 |
| R3 | O arquivo é entregue para download | Ação | `102`, FP 5 |
| R4 | A exportação é registrada no log de auditoria | Regra | `102`, FP 6 |
| R5 | Filtros sem registros: informa e não gera o arquivo | Regra | `102`, FA 1–2 |
| R6 | A tabela do log mostra a justificativa de cada ação | Campo | EA-065-01 |
| R7 | Total de ações em 30 dias, com a variação e a média diária | Campo | EA-065-02 |
| R8 | Filtros rápidos | Campo | EA-065-03 |
| R9 | O log grava o IP de quem fez a ação e permite buscar por ele | Regra | EA-065-04; ADR-053, item 8 |

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

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Logs do sistema | [228-2395](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-2395) | R2, R6–R9 | ⚠️ Divergente |

- "Ledger imutável", "Bloco atual" e "HSM online" são efeito visual.
- O cargo do responsável ("Lead Trust & Safety") não existe no DER (L4).

## Fora do escopo

- Cargos de administrador (EA-065-05) — L4.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Em quais ações a justificativa é obrigatória? (proposta: nas que mudam status ou excluem; nas demais, opcional) | pendente — proposta | — |
| L2 | Formato do arquivo (proposta: CSV, como no ADR-050, item 3) | pendente — proposta | — |
| L3 | Limite de linhas (proposta: 10.000, com aviso para refinar os filtros) | pendente — proposta | — |
| L4 | Cargo do responsável (EA-065-05) (proposta: não entra; o DER só tem o papel ADMIN) | pendente — proposta | — |
| L5 | Filtros rápidos (proposta: Banimentos, Remoção de grupos e Mudança de papel) | pendente — proposta | — |
