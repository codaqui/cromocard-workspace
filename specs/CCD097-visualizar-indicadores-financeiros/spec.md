# CCD097 — Visualizar Indicadores Financeiros

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #601 `CCD097-Visualizar Indicadores Financeiros` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [97-visualizar-indicadores-financeiros.md](../../docs/Casos-De-Uso/97-visualizar-indicadores-financeiros.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero ver no Dashboard o valor em custódia, o valor liquidado no dia e o valor retido em garantia para acompanhar o dinheiro que passa pelo marketplace.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `97`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Valor em custódia: soma dos pagamentos `APPROVED` de pedidos `PAID` ou `SHIPPED` | Campo | `97`, FP 2; DBML `payments`, `orders` |
| R3 | Valor liquidado no dia e quantidade de pedidos liberados (`DELIVERED` no dia) | Campo | `97`, FP 3 |
| R4 | Valor retido em garantia | Campo | `97`, FP 3 |
| R5 | Volume anunciado e reputação de cada vendedor na lista de vendedores | Campo | `97`, FP 4; DBML `listings`, `reviews` |
| R6 | Filtro de período (Hoje, 7 dias, 30 dias, 1 ano) | Campo | `97`, FP 5–6 |
| R7 | "Ver Livro Razão de Hoje": pagamentos e liberações do dia | Tela | `97`, FP 7–8 |
| R8 | Sem movimentação: indicadores em zero e a mensagem | Estado | `97`, FA 1–2 |
| R9 | População e preço médio de referência de cada carta na Gestão de Catálogo | Campo | EA-061-05; DBML `collection_cards`, `price_history` |
| R10 | Volume negociado e negociações ativas de cada grupo na Gestão de Comunidade | Campo | EA-062-03 (cálculo em L5) |
| R11 | Relatório "Volume Transacionado & Custódia" em Exportar Relatórios | Ação | EA-063-03 |

## Critérios de aceite

- **CA1** (R2) — **Dado** dois pagamentos aprovados de pedidos pagos, de R$ 100 e R$ 50, **quando** o admin abre o Dashboard, **então** a custódia mostra R$ 150,00.
- **CA2** (R3) — **Dado** um pedido entregue hoje de R$ 80, **quando** o admin abre o Dashboard, **então** o liquidado do dia mostra R$ 80,00 e 1 pedido.
- **CA3** (R7) — **Dado** movimentação hoje, **quando** o admin abre o livro razão, **então** vê os pagamentos e liberações do dia.
- **CA4** (R8) — **Dado** nenhuma movimentação no período, **quando** o admin filtra, **então** os indicadores mostram zero e a mensagem.
- **CA5** (R5) — **Dado** um vendedor com anúncios ativos e avaliações, **quando** o admin vê a lista de vendedores, **então** vê o volume anunciado e a média das notas.
- **CA6** (R9) — **Dado** uma carta em 3 coleções e preços nos últimos 30 dias, **quando** o admin vê o catálogo, **então** vê a população 3 e o preço médio.
- **CA7** (R11) — **Dado** movimentação no período, **quando** o admin exporta o relatório de volume, **então** o CSV traz custódia e liquidado por dia.
- **CA8** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `orders`, `payments` | status e valores | tabelas do DER, criadas nesta story (L2) |
| `listings`, `reviews` | preço, status, nota | tabelas do DER, criadas nesta story (L2) |
| `price_history` | preço e data | tabela do DER, criada nesta story (L2) |
| `collection_cards` | quantidade | se ainda não existir, conta zero (L4) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Dashboard geral | [208-1240](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-1240) | R2, R5 | ⚠️ Divergente |
| Dashboard — Hoje | [247-3539](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=247-3539) | R3, R4, R7 | ⚠️ Divergente |
| Validar Cadastro | [246-1201](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=246-1201) | R5 | ⚠️ Divergente |
| Catálogo | [208-2895](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2895) | R9 | ⚠️ Divergente |
| Comunidade | [220-3524](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=220-3524) | R10 | ⚠️ Divergente |

- "Smart Contract", "Auditoria automática 100% validada" e leilões são efeito visual ou dependem de funcionalidade sem caso de uso.

## Fora do escopo

- Compra, pedidos e pagamentos em si — fase Futuro Marketplace (CCD072 e seguintes).
- Leilões e chargebacks.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Valor retido em garantia (proposta: pagamentos de pedidos `DELIVERED` há menos de 7 dias, o prazo de reclamação) | Pagamentos de pedidos `DELIVERED` há menos de 7 dias, o prazo de reclamação | `97`, FP 3 |
| L2 | As tabelas do marketplace não existem no banco (proposta: esta story cria `listings`, `orders`, `payments`, `reviews` e `price_history` copiadas do DBML, com dados do seed, só para leitura) | Esta story cria `listings`, `orders`, `payments`, `reviews` e `price_history` copiadas do DBML, com dados do seed, só para leitura | ADR-054 |
| L3 | Reputação (proposta: média das notas recebidas em `reviews`, de 0 a 5) | Média das notas recebidas em `reviews`, de 0 a 5 | `97`, FP 4 |
| L4 | População e preço médio (proposta: população = soma das quantidades em coleções `OWNED` e `DUPLICATE`; preço médio = média de `price_history` nos últimos 30 dias) | População = soma das quantidades em coleções `OWNED` e `DUPLICATE`; preço médio = média de `price_history` nos últimos 30 dias | `escopo-adicional.md`, EA-061-05 |
| L5 | Volume por grupo (proposta: soma dos anúncios ativos compartilhados no grupo, mensagens `LISTING`) | Soma dos anúncios ativos compartilhados no grupo, mensagens `LISTING` | `escopo-adicional.md`, EA-062-03 |
