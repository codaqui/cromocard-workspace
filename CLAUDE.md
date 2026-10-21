# CLAUDE.md — CromoCard

Projeto acadêmico (Escola de TI) em equipe: **CromoCard — Sistema de Gestão de Cartas Colecionáveis**.
Plataforma para colecionadores organizarem álbuns e cartas/figurinhas, participarem de grupos
da comunidade, conversarem em tempo real e negociarem cartas num marketplace. Administradores
gerenciam usuários, catálogo e comunidade.

Idioma do projeto: **português (pt-BR)** — responda, documente e escreva commits em português.
**Código e banco em inglês** (identificadores, tabelas, colunas, enums, nomes de arquivo).

## Estrutura do repositório

```
cromocard-workspace/               (repo de documentação/workspace — branch de trabalho: development, principal: main)
├── docs/                          documentação — a fonte da verdade; só guarda documentação
│   ├── ADR/                       ADR-001…046 + README.md (índice e modelo) — decisões de arquitetura; LEIA antes de mexer no backend ou no frontend
│   ├── Casos-De-Uso/              NN-nome-do-caso.md (01–93), user-stories.md, resumo-user-stories.md, CromoCard 1.xlsx
│   ├── Diagrama-de-Classe/        cromocard-diagrama-classes.v2.c4 (LikeC4, atual) + .v1.c4 (histórico) + README.md — 43 classes, 1:1 com o DER
│   └── Diagramas/
│       ├── DER/                   puml/, dbdiagram.io/ (DBML), chartdb/ (DDL PostgreSQL) + README.md
│       ├── Diagramas-C4/          01-contexto, 02-containers, 03-componentes (.puml + .svg)
│       ├── Diagrama-Casos-de-Uso/ cromocard_casos_de_uso.puml (CCD001–CCD046)
│       └── Diagrama-Atividades/   Diagrama_Atividades.c4 (LikeC4, CCD001–CCD066)
├── specs/                         SDD (ADR-047): README.md (fluxo e índice), template/ e uma pasta CCDnnn-nome/ por user story
├── apps/                          submódulos git (`.gitmodules`) — cada app é um repo git próprio
│   ├── cromocard-backend/         github.com/codaqui/cromocard-backend   (esqueleto + domínio de exemplo `users` em `develop`)
│   └── cromocard-frontend/        github.com/codaqui/cromocard-frontend  (esqueleto + feature de exemplo `users` em `develop`)
├── .claude/
│   ├── settings.json              aprova os MCPs, libera leituras e pede confirmação nas escritas
│   ├── rules/                     git (sempre) + regras por pasta: backend, frontend, modelagem de dados, casos de uso, specs, ADRs, diagramas
│   ├── skills/                    /especificar, /planejar, /implementar, /conferir-tarefa, /analisar-figma-chrome, /analisar-figma-mcp, /revisar-codigo, /criar-pr
│   └── agents/                    analista-requisitos, leitor-figma, revisor-codigo
├── .mcp.json                      MCPs do time: `azure-devops` (board, PAT de cada pessoa em `$AZURE_DEVOPS_PAT`), `figma` (protótipo, OAuth via `/mcp`) e `playwright` (Chrome isolado para testar os apps rodando; o Figma segue pelo Claude in Chrome)
├── README.md                      como clonar (com submódulos) e o setup de cada pessoa (token do Azure, login no Figma)
└── CromoCardWorks.code-workspace  workspace VS Code (raiz + os 2 apps)
```

**`docs/` é a fonte da verdade e só guarda documentação:** casos de uso, user stories, DER, diagramas e ADRs. O que
deriva dela ou é material de trabalho fica fora de `docs/` (as specs do SDD ficam em `specs/`).

## Apps

| App | Caminho | Stack | Modelo a copiar | Regras |
|---|---|---|---|---|
| Backend | `apps/cromocard-backend` | Node 24 + TypeScript + Express 5 + Prisma/PostgreSQL (ADRs 001–020) | domínio `src/domains/users/` | `.claude/rules/backend.md` |
| Frontend | `apps/cromocard-frontend` | React 19 + TypeScript + Vite, SPA único para Web e BackOffice (ADRs 038–046) | feature `src/features/users/` | `.claude/rules/frontend.md` |

As rules de cada app (comandos, estrutura, regras e qualidade) carregam quando você lê ou edita arquivos do app.
Os dois usam a branch base `develop` e Node 24 (`.nvmrc`).

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

Na implementação, Aplicação Web e Painel BackOffice são **um único SPA** (`cromocard-frontend`, BackOffice
em `/backoffice`) — ADR-038. O C4 nível 2 ainda mostra os dois containers separados.

**Sistemas externos:** Gateway de Pagamento (Stripe/Mercado Pago, HTTPS/Webhook) e Transportadora.

**Componentes da API** (organize o backend por esses módulos):
Autenticação · Acesso Público · Coleção · Comunidade · Chat Pessoal · Perfil ·
Notificações e Favoritos · Pagamentos e Pedidos · Administração.

## Modelo de dados (DER — fonte: `docs/Diagramas/DER/`)

**Fonte da verdade:** `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml` (44 tabelas, 77 FKs, 22 enums).
As convenções (nomes em inglês, UUID v7, colunas de tempo, soft delete, alvos polimórficos, sincronia dos três
formatos) estão em `.claude/rules/modelagem-de-dados.md`.

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

- Código dos casos de uso: **`CCDnnn`** = número do arquivo (`CCD014` → `docs/Casos-De-Uso/14-*.md`). No Azure,
  a user story tem o título `CCD014 - <Nome>`. Formato de um caso de uso: `.claude/rules/casos-de-uso.md`.
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

## SDD — da user story ao código (ADR-047)

Cada user story ganha uma pasta em `specs/CCDnnn-<nome>/` com `spec.md` (o quê: requisitos `R` com origem,
critérios de aceite `CA`, telas, lacunas), `plano.md` (como: dados, contrato da API, arquivos, testes) e
`tarefas.md` (em que ordem, com o `AB#` de cada Task). Fluxo e índice em `specs/README.md`; regras em
`.claude/rules/specs.md`.

```
/especificar CCDnnn → spec Rascunho → PO aprova → /planejar → /implementar <app> → /revisar-codigo → /criar-pr
```

- Fontes: **documentação → spec → código**. A spec não cria requisito; lacuna decidida volta para o caso de uso
  (regra de negócio) ou vira ADR (decisão técnica).
- A spec deriva da documentação, por isso fica em `specs/` e nunca em `docs/`.
- Só o usuário confirma uma spec como `Aprovada` (validação do PO), como nos ADRs.
- Antes de implementar uma user story, procure a spec dela. Sem spec, ofereça o `/especificar`; com spec, o código
  segue o plano e o contrato da API, e um desvio corrige a spec ou o plano antes do código.

## Azure DevOps (board da disciplina)

- Org/projeto `CromoCard`, time `CromoCard Team`. Acesso via MCP `azure-devops` (`.mcp.json`);
  as ferramentas de escrita pedem confirmação (`.claude/settings.json`).
- **Nunca altere work items no Azure sem pedido explícito.**
- Hierarquia desejada: Epic (produto ou processo) → Feature (área funcional) → User Story
  (`CCD0xx - Verbo + objeto`) → Task (ação técnica, ex.: `Criar endpoint GET /albuns`).
- `#84 Documentacao - CromoCard` é o épico de **processo** (sprints, cerimônias, diagramas); o
  produto deveria ter épico próprio.
- Cerimônias: `<Evento> Sprint NN` (ex.: `Planning Sprint 04`), Daily `Daily DD/MM`,
  apontamentos `Apontamento <Nome>` como Task filha da cerimônia, sempre dentro de `#89 Reuniões`.
- Tipos customizados existentes: Reuniões, Cerimônias, Daily, Spike, Task Spike — não criar novos.
- Equipe: Daniel Andrade (usuário), Felipe Consulim, Lucas Oliveira Lima, Felipe Broetto Araujo,
  Gabriel Nascimento, Lucca Rocha.

## Figma (protótipo)

- Arquivo: https://www.figma.com/design/43K7rTPJQNIOroQ4j09YTP (fileKey `43K7rTPJQNIOroQ4j09YTP`),
  mantido por Gabriel Nascimento. Uma página só (`Page 1`); o índice das 44 telas (nome → `node-id`) fica na skill
  `/analisar-figma-chrome`.
- **Analise telas pelo Claude in Chrome** (skill `/analisar-figma-chrome`, agent `leitor-figma`): prints no modo
  protótipo, só leitura, sem cota. **Nunca abra o editor** (`/design/`) no Chrome: ele trava a extensão.
- **A documentação é a fonte da verdade** (casos de uso, user stories, DER, ADRs); o Figma é o design
  a seguir na implementação. O Figma foi feito a partir da documentação: se ele divergir dela ou
  deixar algum requisito de fora, aponte onde (tela/frame) em vez de seguir o Figma ou omitir o requisito.
- O MCP `figma` tem cota (cerca de 20 chamadas por mês no plano Starter): só pela skill `/analisar-figma-mcp`, quando
  o usuário pedir, para medidas/tokens ou para regenerar o índice de telas.
- Não edite o arquivo do Figma sem pedido explícito.

## ADRs

Ao tomar uma nova decisão de arquitetura, registre um ADR novo em `docs/ADR/`, com o próximo número e o
modelo do `README.md` da pasta. Todo ADR nasce `Proposto` e só muda de status com a validação do PO; não edite
um ADR aceito. Detalhes em `.claude/rules/adrs.md`.

## Skills e agents do time

| Skill | Quando usar |
|---|---|
| `/especificar <CCDnnn ou #id> [link do frame]` | SDD passo 1: cria ou atualiza o `spec.md` da user story a partir da documentação e do Figma |
| `/planejar <CCDnnn>` | SDD passo 2, com a spec aprovada: gera `plano.md` e `tarefas.md` e oferece criar as Tasks no Azure |
| `/implementar <CCDnnn> <backend\|frontend> [T<n>]` | SDD passo 3: executa as tarefas no app, uma por vez, sem sair da spec |
| `/conferir-tarefa <#id ou CCDnnn> [link do frame]` | Antes de implementar uma tela: confere se o Figma cobre a documentação e aponta onde está errado |
| `/analisar-figma-chrome <link ou nome da tela>` | Analisa uma tela do Figma por prints no Chrome (modo protótipo, sem cota) e devolve o inventário dela |
| `/analisar-figma-mcp <link ou nome da tela> [o que precisa]` | Mesma análise pelo MCP do Figma (gasta cota): estrutura, tokens, contexto de implementação e regenerar o índice de telas |
| `/revisar-codigo [repo] [base] [#id]` | Antes do PR: revisão em dois eixos, padrões e spec |
| `/criar-pr [repo] [#id]` | Abre o PR no padrão: branch, commits com `AB#`, checagens, push e template |

| Agent | Faz |
|---|---|
| `analista-requisitos` | Lista os requisitos de uma tarefa com a origem de cada um (spec salva, caso de uso, user story, work item, DER); no modo revisão, marca o que o diff implementou e confere o contrato da API |
| `leitor-figma` | Inventário de telas do Figma pelo Chrome (segue a `/analisar-figma-chrome`), fora da conversa principal |
| `revisor-codigo` | Revisa um diff contra ADRs, rules, Clean Code, SOLID e Object Calisthenics |

Critério de code review do projeto: Clean Code, SOLID e Object Calisthenics, aplicado pelo `revisor-codigo`.

## Git (ADR-013)

Branches, commits (Conventional Commits em pt-BR com rodapé `AB#<id>`) e PRs estão em `.claude/rules/git.md`,
que carrega em toda sessão. Nunca faça push direto em `main`, `homolog`, `develop` ou `development`.
