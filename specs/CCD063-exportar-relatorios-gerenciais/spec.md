# CCD063 — Exportar Relatórios Gerenciais

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #338 `CCD063-Exportar Relatórios Gerenciais` · responsável Lucca Rocha · Sprint 07
- **Caso de uso:** [63-exportar-relatorios-gerenciais.md](../../docs/Casos-De-Uso/63-exportar-relatorios-gerenciais.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN` (o texto do caso de uso repete a finalidade)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero exportar os gráficos e tabelas da Dashboard (ex: novos cadastros do mês) para um arquivo
> CSV ou PDF.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN` gera e baixa relatórios; `401`/`403` | Permissão | `63`, Atores; ADR-005, item 4; ADR-011 |
| R2 | Tela de relatórios em `/backoffice/relatorios`, com `RequireRole role="ADMIN"` | Tela | ADR-038; Diagrama de Atividades ccd063, passo 1 |
| R3 | O sistema apresenta os relatórios e os filtros disponíveis | Tela | `63`, FP 2 |
| R4 | Seleção do tipo de relatório | Campo | `63`, FP 3 |
| R5 | Seleção dos filtros (período) | Campo | `63`, FP 3 |
| R6 | Os filtros são processados na API | Regra | `63`, FP 4 |
| R7 | O sistema apresenta os dados do relatório antes de exportar | Tela | `63`, FP 5 |
| R8 | Opção "Exportar" com confirmação | Ação | `63`, FP 6–7 |
| R9 | O arquivo é gerado no backend e entregue para download | Ação | `63`, FP 7–8 |
| R10 | Formatos CSV e PDF | Regra | user-stories.md §8 |
| R11 | O conteúdo são os dados do Dashboard (ex.: novos cadastros do mês) | Regra | user-stories.md §8 |
| R12 | Filtros sem dados informam "não foram encontrados dados para os filtros selecionados" | Mensagem | `63`, FA 1–2 |
| R13 | O admin altera os filtros e a consulta é refeita | Ação | `63`, FA 3–4 |
| R14 | Cancelar encerra sem gerar o arquivo | Ação | `63`, FA 5–6 |
| R15 | Os dados ignoram registros excluídos | Regra | ADR-015, item 5 |
| R16 | Histórico das exportações, lido do log de auditoria, com "Baixar" gerando o arquivo de novo com os mesmos filtros | Tela | `63`, FP 2 e FP 10–11; ADR-051, item 5 |

## Critérios de aceite

- **CA1** (R3–R7, R11) — **Dado** um admin na tela de Relatórios, **quando** escolhe "Novos cadastros" e 30 dias,
  **então** vê a pré-visualização com as linhas e o total.
- **CA2** (R8–R10) — **Dado** a pré-visualização, **quando** clica em Exportar, escolhe CSV e confirma, **então**
  baixa um CSV com as mesmas linhas.
- **CA3** (R10) — **Dado** a pré-visualização, **quando** exporta em PDF, **então** baixa um PDF com título, período,
  data de geração e a tabela.
- **CA4** (R12, R13) — **Dado** um período sem dados, **quando** filtra, **então** a tela mostra a mensagem e o botão
  Exportar fica desabilitado.
- **CA5** (R14) — **Dado** o diálogo de confirmação, **quando** cancela, **então** nenhum arquivo é gerado.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** pede a exportação, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `users` | `name`, `email`, `role`, `created_at`, `deleted_at` | relatório de novos cadastros |
| `cards`, `albums` | `name`/`title`, `created_at`, `deleted_at` | relatório de catálogo |
| `audit_logs` | `action = EXPORT_REPORT`, `details` | histórico de exportações (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| administração - relatorio | [228-1236](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-1236) | R3–R10 | ⚠️ Divergente |

- O Figma tem 3 tipos visíveis (Novos Cadastros & Ativos, Inventário & Catalogação, Auditoria de Lojistas), a
  pré-visualização, "Exportar PDF", "Exportar CSV" e o histórico com "Baixar". "Auditoria de Lojistas" e "Volume
  transacional & custódia escrow" ficam fora (credenciamento e marketplace). "Assinatura HSM" e "SHA-256" são
  enfeite visual sem requisito.

## Fora do escopo

- Relatórios de lojistas e de marketplace.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais tipos de relatório? (proposta: "Novos cadastros" e "Catálogo") | "Novos cadastros" e "Catálogo" | `63`, FP 2 |
| L2 | Formato do CSV e do PDF (proposta: CSV UTF-8 com BOM e `;`; PDF com cabeçalho e tabela, sem gráfico) | CSV UTF-8 com BOM e `;`; PDF com cabeçalho e tabela, sem gráfico | ADR-050, itens 3 e 4 |
| L3 | Guardar histórico? (proposta: lista das exportações lida de `audit_logs`; "Baixar" gera de novo com os mesmos filtros, sem guardar arquivo) | Lista das exportações lida de `audit_logs`; "Baixar" gera de novo com os mesmos filtros, sem guardar arquivo | `63`, FP 2 e FP 10–11; ADR-051, item 5 |
| L4 | A exportação grava auditoria? (proposta: sim, `EXPORT_REPORT`) | Sim, `EXPORT_REPORT` | `63`, FP 8; ADR-051, item 4 |
| L5 | Corrigir o caso de uso 63 (FP 1 diz "Gestão de Comunidade"; pré-condições e numeração) | Corrigido: FP 1, pré-condições e numeração | `63` |
