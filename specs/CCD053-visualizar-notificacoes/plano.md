# Plano — CCD053 Visualizar Notificações

> Refeito em 28/11/2026 com a spec Aprovada (decisões L1–L16).

- **Spec:** [spec.md](spec.md), Aprovada
- **Repositórios:** backend · frontend, a partir da `develop` (que já tem o Socket.IO autenticado da CCD046 T12/T13 e o
  domínio `notifications` da CCD060). A ligação da `NEW_MESSAGE` (T14) ia sair empilhada no chat pessoal, mas o chat
  (#49) entrou na `develop` durante a implementação e a T14 foi feita na mesma branch.
- **Data:** 2026-11-22, refeito em 2026-11-28 · **Autor:** Daniel Andrade

## Solução

A central (`/notificacoes`) lista as notificações do usuário por `GET /api/v1/notifications`, por cursor, com a contagem
de não lidas e por categoria em `meta`. Abrir uma notificação chama `PATCH /notifications/:id/read` e navega para o
`referenceLink`, se houver. Toda notificação nasce no `notificationsService.notify`, que lê a preferência do usuário
(ADR-074), grava e só depois publica `notification:new` na room `user:<id>`. A publicação passa pelo adapter do
PostgreSQL (ADR-075): na `api`, pelo emitter; no `ws`, pelo próprio `io`. No site, o `SiteShell` conecta o Socket.IO
para `CUSTOMER` e `SELLER`, escuta o evento em qualquer tela, mostra o aviso flutuante e atualiza o cache (contador do
sino +1). As preferências ficam em `/configuracoes`, que nasce só com os blocos de aviso (L15).

## Dependências

- **CCD046 T12/T13** (na `develop`): servidor Socket.IO com JWT e a room `user:<id>`; `src/lib/socket.ts` no front.
- **CCD060** (na `develop`): `src/domains/notifications/`, `notify()` mínimo e o disparo global em lotes.
- **Chat pessoal** (#49, já na `develop`): só a T14 (`NEW_MESSAGE`) depende dele. O link `/mensagens?conversa=<id>` abre a conversa quando a tela de mensagens do frontend (PR #36 e seguintes) entrar.
- **CCD054**: "Marcar todas como lidas" e excluir; aqui o botão aparece sem ação (L14).
- **CCD051/CCD052**: acrescentam Conta e segurança, Privacidade e Excluir conta à página de Configurações (L15).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `notification_preferences` | não | `create_notification_preferences_table` | copiada do DBML, com o enum `notification_event` e o único (`user_id`, `event`) (ADR-074) |
| `socket_io_attachments` | não | `create_socket_io_attachments_table` | técnica (ADR-075): `id bigserial`, `created_at`, `payload bytea`; no Prisma com `@@ignore` |

## Regras

- **Quem tem central** (R1): `authorize('CUSTOMER', 'SELLER')`; o `ADMIN` recebe `403`.
- **Escopo** (R1, R2): sempre `user_id` do token e `deleted_at` nulo; notificação de outro usuário é `404`.
- **Ordem e cursor** (R3, R14): `created_at desc, id desc`, `limit` padrão e máximo 50; `cursor` é o `id` da última
  notificação da página anterior; `meta.nextCursor` nulo no fim. O agrupamento "HOJE"/"ANTERIORES" é feito no front pela
  data local.
- **Tipos** (R20): `NOTIFICATION_TYPES` em `notification-types.ts`, com a categoria (`MESSAGES`, `GROUPS`, `PLATFORM`,
  `ORDERS`) e o evento de preferência (ADR-074) de cada tipo. Os domínios que já gravam (`catalog-requests`,
  `seller-verifications`, `global-notifications`) passam a usar as constantes.
- **Filtros** (R15): `filter` = `ALL` (padrão), `UNREAD`, `MESSAGES`, `GROUPS`, `PLATFORM` ou `ORDERS`; as contagens de
  cada um vêm em `meta.counts`.
- **Marcar como lida** (R6, R17): `updateMany` com `id`, `user_id` e `deleted_at` nulo; a já lida responde `200` sem mudar.
- **Preferência** (R21): `notify` não grava nem publica se o evento do tipo (ou `ALL`) tiver `in_app = false`; tipos sem
  evento (`GLOBAL`, `SELLER_*`) só respeitam `ALL`. O disparo global filtra os destinatários com `ALL` desligado.
- **Tempo real** (R9, R18): publica depois do commit; falha do publisher vai para o log e não desfaz a gravação.
- **`NEW_MESSAGE`** (R13): ao gravar a mensagem, o chat chama `notify` para o destinatário só se não houver
  `NEW_MESSAGE` não lida com o mesmo `reference_link` (`/mensagens?conversa=<id>`).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.

```ts
NotificationCategory = 'MESSAGES' | 'GROUPS' | 'PLATFORM' | 'ORDERS'
Notification = { id, title, message, type, category: NotificationCategory, referenceLink: string | null, isRead, createdAt }
NotificationCounts = { ALL, UNREAD, MESSAGES, GROUPS, PLATFORM, ORDERS }   // números
NotificationEvent = 'ORDER_UPDATES' | 'PAYOUT_RELEASED' | 'GROUP_INVITES' | 'DIRECT_MESSAGES' | 'CATALOG_RELEASES' | 'CATALOG_REQUESTS'
NotificationPreferences = { channels: { inApp, email }, events: [{ event: NotificationEvent, inApp, email }] }
```

### `GET /api/v1/notifications` — R1–R4, R10, R14, R15

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `cursor` (uuid, opcional), `limit` (1–50, padrão 50), `filter` (padrão `ALL`)
- **Sucesso:** `200` `{ data: Notification[], meta: { nextCursor: string | null, counts: NotificationCounts } }`
- **Erros:** `400 VALIDATION_ERROR`, `401 UNAUTHORIZED`, `403 FORBIDDEN`

### `PATCH /api/v1/notifications/:id/read` — R1, R5, R6, R17

- **Acesso:** igual ao anterior
- **Sucesso:** `200` `{ data: Notification }` com `isRead: true`
- **Erros:** `400 VALIDATION_ERROR` (id não é uuid), `401`, `403`, `404 NOTIFICATION_NOT_FOUND`

### `GET`, `PUT` e `DELETE /api/v1/me/notification-preferences` — R11

- **Acesso:** igual ao anterior
- **`GET`:** `200` `{ data: NotificationPreferences }`, com tudo `true` onde não há escolha gravada
- **`PUT`:** corpo `NotificationPreferences` completo (os seis eventos) → `200` `{ data: NotificationPreferences }`
- **`DELETE`** ("Restaurar Padrões"): soft delete das escolhas → `200` `{ data: NotificationPreferences }` tudo `true`
- **Erros:** `400 VALIDATION_ERROR` (evento desconhecido, repetido ou faltando), `401`, `403`

### Evento `notification:new` (Socket.IO, room `user:<id>`) — R9, R18

- **Payload:** `Notification`, publicado depois da gravação, pela `api` (emitter) ou pelo `ws` (`io`).

## Backend — `apps/cromocard-backend`

Domínio `src/domains/notifications/`, no modelo de `src/domains/users/` (ADR-004).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 3 migrations | `NotificationPreference`, enum `NotificationEvent`, `SocketIoAttachment` (`@@ignore`); sem índice novo, porque o DBML não declara índices comuns | R11, R14; ADR-075 |
| `notification-types.ts` + `.spec.ts` | `NOTIFICATION_TYPES` com categoria e evento; `categoryOf`, `eventOf` | R15, R20, R21 |
| `notifications.repository.ts` | `listByUser` (cursor, filtro), `countByUser`, `markAsRead`, `create` devolvendo a notificação, `hasUnreadWithLink` | R2–R6, R13–R15 |
| `notification-preferences.repository.ts` · `notification-preferences.service.ts` + `.spec.ts` | ler, gravar (upsert), restaurar; `allowsInApp(userId, type)` | R11, R21 |
| `notification.publisher.ts` + `.spec.ts` | `NotificationPublisher` com `SocketEmitter` injetado: emite `notification:new` nas rooms `user:<id>` | R9, R18 |
| `src/lib/socket-emitter.ts` | `PostgresSocketEmitter` próprio (`pg_notify` no formato do adapter) com um `pg.Pool` do `DATABASE_URL`, e o adapter do `ws` | R9; ADR-075 |
| `src/lib/transaction.ts` | `afterCommit(tx, cb)`: publica só depois do commit | R9; ADR-012 |
| `src/socket/socket-server.ts` | `io.adapter(createAdapter(pool))` | R9; ADR-075 |
| `notifications.service.ts` + `.spec.ts` | `list`, `markAsRead`, `notify` (preferência → grava → publica) | R1–R6, R9, R13–R15, R21 |
| `global-notifications.repository.ts` · `.service.ts` | ignora destinatários com `ALL` desligado e publica para os gravados | R10, R18, R21 |
| `catalog-requests.service.ts` · `seller-verifications.service.ts` · `pending-notice.service.ts` | usam as constantes de tipo | R20 |
| `notifications.{validator,errors,controller,routes,swagger}.ts` · `notifications.module.ts` · `src/routes.ts` | rotas `/notifications` e `/me/notification-preferences` | R1 |
| `database/seeds/` | notificações do cliente do seed: lidas e não lidas, com e sem link, uma `GLOBAL`, uma `NEW_MESSAGE` | R2–R5 |
| T14, no chat: `chat.service.ts` · `new-message.notification.ts` | `notifyNewMessage` depois de gravar a mensagem; `notifyOnce` não grava outra `NEW_MESSAGE` da conversa enquanto a anterior não for lida | R13 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/notifications/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `notifications.{types,api,queries,labels,format}.ts` | contrato, chamadas, queries infinitas (TanStack Query), rótulos e ações por tipo, tempo relativo e grupo HOJE/ANTERIORES | R2–R6, R14, R15, R20 |
| `pages/NotificationsPage/` | frame `490-796`: cabeçalho, selos, "Marcar todas como lidas" (sem ação, L14), "Configurar Alertas", abas, filtros, grupos, "Carregar mais"; "Tudo em dia!" (`675-11716`), vazio, carregando e erro | R2–R7, R14, R15, R19 |
| `components/NotificationItem/` | rótulo, tempo, título, mensagem, botão de ação, ✓ e menu ⋮ (`675-12111`) | R4–R6, R17 |
| `hooks/useOpenNotification.ts` | marca como lida e navega com `state.fromNotification` | R5, R6, R8 |
| `src/components/NotFoundPage/` | com `state.fromNotification`, mostra "Este conteúdo não está mais disponível." | R8 |
| `hooks/useNotificationsSocket.ts` · `components/NotificationToast/` | escuta `notification:new`, atualiza o cache e mostra os avisos flutuantes (`675-13070`) | R9 |
| `components/NotificationBell/` | contador e popup (`1124-22490`), com os filtros do popup | R15, R16 |
| `app/layouts/SiteShell/SiteShell.tsx` | troca o link do sino pelo `NotificationBell` e monta o socket e os avisos para `CUSTOMER`/`SELLER` | R9, R16 |
| `pages/NotificationSettingsPage/` | `/configuracoes` com o cabeçalho, "Canais de aviso", "Categorias e Eventos", "Restaurar Padrões", "Cancelar" e "Salvar Preferências" (`1160-41305`) | R11 |
| `notifications.routes.ts` · `users.routes.ts` | `/notificacoes` e `/configuracoes` no lugar das páginas em construção | R1, R11 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA17, CA18 | ordem, grupos, cursor de 50, filtros e contagens | `notifications.service.spec.ts` · `tests/integration/notifications/notifications.spec.ts` · `NotificationsPage.spec.tsx` |
| CA2, CA3, CA20 | marca como lida, contador −1, navega só com link, ✓ e menu | integração · `NotificationItem.spec.tsx` · `useOpenNotification.spec.tsx` |
| CA4, CA10, CA22 | vazio, carregando, erro e "Tudo em dia!" | `NotificationsPage.spec.tsx` |
| CA5 | aviso na página de destino e notificação lida | `NotFoundPage.spec.tsx` |
| CA6, CA21 | publica só para `user:<id>` depois de gravar; disparo global publica para os gravados; aviso e contador +1 | `notification.publisher.spec.ts` · `notifications.service.spec.ts` · `global-notifications.service.spec.ts` · `tests/integration/notifications/notifications-socket.spec.ts` · `useNotificationsSocket.spec.tsx` |
| CA7 | `GLOBAL` aparece com o rótulo "Aviso da plataforma" | integração · `NotificationItem.spec.tsx` |
| CA8, CA23 | grava, lê e restaura a preferência; `notify` respeita o site | `notification-preferences.service.spec.ts` · integração · `NotificationSettingsPage.spec.tsx` |
| CA9 | `401`, `403` do `ADMIN` e `404` da notificação de outro usuário | integração |
| CA16 | uma `NEW_MESSAGE` por conversa não lida | `chat.service.spec.ts` · `notifications.service.spec.ts` · `tests/integration/chat/new-message-notification.spec.ts` (T14) |
| CA19 | contador e popup do sino | `NotificationBell.spec.tsx` |
| CA11–CA15, CA24 | prints em 1280 px iguais aos frames e sem quebra em 375/768/1024 px | validação no navegador (ADR-060, item 5) |

## Decisões técnicas

- `notificationsService.notify` é a única porta para criar notificação; as outras stories passam o tipo do enum.
- A publicação fica atrás da interface `SocketEmitter`, que o teste troca por um falso; a `api` usa o emitter do
  PostgreSQL e o `ws` usa o `io` (ADR-075).
- O contador vem em `meta.counts.UNREAD`; o evento em tempo real atualiza o cache das queries, sem nova chamada.
- O conteúdo indisponível (R8) é detectado pela página de destino, porque `referenceLink` é um caminho do site.
