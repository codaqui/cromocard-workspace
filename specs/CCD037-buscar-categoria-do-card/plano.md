# Plano — CCD037 Buscar Categoria do Card

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> **Fase MVP** desde 22/11/2026 (ADR-069).

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L6 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A lista das cartas da coleção (`GET /collections/me/cards`) ganha os filtros de elementos: `q` (nome ou número),
`rarityId`, `variant` (atributos, L2) e, no detalhe do álbum, `languageId` e a faixa `numberFrom`/`numberTo` (L1). A API
valida os ids e responde `422` para o que não existe. No detalhe do álbum, os campos "Buscar carta pelo nome ou número",
"Nº (#01 a #54)", "Todos os idiomas" e "Todas as Raridades"; no Início, "Buscar carta na coleção". Sem resultado, a grade
mostra "Nenhum card encontrado com estes elementos" e o botão de limpar os filtros.

## Dependências

- **CCD007** (grade do Início, frame `1122-17812`) e **CCD013** (grade do detalhe do álbum, frame `1160-23696`): uma das
  duas cria `GET /collections/me/cards`; esta story acrescenta os filtros.
- **CCD105** — `cards.variants`, para os "atributos" (depende da L2).
- **CCD034** — o filtro por categoria na mesma rota; os dois se combinam.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | não | da CCD007 | cartas da coleção do cliente (R4); status na L3 |
| `cards` | sim, sem `variants` | `variants` da CCD105 | `name`, `number`, `rarity_id`, `language_id`, `variants` |
| `rarities` · `languages` | sim | — | conferência dos ids (R3) e as opções dos selects |

Nenhuma coluna nova: "atributos" usam `cards.variants` (depende da L2 e da CCD105).

## Regras

- **E entre filtros** (R4): a carta precisa atender a todos os elementos informados.
- **`q`** (R2): `contains` no nome ou no número, sem diferenciar maiúsculas, de 1 a 60 caracteres.
- **`rarityId` / `languageId`** (R3): id inexistente ou excluído → `422 INVALID_FILTER`, com o campo em `details`.
- **`variant`** (R2, depende da L2): `contains` em `cards.variants`.
- **`numberFrom` / `numberTo`** (depende da L1): faixa numérica sobre `number` quando ele é só dígitos.
- **Status** (depende da L3): todas as marcações não excluídas.
- **Quem pesquisa** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L6).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data, meta }`, erros `{ error, message, details? }`.

### `GET /api/v1/collections/me/cards` (CCD007/CCD013) — R1–R4

- **Entrada nova (query):** `q`, `rarityId`, `languageId` (depende da L1), `variant` (depende da L2), `numberFrom`,
  `numberTo` (depende da L1), além do `albumId` e do `status` da grade.
- **Sucesso:** `200` `{ data: CollectionCard[], meta }`; lista vazia sem resultado (R5).
- **Erros novos:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | formato inválido (id que não é uuid, faixa invertida) | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 422 | `INVALID_FILTER` | raridade ou idioma inexistente | R3 |

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.validator.ts` | os parâmetros novos da lista | R2, R3 |
| `collection.errors.ts` | `InvalidFilterError` (`422 INVALID_FILTER`) | R3 |
| `collection-cards.repository.ts` | o `where` com os elementos combinados | R4 |
| `collection-cards.service.ts` + `.spec.ts` | confere raridade e idioma pela service exportada do catálogo e aplica os filtros | R3, R4 |
| `collection.swagger.ts` | documenta os parâmetros | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.api.ts` · `collection.queries.ts` · `collection.labels.ts` | filtros na query (com `useDebounce` no texto), "Nenhum card encontrado com estes elementos" e "Limpar filtros" | R2, R5 |
| `components/CollectionCardFilters/` | "Buscar carta pelo nome ou número", "Nº (#01 a #54)", "Todos os idiomas", "Todas as Raridades" — frame `1160-23696`; "Buscar carta na coleção" — frame `1122-17812` | R2, R6 |
| `components/NoCardsFound/` | o vazio com "Limpar filtros", no estilo da grade (L4) | R5 |
| páginas do detalhe do álbum (CCD013) e do Início (CCD007) | ligam os filtros à grade | R2, R4 |

- **Estados:** carregando e erro com `LoadingState` e `ErrorState`; vazio com `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** `SearchBar`, `Select`, `TextField`, `EmptyState`, `Button`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | raridade + parte do nome no detalhe do álbum | `collection-cards.service.spec.ts` · `tests/integration/collection-cards-filter.spec.ts` · `CollectionCardFilters.spec.tsx` |
| CA2 | "charizard" no Início traz só as cartas com o nome | integração · `CollectionCardFilters.spec.tsx` |
| CA3 | sem resultado: mensagem e "Limpar filtros" volta todas | `NoCardsFound.spec.tsx` |
| CA4 | raridade inexistente: `422 INVALID_FILTER` | `collection-cards.service.spec.ts` · integração |
| CA5 | sem token `401` | integração |
| CA6, CA7 | print em 1280 px igual aos frames `1160-23696` e `1122-17812`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Os filtros entram na rota da lista que já existe, e não numa rota de busca nova, para a grade, as abas de status e a
  categoria da CCD034 se combinarem numa consulta só.
- Raridade ou idioma inexistente é `422` (R3, CA4): o Zod valida o formato e a service confere a existência.
