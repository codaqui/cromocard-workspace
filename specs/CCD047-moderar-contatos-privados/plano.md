# Plano — CCD047 Moderar Contatos Privados

- **Spec:** [spec.md](spec.md)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-26 (refeito com as decisões L1–L12) · **Autor:** Daniel Andrade
- **Código lido:** backend e frontend `feature/1217-visualizar-mensagens` (CCD046, PRs #49 e #36): domínio e feature
  `chat`, `user_blocks` já no `schema.prisma`, Socket.IO; `develop`: `reports`, a Fila de moderação
  (`src/domains/community/admin/`, `src/features/community/admin/`), a sanção (`user-sanctions.service.ts`) e o upload
  (ADR-050)

## Solução

No topo da conversa (CCD046), o escudo abre o modal "Bloquear ou denunciar @<usuário>". "Somente bloquear" grava (ou
restaura) a linha de `user_blocks`. As opções com denúncia enviam um `multipart` com o motivo, a descrição e de 1 a 3
prints; a API grava `reports` (`USER`, `PENDING`), os prints em `report_evidences` e, em "Bloquear e denunciar", o
bloqueio, tudo numa transação. Com bloqueio ativo, o `message:send` é recusado nos dois sentidos, e a conversa troca o
campo de digitação pelo aviso de quem bloqueou (com "Desbloquear") ou de quem foi bloqueado. A Fila de moderação do
BackOffice passa a mostrar as denúncias do chat, com os prints, "Dispensar Denúncia" e "Aplicar sanção ao autor".

## Dependências

- **CCD046** (PRs #49 e #36): o domínio e a feature `chat`, `user_blocks`, o `message:send` e a lista de conversas. As
  branches desta spec saem empilhadas sobre elas.
- **CCD062** (na `develop`): a Fila de moderação, estendida aqui (L7; CCD062 L9).
- **CCD099** (na `develop`): a sanção ao usuário, chamada pelo card do chat.
- **ADR-050:** upload com `multer` e `StorageProvider`. **ADR-073:** `report_evidences`.
- **CCD051** (Gabriel): a linha "Contatos bloqueados" em Configurações usa o modal e a rota desta spec (L9).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `report_evidences` | não | `create_report_evidences_table` | copiada do DBML (ADR-073): `report_id` (FK), `url`, `sort_order` | R9, R16, R19 |
| `reports` | sim | — | `target_type = USER`, `target_user_id`, `reason` (texto do motivo), `description`, `status = PENDING` | R9, R18 |
| `user_blocks` | sim (CCD046) | — | bloquear restaura a linha com `deleted_at`; desbloquear preenche `deleted_at` | R6, R13 |

Seed: na conversa ana-carla, a Ana denuncia a Carla ("Spam", com um print de exemplo, só no banco local), para a fila e
o CA18; o bloqueio ana-bloqueia-gabriela (CCD046) serve ao CA9 e ao CA16.

## Regras

- **Contato** (R1): o `userId` tem de ser o outro participante de uma conversa do usuário; senão `404 CONTACT_NOT_FOUND`.
  Igual ao do usuário: `400 CANNOT_MODERATE_SELF`. Papéis `CUSTOMER` e `SELLER` (`403` para o `ADMIN`).
- **Bloquear** (R6): `upsert` no único `(blocker_id, blocked_id)`; a linha com `deleted_at` volta a `NULL` (CA8). Já
  bloqueado: responde o mesmo bloqueio, sem erro.
- **Denunciar** (R9, R16, R18): motivo um dos 4 textos (L4), `description` até 500, de 1 a 3 prints PNG, JPG ou WEBP até
  4 MB (`413` acima). Com denúncia `PENDING` do usuário contra o contato: `409 REPORT_ALREADY_PENDING`. Os prints sobem
  para `report-evidences/` antes da transação; se a transação falhar, os arquivos enviados são apagados do storage.
- **Bloquear e denunciar**: o mesmo pedido da denúncia com `block = true`; bloqueio, denúncia e evidências na mesma
  transação.
- **Envio no chat** (R7): `chatService.sendMessage` recusa com `422 CONTACT_BLOCKED` quando há `user_blocks` ativo em
  qualquer sentido; nada é gravado nem emitido.
- **Lista de conversas** (R8, R12, R17): cada item ganha `block: 'BY_ME' | 'BY_CONTACT' | null`.
- **Fila** (R19): `target_type IN (GROUP_MESSAGE, USER)`; a denúncia `USER` entra com `origin = 'CHAT'`, o autor é o
  `target_user`, sem mensagem e com as evidências. Gravidade: Críticos inclui "Golpe / pagamento externo" e "Assédio",
  Spam inclui "Spam". Dispensar vale para os dois tipos. A sanção pedida com o `reportId` de uma denúncia do chat resolve
  a denúncia (`RESOLVED`, `moderator_id`, `resolved_at`) na mesma transação.

## Contrato da API

Convenções do ADR-011. `ContactReportReason = 'Golpe / pagamento externo' | 'Assédio' | 'Spam' | 'Perfil falso'`.

### `POST /api/v1/me/blocks` — R1, R6

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "userId": "uuid" }`
- **Sucesso:** `201` `{ "data": { "userId": "uuid", "blockedAt": "iso" } }`
- **Erros:** `400 VALIDATION_ERROR` · `400 CANNOT_MODERATE_SELF` · `401` · `403` · `404 CONTACT_NOT_FOUND`

### `DELETE /api/v1/me/blocks/:userId` — R12, R13

- **Sucesso:** `204` · **Erros:** `400 VALIDATION_ERROR` · `401` · `403` · `404 BLOCK_NOT_FOUND` (sem bloqueio ativo)

### `GET /api/v1/me/blocks` — R14

- **Entrada:** `page`, `pageSize` (padrão 20)
- **Sucesso:** `200` `{ "data": [{ "userId", "name", "username", "avatarUrl", "blockedAt" }], "meta": { "page", "pageSize", "total", "totalPages" } }`

### `POST /api/v1/me/contact-reports` — R1, R4, R9, R16, R18

- **Entrada:** `multipart/form-data`: `userId`, `reason`, `description` (opcional), `block` (`true` em "Bloquear e
  denunciar"), `evidences` (1 a 3 arquivos)
- **Sucesso:** `201` `{ "data": { "id": "uuid", "status": "PENDING", "blocked": true } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | sem `reason`, motivo fora da lista, `description` > 500, sem print, mais de 3, tipo não aceito | R4, R16 |
  | 400 | `CANNOT_MODERATE_SELF` | `userId` é o próprio usuário | R1 |
  | 401 / 403 | `UNAUTHORIZED` / `FORBIDDEN` | sem token / `ADMIN` | R1 |
  | 404 | `CONTACT_NOT_FOUND` | sem conversa com o contato | R1 |
  | 409 | `REPORT_ALREADY_PENDING` | denúncia pendente do usuário contra o contato | R18 |
  | 413 | `FILE_TOO_LARGE` | print acima de 4 MB | R16 |

### Mudanças em contratos existentes

| Contrato | O que muda | Requisitos |
|---|---|---|
| `GET /me/conversations` e `POST /me/conversations` (CCD046) | cada conversa ganha `block: 'BY_ME' \| 'BY_CONTACT' \| null` | R8, R12, R17 |
| `message:send` (CCD046) | ack de erro `{ error: 'CONTACT_BLOCKED', message }` com bloqueio ativo (o ack do socket não leva status) | R7 |
| `GET /admin/community/reports` (CCD062) | inclui as denúncias `USER` com print; cada item ganha `origin: 'GROUP' \| 'CHAT'`, `reporterUsername`, `reportedUser` (`id`, `name`, `username`, `accountAgeDays`, `warnings`; só no chat) e `evidences` (lista de URLs); `message` nula na do chat | R19 |
| `GET /admin/community/summary` (CCD062) | "Denúncias pendentes" conta as do chat | R19 |
| `POST /admin/community/reports/:id/dismiss` (CCD062) | aceita a denúncia do chat | R19 |
| Sanção da CCD099 (`POST /users/:id/warn`, `/suspend`, `/block`) | as três aceitam `reportId` (antes só a advertência) e resolvem a denúncia do chat na mesma transação | R19 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `create_report_evidences_table` | modelo `ReportEvidence`, relação `evidences` em `Report` | R16 |
| `database/seeds/chat.seed.ts` · `data/conversations.json` | denúncia da Ana contra a Carla, com print no banco local | R19 |
| `src/domains/chat/moderation/contact-moderation.{validator,errors,repository,service,controller,routes,swagger}.ts` + `.service.spec.ts` | bloquear, desbloquear, listar bloqueados, denunciar (com bloqueio opcional) | R1, R4, R6, R9, R13, R14, R16, R18 |
| `src/domains/chat/chat.service.ts` · `chat.repository.ts` | `sendMessage` recusa com bloqueio; `block` na conversa | R7, R8, R12, R17 |
| `src/domains/chat/chat.module.ts` · `src/routes.ts` | rotas `/me/blocks` e `/me/contact-reports` | R1 |
| `src/domains/community/admin/community-admin.{validator,repository,service}.ts` | fila com `USER`, `origin`, `evidences`, gravidade, dispensar | R19 |
| `src/domains/users/user-sanctions.service.ts` | sanção com `reportId` do chat resolve a denúncia | R19 |
| `tests/integration/chat/contact-moderation.spec.ts` · `chat-socket.spec.ts` · `tests/integration/community-admin*.spec.ts` | rotas, envio recusado, fila | R1, R4, R6, R7, R9, R13, R14, R16–R19 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `features/chat/moderation/contact-moderation.{types,labels,api,queries}.ts` | opções, motivos, textos (L5), as 4 rotas | R3–R5, R10, R16 |
| `features/chat/components/ContactModerationDialog/` | modal do frame `1160-34298`: contato, opções, motivo, "Conte o que aconteceu", "Prints da conversa" com "+ Adicionar print" e as miniaturas, rodapé; com o contato já bloqueado, "Desbloquear" | R2–R5, R11, R12, R16, R18, R20 |
| `features/chat/components/BlockedNotice/` | aviso no lugar do campo: "Você bloqueou…" com "Desbloquear" (`1160-37184`) e "@… bloqueou você." | R8, R12, R13, R17 |
| `features/chat/components/BlockedContactsDialog/` | modal "Contatos bloqueados" com o total e "Desbloquear", exportado pelo `index.ts` para a CCD051 | R14 |
| `features/chat/components/ConversationHeader/` · `ConversationView/` (CCD046) | o escudo abre o modal; o aviso substitui o campo | R2, R8, R17 |
| `features/community/admin/components/ModerationQueue/ReportCard.tsx` · `community-admin.{types,labels}.ts` | card do chat (origem, prints, ações) e o subtítulo da fila | R19 |

- **Reaproveitados:** `Modal`, `Textarea`, `Button`, `Toast`, `FileUpload` (se servir aos 3 prints), `EmptyState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1–CA3 | bloqueio, denúncia e prints gravados conforme a opção; aviso e campo | `contact-moderation.service.spec.ts` · `contact-moderation.spec.ts` · `ContactModerationDialog.spec.tsx` |
| CA4, CA15 | `400` sem motivo ou print, mais de 3, tipo errado; `413`; a tela pede | integração · `ContactModerationDialog.spec.tsx` |
| CA5 | `message:send` recusado nos dois sentidos, nada gravado nem emitido | `chat.service.spec.ts` · `chat-socket.spec.ts` |
| CA6 | "Cancelar" e "✕" não chamam a API | `ContactModerationDialog.spec.tsx` |
| CA7, CA8 | desbloquear e bloquear de novo restaurando a linha | integração · `BlockedNotice.spec.tsx` |
| CA9 | "1 contato bloqueado" e desbloquear na lista | integração · `BlockedContactsDialog.spec.tsx` |
| CA10 | `401`, `403`, `400 CANNOT_MODERATE_SELF`, `404` | integração |
| CA16 | o aviso do bloqueado | `BlockedNotice.spec.tsx` · `ConversationView.spec.tsx` |
| CA17 | `409 REPORT_ALREADY_PENDING` e a nova depois de dispensada | integração · `ContactModerationDialog.spec.tsx` |
| CA18 | card do chat na fila, gravidade, dispensar e sanção resolvendo | `community-admin.service.spec.ts` · integração · `ReportCard.spec.tsx` |
| CA19 | erro mantém o modal | `ContactModerationDialog.spec.tsx` |
| CA11–CA13 | prints iguais aos frames `1160-32980`, `1160-34298`, `1160-37184`; 320–1920 px | navegador |

## Dependências e riscos

- Os PRs da CCD046 (#49 e #36) entram antes; depois, as branches desta spec são mescladas com a `develop`.
- O card do chat na fila não tem frame (o BackOffice do Figma não é editado): segue o estilo do card de grupo.
- O modal "Contatos bloqueados" só ganha a entrada em Configurações com a CCD051; até lá, desbloquear é pela conversa.
