# Arquitetura do backend (`apps/cromocard-backend`)

Monólito modular em Node 24, TypeScript strict, Express 5 e Prisma/PostgreSQL. Decisões nos ADRs 001–020; regras em
`.claude/rules/backend.md`. **Modelo a copiar: `src/domains/users/`.**

Este mapa foi levantado da branch `develop` em 2026-11-09. Se um arquivo citado não existir mais, confie no
`git -C apps/cromocard-backend ls-files`.

## Caminho de uma requisição

```
routes.ts → <d>.routes.ts → middlewares → <d>.controller.ts → <d>.service.ts → <d>.repository.ts → Prisma
```

Um domínio nunca importa o repository de outro: usa a service exportada pelo `.module.ts` dele.

## Raiz de `src/`

| Arquivo | Faz |
|---|---|
| `app.ts` | `createApp`: monta o Express com helmet, CORS, JSON, logger, health, uploads locais, rotas, 404 e `errorHandler` |
| `server.ts` | Processo da API HTTP |
| `ws-server.ts` | Processo do Socket.IO (imagem `cromocard-ws`); reusa as services, sem uploads |
| `routes.ts` | Lista os `DomainModule`, aplica o prefixo `/api/v1` e serve o Swagger em `/docs` fora de produção. **Domínio novo entra em `sharedModules`** |

## Pastas de `src/`

### `config/`: configuração lida uma vez

| Arquivo | Faz |
|---|---|
| `env.ts` | Único lugar que lê `process.env`, validado com Zod (o ESLint barra fora dele) |
| `logger.ts` | pino e logger HTTP, com `requestId` e redaction |
| `swagger.ts` | Monta o OpenAPI a partir do `registerDocs` de cada módulo |

### `lib/`: adaptadores finos de bibliotecas, sem regra de negócio

| Arquivo | Faz |
|---|---|
| `prisma.ts` | Instância do `PrismaClient` |
| `transaction.ts` | `runInTransaction` e os tipos `Transaction` e `TransactionRunner`, para injetar transação na service |
| `zod.ts` | O `z` do projeto: importe sempre daqui |
| `jwt.ts` | Assina e verifica o access token |
| `opaque-token.ts` | Tokens opacos, como o refresh token |
| `password.ts` | Hash e verificação de senha |
| `google.ts` | Validação do `id_token` do Google |

`src/generated/prisma/` é gerado pelo `prisma generate`: importe `@/generated/prisma/client` e nunca edite.

### `domains/<dominio>/`: as regras de negócio

Domínios: `auth`, `users`, `uploads`, `catalog`, `collection`, `community`, `chat`, `notifications`, com subdomínios em
`admin/<sub>` (`audit-logs`, `dashboard`, `reports`, `settings`) e `marketplace/<sub>` (`listings`, `orders`,
`payments`). Pasta só com `.gitkeep` é domínio ainda não implementado.

| Arquivo | Responsabilidade | Não faz |
|---|---|---|
| `<d>.routes.ts` | `create<D>Routes(controller)`: caminhos e middlewares (`authenticate`, `authorize('ADMIN')`) | Lógica |
| `<d>.controller.ts` | Valida a entrada com o validator, chama a service e responde com `shared/utils/http-response` | Regra de negócio, Prisma |
| `<d>.service.ts` | Regras de negócio; recebe as dependências pelo construtor | Conhecer `req`/`res` |
| `<d>.repository.ts` | `Prisma<D>Repository`: consultas com `select` explícito e `notDeleted` em toda leitura | Regra de negócio |
| `<d>.validator.ts` | Schemas Zod e tipos inferidos da entrada; o `.schemas.ts` do frontend espelha este arquivo | |
| `<d>.errors.ts` | Uma classe por erro de negócio, derivada do `AppError`, com código `SCREAMING_SNAKE_CASE` | `throw new Error()` |
| `<d>.swagger.ts` | `register<D>Docs(registry)`: documenta as rotas a partir dos schemas | |
| `<d>.module.ts` | Composition root: instancia repository, service e controller; exporta o `DomainModule` (`basePath`, `router`, `registerDocs`) e a service | |
| `<d>.service.spec.ts` | Testes da service com repository falso injetado; cobertura mínima de 80% | |

Arquivos auxiliares ficam no domínio, com nome próprio e sem Express nem Prisma quando forem lógica pura, como
`dashboard.period.ts` (cálculo do período) e `uploads/image-type.ts` (detecta o tipo pela assinatura do arquivo).
Middleware específico vira `<d>.middleware.ts`.

### `providers/<servico>/`: integrações externas, sempre atrás de interface

| Arquivo | Faz |
|---|---|
| `<s>.provider.ts` | Interface usada pelas services |
| `<s>.factory.ts` | Escolhe a implementação pelo ambiente |
| `<impl>.<s>-provider.ts` | Implementação (`nodemailer.mail-provider.ts`, `memory.mail-provider.ts`, `local.storage-provider.ts`) |
| `storage/storage.errors.ts` | Erros do storage |
| `storage/local-uploads.static.ts` | Serve os arquivos locais em `/uploads` |
| `mail/templates/*.mail.ts` | Um e-mail por arquivo; `escape-html.ts` e `describe-duration.ts` são apoio |

`payment/`, `shipping/` e `zip-code/` estão vazias: siga o mesmo formato.

### `shared/`: reutilizável, sem regra de negócio

| Arquivo | Faz |
|---|---|
| `errors/app-error.ts` | Classe base dos erros |
| `errors/http-errors.ts` | Erros HTTP genéricos |
| `errors/error-handler.ts` | `errorHandler` e `notFoundHandler`: resposta `{ error, message, details? }` |
| `errors/unique-constraint.ts` | `isUniqueConstraintError` (P2002) |
| `health/health.routes.ts` | `/health` e `/health/ready` |
| `middlewares/authenticate.ts` | Valida o Bearer e preenche o usuário |
| `middlewares/authorize.ts` | `authorize(...roles)` |
| `middlewares/rate-limit.ts` | Limites de requisição |
| `types/domain-module.ts` | Contrato `DomainModule` |
| `types/authenticated-user.ts` · `types/express.d.ts` | Tipo do usuário e extensão do `Request` |
| `utils/http-response.ts` | `ok`, `created`, `accepted`, `noContent`, `paginated`: formato `{ data }` / `{ data, meta }` |
| `utils/pagination.ts` | `paginationQuerySchema`, `toSkipTake`, `buildPaginationMeta` |
| `utils/soft-delete.ts` | `notDeleted` e `softDeleteData`. Nunca `delete` do Prisma em dado de negócio |
| `utils/time-zone.ts` | Datas no fuso de Brasília, `DateRange` |
| `validators/reason.ts` | Schema do campo "motivo" das ações administrativas |

### `jobs/` e `socket/`

- `jobs/<nome>.job.ts`: uma rotina `node-cron` por arquivo. `jobs/index.ts` (`startJobs`) registra todas; só rodam com
  `JOBS_ENABLED=true`.
- `socket/`: código de apoio do Socket.IO. Rooms `user:<id>`, `group:<id>`, `conversation:<id>`; eventos `dominio:acao`;
  persista antes de emitir.

## Fora de `src/`

| Caminho | Faz |
|---|---|
| `database/schema.prisma` | Só as tabelas já implementadas, copiadas do DBML, com `@@map`/`@map` |
| `database/migrations/` | Uma migration por tabela: `npm run db:migrate -- --name create_<tabela>_table` |
| `database/seeds/` | `index.ts` orquestra, `<x>.seed.ts` popula, `data/*.json` guarda os dados; `load-seed-data.ts`, `seed-id.ts`, `seed-options.ts` e `sample-image.ts` são apoio |
| `tests/integration/` | Testes com o PostgreSQL de teste (`npm run test:integration`) |
| `tests/unit/` | Testes de rotas e módulos sem banco |
| `tests/helpers/` | Apoio dos testes |
| `infra/`, `Dockerfile`, `docker-compose.yml` | Deploy e PostgreSQL local |
| `docs/ONBOARDING.md`, `docs/runbooks/` | Fluxo do time e operação |

## Domínio novo, na ordem

1. Tabela copiada do DBML no `schema.prisma` e migration própria.
2. `.validator.ts` e `.errors.ts`.
3. `.repository.ts`, com `notDeleted` em toda leitura.
4. `.service.ts` e `.service.spec.ts`, com os `CA` no nome dos testes.
5. `.controller.ts`, `.routes.ts`, `.swagger.ts` e `.module.ts`.
6. Registro em `sharedModules` no `src/routes.ts`.
7. Teste de integração em `tests/integration/`.

## Regras que mais reprovam

- Sem comentários no código; sem `console.log`; imports com `@/` (`../` é barrado).
- ESLint: `max-depth` 1, `max-params` 3, `max-lines-per-function` 25, `no-else-return`.
- API: recursos no plural em kebab-case, `/me`, ações em `POST /:id/<acao>`, JSON em camelCase, datas ISO UTC, dinheiro
  como string decimal, `422` para regra de negócio, `409` para conflito.
- Ação administrativa grava em `audit_logs` (ADR-034).
- UUID v7 nas PKs; tabela termina com `created_at`, `updated_at` e `deleted_at`.
