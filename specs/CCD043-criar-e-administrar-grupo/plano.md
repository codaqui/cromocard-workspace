# Plano — CCD043 Criar e Administrar Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L21 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Criar grupo" (cartão "Crie seu grupo de graça" e botão em "Comunidades") abre o formulário; a capa sobe pelo upload de
imagens e o `POST /groups` grava o grupo e o criador como `ADMIN`, abrindo a tela do grupo. O administrador abre a
página de administração (`/comunidades/:id/administrar`) pelo ícone de membros do chat: aba "Solicitações" (aprovar ou
recusar) e aba "Membros" (promover, remover), mais editar e excluir o grupo. Fixar e desafixar é uma ação do
administrador sobre a mensagem, no chat.

## Dependências

- CCD039: domínio `community/groups/`, `group-access.ts` (`assertGroupAdmin`), `group_join_requests` e a página
  "Comunidades".
- CCD044: tela do grupo (`/comunidades/:id`), destino depois de criar, e o `PinnedMessageBanner` do CA9.
- Upload de imagens (`src/domains/uploads/`): hoje só `ADMIN` e pastas `cards`, `albums`, `banners`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `groups` | sim | — | criada, editada e excluída (soft delete) |
| `group_members` | sim | — | criador `ADMIN`; aprovar faz `upsert` (ADR-015, item 7); remover grava `deleted_at` |
| `group_join_requests` | sim, pela CCD039 | — | `status`, `reviewed_by_id`, `reviewed_at` |
| `group_messages` | sim | — | `pinned` |
| `profiles`, `users` | sim | — | nome, `username`, cidade e avatar na lista de solicitações |

## Regras

- **Criar:** `CUSTOMER` e `SELLER` (L1 da CCD039); `name` 1–120 sem espaços nas pontas, `description` opcional (depende
  da L2), `coverImageUrl` opcional, `accessType` obrigatório e sem valor inicial no formulário (depende da L7). Formulário
  único, etapas só como guia visual (depende da L1).
- **Administrar:** `assertGroupAdmin`; grupo excluído responde `404`, suspenso permite administrar.
- **Aprovar/recusar:** só `PENDING`; aprovar faz `upsert` do membro (`deleted_at = null`, `role = MEMBER`,
  `muted_until = null`) na mesma transação.
- **Remover:** não remove o criador nem o último `ADMIN` (depende da L12); o removido sai da room no próximo `group:join`
  (o acesso é checado em cada evento, CCD044).
- **Função:** só promover `MEMBER` → `ADMIN`; rebaixar depende da L13.
- **Excluir:** `deleted_at` no grupo, sem restaurar pela tela (depende da L21).
- **Fixar:** sem limite de fixadas e sem guardar quem fixou (depende da L15); mensagem excluída responde `404`.
- **Avisos:** sem aviso ao solicitante nem ao removido até a L19; sucesso com `Toast` (depende da L20).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')`; as rotas `/:id/...` exigem `assertGroupAdmin`
(`403 NOT_GROUP_ADMIN`). Grupo inexistente ou excluído: `404 GROUP_NOT_FOUND`.

| Método e caminho | Entrada | Sucesso | Erros próprios | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/groups` | `{ name, description?, coverImageUrl?, accessType }` | `201` `{ data: Group }` | `400 VALIDATION_ERROR`, `401` | R1–R8 |
| `PATCH /api/v1/groups/:id` | os mesmos campos, todos opcionais | `200` `{ data: Group }` | `400 VALIDATION_ERROR` | R12 |
| `DELETE /api/v1/groups/:id` | — | `204` | — | R13 |
| `GET /api/v1/groups/:id/join-requests` | `page`, `pageSize` | `200` `{ data: JoinRequest[], meta }`, da mais antiga à mais nova | — | R9, R15 |
| `POST /api/v1/groups/:id/join-requests/:requestId/approve` | — | `200` `{ data: JoinRequest }` | `404 JOIN_REQUEST_NOT_FOUND`, `409 JOIN_REQUEST_ALREADY_REVIEWED` | R9 |
| `POST /api/v1/groups/:id/join-requests/:requestId/reject` | — | `200` `{ data: JoinRequest }` | os mesmos | R9 |
| `GET /api/v1/groups/:id/members` | `page`, `pageSize` | `200` `{ data: Member[], meta }` | — | R15 |
| `PATCH /api/v1/groups/:id/members/:userId` | `{ role: 'ADMIN' }` | `200` `{ data: Member }` | `404 MEMBER_NOT_FOUND` | R11 |
| `DELETE /api/v1/groups/:id/members/:userId` | — | `204` | `404 MEMBER_NOT_FOUND`, `422 CANNOT_REMOVE_CREATOR`, `422 LAST_GROUP_ADMIN` (depende da L12) | R10 |
| `PUT /api/v1/groups/:id/messages/:messageId/pin` | `{ pinned: boolean }` | `200` `{ data: { id, pinned } }` | `404 GROUP_MESSAGE_NOT_FOUND` | R14 |
| `POST /api/v1/uploads` (existente) | pasta nova `groups` | `201` | `403` para `CUSTOMER`/`SELLER` em outra pasta | R5 |

```ts
Group = { id, name, description, coverImageUrl, accessType, status, createdAt }
JoinRequest = { id, status, createdAt, reviewedAt, user: { id, name, username, city, avatarUrl } }
Member = { userId, name, username, avatarUrl, role, joinedAt }   // joinedAt = group_members.created_at
```

A CA2 da spec diz `422` para o formulário sem nome; pelo ADR-011, validação de entrada é `400 VALIDATION_ERROR`, e o
plano segue o ADR.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/groups/` (da CCD039).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `groups.validator.ts` | `createGroupSchema`, `updateGroupSchema`, `changeMemberRoleSchema`, `pinMessageSchema` | R3–R7, R11, R12, R14 |
| `groups.repository.ts` | criar com o membro `ADMIN` numa transação, editar, excluir | R8, R12, R13 |
| `groups.service.ts` | `create`, `update`, `remove` | R1, R8, R12, R13 |
| `group-administration.repository.ts` · `group-administration.service.ts` | solicitações, membros, função, remoção, fixar | R9–R11, R14, R15 |
| `groups.controller.ts` · `groups.routes.ts` · `groups.swagger.ts` · `groups.errors.ts` | as rotas e os erros novos | R1 |
| `src/domains/uploads/uploads.validator.ts` · `uploads.routes.ts` · `uploads.service.ts` | pasta `groups` liberada para `CUSTOMER` e `SELLER`; as outras continuam só `ADMIN` | R5 |
| `database/seeds/community.seed.ts` | membros e solicitações do frame `675-16465` | R9, R15 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/community/groups/` (da CCD039).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `group-admin.types.ts` · `group-admin.api.ts` · `group-admin.queries.ts` · `groups.schemas.ts` | API e validação do formulário (Zod) | R3–R15 |
| `components/CreateGroupCard/` | cartão "Crie seu grupo de graça" com "Criar grupo" no frame `417-2915` | R2, R16 |
| `pages/CreateGroupPage/` · `components/GroupForm/` | formulário do frame `417-2581` (capa com `FileUpload`, acesso, sem foto do grupo, cidade e regras: L3, L5, L6); erros nos campos (R7, não desenhado) | R2–R8, R16 |
| `pages/EditGroupPage/` | o mesmo `GroupForm` preenchido, no estilo do frame `417-2581` (sem frame, L14) | R12 |
| `pages/GroupAdminPage/` | administração do frame `675-16465`: abas "Solicitações" e "Membros", "Editar" e "Excluir" | R9–R11, R13, R15, R16 |
| `components/JoinRequestsList/` · `components/MembersTable/` | "Aprovar"/"Recusar"; função (só "Admin" e "Membro", L8), entrada e "Remover", sem "Banir" (L9) | R9–R11, R15 |
| `components/DeleteGroupDialog/` | confirmação com `ConfirmDialog` (sem frame, L14) | R13 |
| `features/community/chat/components/MessageBubble/` (CCD044) | "Fixar"/"Desafixar" para o administrador, no menu de ações da mensagem (L15; menu da L5 da CCD040) | R14 |
| `community.routes.ts` · `routes/paths.ts` | `/comunidades/novo`, `/comunidades/:id/administrar`, `/comunidades/:id/editar`, com `RequireAuth` | R1, R2 |

- **Estados:** carregando, erro e vazio (sem solicitações, sem membros) com `LoadingState`, `ErrorState` e `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** `FormField`, `TextField`, `Textarea`, `FileUpload`, `Tabs`,
  `DataTable`, `Select`, `ConfirmDialog`, `Pagination`, `Toast`, `Button`, `Badge`.
- Fora do frame até decisão: "Moderador" (L8), "Banir" (L9), "Convidar membros" (L10), texto do solicitante (L11),
  cabeçalho com online e contagens (L16), online e denúncias na coluna Membro (L17), "Buscar membro..." (L18), abas
  "Denúncias" e "Mensagens fixadas" (L15; L9 da CCD040).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | grava grupo `CLOSED`/`ACTIVE` e o criador `ADMIN`; abre a tela do grupo | `groups.service.spec.ts` · `tests/integration/groups.spec.ts` · `CreateGroupPage.spec.tsx` |
| CA2 | sem nome ou sem acesso: erro no campo; a API responde `400` | `groups.validator.spec.ts` · integração · `GroupForm.spec.tsx` |
| CA3, CA4 | aprovar vira `MEMBER` (restaurando a linha), recusar não; `reviewed_*` gravados | `group-administration.service.spec.ts` · integração · `JoinRequestsList.spec.tsx` |
| CA5 | remover grava `deleted_at`; criador e último admin recusados | `group-administration.service.spec.ts` · integração |
| CA6 | promover a `ADMIN` | `group-administration.service.spec.ts` · `MembersTable.spec.tsx` |
| CA7 | editar nome e acesso | integração · `EditGroupPage.spec.tsx` |
| CA8 | excluir com confirmação; cancelar não muda nada; o grupo some da lista | integração · `DeleteGroupDialog.spec.tsx` |
| CA9 | fixar e desafixar | integração · `MessageBubble.spec.tsx` |
| CA10 | `401` sem token; `403` para `MEMBER` em cada rota de administração | integração |
| CA11–CA13 | print em 1280 px igual aos frames `417-2581`, `675-16465` e `417-2915`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- Foto do grupo (L3), cidade (L5), regras (L6), moderador (L8), banimento (L9), convite (L10), texto do solicitante
  (L11) e quem fixou (L15) exigem PR de docs no DBML antes do código, se aceitos.
- A tela de editar e a confirmação de exclusão não têm frame (L14): seguem o estilo do `417-2581` até o Gabriel desenhar.
- Fixar depende do menu de ações da mensagem (L5 da CCD040), que esta story e a CCD040 usam.

## Decisões técnicas

- Criar o grupo e o membro `ADMIN` numa transação, para nunca haver grupo sem administrador.
- O upload da capa reaproveita `POST /uploads` com a pasta `groups` liberada para o cliente, em vez de uma rota nova; a
  regra de quem sobe em cada pasta fica no `uploads.service.ts`. Se o PO entender que isso muda o ADR-050, vira ADR novo.
- A administração fica num service próprio (`group-administration`), separado do CRUD do grupo, para manter os services
  pequenos (SRP).
