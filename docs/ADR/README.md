# ADRs — Architecture Decision Records (CromoCard)

Um ADR registra **uma** decisão de arquitetura: o contexto, o que foi decidido, as
alternativas e as consequências. ADRs não são editados depois de aceitos. Se a
decisão mudar, cria-se um ADR novo que **substitui** o antigo, e o antigo passa a
ter o status `Substituído por ADR-XXX`.

**Status possíveis:** `Proposto` (em discussão) · `Aceito` · `Substituído por ADR-XXX` · `Rejeitado`

- Um ADR `Proposto` aguarda validação do PO. Depois de validado, atualize o campo
  `Status` do arquivo e, se fizer sentido, replique o resultado no work item `#270`
  do Azure DevOps.
- Ao criar um ADR novo, use o próximo número sequencial e o modelo abaixo.

## Índice

| # | Área | Decisão | Status |
|---|---|---|---|
| [001](ADR-001-monolito-modular.md) | Backend | Estilo arquitetural: monólito modular | Aceito |
| [002](ADR-002-stack-node-typescript-express.md) | Backend | Stack: Node.js 24 LTS + TypeScript + Express 5 | Aceito |
| [003](ADR-003-postgresql-prisma-schema-ingles.md) | Dados | Banco: PostgreSQL + Prisma, pasta `database/`, schema em inglês | Aceito (IDs: ver 014) |
| [004](ADR-004-estrutura-de-pastas-por-dominio.md) | Backend | Estrutura de pastas por domínio e camadas | Aceito (pasta `infra` substituída pelo 020) |
| [005](ADR-005-autenticacao-jwt-refresh-google.md) | Backend | Autenticação: JWT + refresh token + login Google (OIDC) | Aceito |
| [006](ADR-006-validacao-zod-swagger.md) | Backend | Validação com Zod e Swagger gerado a partir dos validators | Aceito |
| [007](ADR-007-tempo-real-websocket.md) | Backend | Tempo real: WebSocket no mesmo repositório | Aceito (biblioteca definida no ADR-012) |
| [008](ADR-008-qualidade-lint-tsc-testes.md) | Backend | Qualidade: ESLint, Prettier, `tsc` e testes `.spec` com Vitest + cobertura | Aceito |
| [009](ADR-009-integracoes-externas-providers.md) | Backend | Integrações externas via providers: CEP, e-mail, storage, pagamento | Aceito |
| [010](ADR-010-jobs-agendados-cron.md) | Backend | Jobs agendados com cron | Aceito |
| [011](ADR-011-convencoes-da-api-rest.md) | Backend | Convenções da API REST (`/api/v1`, envelope, paginação, status) | Aceito |
| [012](ADR-012-socket-io.md) | Backend | Biblioteca de tempo real: Socket.IO | Aceito |
| [013](ADR-013-git-flow.md) | Processo | Git Flow: main · homolog · development · feature + Conventional Commits | Aceito |
| [014](ADR-014-ids-uuid-v7.md) | Dados | Identificadores: UUID v7 (PostgreSQL 18) | Aceito |
| [015](ADR-015-soft-delete.md) | Dados | Exclusão de dados: soft delete com `deleted_at` | Aceito (ampliado pelo 016) |
| [016](ADR-016-colunas-de-tempo-timestamptz.md) | Dados | `created_at`/`updated_at`/`deleted_at` em todas as tabelas + `timestamptz` | Aceito |
| [017](ADR-017-convencoes-de-codigo.md) | Processo | Convenções de código e contribuição (pt-BR nos comentários, npm, alias `@/`, template de PR) | Aceito |
| [018](ADR-018-configuracao-e-ambientes.md) | Backend | Configuração e ambientes (local, test, homolog, produção; `.env`; segredos) | Proposto |
| [019](ADR-019-logs-e-observabilidade.md) | Backend | Logs e observabilidade (pino, `requestId`, redaction, health check) | Proposto |
| [020](ADR-020-estrutura-src-sem-infra.md) | Backend | Estrutura do `src` sem a pasta `infra` (pastas na raiz do `src`) | Aceito |
| [021](ADR-021-separacao-de-clientes-por-plataforma.md) | Frontend | Separação das aplicações cliente por plataforma (Web, Mobile, BackOffice) | Substituído parcialmente por ADR-038 |
| [022](ADR-022-stack-frontend-web-backoffice-react-vite.md) | Frontend | Stack de frontend para Web e BackOffice: React + Vite | Substituído por ADR-039 |
| [023](ADR-023-stack-mobile-react-native.md) | Frontend | Stack do aplicativo mobile: React Native | Proposto |
| [024](ADR-024-integracao-gateway-pagamento.md) | Integrações | Integração com gateway de pagamento externo via HTTPS/Webhook | Proposto |
| [025](ADR-025-integracao-transportadora.md) | Integrações | Integração com transportadora terceirizada para entrega física | Proposto |
| [026](ADR-026-estrutura-multi-repositorio.md) | Processo | Estrutura multi-repositório (workspace para SDD e documentação; um repositório por aplicação) | Proposto |
| [027](ADR-027-escopo-marketplace-no-mvp.md) | Produto | Escopo do Marketplace no MVP (decisão em aberto) | Proposto |
| [028](ADR-028-stack-backend-node-express-prisma.md) | Backend | Stack de backend: Node.js + Express + Prisma | Substituído por ADR-002 |
| [029](ADR-029-banco-de-dados-postgresql.md) | Dados | Banco de dados relacional: PostgreSQL via Prisma ORM | Substituído por ADR-003 e ADR-014 |
| [030](ADR-030-autenticacao-jwt-compartilhada.md) | Backend | Autenticação via JWT compartilhado entre API REST e serviço de tempo real | Substituído por ADR-005 |
| [031](ADR-031-servico-tempo-real-dedicado.md) | Backend | Serviço de mensageria em tempo real como container dedicado | Substituído por ADR-007 e ADR-012 |
| [032](ADR-032-modelagem-polimorfica-favorito-denuncia.md) | Dados | Modelagem polimórfica para alvos de `favorito` e `denuncia` | Proposto |
| [033](ADR-033-convencoes-modelagem-dados.md) | Dados | Convenções de modelagem de dados (nomenclatura, PK, associativas N:N) | Substituído por ADR-003 e ADR-014 |
| [034](ADR-034-trilha-auditoria-acoes-administrativas.md) | Backend | Trilha de auditoria obrigatória para ações administrativas | Proposto |
| [035](ADR-035-heranca-tipos-usuario-diagrama-classes.md) | Diagramas | Herança de tipos de usuário no diagrama de classes (Single Table Inheritance) | Proposto |
| [036](ADR-036-granularidade-diagrama-classes.md) | Diagramas | Granularidade do diagrama de classes (1:1 com as 43 entidades do DER) | Proposto |
| [037](ADR-037-notacao-relacionamento-diagrama-classes.md) | Diagramas | Notação de relacionamento no diagrama de classes (rótulo textual) | Proposto |
| [038](ADR-038-spa-unico-web-e-backoffice.md) | Frontend | Web e BackOffice num único SPA, separados por rota e papel | Aceito |
| [039](ADR-039-stack-frontend-react-typescript-vite.md) | Frontend | Stack do frontend web: React 19 + TypeScript + Vite + React Router | Aceito |
| [040](ADR-040-estrutura-frontend-por-feature.md) | Frontend | Estrutura de pastas do frontend por feature | Aceito |
| [041](ADR-041-comunicacao-api-estado-servidor.md) | Frontend | Comunicação com a API e estado do servidor: cliente HTTP único + TanStack Query | Aceito |
| [042](ADR-042-formularios-react-hook-form-zod.md) | Frontend | Formulários e validação: React Hook Form + Zod | Aceito |
| [043](ADR-043-sessao-e-controle-de-acesso-no-frontend.md) | Frontend | Sessão e controle de acesso no frontend (token em memória, guards por papel) | Aceito |
| [044](ADR-044-estilos-css-modules-e-tokens.md) | Frontend | Estilos: CSS Modules + design tokens, sem biblioteca de componentes | Aceito |
| [045](ADR-045-configuracao-runtime-e-imagem-docker-frontend.md) | Frontend | Configuração em runtime e imagem Docker do frontend (uma imagem para todos os ambientes) | Aceito |
| [046](ADR-046-qualidade-frontend-lint-testes.md) | Frontend | Qualidade do frontend: ESLint, Prettier, `tsc` e Vitest + Testing Library | Aceito |
| [047](ADR-047-desenvolvimento-orientado-a-especificacao.md) | Processo | SDD: spec, plano e tarefas por user story em `specs/` | Proposto |

## Modelo

```markdown
# ADR-XXX — Título

- **Status:** Proposto
- **Data:** AAAA-MM-DD
- **Decisores:** ...

## Contexto
O problema e as forças envolvidas.

## Decisão
O que foi decidido, no imperativo.

## Alternativas consideradas
O que mais foi avaliado e por que não foi escolhido.

## Consequências
O que fica mais fácil, o que fica mais difícil e o que precisa ser feito.

## Referências (opcional)
Diagramas, casos de uso e documentos que embasam a decisão.
```
