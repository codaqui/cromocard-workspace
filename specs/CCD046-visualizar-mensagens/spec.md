# CCD046 — Visualizar Mensagens

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1217 `CCD046 - Visualizar Mensagens` (criada em 22/11/2026)
- **Caso de uso:** [46-visualizar-mensagens.md](../../docs/Casos-De-Uso/46-visualizar-mensagens.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com acesso à área de mensagens
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar minhas mensagens para acompanhar as conversas realizadas com outros usuários dentro do grupo.

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
| R1 | A área de mensagens exige login (`401` sem token); o usuário só vê as conversas de que participa, e abrir a conversa de outra pessoa responde `404` | Permissão | `46`, Pré-condições; ADR-005; ADR-012, Rooms (entrada só se participante) |
| R2 | Página "Mensagens" (item "Mensagens" no menu da Área do Cliente), com o topo "MENSAGENS • Chat pessoal com outros colecionadores" e a coluna "Conversas" | Tela | `46`, FP 1; Figma `1160-32980` |
| R3 | A lista mostra as conversas do usuário: foto, nome e @ do outro participante, a última mensagem (com "Você: " quando é do próprio usuário), a hora ou a data dela e a quantidade de mensagens não lidas | Tela | `46`, FP 2 e FP 5; DBML `conversation_participants`, `messages`; Figma `1160-32980` |
| R4 | Selecionar uma conversa carrega as mensagens dela em ordem cronológica, com o nome e o @ do outro participante no topo e a separação por dia ("Hoje, 31 de Outubro") | Ação | `46`, FP 3–4; Figma `1160-32980` |
| R5 | As mensagens recebidas e ainda não lidas (`is_read = false`) são identificadas visualmente: contador na conversa da lista e destaque na conversa aberta | Estado | `46`, FP 5; DBML `messages.is_read`, `messages.read_at` (L13) |
| R6 | Sem nenhuma conversa, a tela mostra "Nenhuma conversa encontrada" | Estado | `46`, FA 1 (L2) |
| R7 | Falha ao carregar a lista ou as mensagens: a tela informa que não foi possível carregar as mensagens | Estado | `46`, FA 2 |
| R8 | Mensagem nova chega em tempo real: aparece na conversa aberta e atualiza a lista (última mensagem, hora e não lidas) sem recarregar a página | Regra | ADR-012, Decisão (rooms `user:<id>` e `conversation:<id>`); `CLAUDE.md`, Arquitetura (Mensageria em Tempo Real) |
| R9 | Mensagens excluídas (`deleted_at`) e conversas de participante excluído não aparecem | Regra | ADR-015, itens 5 e 8 |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-36236`, `1160-34999`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** Gabriel com 4 conversas, **quando** ele abre "Mensagens" e seleciona a conversa com Marcos, **então** vê as 4 conversas na lista, cada uma com foto, nome, @, última mensagem e hora, e as mensagens com Marcos em ordem cronológica, separadas por dia.
- **CA2** (R3) — **Dado** uma conversa cuja última mensagem é de Gabriel, **quando** ele abre a lista, **então** a prévia começa com "Você: ".
- **CA3** (R5) — **Dado** a conversa com Renata com 1 mensagem não lida, **quando** Gabriel abre a lista, **então** a conversa mostra o contador "1"; ao abrir a conversa, a mensagem não lida aparece destacada.
- **CA4** (R6) — **Dado** um usuário sem nenhuma conversa, **quando** ele abre "Mensagens", **então** a tela mostra "Nenhuma conversa encontrada" (texto sujeito à L2).
- **CA5** (R7) — **Dado** a API fora do ar, **quando** o usuário abre "Mensagens" ou uma conversa, **então** a tela informa que não foi possível carregar as mensagens.
- **CA6** (R8) — **Dado** Gabriel com a conversa com Marcos aberta, **quando** Marcos envia uma mensagem, **então** ela aparece no fim da conversa e a lista atualiza a prévia e a hora, sem recarregar a página.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a lista de conversas, **então** recebe `401`; **dado** Gabriel, **quando** pede as mensagens de uma conversa entre outras duas pessoas, **então** recebe `404`.
- **CA8** (R9) — **Dado** uma mensagem excluída na conversa, **quando** o usuário abre a conversa, **então** ela não aparece.
- **CA9** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (conversas), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R10) — **Dado** a tela implementada aberta em 1280 px sem conversas, **quando** o print dela é comparado lado a lado com o print do frame `1160-36236` (sem conversas), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem (salvo o texto decidido na L2); e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R10) — Vale se a L5 trouxer "Nova conversa" para esta spec: **dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-34999` (nova conversa), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `conversations` | `id`, `created_at`, `deleted_at` | `listing_id` não é usado aqui (conversa de anúncio é da CCD073) |
| `conversation_participants` | `conversation_id`, `user_id`, `deleted_at` | PK composta; define as conversas do usuário (R1, R3) |
| `messages` | `conversation_id`, `author_id`, `reply_to_id`, `content`, `is_read`, `read_at`, `created_at`, `deleted_at` | `is_read` default `false`; `reply_to_id` só para mostrar a citação (CCD045) |
| `users` | `name`, `username`, `deleted_at` | nome e @ do outro participante |
| `profiles` | `avatar_url` | foto do outro participante |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - conversas | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R2–R5, R8 | ❌ Não bate: busca, filtros, arquivadas, selo, presença, reações e textos de segurança só no Figma (L3, L4, L6–L11) |
| Mensagens - sem conversas | [1160-36236](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-36236) | R6 | ❌ Não bate: texto diferente do caso de uso (L2) |
| Mensagens - nova conversa | [1160-34999](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-34999) | — | ⚠️ Sem requisito no caso de uso 46; depende da L5 |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): Mensagens - sem conversas — mostra "Nenhuma conversa ainda",
  "Toque em "Nova conversa" para falar em particular com outro colecionador." e, no rodapé da lista, "Nenhuma conversa";
  o caso de uso pede "Nenhuma conversa encontrada" (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Buscar conversa" (L3); abas "Todas" e "Não
  Lidas" com contadores, "4 ativas" e o botão de filtros (L4); botão e modal "Nova conversa" (L5); "Ver Arquivadas" e "4
  de 4 conversas listadas" (L6); selo "Verificado" (L7); ponto verde de online e "Visto há 3h" (L8); reações "⚡ 2 🔥 1" e
  "Reagir" (L9); "Concluído" abaixo do @ (L10); botão "Ver Perfil" e o escudo no topo da conversa (L11); "Dica de
  segurança" e o rodapé "Faça compras e pagamentos só pelo marketplace da CromoCard." (L12).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 erro ao carregar; estado carregando (L14).

## Fora do escopo

- Responder uma mensagem específica — CCD045. Bloquear ou denunciar pelo escudo do topo — CCD047.
- Indicador de leitura (✓ na mensagem enviada) — user story "Visualizar Status de Leitura" (fase Futuro).
- Conversa aberta a partir de um anúncio (`conversations.listing_id`) — CCD073.
- Anexos, cartas e localização no chat — fase Futuro.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | A narrativa da user story diz "conversas ... dentro do grupo", mas o caso de uso e o Figma são do chat pessoal (o chat do grupo é a CCD044). Ajustar a narrativa? | pendente | — |
| L2 | Texto do estado vazio: o Figma (`1160-36236`) mostra "Nenhuma conversa ainda" e a dica de "Nova conversa"; o `46`, FA 1, pede "Nenhuma conversa encontrada". Qual vale? | pendente | — |
| L3 | Só no Figma: "Buscar conversa" (por nome ou @). Faz sentido implementar? | pendente | — |
| L4 | Só no Figma: abas "Todas" e "Não Lidas" com contadores, o selo "4 ativas" e o botão de filtros ao lado de "Nova conversa". Faz sentido implementar? O que o botão de filtros faz? | pendente | — |
| L5 | Só no Figma: "Nova conversa" (`1160-34999`), com busca de pessoas, abas "Todos", "Dos meus grupos", "Lojistas" e "Já negociei", "Conversas recentes" e a regra "Só é possível conversar com quem aceita mensagens de desconhecidos ou participa de um grupo com você." Isso é da user story "Conversar com Colecionador", que não tem caso de uso nem CCD; o DBML não tem a opção "aceita mensagens de desconhecidos". Entra nesta spec, vira caso de uso novo ou fica de fora? | pendente | — |
| L6 | Só no Figma: "Ver Arquivadas" e o rodapé "4 de 4 conversas listadas". O DBML não tem conversa arquivada. Faz sentido implementar? E a lista pagina? | pendente | — |
| L7 | Só no Figma: selo "Verificado" ao lado do nome. O que ele significa (vendedor com conta Stripe pronta, e-mail confirmado)? Faz sentido implementar? | pendente | — |
| L8 | Só no Figma: ponto verde de online e "Visto há 3h". O DBML não guarda presença nem último acesso público (`last_login_at` é do BackOffice). Faz sentido implementar? | pendente | — |
| L9 | Só no Figma: reações nas mensagens ("⚡ 2", "🔥 1", "Reagir"). O DBML não tem tabela de reação. Faz sentido implementar? (ver L2 da CCD045) | pendente | — |
| L10 | Só no Figma: "Concluído" abaixo do @ de uma conversa. O que significa? Faz sentido implementar? | pendente | — |
| L11 | Só no Figma: "Ver Perfil" no topo da conversa (abriria o perfil público, EA-080-01). Faz sentido implementar? O escudo ao lado abre "Bloquear ou denunciar" (CCD047) | pendente | — |
| L12 | Só no Figma: o quadro "Dica de segurança" ("Nunca pague por Pix ou link fora da CromoCard...") e o rodapé "Faça compras e pagamentos só pelo marketplace da CromoCard.". Faz sentido implementar? (proposta: sim, texto fixo) | pendente | — |
| L13 | Quando a mensagem passa a lida (`is_read = true`, `read_at`)? (proposta: quando o destinatário abre a conversa) | pendente | — |
| L14 | Ordem da lista (proposta: pela última mensagem, a mais recente primeiro), quantas mensagens carregar por vez e o estado carregando, que não tem frame | pendente | — |
| L15 | O ator é Cliente: `SELLER` e `ADMIN` também usam o chat pessoal? (proposta: `CUSTOMER` e `SELLER`) | pendente | — |
| L16 | A T12 (servidor Socket.IO autenticado por JWT, base da Onda 0) pode entrar antes da aprovação desta spec? | Sim (PO, 25/11/2026, na revisão de codaqui/cromocard-backend#42): a T12 não depende de nenhuma lacuna pendente. O resto da spec só entra depois da aprovação | esta tabela; plano da CCD044 (handshake) |
