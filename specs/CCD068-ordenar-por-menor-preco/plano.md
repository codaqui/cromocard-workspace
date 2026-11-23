# Plano — CCD068 Ordenar por Menor Preço (agrupa CCD069 e CCD071)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase MVP. A CCD070 (R9–R11, ordenar por avaliações) foi removida do projeto em 22/11/2026 (ADR-069), e os trechos dela saíram deste plano.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A ordenação é o parâmetro `sort` das duas listagens de anúncios: `GET /api/v1/listings` (Explorar, CCD078) e
`GET /api/v1/cards/:cardId/listings` (lista "Anúncios disponíveis" do perfil da carta, CCD030/CCD079). Um módulo só,
`listings.sort.ts`, traduz a lista de valores permitidos (`-createdAt`, `price`, `-price`) para o `orderBy` do Prisma, com
desempate estável, e responde `400` para o resto. No frontend, o seletor "Ordenar:" (`SortSelect`) grava a ordem na URL e
mantém os filtros; o padrão é "Mais recentes" no Explorar e "Menor preço" no perfil da carta.

## Dependências

- **CCD078:** cria `GET /listings`, `listings.sort.ts` só com `-createdAt`, o seletor e a página do Explorar. Esta story
  estende a lista de `sort` e as opções do seletor.
- **CCD079 / CCD030:** criam `GET /cards/:cardId/listings` e a lista "Anúncios disponíveis". O plano da CCD079 usa
  `sort=price_asc`; o ADR-011 pede `sort=price` / `sort=-price`, e este plano segue o ADR-011 (ver riscos).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `listings` | não | da CCD078/CCD097 | só leitura: `price`, `created_at` (R3–R5) |

Nenhuma coluna nova.

## Regras

- **`price`** (R3): `price` crescente; **`-price`** (R4): decrescente; **`-createdAt`** (R5): `created_at` decrescente
  (depende da L3: reativar um anúncio não muda a ordem).
- **Desempate** (depende da L2): mesmo preço, o mais recente primeiro; depois `id`, para a paginação não repetir nem pular
  anúncios entre "Carregar mais cartas" (R6).
- **Padrão** (R7): `-createdAt` em `GET /listings`; `price` em `GET /cards/:cardId/listings`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Nenhuma rota nova: o parâmetro `sort` entra em duas rotas existentes.

### `GET /api/v1/listings` — R2–R6, R12

- **Acesso:** público.
- **Entrada:** acrescenta a `sort` os valores `price` e `-price` (além do `-createdAt` da CCD078). Os filtros continuam
  valendo junto com a ordem.
- **Sucesso:** `200`, o formato da CCD078, na ordem pedida.
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `sort` fora de `-createdAt`, `price`, `-price` (detalhe no campo `sort`) | R12 |


### `GET /api/v1/cards/:cardId/listings` — R1, R3–R7, R12

- **Acesso:** público.
- **Entrada:** `sort` com os mesmos valores, padrão `price`.
- **Sucesso:** `200`, o formato da CCD079, na ordem pedida. **Erros:** `400 VALIDATION_ERROR` para `sort` fora da lista
  (R12).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/marketplace/listings/` (da CCD078/CCD079).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `listings.sort.ts` + `listings.sort.spec.ts` | `price` e `-price` na lista; desempate `created_at` desc e `id`; padrão por rota | R3–R7, R12 |
| `listings.validator.ts` | `sort` como `z.enum` da lista nas duas queries, com padrões diferentes | R7, R12 |
| `listings.repository.ts` | `findPublicPage` e `findActiveByCard` recebem o `orderBy` do `listings.sort.ts` | R3–R6 |
| `listings.swagger.ts` | valores e padrão de `sort` nas duas rotas | R12 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/listings/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `listings.sort.ts` · `listings.labels.ts` | opções "Mais recentes", "Menor preço" e "Maior preço" (depende da L1) → `-createdAt`, `price`, `-price` | R1, R3–R5 |
| `components/SortSelect/` | "Ordenar: <opção>" com a lista aberta no estilo do `Select`, frames `1112-3281` e `1112-4615` (a lista aberta não tem frame) | R1, R13 |
| `pages/ExploreMarketplacePage/` (CCD078) | usa o `SortSelect`, padrão "Mais recentes"; trocar a ordem reinicia a lista na página 1 e mantém os filtros na URL; o vazio continua "Nenhum anúncio encontrado", frame `1112-3674` | R1, R6–R8 |
| `components/AvailableListings/` (do perfil da carta, CCD030) | usa o `SortSelect`, padrão "Menor preço", frame `1112-4615` | R1, R7 |

- **Rotas:** nenhuma nova. **Estados:** os da CCD078 e da CCD030.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA2 | R$ 380, 120 e 1.750 saem em ordem crescente e decrescente | `listings.sort.spec.ts` · `tests/integration/listings-public.spec.ts` · `ExploreMarketplacePage.spec.tsx` |
| CA3 | o publicado por último aparece primeiro | integração |
| CA4 | com Pokémon e mais de 8, a segunda página continua crescente e o filtro fica | integração · `ExploreMarketplacePage.spec.tsx` |
| CA5 | padrão "Mais recentes" no Explorar e "Menor preço" no perfil da carta | `SortSelect.spec.tsx` · `AvailableListings.spec.tsx` · integração de `/cards/:cardId/listings` |
| CA6 | sem resultados, trocar a ordem mantém o vazio | `ExploreMarketplacePage.spec.tsx` |
| CA7 | sem token `sort=-price` responde `200`; `sort=nome` responde `400` | integração |
| CA9–CA12 | print em 1280 px igual aos frames `1112-3281`, `1112-3674` e `1112-4615`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- O plano da CCD079 usa `sort=price_asc` em `GET /cards/:cardId/listings`; este plano usa `sort=price` (ADR-011). O plano da
  CCD079 precisa ser alinhado antes do código.
- A user story desta spec não existe no board (L4): as Tasks só podem ser criadas depois dela.

## Decisões técnicas

- Uma lista de ordenações por rota, num módulo só, para o Explorar e o perfil da carta não divergirem nas regras.
- O desempate por `id` é técnico (paginação estável); a regra de negócio do desempate é a L2.
