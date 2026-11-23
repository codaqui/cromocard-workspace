# Tarefas — CCD053 Visualizar Notificações

- **Plano:** [plano.md](plano.md) · **User story:** AB#1294
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende do servidor Socket.IO da CCD044 e do domínio `notifications` da CCD060.

## Docs — workspace

- [ ] **T1** · Registrar no DBML e em ADR onde gravar as preferências de aviso — R11 · AB#1295
  - Pronto quando: a L10 está decidida e os três `.dbml` têm a estrutura das preferências (PR de docs mergeado).

## Backend — `apps/cromocard-backend`, branch `feature/1294-visualizar-notificacoes`

- [ ] **T2** · Criar repository e service da central de notificações — R1–R6, R10 · CA1–CA3, CA7, CA9 · AB#1296
  - Pronto quando: `notifications.service.spec.ts` cobre ordem, `unreadCount`, marcar como lida e a de outro usuário (`404`).
- [ ] **T3** · Criar notify com emissão de notification:new na room do usuário — R9, R10 · CA6, CA7 · AB#1297
  - Pronto quando: `notify` grava e emite só para `user:<id>`, não emite se a gravação falha, e a entrega da CCD060 emite para cada destinatário.
- [ ] **T4** · Criar endpoints GET /notifications e PATCH /notifications/:id/read — R1–R6 · CA1–CA3, CA9 · AB#1298
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/notifications.spec.ts` cobre `200`, `401`, `403` (ADMIN, depende da L1) e `404`.
- [ ] **T5** · Criar endpoints de preferências de aviso — R11 · CA8 · AB#1299
  - Pronto quando: depois da T1, `GET` e `PUT /me/notification-preferences` gravam e devolvem as preferências, com 90% de cobertura.
- [ ] **T6** [P] · Criar seed de notificações do cliente — R2–R5 · AB#1300
  - Pronto quando: o cliente do seed tem notificações lidas, não lidas, com e sem `reference_link` e uma `GLOBAL`.

## Frontend — `apps/cromocard-frontend`, branch `feature/1294-visualizar-notificacoes`

- [ ] **T7** [P] · Criar tipos, api, queries e rótulos das notificações — R2–R6 · AB#1301
  - Pronto quando: o typecheck passa e `notifications.api.spec.ts` cobre a lista e marcar como lida.
- [ ] **T8** · Criar página da central de notificações — R2–R7, R12 · CA1–CA4, CA10, CA11, CA12 · AB#1302
  - Pronto quando: `NotificationsPage.spec.tsx` e `NotificationItem.spec.tsx` cobrem lista, destaque, abrir com e sem link, vazia, carregando e erro; print em 1280 px igual aos frames `490-796` e `675-12111` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar aviso de conteúdo indisponível ao abrir notificação — R8 · CA5 · AB#1303
  - Pronto quando: `NotFoundPage.spec.tsx` mostra o aviso com `state.fromNotification` (texto depende da L3).
- [ ] **T10** · Criar aviso em tempo real de notificação nova — R9, R12 · CA6, CA13 · AB#1304
  - Pronto quando: `useNotificationsSocket.spec.tsx` cobre toast e contador +1 em qualquer tela do cliente; print em 1280 px igual ao frame `675-13070` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar blocos de preferências de aviso em Configurações — R11, R12 · CA8, CA15 · AB#1305
  - Pronto quando: depois da T5, `NotificationPreferences.spec.tsx` cobre salvar e reabrir; print em 1280 px igual ao frame `1160-41305` e sem quebra em 375/768/1024 px.
- [ ] **T12** · Criar sino com contador e popup de notificações — R2–R6, R9, R12 · CA14 · AB#1306
  - Pronto quando: só com a L6 aprovada; print em 1280 px igual ao frame `1124-22490` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1307
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T4, T5 |
| R2, R3 | T2, T4, T7, T8, T12 |
| R4 | T2, T7, T8 |
| R5, R6 | T2, T4, T7, T8 |
| R7 | T8 |
| R8 | T9 |
| R9 | T3, T10 |
| R10 | T2, T3, T6 |
| R11 | T1, T5, T11 |
| R12 | T8, T10, T11, T12 |
