# Plano — CCD076 Visualizar Anúncios Ativos

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase Futuro Marketplace: implementar depois do MVP (depende da L4).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O usuário logado abre a seção "Anúncios Ativos" e vê os próprios anúncios `ACTIVE` e não excluídos, por
`GET /api/v1/me/listings?status=ACTIVE`. A lista é um componente (`ActiveListingsTable`) com a carta, a condição, o preço e
o estoque; onde ele fica (seção do Dashboard, aba "Ativos" de "Meus Anúncios" ou indicador da Visão geral) depende da L2 e
da L3. Sem anúncios ativos, mostra "Não existem anúncios ativos no momento.".

## Dependências

- **CCD097** (ADR-054): tabela `listings` no banco; **CCD084**: `card_conditions` e a criação de anúncios.
- **CCD085–CCD088**: a tela "Meus Anúncios" (`675-1452`), se a L3 decidir que esta lista é a aba "Ativos" dela.
- **CCD092 / CCD093**: a Visão geral do vendedor (`492-2007`), dona do indicador "Anúncios Ativos".

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings` | da CCD097 | — | `seller_id`, `status = ACTIVE`, `deleted_at` nulo, `price`, `available_quantity`, `created_at` (R3, R4) |
| `cards` · `card_conditions` | sim · da CCD084 | — | `name`, `front_image_url`; `name` (R4) |

## Regras

- **Dono** (R3): sempre `seller_id = usuário do token` (depende da L1: os anúncios do próprio usuário).
- **Ativo** (R3): `status = ACTIVE` e `deleted_at` nulo, com qualquer `available_quantity`; se o esgotado sai da lista
  depende da L5.
- **Ordem**: mais recentes primeiro (`created_at` decrescente), 20 por página (ADR-011). Busca, ordenação escolhida,
  "Visitas" e "+6 esta semana" ficam fora até a L6 e a L5.

## Contrato da API

### `GET /api/v1/me/listings` — R1, R3, R4

- **Acesso:** `authenticate`
- **Entrada:** `status=ACTIVE` (único valor nesta story), `page`, `pageSize`
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "price": "1750.00", "availableQuantity": 2, "status": "ACTIVE", "createdAt": "…",
    "card": { "id": "uuid", "name": "Lionel Messi", "frontImageUrl": "https://…" }, "condition": { "name": "Bom" } }],
    "meta": { "page": 1, "pageSize": 20, "total": 3 } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (status ou paginação inválidos), `401` — R1

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/listings/my-listings.validator.ts` | `status`, paginação | R3 |
| `listings.repository.ts` (CCD079) | `listBySeller(sellerId, status, page)` com carta e condição | R3, R4 |
| `my-listings.service.ts` + `.spec.ts` | só do usuário, só ativos | R3, R4 |
| `my-listings.controller.ts` · `.routes.ts` · `.swagger.ts` | rota em `/me/listings` | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/listings/my-listings.{types,api,queries}.ts` | contrato e query | R3, R4 |
| `components/ActiveListingsTable/` | colunas Carta, Condição, Preço, Estoque e Status do frame `675-1452`, com o cartão "Anúncios ativos"; `EmptyState` "Não existem anúncios ativos no momento.", `LoadingState`, `ErrorState` | R4–R6 |
| tela escolhida na L2/L3 | monta a seção "Anúncios Ativos"; o indicador do frame `492-2007` mostra o total (`meta.total`) | R2, R6 |

- **Rotas:** a da tela escolhida na L2, com `RequireAuth`.
- **Componentes reaproveitados:** `DataTable`, `Badge`, `KpiCard`, `Pagination`, `EmptyState`, `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 3 ativos, sem o pausado e o excluído | `my-listings.service.spec.ts` · `tests/integration/my-listings.spec.ts` |
| CA2 | anúncios de outros não aparecem | integração |
| CA3 | lista vazia com a mensagem | `ActiveListingsTable.spec.tsx` |
| CA4 | `401` sem token | integração |
| CA5 | carregando e erro, sem a mensagem de vazio | `ActiveListingsTable.spec.tsx` |
| CA6, CA7 | print em 1280 px igual aos frames `675-1452` e `492-2007`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O recurso fica em `/me/listings`, separado do `/listings` público da CCD079, porque o filtro pelo dono vem do token e
  não de um parâmetro.
