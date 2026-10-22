# CCD103 — Votar em Solicitação de Catálogo

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #607 `CCD103-Votar em Solicitação de Catálogo` · responsável Gabriel Nascimento · Sprint 06
- **Caso de uso:** [103-votar-em-solicitacao-de-catalogo.md](../../docs/Casos-De-Uso/103-votar-em-solicitacao-de-catalogo.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Cliente, Administrador · **Pré-condições:** cliente autenticado para votar; `ADMIN` para ver o quórum
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso votar a favor, neutro ou contra uma sugestão de nova categoria para ajudar o administrador a decidir o que entra no catálogo.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Votar exige login; ver o quórum exige `ADMIN` | Permissão | `103`, Atores e Pré-condições; ADR-005, item 4 |
| R2 | Lista das sugestões de categoria pendentes em votação, com a descrição e a contagem de votos | Tela | `103`, FP 1–2 |
| R3 | Voto a favor, neutro ou contra, um por cliente em cada sugestão | Ação | `103`, FP 3–4; DBML `catalog_request_votes` |
| R4 | A contagem é atualizada depois do voto | Regra | `103`, FP 5 |
| R5 | O admin vê o quórum: total, meta, percentual da meta e a divisão entre a favor, neutros e contra | Tela | `103`, FP 6–7 |
| R6 | Aprovar ou recusar encerra a votação | Regra | `103`, FP 8–9 |
| R7 | Votar de novo troca o voto anterior | Regra | `103`, FA 1–2 |
| R8 | Sugestão encerrada não aceita voto | Regra | `103`, FA 3–4 |
| R9 | A meta de votos vem de `global_settings` (`catalog.voting_goal`) | Regra | ADR-053, item 7 |
| R10 | Na sugestão de carta: frente e verso, ilustrador, população estimada, justificativa e fontes | Tela | EA-064-02; DBML `catalog_requests.data` |
| R11 | Na sugestão de álbum: checklist das cartas com "Baixar Planilha .CSV" | Ação | EA-064-03 |
| R12 | Na sugestão de categoria: as subcategorias a criar; aprovar cria todas | Ação | EA-064-04; DBML `categories.parent_category_id` |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** uma sugestão de categoria pendente, **quando** o cliente vota a favor, **então** o voto é gravado e a contagem sobe.
- **CA2** (R7) — **Dado** um cliente que votou contra, **quando** ele vota a favor, **então** o voto é trocado e o total não muda.
- **CA3** (R8) — **Dado** uma sugestão aprovada, **quando** o cliente tenta votar, **então** a API responde `409 VOTING_CLOSED`.
- **CA4** (R5, R9) — **Dado** meta de 200 e 340 votos, **quando** o admin abre a sugestão, **então** vê 340/200 (170%) e a divisão dos votos.
- **CA5** (R12) — **Dado** uma sugestão de categoria com 3 subcategorias, **quando** o admin aprova, **então** a categoria e as 3 subcategorias são criadas.
- **CA6** (R11) — **Dado** uma sugestão de álbum com checklist, **quando** o admin baixa a planilha, **então** recebe um CSV com as cartas.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** tenta votar, **então** a API responde `401`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `catalog_request_votes` | todas | tabela nova (ADR-053) |
| `catalog_requests` | `type`, `data`, `status` | MVP |
| `categories` | `parent_category_id` | subcategorias |
| `global_settings` | `catalog.voting_goal` | chave nova, criada pelo seed |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Fila de solicitações de cartas | [228-1804](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-1804) | R5, R10–R12 | ⚠️ Divergente |

- O Figma não tem a tela de votação do cliente (L1).
- "Arquivos criptográficos de autenticação" e "API GraphQL e Banco Central" são efeito visual.

## Fora do escopo

- Votar em sugestões de carta e de álbum (L2).
- Criar a solicitação — CCD010 e CCD023.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Onde o cliente vota, se não há tela? (proposta: página "Sugestões da comunidade" em `/sugestoes` no Painel Cliente; o Gabriel desenha) | pendente — proposta | — |
| L2 | Só categorias ou também cartas e álbuns? (proposta: só categorias, como no Figma e no caso de uso) | pendente — proposta | — |
| L3 | Meta padrão (proposta: 200, do Figma) | pendente — proposta | — |
| L4 | Campos extras das sugestões dependem de quem cria a solicitação (proposta: lidos de `data` quando existirem) | pendente — proposta | — |
