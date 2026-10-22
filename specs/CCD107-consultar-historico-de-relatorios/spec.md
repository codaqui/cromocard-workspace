# CCD107 — Consultar Histórico de Relatórios

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #611 `CCD107-Consultar Histórico de Relatórios` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [107-consultar-historico-de-relatorios.md](../../docs/Casos-De-Uso/107-consultar-historico-de-relatorios.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero ver os relatórios exportados recentemente e baixar de novo um arquivo já gerado para não precisar exportar outra vez.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `107`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Histórico com código, tipo e período do relatório, solicitante, data e hora, formato e tamanho | Tela | `107`, FP 2 |
| R3 | "Baixar" entrega o mesmo arquivo gerado na exportação | Ação | `107`, FP 3–4 |
| R4 | Cada arquivo fica disponível por 90 dias | Regra | `107`, FP 5; ADR-053, item 9 |
| R5 | Arquivo vencido: informa e oferece gerar de novo com os mesmos filtros | Regra | `107`, FA 1–2 |
| R6 | Histórico vazio mostra a mensagem | Estado | `107`, FA 3–4 |
| R7 | Um job apaga do storage os arquivos vencidos | Regra | ADR-053, item 9; ADR-010 |

## Critérios de aceite

- **CA1** (R2) — **Dado** três exportações feitas por admins diferentes, **quando** o admin abre Relatórios, **então** vê as três com código, tipo, período, solicitante, data, formato e tamanho.
- **CA2** (R3) — **Dado** uma exportação de ontem, **quando** o admin clica em "Baixar", **então** recebe o mesmo arquivo.
- **CA3** (R5) — **Dado** uma exportação com mais de 90 dias, **quando** o admin clica em "Baixar", **então** a API responde `410` e a tela oferece gerar de novo.
- **CA4** (R7) — **Dado** arquivos vencidos, **quando** o job roda, **então** os arquivos somem do storage e as linhas ficam com `deleted_at`.
- **CA5** (R6) — **Dado** nenhuma exportação, **quando** o admin abre Relatórios, **então** vê a mensagem de histórico vazio.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `report_exports` | todas | tabela nova (ADR-053) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Relatórios — histórico | [228-1236](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-1236) | R2, R3 | ⚠️ Divergente |

- "Assinado HSM" e "Digest SHA-256" são efeito visual.

## Fora do escopo

- Gerar e exportar relatórios — CCD063.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Histórico só do próprio admin ou de todos? (proposta: de todos, como o "pela equipe diretiva" do Figma) | pendente — proposta | — |
| L2 | Substitui o histórico lido de `audit_logs` na CCD063? (proposta: sim; a CCD063 continua gravando `EXPORT_REPORT`) | pendente — proposta | — |
| L3 | Como o arquivo é servido? (proposta: rota autenticada `GET /admin/reports/exports/:id/file`, sem URL pública) | pendente — proposta | — |
