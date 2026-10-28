# Tarefas — CCD004 Realizar Login

- **Plano:** [plano.md](plano.md) · **User story:** AB#109
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/109-realizar-login`

- [x] **T1** · Criar migration create_refresh_tokens_table e índice único de Google em users — R19 · L15 · AB#482
  - Pronto quando: `npm run db:migrate` cria a tabela e o índice, e o `schema.prisma` bate com o DBML.
- [x] **T2** · Configurar variáveis de auth, cookie-parser, CORS com credenciais e redaction do log — R22, R38, R50, R51 · CA21 · AB#483
  - Pronto quando: a API não sobe sem as variáveis novas e o teste do logger não mostra senha, token, cookie nem e-mail.
- [x] **T3** · Criar lib de hash de senha (argon2id) e ajustar o JWT de acesso — R10, R15–R17 · AB#484
  - Pronto quando: os testes de `password.ts` e `jwt.ts` passam e o `authenticate` recusa token com `purpose`.
- [x] **T4** · Criar validator, errors e repository do domínio auth — R8, R9, R11–R14, R19, R30, R31 · AB#485
  - Pronto quando: o repository grava, acha por hash e revoga refresh tokens, filtrando expirados e revogados.
- [x] **T5** · Criar service de login com senha e bloqueios — R10–R23 · CA1–CA7 · AB#486
  - Pronto quando: `auth.service.spec.ts` cobre CA1–CA7 com repository falso.
- [x] **T6** · Criar login com Google (validação do id_token, criação e vínculo) — R24–R28 · CA9–CA11 · AB#487
  - Pronto quando: os testes de CA9–CA11 passam com o verificador do Google falso.
- [x] **T7** · Criar renovação com rotação, detecção de reuso e logout — R29–R35 · CA12–CA15 · AB#488
  - Pronto quando: os testes de CA12–CA15 passam.
- [x] **T8** · Criar controller, rotas, rate limit, swagger e module do auth — R22, R23, R49 · CA8 · AB#489
  - Pronto quando: as 4 rotas aparecem no `/docs` e o login responde `429` depois do limite.
- [x] **T9** · Criar job diário de limpeza de tokens expirados — R52 · CA22 · AB#490
  - Pronto quando: o job apaga refresh tokens expirados e mantém os válidos.
- [x] **T10** · Criar testes de integração do auth — CA1–CA14, CA19 · AB#491
  - Pronto quando: `npm run test:integration` passa com o PostgreSQL local.

## Frontend — `apps/cromocard-frontend`, branch `feature/109-realizar-login`

- [x] **T11** [P] · Criar types, schemas, labels e api da feature auth — R8, R24, R29, R35 · AB#492
  - Pronto quando: `auth.api.ts` chama as 4 rotas do contrato e o typecheck passa.
- [x] **T12** · Reescrever sessão: access token em memória, refresh no boot e no 401, signOut — R36–R42 · CA16, CA17 · AB#493
  - Pronto quando: os testes de `AuthProvider` e `http` cobrem F5 e refresh no `401`.
- [x] **T13** · Criar AuthLayout e página de abas /login e /cadastro — R1 · AB#494
  - Pronto quando: as duas rotas abrem a mesma página com a aba certa, no visual do Figma 152-2587.
- [x] **T14** · Criar formulário de login com lembrar de mim e link Esqueci minha senha — R2–R5, R7, R11, R48 · CA1, CA4–CA7 · AB#495
  - Pronto quando: `LoginForm.spec.tsx` cobre envio, erro genérico e mensagens de bloqueio.
- [x] **T15** · Criar botão Entrar com Google — R6, R24 · CA9 · AB#496
  - Pronto quando: o botão obtém o `id_token` e entra pela API, com o aviso dos termos ao lado.
- [x] **T16** · Ajustar guards, redirecionamento por papel e botão Sair nos cabeçalhos — R35, R43–R45 · CA3, CA15, CA18 · AB#497
  - Pronto quando: os testes dos guards passam e o "Sair" encerra a sessão nas duas áreas.
- [x] **T17** · Remover o token de desenvolvimento e documentar GOOGLE_CLIENT_ID — R47 · CA20 · AB#498
  - Pronto quando: não há `DEV_ACCESS_TOKEN` no código nem no README e o build passa.

## Fechamento — workspace

- [ ] **T18** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#499
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T13 |
| R2–R5, R7 | T14 |
| R6 | T6, T15 |
| R8, R9 | T4, T11 |
| R10 | T3, T5 |
| R11–R14 | T4, T5, T14 |
| R15–R17 | T3 |
| R18–R21 | T5 |
| R22 | T2, T8 |
| R23 | T5, T8 |
| R24–R28 | T6, T15 |
| R29–R34 | T7 |
| R35 | T7, T16 |
| R36–R42 | T12 |
| R43–R46 | T16 (R46: T8, `authorize` já existe) |
| R47 | T17 |
| R48 | T14 |
| R49 | T8 |
| R50, R51 | T2 |
| R52 | T9 |
