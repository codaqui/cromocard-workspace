# CLAUDE.md — CromoCard

Projeto acadêmico (Escola de TI) em equipe: **CromoCard — Sistema de Gestão de Cartas Colecionáveis**.
Plataforma para colecionadores organizarem álbuns e cartas/figurinhas, participarem de grupos
da comunidade, conversarem em tempo real e negociarem cartas num marketplace. Administradores
gerenciam usuários, catálogo e comunidade.

Idioma do projeto: **português (pt-BR)** — responda, documente e escreva commits em português.
**Código e banco em inglês** (identificadores, tabelas, colunas, enums, nomes de arquivo).

## Estrutura do repositório

```
ESCOLA-TI/                         (repo de documentação/workspace — branch de trabalho: development, principal: main)
├── docs/
│   ├── ADR/                       ADR-001…037 + README.md (índice e modelo) — decisões de arquitetura; LEIA antes de mexer no backend
│   ├── Padroes/                   CONTRIBUTING.md e template de PR (fonte para os repos de código)
│   ├── Casos-De-Uso/              NN-nome-do-caso.md (01–93), user-stories.md, resumo-user-stories.md, CromoCard 1.xlsx
│   ├── Diagrama-de-Classe/        cromocard-diagrama-classes.v2.c4 (LikeC4, atual) + .v1.c4 (histórico) + README.md — 43 classes, 1:1 com o DER
│   └── Diagramas/
│       ├── DER/                   puml/, dbdiagram.io/ (DBML), chartdb/ (DDL PostgreSQL) + README.md
│       ├── Diagramas-C4/          01-contexto, 02-containers, 03-componentes (.puml + .svg)
│       ├── Diagrama-Casos-de-Uso/ cromocard_casos_de_uso.puml (CCD001–CCD046)
│       └── Diagrama-Atividades/   Diagrama_Atividades.c4 (LikeC4, CCD001–CCD066)
├── Azure-Devops/                  organização do board, mapa de artefatos por autor, board-cromocard.html
├── apps/                          submódulos git (`.gitmodules`) — cada app é um repo git próprio
│   ├── cromocard-backend/         github.com/codaqui/cromocard-backend   (esqueleto + domínio de exemplo `users` em `develop`)
│   └── cromocard-frontend/        github.com/codaqui/cromocard-frontend  (ainda vazio: só README)
├── CromoCardWorks.code-workspace  workspace VS Code (raiz + os 2 apps)
└── .mcp.json                      MCP do Azure DevOps (org/projeto `CromoCard`, PAT via $AZURE_DEVOPS_PAT)
```

**Backend** (`apps/cromocard-backend`, Node 24 via `.nvmrc`): `npm run dev` · `npm run build` ·
`npm run lint` · `npm run typecheck` · `npm test` · `npm run test:cov` · `npm run db:migrate`.
O domínio `src/domains/users/` é o **modelo** para os demais. O frontend ainda está vazio.
**Migrations: uma por tabela** (`npm run db:migrate -- --name create_<tabela>_table`). O `schema.prisma`
só contém as tabelas já implementadas (hoje: `users`); as demais entram uma a uma, copiadas do DER.
Ao executar git dentro de `apps/*`, lembre que são repositórios independentes do repo raiz, ligados
como submódulos: o repo raiz guarda só a URL e o commit de cada app. Clone com
`git clone --recurse-submodules` (ou `git submodule update --init` num clone existente); para
apontar a raiz para um commit novo de um app, `git add apps/<app>` e commit na raiz.

## Arquitetura (C4 — fonte: `docs/Diagramas/Diagramas-C4/`)

**Atores:** Visitante (não autenticado) · Cliente (colecionador) · Vendedor · Administrador.
No diagrama de casos de uso também existe "Administrador do Grupo" (herda de Cliente).

**Containers:**
| Container | Stack | Uso |
|---|---|---|
| Aplicação Web | React + Vite (SPA) | Visitantes e clientes |
| Aplicativo Mobile | React Native | Mesmas funções da web |
| Painel BackOffice | React + Vite (SPA) | Administradores |
| API de Aplicação | Node.js + Express + Prisma | REST, autenticação JWT (`Authorization: Bearer`) |
| Mensageria em Tempo Real | Node.js + WebSocket | Chat pessoal e de grupo, conexão autenticada via JWT |
| Banco de Dados | PostgreSQL (via Prisma ORM) | Todos os dados |

**Sistemas externos:** Gateway de Pagamento (Stripe/Mercado Pago, HTTPS/Webhook) e Transportadora.

**Componentes da API** (organize o backend por esses módulos):
Autenticação · Acesso Público · Coleção · Comunidade · Chat Pessoal · Perfil ·
Notificações e Favoritos · Pagamentos e Pedidos · Administração.

## Modelo de dados (DER — fonte: `docs/Diagramas/DER/`)

- **Fonte da verdade:** `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml`. Os `.sql` em
  `chartdb/` e os `.puml` são derivados dele — **mantenha os três formatos sincronizados** ao
  alterar o modelo (44 tabelas, 77 FKs, 22 enums). Os `.svg` estão desatualizados (pré-tradução).
- **Identificadores em inglês** (ADR-003): tabelas `snake_case` no **plural** (`users`, `orders`,
  `groups` — singular colide com palavras reservadas do PostgreSQL), colunas/enums no singular,
  valores de enum em MAIÚSCULAS, datas `*_at`. Comentários e notas continuam em português.
  Glossário PT → EN no `README.md` do DER — use-o ao ler casos de uso que citam nomes antigos.
- PK `id` **UUID v7** (`uuidv7()`, PostgreSQL 18+), FKs `uuid` (ADR-014) · associativas N:N com PK composta (`user_achievements`,
  `poll_votes`, `conversation_participants`) · FKs em `ALTER TABLE` no fim do SQL (`fk_<tabela>_<coluna>`).
- **Alvos polimórficos:** `favorites` (`type` + `album_id`/`card_id`/`group_id`, exatamente
  um preenchido) e `reports` (`target_type` + `listing_id`/`target_user_id`/`group_message_id`).
- `cards.album_id` nulo = carta avulsa (portfólio). `catalog_requests.data` é `jsonb`.
- **Tempo** (ADR-016): toda tabela termina com `created_at`, `updated_at`, `deleted_at` — todos `timestamptz`.
- `refresh_tokens` guarda só o hash do refresh token (ADR-005).
- **Soft delete** (ADR-015): excluir = `deleted_at = now()`, restaurar = `NULL`. Nunca `DELETE` em dado de
  negócio (exceção: tokens expirados, limpos por cron). Todo repository filtra `deletedAt: null`
  explicitamente; re-adicionar item excluído restaura a linha (upsert). `DELETED` não existe nos enums de status.

**8 módulos:**
| # | Módulo | Entidades |
|---|---|---|
| 1 | Usuários, Perfil e Acesso | users, profiles, addresses, password_reset_tokens, refresh_tokens, achievements, user_achievements, subscriptions |
| 2 | Catálogo Global | categories (hierárquica), rarities, languages, card_conditions, albums, cards, card_photos, price_history |
| 3 | Coleção do Cliente | collections (1:1 usuário), user_albums, collection_cards (status OWNED/MISSING/DUPLICATE + quantity) |
| 4 | Comunidade (Grupos) | groups, group_members, group_join_requests, group_messages, polls, poll_options, poll_votes |
| 5 | Chat Pessoal | conversations, conversation_participants, messages, user_blocks |
| 6 | Marketplace | listings, listing_photos, offers, orders, payments, reviews |
| 7 | Notificações e Favoritos | favorites, price_alerts, notifications, global_notifications |
| 8 | Moderação e Administração | reports, catalog_requests, audit_logs, global_settings |

Enums principais: `user_role` (CUSTOMER, SELLER, ADMIN) · `listing_status` (ACTIVE, PAUSED,
CLOSED) · `order_status` (AWAITING_PAYMENT, PAID, SHIPPED, DELIVERED, CANCELED) ·
`payment_method` (CREDIT_CARD, PIX, BOLETO). Veja o DBML para os demais.

A tabela de rastreabilidade entidade → caso de uso está em `docs/Diagramas/DER/README.md`.

## Requisitos: casos de uso e user stories

- Código dos casos de uso: **`CCDnnn`** (CCD001…). Arquivos em `docs/Casos-De-Uso/NN-nome.md`.
- Formato de cada caso de uso (tabelas Markdown): Nome · Finalidade/Objetivo · Atores ·
  Pré-condições · **Fluxo Principal** (Ações do Ator | Ações do Sistema) · **Fluxo Alternativo**.
  Siga esse formato ao criar novos.
- User stories: `docs/Casos-De-Uso/user-stories.md` — narrativa "Como <ator> preciso/quero … para …".
- **Escopo / fases** (legenda das user stories):
  - sem marcador → **MVP** (tag `mvp`)
  - `**` → **Futuro** (tag `futuro`) — ex.: escanear carta, alertas de preço, plano PRO, acessibilidade avançada
  - `***` → **Futuro Marketplace** (tag `futuro-marketplace`) — compra, anúncios, pedidos, avaliações
  Priorize o MVP ao implementar; entidades de funcionalidades futuras já existem no DER.
- Áreas funcionais: 1 Painel Público · 2 Painel Cliente · 3 Minha Coleção · 4 Grupos · 5 Chat
  Pessoal · 6 Perfil e Configurações · 7 Notificações e Favoritos · 8 BackOffice · 9 Painel Vendedor.

### Inconsistências conhecidas na documentação (não "corrigir" sem confirmar com o usuário)
- `10-buscar-album.md` tem título "Buscar Álbum", mas o conteúdo é **Solicitar Álbum** (CCD010).
- `80-visualizar-quantidade-disponivel.md` tem título duplicado; o conteúdo é **Visualizar Dados do Vendedor**.
- Busca por vendedor aparece em `33-` e em `67-`.
- CCD032/CCD033 divergem entre o board do Azure e a planilha `CromoCard 1.xlsx`.
- O diagrama de casos de uso (`.puml`) cobre só CCD001–CCD046; o de atividades vai até CCD066;
  os arquivos `.md` vão até 93 (marketplace e painel do vendedor).

## Azure DevOps (board da disciplina)

- Org/projeto `CromoCard`, time `CromoCard Team`. Acesso via MCP `azure-devops` (`.mcp.json`).
- **Nunca altere work items no Azure sem pedido explícito** — os docs em `Azure-Devops/` são leituras/propostas.
- Hierarquia desejada: Epic (produto ou processo) → Feature (área funcional) → User Story
  (`CCD0xx - Verbo + objeto`) → Task (ação técnica, ex.: `Criar endpoint GET /albuns`).
- `#84 Documentacao - CromoCard` é o épico de **processo** (sprints, cerimônias, diagramas); o
  produto deveria ter épico próprio.
- Cerimônias: `<Evento> Sprint NN` (ex.: `Planning Sprint 04`), Daily `Daily DD/MM`,
  apontamentos `Apontamento <Nome>` como Task filha da cerimônia, sempre dentro de `#89 Reuniões`.
- Tipos customizados existentes: Reuniões, Cerimônias, Daily, Spike, Task Spike — não criar novos.
- Equipe: Daniel Andrade (usuário), Felipe Consulim, Lucas Oliveira Lima, Felipe Broetto Araujo,
  Gabriel Nascimento, Lucca Rocha.

## Diagramas — dicas práticas

- PlantUML: exporte em **SVG, não PNG** (o servidor público corta PNG em 4096px).
- Diagramas DER 02 e 03 usam `left to right direction` — mantenha.
- Nas legendas `.puml`, escreva `|` como `&#124;`.
- C4 usa `!include` do C4-PlantUML via GitHub raw.

## Arquitetura do backend (decidida — ver `docs/ADR/`)

- **Monólito modular** (ADR-001): um repo, um banco, módulos por domínio em `src/domains/<dominio>`.
- **Stack** (ADR-002/003): Node 24 LTS + TypeScript strict + Express 5 + Prisma/PostgreSQL;
  schema e migrations em `database/` (não `prisma/`).
- **Arquivos por domínio** (ADR-004): `<d>.routes.ts`, `.controller.ts`, `.service.ts`,
  `.repository.ts`, `.validator.ts` (Zod), `.errors.ts`, `.swagger.ts`, `.module.ts`
  (composition root — monta dependências e exporta router + service), `.service.spec.ts`.
  Fluxo: rota → middlewares → controller → service → repository. Service dentro do domínio.
  Um domínio **nunca** importa o repository de outro — só a service exportada pelo `.module.ts`.
  Dependências sempre injetadas pelo construtor. `shared/` = reutilizável sem regra de negócio.
- **Estrutura do `src`** (ADR-020, sem pasta `infra`): `app.ts`, `server.ts`, `routes.ts` na raiz;
  `config/` (env, logger, swagger), `lib/` (prisma, jwt, zod), `domains/`, `shared/`
  (errors, middlewares, utils, types), `providers/`, `jobs/`, `socket/`.
- **Código sem comentários** (pedido do usuário): nomes claros no lugar de comentários.
- **Auth** (ADR-005): access JWT 15 min (`sub`, `role`) + refresh token opaco rotativo (hash em
  `refresh_tokens`); Google via `id_token` validado com `google-auth-library` (não é servidor OAuth2).
- **Validação/erros** (ADR-006): Zod gera validação, tipos e Swagger; erros `{ error, message, details? }`
  via `AppError` + `errorHandler` global.
- **API** (ADR-011): `/api/v1`, recursos plural kebab-case, `/me` para o usuário logado, ações via `POST /:id/<acao>`;
  resposta `{ data }` / `{ data, meta }`, JSON camelCase, datas ISO UTC, dinheiro como string decimal;
  `422` para regra de negócio, `409` conflito; paginação offset (`page`/`pageSize`) e cursor para chat/notificações.
- **Tempo real** (ADR-007/012): Socket.IO neste mesmo repo (`src/realtime.ts`), reusa services de chat/community;
  rooms `user:<id>`, `group:<id>`, `conversation:<id>`; eventos `dominio:acao`; persiste antes de emitir.
- **Qualidade** (ADR-008): ESLint + Prettier + `tsc --noEmit` + husky; testes `.spec.ts` com **Vitest**,
  cobertura mínima 80% nas services.
- **Providers** (ADR-009): CEP (ViaCEP/BrasilAPI), e-mail (Nodemailer + Ethereal em dev), storage
  (local/MinIO em dev, S3 depois), pagamento e transportadora — sempre via interface.
- **Cron** (ADR-010): `node-cron` em `infra/jobs/`, só com `JOBS_ENABLED=true`.
- Ações administrativas geram registro em `audit_logs`.
- **Convenções** (ADR-017): comentários em **pt-BR**, código em inglês; **npm** (`npm ci` no CI); imports com
  alias `@/`; sem `console.log`. Guia completo em `docs/Padroes/CONTRIBUTING.md`, template de PR em
  `docs/Padroes/pull_request_template.md` (copiar para cada repo de código).
- **Config** (ADR-018, proposto): só variáveis de ambiente, lidas/validadas em `src/config/env.ts`;
  ambientes local · test · homolog · produção (`APP_ENV`); segredos fora do repo.
- **Logs** (ADR-019, proposto): pino JSON, `requestId` por requisição, redaction de tokens/dados pessoais,
  `/health` e `/health/ready`, shutdown gracioso.
- Critério de code review: Clean Code, SOLID, Object Calisthenics (skill `code-review-daniel`).

Ao tomar uma nova decisão de arquitetura, registre um ADR novo em `docs/ADR/`, com o próximo número e o
modelo do `README.md` da pasta (não edite um ADR aceito).

## Git (ADR-013)

- Git Flow: `main` (produção, tag `vX.Y.Z`) ← `homolog` ← `development` ← `feature/<id-azure>-<descricao>`.
  `fix/*` sai de `development`; `hotfix/*` sai de `main` e volta para `homolog` e `development`.
- Nunca push direto nas branches fixas: sempre PR com 1 aprovação + CI verde.
- Conventional Commits em português com escopo do domínio: `feat(collection): marca carta como possuo`,
  rodapé `AB#<id>` para ligar ao Azure Boards.
- Neste repo de documentação: trabalho em `development`, PR para `main`. Guia completo de commits
  (tipos, escopo, exemplos, PRs) em `CONTRIBUTING.md`.
