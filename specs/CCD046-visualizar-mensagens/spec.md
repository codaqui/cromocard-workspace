# CCD046 — Visualizar Mensagens

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #1217 `CCD046 - Visualizar Mensagens` (criada em 22/11/2026)
- **Caso de uso:** [46-visualizar-mensagens.md](../../docs/Casos-De-Uso/46-visualizar-mensagens.md)
- **Atores:** Cliente e Vendedor · **Pré-condições:** autenticado como `CUSTOMER` ou `SELLER`
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-11-24, Daniel Andrade (dono do módulo no plano final); a validar pelo PO, Felipe Consulim

## Objetivo

> Como Cliente preciso visualizar minhas mensagens para acompanhar as conversas pessoais com outros colecionadores.
>
> Inclui a user story "Conversar com Colecionador" (nova conversa e envio), que não tinha caso de uso (L5).

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
| R1 | A área de mensagens exige login (`401` sem token) e é só de `CUSTOMER` e `SELLER` (`403` para `ADMIN`); o usuário só vê as conversas de que participa, e abrir a conversa de outra pessoa responde `404` | Permissão | `46`, Atores e Pré-condições (L15); ADR-005; ADR-012, Rooms (entrada só se participante) |
| R2 | Página "Mensagens" (item "Mensagens" no menu do site), com o topo "MENSAGENS • Chat pessoal com outros colecionadores" e a coluna "Conversas" | Tela | `46`, FP 1–2; Figma `1160-32980` |
| R3 | A lista mostra as conversas do usuário, da última mensagem mais recente para a mais antiga: foto (ou inicial), nome e @ do outro participante, a prévia da última mensagem (com "Você: " quando é do próprio usuário), a hora ou a data dela e a quantidade de não lidas | Tela | `46`, FP 3 (L14, L16); DBML `conversation_participants`, `messages`; Figma `1160-32980` |
| R4 | Selecionar uma conversa carrega as 30 mensagens mais recentes em ordem cronológica, com a separação por dia ("Hoje, 31 de Outubro"); as anteriores carregam ao rolar para cima | Ação | `46`, FP 5 e FP 7 (L14); Figma `1160-32980` |
| R5 | As mensagens recebidas e não lidas (`is_read = false`) aparecem com o contador na lista e destacadas na conversa; abrir a conversa marca as recebidas como lidas (`is_read`, `read_at`), e a que chega com a conversa aberta já entra lida | Estado | `46`, FP 3, FP 8 e FP 10 (L13); DBML `messages.is_read`, `messages.read_at` |
| R6 | Sem nenhuma conversa, a tela mostra "Nenhuma conversa ainda", a dica "Toque em "Nova conversa" para falar em particular com outro colecionador." e, no rodapé da lista, "Nenhuma conversa" | Estado | `46`, FA 1 (L2); Figma `1160-36236` |
| R7 | Falha ao carregar a lista ou as mensagens: a tela informa que não foi possível carregar as mensagens | Estado | `46`, FA 2 |
| R8 | Mensagem nova chega em tempo real: aparece na conversa aberta e atualiza a lista (prévia, hora e não lidas) sem recarregar a página | Regra | `46`, FP 10; ADR-012, Decisão (rooms `user:<id>` e `conversation:<id>`) |
| R9 | Mensagens excluídas (`deleted_at`) e conversas de participante excluído não aparecem | Regra | ADR-015, itens 5 e 8 |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-36236`, `1160-34999`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R11 | "Buscar conversa" filtra a lista pelo nome ou pelo @ do outro participante | Ação | `46`, FA 3–4 (L3); Figma `1160-32980` |
| R12 | Abas "Todas" e "Não Lidas", cada uma com a sua quantidade, o selo "N ativas" com o total e o rodapé "N de N conversas listadas", que acompanha a busca e a aba | Tela | `46`, FP 2, FP 4 e FA 5–6 (L4, L6); Figma `1160-32980` |
| R13 | "Nova conversa" abre o modal do frame `1160-34999`: busca por nome ou @, abas "Todos", "Dos meus grupos" (com os grupos em comum), "Lojistas" (`SELLER`) e "Já negociei" (com pedido entre os dois), "Resultados", "Conversas recentes", "Conversar" (abre a conversa, criando-a se não existir) e "Cancelar"; a busca traz só usuários ativos e não bloqueados, sem a regra de desconhecidos | Ação | `46`, FA 7–14 (L5); user story "Conversar com Colecionador"; DBML `group_members`, `orders`, `user_blocks` |
| R14 | O selo "Verificado" aparece ao lado do nome do vendedor com a verificação aprovada | Tela | `46`, FP 3 e FP 6 (L7); DBML `seller_verifications` |
| R15 | O ponto verde na foto indica que o outro participante está conectado ao tempo real agora, sem gravar presença no banco | Estado | `46`, FP 3 (L8); ADR-012 |
| R16 | O topo da conversa mostra foto, nome, @, selo, "Ver Perfil" (perfil público do outro participante; em construção até a CCD080) e o escudo de bloquear ou denunciar (a ação é da CCD047) | Tela | `46`, FP 6 (L11); Figma `1160-32980` |
| R17 | A conversa mostra o quadro "Dica de segurança" com "Nunca pague por Pix ou link fora da CromoCard. Compre pelo anúncio no marketplace: o pagamento fica retido até a entrega." e, abaixo do campo, "Faça compras e pagamentos só pelo marketplace da CromoCard." | Tela | `46`, FP 7 e FP 9 (L12); Figma `1160-32980` |
| R18 | O campo "Digite sua mensagem para @<usuário>..." envia com "Enviar" ou Enter; a mensagem é gravada, aparece no fim da conversa e chega ao outro participante em tempo real; se o envio falhar, o texto fica no campo e a tela avisa | Ação | `46`, FP 11–12 e FA 2 (L5); ADR-012 |
| R19 | Sem foto (a tabela `profiles` chega com a CCD048), o círculo mostra a inicial do nome; com `profiles`, a API passa a mandar `avatarUrl` | Tela | L16; DBML `profiles.avatar_url` |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** Gabriel com 4 conversas, **quando** ele abre "Mensagens" e seleciona a conversa com Marcos, **então** vê as 4 conversas na lista, da mais recente para a mais antiga, cada uma com foto ou inicial, nome, @, última mensagem e hora, e as mensagens com Marcos em ordem cronológica, separadas por dia.
- **CA2** (R3) — **Dado** uma conversa cuja última mensagem é de Gabriel, **quando** ele abre a lista, **então** a prévia começa com "Você: ".
- **CA3** (R5) — **Dado** a conversa com Renata com 1 mensagem não lida, **quando** Gabriel abre a lista, **então** a conversa mostra o contador "1"; ao abrir a conversa, a mensagem aparece destacada e o contador zera.
- **CA4** (R6) — **Dado** um usuário sem nenhuma conversa, **quando** ele abre "Mensagens", **então** a tela mostra "Nenhuma conversa ainda", a dica de "Nova conversa" e "Nenhuma conversa" no rodapé da lista.
- **CA5** (R7) — **Dado** a API fora do ar, **quando** o usuário abre "Mensagens" ou uma conversa, **então** a tela informa que não foi possível carregar as mensagens.
- **CA6** (R8, R18) — **Dado** Gabriel com a conversa com Marcos aberta, **quando** Marcos envia uma mensagem, **então** ela aparece no fim da conversa de Gabriel, já lida, e a lista atualiza a prévia e a hora, sem recarregar a página.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a lista de conversas, **então** recebe `401`; **dado** um `ADMIN`, recebe `403`; **dado** Gabriel, **quando** pede as mensagens de uma conversa entre outras duas pessoas, **então** recebe `404`.
- **CA8** (R9) — **Dado** uma mensagem excluída na conversa, **quando** o usuário abre a conversa, **então** ela não aparece.
- **CA9** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (conversas), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R10) — **Dado** a tela implementada aberta em 1280 px sem conversas, **quando** o print dela é comparado lado a lado com o print do frame `1160-36236` (sem conversas), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R10, R13) — **Dado** o modal "Nova conversa" aberto em 1280 px com os mesmos dados do frame, **quando** o print dele é comparado lado a lado com o print do frame `1160-34999`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R11, R12) — **Dado** Gabriel com 4 conversas e 2 com não lidas, **quando** ele digita "ren" em "Buscar conversa", **então** a lista mostra só a conversa com Renata e o rodapé "1 de 4 conversas listadas"; **quando** ele limpa a busca e escolhe "Não Lidas", **então** vê só as 2 conversas com não lidas.
- **CA13** (R13) — **Dado** Gabriel sem conversa com Renan, **quando** ele abre "Nova conversa", busca "ren" e seleciona "Conversar" em Renan, **então** a conversa com Renan é criada, aparece aberta e o modal fecha; **quando** ele faz o mesmo com Renata, que já tem conversa, **então** abre a conversa existente, sem criar outra.
- **CA14** (R13) — **Dado** um usuário que Gabriel bloqueou ou um usuário suspenso, **quando** Gabriel busca pelo nome dele em "Nova conversa", **então** ele não aparece nos resultados; **dado** a aba "Dos meus grupos", **então** os resultados são só de quem participa de um grupo com Gabriel, com os grupos em comum.
- **CA15** (R14, R15) — **Dado** Marcos, vendedor com a verificação aprovada e conectado, **quando** Gabriel abre a lista, **então** Marcos aparece com o selo "Verificado" e o ponto verde; **dado** Thiago, cliente desconectado, **então** aparece sem os dois.
- **CA16** (R18) — **Dado** a conversa com Marcos aberta, **quando** Gabriel digita "Combinado, compro pelo anúncio." e pressiona Enter, **então** a mensagem aparece no fim da conversa, a prévia da lista vira "Você: Combinado, compro pelo anúncio." e Marcos a recebe em tempo real; **dado** o envio recusado, **então** o texto continua no campo e a tela avisa.

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
| Mensagens - conversas | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R2–R5, R8, R11, R12, R14–R18 | ✅ Bate depois das decisões L3–L12 e do ajuste no Figma de 24/11/2026 |
| Mensagens - sem conversas | [1160-36236](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-36236) | R6 | ✅ Bate: o caso de uso passou a usar o texto do Figma (L2) |
| Mensagens - nova conversa | [1160-34999](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-34999) | R13 | ✅ Bate depois da L5 (sem o aviso de desconhecidos, tirado do Figma) |

- **Ajustes no Figma em 24/11/2026:** saíram dos três frames o botão de filtros, "Ver Arquivadas", "Visto há 3h", as reações, "Concluído", o aviso de desconhecidos, o ✓✓ de leitura, o botão de emoji e textos escondidos de trocas e avaliações.
- **Diferença aceita:** a foto vira a inicial do nome até a CCD048 criar `profiles` (L17).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 erro ao carregar; estado carregando (L14); aviso de envio que falhou (R18).

## Fora do escopo

- Responder uma mensagem específica — CCD045. A ação de bloquear ou denunciar pelo escudo do topo — CCD047.
- Indicador de leitura (✓✓ na mensagem enviada) — user story "Visualizar Status de Leitura" (fase Futuro, fora do plano final); tirado do Figma em 24/11/2026.
- Seletor de emoji no campo de mensagem — nenhum documento pede; tirado do Figma em 24/11/2026 (o teclado do sistema já tem emoji).
- Conversa aberta a partir de um anúncio (`conversations.listing_id`) — CCD073.
- Anexos, cartas e localização no chat — fase Futuro.
- Tirados do Figma em 24/11/2026 por decisão: botão de filtros da coluna (L4), "Ver Arquivadas" e arquivar conversa (L6), "Visto há 3h" (L8), reações e "Reagir" (L9), "Concluído" (L10) e o aviso "Só é possível conversar com quem aceita mensagens de desconhecidos…" do modal (L5).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | A narrativa diz "dentro do grupo", mas o caso de uso e o Figma são do chat pessoal | Ajustada para "conversas pessoais com outros colecionadores" (24/11/2026, Daniel) | `user-stories.md`, `resumo-user-stories.md` |
| L2 | Texto do estado vazio: Figma ou caso de uso? | Segue o Figma: "Nenhuma conversa ainda", a dica de "Nova conversa" e "Nenhuma conversa" no rodapé | `46`, FA 1; R6 |
| L3 | "Buscar conversa" só no Figma | Entra: filtra pelo nome ou @ | `46`, FA 3–4; R11 |
| L4 | Abas, "4 ativas" e botão de filtros só no Figma | Entram as abas e o selo; o botão de filtros sai (sem função) e foi tirado do Figma | `46`, FP 2 e FA 5–6; R12; Figma |
| L5 | "Nova conversa" (`1160-34999`) e a regra de desconhecidos | Entra nesta spec, com o envio, absorvendo a user story "Conversar com Colecionador"; sem a regra de desconhecidos (conversa com qualquer usuário ativo, menos bloqueados); o aviso 🔒 foi tirado do Figma | `46`, FP 11–12 e FA 7–14; R13, R18; Figma |
| L6 | "Ver Arquivadas" e "4 de 4 conversas listadas" | Só o rodapé com a contagem; "Ver Arquivadas" sai e foi tirado do Figma | `46`, FP 4; R12; Figma |
| L7 | Selo "Verificado" | Vendedor com a verificação aprovada (`seller_verifications`) | `46`, FP 3; R14 |
| L8 | Ponto online e "Visto há 3h" | Só o ponto online, pela conexão no Socket.IO, sem gravar no banco; "Visto há" sai e foi tirado do Figma | `46`, FP 3; R15; Figma |
| L9 | Reações | Ficam fora; tiradas do Figma | Fora do escopo; Figma |
| L10 | "Concluído" | Não entra; tirado do Figma | Fora do escopo; Figma |
| L11 | "Ver Perfil" e escudo | Os dois aparecem: "Ver Perfil" leva ao perfil público (em construção até a CCD080) e o escudo ganha a ação na CCD047 | `46`, FP 6; R16 |
| L12 | "Dica de segurança" e o rodapé de compras | Entram, texto fixo | `46`, FP 7 e FP 9; R17 |
| L13 | Quando a mensagem passa a lida | Ao abrir a conversa; com ela aberta, a nova já entra lida | `46`, FP 8 e FP 10; R5 |
| L14 | Ordem, carga e carregando | Lista pela última mensagem; 30 mensagens por vez, as anteriores ao rolar para cima; `LoadingState` | `46`, FP 3 e FP 7; R3, R4 |
| L15 | Papéis do chat pessoal | `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` | `46`, Atores; R1 |
| L16 | A T12 (servidor Socket.IO autenticado por JWT) e a T13 (cliente Socket.IO e `VITE_WS_URL`), a base da Onda 0, podem entrar antes da aprovação desta spec? | Sim (PO, 25/11/2026, nas revisões de codaqui/cromocard-backend#42 e codaqui/cromocard-frontend#33): as duas não dependem de nenhuma lacuna pendente. O resto da spec só entra depois da aprovação | esta tabela; plano da CCD044 (handshake) |
| L17 | A foto vem de `profiles`, que só chega com a CCD048 (Onda 0 do Gabriel) | Inicial do nome até lá; a API passa a mandar `avatarUrl` quando `profiles` existir | R19 |
