# Plano — CCD067 Buscar por Vendedor

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> **Fase MVP** desde 22/11/2026: o filtro "Vendedor" foi desenhado no Figma (ADR-069).

- **Spec:** [spec.md](spec.md), em Rascunho (L1, L3, L4 e L5 decididas em 22/11/2026; L2 e L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Dois endpoints públicos: `GET /api/v1/sellers?q=` busca os vendedores (`SELLER`, `ACTIVE`, por trecho do nome de usuário)
e `GET /api/v1/listings?sellerId=` (filtro novo na listagem da CCD078) traz os anúncios ativos do vendedor escolhido. No
Explorar, a linha de filtros ganha o seletor "Vendedor" (L4, frame `1112-3281`). Ao abrir, ele mostra o campo do nome e a
lista de vendedores com cidade e número de anúncios ativos (`1226-1280`), ou "Nenhum vendedor encontrado." (`1226-1576`).
Escolhido um vendedor, a grade mostra só os anúncios ativos dele, com o chip "Vendedor: <nome> ✕" nos filtros ativos
(`1226-1862`), ou "Este vendedor não possui anúncios ativos." (`1226-2142`).

## Dependências

- **CCD078:** `GET /listings`, `ListingCard` e o Explorar (`/marketplace`).
- **CCD068:** chips de filtros ativos e o seletor "Ordenar" do Explorar (o chip do vendedor entra ao lado deles).
- **CCD033:** removida em 22/11/2026 (L1, ADR-069).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `users` | sim | — | só leitura: `username`, `role`, `status`, `deleted_at` (R3, R7) |
| `listings` | não | da CCD097/CCD078 | só leitura: `seller_id`, `status` (R4) |

## Regras

- **Vendedor** (R7, depende da L6): `role = SELLER`, `status = ACTIVE`, `deleted_at` nulo.
- **Termo** (R3, L5 decidida): trecho de `username`, sem diferenciar maiúsculas; o nome completo nunca é pesquisado nem
  devolvido (EA-080-01).
- **Anúncios** (R4): os da listagem pública da CCD078 (ativos, não excluídos) com `seller_id` igual.
- **Escolha do vendedor** (depende da L6): o cliente escolhe na lista, mesmo com um resultado só.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/sellers` — R3, R5, R7

- **Acesso:** público (o `67` não exige login).
- **Entrada:** `q` (2 a 100 caracteres), `page`, `pageSize` (padrão 8).
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "username": "tiago_trocas", "avatarUrl": null, "activeListingsCount": 1 }],
    "meta": { "page": 1, "pageSize": 8, "total": 1, "totalPages": 1 } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `q` ausente ou fora do tamanho | R3 |

### `GET /api/v1/listings` (CCD078) — R4, R6

- **Entrada:** acrescenta `sellerId` (uuid).
- **Sucesso:** `200`, o formato da CCD078; vendedor sem anúncio ativo devolve `data: []` e `total: 0`.
- **Erros:** `400 VALIDATION_ERROR` se `sellerId` não for uuid (R4).

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/sellers.validator.ts` · `sellers.repository.ts` · `sellers.service.ts` + `.spec.ts` · `sellers.controller.ts` · `sellers.routes.ts` · `sellers.swagger.ts` · `sellers.module.ts` | busca pública de vendedores, com a contagem de anúncios ativos pelo `listingsService` | R3, R5, R7 |
| `src/domains/marketplace/listings/listings.validator.ts` · `listings.repository.ts` · `listings.swagger.ts` | filtro `sellerId` | R4, R6 |
| `src/routes.ts` | registra `sellersModule` | R3 |
| `tests/integration/sellers.spec.ts` · `listings-public.spec.ts` | CA1–CA4 | R3–R7 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/users/sellers.{types,api,queries}.ts` + `index.ts` | busca de vendedores | R3, R7 |
| `src/features/marketplace/listings/listings.api.ts` · `listings.queries.ts` | `sellerId` na listagem | R4 |
| `src/features/marketplace/listings/components/SellerFilter/` | seletor "Vendedor: Todos" na linha de filtros do Explorar (`1112-3281`, `1112-3674`); ao abrir, o campo do nome e a lista de vendedores com avatar, @usuário, cidade e "<n> anúncios ativos" (`1226-1280`) ou "Nenhum vendedor encontrado." (`1226-1576`) | R1–R3, R5, R7, R8 |
| `src/features/marketplace/listings/components/ActiveFilters/` | chip "Vendedor: <nome> ✕" que desfaz o filtro (`1226-1862`) | R4, R8 |
| `src/features/marketplace/listings/pages/ExploreMarketplacePage/` | `sellerId` na URL e na consulta; vazio "Este vendedor não possui anúncios ativos." (`1226-2142`) | R4, R6, R8 |

- **Rotas:** nenhuma nova; o vendedor escolhido vai na query do Explorar (`/marketplace?vendedor=<username>`).
- **Estados:** `LoadingState` e `ErrorState`, como no Explorar.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "tiago" acha "tiago_trocas"; o Explorar mostra só o anúncio ativo dele | `sellers.service.spec.ts` · integração · `SellerFilter.spec.tsx` · `ExploreMarketplacePage.spec.tsx` |
| CA2 | "zzz" mostra “Nenhum vendedor encontrado.” | integração · `SellerFilter.spec.tsx` |
| CA3 | vendedor só com pausados mostra “Este vendedor não possui anúncios ativos.” | integração · `ExploreMarketplacePage.spec.tsx` |
| CA4 | `CUSTOMER` "tiago" não aparece | `sellers.service.spec.ts` · integração |
| CA5, CA6, CA9 | print em 1280 px igual aos frames `1112-3281`, `1112-3674`, `1226-1280`, `1226-1576`, `1226-1862` e `1226-2142`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- Vendedor suspenso fora da lista segue a proposta da L6 (pendente).
- A user story não existe no board (L2): as Tasks só podem ser criadas depois dela.

## Decisões técnicas

- A busca de vendedores fica no domínio `users` (dono de `users`), e a contagem de anúncios vem do `listingsService`
  (ADR-001: um domínio fala com o outro pelo service).
- Os anúncios do vendedor são um filtro da listagem pública, para o perfil público e o Explorar usarem o mesmo cartão e a
  mesma regra de "ativo".
