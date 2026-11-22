# CCD039 — Explorar e Entrar em Grupos

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #142 `CCD039 - Explorar e Entrar em Grupos`
- **Caso de uso:** [39-explorar-e-entrar-em-grupos.md](../../docs/Casos-De-Uso/39-explorar-e-entrar-em-grupos.md)
- **Atores:** Cliente · **Pré-condições:** usuário autenticado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso buscar grupos, solicitar entrada ou compartilhar o link de um grupo existente.

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
| R1 | Explorar, buscar e entrar em grupos exige login: sem token, a API responde `401`. O visitante não tem o item "Comunidades" no menu | Permissão | `39`, Pré-condições; EA-001-01; ADR-005, item 4 |
| R2 | Página "Comunidades", aberta pelo item "Comunidades" do menu do cliente, com a lista de grupos | Tela | `39`, FP 1; `escopo-adicional.md`, seção 4 (menu lateral único, 20/11/2026) |
| R3 | Campo de busca de grupos por nome ou tema | Campo | `39`, FP 2 (L2) |
| R4 | A lista mostra, de cada grupo, nome, descrição, quantidade de membros e tipo de acesso (aberto ou fechado) | Tela | `39`, FP 3; DBML `groups.name`, `description`, `access_type` |
| R5 | A lista mostra só grupos não excluídos e não suspensos | Regra | `62`, FP 8; ADR-015, itens 5 e 6; DBML `groups.status`, `deleted_at` |
| R6 | A lista é paginada | Regra | ADR-011 (paginação por offset) |
| R7 | Num grupo aberto (`OPEN`), entrar adiciona o usuário como membro na hora, com o papel `MEMBER`, e abre a tela do grupo | Ação | `39`, FP 4–6; DBML `group_members.role` (default `MEMBER`) |
| R8 | Quem saiu ou foi removido e entra de novo tem a linha de `group_members` restaurada (`deleted_at` volta a nulo), sem linha nova | Regra | ADR-015, item 7; DBML `group_members` (`group_id`, `user_id` único) |
| R9 | Num grupo fechado (`CLOSED`), entrar cria uma solicitação de entrada `PENDING` para o administrador do grupo e informa que a solicitação está pendente de aprovação | Ação | `39`, FA 1; DBML `group_join_requests.status` (default `PENDING`) |
| R10 | Busca sem resultado: a tela informa que nenhum grupo foi encontrado e sugere criar um grupo novo | Estado | `39`, FA 2 |
| R11 | Compartilhar o link de um grupo existente | Ação | `user-stories.md`, seção 4, "Explorar e Entrar em Grupos" (L12) |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`417-2915`, `675-17336`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2–R4, R6) — **Dado** um cliente logado e grupos cadastrados, **quando** ele abre "Comunidades" e busca
  "Pokémon", **então** a lista mostra os grupos que batem com o termo, cada um com nome, descrição, quantidade de membros
  e o selo do tipo de acesso, paginados.
- **CA2** (R7) — **Dado** um grupo aberto do qual o cliente não é membro, **quando** ele seleciona "Entrar no grupo",
  **então** a API grava `group_members` com `role = MEMBER` e a tela do grupo abre.
- **CA3** (R8) — **Dado** um cliente que saiu de um grupo aberto, **quando** ele entra de novo, **então** a mesma linha
  de `group_members` volta com `deleted_at` nulo e nenhuma linha nova é criada.
- **CA4** (R9) — **Dado** um grupo fechado, **quando** o cliente seleciona "Solicitar entrada", **então** a API grava
  `group_join_requests` com `status = PENDING`, o usuário não vira membro e o cartão do grupo passa a mostrar que a
  solicitação está aguardando aprovação.
- **CA5** (R10) — **Dado** nenhum grupo com o termo "zzzz", **quando** o cliente busca, **então** a tela informa que
  nenhum grupo foi encontrado e mostra a sugestão de criar um grupo, que leva ao "Criar grupo" (CCD043).
- **CA6** (R5) — **Dado** um grupo suspenso e um excluído, **quando** o cliente abre "Comunidades", **então** nenhum
  dos dois aparece na lista nem na busca.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a listagem ou a entrada num grupo, **então** a API
  responde `401`; no site, o menu do visitante não mostra "Comunidades".
- **CA8** (R11) — **Dado** um grupo na lista, **quando** o cliente seleciona "Compartilhar" e "Copiar link", **então**
  o link do grupo vai para a área de transferência.
- **CA9** (R12) — **Dado** a página "Comunidades" aberta em 1280 px com os mesmos dados do frame, **quando** o print
  dela é comparado lado a lado com o print do frame `417-2915`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.
- **CA10** (R12) — **Dado** o modal "Compartilhar grupo" aberto em 1280 px com os mesmos dados do frame, **quando** o
  print dele é comparado lado a lado com o print do frame `675-17336`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `groups` | `id`, `name`, `description`, `cover_image_url`, `access_type` (`group_access_type`: `OPEN`, `CLOSED`), `status` (`group_status`: `ACTIVE`, `WARNED`, `SUSPENDED`), `deleted_at` | `name` obrigatório (120); `access_type` obrigatório; `status` default `ACTIVE` |
| `group_members` | `group_id`, `user_id`, `role` (`member_role`: `MEMBER`, `ADMIN`), `deleted_at` | `(group_id, user_id)` único; `role` default `MEMBER`; a quantidade de membros conta as linhas não excluídas |
| `group_join_requests` | `group_id`, `user_id`, `status` (`request_status`: `PENDING`, `APPROVED`, `REJECTED`), `created_at` | `status` default `PENDING`; sem índice único no DBML (L15) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - Pagina principal | [417-2915](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=417-2915) | R2–R5, R7, R9 | ❌ Não bate: busca por cidade (L2), abas e "Meus grupos" (L3), ordenação (L4), selo "AGUARDANDO MODERAÇÃO" (L5), online (L6), verificado (L7), franquia (L8), painéis laterais (L9, L10) |
| Comunidade - detalhes e compartilhar grupo | [675-17336](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-17336) | R11 | ❌ Não bate: página de detalhes antes de entrar (L11), o caso de uso não tem o passo de compartilhar (L12), convite com prazo (L13), QR code e canais (L14) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Página principal — busca: o placeholder é "Buscar grupos por nome ou cidade..." e há o filtro "FILTRAR: Todas as
    Cidades"; o `39` FP 2 pede busca por nome ou tema (L2).
  - Página principal — o cartão do grupo com a solicitação pendente mostra o selo "AGUARDANDO MODERAÇÃO", "Solicitação
    enviada há 2 dias" e o botão desabilitado "Aguardando Aprovação"; o `39` FA 1 fala em "pendente de aprovação" do
    administrador do grupo (L5).
  - Página principal — os cartões mostram a franquia ("Pokémon TCG • SP", "Futebol Panini • Nacional"), que o
    `escopo-adicional.md`, seção 3, tirou (L8).
  - Detalhes e compartilhar — ao fundo do modal, a página do grupo antes de entrar ("Solicitar entrada", "Restrito •
    requer aprovação", "Sobre", "Administração", "Regras do grupo"); o `39` FP 4–5 entra direto ao selecionar o grupo (L11).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Página principal — abas "Todos os Grupos", "Meus Grupos", "Grupos que Administro" e "Solicitações Pendentes", com
    contadores, e a seção "Meus grupos — Grupos em que você participa" com selo de papel ("Membro Ativo", "Membro"),
    "Abrir grupo" e o ícone de engrenagem ou de compartilhar (L3).
  - Página principal — "Explorar comunidades — Grupos públicos e com aprovação" com "Ordenar por: Mais Ativos" (L4).
  - Página principal — "<n> online" em cada cartão (L6) e o ícone de verificado ao lado do nome (L7).
  - Página principal — painéis "Tópicos em Alta" (Últimas 24h, hashtags com "+480 posts") e "Buscas Recentes" (L9).
  - Página principal — painel "Diretrizes de Segurança" com "Denunciar Grupo ou Spam" e "Ver Termos Completos" (L10).
  - Página principal — botão só com ícone ao lado de "Criar grupo" (L17).
  - Compartilhar grupo — QR code com "Baixar QR Code", os atalhos "WhatsApp", "Mensagem" e "E-mail", o link com código
    (`cromocard.com.br/g/pokemon-tcg-sp?c=7KX2`), "Link expira em 7 dias" e "Entrar sem aprovação pelo link" (L13, L14).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R10 — estado da busca sem resultado, com a sugestão de criar um grupo.
  - R9 — o aviso logo depois de "Solicitar entrada" de que a solicitação está pendente de aprovação (o frame só desenha o
    cartão já pendente).
  - Estados de carregando e de erro da lista (L19).

## Fora do escopo

- Criar grupo (botão "Criar grupo" e o cartão "Crie seu grupo de graça") e aprovar ou recusar solicitações — CCD043.
- Tela do grupo e chat — CCD044. "Abrir grupo" só navega para ela.
- Sino de silenciado nos cartões de "Meus grupos" — CCD041.
- Favoritar grupo — CCD057.
- Grupos na busca global — CCD002.
- Franquia ou categoria do grupo — `escopo-adicional.md`, seção 3 (o DER não liga grupo a categoria).
- Moderação de grupos pela plataforma (suspender, excluir) — CCD062.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais papéis usam os grupos? O `39` diz "Cliente". (proposta: `CUSTOMER` e `SELLER`, como na CCD103; o `ADMIN` da plataforma modera pela CCD062 e recebe `403`) | pendente | — |
| L2 | A busca é por "nome ou tema" (`39` FP 2) ou por "nome ou cidade" com o filtro "Todas as Cidades" (Figma `417-2915`)? O DBML `groups` não tem cidade nem tema. (proposta: nome e descrição; cidade só se a CCD043 ganhar a coluna, L5 da CCD043) | pendente | — |
| L3 | Abas "Todos os Grupos", "Meus Grupos (4)", "Grupos que Administro (1)" e "Solicitações Pendentes (2)" e a seção "Meus grupos" com o selo de papel e "Abrir grupo" só existem no Figma: faz sentido implementar? "Solicitações Pendentes" são as do próprio usuário ou as que ele aprova como administrador? Qual a diferença entre "Membro Ativo" e "Membro"? | pendente | — |
| L4 | "Ordenar por: Mais Ativos" (Figma): faz sentido implementar? Qual o critério de "mais ativo" e quais as outras opções? | pendente | — |
| L5 | Texto do cartão com solicitação pendente: o Figma usa o selo "AGUARDANDO MODERAÇÃO" (moderação lembra a plataforma), "Solicitação enviada há 2 dias" e "Aguardando Aprovação"; o `39` FA 1 diz "pendente de aprovação". Qual texto vale? | pendente | — |
| L6 | "<n> online" nos cartões (Figma): faz sentido implementar? Exige presença em tempo real (Socket.IO), que nenhum caso de uso descreve (mesma pergunta na L7 da CCD044) | pendente | — |
| L7 | Ícone de verificado ao lado do nome do grupo (Figma): faz sentido implementar? O DBML não tem a coluna nem a regra | pendente | — |
| L8 | Os cartões mostram a franquia ("Pokémon TCG • SP"), que o `escopo-adicional.md`, seção 3, tirou. O Figma é ajustado para mostrar só a cidade (se a L2 a aceitar) ou nada? | pendente | — |
| L9 | "Tópicos em Alta" (hashtags com contagem de posts nas últimas 24h) e "Buscas Recentes" (Figma): faz sentido implementar? Não há hashtag nem histórico de busca no DBML | pendente | — |
| L10 | "Diretrizes de Segurança" (Figma), com "Denunciar Grupo ou Spam" e "Ver Termos Completos": faz sentido implementar? Denunciar grupo não tem caso de uso e o `report_target_type` não tem `GROUP`. (proposta: o texto fixo e "Ver Termos Completos" levando aos Termos, EA-001-04; denunciar grupo fica fora) | pendente | — |
| L11 | Página do grupo antes de entrar (fundo do frame `675-17336`: "Solicitar entrada", "Restrito • requer aprovação", membros, online, "Sobre", "Administração", "Regras do grupo"): faz sentido implementar? O `39` FP 4–5 entra direto. Se sim, a página precisa de um frame próprio (hoje só aparece ao fundo do modal) | pendente | — |
| L12 | O compartilhamento está só na narrativa da user story; o `39` não tem o passo. Acrescentar ao caso de uso? Quem compartilha: qualquer membro, qualquer usuário logado ou só o administrador? | pendente | — |
| L13 | O link do Figma tem slug e código de convite (`/g/pokemon-tcg-sp?c=7KX2`), "Link expira em 7 dias" e "Entrar sem aprovação pelo link". O DBML não tem slug nem convite: faz sentido implementar? Se sim, é uma tabela nova (PR de docs no DER e ADR). (proposta: no MVP, o link fixo do grupo pelo id, sem prazo e sem entrada sem aprovação) | pendente | — |
| L14 | QR code com "Baixar QR Code" e os atalhos "WhatsApp", "Mensagem" (chat pessoal) e "E-mail" (Figma): faz sentido implementar? O projeto tirou o WhatsApp dos avisos (EA-053-01) | pendente | — |
| L15 | Solicitação repetida: o que acontece se já existe uma `PENDING` do mesmo usuário no grupo, se ele já é membro ou se a última foi recusada? (proposta: uma pendente por usuário e grupo, `409 JOIN_REQUEST_PENDING`; membro recebe `409 ALREADY_MEMBER`; recusada permite pedir de novo) | pendente | — |
| L16 | "Envia uma solicitação ao administrador" (`39` FA 1) gera aviso em `notifications` para os administradores do grupo? (proposta: sim, um aviso para cada `ADMIN` do grupo) | pendente | — |
| L17 | O botão só com ícone ao lado de "Criar grupo" (Figma `417-2915`) não tem rótulo nem caso de uso: o que ele faz? | pendente | — |
| L18 | Grupo advertido (`WARNED`, CCD099) continua no Explorar? O `62` FP 8 só tira o suspenso. (proposta: continua, sem selo para o cliente) | pendente | — |
| L19 | Estados de carregando e de erro da lista não estão desenhados (proposta: os componentes padrão do app) | pendente | — |
