# Plano — CCD103 Votar em Solicitação de Catálogo

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22; reaprovada em 12/11/2026 e em 17/11/2026 (L7–L10)
- **Data:** 2026-10-22, refeito em 2026-11-17 · **Autor:** Daniel Andrade

## Solução

O cliente vota nas sugestões de categoria pendentes pela página "Sugestões da comunidade" (`/sugestoes`). A fila de
solicitações do BackOffice (CCD064) ganha, em cada cartão, o quórum da categoria, os campos extras da carta, o checklist
e a capa do álbum, e o logo e as subcategorias da categoria. Aprovar a categoria cria também as subcategorias.

## Dependências

- CCD064: a fila (`src/domains/catalog/requests/`, `src/features/catalog/requests/`). Esta story sai das branches
  `feature/339-aprovar-solicitacoes` dos dois apps e entra depois delas.
- CCD061: `catalogService.createCategory` para a categoria e as subcategorias.
- CCD066: a tela de Configurações grava a meta depois; aqui só o seed cria a chave.

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10). O DBML já tem a tabela.

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `catalog_request_votes` | `create_catalog_request_votes_table` | tabela, PK `(catalog_request_id, user_id)` e enum `catalog_vote` (`FOR`, `NEUTRAL`, `AGAINST`) | R3 |
| `global_settings` | — (seed) | chave `catalog.voting_goal`, valor `200` | R9 |

Campos lidos de `catalog_requests.data`, todos opcionais (L4, L9):

| Tipo | Chaves | Requisitos |
|---|---|---|
| `CARD` | `illustrator`, `estimatedPopulation` (número), `justification`, `sources` (`[{ label, url }]`) | R10 |
| `ALBUM` | `coverImageUrl`, `checklist` (`[{ number, code, name, rarityId, variants }]`) | R11, R13 |
| `CATEGORY` | `description`, `logoUrl`, `subcategories` (`string[]`) | R2, R12, R13 |

## Regras

- **Aberta para votação:** solicitação `CATEGORY`, `PENDING` e não excluída. Aprovar ou recusar (CCD064) encerra (R6).
- **Voto:** `upsert` na PK composta; votar de novo troca o voto e reativa a linha se `deleted_at` estiver preenchido (R7).
- **Quem vota:** `CUSTOMER` e `SELLER`, inclusive quem sugeriu; `ADMIN` recebe `403` (L8).
- **Quórum:** `total = for + neutral + against`; `forPercent = for / total`; `goalPercent = total / goal`; a meta vem de
  `catalog.voting_goal` e cai para 200 se a chave não existir ou não for número (R9).
- **Resumo do checklist:** o total de cartas e, entre as raridades presentes, as três de maior `sort_order` (L10).
- **Subcategorias:** do mesmo `type` da categoria, com `parentCategoryId` da criada; nomes vazios ou repetidos tornam a
  sugestão incompleta (`422 REQUEST_DATA_INCOMPLETE`, da CCD064).

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/catalog-requests/voting` | `page`, `pageSize` | `200` `{ data: VotingSuggestion[], meta }`, da mais antiga à mais nova | `401`, `403` (ADMIN) | R1, R2, R4 |
| `PUT /api/v1/catalog-requests/:id/vote` | `{ vote: 'FOR' \| 'NEUTRAL' \| 'AGAINST' }` | `200` `{ data: VotingSuggestion }` | `400 VALIDATION_ERROR`, `401`, `403`, `404 CATALOG_REQUEST_NOT_FOUND` (inexistente ou que não é categoria), `409 VOTING_CLOSED` | R1, R3, R7, R8 |
| `GET /api/v1/admin/catalog-requests` e `/:id` (CCD064) | — | cada item ganha `votes` (só `CATEGORY`, senão `null`) e `checklistSummary` (só `ALBUM` com checklist, senão `null`); `data.checklist[].rarity` com o nome | — | R5, R9–R13 |
| `GET /api/v1/admin/catalog-requests/:id/checklist.csv` | — | `200` `text/csv; charset=utf-8`, `Content-Disposition: attachment; filename="checklist-SOL-XXXX.csv"` | `404 CATALOG_REQUEST_NOT_FOUND`, `404 CHECKLIST_NOT_FOUND` (não é álbum ou não tem checklist) | R11 |

```ts
VotingSuggestion = { id, code, name, description, requester: { id, name, username },
  votes: { for, neutral, against, total }, myVote: 'FOR' | 'NEUTRAL' | 'AGAINST' | null, createdAt }
votes (admin) = { for, neutral, against, total, goal, forPercent, goalPercent }
checklistSummary = { total, rarities: [{ name, count }] }   // até 3, da mais alta para a mais baixa
```

O CSV tem cabeçalho `Nº;Código;Nome da carta;Raridade;Variantes`, separador `;` e BOM UTF-8, para abrir certo no Excel.
Baixar o checklist não grava `audit_logs`: não é relatório da plataforma (ADR-051, item 4).

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | enum `CatalogVote`, modelo `CatalogRequestVote` | R3 |
| `database/seeds/admin.seed.ts` · `data/global-settings.json` · `data/catalog-requests.json` | meta 200, sugestões com os campos extras e votos de exemplo | R9–R13 |
| `src/domains/catalog/requests/catalog-request-votes.{validator,repository,service,controller,routes,swagger,errors}.ts` + `catalog-request-votes.module.ts` | votação do cliente (`/catalog-requests`) | R1–R4, R7, R8 |
| `catalog-requests.repository.ts` · `catalog-requests.service.ts` (CCD064) | votos e meta na lista e no detalhe, resumo do checklist, subcategorias na aprovação | R5, R6, R9–R13 |
| `catalog-requests.checklist.ts` | montar o CSV | R11 |
| `catalog-requests.controller.ts` · `.routes.ts` · `.swagger.ts` | rota do CSV | R11 |
| `src/routes.ts` | registra o módulo da votação | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` · `app/layouts/SiteShell/siteMenu.ts` | `/sugestoes` e o item "Sugestões" no menu | R2 |
| `src/features/catalog/requests/catalog-request-votes.{types,api,queries,labels,format}.ts` | votação do cliente | R2–R4, R7, R8 |
| `pages/CommunitySuggestionsPage/` · `components/SuggestionVoteCard/` | a página `1038-1750` e os estados `1038-2242`, `1038-2740` | R2–R4, R7, R8 |
| `catalog-requests.types.ts` · `.api.ts` · `components/CatalogRequestCard/` (CCD064) | quórum, campos da carta, capa, checklist com CSV, logo e subcategorias | R5, R10–R13 |
| `src/features/catalog/catalog.routes.ts` | rota da página, só para usuário logado | R1 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3, CA8 | `catalog-request-votes.service.spec.ts` · integração |
| CA4, CA5, CA11 | `catalog-requests.service.spec.ts` · integração |
| CA6 | `catalog-requests.checklist.spec.ts` · integração |
| CA7 | integração |
| CA1–CA3, CA9, CA10 | `CommunitySuggestionsPage.spec.tsx` |
| CA4–CA6, CA11 | `CatalogRequestsPage.spec.tsx` |

## Decisões técnicas

- O voto usa `upsert` na PK composta, o que garante um voto por cliente sem corrida.
- O quórum vem em cada item da lista do BackOffice, porque a fila mostra os cartões abertos e não tem tela de detalhe
  (CCD064, L6); a contagem é um `groupBy` por solicitação e voto, numa consulta só para a página.
- A votação do cliente fica no domínio `catalog/requests`, com módulo próprio em `/catalog-requests`, separado do módulo
  do admin em `/admin/catalog-requests`.
- As subcategorias são criadas pelo `catalogService` depois da categoria; se uma falhar, a solicitação volta a ficar
  pendente, como na CCD064 (R16). Os nomes são validados antes (vazios ou repetidos), para que a falha seja rara.
