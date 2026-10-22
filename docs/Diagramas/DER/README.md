# DER - CromoCard (Sistema de Gestao de Cartas Colecionaveis)

Modelo de dados derivado dos **Casos de Uso / User Stories** em `../Casos-De-Uso/`
e alinhado aos diagramas C4 em `../Diagramas-C4/` (API Node.js + Prisma + PostgreSQL).

**50 entidades organizadas em 8 modulos.** Nomes de tabelas, colunas e enums em **ingles** (glossario PT → EN no fim deste arquivo). Os 3 diagramas existem nos dois formatos.

## Estrutura

```
DER/
├── puml/                              -> PlantUML  (plantuml.com / VS Code)
│   ├── 01-diagrama-entidades.puml
│   ├── 02-diagrama-relacionamentos.puml
│   └── 03-der-completo.puml
├── dbdiagram.io/                      -> DBML      (dbdiagram.io/d)
│   ├── 01-diagrama-entidades.dbml
│   ├── 02-diagrama-relacionamentos.dbml
│   └── 03-der-completo.dbml
└── chartdb/                           -> DDL SQL   (app.chartdb.io e outros)
    ├── schema-cromocard.sql
    └── schema-cromocard-sem-enums.sql
```

## Pasta `chartdb/` (DDL SQL)

O ChartDB nao le DBML - ele importa **script SQL**. Os dois arquivos foram
gerados a partir de `dbdiagram.io/03-der-completo.dbml`, entao nao divergem do
modelo: 50 tabelas, 90 chaves estrangeiras, 27 enums.

1. Abra <https://app.chartdb.io>.
2. Escolha importar a partir de **script SQL** e selecione o dialeto **PostgreSQL**.
3. Cole `schema-cromocard.sql` inteiro.
4. Se a ferramenta reclamar dos `CREATE TYPE ... AS ENUM`, use
   `schema-cromocard-sem-enums.sql`: as colunas viram `VARCHAR(30)` e os valores
   possiveis ficam anotados no comentario ao lado de cada coluna.

O mesmo SQL serve para **dbdiagram.io** (Import > From PostgreSQL), DrawSQL,
QuickDBD, pgModeler - e para criar o banco de verdade.

> As chaves estrangeiras ficam todas em `ALTER TABLE` no final do arquivo, entao
> a ordem de criacao das tabelas nao importa e nao ha erro de referencia futura.

| # | Diagrama | O que mostra |
|---|---|---|
| 01 | **Entidades** | Todas as entidades com atributos, tipos, PK/FK/UQ e obrigatoriedade. **Sem** linhas de relacionamento. |
| 02 | **Relacionamentos** | Todas as entidades com **apenas as chaves** (PK/FK) + todas as ligacoes com cardinalidade. Caixas pequenas, linhas legiveis. |
| 03 | **DER completo** | Atributos **e** relacionamentos juntos - a visao final do modelo. |

## Como gerar a imagem para o relatorio

### PlantUML (`puml/`)
1. Abra <https://www.plantuml.com/plantuml/uml/>.
2. Cole o conteudo do `.puml`.
3. Clique em **SVG**, nao PNG. Para baixar: botao direito na imagem ->
   "Salvar imagem como...".
4. No VS Code: extensao *PlantUML* -> `Alt+D` (preview) -> botao direito -> *Export*.

> **Use SVG, nao PNG.** O servidor publico do PlantUML corta o PNG em 4096px.
> O diagrama 03 tem 6055px de altura, entao o PNG sai truncado (falta o modulo
> "Usuarios" no rodape). Em SVG sai inteiro e o texto fica nitido em qualquer zoom.

### Layout: por que os diagramas 02 e 03 usam `left to right direction`

Sem essa linha o PlantUML monta uma **tira** larga e baixa, que nao cabe legivel
na pagina e estoura o limite do PNG:

| Diagrama | sem `left to right` | com `left to right` |
|---|---|---|
| 02 Relacionamentos | 4513 x 1354 (corta `denuncia`) | **1889 x 3553** |
| 03 DER completo | 7938 x 2018 (corta metade) | **3265 x 6055** |

O diagrama 01 nao precisa disso: ele nao tem linhas de relacionamento e usa uma
grade 3x3 de modulos (ligacoes invisiveis no fim do arquivo).

> Nota: nas legendas dos `.puml`, o caractere `|` da notacao pe-de-galinha e
> escrito como `&#124;`. Escrito cru, ele e interpretado como separador de
> celula da tabela e quebra a legenda.

### dbdiagram.io (`dbdiagram.io/`)
1. Abra <https://dbdiagram.io/d>.
2. Apague o exemplo e cole todo o conteudo do `.dbml`.
3. As tabelas ja vem coloridas por modulo e agrupadas em *TableGroup*.
4. Use **Export -> PDF/PNG** (ou *Print*) para o relatorio.

> Dica: no dbdiagram voce pode arrastar as caixas antes de exportar. Como cada
> modulo tem uma cor propria de cabecalho, basta juntar as caixas da mesma cor
> para o desenho ficar organizado em blocos.

## Cores por modulo (iguais nos dois formatos)

| # | Modulo | Cor | Entidades |
|---|---|---|---|
| 1 | Usuarios, Perfil e Acesso | azul `#3E5F8A` | users, profiles, addresses, password_reset_tokens, refresh_tokens, achievements, user_achievements, subscriptions |
| 2 | Catalogo Global | verde `#2E7D5B` | categories, rarities, languages, card_conditions, albums, cards, card_photos, price_history |
| 3 | Colecao do Cliente | roxo `#7B4F9D` | collections, user_albums, collection_cards |
| 4 | Comunidade (Grupos) | laranja `#C2703D` | groups, group_members, group_join_requests, group_messages, polls, poll_options, poll_votes |
| 5 | Chat Pessoal | ciano `#2A7B8C` | conversations, conversation_participants, messages, user_blocks |
| 6 | Marketplace | vinho `#A63D5F` | listings, listing_photos, offers, orders, payments, reviews |
| 7 | Notificacoes e Favoritos | dourado `#B08A2E` | favorites, price_alerts, notifications, global_notifications |
| 8 | Moderacao e Administracao | cinza `#5A5A66` | reports, catalog_requests, audit_logs, global_settings, seller_verifications, seller_documents, seller_verification_notes, user_warnings, catalog_request_votes, report_exports |

## Rastreabilidade (entidade -> casos de uso principais)

| Entidade | Casos de uso |
|---|---|
| `users`, `password_reset_tokens`, `refresh_tokens` | 03 Criar Conta, 04 Login, 06 Recuperar Senha, 52 Exclusao da Conta, 59 Gestao de Usuarios, 98 Dados Complementares do Usuario, 99 Aplicar Sancao |
| `profiles`, `addresses`, `achievements`/`user_achievements` | 48 Editar Perfil, 49 Vitrine de Conquistas, 51 Privacidade e Senha |
| `subscriptions` | Gerenciar Plano PRO (futuro) |
| `albums`, `cards`, `categories`, `rarities`, `languages`, `card_conditions`, `card_photos` | 08-10 Albuns, 13 Visualizar Cartas, 24-32 Buscas/Filtros, 30-31 Detalhes, 61 Gestao de Catalogo, 104 Ordenar Categorias Padrao, 105 Duplicar Carta, 106 Rascunho de Carta |
| `collections`, `user_albums`, `collection_cards` | 07 Resumo, 12 Compartilhar Colecao, 14-18 Marcar/Quantidade/Remover, 19 Progresso, 22 Adicionar Carta, 35 Resetar Progresso, 36 Portfolio |
| `price_history` | 75 Historico de Precos |
| `groups`, `group_members`, `group_join_requests` | 39 Explorar/Entrar em Grupos, 43 Criar e Administrar Grupo, 64 Aprovar Solicitacoes |
| `group_messages`, `polls`, `poll_options`, `poll_votes` | 42 Historico do Grupo, 44 Chat do Grupo, 41 Silenciar, 62 Gestao de Comunidade |
| `conversations`, `conversation_participants`, `messages`, `user_blocks` | 45 Responder Mensagem, 46 Visualizar Mensagens, 47 Moderar Contatos, 73 Entrar em Contato |
| `listings`, `listing_photos` | 84 Criar / 85 Editar / 86 Excluir / 87 Pausar / 88 Reativar Anuncio, 76 Anuncios Ativos |
| `offers` | 89 Visualizar Propostas |
| `orders`, `payments` | 72 Comprar, 77 Visualizar Pedidos, 92 Total de Vendas, 93 Cartas Mais Vendidas |
| `reviews` | 70 Ordenar por Avaliacoes, 81 Visualizar Avaliacoes |
| `favorites` | 55 Favoritar Album, 56 Favoritar Carta, 57 Favoritar Grupo |
| `price_alerts` | Configurar Alertas de Preco (futuro) |
| `notifications`, `global_notifications` | 53 Visualizar Notificacoes, 54 Limpar Central, 60 Disparar Notificacao Global, 100 Agendar e 101 Segmentar Notificacao Global |
| `reports` | 40 Denunciar Mensagem, 50 Denunciar Perfil, 82 Denunciar Anuncio, 83 Denunciar Vendedor, 90 Denunciar Usuario |
| `catalog_requests` | 21/23 Solicitar Cadastro de Carta, Solicitar Album, 64 Aprovar Solicitacoes |
| `audit_logs` | 65 Log de Auditoria Admin, 102 Exportar Log de Auditoria |
| `global_settings` | 66 Configuracoes Globais, 96 Evolucao de Cadastros (meta mensal) |
| `seller_verifications`, `seller_documents`, `seller_verification_notes` | 94 Validar Cadastro de Vendedor, 95 Notificar Pendencia Cadastral |
| `user_warnings` | 99 Aplicar Sancao a Usuario |
| `catalog_request_votes` | 103 Votar em Solicitacao de Catalogo |
| `report_exports` | 107 Consultar Historico de Relatorios |

## Convencoes

- Nomes de tabelas/colunas/enums em **ingles**, `snake_case`. Tabelas no **plural**
  (`users`, `orders`, `groups`) - `user`, `order` e `group` sao palavras reservadas do
  PostgreSQL, e o plural evita aspas em toda query. Enums e colunas no singular.
- Valores de enum em ingles e MAIUSCULAS (`ACTIVE`, `AWAITING_PAYMENT`).
- Datas de evento terminam em `_at` (`created_at`, `expires_at`); booleanos com prefixo
  `is_` quando o nome sozinho seria ambiguo (`is_read`, `is_primary`, `is_default`).
- `id` **UUID v7** (`DEFAULT uuidv7()`, PostgreSQL 18+) como PK em todas as entidades fortes; FKs `uuid` (ADR-014).
- **Colunas de tempo** (ADR-016): toda tabela termina com `created_at`, `updated_at` e `deleted_at`,
  todas `timestamptz` (datas sem hora continuam `date`).
- **Soft delete** (ADR-015): `deleted_at` (nulo = ativo). `DELETED` nao
  existe nos enums de status - excluido e sempre `deleted_at IS NOT NULL`.
- Entidades associativas (N:N) com PK composta: `user_achievements`, `poll_votes`, `conversation_participants`.
- Enums centralizados no topo dos arquivos `.dbml`.
- `favorites` e `reports` usam alvo polimorfico: FKs opcionais + coluna discriminadora (`type` / `target_type`).
- Constraints FK no SQL: `fk_<tabela>_<coluna>`.
- Notacao de cardinalidade: pe-de-galinha no PlantUML (`||--o{`) e `>` / `-` no DBML.
- Comentarios, notas e legendas dos diagramas continuam em portugues.

> **SVGs desatualizados:** os `.svg` destas pastas foram gerados antes da traducao para ingles
> da tabela `refresh_tokens`, dos UUIDs, do soft delete e das colunas de tempo. Reexportar: `.puml` no plantuml.com (SVG) e `.dbml` no dbdiagram.io.

## Glossario PT → EN

### Tabelas

| Antes (PT) | Agora (EN) |
|---|---|
| `usuario` | `users` |
| `perfil` | `profiles` |
| `endereco` | `addresses` |
| `token_recuperacao_senha` | `password_reset_tokens` |
| `conquista` | `achievements` |
| `usuario_conquista` | `user_achievements` |
| `assinatura` | `subscriptions` |
| `categoria` | `categories` |
| `raridade` | `rarities` |
| `idioma` | `languages` |
| `estado_conservacao` | `card_conditions` |
| `album` | `albums` |
| `carta` | `cards` |
| `foto_carta` | `card_photos` |
| `historico_preco` | `price_history` |
| `colecao` | `collections` |
| `album_usuario` | `user_albums` |
| `colecao_carta` | `collection_cards` |
| `grupo` | `groups` |
| `membro_grupo` | `group_members` |
| `solicitacao_grupo` | `group_join_requests` |
| `mensagem_grupo` | `group_messages` |
| `enquete` | `polls` |
| `opcao_enquete` | `poll_options` |
| `voto_enquete` | `poll_votes` |
| `conversa` | `conversations` |
| `participante_conversa` | `conversation_participants` |
| `mensagem` | `messages` |
| `bloqueio_usuario` | `user_blocks` |
| `anuncio` | `listings` |
| `foto_anuncio` | `listing_photos` |
| `proposta` | `offers` |
| `pedido` | `orders` |
| `pagamento` | `payments` |
| `avaliacao` | `reviews` |
| `favorito` | `favorites` |
| `alerta_preco` | `price_alerts` |
| `notificacao` | `notifications` |
| `notificacao_global` | `global_notifications` |
| `denuncia` | `reports` |
| `solicitacao_cadastro` | `catalog_requests` |
| `log_auditoria` | `audit_logs` |
| `configuracao_global` | `global_settings` |
| *(nova)* | `refresh_tokens` |

### Enums

| Antes (PT) | Agora (EN) |
|---|---|
| `tipo_usuario` | `user_role` |
| `status_usuario` | `user_status` |
| `privacidade` | `privacy` |
| `tipo_categoria` | `category_type` |
| `status_album` | `album_status` |
| `origem_preco` | `price_source` |
| `status_plano` | `subscription_status` |
| `status_carta_colecao` | `collection_card_status` |
| `tipo_acesso_grupo` | `group_access_type` |
| `status_grupo` | `group_status` |
| `papel_membro` | `member_role` |
| `status_solicitacao` | `request_status` |
| `tipo_conteudo_msg` | `message_content_type` |
| `status_anuncio` | `listing_status` |
| `status_proposta` | `offer_status` |
| `status_pedido` | `order_status` |
| `metodo_pagamento` | `payment_method` |
| `status_pagamento` | `payment_status` |
| `tipo_favorito` | `favorite_type` |
| `tipo_alvo_denuncia` | `report_target_type` |
| `status_denuncia` | `report_status` |
| `tipo_solic_cadastro` | `catalog_request_type` |

### Valores de enum

| Antes (PT) | Agora (EN) |
|---|---|
| `CLIENTE` | `CUSTOMER` |
| `VENDEDOR` | `SELLER` |
| `ADMINISTRADOR` | `ADMIN` |
| `ATIVO` | `ACTIVE` |
| `SUSPENSO` | `SUSPENDED` |
| `EXCLUIDO` | `DELETED` |
| `PUBLICO` | `PUBLIC` |
| `PRIVADO` | `PRIVATE` |
| `CARTA` | `CARD` |
| `INATIVO` | `INACTIVE` |
| `VENDA` | `SALE` |
| `ANUNCIO` | `LISTING` |
| `ATIVA` | `ACTIVE` |
| `CANCELADA` | `CANCELED` |
| `EXPIRADA` | `EXPIRED` |
| `POSSUO` | `OWNED` |
| `FALTANTE` | `MISSING` |
| `REPETIDA` | `DUPLICATE` |
| `ABERTO` | `OPEN` |
| `FECHADO` | `CLOSED` |
| `MEMBRO` | `MEMBER` |
| `PENDENTE` | `PENDING` |
| `APROVADA` | `APPROVED` |
| `RECUSADA` | `REJECTED` |
| `TEXTO` | `TEXT` |
| `IMAGEM` | `IMAGE` |
| `ENQUETE` | `POLL` |
| `PAUSADO` | `PAUSED` |
| `ENCERRADO` | `CLOSED` |
| `ACEITA` | `ACCEPTED` |
| `AGUARDANDO_PAGAMENTO` | `AWAITING_PAYMENT` |
| `PAGO` | `PAID` |
| `ENVIADO` | `SHIPPED` |
| `ENTREGUE` | `DELIVERED` |
| `CANCELADO` | `CANCELED` |
| `CARTAO_CREDITO` | `CREDIT_CARD` |
| `APROVADO` | `APPROVED` |
| `RECUSADO` | `REJECTED` |
| `ESTORNADO` | `REFUNDED` |
| `GRUPO` | `GROUP` |
| `USUARIO` | `USER` |
| `PERFIL` | `PROFILE` |
| `MENSAGEM_GRUPO` | `GROUP_MESSAGE` |
| `EM_ANALISE` | `UNDER_REVIEW` |
| `RESOLVIDA` | `RESOLVED` |
| `DESCARTADA` | `DISMISSED` |
| `CATEGORIA` | `CATEGORY` |

<details>
<summary>Colunas</summary>

| Antes (PT) | Agora (EN) |
|---|---|
| `acao` | `action` |
| `aceite_termos` | `terms_accepted` |
| `anexo_url` | `attachment_url` |
| `ano` | `year` |
| `anuncio_id` | `listing_id` |
| `ativo` | `active` |
| `atualizado_por_id` | `updated_by_id` |
| `autor_id` | `author_id` |
| `avaliado_por_id` | `reviewed_by_id` |
| `bairro` | `neighborhood` |
| `bloqueado_id` | `blocked_id` |
| `bloqueador_id` | `blocker_id` |
| `capa_url` | `cover_url` |
| `carta_id` | `card_id` |
| `categoria_id` | `category_id` |
| `categoria_pai_id` | `parent_category_id` |
| `cep` | `zip_code` |
| `chave` | `key` |
| `cidade` | `city` |
| `codigo` | `code` |
| `colecao_id` | `collection_id` |
| `comentario` | `comment` |
| `complemento` | `complement` |
| `comprador_id` | `buyer_id` |
| `conquista_id` | `achievement_id` |
| `conteudo` | `content` |
| `conversa_id` | `conversation_id` |
| `criador_id` | `creator_id` |
| `criterio` | `criteria` |
| `dados` | `data` |
| `favorito` (coluna de `album_usuario`) | `is_favorite` |
| `data_adicao` | `created_at` |
| `data_atualizacao` | `updated_at` |
| `data_avaliacao` | `reviewed_at` |
| `data_bloqueio` | `created_at` |
| `data_cadastro` | `created_at` |
| `data_criacao` | `created_at` |
| `data_disparo` | `created_at` |
| `data_entrada` | `created_at` |
| `data_envio` | `created_at` |
| `data_exclusao` | `deleted_at` |
| `data_fim` | `end_date` |
| `data_inicio` | `start_date` (em `user_albums` virou `created_at`) |
| `data_leitura` | `read_at` |
| `data_obtencao` | `created_at` |
| `data_pedido` | `created_at` |
| `data_referencia` | `reference_date` |
| `data_registro` | `created_at` |
| `data_resolucao` | `resolved_at` |
| `data_solicitacao` | `created_at` |
| `data_voto` | `created_at` |
| `denunciante_id` | `reporter_id` |
| `descricao` | `description` |
| `detalhes` | `details` |
| `editora` | `publisher` |
| `email_confirmado` | `email_verified` |
| `encerra_em` | `closes_at` |
| `endereco_entrega_id` | `shipping_address_id` |
| `enquete_id` | `poll_id` |
| `entidade_afetada` | `entity_type` |
| `entidade_id` | `entity_id` |
| `estado` | `state` |
| `estado_conservacao_id` | `condition_id` |
| `expira_em` | `expires_at` |
| `fixada` | `pinned` |
| `forma_envio` | `shipping_method` |
| `gateway_referencia` | `gateway_reference` |
| `grupo_id` | `group_id` |
| `icone_url` | `icon_url` |
| `idioma_id` | `language_id` |
| `imagem_capa_url` | `cover_image_url` |
| `imagem_frente_url` | `front_image_url` |
| `imagem_verso_url` | `back_image_url` |
| `lida` | `is_read` |
| `link_compartilhamento` | `share_link` |
| `link_referencia` | `reference_link` |
| `logradouro` | `street` |
| `mensagem` | `message` |
| `mensagem_grupo_id` | `group_message_id` |
| `mensagem_respondida_id` | `reply_to_id` |
| `metodo` | `method` |
| `metodo_pagamento` | `payment_method` |
| `moderador_id` | `moderator_id` |
| `motivo` | `reason` |
| `multipla_escolha` | `multiple_choice` |
| `nome` | `name` |
| `nota` | `rating` |
| `notificacao_global_id` | `global_notification_id` |
| `numero` | `number` |
| `opcao_enquete_id` | `poll_option_id` |
| `ordem` | `sort_order` |
| `origem` | `source` |
| `padrao` | `is_default` |
| `papel` | `role` |
| `pedido_id` | `order_id` |
| `pergunta` | `question` |
| `plano` | `plan` |
| `preco` | `price` |
| `preco_alvo` | `target_price` |
| `principal` | `is_primary` |
| `privacidade_portfolio` | `portfolio_privacy` |
| `progresso_percentual` | `progress_percentage` |
| `publica` | `is_public` |
| `quantidade` | `quantity` |
| `quantidade_disponivel` | `available_quantity` |
| `raridade_id` | `rarity_id` |
| `rotulo` | `label` |
| `senha_hash` | `password_hash` |
| `silenciado_ate` | `muted_until` |
| `solicitante_id` | `requester_id` |
| `texto` | `text` |
| `tipo` | `type` |
| `tipo_acesso` | `access_type` |
| `tipo_alvo` | `target_type` |
| `tipo_conteudo` | `content_type` |
| `tipo_usuario` | `role` |
| `titulo` | `title` |
| `total_cartas` | `total_cards` |
| `total_destinatarios` | `recipient_count` |
| `usado` | `used` |
| `usuario_alvo_id` | `target_user_id` |
| `usuario_id` | `user_id` |
| `valor` | `value` |
| `valor_frete` | `shipping_amount` |
| `valor_itens` | `items_amount` |
| `valor_mercado` | `market_value` |
| `valor_ofertado` | `offered_amount` |
| `valor_total` | `total_amount` |
| `vendedor_id` | `seller_id` |

</details>
