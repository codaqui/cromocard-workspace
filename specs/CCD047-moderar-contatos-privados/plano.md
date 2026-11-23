# Plano — CCD047 Moderar Contatos Privados

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps (`Report` e o enum `ReportTargetType` já estão
  no `schema.prisma`; `user_blocks` não; o domínio `chat` é criado pela CCD046)

## Solução

No topo da conversa (CCD046), o escudo abre o modal "Bloquear ou denunciar @<usuário>". A opção escolhida vai para a API:
bloquear grava (ou restaura) a linha de `user_blocks` e, junto, pode gravar a denúncia em `reports` numa transação; só
denunciar grava `reports`. Com bloqueio ativo nos dois sentidos, a service do chat recusa o `message:send` e a conversa
troca o campo de digitação pelo aviso de contato bloqueado. Em Configurações › Privacidade (CCD051), "Contatos bloqueados"
mostra o total e a lista, com desbloquear.

## Dependências

- **CCD046:** o domínio `chat` (participação, `chatService.sendMessage`, lista e topo da conversa).
- **CCD044:** o servidor Socket.IO, pelo `message:send` da CCD046.
- **CCD051:** a página "Configurações" e o bloco "Privacidade", onde entra a linha "Contatos bloqueados" (T9).
- A CCD045 reaproveita a checagem de bloqueio desta story (R11 dela).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `user_blocks` | não | `create_user_blocks_table` | copiada do DBML: `id`, `blocker_id`, `blocked_id`, colunas de tempo, único `(blocker_id, blocked_id)` | R6, R7, R13, R14 |
| `reports` | sim | — | grava `target_type = USER` (depende da L7), `target_user_id`, `reason`, `description`, `status = PENDING` | R9 |

Seed: Gabriel com Marcos bloqueado numa conversa, para CA9 e o frame `1160-37184`.

## Regras

- **Contato:** o `userId` tem que ser o outro participante de uma conversa não excluída do usuário; senão
  `404 CONTACT_NOT_FOUND`. `userId` igual ao do usuário: `400 CANNOT_MODERATE_SELF` (R1, CA10).
- **Bloquear:** `upsert` no único `(blocker_id, blocked_id)`; se a linha existe com `deleted_at`, volta a `NULL` (R6, CA8).
  Já bloqueado e ativo: responde o mesmo bloqueio, sem erro (idempotente).
- **Bloquear e denunciar:** bloqueio e denúncia na mesma transação (`runInTransaction`); se uma falhar, nada é gravado.
- **Motivo:** um dos quatro textos da tela, gravado como está em `reports.reason` (depende da L4); `description` até 500.
- **Denunciar de novo:** cria outra denúncia (depende da L11, sem proposta; o plano não recusa).
- **Bloqueio no envio:** `chatService.sendMessage` recusa com `422 CONTACT_BLOCKED` quando há `user_blocks` ativo em
  qualquer sentido entre os dois participantes; nada é gravado nem emitido (R7, CA5; depende da L6 para o texto de quem
  foi bloqueado).
- **Desbloquear:** preenche `deleted_at` da linha ativa (R13).
- **Papéis:** `CUSTOMER` e `SELLER` (depende da L12).

## Contrato da API

Convenções do ADR-011. `ModerationReason = 'Golpe / pagamento externo' | 'Assédio' | 'Spam' | 'Perfil falso'` (L4).

### `POST /api/v1/me/blocks` — R1, R3, R5, R6, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "userId": "uuid", "report": { "reason": "Golpe / pagamento externo", "description": "string até 500" } }`
  (`report` só em "Bloquear e denunciar")
- **Sucesso:** `201` `{ "data": { "userId": "uuid", "blockedAt": "iso", "reportId": "uuid" | null } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `report` sem `reason`, motivo fora da lista, `description` > 500 | R4 |
  | 400 | `CANNOT_MODERATE_SELF` | `userId` é o próprio usuário | R1 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 404 | `CONTACT_NOT_FOUND` | sem conversa com o contato, ou contato excluído | R1 |

### `POST /api/v1/me/contact-reports` — R1, R3, R4, R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "userId": "uuid", "reason": "Spam", "description": "string até 500" }`
- **Sucesso:** `201` `{ "data": { "id": "uuid", "status": "PENDING" } }`
- **Erros:** os mesmos do `POST /me/blocks` (`400 VALIDATION_ERROR` sem `reason`, `400 CANNOT_MODERATE_SELF`, `401`,
  `404 CONTACT_NOT_FOUND`).

### `GET /api/v1/me/blocks` — R14

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `page`, `pageSize`
- **Sucesso:** `200` `{ "data": [{ "userId", "name", "username", "avatarUrl", "blockedAt" }], "meta": { "page", "pageSize", "total" } }`
  (o `total` alimenta "1 contato bloqueado")
- **Erros:** `401`.

### `DELETE /api/v1/me/blocks/:userId` — R12, R13

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Sucesso:** `204`
- **Erros:** `400 VALIDATION_ERROR` (`userId` não é UUID), `401`, `404 BLOCK_NOT_FOUND` (não há bloqueio ativo).

### Mudanças em contratos da CCD046 — R2, R7, R8, R12

| Contrato | O que muda | Requisitos |
|---|---|---|
| `GET /me/conversations` | cada item ganha `block: 'BY_ME' \| 'BY_CONTACT' \| null` (o `createdAt` já dá "conversa desde") | R2, R8, R12 |
| `message:send` (Socket.IO) | ack de erro `{ error: 'CONTACT_BLOCKED', status: 422 }` com bloqueio ativo | R7 |

## Backend — `apps/cromocard-backend`

No domínio `src/domains/chat/` (CCD046), no modelo de `src/domains/users/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `create_user_blocks_table` | modelo `UserBlock`, relações `blocksMade`/`blocksReceived` em `User` | R6, R13 |
| `database/seeds/chat.seed.ts` · `data/conversations.json` | Marcos bloqueado por Gabriel | R8, R14 |
| `user-blocks.validator.ts` | `blockSchema`, `contactReportSchema`, motivos (L4), `description` até 500 | R4 |
| `user-blocks.errors.ts` | `CannotModerateSelfError`, `ContactNotFoundError`, `BlockNotFoundError`, `ContactBlockedError` | R1, R7, R13 |
| `user-blocks.repository.ts` | `upsert`/restaurar, desbloquear, listar com total, `hasActiveBlockBetween`, gravar `reports` | R6, R9, R13, R14 |
| `user-blocks.service.ts` + `.spec.ts` | bloquear (com denúncia na transação), só denunciar, desbloquear, listar | R1, R3, R6, R9, R13, R14 |
| `user-blocks.controller.ts` · `.routes.ts` · `.swagger.ts` · `user-blocks.module.ts` | rotas `/me/blocks` e `/me/contact-reports` | R1 |
| `chat.service.ts` · `chat.repository.ts` (CCD046) | `sendMessage` chama `hasActiveBlockBetween`; a lista devolve `block` | R7, R8, R12 |
| `src/routes.ts` | registra o `userBlocksModule` | R1 |
| `tests/integration/chat-blocks.spec.ts` · `chat-socket.spec.ts` (CCD046) | rotas e o envio recusado | R1, R4, R6, R7, R9, R13, R14 |

## Frontend — `apps/cromocard-frontend`

Na feature `src/features/chat/` (CCD046) e na página de Configurações (CCD051).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `user-blocks.types.ts` · `user-blocks.schemas.ts` · `user-blocks.labels.ts` | opções, motivos e textos ("Somente bloquear"…, avisos pela L5) | R3, R4, R10 |
| `user-blocks.api.ts` · `user-blocks.queries.ts` | as 4 rotas; invalidam a lista de conversas | R6, R9, R13, R14 |
| `components/ContactModerationDialog/` | modal "Bloquear ou denunciar @<usuário>" com contato, opções, motivo, "Conte o que aconteceu", "Cancelar"/"✕" e o rodapé — frame `1160-34298` | R2–R5, R11 |
| `components/ConversationView/` (CCD046) | botão de escudo no topo — frame `1160-32980`; aviso "Você bloqueou @…" no lugar do campo, com desbloquear (L8) — frame `1160-37184` | R2, R8, R12, R13 |
| `components/BlockedContactsDialog/` | lista "Ver bloqueados" com desbloquear, no estilo da tela (sem frame, L9) | R13, R14 |
| `features/users/pages/SettingsPage/` (CCD051) · `components/PrivacySection/` | linha "Contatos bloqueados" com "1 contato bloqueado" e "Ver bloqueados" — frame `1160-41305` | R14 |

- **Reaproveitados:** `Modal`, `Select` ou `Checkbox` (opções), `Textarea`, `Button`, `Toast` (aviso "Contato bloqueado e
  denunciado"), `EmptyState` (lista vazia).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | bloqueio e denúncia `PENDING` gravados juntos; aviso e campo trocado | `user-blocks.service.spec.ts` · `chat-blocks.spec.ts` · `ContactModerationDialog.spec.tsx` |
| CA2 | só `user_blocks`, sem denúncia | `user-blocks.service.spec.ts` · `ContactModerationDialog.spec.tsx` |
| CA3 | só `reports`; o campo continua | `user-blocks.service.spec.ts` · `ContactModerationDialog.spec.tsx` |
| CA4 | `400` sem `reason`; a tela pede o motivo | `chat-blocks.spec.ts` · `ContactModerationDialog.spec.tsx` |
| CA5 | `message:send` dos dois lados recusado com `422 CONTACT_BLOCKED`, nada gravado nem emitido | `chat.service.spec.ts` · `chat-socket.spec.ts` |
| CA6 | "Cancelar" e "✕" não chamam a API | `ContactModerationDialog.spec.tsx` |
| CA7 | desbloquear preenche `deleted_at` e o campo volta | `chat-blocks.spec.ts` · `ConversationView.spec.tsx` |
| CA8 | bloquear de novo restaura a mesma linha | `user-blocks.service.spec.ts` · `chat-blocks.spec.ts` |
| CA9 | "1 contato bloqueado" e a lista com desbloquear | `chat-blocks.spec.ts` · `PrivacySection.spec.tsx` · `BlockedContactsDialog.spec.tsx` |
| CA10 | `401` sem login; `400 CANNOT_MODERATE_SELF` | `chat-blocks.spec.ts` |
| CA11–CA14 | print em 1280 px igual aos frames `1160-32980`, `1160-34298`, `1160-37184` e `1160-41305`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- `target_type` segue a proposta implícita da R9 (`USER`), mas depende da L7; a fila do BackOffice (CCD062) não mostra
  denúncia de usuário até alguém planejar isso (fora do escopo).
- L3 ("Anexar as últimas 20 mensagens") não entra: o DBML não tem onde guardar; se o PO quiser, é PR de docs no DBML antes.
- L1 ("remover contato"), L5 (textos), L8 (desbloquear na conversa ou só em Configurações), L9 (frame da lista), L10 e L11
  podem mudar a tela; o plano segue a documentação (desbloquear na hora, `47` FA 3).
- A linha de Configurações depende da página da CCD051.

## Decisões técnicas

- "Bloquear e denunciar" vai num só `POST /me/blocks` com `report` opcional, para gravar os dois na mesma transação; "Somente
  denunciar" tem rota própria porque não cria bloqueio.
- Os bloqueios ficam no domínio `chat`, que é quem os consulta no envio (ADR-012, "valida o bloqueio").
