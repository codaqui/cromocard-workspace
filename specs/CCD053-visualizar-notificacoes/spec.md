# CCD053 — Visualizar Notificações

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #1294 `CCD053 - Visualizar Notificações` (criada em 22/11/2026)
- **Caso de uso:** [53-visualizar-notificacoes.md](../../docs/Casos-De-Uso/53-visualizar-notificacoes.md) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-053-01)
- **Atores:** Cliente e Vendedor · **Pré-condições:** autenticado como cliente ou vendedor, com acesso à central de notificações
- **Data:** 2026-11-21, revista em 2026-11-28 com as decisões L1–L16 · **Autor:** Daniel Andrade
- **Aprovação:** Daniel Andrade, 28/11/2026 (falta a validação do PO, Felipe)

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
| R1 | Só `CUSTOMER` e `SELLER` autenticados têm a central: `401` sem token e `403` para o `ADMIN`. Cada um vê e altera só as próprias notificações; a de outro usuário responde `404` | Permissão | `53`, Atores e Pré-condições (L1); ADR-005; ADR-011 |
| R2 | Central de notificações com as notificações do usuário (`notifications.user_id`), sem as excluídas (`deleted_at` nulo) | Tela | `53`, FP 1–2 (L13); DBML `notifications` |
| R3 | As notificações aparecem da mais recente para a mais antiga, agrupadas em "HOJE" e "ANTERIORES", sem corte por data | Regra | `53`, FP 3 (L9) |
| R4 | Cada notificação mostra o rótulo do tipo, quando chegou, o título e a mensagem (`type`, `created_at`, `title`, `message`), e a não lida se distingue da lida (`is_read`) | Campo | `53`, FP 3; DBML `notifications` |
| R5 | Notificação com destino (`reference_link`) tem um botão de ação com o rótulo do tipo ("Ver pedido", "Ver álbum", "Responder"…); selecionar a notificação ou o botão leva o usuário ao conteúdo relacionado | Ação | `53`, FP 3–5 (L7); DBML `notifications.reference_link` |
| R6 | Abrir uma notificação marca a notificação como lida (`is_read = true`) e o contador de não lidas diminui | Regra | `53`, FP 6 |
| R7 | Sem nenhuma notificação, a central mostra "Nenhuma notificação encontrada", no estilo do cartão "Tudo em dia!" | Mensagem | `53`, FA 1 (L2) |
| R8 | Se o conteúdo relacionado não existe mais, a página de destino mostra "Este conteúdo não está mais disponível." quando o usuário chegou por uma notificação, e a notificação fica lida | Mensagem | `53`, FA 2 (L3) |
| R9 | Notificação nova chega em tempo real, em qualquer tela, sem recarregar: o servidor emite `notification:new` na room `user:<id>` depois de gravar a notificação, e o site mostra o aviso flutuante com o botão de ação e "Marcar como lida" | Estado | `53`, FA 8; ADR-012 (rooms, eventos e persistência primeiro); user story |
| R10 | As notificações do disparo global (CCD060, `type = GLOBAL`, `global_notification_id`) aparecem na central como as demais | Regra | DBML `notifications.global_notification_id`; ADR-051, item 2 |
| R11 | Em Configurações, o usuário escolhe se recebe no site e por e-mail: duas chaves gerais ("In-App (Central & Sino)" e "E-mail") e seis eventos em três grupos, com "Restaurar Padrões" e "Salvar Preferências". Sem escolha gravada, tudo ligado. Sem WhatsApp nem push | Campo | EA-053-01 (L10, L15); ADR-074; ADR-058 |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R13 | Mensagem nova no chat pessoal gera uma notificação `NEW_MESSAGE` para o destinatário (título "@<remetente>", trecho da mensagem, link `/mensagens?conversa=<id>`), só se ele não tiver uma `NEW_MESSAGE` não lida daquela conversa | Regra | CCD073, L9 (L11) |
| R14 | A lista vem 50 por vez, por cursor (`?cursor=<id>&limit=50`, `meta.nextCursor`), com "Carregar mais" no fim | Regra | ADR-011, Paginação (L9) |
| R15 | Filtros com contagem: na central, "Todas", "Novas Mensagens", "Convites de Grupos" e "Avisos da Plataforma"; no popup do sino, "Todas", "Não lidas", "Pedidos" e "Grupos". Cada tipo pertence a uma categoria; o filtro mostra só as notificações dela | Ação | `53`, FA 4–5 e 10 (L5) |
| R16 | O sino do topo mostra o número de não lidas em todas as telas do cliente e do vendedor e abre um popup com as últimas notificações, "Marcar todas como lidas", "Ver todas as notificações" e "Configurar alertas" | Tela | `53`, FA 9–10 (L6) |
| R17 | Cada notificação tem o botão "✓" e o menu "⋮" com "Marcar como lida" e "Configurar este tipo de alerta" (leva às preferências em Configurações); marcar como lida não sai da central | Ação | `53`, FA 6–7 (L8) |
| R18 | O disparo global emite `notification:new` para cada destinatário depois de gravar cada lote | Estado | ADR-012; R9 (L12) |
| R19 | Sem notificações não lidas, a central mostra "Tudo em dia!", "Você não tem notificações não lidas. Avisaremos quando chegar algo novo." e "Configurar alertas", e as lidas continuam abaixo, em "ANTERIORES" | Mensagem | `53`, FA 3 (L2); Figma `675-11716` |
| R20 | Os tipos de notificação ficam num enum do domínio `notifications`, com o rótulo e a categoria de cada um: `GLOBAL` "Aviso da plataforma", `CATALOG_REQUEST` "Solicitação ao catálogo", `SELLER_PENDING` e `SELLER_REVIEW` "Cadastro de vendedor" (Avisos da Plataforma) e `NEW_MESSAGE` "Nova mensagem" (Novas Mensagens); pedido e convite de grupo entram com as stories deles | Regra | ADR-051, item 2 (L4) |
| R21 | Com o site desligado para o evento do tipo (ou na chave geral), o `notify()` não grava nem emite a notificação | Regra | ADR-074, item 4 (L10) |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** um cliente com 4 notificações, 3 não lidas, **quando** ele abre a "Central de Notificações", **então** vê as 4 da mais recente para a mais antiga, agrupadas em "HOJE" e "ANTERIORES", cada uma com rótulo, tempo, título e mensagem, e as 3 não lidas destacadas.
- **CA2** (R5, R6) — **Dado** uma notificação não lida com `reference_link = /pedidos/<id>`, **quando** o cliente seleciona "Ver pedido", **então** a tela do pedido abre, a notificação fica com `is_read = true` e o contador de não lidas diminui 1.
- **CA3** (R6) — **Dado** uma notificação não lida sem `reference_link`, **quando** o cliente a seleciona, **então** ela é marcada como lida e o cliente continua na central.
- **CA4** (R7) — **Dado** um cliente sem nenhuma notificação, **quando** abre a central, **então** vê "Nenhuma notificação encontrada".
- **CA5** (R8) — **Dado** uma notificação cujo destino foi excluído (ex.: álbum removido do catálogo), **quando** o cliente a seleciona, **então** a página de destino mostra "Este conteúdo não está mais disponível." e a notificação fica lida.
- **CA6** (R9) — **Dado** o cliente logado em qualquer tela, **quando** uma notificação é gravada para ele, **então** o aviso flutuante aparece e o contador do sino aumenta 1, sem recarregar a página; um usuário diferente não recebe o evento.
- **CA7** (R10) — **Dado** um disparo global enviado pela CCD060, **quando** o cliente abre a central, **então** a notificação do disparo aparece com o título e a mensagem do disparo e o rótulo "Aviso da plataforma".
- **CA8** (R11) — **Dado** a tela Configurações, **quando** o cliente desliga o e-mail de "Convite para entrar em novo grupo" e salva, **então** a preferência fica gravada e continua desligada ao reabrir a tela; "Restaurar Padrões" volta tudo a ligado.
- **CA9** (R1) — **Dado** uma chamada sem token, **quando** pede a lista de notificações, **então** recebe `401`; **dado** o cliente A, **quando** tenta marcar como lida uma notificação do cliente B, **então** recebe `404` e a notificação de B não muda; **dado** um `ADMIN`, **quando** pede a lista, **então** recebe `403`.
- **CA10** (R2) — **Dado** a central abrindo, **quando** a busca ainda não respondeu, **então** a tela mostra o estado de carregamento; **quando** a busca falha, **então** mostra um aviso de erro no estilo da tela, e não a mensagem de central vazia.
- **CA11** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `490-796`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem, salvo as diferenças aceitas em **Telas (Figma)**; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela com o menu "⋮" aberto é comparado lado a lado com o print do frame `675-12111`, **então** não há diferença, salvo as diferenças aceitas em **Telas (Figma)**; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dos avisos flutuantes é comparado lado a lado com o print do frame `675-13070`, **então** não há diferença, salvo as diferenças aceitas em **Telas (Figma)**; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print do sino com o popup aberto é comparado lado a lado com o print do frame `1124-22490`, **então** não há diferença, salvo as diferenças aceitas em **Telas (Figma)**; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA15** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dos blocos "Canais de aviso" e "Categorias e Eventos" é comparado lado a lado com o print do frame `1160-41305`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA16** (R13) — **Dado** a Ana sem notificação não lida da conversa com o Bruno, **quando** o Bruno manda duas mensagens seguidas, **então** a Ana recebe uma só notificação `NEW_MESSAGE` ("@bruno", trecho da primeira, link da conversa); **depois que** ela a lê, a próxima mensagem gera outra.
- **CA17** (R14) — **Dado** um cliente com 60 notificações, **quando** abre a central, **então** vê as 50 mais recentes e "Carregar mais"; **quando** seleciona "Carregar mais", **então** vê as 10 restantes e o botão some.
- **CA18** (R15) — **Dado** um cliente com 1 `NEW_MESSAGE` e 2 `GLOBAL`, **quando** abre a central, **então** os filtros mostram "Todas 3", "Novas Mensagens 1" e "Avisos da Plataforma 2"; **quando** escolhe "Novas Mensagens", **então** vê só a `NEW_MESSAGE`.
- **CA19** (R16) — **Dado** um cliente com 3 não lidas, **quando** abre qualquer tela, **então** o sino mostra "3"; **quando** seleciona o sino, **então** o popup mostra as últimas notificações, "Ver todas as notificações" leva à central e "Configurar alertas" leva a Configurações.
- **CA20** (R17) — **Dado** uma notificação não lida, **quando** o cliente seleciona "✓", **então** ela fica lida e ele continua na central; **quando** escolhe "Configurar este tipo de alerta" no menu "⋮", **então** vai para as preferências em Configurações.
- **CA21** (R18) — **Dado** dois clientes conectados e um terceiro fora do site, **quando** o administrador envia um disparo global para todos, **então** os dois conectados recebem `notification:new` na hora e o terceiro vê a notificação ao abrir a central.
- **CA22** (R19) — **Dado** um cliente com notificações, todas lidas, **quando** abre a central, **então** vê "Tudo em dia!" e as notificações lidas abaixo, em "ANTERIORES".
- **CA23** (R21) — **Dado** a Ana com o site desligado para "Mensagem direta ou menção em chat comunitário", **quando** o Bruno manda uma mensagem, **então** nenhuma `NEW_MESSAGE` é gravada nem emitida para ela; **dado** a chave geral do site desligada, **quando** chega um disparo global, **então** ele também não é gravado para ela.
- **CA24** (R12) — **Dado** a tela implementada aberta em 1280 px sem notificações não lidas, **quando** o print dela é comparado lado a lado com o print do frame `675-11716`, **então** o cartão "Tudo em dia!" não tem diferença, salvo as diferenças aceitas em **Telas (Figma)**; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `notifications` | `id`, `user_id`, `global_notification_id`, `title`, `message`, `type`, `reference_link`, `is_read`, `created_at`, `deleted_at` | `title` (120) e `message` (500) obrigatórios; `type` varchar(40) obrigatório, com a lista no enum do domínio (R20); `is_read` default `false` |
| `global_notifications` | `id` | só a ligação da notificação ao disparo (CCD060) |
| `notification_preferences` | `user_id`, `event` (`notification_event`), `in_app`, `email`, `deleted_at` | tabela nova (ADR-074), único em (`user_id`, `event`); `ALL` guarda as chaves gerais; sem linha, tudo ligado |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel principal de notificações | [490-796](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=490-796) | R2–R7, R14, R15, R17, R20 | ⚠️ Bate, com as diferenças aceitas abaixo (L7, L9, L14) |
| Notificações — ações da notificação | [675-12111](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-12111) | R17 | ⚠️ Menu "⋮" sem "Fixar no topo" (L8); seleção e "Excluir notificação" são da CCD054 |
| Notificações — notificação em tempo real | [675-13070](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-13070) | R9 | ⚠️ Avisos flutuantes com um botão de ação e "Marcar como lida" (L7) |
| Notificações — tudo em dia | [675-11716](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-11716) | R19 | ✅ Bate no cartão "Tudo em dia!"; o aviso "5 notificações marcadas como lidas · Desfazer" é da CCD054 |
| Cliente — Início com notificações abertas | [1124-22490](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1124-22490) | R15, R16 | ⚠️ Sino e popup entram (L6); Aceitar/Recusar do convite ficam fora (L7) |
| Configurações (blocos "Canais de aviso" e "Categorias e Eventos") | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | R11 | ✅ Seis eventos e duas chaves gerais, como no frame (L10); a página nasce só com esses blocos (L15) |

- Textos da central (`490-796`): "NOTIFICAÇÕES E FAVORITOS", "Notificações & Favoritos", "Acompanhe alertas em tempo real e acesse rapidamente seus álbuns, cartas raras e comunidades salvas.", "Marcar todas como lidas", "Configurar Alertas", "5 Não Lidas", "28 Itens Salvos", abas "Central de Notificações" e "Meus Favoritos", "Mais recentes primeiro", grupos "HOJE" e "ANTERIORES".
- Popup do sino (`1124-22490`): "Notificações", "3 novas", "Marcar todas como lidas", abas "Todas (4)", "Não lidas (3)", "Pedidos (1)", "Grupos (1)", "Ver todas as notificações", "Configurar alertas".
- **Diferenças aceitas** (decididas em Lacunas e decisões): o grupo "ANTERIORES" não traz "• Últimos 3 dias", porque a central não corta por data (L9); cada notificação tem um só botão de ação, sem "Acompanhar rastreio", "Aceitar Convite"/"Recusar" e "Criar Novo Álbum Desta Coleção" (L7); o menu "⋮" não tem "Fixar no topo" (L8); "Marcar todas como lidas" aparece e ganha a ação na CCD054; a aba "Meus Favoritos" abre a página em construção (CCD055) e o selo "Itens Salvos" aparece sem número até os favoritos existirem (L14).
- **O que falta no Figma** (implementar no estilo da tela): R7 central sem nenhuma notificação; R8 aviso de conteúdo indisponível; R14 "Carregar mais"; estados de carregamento e erro (CA10).

## Fora do escopo

- "Marcar todas como lidas", excluir, a seleção de várias notificações e o aviso "Desfazer" — CCD054.
- A aba "Meus Favoritos" e o número de "Itens Salvos" — CCD055, CCD056 e CCD057.
- Criar a notificação de cada evento — a story que gera o evento (CCD060, CCD064, CCD072, CCD109, CCD110…), que acrescenta o tipo e o evento dele (ADR-051, item 2; ADR-074, item 3). A exceção é a `NEW_MESSAGE` do chat pessoal (R13).
- Mandar e-mail por evento — a story que manda o e-mail, lendo a preferência (ADR-074, item 4).
- "Fixar no topo" (L8); aceitar ou recusar convite, rastreio e criar álbum dentro da notificação (L7).
- Silenciar notificações de um grupo — CCD041. Menção no chat do grupo — Comunidades.
- Alerta de preço ("Avisar abaixo de…") — fase Futuro.
- Push e WhatsApp — não existem (ADR-058).
- O restante das telas Início (CCD007) e Configurações (Conta e segurança, Privacidade e Excluir conta: CCD051 e CCD052).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O ator é só "Cliente". `SELLER` também tem a central? E o `ADMIN`, que usa o BackOffice? | `CUSTOMER` e `SELLER`; o `ADMIN` recebe `403` e não vê o sino (Daniel, 28/11/2026) | `53`, Atores e Pré-condições; R1 |
| L2 | Mensagem da central vazia: "Nenhuma notificação encontrada" (caso de uso) ou "Tudo em dia!" (Figma `675-11716`, sem não lidas)? | Os dois, cada um no seu caso: "Tudo em dia!" sem não lidas, com as lidas abaixo; "Nenhuma notificação encontrada" sem nenhuma notificação (Daniel, 28/11/2026) | `53`, FA 1 e FA 3; R7, R19 |
| L3 | Texto do aviso de conteúdo indisponível (FA 2) | "Este conteúdo não está mais disponível.", na página de destino, quando o usuário veio de uma notificação (Daniel, 28/11/2026) | `53`, FA 2; R8 |
| L4 | Quais tipos de notificação existem e com que rótulo? | Enum de tipos no domínio `notifications`, com rótulo e categoria; pedido e convite de grupo entram com as stories deles (Daniel, 28/11/2026) | R20 |
| L5 | Filtros com contagem (só no Figma). Faz sentido implementar? | Sim, como no Figma, com a contagem por categoria (Daniel, 28/11/2026) | `53`, FA 4–5 e 10; R15 |
| L6 | Sino com contador e popup (só no Figma, `1124-22490`). Faz sentido implementar? | Sim, contador e popup em todas as telas do cliente e do vendedor (Daniel, 28/11/2026) | `53`, FA 9–10; R16 |
| L7 | Botões dentro da notificação e do aviso flutuante (só no Figma). O DBML guarda um só `reference_link` e não tem convite para grupo | Um botão com o link, com o rótulo do tipo, e "Marcar como lida" no aviso flutuante; os demais ficam fora (Daniel, 28/11/2026) | `53`, FP 3 e FA 8; R5, R9; Fora do escopo |
| L8 | Botão ✓ e menu ⋮ (só no Figma, `675-12111`) | "✓" e o menu com "Marcar como lida" e "Configurar este tipo de alerta"; sem "Fixar no topo"; "Excluir notificação" entra com a CCD054 (Daniel, 28/11/2026) | `53`, FA 6–7; R17 |
| L9 | Agrupamento "HOJE" / "ANTERIORES • Últimos 3 dias" e paginação | Todas as notificações, agrupadas em "HOJE" e "ANTERIORES", 50 por vez por cursor (ADR-011), com "Carregar mais"; sem corte em 3 dias (Daniel, 28/11/2026) | `53`, FP 3; R3, R14 |
| L10 | Preferências por tipo de aviso: onde gravar, quais tipos e quem respeita? | Como no Figma (seis eventos e duas chaves gerais), na tabela `notification_preferences`; o `notify()` não grava nem emite com o site desligado; o e-mail fica com a story que manda e-mail (Daniel, 28/11/2026) | EA-053-01; ADR-074; DER; R11, R21 |
| L11 | A L9 da CCD073 põe o aviso de mensagem nova com a CCD053. Quem o cria, e uma notificação por mensagem? | Uma por conversa: o chat chama `notify()` com `NEW_MESSAGE` só se o destinatário não tiver uma não lida daquela conversa; a ligação vai num PR à parte, empilhado no chat pessoal (Daniel, 28/11/2026) | R13 |
| L12 | O disparo global (CCD060) grava em lotes e não emite em tempo real | Emite `notification:new` para cada destinatário depois de cada lote (Daniel, 28/11/2026) | R18 |
| L13 | O ADR-015 (item 4) diz que notificações não são excluídas, mas o DBML tem `deleted_at` | A central filtra `deleted_at` nulo; excluir ou não é decidido na CCD054 (Daniel, 28/11/2026) | R2 |
| L14 | "Marcar todas como lidas" (CCD054), "Meus Favoritos" e "Itens Salvos" (CCD055–057) estão no frame | Aparecem como no frame: a ação de "Marcar todas como lidas" entra com a CCD054, "Meus Favoritos" abre a página em construção e "Itens Salvos" fica sem número (Daniel, 28/11/2026) | Telas (Figma) |
| L15 | A tela Configurações (`1160-41305`) é da CCD051/CCD052 e está em construção. Onde ficam as preferências? | `/configuracoes` passa a existir só com o cabeçalho e os blocos de aviso; a CCD051 e a CCD052 acrescentam o resto na mesma página (Daniel, 28/11/2026) | R11 |
| L16 | A `api` e o `ws` rodam em contêineres separados (ADR-055), e as notificações do disparo global, do catálogo e do cadastro de vendedor nascem na `api`. Como a `api` avisa o `ws` para emitir `notification:new`? | Adapter do PostgreSQL (`@socket.io/postgres-adapter` no `ws`, `@socket.io/postgres-emitter` na `api`), pelo `LISTEN/NOTIFY`, com a tabela técnica `socket_io_attachments` (Daniel, 28/11/2026) | ADR-075; R9, R18 |
