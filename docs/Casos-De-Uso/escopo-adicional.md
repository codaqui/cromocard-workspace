# Escopo adicional — o que o protótipo tem e a documentação não tinha

Itens que aparecem no protótipo do Figma (arquivo `43K7rTPJQNIOroQ4j09YTP`) e não estavam nos casos de uso nem nas
user stories. Foram levantados na conferência das telas de **Administração** e de **Login/Cadastro** em 22/10/2026,
partindo do que o PR #4 (cancelado) tinha documentado, conferido tela por tela no modo protótipo.

- **Marcador:** `++` no fim da narrativa da user story (legenda em [user-stories.md](user-stories.md)).
  **Tag no Azure:** `escopo-adicional`.
- **Fase:** o PO puxou o escopo adicional para a **Sprint 06** e aprovou as specs CCD094–CCD107 em 22/10/2026. Cada item segue o SDD como os outros
  (spec, plano, tarefas). A documentação continua sendo a fonte da verdade: onde o Figma contradiz um caso de uso,
  vale o caso de uso (as divergências estão nas specs, na seção "Telas").
- **Dados:** o DER já tem o que estes itens precisam (ADR-052 e ADR-053). Cada coluna entra com a user
  story que a usa, numa migration própria.

## 1. Casos de uso novos

| Código | Caso de uso | Ator | Telas (frame) | Depende de | Dados (DER) |
|---|---|---|---|---|---|
| CCD094 | [Validar Cadastro de Vendedor](94-validar-cadastro-de-vendedor.md) | Administrador | Dashboard `208-1240` (lista), Validar Cadastro `246-1201`, dossiê `252-1723` e `252-2837` | CCD003 (cadastro como Vendedor); o envio dos dados pelo vendedor **não existe** na documentação nem no Figma (dados de teste pelo seed) | `seller_verifications`, `seller_documents`, `seller_verification_notes` (ADR-052) |
| CCD095 | [Notificar Pendência Cadastral](95-notificar-pendencia-cadastral.md) | Administrador | Notificar lojista `246-2038`, confirmação `252-1375` | CCD094; provider de e-mail (ADR-009) | `seller_verifications.regularization_deadline`; modelos em `global_settings` |
| CCD096 | [Acompanhar Evolução de Cadastros](96-acompanhar-evolucao-de-cadastros.md) | Administrador | `208-1240`, Hoje `247-3539`, 7 dias `247-2499` | CCD058; a linha de lojistas certificados usa a CCD094 | meta mensal em `global_settings` |
| CCD097 | [Visualizar Indicadores Financeiros](97-visualizar-indicadores-financeiros.md) | Administrador | `208-1240`, `247-3539`, `247-2499`, painel `246-1201` | `orders` e `payments` do marketplace (`***`, ADR-027) | — (lê `orders` e `payments`) |
| CCD098 | [Gerenciar Dados Complementares do Usuário](98-gerenciar-dados-complementares-do-usuario.md) | Administrador | Gestão de usuários `208-1793`, novo usuário `276-1202`, remover `276-1735` | CCD059, CCD004 | `users.username`, `phone`, `cpf`, `last_login_at`, `last_login_ip` (ADR-053) |
| CCD099 | [Aplicar Sanção a Usuário](99-aplicar-sancao-a-usuario.md) | Administrador | `208-1793`, comunidade `220-3524`, logs `228-2395` | CCD059, CCD062 | `users.suspended_until`, `user_status.BLOCKED`, `group_status.WARNED`, `user_warnings` (ADR-053) |
| CCD100 | [Agendar Notificação Global](100-agendar-notificacao-global.md) | Administrador | Notificação `208-2380`, agendamento `277-2689`, confirmação `277-2982` | CCD060; job agendado (ADR-010) | `global_notifications.status`, `scheduled_at`, `sent_at`, `reference_link` (ADR-053) |
| CCD101 | [Segmentar Notificação Global](101-segmentar-notificacao-global.md) | Administrador | `208-2380` (histórico: público e canal), `277-2982` (público-alvo) | CCD060, CCD100 | `global_notifications.audience`, `channels` (ADR-053) |
| CCD102 | [Exportar Log de Auditoria](102-exportar-log-de-auditoria.md) | Administrador | Logs `228-2395` ("Extrair Logs") | CCD065 | `audit_logs.ip_address` (ADR-053) |
| CCD103 | [Votar em Solicitação de Catálogo](103-votar-em-solicitacao-de-catalogo.md) | Cliente, Administrador | Fila de solicitações `228-1804` (só o lado do admin); o Figma **não tem** a tela de votação do cliente | CCD064 | `catalog_request_votes`; meta em `global_settings` (ADR-053) |
| CCD104 | [Ordenar Categorias Padrão](104-ordenar-categorias-padrao.md) | Administrador | Configurações `228-3048` (Módulo 2) | CCD066, CCD061 | `categories.slug`, `display_order`, `is_pinned`, `badge` (ADR-053) |
| CCD105 | [Duplicar Carta](105-duplicar-carta.md) | Administrador | Catálogo `208-2895` | CCD061 | `cards.code`, `variants` (ADR-053) |
| CCD106 | [Salvar Rascunho de Carta](106-salvar-rascunho-de-carta.md) | Administrador | Cadastrar carta `278-3246` | CCD061 | `cards.status`, `release_year` (ADR-053) |
| CCD107 | [Consultar Histórico de Relatórios](107-consultar-historico-de-relatorios.md) | Administrador | Relatórios `228-1236` | CCD063; storage (ADR-009) e job de limpeza (ADR-010) | `report_exports` (ADR-053) |

A recusa de solicitação (botão "Recusar" do frame `228-1804`) entrou no MVP pela CCD064 (lacuna L1 aprovada) e não é
escopo adicional.

## 2. Complementos de casos de uso existentes

Detalhes do protótipo pequenos demais para um caso de uso próprio. Cada um entra como requisito na spec indicada na
coluna "Entra em", citando o código `EA-…` como origem. Os marcados **MVP** já foram cobertos pelas decisões das specs
aprovadas.

| Código | Item do protótipo | Tela | Entra em | Observação |
|---|---|---|---|---|
| EA-004-01 | Entrar com "e-mail ou ID colecionador" | `152-2587` | CCD098 | O "ID colecionador" é o nome de usuário (@) da CCD098. |
| EA-058-01 | Intervalo de datas personalizado | `208-1240` | **MVP** (CCD058, L4) | |
| EA-058-02 | Variação de cada indicador em relação ao período anterior | `208-1240` | CCD096 | |
| EA-058-03 | Total de usuários separado em colecionadores e lojistas | `208-1240` | CCD096 | |
| EA-058-04 | Novas cartas cadastradas na semana | `208-1240` | CCD096 | |
| EA-058-05 | Colunas extras na lista de vendedores (CNPJ/CPF, reputação, volume, status da análise), filtro de status e "Atualizar Fila" | `208-1240` | CCD094 | Reputação e volume vêm da CCD097. |
| EA-058-06 | Card "Lojistas & Credenciamento" (homologados, pendentes, "Analisar Fila") | `208-1240`, `247-2499` | CCD094 | |
| EA-058-07 | Taxa de autenticação e conversão KYC | `208-1240` | CCD094 | Conversão = cadastros aprovados ÷ cadastros analisados. A taxa de autenticação não entra: não tem origem de dado. |
| EA-059-01 | Confirmação reforçada ao excluir (digitar o texto e marcar "Estou ciente") | `276-1735` | CCD098 | O texto "irreversível" contraria o soft delete (ADR-015). Texto de confirmação: `EXCLUIR-` + o primeiro nome em maiúsculas. O texto "irreversível" muda: a conta pode ser restaurada (ADR-015). |
| EA-059-02 | Total de usuários no cabeçalho | `208-1793` | CCD098 | |
| EA-059-03 | "Clique na linha para inspecionar": detalhe do usuário | `208-1793` | CCD098 | Não há frame do detalhe. Gaveta lateral com os dados e as ações; o Gabriel desenha. |
| EA-059-04 | Status "Em análise" (vendedor aguardando credenciamento) | `208-1793` | CCD094 | |
| EA-060-01 | Link de destino da notificação | `208-2380` | **MVP** (CCD060, L4) | |
| EA-060-02 | Pré-visualização da notificação num celular | `208-2380` | **MVP** (plano da CCD060) | |
| EA-060-03 | Contadores de caracteres (título 80, corpo 240) | `208-2380` | **MVP** (CCD060) | Vale o DER: 120 e 500. |
| EA-060-04 | Botão com o número de destinatários e aviso de envio | `208-2380` | **MVP** (plano da CCD060) | |
| EA-060-05 | Histórico com público, canal e status | `208-2380` | CCD101 (público e canal), CCD100 (status) | O histórico em si é MVP (CCD060, L5). |
| EA-061-01 | Indicadores: total de álbuns, álbuns licenciados e pendentes de revisão | `208-2895` | CCD105 | Licenciado = álbum `ACTIVE`; pendente de revisão = solicitação de álbum `PENDING`. |
| EA-061-02 | Código da carta e etiquetas de variante | `208-2895` | CCD105 | Código digitado, opcional e único; não é copiado ao duplicar. |
| EA-061-03 | Filtro por edição/ano e chips de filtros ativos | `208-2895` | CCD105 | |
| EA-061-04 | Seleção de várias cartas | `208-2895` | CCD105 | O Figma não desenha ação em lote (lacuna na spec). Ação em lote: excluir as selecionadas, com motivo. |
| EA-061-05 | População base e preço médio por carta | `208-2895` | CCD097 | Depende de `price_history` e das vendas. População = soma das quantidades em coleções `OWNED` e `DUPLICATE`; preço médio = média de `price_history` nos últimos 30 dias. |
| EA-061-06 | Ano de lançamento da carta | `278-3246` | CCD106 | |
| EA-061-07 | Verso padrão da franquia aplicado automaticamente | `278-3246` | CCD106 | Verso padrão por categoria na chave `catalog.default_backs` de `global_settings`. |
| EA-061-08 | Checagem de duplicidade antes de cadastrar | `278-3246` | CCD106 | Duplicata = mesmo nome e numeração no mesmo álbum, ou mesmo nome sem álbum; só aviso, sem bloquear. |
| EA-061-09 | Imagem com mínimo de 1200×1600 px | `278-3246` | CCD106 | |
| EA-062-01 | Indicadores da comunidade | `220-3524` | **MVP** (CCD062, L5) | |
| EA-062-02 | Status "Advertido por Regras" para grupo | `220-3524` | CCD099 | Só o selo "Advertido"; reativar volta a `ACTIVE`. |
| EA-062-03 | Volume custodiado e negociações ativas por grupo | `220-3524` | CCD097 | Volume = soma dos anúncios ativos compartilhados no grupo (mensagens `LISTING`). |
| EA-062-04 | Categoria da denúncia e filtro da fila por gravidade | `220-3524` | CCD099 | Críticas: "Spam/Golpe" e "Discurso de ódio/Ameaça"; filtros "Críticos" e "Spam". |
| EA-062-05 | Denúncia criada por detecção automática de conteúdo | `220-3524` | CCD099 | Exige detecção automática; lacuna na spec. Não entra: não há caso de uso de detecção automática (decisão do PO em 22/10/2026). |
| EA-062-06 | Idade da conta do autor, advertências anteriores e quantos denunciaram | `220-3524` | CCD099 | |
| EA-063-01 | Pré-visualização antes de exportar | `228-1236` | **MVP** (CCD063, R7) | |
| EA-063-02 | Relatório "Auditoria de Lojistas" | `228-1236` | CCD094 | |
| EA-063-03 | Relatório "Volume Transacionado & Custódia" | `228-1236` | CCD097 | |
| EA-064-01 | Abas por tipo com contagem | `228-1804` | **MVP** (CCD064, CA1) | |
| EA-064-02 | Campos da sugestão de carta (frente e verso, ilustrador, população, fontes) | `228-1804` | CCD103 | Ficam em `catalog_requests.data`. Lidos de `catalog_requests.data` quando existirem. |
| EA-064-03 | Checklist das cartas do álbum sugerido, com "Baixar Planilha .CSV" | `228-1804` | CCD103 | |
| EA-064-04 | Subcategorias a criar junto com a categoria sugerida | `228-1804` | CCD103 | |
| EA-065-01 | Justificativa obrigatória em toda ação administrativa | `228-2395` | CCD102 | O MVP já exige motivo em suspender, excluir e moderar. Obrigatória nas ações que mudam status ou excluem; opcional nas demais. |
| EA-065-02 | Total de ações em 30 dias, com variação e média diária | `228-2395` | CCD102 | |
| EA-065-03 | Filtros rápidos | `228-2395` | CCD102 | Banimentos, Remoção de grupos e Mudança de papel. |
| EA-065-04 | Busca por IP | `228-2395` | CCD102 | |
| EA-065-05 | Cargo do responsável | `228-2395` | CCD102 | O DER só tem o papel ADMIN; lacuna na spec. Não entra: o DER só tem o papel ADMIN (decisão do PO em 22/10/2026). |
| EA-066-01 | Quantidade de cartas e selo de cada categoria padrão | `228-3048` | CCD104 | O admin define o selo no formulário de categoria. |

## 3. O que não vira requisito

Textos e selos de efeito visual, sem regra por trás: "SHA-256", "assinado criptograficamente", "Assinatura HSM",
"Ledger imutável", "Bloco atual", "Smart Contract", "Cluster Alpha 100% operacional", "SLA & Gateway", "Latência
média", "Tempo real", "Live Sync", "rede neural anti-fraude", "API GraphQL e Banco Central", "Superusuário Vault",
"pré-validado via OCR", "protocolo de auditoria" e os prazos "Padrão Bacen". Se algum deles precisar virar
funcionalidade, vira caso de uso novo.

## 4. Telas conferidas

Administração: `208-1240`, `247-2499`, `247-3539`, `246-1201`, `246-2038`, `252-1375`, `252-1723`, `252-2837`,
`208-1793`, `276-1202`, `276-1735`, `208-2380`, `277-2689`, `277-2982`, `208-2895`, `278-3246`, `220-3524`,
`228-1236`, `228-1804`, `228-2395`, `228-3048`. Login: `152-2587`, `238-1204`. Painel do vendedor `281-3729` e
perfil `229-3585` só para procurar o envio dos documentos do vendedor (não existe).

- O frame `208-2895` (Catálogo) está cortado à direita no próprio Figma.
- Os frames `252-1723`, `252-2837` e `278-3246` aparecem como "Html → Body" no Figma: são o dossiê do vendedor (dois
  estados) e o cadastro de carta.
