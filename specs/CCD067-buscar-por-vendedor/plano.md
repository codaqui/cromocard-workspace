# Plano — CCD067 Buscar por Vendedor

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase Futuro Marketplace (depende da L3): implementar depois do MVP.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Dois endpoints públicos: `GET /api/v1/sellers?q=` busca os vendedores (`SELLER`, `ACTIVE`, por trecho do nome de usuário)
e `GET /api/v1/listings?sellerId=` (filtro novo na listagem da CCD078) traz os anúncios ativos do vendedor escolhido. A
proposta da L4 é o caminho que o Figma já tem: busca global → "Ver perfil" → "Anúncios ativos de <usuário>" no perfil
público (`1112-3970`, `1160-1396`), que passa a usar `GET /listings?sellerId=` e mostra "Este vendedor não possui anúncios
ativos." quando vazio. Como a spec pede a opção de busca por vendedor, a lista de vendedores e as duas mensagens "no estilo
da tela" (Telas, "O que falta no Figma"), a seção de busca do Explorar ganha a escolha "Cartas | Vendedores" com o mesmo
estilo das abas de escopo do `SearchBar` (depende da L4); escolhido um vendedor, abre o perfil público dele.

## Dependências

- **CCD078:** `GET /listings`, `ListingCard` e o Explorar (`/marketplace`).
- **CCD080:** perfil público do vendedor (`/usuarios/:username`) e a seção "Anúncios ativos de <usuário> (<n>)". Esta story
  liga a seção ao filtro `sellerId` e à mensagem do R6.
- **CCD002:** grupo "Usuários" da busca global, caminho alternativo do Figma (sem mudança aqui).
- **CCD033:** duplicada desta (L1): pela proposta, a CCD033 é cancelada e esta fica.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `users` | sim | — | só leitura: `username`, `role`, `status`, `deleted_at` (R3, R7) |
| `listings` | não | da CCD097/CCD078 | só leitura: `seller_id`, `status` (R4) |

## Regras

- **Vendedor** (R7, depende da L6): `role = SELLER`, `status = ACTIVE`, `deleted_at` nulo.
- **Termo** (R3, depende da L5): trecho de `username`, sem diferenciar maiúsculas; o nome completo nunca é pesquisado nem
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
| `src/features/marketplace/listings/components/ListingSearchScope/` | "Cartas \| Vendedores" na seção de busca do Explorar, no estilo das abas de escopo do `SearchBar`, frame `1112-3281` (depende da L4) | R1, R2, R8 |
| `src/features/users/components/SellerResultList/` | vendedores encontrados (iniciais ou avatar, @usuário, "<n> anúncios") e “Nenhum vendedor encontrado.”, no estilo do grupo "Usuários" do `1112-3970` | R3, R5, R8 |
| `src/features/users/components/SellerActiveListings/` (no perfil público da CCD080) | "Anúncios ativos de <usuário> (<n>)" com `ListingCard` e “Este vendedor não possui anúncios ativos.”, frame `1160-1396` | R4, R6, R8 |
| `src/features/marketplace/listings/pages/ExploreMarketplacePage/` | troca a grade pela lista de vendedores quando o escopo é "Vendedores" | R1–R3 |

- **Rotas:** nenhuma nova; selecionar o vendedor abre `/usuarios/:username` (CCD080).
- **Estados:** `LoadingState` e `ErrorState`, como no Explorar.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "tiago" acha "tiago_trocas"; o perfil mostra só o anúncio ativo | `sellers.service.spec.ts` · integração · `ExploreMarketplacePage.spec.tsx` · `SellerActiveListings.spec.tsx` |
| CA2 | "zzz" mostra “Nenhum vendedor encontrado.” | integração · `SellerResultList.spec.tsx` |
| CA3 | vendedor só com pausados mostra “Este vendedor não possui anúncios ativos.” | integração · `SellerActiveListings.spec.tsx` |
| CA4 | `CUSTOMER` "tiago" não aparece | `sellers.service.spec.ts` · integração |
| CA5–CA9 | print em 1280 px igual aos frames `1112-3281`, `1112-3970` e `1160-1396`, conforme a L4; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- A opção "Cartas | Vendedores" no Explorar não tem frame (L4): o R8 vale quando o Gabriel desenhar. Se a L4 ficar só com o
  caminho da busca global, a T6 e a T7 saem e o resto continua igual.
- A user story não existe no board (L2): as Tasks só podem ser criadas depois dela.

## Decisões técnicas

- A busca de vendedores fica no domínio `users` (dono de `users`), e a contagem de anúncios vem do `listingsService`
  (ADR-001: um domínio fala com o outro pelo service).
- Os anúncios do vendedor são um filtro da listagem pública, para o perfil público e o Explorar usarem o mesmo cartão e a
  mesma regra de "ativo".
