# Plano — CCD053 Visualizar Notificações

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L10 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A central (`/notificacoes`) lista as notificações do usuário por `GET /api/v1/notifications`, da mais recente à mais
antiga, com o total de não lidas em `meta`. Selecionar uma notificação chama `PATCH /notifications/:id/read` e, se houver
`referenceLink`, navega para ele. Toda notificação passa a ser criada por `notificationsService.notify`, que grava e só
depois emite `notification:new` na room `user:<id>` do Socket.IO; o `CustomerLayout` escuta o evento em qualquer tela,
mostra o aviso flutuante e soma 1 ao contador. As preferências por tipo de aviso ficam em Configurações (depende da L10).

## Dependências

- **CCD044** (lote Grupos): cria o servidor Socket.IO em `src/socket/` com o handshake por JWT, a entrada automática na
  room `user:<id>` (ADR-012) e o cliente `socket.io-client` no frontend. Esta story só emite e escuta `notification:new`.
- **CCD060**: cria o domínio `src/domains/notifications/` (`notifications.module.ts`) e grava as notificações do disparo
  global (`type = GLOBAL`). Esta story acrescenta a emissão em tempo real à entrega dela (R9, R10).
- **CCD051**: dona da tela Configurações (`/configuracoes`). Se ela ainda não existir, esta story cria a página só com os
  blocos "Canais de aviso" e "Categorias e Eventos", e a CCD051 acrescenta o resto.
- As stories que geram eventos (CCD064, CCD072, CCD073, CCD109, CCD110…) passam a chamar `notificationsService.notify`
  e acrescentam o tipo delas (ADR-051, item 2; L4).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `notifications` | sim | — | leitura e `is_read` (R2–R6, R10) |
| preferências por tipo de aviso | não (o DBML não tem) | depende da L10 | R11: PR de docs no DBML (e ADR) antes do código |

## Regras

- **Quem tem central** (R1): `CUSTOMER` e `SELLER`; o `ADMIN` recebe `403` (depende da L1).
- **Escopo** (R1, R2): sempre `user_id = usuário do token` e `deleted_at` nulo; notificação de outro usuário é `404`.
- **Ordem** (R3): `created_at` decrescente ("Mais recentes primeiro"), 20 por página (ADR-011). O agrupamento "HOJE" /
  "ANTERIORES • Últimos 3 dias" e o corte em 3 dias só entram com a L9.
- **Marcar como lida** (R6): `updateMany` com `id`, `user_id` e `is_read = false`; já lida responde `200` sem mudar nada.
- **Rótulo do tipo** (R4): mapa tipo → rótulo no frontend (`notifications.labels.ts`), começando pelos tipos do ADR-051
  (`GLOBAL`, `CATALOG_REQUEST`, `SELLER_PENDING`, `SELLER_REVIEW`); cada story nova acrescenta o seu (depende da L4).
- **Tempo real** (R9): persistência primeiro (ADR-012); se a gravação falha, nada é emitido.
- O que só existe no Figma (filtros L5, sino e popup L6, botões dentro da notificação L7, ✓ e menu ⋮ L8) fica fora do
  código até a decisão; a documentação vale até lá.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

```ts
Notification = { id, title, message, type, referenceLink: string | null, isRead, createdAt }
```

### `GET /api/v1/notifications` — R1–R4, R10

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1)
- **Entrada:** `page`, `pageSize` (padrão 20)
- **Sucesso:** `200` `{ data: Notification[], meta: { page, pageSize, total, unreadCount } }`
- **Erros:** `400 VALIDATION_ERROR` (paginação inválida), `401`, `403` (ADMIN) — R1

### `PATCH /api/v1/notifications/:id/read` — R1, R5, R6

- **Acesso:** igual ao anterior
- **Sucesso:** `200` `{ data: Notification }` com `isRead: true`
- **Erros:** `400 VALIDATION_ERROR` (id não é uuid), `401`, `403`, `404 NOTIFICATION_NOT_FOUND` (inexistente, excluída ou
  de outro usuário) — R1

### Evento `notification:new` (Socket.IO, room `user:<id>`) — R9

- **Payload:** `Notification`, emitido pelo `notificationsService.notify` depois do commit.

### `GET` e `PUT /api/v1/me/notification-preferences` — R11 (depende da L10)

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Corpo do `PUT` e resposta do `GET`:** `{ data: [{ category, inApp: boolean, email: boolean }] }`, com
  `category` em `ORDERS`, `MESSAGES`, `GROUPS`, `CATALOG_REQUESTS`, `PLATFORM` (os 5 tipos do EA-053-01; os 6 eventos do
  Figma dependem da L10). Sem preferência gravada, todos `true`.
- **Erros:** `400 VALIDATION_ERROR` (categoria desconhecida ou campo faltando), `401`, `403`.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/notifications/` (da CCD060), no modelo de `src/domains/users/` (ADR-004).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `notifications.validator.ts` | paginação, `notificationIdParams`, corpo das preferências | R1, R11 |
| `notifications.errors.ts` | `NotificationNotFoundError` (`404 NOTIFICATION_NOT_FOUND`) | R1 |
| `notifications.repository.ts` | `listByUser` (com `unreadCount`), `markAsRead`, `create`, `createMany` | R2–R6, R10 |
| `notifications.publisher.ts` | emite `notification:new` na room `user:<id>` pelo `io` da CCD044 | R9 |
| `notifications.service.ts` + `.spec.ts` | listar, marcar como lida, `notify` (grava e emite) | R1–R6, R9 |
| `global-notifications.service.ts` (CCD060) | emite `notification:new` para cada destinatário depois da entrega | R9, R10 |
| `notification-preferences.{repository,service}.ts` + `.spec.ts` | ler e gravar as preferências (depende da L10) | R11 |
| `notifications.controller.ts` · `.routes.ts` · `.swagger.ts` · `notifications.module.ts` | rotas da central e das preferências | R1 |
| `database/seeds/` | notificações de exemplo do cliente do seed (lidas e não lidas, com e sem link) | R2–R5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/notifications/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `notifications.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` | contrato, chamadas, queries (TanStack Query) e rótulos dos tipos | R2–R6 |
| `pages/NotificationsPage/` | cabeçalho "NOTIFICAÇÕES E FAVORITOS", "<n> Não Lidas", abas "Central de Notificações" e "Meus Favoritos" (a aba de favoritos é da CCD055), frame `490-796`; estados `LoadingState`, `ErrorState` e `EmptyState` "Nenhuma notificação encontrada" (depende da L2) | R2, R3, R7, R12 |
| `components/NotificationItem/` | título, mensagem, rótulo do tipo, tempo relativo e destaque de não lida, frames `490-796` e `675-12111` | R4–R6, R12 |
| `hooks/useOpenNotification.ts` | marca como lida e navega para o `referenceLink` com `state.fromNotification` | R5, R6 |
| `components/NotificationToast/` · `hooks/useNotificationsSocket.ts` | escuta `notification:new`, mostra o aviso flutuante e atualiza o cache (contador +1), frame `675-13070` | R9, R12 |
| `app/layouts/CustomerLayout/CustomerLayout.tsx` | monta o `useNotificationsSocket` em todas as telas do cliente | R9 |
| `src/components/NotFoundPage/` | com `state.fromNotification`, mostra o aviso de conteúdo indisponível (texto depende da L3) | R8 |
| `components/NotificationPreferences/` | blocos "Canais de aviso" e "Categorias e Eventos" em Configurações, frame `1160-41305` (depende da L10) | R11, R12 |
| `notifications.routes.ts` | troca o `underConstructionRoute` de `/notificacoes` pela página | R1 |

- **Rotas:** `/notificacoes` (já em `paths.ts`), dentro do `CustomerLayout` com `RequireAuth`; o `ADMIN` é levado ao
  BackOffice (depende da L1).
- **Componentes reaproveitados:** `Tabs`, `Badge`, `Toast`, `Pagination`, `LoadingState`, `ErrorState`, `EmptyState`,
  `Checkbox` (chaves das preferências), `Button`.
- O sino com contador e popup (`1124-22490`) só entra se a L6 for aprovada; aí reaproveita `NotificationItem` e as queries.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 notificações em ordem decrescente, `unreadCount = 3`, destaque das não lidas | `notifications.service.spec.ts` · `tests/integration/notifications.spec.ts` · `NotificationsPage.spec.tsx` |
| CA2, CA3 | marca como lida, contador −1, navega só com `referenceLink` | integração · `NotificationItem.spec.tsx` |
| CA4 | "Nenhuma notificação encontrada" | `NotificationsPage.spec.tsx` |
| CA5 | aviso de conteúdo indisponível e notificação lida | `NotFoundPage.spec.tsx` · `useOpenNotification.spec.ts` |
| CA6 | `notify` emite só para `user:<id>` e não emite se a gravação falha; o toast aparece e o contador soma 1 | `notifications.service.spec.ts` · `tests/integration/notifications-socket.spec.ts` · `useNotificationsSocket.spec.tsx` |
| CA7 | notificação `GLOBAL` da CCD060 aparece na lista | integração |
| CA8 | preferência gravada e lida de volta (depende da L10) | `notification-preferences.service.spec.ts` · `NotificationPreferences.spec.tsx` |
| CA9 | `401` sem token; `404` ao marcar a de outro usuário, sem mudar a dele | integração · `tests/unit/notifications-routes.spec.ts` |
| CA10 | carregando e erro, sem mostrar a central vazia | `NotificationsPage.spec.tsx` |
| CA11–CA15 | print em 1280 px igual aos frames `490-796`, `675-12111`, `675-13070`, `1124-22490` (depende da L6) e `1160-41305`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- `notificationsService.notify` é a única porta para criar notificação: as outras stories não gravam em `notifications`
  direto, e a emissão em tempo real fica num lugar só (`notifications.publisher.ts`, que recebe o `io` por injeção para o
  teste usar um falso).
- O contador de não lidas vem em `meta.unreadCount` da lista; o evento em tempo real atualiza o cache da query, sem
  outra chamada.
- O conteúdo indisponível (R8) é detectado pela tela de destino: a página que responde `404` mostra o aviso quando veio de
  uma notificação, porque `referenceLink` é um caminho do frontend que o backend não resolve.
