# Tarefas — CCD053 Visualizar Notificações

- **Plano:** [plano.md](plano.md) · **User story:** AB#1294
- Tarefas refeitas em 28/11/2026 com a spec Aprovada. Ordem de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Backend e frontend saem da `develop`. A T14 ia sair empilhada no chat pessoal, mas o chat (#49) entrou na `develop` e ela foi feita na branch do backend.

## Docs — workspace

- [x] **T1** · Registrar no DBML e em ADR onde gravar as preferências de aviso — R11 · AB#1295
  - Pronto quando: `notification_preferences` está nos três `.dbml` e no diagrama de classes, com o ADR-074 e o ADR-075.

## Backend — `apps/cromocard-backend`, branch `feature/1294-visualizar-notificacoes`

- [x] **T2** · Criar tipos, repository e service da central de notificações — R1–R6, R10, R14, R15, R20 · CA1–CA3, CA7, CA17, CA18 · AB#1296
  - Pronto quando: `notifications.service.spec.ts` cobre ordem, cursor, filtros, contagens, marcar como lida e a de outro usuário (`404`).
- [x] **T3** · Criar notify com preferência e emissão de notification:new pelo adapter do PostgreSQL — R9, R18, R21 · CA6, CA21, CA23 · AB#1297
  - Pronto quando: `notify` não grava com o site desligado, grava e publica só para `user:<id>`, não publica se a gravação falha, e o disparo global publica para os gravados.
- [x] **T4** · Criar endpoints GET /notifications e PATCH /notifications/:id/read — R1–R6, R14, R15 · CA1–CA3, CA9 · AB#1298
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/notifications/notifications.spec.ts` cobre `200`, `400`, `401`, `403` e `404`.
- [x] **T5** · Criar endpoints de preferências de aviso — R11, R21 · CA8, CA23 · AB#1299
  - Pronto quando: `GET`, `PUT` e `DELETE /me/notification-preferences` gravam, devolvem e restauram, com a integração cobrindo `400`.
- [x] **T6** [P] · Criar seed de notificações do cliente — R2–R5 · AB#1300
  - Pronto quando: o cliente do seed tem notificações lidas, não lidas, com e sem `reference_link`, uma `GLOBAL` e uma `NEW_MESSAGE`.

## Frontend — `apps/cromocard-frontend`, branch `feature/1294-visualizar-notificacoes`

- [x] **T7** [P] · Criar tipos, api, queries e rótulos das notificações — R2–R6, R14, R15, R20 · AB#1301
  - Pronto quando: o typecheck passa e os `.spec.ts` cobrem as chamadas, os rótulos e o grupo HOJE/ANTERIORES.
- [x] **T8** · Criar página da central de notificações — R2–R7, R14, R15, R17, R19 · CA1–CA4, CA10, CA11, CA12, CA17, CA18, CA20, CA22, CA24 · AB#1302
  - Pronto quando: `NotificationsPage.spec.tsx` e `NotificationItem.spec.tsx` cobrem lista, filtros, grupos, carregar mais, ✓, menu, "Tudo em dia!", vazio, carregando e erro; prints iguais a `490-796`, `675-12111` e `675-11716` e sem quebra em 375/768/1024 px.
- [x] **T9** · Criar aviso de conteúdo indisponível ao abrir notificação — R8 · CA5 · AB#1303
  - Pronto quando: `NotFoundPage.spec.tsx` mostra "Este conteúdo não está mais disponível." com `state.fromNotification`.
- [x] **T10** · Criar aviso em tempo real de notificação nova — R9 · CA6, CA13 · AB#1304
  - Pronto quando: `useNotificationsSocket.spec.tsx` cobre o aviso e o contador +1 em qualquer tela; print igual a `675-13070`.
- [x] **T11** · Criar página de Configurações com as preferências de aviso — R11 · CA8, CA15 · AB#1305
  - Pronto quando: `NotificationSettingsPage.spec.tsx` cobre salvar, restaurar e reabrir; print igual a `1160-41305` nos blocos de aviso.
- [x] **T12** · Criar sino com contador e popup de notificações — R15, R16 · CA14, CA19 · AB#1306
  - Pronto quando: `NotificationBell.spec.tsx` cobre o contador e o popup; print igual a `1124-22490`.

## Chat pessoal — backend, na branch `feature/1294-visualizar-notificacoes`

- [x] **T14** · Notificar mensagem nova com NEW_MESSAGE, uma por conversa — R13 · CA16 · AB da user story (#1294)
  - Pronto quando: `chat.service.spec.ts`, `notifications.service.spec.ts` e a integração cobrem a primeira mensagem notificando e a segunda não, enquanto a anterior não for lida.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1307
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T4, T5 |
| R2–R6 | T2, T4, T7, T8 |
| R7, R19 | T8 |
| R8 | T9 |
| R9, R18 | T3, T10 |
| R10 | T2, T3, T6 |
| R11, R21 | T1, T3, T5, T11 |
| R12 | T8, T10, T11, T12 |
| R13 | T14 |
| R14, R15 | T2, T4, T7, T8, T12 |
| R16 | T12 |
| R17 | T8 |
| R20 | T2, T7 |
