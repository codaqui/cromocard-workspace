# Plano — CCD064 Aprovar Solicitações

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22 e revista em 2026-11-12 e 2026-11-16
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Subdomínio `catalog/requests`: lista e detalhe das solicitações, aprovar (usa o `catalogService` da CCD061 para criar
o item, numa transação com a mudança de status) e recusar com motivo. Cada decisão grava `audit_logs` e avisa o
solicitante com uma notificação.

## Dependências

- CCD061 (`catalogService` exportado) e fundação (`catalog_requests`, seeds, `AuditLogService`, `ConfirmDialog`).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`, prefixo `/api/v1/admin/catalog-requests`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /` | `type`, `status` (padrão `PENDING`), `page`, `pageSize` | `200` `{ data, meta }` + `meta.pendingByType` | `400` | R3, R4 |
| `GET /:id` | — | `200` com `data` e o solicitante | `404 CATALOG_REQUEST_NOT_FOUND` | R5 |
| `POST /:id/approve` | — | `200` com a solicitação revisada e `createdItem: { type, id, name }` | `404`, `409 REQUEST_ALREADY_REVIEWED`, `409 CARD_NUMBER_TAKEN` e os demais erros do catálogo, `422 REQUEST_DATA_INCOMPLETE` | R6–R11, R13, R16 |
| `POST /:id/reject` | `{ reason }` (3 a 500) | `200` com a solicitação revisada | `400`, `404`, `409 REQUEST_ALREADY_REVIEWED` | R14 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/requests/catalog-requests.validator.ts` · `.errors.ts` | filtros, motivo e erros | R11, R14 |
| `catalog-requests.repository.ts` | lista, detalhe, mudança de status com checagem `status = PENDING` | R3, R5, R7, R11 |
| `catalog-requests.service.ts` + `.spec.ts` | aprovar (cria via `catalogService`), recusar, auditoria, notificação | R6–R15 |
| `catalog-requests.controller.ts` · `.routes.ts` · `.swagger.ts` | rotas | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/requests/` (api, queries, types) | chamadas | R3–R7 |
| `pages/CatalogRequestsPage/` | abas por tipo com contadores e lista de cartões | R2–R4 |
| `components/CatalogRequestCard/` | dados por tipo (carta com franquia, raridade, idioma e imagens; álbum; categoria), "Aprovar" e "Recusar" | R5–R12 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA6 | `catalog-requests.service.spec.ts` · integração |
| CA1, CA4 | `CatalogRequestsPage.spec.tsx` |
| CA7 | integração |

## Revisão de 12/11/2026 (L6, L7)

- R3: a página lista os cards abertos com paginação e as abas por tipo; o código exibido é `#SOL-` + o início do id.
- R6: `ApproveRequestDialog` resume o que será criado; R14: `RejectRequestDialog` com o motivo obrigatório e o erro.
- R11: o `409` de solicitação processada devolve quem e quando, e a tela mostra o diálogo `847-1878`.
- R16: o `409` do catálogo (número repetido) mostra o diálogo `847-2371` e a solicitação continua pendente.

## Revisão de 16/11/2026 (L8–L11)

- **Dados sugeridos** (`catalog_requests.data`): carta `{ name, albumId?, number?, categoryId, rarityId, languageId,
  frontImageUrl, backImageUrl? }`; álbum `{ title, categoryId?, publisher?, year? }`; categoria `{ name, type }`. O
  service valida a carta com o `createCardSchema` do catálogo antes de criar: faltou campo, `422
  REQUEST_DATA_INCOMPLETE` com `details` por campo, e nada é gravado (R16, CA8).
- **Aprovar** cria o item com o `catalogService` da CCD061 (carta publicada, álbum sem cartas, categoria com
  `data.createdCategoryId`), muda o status só se ainda estiver `PENDING`, grava `CATALOG_REQUEST_APPROVED` e cria a
  notificação. O log de criação do próprio catálogo (`CARD_CREATED` etc.) continua, porque registra o item novo.
- **`409 REQUEST_ALREADY_REVIEWED`** devolve em `details` o `status` (`APPROVED`/`REJECTED`), `reviewedBy` (`id`,
  `name`, `username`) e `reviewedAt`, para o diálogo `847-1878`.
- **`GET /`**: `meta.pendingByType` = `{ CARD, ALBUM, CATEGORY, ALL }`; cada item traz o solicitante (`id`, `name`,
  `username`) e é ordenado do mais antigo para o mais novo. Os ids da carta (franquia, raridade, idioma, álbum) vêm
  resolvidos em nomes para exibir no card.
- **Código `#SOL-`**: os 4 últimos caracteres do id em maiúsculas (o início do UUID v7 é o horário e se repete).
- **Notificação** (L11): `type = CATALOG_REQUEST`, título e mensagem do caso de uso, sem `reference_link`.
- **Abas** (L10): "Todas · Cartas · Álbuns · Categorias", com o selo "STATUS DA FILA · N Pendentes".
- **Seed**: a sugestão de carta pendente ganha franquia, raridade, idioma e imagem; entram uma sugestão sem idioma
  (CA8), uma carta com número repetido pendente (CA6) e uma solicitação já aprovada (CA5).
