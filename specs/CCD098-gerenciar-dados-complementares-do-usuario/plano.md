# Plano — CCD098 Gerenciar Dados Complementares do Usuário

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com as colunas novas de `users`; o domínio `users` (CCD059) aceita, valida e busca pelos dados complementares; o `auth` grava o último acesso e aceita o @ no login; o frontend acrescenta colunas, campos, detalhe e a confirmação reforçada.

## Dependências

- CCD059 (gestão de usuários).
- CCD004 (login) — a mudança no `auth.service` é combinada com o Daniel.
- CCD094 (CNPJ).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `users` | `add_profile_fields_to_users_table` | `username`, `phone`, `cpf`, `last_login_at`, `last_login_ip` | R2, R4, R8 |
| `seller_verifications` | `create_seller_verifications_table` | tabela copiada do DBML (CCD094), criada aqui só para viabilizar a busca por CNPJ (R3/L2); `address_id` fica como coluna solta, sem FK, até a CCD094 criar `addresses` | R3 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/users` (CCD059) | `q` também busca @, CPF, CNPJ e ID | acrescenta `username`, `phone`, `lastLoginAt`, `lastLoginIp`, `total` | — | R2, R3, R12 |
| `POST /api/v1/users` · `PATCH /api/v1/users/:id` (CCD059) | acrescenta `username?`, `cpf?`, `phone?`, `sendActivation` | `201` / `200` | `400`, `409 USERNAME_TAKEN`, `409 CPF_TAKEN` | R4–R7, R9 |
| `GET /api/v1/users/:id` | — | `200` todos os dados | `404` | R13 |
| `POST /api/v1/users/:id/resend-activation` | — | `202` | `404`, `409 ALREADY_ACTIVATED` | R15 |
| `POST /api/v1/auth/login` (CCD004) | `{ login, password, rememberMe }` — e-mail ou @ | igual ao login | igual ao login | R8, R10 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas novas de `users` | R2, R4, R8 |
| `users.validator.ts` · `admin-users.repository.ts` | @, CPF (dígitos), telefone e busca | R3, R4, R6, R7 |
| `admin-users.service.ts` + `.spec.ts` | link opcional, reenvio e auditoria | R5, R9, R15 |
| `auth.service.ts` · `auth.validator.ts` + `.spec.ts` | login por e-mail ou @ e último acesso | R8, R10 |
| `src/lib/logger` (redaction) · routes · swagger | `cpf` no `redact`; rotas novas | R1, R13, R14, R15 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/users/` (api, queries, schemas, types) | campos e rotas novas | R3–R7, R15 |
| `pages/UsersListPage/` · `components/UsersTable/` | colunas (@, telefone, último acesso), busca e total | R2–R7, R12 |
| `pages/UserDetailPage/` (já existe, da CCD059) | acrescenta @, telefone, CPF e último acesso/IP | R13 |
| `components/DeleteUserDialog/` (já existe, da CCD059) | confirmação reforçada (`EXCLUIR-`+primeiro nome, caixa "Estou ciente") | R11 |
| `src/features/auth/components/LoginForm/` | rótulo "E-mail ou nome de usuário" | R10 |

## Testes

| Critério | Onde |
|---|---|
| CA3–CA5, CA8 | `admin-users.service.spec.ts` · integração |
| CA6 | `auth.service.spec.ts` |
| CA1, CA2, CA7 | `UsersPage.spec.tsx` · `DeleteUserDialog.spec.tsx` |
| CA9 | integração |

## Decisões técnicas

- O campo do login passa de `email` para `login`, com o e-mail ainda aceito. **Confirmado em 2026-11-10** (Felipe Consulim).
- A tela de detalhe (R13) é a `UserDetailPage` da CCD059 (`/backoffice/users/:id`), não uma gaveta — ver L4 revista no `spec.md`.
- O `DeleteUserDialog` da CCD059 é o mesmo componente desta story; o formato de confirmação do R11 vale para toda exclusão de usuário.
