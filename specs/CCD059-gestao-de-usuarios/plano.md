# Plano — CCD059 Gestão de Usuários

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22; revisão de 11/11/2026, reaprovada em 12/11/2026; revista em
  12/11/2026 (T11 — L9, L10)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Estende o domínio `users` (que já tem `GET /users` para ADMIN) com detalhe, criação com convite, edição, troca de
papel, suspensão, reativação e exclusão. As ações sensíveis pedem motivo, revogam sessões pelo `authService` e
gravam `audit_logs`. A tela existente `UsersListPage` ganha filtros, ações e os modais.

## Dependências

- Fundação (`AuditLogService`, `ConfirmDialog` com motivo, `Modal`, `Select`, `Badge`).
- CCD004 (`authService.revokeAllSessions`) e CCD006 (token de definir senha para o convite).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/users` | `q`, `role`, `status`, `page`, `pageSize`, `sort` | `200` `{ data, meta }` | `400` | R3, R16 |
| `GET /api/v1/users/:id` | — | `200` com `addresses[]` e `adminActions[]` (últimas 10 entradas do `audit_logs` com `entityType: 'user'` e `entityId` do usuário) | `404 USER_NOT_FOUND` | R4, R20 |
| `POST /api/v1/users` | `{ name, email, role }` | `201` + e-mail de convite | `400`, `409 EMAIL_ALREADY_REGISTERED` | R5, R10, R17 |
| `PATCH /api/v1/users/:id` | `{ name?, email?, role? }` | `200` | `400`, `404`, `409`, `422 CANNOT_CHANGE_OWN_ROLE`, `422 LAST_ADMIN` | R6, R7, R18 |
| `POST /api/v1/users/:id/suspend` | `{ reason }` | `200` | `404`, `409 ALREADY_SUSPENDED`, `422 CANNOT_SUSPEND_SELF` | R8, R14, R19 |
| `POST /api/v1/users/:id/reactivate` | — (sem corpo, L9) | `200` | `404`, `409 NOT_SUSPENDED` | R8, R19 |
| `DELETE /api/v1/users/:id` | `{ reason }` | `204` | `404`, `422 CANNOT_DELETE_SELF`, `422 LAST_ADMIN` | R9, R14 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/users.validator.ts` · `users.errors.ts` | schemas de admin e erros acima; busca passa a `q` (ADR-011) | R5–R11 |
| `users.repository.ts` | filtros, detalhe, criar, atualizar, mudar status, soft delete | R3–R9 |
| `admin-users.service.ts` + `.spec.ts` | regras de admin, convite, revogação, auditoria e reativação sem motivo (L9) | R5–R10, R14, R17–R19 |
| `users.routes.ts` · `users.controller.ts` · `users.swagger.ts` · `users.module.ts` | rotas novas | R1 |
| `addresses.repository.ts` (ou equivalente já existente) | ler os endereços do usuário no detalhe admin | R4, R20 |
| `tests/integration/admin-users.spec.ts` | fluxo completo | CA1–CA9 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/users/users.api.ts` · `.queries.ts` · `.schemas.ts` · `.labels.ts` | chamadas e schemas, inclusive `reactivate` sem corpo | R5–R9, R19 |
| `pages/UsersListPage/` · `components/UsersTable/` | filtros, ações por linha, `Badge` de status e papel | R2–R4 |
| `pages/UserDetailPage/` | "Membro desde", indicador de status, advertências, quadro "Autenticação", endereços e "Ações administrativas" (histórico do `audit_logs`) | R4, R20, CA10, CA11 |
| `components/UserFormModal/` + `hooks/useUserForm.ts` | criar e editar (nome, e-mail, papel); checkbox "Reenviar link de ativação" na edição quando `!emailVerified` (CCD098 R15) | R5–R7, R11–R13 |
| `components/SuspendUserDialog/` · `DeleteUserDialog/` | `ConfirmDialog` com motivo para suspender/excluir; reativar vira confirmação simples, sem motivo (L9) | R8, R9, R14, R19 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA7 | `admin-users.service.spec.ts` · integração |
| CA2, CA6, CA8 | `UserFormModal.spec.tsx` · `DeleteUserDialog.spec.tsx` |
| CA9 | integração |
| CA10, CA11 | `admin-users.service.spec.ts` · `UserDetailPage.spec.tsx` |
| CA5 (reativar sem motivo) | `SuspendUserDialog.spec.tsx` · integração |

## Revisão de 11/11/2026 (L7, L8)

- R3: a lista ganha a coluna de data de cadastro (`createdAt`) e mostra os papéis como Cliente, Vendedor e
  Administrador.
- R4: em vez do detalhe na própria lista, a seleção abre `/backoffice/users/:id` (página do usuário). O
  `GET /api/v1/users/:id` devolve também os endereços e `adminActions` (últimas entradas do `audit_logs` com
  `entityType: 'user'` e `entityId` do usuário).
- Testes: CA1 inclui as colunas; CA10 é novo (`admin-users.service.spec.ts` e `UserDetailPage.spec.tsx`).

## Revisão de 12/11/2026 (T11 — L9, L10)

- R19: a reativação deixa de exigir motivo; `POST /users/:id/reactivate` não recebe corpo, e o caso de uso 59 ganha o
  passo FP 11–12 só para a reativação.
- R20 (novo): a página do usuário ganha "Membro desde", o indicador de status (Ativo/Suspenso/Bloqueado) e o quadro
  "Autenticação" (`Login com Google`/`E-mail e senha` e desde quando, a partir de `oauth_identities` e
  `password_account`); "Aplicar sanção" e o status "Bloqueado" aparecem, mas indisponíveis (CCD099). Na própria conta
  do admin, "Aplicar sanção" e "Excluir ou alterar o papel" também aparecem indisponíveis (R18, já implementado).
- O reenvio do link de ativação (CCD098 R15) sai do botão da página de detalhe e vira o checkbox "Reenviar link de
  ativação" dentro do `UserFormModal` em modo de edição, condicional a `!emailVerified` — ver
  `specs/CCD098-gerenciar-dados-complementares-do-usuario/plano.md`.
- Testes: CA11 é novo (`UserDetailPage.spec.tsx`); CA5 passa a cobrir a reativação sem motivo.
