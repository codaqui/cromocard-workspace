---
paths:
  - "apps/cromocard-backend/**"
---

# Backend (`apps/cromocard-backend`) — arquitetura decidida nos ADRs 001–020

Repositório próprio (submódulo). Rode git com `git -C apps/cromocard-backend …`; a branch base é `develop`.

## Comandos

`docker compose up -d` (PostgreSQL 18 local) · `npm ci` · `npm run db:migrate` · `npm run dev` (API em
http://localhost:3000, Swagger em `/docs`) · `npm run lint` · `npm run typecheck` · `npm test` ·
`npm run test:cov` · `npm run test:integration` (precisa do PostgreSQL local de pé) · `npm run build`.
Fluxo de trabalho da equipe: `docs/ONBOARDING.md` do repositório do backend.

## Estrutura

- **Monólito modular** (ADR-001): um repo, um banco, módulos por domínio em `src/domains/<dominio>`.
- **Stack** (ADR-002/003): Node 24 LTS + TypeScript strict + Express 5 + Prisma/PostgreSQL;
  schema e migrations em `database/` (não `prisma/`).
- **Arquivos por domínio** (ADR-004): `<d>.routes.ts`, `.controller.ts`, `.service.ts`,
  `.repository.ts`, `.validator.ts` (Zod), `.errors.ts`, `.swagger.ts`, `.module.ts`
  (composition root — monta dependências e exporta router + service), `.service.spec.ts`.
  Fluxo: rota → middlewares → controller → service → repository. Service dentro do domínio.
  Um domínio **nunca** importa o repository de outro — só a service exportada pelo `.module.ts`.
  Dependências sempre injetadas pelo construtor. `shared/` = reutilizável sem regra de negócio.
  O domínio `src/domains/users/` é o **modelo** para os demais.
- **Estrutura do `src`** (ADR-020, sem pasta `infra`): `app.ts`, `server.ts`, `routes.ts` na raiz;
  `config/` (env, logger, swagger), `lib/` (prisma, jwt, zod), `domains/`, `shared/`
  (errors, middlewares, utils, types), `providers/`, `jobs/`, `socket/`.
- **Migrations: uma por tabela** (`npm run db:migrate -- --name create_<tabela>_table`). O `schema.prisma`
  só contém as tabelas já implementadas (hoje: `users` e as 15 da fundação do BackOffice); as demais entram uma a uma, copiadas do DER
  (`.claude/rules/modelagem-de-dados.md`).

## Regras

- **Código sem comentários** (pedido do time, prevalece sobre o ADR-017): nomes claros no lugar de
  comentários. Se um comentário for inevitável (configuração, contorno de bug de biblioteca), em pt-BR e
  explicando o porquê.
- **Auth** (ADR-005): access JWT 15 min (`sub`, `role`) + refresh token opaco rotativo (hash em
  `refresh_tokens`); Google via `id_token` validado com `google-auth-library` (não é servidor OAuth2).
  Rotas protegidas usam `authenticate` e `authorize(...roles)`.
- **Validação/erros** (ADR-006): Zod gera validação, tipos e Swagger; erros `{ error, message, details? }`
  via `AppError` + `errorHandler` global. Erro de negócio é uma classe no `.errors.ts`, nunca `throw new Error()` solto.
- **API** (ADR-011): `/api/v1`, recursos plural kebab-case, `/me` para o usuário logado, ações via `POST /:id/<acao>`;
  resposta `{ data }` / `{ data, meta }`, JSON camelCase, datas ISO UTC, dinheiro como string decimal;
  `422` para regra de negócio, `409` conflito; paginação offset (`page`/`pageSize`) e cursor para chat/notificações.
- **Soft delete** (ADR-015): todo repository filtra `deletedAt: null` explicitamente; excluir = preencher
  `deletedAt`; re-adicionar item excluído restaura a linha (upsert). Nunca `delete` do Prisma em dado de negócio.
- **Tempo real** (ADR-007/012): Socket.IO no mesmo repositório, em processo próprio (`src/ws-server.ts`,
  imagem `cromocard-ws`, código de apoio em `src/socket/`); reusa as services de chat/community; rooms
  `user:<id>`, `group:<id>`, `conversation:<id>`; eventos `dominio:acao`; persiste antes de emitir.
- **Providers** (ADR-009): CEP (ViaCEP/BrasilAPI), e-mail (Nodemailer + Ethereal em dev), storage
  (local/MinIO em dev, S3 depois), pagamento e transportadora — sempre via interface, em `src/providers/`.
- **Cron** (ADR-010): `node-cron` em `src/jobs/` (ADR-020), só com `JOBS_ENABLED=true`.
- Ações administrativas geram registro em `audit_logs` (ADR-034).
- **Convenções** (ADR-017): código em inglês; **npm** (`npm ci` no CI); imports com alias `@/`; sem `console.log`
  (use o logger).
- **Config** (ADR-018): só variáveis de ambiente, lidas/validadas em `src/config/env.ts` (`process.env` fora
  dele é barrado pelo ESLint); ambientes local · test · homolog · produção (`APP_ENV`); segredos fora do repo.
- **Logs** (ADR-019): pino JSON, `requestId` por requisição, redaction de tokens/dados pessoais,
  `/health` e `/health/ready`, shutdown gracioso.

## Qualidade (ADR-008)

- ESLint type-checked com `max-depth` 1, `max-params` 3, `max-lines-per-function` 25, `no-else-return`,
  `no-console`, import de repository de outro domínio barrado e `../` barrado (use `@/`). Prettier e `tsc --noEmit`.
- Testes `.spec.ts` com **Vitest**: unitários ao lado do arquivo (service com repository falso injetado pelo
  construtor) e integração em `tests/integration/` com o PostgreSQL de teste. Cobertura mínima de 80% nas services.
- O husky/lint-staged do ADR-008 ainda não está configurado: o CI é a barreira.
- Critério de code review: Clean Code, SOLID e Object Calisthenics (agent `revisor-codigo`, skill `/revisar-codigo`).
