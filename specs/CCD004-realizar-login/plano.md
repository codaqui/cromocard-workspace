# Plano — CCD004 Realizar Login

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Repositórios:** backend (`develop`) · frontend (`develop`)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

A tela `/login` (aba Fazer Login) envia e-mail e senha para `POST /api/v1/auth/login`. A service do domínio `auth`
confere a senha com argon2id, aplica os bloqueios (suspensa, excluída, e-mail não confirmado), emite o access token
(15 min) e grava o refresh com hash em `refresh_tokens`, entregue em cookie httpOnly. O frontend guarda o access em
memória, renova pelo cookie ao iniciar e em cada `401`, e o logout revoga o refresh. O Google entra pelo mesmo fluxo
(`POST /api/v1/auth/google`).

## Dependências

- Nenhuma spec antes. A CCD003 e a CCD006 reaproveitam `lib/password.ts`, o `MailProvider` (criado na CCD003) e a
  página de abas criada aqui.
- ADR-048 (`GOOGLE_CLIENT_ID` no frontend e índice único em `users (oauth_provider, oauth_id)`).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `users` | sim | `add_users_oauth_unique_index` | índice único (`oauth_provider`, `oauth_id`) — ADR-048 |
| `refresh_tokens` | não | `create_refresh_tokens_table` | copiada do DBML |

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `POST /api/v1/auth/login` — R2–R5, R8–R23, R43

- **Acesso:** público, com rate limit (5 tentativas/min por IP + e-mail)
- **Entrada:** `{ "email": "string", "password": "string", "rememberMe": false }`
- **Sucesso:** `200` `{ "data": { "accessToken": "jwt", "user": { "id": "uuid", "name": "string", "role": "CUSTOMER" } } }`
  e cookie `cromocard_refresh` (httpOnly, `Secure` fora de dev, `SameSite=Lax`, `Path=/api/v1/auth`; sem `Max-Age`
  quando `rememberMe = false`)
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | campo vazio ou e-mail inválido | R9 |
  | 401 | `INVALID_CREDENTIALS` | e-mail inexistente, senha errada ou conta só Google | R11 |
  | 403 | `EMAIL_NOT_VERIFIED` | `email_verified = false` | L9 |
  | 403 | `ACCOUNT_SUSPENDED` | `status = SUSPENDED` (checado depois da senha) | R12 |
  | 403 | `ACCOUNT_DELETED` | `deleted_at` preenchido | R13, R14 |
  | 429 | `TOO_MANY_REQUESTS` | passou do limite | R23 |

### `POST /api/v1/auth/google` — R6, R24–R28

- **Acesso:** público, com rate limit
- **Entrada:** `{ "idToken": "string", "rememberMe": false }`
- **Sucesso:** igual ao login. Cria a conta `CUSTOMER` (e-mail confirmado, termos aceitos, `name` do token) se não
  existir; vincula `oauth_*` se o e-mail já tiver conta
- **Erros:** `401 INVALID_GOOGLE_TOKEN` (R25) · `403 ACCOUNT_SUSPENDED` · `403 ACCOUNT_DELETED` (R28)

### `POST /api/v1/auth/refresh` — R29–R34

- **Acesso:** cookie `cromocard_refresh`
- **Sucesso:** `200` `{ "data": { "accessToken": "jwt", "user": { … } } }` e cookie novo (rotação; herda o `expires_at`)
- **Erros:** `401 INVALID_REFRESH_TOKEN` (expirado, inválido, usuário suspenso ou excluído) · `401
  REFRESH_TOKEN_REUSED` (revoga todas as sessões e loga `warn`)

### `POST /api/v1/auth/logout` — R35

- **Acesso:** cookie `cromocard_refresh` (sem access token)
- **Sucesso:** `204`, revoga o refresh e limpa o cookie

## Backend — `apps/cromocard-backend`

Domínio `src/domains/auth/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migrations | `RefreshToken` e o índice único em `User` | R19, L15 |
| `src/config/env.ts` · `.env.example` | `JWT_ACCESS_TTL`, `REFRESH_TTL`, `REFRESH_TTL_REMEMBER`, `GOOGLE_CLIENT_ID` (opcional: sem ela o login com Google fica desligado), `COOKIE_SECURE`, `TRUST_PROXY` | R51 |
| `src/lib/password.ts` | `hashPassword`/`verifyPassword` com argon2id | R10 |
| `src/lib/jwt.ts` | `signAccessToken` com TTL do env; `authenticate` recusa token com `purpose` | R15–R17 |
| `src/lib/google.ts` | `verifyGoogleIdToken` (`google-auth-library`) | R25 |
| `auth.validator.ts` · `auth.errors.ts` | schemas Zod e erros da tabela acima | R8, R9, R11–R14 |
| `auth.repository.ts` | `refresh_tokens` (criar, achar por hash, revogar, revogar todos); usuário por e-mail e por Google via `usersService` | R19, R26, R30, R31 |
| `auth.service.ts` + `.spec.ts` | login, Google, refresh com rotação e reuso, logout | R10–R34 |
| `auth.controller.ts` · `auth.routes.ts` · `auth.swagger.ts` · `auth.module.ts` | rotas, cookie, rate limit (`express-rate-limit`) | R22, R23, R49 |
| `src/app.ts` | `cookie-parser`; CORS com `credentials: true` | R22, R38 |
| `src/config/logger.ts` | redaction de `password`, `token`, `cookie`, `authorization`, `email` | R50 |
| `src/jobs/cleanup-expired-tokens.job.ts` | job diário (`node-cron`) que apaga refresh expirados | R52 |
| `tests/integration/auth.spec.ts` | fluxo completo no PostgreSQL de teste | CA1–CA14 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/auth/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `auth.types.ts` · `auth.schemas.ts` · `auth.labels.ts` | tipos e Zod do login (espelha o validator) | R8 |
| `auth.api.ts` · `auth.queries.ts` | `login`, `loginWithGoogle`, `refresh`, `logout` | R24, R29, R35 |
| `components/AuthLayout/` | layout em duas colunas da tela de Login (Figma 152-2587) | R1 |
| `pages/AuthPage/` | abas Fazer Login / Criar Conta (`/login` e `/cadastro`) | R1 |
| `components/LoginForm/` + `hooks/useLoginForm.ts` | e-mail, senha, "lembrar de mim", link "Esqueci minha senha", erros | R2–R5, R7, R48 |
| `components/GoogleButton/` | Google Identity Services | R6, R24 |
| `src/lib/access-token.ts` · `src/lib/http.ts` | access em memória, `withCredentials`, refresh único em andamento no `401` | R37–R39, R42 |
| `src/contexts/AuthProvider.tsx` | refresh ao iniciar, `signIn`, `signOut` com `queryClient.clear()`, estado "carregando sessão" | R36, R40, R41 |
| `src/routes/guards/*` · `RoleHomeRedirect.tsx` · `paths.ts` | guards levam a `/login?redirect=`; logado em `/login` vai para a home | R43–R45 |
| `src/app/layouts/*` | botão "Sair" nos cabeçalhos Cliente e BackOffice | R35 |
| `src/config/env.ts` · README | `GOOGLE_CLIENT_ID`; remove `DEV_ACCESS_TOKEN` e a "Sessão de desenvolvimento" | R47, L16 |

- **Rotas:** `/login`, `/cadastro` (públicas).
- **Componentes reaproveitados:** `Button`, `TextField`, `ErrorState`, `LoadingState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA2, CA3 | login emite tokens, TTL 1 ou 30 dias, destino por papel | `auth.service.spec.ts` · `tests/integration/auth.spec.ts` · `LoginForm.spec.tsx` |
| CA4, CA5 | `401` genérico e `400` por campo | `auth.service.spec.ts` · integração |
| CA6, CA7 | bloqueio de suspensa e excluída | `auth.service.spec.ts` |
| CA8 | `429` | integração |
| CA9–CA11 | Google vinculado, novo e token inválido | `auth.service.spec.ts` (Google falso injetado) |
| CA12–CA14 | rotação, reuso e refresh inválido | `auth.service.spec.ts` · integração |
| CA15–CA18 | logout, F5, refresh no `401`, guards | `AuthProvider.spec.tsx` · `http.spec.ts` · `RequireRole.spec.tsx` |
| CA19 | `403` por papel | integração |
| CA20 | sem `DEV_ACCESS_TOKEN` | revisão + `npm run build` |
| CA21 | redaction | `logger.spec.ts` |
| CA22 | job apaga expirados | `cleanup-expired-tokens.job.spec.ts` |

## Decisões técnicas

- argon2id (`argon2`), cookie `cromocard_refresh` com `Path=/api/v1/auth`, rate limit de 5/min no login e no Google.
- `TRUST_PROXY=1` em hml e prod: atrás do cloudflared, sem ele o rate limit veria um IP só para o site inteiro.
- Login com e-mail inexistente ou conta só Google roda o argon2 contra um hash fixo, para o tempo de resposta não revelar
  quais e-mails têm conta (R11).
- Duas abas renovando juntas: o frontend serializa a renovação com o Web Locks, para a segunda aba não reapresentar o
  refresh já rotacionado (o que contaria como reuso e derrubaria as sessões).
- O refresh rotacionado herda o `expires_at`, o que dispensa coluna para o "lembrar de mim" (L14).
- `user_agent` e `ip_address` são gravados no login (R19).
- Token e cliente do Google entram por injeção no construtor, para os testes.
