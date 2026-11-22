# Plano — CCD051 Configurar Privacidade e Senha

Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (feito sobre a spec em Rascunho)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade
- **Código lido:** branch `feature/336-remove-tipo-categoria` dos dois apps. Já existem `passwordSchema` (regra do
  cadastro) em `auth.validator.ts`, o hash em `src/lib/password.ts`, `usersService.changePassword`, o redaction do logger
  (`LOG_REDACT_PATHS`) e a rota `paths.settings` (`/configuracoes`) como `underConstructionRoute` da CCD051. `profiles` vem
  da CCD048; `collections` não está no `schema.prisma`.

## Solução

A página "Configurações" (`/configuracoes`) substitui a página em construção, no frame `1160-41305`, com os blocos "Conta e
segurança" e "Privacidade". A chave "Coleção pública" grava `profiles.portfolio_privacy` por `PATCH /users/me/privacy` e
confirma com um aviso. "Alterar senha" abre o modal; `POST /auth/password/change` confere a senha atual com o hash, valida a
nova pela regra do cadastro e grava só o hash. Um helper de visibilidade do portfólio fica pronto para as consultas públicas
da coleção esconderem os álbuns e as cartas da coleção privada.

## Dependências

- **CCD048:** a tabela `profiles` (`portfolio_privacy`, default `PUBLIC`) e o `GET /users/me` com o `profile`.
- **CCD003/CCD004:** `passwordSchema`, `lib/password.ts` e o login que passa a aceitar só a senha nova.
- **Consultas públicas da coleção** (CCD012, CCD080 e as da Minha Coleção): aplicam o helper desta story; até existirem,
  R5 fica coberto pelo teste do helper (CA2 completo depende delas e da L2).
- Esta página recebe depois "Contatos bloqueados" (CCD047), "Excluir conta" (CCD052) e os avisos (CCD053).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação | Requisitos |
|---|---|---|---|---|
| `profiles` | não (entra na CCD048) | — | `portfolio_privacy` (`PUBLIC`/`PRIVATE`) é a coluna da chave (depende da L1) | R3–R5 |
| `users` | sim | — | `password_hash` trocado; `oauth_provider` para a conta só Google (L7) | R7, R9 |
| `collections` | não | — | `is_public` não é usada aqui (depende da L1: a outra coluna sai do DBML num PR de docs) | R5 |

## Regras

- **Privacidade:** grava na hora da chave (depende da L5); `upsert` de `profiles` se a linha ainda não existir; desistir
  (erro ou desligar e religar) mantém o valor gravado (R12).
- **Visibilidade:** `isPortfolioVisible(ownerId, viewerId)` responde `true` para o dono ou quando `PUBLIC` (R5; o que a
  coleção privada esconde depende da L2).
- **Senha atual:** comparada com `password_hash`; errada responde `422 CURRENT_PASSWORD_INCORRECT` e nada muda (R7, R10).
- **Nova senha:** o `passwordSchema` do cadastro (8+, letra, número e símbolo) e `confirmPassword` igual (R8, R11). Igual à
  atual é aceita (depende da L10, sem proposta).
- **Conta só Google:** sem `password_hash`, responde `422 PASSWORD_NOT_SET` (depende da L7).
- **Sessões e e-mail:** a troca não revoga as outras sessões nem manda e-mail (depende da L6, sem proposta).
- **Log:** `currentPassword`, `newPassword` e `confirmPassword` entram no `LOG_REDACT_PATHS`; nenhuma linha de log leva o
  hash (R13).
- **Papéis:** `CUSTOMER` e `SELLER` (depende da L11).

## Contrato da API

### `PATCH /api/v1/users/me/privacy` — R1, R3, R4, R12

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')`
- **Entrada:** `{ "portfolioPrivacy": "PRIVATE" }`
- **Sucesso:** `200` `{ "data": { "portfolioPrivacy": "PRIVATE" } }`
- **Erros:** `400 VALIDATION_ERROR` (valor fora do enum), `401` — R4.

O valor atual vem no `GET /users/me` (`profile.portfolioPrivacy`, CCD048).

### `POST /api/v1/auth/password/change` — R1, R6–R11, R13

- **Acesso:** `authenticate`
- **Entrada:** `{ "currentPassword": "string", "newPassword": "string", "confirmPassword": "string" }`
- **Sucesso:** `204`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | nova senha fora da regra ou confirmação diferente (`details` por campo) | R8, R11 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 422 | `CURRENT_PASSWORD_INCORRECT` | senha atual não confere | R7, R10 |
  | 422 | `PASSWORD_NOT_SET` | conta só Google (L7) | R7 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/users.validator.ts` | `updatePrivacySchema` | R3, R4 |
| `src/domains/users/users.repository.ts` · `users.service.ts` + `users.service.spec.ts` | `updatePrivacy` (`upsert` de `profiles`), `isPortfolioVisible` exportado pelo `users.module.ts` | R3–R5 |
| `src/domains/users/users.controller.ts` · `users.routes.ts` · `users.swagger.ts` | `PATCH /me/privacy` | R1, R4 |
| `src/domains/auth/auth.validator.ts` | `changePasswordSchema` com o `passwordSchema` e o `refine` da confirmação | R8, R11 |
| `src/domains/auth/auth.errors.ts` | `CurrentPasswordIncorrectError`, `PasswordNotSetError` | R7, R10 |
| `src/domains/auth/auth.service.ts` + `auth.service.spec.ts` | `changePassword`: confere o hash, grava o novo por `usersService.changePassword` | R7–R10 |
| `src/domains/auth/auth.controller.ts` · `auth.routes.ts` · `auth.swagger.ts` | `POST /password/change` com `authenticate` | R1, R6 |
| `src/config/logger.ts` | campos de senha no `LOG_REDACT_PATHS` | R13 |
| `tests/integration/auth-password.spec.ts` · `users-privacy.spec.ts` | troca de senha, login com a nova, privacidade, log sem senha | R1, R3–R5, R7–R11, R13 |

## Frontend — `apps/cromocard-frontend`

Página nova na feature `src/features/users/`, na rota `paths.settings` que já existe (troca o `underConstructionRoute` em
`users.routes.ts`, com `RequireAuth`).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `users.types.ts` · `users.schemas.ts` · `users.labels.ts` | `PortfolioPrivacy`; `changePasswordSchema` igual ao do backend; textos dos blocos e dos avisos | R3, R6, R8, R11 |
| `users.api.ts` · `users.queries.ts` | `updatePrivacy`, `changePassword` | R4, R9 |
| `src/components/Switch/` | chave acessível (`role="switch"`) no estilo do frame `1160-41305` | R3 |
| `components/PrivacySection/` | "Privacidade", "Quem pode ver sua coleção.", "Coleção pública" e o texto de ajuda; aviso de salvo (sem frame, no estilo da tela) — frame `1160-41305` | R3, R4, R12 |
| `components/AccountSecuritySection/` | "Conta e segurança" com a linha "Senha" e "Alterar senha" — frame `1160-41305` | R6 |
| `components/ChangePasswordDialog/` | "Alterar senha", a regra, os 3 campos, "Cancelar"/"✕", erro "Senha atual • senha atual incorreta", aviso da regra e o toast "Senha alterada" — frames `1160-41859`, `1160-42338`, `1160-42817` | R6, R8–R12 |
| `pages/SettingsPage/` · `users.routes.ts` | topo "MINHA CONTA", "Configurações" e o subtítulo, os dois blocos — frame `1160-41305` | R2 |

- **Reaproveitados:** `TextField` (tipo senha), `FormField`, `FormError`, `Modal`, `Button`, `Toast`, `LoadingState`, `ErrorState`.
- **Fora deste plano:** "Mostrar a cidade no perfil público" (L3), "Alterar e-mail" (L4), "Alterada há 3 meses" (L8) e o
  medidor "Senha forte" (L9).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | desligar a chave grava `PRIVATE` e confirma | `users.service.spec.ts` · `users-privacy.spec.ts` · `PrivacySection.spec.tsx` |
| CA2 | `isPortfolioVisible` falso para outra pessoa na coleção privada | `users.service.spec.ts` (e o teste da consulta pública quando ela existir) |
| CA3 | hash trocado, toast "Senha alterada", login só com a nova | `auth.service.spec.ts` · `auth-password.spec.ts` · `ChangePasswordDialog.spec.tsx` |
| CA4 | senha atual errada: `422` e o rótulo em vermelho | `auth.service.spec.ts` · `auth-password.spec.ts` · `ChangePasswordDialog.spec.tsx` |
| CA5 | "abc12345" ou confirmação diferente: `400` e o aviso da regra | `auth.validator.spec.ts` · `auth-password.spec.ts` · `ChangePasswordDialog.spec.tsx` |
| CA6 | "Cancelar" e "✕" não chamam a API | `ChangePasswordDialog.spec.tsx` |
| CA7 | `401` nas duas rotas sem login | `auth-password.spec.ts` · `users-privacy.spec.ts` |
| CA8 | o log da troca não tem senha nem hash | `auth-password.spec.ts` (logger capturado) |
| CA9–CA12 | print em 1280 px igual aos frames `1160-41305`, `1160-41859`, `1160-42338` e `1160-42817`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Dependências e riscos

- L1: o DBML tem `profiles.portfolio_privacy` e `collections.is_public` para a mesma coisa. O plano usa a primeira; ficar
  com uma só exige PR de docs nos três `.dbml` e ADR antes do código.
- R5 só fecha de ponta a ponta quando existir uma consulta pública da coleção (CCD012, CCD080); o helper fica pronto e testado.
- A spec R10 e o CA4 dizem "a API recusa": o plano usa `422`, não `401`, porque o `http.ts` do frontend tenta renovar a
  sessão em todo `401`.
- L5, L6, L7, L10 e L11 seguem a proposta ou ficam sem regra extra e podem mudar o plano.

## Decisões técnicas

- A troca de senha fica no domínio `auth`, ao lado de `/password/forgot` e `/password/reset`, e grava pelo
  `usersService.changePassword` que já existe.
- A chave grava na hora (sem "Salvar Preferências", que parece ser da CCD053), até a L5 decidir.
