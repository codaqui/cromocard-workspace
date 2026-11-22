# CCD053 — Visualizar Notificações

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1294 `CCD053 - Visualizar Notificações` (criada em 22/11/2026)
- **Caso de uso:** [53-visualizar-notificacoes.md](../../docs/Casos-De-Uso/53-visualizar-notificacoes.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-053-01)
- **Atores:** Cliente · **Pré-condições:** autenticado, com acesso à central de notificações
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso ser notificado sobre novas mensagens, convites para grupos e atualizações da plataforma.

## Fidelidade ao Figma (obrigatória)

> ⚠️ **A tela implementada tem que ficar IGUAL ao Figma.** Os frames listados em **Telas (Figma)** são o contrato visual
> desta user story: não são referência, sugestão nem inspiração. Layout, ordem dos blocos, medidas, espaçamentos,
> alinhamentos, cores, tipografia (fonte, peso, tamanho e altura de linha), raios, bordas, sombras, ícones, imagens, textos
> (letra por letra) e estados (vazio, erro, carregando, hover, foco, desabilitado) seguem o frame. Medidas e cores saem do
> Figma, nunca "a olho".
>
> - Nada é inventado, trocado ou "melhorado" fora do frame. Diferença entre o Figma e a documentação vira lacuna em
>   **Lacunas e decisões** e é decidida antes do código (ADR-060). Até a decisão, vale a documentação.
> - O que o Figma não desenha (R marcado em "O que falta no Figma") segue o estilo da própria tela: os mesmos componentes,
>   tokens e espaçamentos.
> - A tela só está pronta quando o print dela em 1280 px, lado a lado com o print do frame, não mostra diferença. Em
>   celular (375 px), tablet (768 px) e laptop (1024 px), mantém o mesmo design adaptado, sem quebra, corte nem rolagem
>   horizontal.
> - A revisão (`/cromocard-revisor`) reprova o PR que não estiver igual ao Figma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só usuário autenticado vê a central: `401` sem token. Cada um vê e altera só as próprias notificações; a de outro usuário responde `404` | Permissão | `53`, Pré-condições (L1); ADR-005; ADR-011 |
| R2 | Central de notificações com as notificações do usuário (`notifications.user_id`), sem as excluídas (`deleted_at` nulo) | Tela | `53`, FP 1–2; DBML `notifications` |
| R3 | As notificações aparecem em ordem cronológica | Regra | `53`, FP 3 |
| R4 | Cada notificação mostra o título, a mensagem, o tipo e quando chegou (`title`, `message`, `type`, `created_at`), e a não lida se distingue da lida (`is_read`) | Campo | `53`, FP 3; DBML `notifications` |
| R5 | Selecionar uma notificação com destino (`reference_link`) leva o usuário ao conteúdo relacionado | Ação | `53`, FP 4–5; DBML `notifications.reference_link` |
| R6 | Selecionar uma notificação marca a notificação como lida (`is_read = true`) e o contador de não lidas diminui | Regra | `53`, FP 6 |
| R7 | Sem nenhuma notificação, a central mostra "Nenhuma notificação encontrada" | Mensagem | `53`, FA 1 (L2) |
| R8 | Se o conteúdo relacionado não existe mais, o sistema informa que o conteúdo não pode ser acessado | Mensagem | `53`, FA 2 (L3) |
| R9 | Notificação nova chega em tempo real, em qualquer tela, sem recarregar: o servidor emite `notification:new` na room `user:<id>` depois de gravar a notificação | Estado | ADR-012 (Contexto e Convenções: rooms e eventos); user story (narrativa) |
| R10 | As notificações do disparo global (CCD060, `type = GLOBAL`, `global_notification_id`) aparecem na central como as demais | Regra | DBML `notifications.global_notification_id`; ADR-051, item 2 |
| R11 | O cliente escolhe, por tipo de aviso, se recebe no site e por e-mail. Tipos: pedidos e pagamentos, mensagens, grupos, solicitações ao catálogo e avisos da plataforma. Sem WhatsApp nem push | Campo | EA-053-01; ADR-058 (L10) |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** um cliente com 4 notificações, 3 não lidas, **quando** ele abre a "Central de Notificações", **então** vê as 4 em ordem cronológica, cada uma com título, mensagem, tipo e tempo, e as 3 não lidas destacadas.
- **CA2** (R5, R6) — **Dado** uma notificação não lida com `reference_link = /pedidos/<id>`, **quando** o cliente a seleciona, **então** a tela do pedido abre, a notificação fica com `is_read = true` e o contador de não lidas diminui 1.
- **CA3** (R6) — **Dado** uma notificação não lida sem `reference_link`, **quando** o cliente a seleciona, **então** ela é marcada como lida e o cliente continua na central.
- **CA4** (R7) — **Dado** um cliente sem nenhuma notificação, **quando** abre a central, **então** vê "Nenhuma notificação encontrada".
- **CA5** (R8) — **Dado** uma notificação cujo destino foi excluído (ex.: álbum removido do catálogo), **quando** o cliente a seleciona, **então** vê o aviso de que o conteúdo não pode ser acessado e a notificação fica lida.
- **CA6** (R9) — **Dado** o cliente logado em qualquer tela, **quando** uma notificação é gravada para ele, **então** o aviso aparece e o contador de não lidas aumenta 1, sem recarregar a página; um usuário diferente não recebe o evento.
- **CA7** (R10) — **Dado** um disparo global enviado pela CCD060, **quando** o cliente abre a central, **então** a notificação do disparo aparece com o título e a mensagem do disparo.
- **CA8** (R11) — **Dado** a tela Configurações, **quando** o cliente desliga o e-mail de um tipo de aviso e salva, **então** a preferência fica gravada e continua desligada ao reabrir a tela.
- **CA9** (R1) — **Dado** uma chamada sem token, **quando** pede a lista de notificações, **então** recebe `401`; **dado** o cliente A, **quando** tenta marcar como lida uma notificação do cliente B, **então** recebe `404` e a notificação de B não muda.
- **CA10** (R2) — **Dado** a central abrindo, **quando** a busca ainda não respondeu, **então** a tela mostra o estado de carregamento; **quando** a busca falha, **então** mostra um aviso de erro no estilo da tela, e não a mensagem de central vazia.
- **CA11** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `490-796`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-12111`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-13070`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1124-22490`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA15** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dos blocos "Canais de aviso" e "Categorias e Eventos" é comparado lado a lado com o print do frame `1160-41305`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `notifications` | `id`, `user_id`, `global_notification_id`, `title`, `message`, `type`, `reference_link`, `is_read`, `created_at`, `deleted_at` | `title` (120) e `message` (500) obrigatórios; `type` varchar(40) obrigatório, lista fechada no código (ADR-051, item 2: hoje `GLOBAL`, `CATALOG_REQUEST`, `SELLER_PENDING`, `SELLER_REVIEW`); `is_read` default `false` |
| `global_notifications` | `id` | só a ligação da notificação ao disparo (CCD060) |
| — | preferências por tipo de aviso (R11) | o DBML não tem onde gravar (L10) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel principal de notificações | [490-796](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=490-796) | R2–R6 | ⚠️ Bate na lista; filtros, ações dentro da notificação e agrupamento só no Figma (L5, L7, L9) |
| Notificações — ações da notificação | [675-12111](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-12111) | R6 | ⚠️ Menu ⋮ só no Figma (L8); seleção e exclusão são da CCD054 |
| Notificações — notificação em tempo real | [675-13070](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-13070) | R9 | ⚠️ Avisos flutuantes batem com o ADR-012; botões dentro do aviso só no Figma (L7) |
| Cliente — Início com notificações abertas | [1124-22490](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1124-22490) | R2–R6, R9 | ⚠️ Sino com contador e popup só no Figma (L6) |
| Configurações (blocos "Canais de aviso" e "Categorias e Eventos") | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | R11 | ⚠️ Tipos e canais diferem do EA-053-01 (L10) |

- Textos da central (`490-796`): "NOTIFICAÇÕES E FAVORITOS", "Notificações & Favoritos", "Acompanhe alertas em tempo real e acesse rapidamente seus álbuns, cartas raras e comunidades salvas.", "Marcar todas como lidas", "Configurar Alertas", "5 Não Lidas", "28 Itens Salvos", abas "Central de Notificações" e "Meus Favoritos", "Mais recentes primeiro" (bate com a ordem cronológica do R3), grupos "HOJE" e "ANTERIORES • Últimos 3 dias".
- Popup do sino (`1124-22490`): "Notificações", "3 novas", "Marcar todas como lidas", abas "Todas (4)", "Não lidas (3)", "Pedidos (1)", "Grupos (1)", "Ver todas as notificações", "Configurar alertas".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): `675-11716` — central sem não lidas mostra "Tudo em dia!" e "Você não tem notificações não lidas. Avisaremos quando chegar algo novo."; o caso de uso pede "Nenhuma notificação encontrada" para a central sem notificações (L2). `1160-41305` — o Figma tem 6 eventos em 3 grupos ("Pedidos e marketplace", "Comunidades", "Plataforma e coleção") e as chaves gerais "E-mail" e "In-App (Central & Sino)"; o EA-053-01 lista 5 tipos (L10). Tipos das notificações do Figma (Pedido, Convite de grupo, Aviso da plataforma, Nova mensagem) não estão na lista do ADR-051 (L4).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): filtros com contagem na central e no popup (L5); sino com contador e popup em todas as telas (L6); botões dentro da notificação e do aviso flutuante (L7); botão ✓ e menu ⋮ com "Marcar como lida", "Fixar no topo" e "Configurar este tipo de alerta" (L8); grupos "HOJE" e "ANTERIORES • Últimos 3 dias" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 central sem nenhuma notificação; R8 aviso de conteúdo indisponível; estados de carregamento e erro (CA10).

## Fora do escopo

- "Marcar todas como lidas", excluir e a seleção de várias notificações — CCD054.
- A aba "Meus Favoritos" e o contador "Itens Salvos" — CCD055, CCD056 e CCD057.
- Criar a notificação de cada evento — a story que gera o evento (CCD060, CCD064, CCD072, CCD073, CCD109, CCD110…), que acrescenta o tipo dela (ADR-051, item 2).
- Silenciar notificações de um grupo — CCD041.
- Alerta de preço ("Avisar abaixo de…") — fase Futuro.
- Push e WhatsApp — não existem (ADR-058).
- O restante das telas Início (CCD007) e Configurações (CCD051 e CCD052).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O ator é só "Cliente". `SELLER` também tem a central? E o `ADMIN`, que usa o BackOffice? (proposta: `CUSTOMER` e `SELLER`; o `ADMIN` não tem central no site) | pendente | — |
| L2 | Mensagem da central vazia: o caso de uso pede "Nenhuma notificação encontrada"; o Figma (`675-11716`) mostra "Tudo em dia!" para nenhuma **não lida** e não desenha a central sem nenhuma notificação. Qual vale, e para qual situação? | pendente | — |
| L3 | Texto do aviso de conteúdo indisponível (FA 2): a documentação não define e o Figma não desenha | pendente | — |
| L4 | Quais tipos de notificação existem e com que rótulo? O ADR-051 tem `GLOBAL`, `CATALOG_REQUEST`, `SELLER_PENDING` e `SELLER_REVIEW`; o Figma mostra "PEDIDO", "CONVITE DE GRUPO", "AVISO DA PLATAFORMA", "NOVA MENSAGEM" e "Sua solicitação foi aprovada". (proposta: cada story que cria a notificação acrescenta o tipo; a CCD053 mapeia tipo → rótulo) | pendente | — |
| L5 | Filtros com contagem (só no Figma): "Todas", "Novas Mensagens", "Convites de Grupos", "Avisos da Plataforma" na central e "Todas", "Não lidas", "Pedidos", "Grupos" no popup. Faz sentido implementar? Se sim, qual tipo cai em cada filtro (a central não tem "Pedidos")? | pendente | — |
| L6 | Sino no topo com o contador de não lidas e o popup com as últimas notificações (só no Figma, `1124-22490`). Faz sentido implementar? | pendente | — |
| L7 | Botões dentro da notificação (só no Figma): "Ver pedido", "Acompanhar rastreio", "Aceitar Convite"/"Recusar", "Ver no Catálogo", "Criar Novo Álbum Desta Coleção", "Ver álbum", e no aviso flutuante "Ver anúncio", "Responder", "Marcar como lida", "Aceitar"/"Recusar". O DBML guarda um só `reference_link`, e não há tabela de convite para grupo (`group_join_requests` é pedido de entrada). Faz sentido implementar? | pendente | — |
| L8 | Botão ✓ e menu ⋮ por notificação (só no Figma, `675-12111`): "Marcar como lida", "Fixar no topo" (o DBML não tem coluna para fixar) e "Configurar este tipo de alerta". Faz sentido implementar? | pendente | — |
| L9 | Agrupamento "HOJE" e "ANTERIORES • Últimos 3 dias": a central mostra só os últimos 3 dias ou todas, agrupadas? E a paginação (ADR-011, 20 por página), que o Figma não desenha? | pendente | — |
| L10 | Preferências por tipo de aviso (EA-053-01): o DBML não tem onde gravar; o Figma (`1160-41305`) tem 6 eventos em 3 grupos, chaves gerais por canal, "Restaurar Padrões" e "Salvar Preferências", e o EA lista 5 tipos. Onde gravar (coluna ou tabela nova, com ADR), quais tipos valem e quem respeita a preferência ao enviar (cada story que notifica)? | pendente | — |
