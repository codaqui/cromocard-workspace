# Plano — CCD104 Ordenar Categorias Padrão

- **Spec:** [spec.md](spec.md). Spec aprovada pelo PO em 2026-11-17, junto com o ADR-062
- **Repositórios:** backend · frontend
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade · refeito em 2026-11-17 por Lucas Oliveira Lima sobre o código da
  CCD066 (backend `develop` em `8e4d3ea`; frontend no PR 21, `d6f9dbc`)

## Solução

A migration acrescenta `slug`, `display_order`, `is_pinned` e `badge` a `categories`, com o slug único só entre as
não excluídas (ADR-062). O `PATCH /admin/settings/default-categories` da CCD066 passa a receber a lista **na ordem da
tela** e o `isPinned` de cada item e grava `display_order` e `is_pinned` na mesma transação dos versos e da auditoria.
O `GET` devolve as categorias ordenadas (fixada primeiro), com slug, selo e quantidade de cartas. O cadastro de
categoria (CCD061) gera o slug e recebe o selo, e a aba Categorias do Catálogo mostra slug, selo e quantidade e busca
por slug. No frontend, a linha do Módulo 2 da CCD066 ganha posição, alça, setas, alfinete, slug, quantidade e selo.

## Dependências

- **CCD066** — backend no `develop` (#28): rota, serviço, auditoria e versos que este plano estende. **Frontend no PR
  21**, ainda aberto: as tarefas de frontend começam depois do merge dele.
- **CCD061** — cadastro de categoria e aba Categorias, no `develop`.
- **ADR-062** (Aceito) — índice único parcial do slug.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `categories` | sim, sem as 4 colunas | `add_display_fields_to_categories_table` | `slug varchar(100)` nulo permitido, `display_order int not null default 0`, `is_pinned bool not null default false`, `badge varchar(20)` nulo permitido, copiados do DBML (ADR-053, item 10). Na mesma migration: o slug das existentes com sufixo para repetidos, `display_order` em ordem alfabética e o índice `categories_slug_key` `WHERE deleted_at IS NULL` (R13, ADR-062) |

- O índice parcial fica no `schema.prisma` como `@@unique([slug], map: "categories_slug_key", where: raw("deleted_at IS NULL"))`,
  com a preview feature `partialIndexes` no `generator client`. Testado com o Prisma 7.10.0 num PostgreSQL 18
  descartável: o SQL gerado tem o `WHERE (deleted_at IS NULL)` e, depois de aplicado, o `migrate diff` entre as
  migrations e o schema sai vazio (ADR-062, item 1).
- O slug das categorias existentes é gerado em SQL na própria migration (o `migrate diff` só cria a coluna e o
  índice): mesmas regras do `slugify` (sem acentos, minúsculas, `a-z0-9` e hífens), sufixo `-2`, `-3`… por
  `created_at` entre as não excluídas, e o índice criado depois do preenchimento.
- `badge` fica `varchar(20)`, como no DBML, validado no Zod com `STANDARD` e `TRENDING` (R10).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Nenhuma rota nova (L11): duas da CCD066 e três da CCD061 mudam de corpo.

### `GET /api/v1/admin/settings/default-categories` — R1, R2, R6

- **Acesso:** `authenticate` + `authorize('ADMIN')` (já existente)
- **Sucesso:** `200`, ordenado por `isPinned` desc, `displayOrder` asc e `name` asc

  ```json
  { "data": [{ "id": "uuid", "name": "Pokémon", "slug": "pokemon", "badge": "TRENDING",
               "isPinned": true, "displayOrder": 0, "cardsCount": 18240, "backImageUrl": null }] }
  ```

### `PATCH /api/v1/admin/settings/default-categories` — R4, R5, R6

- **Acesso:** `authenticate` + `authorize('ADMIN')` (já existente)
- **Entrada:** a lista na ordem da tela. A posição vira `displayOrder` (0, 1, 2…). `isPinned` é opcional (padrão
  `false`), e só um item pode vir `true`.

  ```json
  { "categories": [{ "id": "uuid", "backImageUrl": null, "isPinned": true }, { "id": "uuid", "backImageUrl": null }] }
  ```

- **Sucesso:** `200`, a lista no formato do `GET`. A auditoria `DEFAULT_CATEGORIES_UPDATED` passa a guardar, no
  antes e depois, `displayOrder` e `isPinned` de cada item.
- **Erros:** os da CCD066 continuam (`404 CATEGORY_NOT_FOUND`, `422 DEFAULT_CATEGORY_NOT_ROOT`).

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | mais de um item com `isPinned: true` (campo `categories`, mensagem "Só uma categoria pode ser fixada no topo") | R4 |

### `POST /api/v1/admin/catalog/categories` · `PATCH /api/v1/admin/catalog/categories/:id` — R9, R10

- **Acesso:** `authenticate` + `authorize('ADMIN')` (já existente)
- **Entrada:** acrescenta `badge`: `"STANDARD" | "TRENDING" | null`, opcional (padrão `null`). O `slug` não é
  enviado: o backend gera do nome na criação e quando o nome muda.
- **Sucesso:** o corpo da categoria acrescenta `slug`, `badge` e `cardsCount`.
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 409 | `SLUG_TAKEN` | o slug do nome já é de outra categoria não excluída (`details: [{ field: "name" }]`) | R9 |

### `GET /api/v1/admin/catalog/categories` — R11

- **Entrada:** o `q` passa a buscar no nome **ou** no slug. A ordem continua por nome (contrato da CCD061).
- **Sucesso:** cada item acrescenta `slug`, `badge` e `cardsCount`.

## Backend — `apps/cromocard-backend`

Domínios `src/domains/catalog/` (dono de `categories`) e `src/domains/admin/settings/`, que fala com o catálogo pelo
`defaultCategoriesService`, como na CCD066 (ADR-001).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + `migrations/<data>_add_display_fields_to_categories_table/` | 4 colunas, `partialIndexes`, índice parcial, slug, ordem inicial das existentes | R9, R13 |
| `database/seeds/catalog.seed.ts` · `data/categories.json` | o seed grava o slug (mesma função do `src/lib/slug.ts`) e a ordem alfabética | R13 |
| `src/lib/slug.ts` + `.spec.ts` | `slugify(nome)`: sem acentos (NFD), minúsculas, só `a-z0-9`, hífens únicos, até 100 caracteres | R9 |
| `catalog.validator.ts` | `badge` (`z.enum(['STANDARD','TRENDING']).nullable().optional()`) no cadastro e na edição | R10 |
| `catalog.errors.ts` | `SlugTakenError` (409, `SLUG_TAKEN`, detalhe no campo `name`) | R9 |
| `catalog-categories.repository.ts` | grava `slug` e `badge`; devolve `slug`, `badge` e `cardsCount`; `q` busca em `name` ou `slug`; `findActiveBySlug(slug, exceptId?)` | R9–R11 |
| `catalog-category-counts.ts` (novo, no catálogo) | `countCardsByCategory(ids)`: uma consulta SQL com CTE recursiva das subcategorias, somando cartas não excluídas ligadas direto (`cards.category_id`) ou pelo álbum não excluído (`albums.category_id`) | R2, R11 |
| `catalog.service.ts` | `createCategory`/`updateCategory` geram o slug (de novo só se o nome mudar), conferem `findActiveBySlug` e traduzem a violação do índice para `SlugTakenError` | R9 |
| `catalog-default-categories.repository.ts` | `findDefaults` ordena por fixada, ordem e nome e devolve `slug`, `badge`, `displayOrder`, `isPinned`; `replaceDefaults` recebe `{ id, isPinned }[]` e grava `display_order` pela posição | R4–R6 |
| `catalog-default-categories.service.ts` | repassa a ordem e o fixado e junta o `cardsCount` | R2, R5 |
| `admin/settings/settings.validator.ts` | `isPinned` opcional em cada item e o `refine` de no máximo um fixado | R4 |
| `admin/settings/settings-default-categories.service.ts` | envia ordem e fixado ao catálogo; antes e depois da auditoria com `displayOrder` e `isPinned` | R5 |
| `catalog.swagger.ts` · `admin/settings/settings.swagger.ts` | campos novos e o `409 SLUG_TAKEN` | R1, R9 |

## Frontend — `apps/cromocard-frontend`

Features `src/features/admin/settings/` (Módulo 2, do PR 21) e `src/features/catalog/` (formulário e aba). Settings
importa do catálogo só pelo `index.ts` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/lib/slug.ts` + `.spec.ts` | a mesma `slugify` do backend, para a prévia do slug no formulário (o valor gravado é o do backend) | R9 |
| `catalog/catalog.types.ts` · `catalog.schemas.ts` · `catalog.labels.ts` · `index.ts` | `CategoryBadge`, `badge` no formulário (`''` = Nenhum → `null`), `slug`/`badge`/`cardsCount` em `Category`, `categoryBadgeLabels` (`STANDARD` "Padrão", `TRENDING` "Em alta") exportado pelo `index.ts` | R10, R11 |
| `catalog/components/CategoryForm/` | "Selo de exibição" (Nenhum, Padrão, Em alta) e "Slug" só leitura, como no `833-10832`; texto "O slug é gerado a partir do nome. A ordem das categorias padrão fica em Configurações."; `409 SLUG_TAKEN` no campo Nome | R9, R10 |
| `catalog/components/CategoriesTab/` | coluna "Nome e slug" (slug abaixo do nome e selo), coluna "Cartas" e busca "Buscar por nome ou slug…" | R11 |
| `admin/settings/settings.types.ts` · `settings.api.ts` | `slug`, `badge`, `isPinned`, `cardsCount` em `DefaultCategory`; `isPinned` em `DefaultCategoryInput` | R2, R5 |
| `admin/settings/hooks/useDefaultCategoriesDraft` (em `useDefaultCategoriesEditor.ts`) | `moveUp`, `moveDown`, `moveTo(origem, destino)` e `togglePin` (fixar move para o topo e desafixa a anterior; desafixar não move); `save` envia a ordem e o `isPinned` | R3–R5, R7 |
| `admin/settings/components/DefaultCategoryRow/DefaultCategoryRow.tsx` | alça, posição, nome, selos ("Fixado no topo" e o do `badge`), "Slug: /x • N cartas", verso (já existe), alfinete e setas, desabilitadas nas pontas | R2–R4, R8 |
| `admin/settings/components/DefaultCategoriesModule/DefaultCategoriesModule.tsx` | arrastar nativo (`draggable`, `onDragStart`/`onDragOver`/`onDrop`) pela alça; botão "Salvar ordem" (L18) | R3, R5 |

- **Estados:** carregando, erro e vazio já existem na CCD066 (R12).
- **Componentes reaproveitados:** `Icon` (acrescentar `pushPin`, `dragIndicator`, `expandLess`, `expandMore` se faltarem),
  `ModuleActions`, `SettingsModule`, `TitleCell`, `CountCell` e `FranchiseBadge` do Catálogo.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | lista com posição, nome, slug, quantidade e selo; Futebol soma as cartas dos álbuns das subcategorias | `catalog-default-categories.service.spec.ts` · `tests/integration/admin-settings.spec.ts` · `DefaultCategoriesModule.spec.tsx` |
| CA2 | mover e salvar grava a ordem, e o log traz antes e depois | `settings-default-categories.service.spec.ts` · `tests/integration/admin-settings.spec.ts` · `DefaultCategoriesModule.spec.tsx` |
| CA3, CA8 | fixar leva ao topo e tira o fixado da anterior; dois fixados no `PATCH` dão 400 | `useDefaultCategoriesEditor.spec.ts` · `settings.validator.spec.ts` |
| CA4 | "Cancelar" volta a ordem carregada | `DefaultCategoriesModule.spec.tsx` |
| CA6, CA12 | slug na criação e de novo ao renomear | `slug.spec.ts` · `catalog.service.spec.ts` |
| CA7 | `CUSTOMER` recebe 403 no `GET` e no `PATCH` | `tests/integration/admin-settings.spec.ts` |
| CA9 | desafixar mantém a posição | `useDefaultCategoriesEditor.spec.ts` |
| CA10 | setas desabilitadas nas pontas | `DefaultCategoriesModule.spec.tsx` |
| CA11 | `GET` devolve a fixada primeiro e as demais por ordem | `tests/integration/admin-settings.spec.ts` |
| CA13 | 409 com duas ativas; cria com uma excluída sem restaurá-la | `catalog.service.spec.ts` · `tests/integration/admin-catalog.spec.ts` (índice parcial real) |
| CA14 | selo "Em alta" e "Nenhum" no formulário, no módulo e na aba | `CategoryForm.spec.tsx` · `CategoriesTab.spec.tsx` |
| CA15 | busca pelo slug encontra a categoria | `tests/integration/admin-catalog.spec.ts` · `CategoriesTab.spec.tsx` |
| CA16 | a migration gera slug, sufixo nos repetidos e ordem alfabética, sem fixada | `tests/integration/migrations/add-display-fields-to-categories.spec.ts`: cria um schema temporário com a `categories` de antes da migration, grava categorias (duas que geram o mesmo slug, uma com acento e uma excluída), roda o `migration.sql` nesse schema e confere slug, sufixo, `display_order` e `is_pinned = false`. O seed não serve aqui: ele grava o slug sozinho |

## Decisões técnicas

- **Ordem pela posição na lista** (L11): o `PATCH` já recebe a lista inteira, então `display_order` = índice. Sem
  campo `displayOrder` na entrada, não há ordem inconsistente (duas na posição 1) para validar.
- **Contagem por SQL** (L13): uma CTE recursiva por chamada, para até 50 categorias padrão ou uma página da aba. Fica
  no repositório do catálogo, com `$queryRaw` tipado; sem coluna de contagem guardada (não está no DBML).
- **`slugify` duplicada** no backend e no frontend: o frontend só mostra a prévia; o valor que vale é o do backend.
  Um teste com os mesmos exemplos nos dois lados (`Pokémon TCG` → `pokemon-tcg`, `Yu-Gi-Oh!` → `yu-gi-oh`) segura a
  igualdade.
- **Arrastar nativo** (L16): eventos HTML5 de arrastar na alça, sem biblioteca; o `onDrop` chama o mesmo `moveTo`
  das setas.
- **Índice parcial** pela preview feature `partialIndexes` do Prisma 7.10 (ADR-062).
