# ADRs — Architecture Decision Records (CromoCard)

Um ADR registra **uma** decisão de arquitetura: o contexto, o que foi decidido, as
alternativas e as consequências. ADRs não são editados depois de aceitos. Se a
decisão mudar, cria-se um ADR novo que **substitui** o antigo, e o antigo passa a
ter o status `Substituído por ADR-XXX`.
A única exceção é corrigir um caminho de arquivo que mudou de lugar (nas Referências
ou no texto): isso não muda a decisão e mantém os links funcionando.

**Status possíveis:** `Proposto` (em discussão) · `Aceito` · `Substituído por ADR-XXX` · `Rejeitado`

- Um ADR `Proposto` aguarda validação do PO. Depois de validado, atualize o campo
  `Status` do arquivo e, se fizer sentido, replique o resultado no work item `#270`
  do Azure DevOps.
- O PO do projeto é o **Felipe Consulim**. Os ADRs aceitos antes de 11/11/2026 citam o
  Daniel Andrade como PO no campo `Decisores`; pela regra acima, eles não são editados,
  e esse registro fica como histórico. Daqui em diante, a validação é do Felipe.
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
| [015](ADR-015-soft-delete.md) | Dados | Exclusão de dados: soft delete com `deleted_at` | Aceito (ampliado pelo 016; exceção ao item 7 no 062) |
| [016](ADR-016-colunas-de-tempo-timestamptz.md) | Dados | `created_at`/`updated_at`/`deleted_at` em todas as tabelas + `timestamptz` | Aceito |
| [017](ADR-017-convencoes-de-codigo.md) | Processo | Convenções de código e contribuição (pt-BR nos comentários, npm, alias `@/`, template de PR) | Aceito |
| [018](ADR-018-configuracao-e-ambientes.md) | Backend | Configuração e ambientes (local, test, homolog, produção; `.env`; segredos) | Proposto |
| [019](ADR-019-logs-e-observabilidade.md) | Backend | Logs e observabilidade (pino, `requestId`, redaction, health check) | Proposto |
| [020](ADR-020-estrutura-src-sem-infra.md) | Backend | Estrutura do `src` sem a pasta `infra` (pastas na raiz do `src`) | Aceito |
| [021](ADR-021-separacao-de-clientes-por-plataforma.md) | Frontend | Separação das aplicações cliente por plataforma (Web, Mobile, BackOffice) | Substituído por ADR-038 e ADR-058 |
| [022](ADR-022-stack-frontend-web-backoffice-react-vite.md) | Frontend | Stack de frontend para Web e BackOffice: React + Vite | Substituído por ADR-039 |
| [023](ADR-023-stack-mobile-react-native.md) | Frontend | Stack do aplicativo mobile: React Native | Substituído por ADR-058 |
| [024](ADR-024-integracao-gateway-pagamento.md) | Integrações | Integração com gateway de pagamento externo via HTTPS/Webhook | Proposto |
| [025](ADR-025-integracao-transportadora.md) | Integrações | Integração com transportadora terceirizada para entrega física | Proposto |
| [026](ADR-026-estrutura-multi-repositorio.md) | Processo | Estrutura multi-repositório (workspace para SDD e documentação; um repositório por aplicação) | Aceito |
| [027](ADR-027-escopo-marketplace-no-mvp.md) | Produto | Escopo do Marketplace no MVP | Aceito |
| [028](ADR-028-stack-backend-node-express-prisma.md) | Backend | Stack de backend: Node.js + Express + Prisma | Substituído por ADR-002 |
| [029](ADR-029-banco-de-dados-postgresql.md) | Dados | Banco de dados relacional: PostgreSQL via Prisma ORM | Substituído por ADR-003 e ADR-014 |
| [030](ADR-030-autenticacao-jwt-compartilhada.md) | Backend | Autenticação via JWT compartilhado entre API REST e serviço de tempo real | Substituído por ADR-005 |
| [031](ADR-031-servico-tempo-real-dedicado.md) | Backend | Serviço de mensageria em tempo real como container dedicado | Substituído por ADR-007 e ADR-012 |
| [032](ADR-032-modelagem-polimorfica-favorito-denuncia.md) | Dados | Modelagem polimórfica para alvos de `favorito` e `denuncia` | Aceito |
| [033](ADR-033-convencoes-modelagem-dados.md) | Dados | Convenções de modelagem de dados (nomenclatura, PK, associativas N:N) | Substituído por ADR-003 e ADR-014 |
| [034](ADR-034-trilha-auditoria-acoes-administrativas.md) | Backend | Trilha de auditoria obrigatória para ações administrativas | Aceito |
| [035](ADR-035-heranca-tipos-usuario-diagrama-classes.md) | Diagramas | Herança de tipos de usuário no diagrama de classes (Single Table Inheritance) | Aceito |
| [036](ADR-036-granularidade-diagrama-classes.md) | Diagramas | Granularidade do diagrama de classes (1:1 com as tabelas do DER) | Aceito |
| [037](ADR-037-notacao-relacionamento-diagrama-classes.md) | Diagramas | Notação de relacionamento no diagrama de classes (rótulo textual) | Aceito |
| [038](ADR-038-spa-unico-web-e-backoffice.md) | Frontend | Web e BackOffice num único SPA, separados por rota e papel | Aceito (mobile: ver 058) |
| [039](ADR-039-stack-frontend-react-typescript-vite.md) | Frontend | Stack do frontend web: React 19 + TypeScript + Vite + React Router | Aceito |
| [040](ADR-040-estrutura-frontend-por-feature.md) | Frontend | Estrutura de pastas do frontend por feature | Aceito |
| [041](ADR-041-comunicacao-api-estado-servidor.md) | Frontend | Comunicação com a API e estado do servidor: cliente HTTP único + TanStack Query | Aceito |
| [042](ADR-042-formularios-react-hook-form-zod.md) | Frontend | Formulários e validação: React Hook Form + Zod | Aceito |
| [043](ADR-043-sessao-e-controle-de-acesso-no-frontend.md) | Frontend | Sessão e controle de acesso no frontend (token em memória, guards por papel) | Aceito |
| [044](ADR-044-estilos-css-modules-e-tokens.md) | Frontend | Estilos: CSS Modules + design tokens, sem biblioteca de componentes | Aceito |
| [045](ADR-045-configuracao-runtime-e-imagem-docker-frontend.md) | Frontend | Configuração em runtime e imagem Docker do frontend (uma imagem para todos os ambientes) | Aceito |
| [046](ADR-046-qualidade-frontend-lint-testes.md) | Frontend | Qualidade do frontend: ESLint, Prettier, `tsc` e Vitest + Testing Library | Aceito |
| [047](ADR-047-desenvolvimento-orientado-a-especificacao.md) | Processo | SDD: spec, plano e tarefas por user story em `specs/` | Proposto |
| [048](ADR-048-tokens-de-email-e-google-no-frontend.md) | Backend | Tokens de confirmação de e-mail e de redefinição de senha; client ID do Google no frontend | Aceito |
| [049](ADR-049-middlewares-http-da-autenticacao.md) | Backend | Middlewares HTTP da autenticação: `express-rate-limit` e `cookie-parser` | Aceito |
| [050](ADR-050-upload-e-arquivos-csv-e-pdf.md) | Backend | Upload de imagens e arquivos CSV e PDF: `multer`, `csv-parse` e `pdfkit` | Aceito |
| [051](ADR-051-convencoes-das-colunas-flexiveis-do-backoffice.md) | Dados | Convenções das colunas flexíveis do BackOffice (`global_settings`, `notifications.type`, `catalog_requests.data`, `audit_logs`) | Aceito (item 1 substituído parcialmente pelo 061) |
| [052](ADR-052-credenciamento-de-vendedor-no-modelo-de-dados.md) | Dados | Credenciamento de vendedor no modelo de dados (`seller_verifications`, documentos e notas) | Aceito |
| [053](ADR-053-colunas-e-tabelas-do-escopo-adicional-do-backoffice.md) | Dados | Colunas, enums e tabelas do escopo adicional do BackOffice | Aceito |
| [054](ADR-054-tabelas-do-marketplace-para-indicadores.md) | Dados | Tabelas do marketplace criadas (só leitura) para os indicadores financeiros | Aceito |
| [055](ADR-055-topologia-de-ambientes-e-implantacao.md) | Infraestrutura | Topologia de ambientes e implantação no servidor próprio (Compose, GHCR, runner self-hosted, Cloudflare Tunnel, Tailscale, backup) | Aceito |
| [056](ADR-056-runner-de-deploy-por-repositorio.md) | Infraestrutura | Um runner de deploy por repositório no servidor e deploy próprio do frontend (substitui parcialmente a decisão 8 do 055) | Proposto |
| [057](ADR-057-imagens-publicas-no-ghcr.md) | Infraestrutura | Imagens públicas no GHCR, sem segredo dentro da imagem (substitui parcialmente a decisão 7 do 055) | Proposto |
| [058](ADR-058-sem-aplicativo-mobile.md) | Frontend | Sem aplicativo mobile: o CromoCard é só web (substitui o 023) | Aceito |
| [059](ADR-059-provedor-de-email-por-ambiente.md) | Infraestrutura | Provedor de e-mail por ambiente: Ethereal em homologação e Resend (SMTP) em produção | Proposto |
| [060](ADR-060-fluxo-de-desenvolvimento-e-revisao-com-figma-e-cobertura.md) | Processo | Fluxo de desenvolvimento e revisão: decisão sobre o Figma, cobertura de 90% e skills únicas (substitui parcialmente 008, 046 e 047) | Proposto |
| [061](ADR-061-chaves-de-configuracao-das-metas-e-dos-versos.md) | Dados | Chaves de configuração das metas e dos versos padrão em `global_settings` (substitui parcialmente o item 1 do 051) | Aceito |
| [062](ADR-062-slug-de-categoria-unico-entre-as-ativas.md) | Dados | Slug de categoria único só entre as não excluídas, com índice parcial e sem restaurar (exceção ao item 7 do 015) | Aceito |
| [063](ADR-063-codigo-de-carta-unico-entre-as-ativas.md) | Dados | Código de carta único só entre as não excluídas, com índice parcial e sem restaurar (exceção ao item 7 do 015) | Aceito |
| [064](ADR-064-categoria-sem-tipo-e-franquia-da-carta-pelo-album.md) | Dados | Categoria sem tipo (`ALBUM`/`CARD`): a mesma franquia serve a álbuns e cartas, e a carta com álbum tem a franquia do álbum | Aceito |
| [065](ADR-065-teste-de-carga-com-k6.md) | Infraestrutura | Teste de carga e de estresse da API com k6: meta de 1 mi de escritas e 2 mi de leituras por dia (105 req/s no pico), réplica, hml e projeto descartável no servidor | Aceito |
| [066](ADR-066-pagamento-com-stripe-checkout-e-repasse-pelo-connect.md) | Backend | Pagamento com Stripe Checkout, valor retido na plataforma e repasse pelo Connect (decide o 024) | Aceito |
| [067](ADR-067-frete-e-rastreio-pelo-melhor-envio.md) | Backend | Frete, etiqueta e rastreio pelo Melhor Envio (decide o 025) | Aceito |
| [068](ADR-068-storage-privado-para-arquivos-sem-url-publica.md) | Backend | Storage privado para arquivos sem URL pública (complementa o 009) | Aceito |
| [069](ADR-069-remover-avaliacoes-e-propostas.md) | Escopo | Remover avaliações e propostas (CCD033, 070, 081, 089, `offers` e `reviews`) e puxar para o MVP as futuras com tela no Figma; substitui trechos dos 010, 015 e 054 | Proposto |
| [070](ADR-070-fidelidade-ao-figma-obrigatoria-na-spec.md) | Processo | Fidelidade ao Figma obrigatória na spec: requisito `Fidelidade` e critério de aceite por frame, em 1280 px lado a lado e adaptado em 375, 768 e 1024 px (complementa o 060) | Proposto |
| [071](ADR-071-webhook-da-conta-conectada-reconsulta-a-stripe.md) | Backend | O `account.updated` da Stripe reconsulta a conta conectada e grava o estado atual, sem tabela de eventos (complementa o 066) | Proposto |
| [072](ADR-072-token-fixo-do-melhor-envio-no-sandbox.md) | Backend | Token fixo do Melhor Envio no sandbox, renovado à mão antes de vencer (complementa o 067) | Proposto |

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
