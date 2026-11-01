# DER - CromoCard (Sistema de Gestao de Cartas Colecionaveis)

Modelo de dados derivado dos **Casos de Uso / User Stories** em `../../Casos-De-Uso/`
e alinhado aos diagramas C4 em `../Diagramas-C4/` (API Node.js + Prisma + PostgreSQL).

**50 entidades organizadas em 8 modulos, 90 chaves estrangeiras e 27 enums.** Nomes de tabelas, colunas e
enums em **ingles** (glossario PT → EN no fim deste arquivo). O DER e escrito em DBML para o
[dbdiagram.io](https://dbdiagram.io/d); cada diagrama tem o `.dbml` e o print tirado do site.

## Estrutura

```
DER/
├── 01-diagrama-entidades.dbml          entidades e atributos, sem ligacoes
├── 01-diagrama-entidades-dbdiagram.png
├── 02-diagrama-relacionamentos.dbml    so as chaves (PK/FK) e as ligacoes
├── 02-diagrama-relacionamentos.png
├── 03-der-completo.dbml                atributos e ligacoes - FONTE DA VERDADE do modelo
├── 03-der-completo.png
└── README.md
```

O `03-der-completo.dbml` e a fonte da verdade; o 01 e o 02 sao recortes dele e mudam junto.

## Como gerar o print

1. Abra <https://dbdiagram.io/d>, apague o exemplo e cole todo o conteudo do `.dbml`.
2. Confira que o canto inferior esquerdo mostra **0 errors**.
3. Recolha o painel de codigo, use o botao de enquadrar o diagrama e tire o print. Exportar
   (PDF/PNG/SVG) pelo botao Export exige login.

## Cores por modulo (`headercolor` no DBML)

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
| `groups`, `group_members`, `group_join_requests` | 39 Explorar/Entrar em Grupos, 43 Criar e Administrar Grupo, 57 Favoritar Grupo, 62 Gestao de Comunidade |
| `group_messages`, `polls`, `poll_options`, `poll_votes` | 42 Historico do Grupo, 44 Chat do Grupo, 41 Silenciar, 62 Gestao de Comunidade |
| `conversations`, `conversation_participants`, `messages`, `user_blocks` | 45 Responder Mensagem, 46 Visualizar Mensagens, 47 Moderar Contatos, 73 Entrar em Contato |
| `listings`, `listing_photos` | 84 Criar / 85 Editar / 86 Excluir / 87 Pausar / 88 Reativar Anuncio, 76 Anuncios Ativos |
| `offers` | 89 Visualizar Propostas |
| `orders`, `payments` | 72 Comprar, 77 Visualizar Pedidos, 92 Total de Vendas, 93 Cartas Mais Vendidas |
| `reviews` | 70 Ordenar por Avaliacoes, 81 Visualizar Avaliacoes |
| `favorites` | 55 Favoritar Album, 56 Favoritar Carta, 57 Favoritar Grupo |
| `price_alerts` | Configurar Alertas de Preco (futuro) |
| `notifications`, `global_notifications` | 53 Visualizar Notificacoes, 54 Limpar Central, 60 Disparar Notificacao Global, 100 Agendar e 101 Segmentar Notificacao Global |
| `reports` | 40 Denunciar Mensagem, 47 Moderar Contatos, 50 Denunciar Perfil, 62 Gestao de Comunidade, 82 Denunciar Anuncio, 83 Denunciar Vendedor, 90 Denunciar Usuario, 99 Aplicar Sancao |
| `catalog_requests` | 10 Solicitar Album, 21/23 Solicitar Cadastro da Carta, 64 Aprovar Solicitacoes, 103 Votar em Solicitacao de Catalogo |
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
- Notacao de cardinalidade no DBML: `>` (muitos para um) e `-` (um para um).
- Comentarios, notas e legendas dos diagramas continuam em portugues.

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
