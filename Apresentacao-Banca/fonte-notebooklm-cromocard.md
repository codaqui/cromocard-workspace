# CromoCard — Fonte consolidada para a apresentação da 1ª Banca de TCC

> Documento-fonte para o NotebookLM. Reúne **apenas fatos validados** nos artefatos do repositório
> `CROMOCARD-WORKSPACE` (branch `development`). Onde o dado ainda não existe no repositório, o texto
> está marcado como **[PENDENTE]** e deve aparecer assim no slide até a equipe completar.
> A seção 3 ("Roteiro slide a slide") define a ordem, os títulos e o conteúdo de cada slide.

---

## 1. Visão geral do projeto

**Nome:** CromoCard
**Definição:** Sistema de Gestão de Cartas Colecionáveis. Plataforma de coleção, comunidade e troca de cartas.
**Descrição oficial (Diagrama C4 – Contexto):** permite que colecionadores organizem álbuns e cartas,
participem de grupos da comunidade, conversem em tempo real, negociem cartas e assinem planos, e permite
que administradores gerenciem usuários, catálogo e comunidade.

**Instituição / curso / orientador / integrantes / data da banca:** [PENDENTE]

**Problema e justificativa:** [PENDENTE — a equipe deve redigir a partir da Pesquisa de Mercado (item #202 do board).]
Hipótese de trabalho a validar: colecionadores de cartas e figurinhas controlam coleções de forma
dispersa (planilhas, anotações, grupos de mensagens) e negociam trocas e vendas em canais genéricos,
sem um lugar único para acompanhar o progresso do álbum, encontrar outros colecionadores e comprar ou vender cartas.

**Objetivo geral (derivado do C4 – Contexto):** desenvolver uma plataforma web (acessível também pelo navegador do celular) que centralize a
gestão de coleções de cartas colecionáveis, a interação entre colecionadores e a negociação de cartas,
com um painel administrativo para gestão e moderação.

**Objetivos específicos (derivados dos módulos do sistema):**
1. Permitir ao colecionador cadastrar álbuns e cartas e acompanhar o progresso da coleção (possuo, faltante, repetida).
2. Oferecer busca e filtros no catálogo global de cartas (nome, número, coleção, categoria, raridade, idioma).
3. Criar grupos de comunidade e chat pessoal para comunicação e combinação de trocas.
4. Disponibilizar um marketplace para compra e venda de cartas, integrado a gateway de pagamento e transportadora.
5. Fornecer um painel administrativo (BackOffice) com indicadores, gestão de usuários, catálogo, comunidade e auditoria.

---

## 2. Fatos validados por artefato

### 2.1 Atores do sistema

| Ator | Papel |
|---|---|
| Visitante | Usuário não autenticado que explora a plataforma antes de criar conta |
| Cliente (colecionador) | Usuário autenticado que gerencia a coleção, participa de grupos, conversa e compra cartas |
| Vendedor | Usuário que cria e gerencia anúncios no marketplace e acompanha suas vendas |
| Administrador | Responsável pela gestão, moderação e configuração da plataforma |

### 2.2 Escopo funcional — 93 casos de uso em 9 módulos

Casos de uso documentados individualmente (CCD001 a CCD093), cada um com nome, objetivo, atores,
pré-condições, fluxo principal e fluxo alternativo.

| # | Módulo | Casos de uso | Qtde | Exemplos |
|---|---|---|---|---|
| 1 | Painel Público | CCD001–CCD006 | 6 | Visualizar destaques, busca global, criar conta, login (e-mail/senha ou Google), FAQ, recuperar senha |
| 2 | Álbuns, Coleção e Catálogo | CCD007–CCD038 | 32 | Resumo da coleção, listar/buscar/solicitar álbum, marcar carta possuo/faltante/repetida, progresso do álbum, buscas e filtros, acessibilidade |
| 3 | Grupos da Comunidade | CCD039–CCD044 | 6 | Explorar e entrar em grupos, criar e administrar grupo, chat do grupo, denunciar mensagem |
| 4 | Chat Pessoal | CCD045–CCD047 | 3 | Responder mensagem, visualizar mensagens, bloquear/denunciar contatos |
| 5 | Perfil e Configurações | CCD048–CCD052 | 5 | Editar perfil, vitrine de conquistas, privacidade e senha, exclusão da conta |
| 6 | Notificações e Favoritos | CCD053–CCD057 | 5 | Central de notificações, favoritar álbum/carta/grupo |
| 7 | BackOffice (Administração) | CCD058–CCD066 | 9 | Dashboard gerencial, gestão de usuários/catálogo/comunidade, notificação global, relatórios, aprovar solicitações, log de auditoria |
| 8 | Marketplace (comprador) | CCD067–CCD083 | 17 | Ordenar por preço/avaliação/recência, comprar, contato com vendedor, histórico de preços, pedidos, denúncias |
| 9 | Painel do Vendedor | CCD084–CCD093 | 10 | Criar/editar/excluir/pausar/reativar anúncio, propostas, total de vendas, cartas mais vendidas |

**Total: 93 casos de uso.**

### 2.3 User Stories e priorização

O backlog tem **111 user stories** no formato "Como <ator> preciso <ação> para <benefício>", organizadas nos
mesmos módulos. A priorização usa uma legenda de fase:

| Fase | Marcador | Qtde de user stories |
|---|---|---|
| MVP (escopo inicial) | sem marcador | 76 |
| Futuro | `**` | 16 |
| Futuro Marketplace | `***` | 19 |

Exemplos de itens futuros: escanear carta por imagem ou código, alertas de preço, plano PRO (assinatura),
status de leitura no chat, compartilhar conquista no Instagram/WhatsApp.

### 2.4 Arquitetura — Modelo C4

**Nível 1 – Contexto:** três atores (Visitante, Cliente, Administrador) usam o Sistema de Gestão de Cartas
Colecionáveis. Sistemas externos: **Gateway de Pagamento** (ex.: Stripe/Mercado Pago, via HTTPS/Webhook) e
**Transportadora** (entrega física das cartas compradas).

**Nível 2 – Containers:**

| Container | Tecnologia | Função |
|---|---|---|
| Aplicação Web (SPA) | React 19 + TypeScript + Vite | SPA único com as áreas Pública, Cliente e BackOffice (`/backoffice`), separadas por rota e papel (ADR-038) |
| API de Aplicação | Node.js + Express + Prisma | Regras de negócio via REST; autenticação JWT |
| Serviço de Mensageria em Tempo Real | Node.js + Socket.IO | Chat pessoal e de grupo em tempo real, autenticado via JWT |
| Banco de Dados | PostgreSQL | Persistência de todos os dados, acessado via Prisma ORM |

**Nível 3 – Componentes da API (9 módulos):** Autenticação · Acesso Público · Coleção · Comunidade ·
Chat Pessoal · Perfil · Notificações e Favoritos · Pagamentos e Pedidos · Administração.
O módulo de Pagamentos e Pedidos integra com o gateway de pagamento e a transportadora.

### 2.5 Modelo de dados — DER

- Banco **PostgreSQL**, acessado via **Prisma ORM**.
- **43 tabelas**, **76 chaves estrangeiras**, **22 enums**, organizadas em **8 módulos**:

| Módulo de dados | Tabelas principais |
|---|---|
| Usuários, Perfil e Acesso | usuario, perfil, endereco, token_recuperacao_senha, conquista, assinatura |
| Catálogo Global | categoria, raridade, idioma, estado_conservacao, album, carta, foto_carta, historico_preco |
| Coleção do Cliente | colecao, album_usuario, colecao_carta |
| Comunidade (Grupos) | grupo, membro_grupo, solicitacao_grupo, mensagem_grupo, enquete |
| Chat Pessoal | conversa, participante_conversa, mensagem, bloqueio_usuario |
| Marketplace | anuncio, foto_anuncio, proposta, pedido, pagamento, avaliacao |
| Notificações e Favoritos | favorito, alerta_preco, notificacao, notificacao_global |
| Moderação e Administração | denuncia, solicitacao_cadastro, log_auditoria, configuracao_global |

- Há **rastreabilidade documentada** entre cada entidade e os casos de uso que ela atende.
- Tipos de usuário no banco: CLIENTE, VENDEDOR, ADMINISTRADOR.

### 2.6 Metodologia e gestão

- Metodologia ágil **Scrum** com sprints de duas semanas.
  Sprint 01: 06/08 a 20/08/2026 · Sprint 02: 20/08 a 03/09/2026 · Sprints seguintes: [PENDENTE].
- Gestão no **Azure DevOps** (organização e projeto CromoCard): hierarquia Epic → Feature → User Story → Task.
- Cerimônias registradas no board: Planning, Review, Retrospectiva e Daily, com apontamento de horas por integrante.
- Código e documentação versionados no **GitHub** (repositório CROMOCARD-WORKSPACE).
- Artefatos produzidos até agora: casos de uso, user stories, diagramas C4 (níveis 1 a 3), DER em três
  formatos (PlantUML, DBML, SQL), organização do board.

### 2.7 Telas previstas (inventário do board)

28 telas mapeadas: Login, Cadastro, Home, Dashboard, Meus Álbuns, Álbum, Cadastro de Carta, Meu Perfil,
Notificações, Favoritos, Marketplace (Listagem, Detalhes, Carrinho, Checkout, Meus Anúncios), Minhas Compras,
Minhas Vendas, Grupos (Trocas, Listagem, Chat), e no BackOffice: Dashboard, Gestão de Usuários, Cartas,
Álbuns, Marketplace e Grupos, Solicitações, Configurações.
Protótipos visuais (wireframes/Figma): [PENDENTE].

---

## 3. Roteiro slide a slide (17 slides, ~15–20 minutos)

Regras gerais: título do slide como afirmação curta; no máximo 4 tópicos por slide, até 12 palavras cada;
números exatamente como na seção 2; itens [PENDENTE] permanecem visíveis como [PENDENTE].

| # | Título do slide | Conteúdo | Visual sugerido |
|---|---|---|---|
| 1 | CromoCard: coleção, comunidade e troca de cartas | Nome do projeto; instituição, curso, integrantes, orientador e data [PENDENTE] | Capa limpa, nome em destaque |
| 2 | Agenda da apresentação | Problema e objetivos · Metodologia · Escopo · Arquitetura · Dados · Status e próximos passos | Lista numerada |
| 3 | Colecionadores não têm um lugar único para coleção e trocas | Problema e justificativa [PENDENTE — hipótese da seção 1] | Ícones: planilha, chat, loja |
| 4 | Objetivo: centralizar coleção, comunidade e negociação | Objetivo geral + 5 objetivos específicos da seção 1 | Objetivo geral em destaque, específicos em lista |
| 5 | Quatro perfis de usuário usam a plataforma | Visitante, Cliente, Vendedor, Administrador (seção 2.1) | 4 cartões lado a lado |
| 6 | O mercado atual deixa lacunas | Pesquisa de mercado e concorrentes [PENDENTE] | Tabela comparativa |
| 7 | Scrum e Azure DevOps guiam o desenvolvimento | Sprints de 2 semanas; Epic→Feature→User Story→Task; cerimônias; GitHub (seção 2.6) | Linha do tempo das sprints |
| 8 | 93 casos de uso em 9 módulos | Tabela de módulos da seção 2.2 | Grade com 9 blocos e a quantidade de cada |
| 9 | MVP primeiro, marketplace e extras depois | 111 user stories: 76 MVP, 16 futuro, 19 futuro marketplace (seção 2.3) | Gráfico de barras ou rosca |
| 10 | Exemplo de caso de uso: marcar carta e ver progresso | Fluxo resumido: abrir álbum → marcar possuo/faltante/repetida → sistema atualiza progresso | Fluxo em 3–4 passos |
| 11 | Contexto: o sistema e seus parceiros externos | C4 Nível 1: atores, sistema, gateway de pagamento, transportadora | **Espaço reservado: diagrama C4 Nível 1** |
| 12 | Web (SPA único), API e tempo real sobre PostgreSQL; sem app mobile (ADR-056) | C4 Nível 2: tabela de containers e tecnologias | **Espaço reservado: diagrama C4 Nível 2** |
| 13 | API organizada em 9 módulos de negócio | C4 Nível 3: lista dos 9 componentes | **Espaço reservado: diagrama C4 Nível 3** |
| 14 | Modelo de dados: 43 tabelas em 8 módulos | PostgreSQL + Prisma; 76 FKs; 22 enums; rastreabilidade com casos de uso | **Espaço reservado: DER (visão de relacionamentos)** |
| 15 | 28 telas mapeadas para a web e o BackOffice | Inventário da seção 2.7; protótipos [PENDENTE] | Mosaico de telas (quando existir) |
| 16 | Status atual e próximos passos | Entregue: casos de uso, user stories, C4, DER, board. Próximos: protótipos, ADRs, implementação do MVP, cronograma [PENDENTE] | Checklist entregue × próximo |
| 17 | Obrigado — perguntas? | Nomes e contato da equipe [PENDENTE] | Encerramento simples |
