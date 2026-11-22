# CCD043 — Criar e Administrar Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #146 `CCD043 - Criar e Administrar Grupo`
- **Caso de uso:** [43-criar-e-administrar-grupo.md](../../docs/Casos-De-Uso/43-criar-e-administrar-grupo.md)
- **Atores:** Cliente (Administrador do Grupo) · **Pré-condições:** usuário autenticado; para administrar, ser administrador do grupo
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso criar um grupo, administrar seus membros e fixar mensagens importantes.

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
| R1 | Criar grupo exige login (sem token, `401`). Administrar exige ser `ADMIN` do grupo em `group_members`: outro membro ou usuário recebe `403` | Permissão | `43`, Atores e Pré-condições; DBML `member_role`; ADR-005, item 4; ADR-011 |
| R2 | "Criar grupo", na tela de grupos, abre o formulário de criação | Ação | `43`, FP 1 |
| R3 | Nome do grupo: obrigatório, até 120 caracteres | Campo | `43`, FP 2 e FA 1; DBML `groups.name` (`varchar(120)`, obrigatório) |
| R4 | Descrição: opcional | Campo | `43`, FP 2; DBML `groups.description` (L2) |
| R5 | Imagem de capa: opcional, enviada pelo upload de imagens | Campo | `43`, FP 2; DBML `groups.cover_image_url`; ADR-050, item 1 (L4) |
| R6 | Tipo de acesso: aberto (`OPEN`) ou fechado (`CLOSED`), obrigatório | Campo | `43`, FP 2 e FA 1; DBML `groups.access_type` (L7) |
| R7 | Sem nome ou sem tipo de acesso, a tela mostra as mensagens de validação e não cria o grupo até a correção | Mensagem | `43`, FA 1 |
| R8 | Confirmar cria o grupo (`creator_id` = quem criou, `status = ACTIVE`), grava o criador em `group_members` com `role = ADMIN` e abre a tela do grupo criado | Ação | `43`, FP 3–4; DBML `groups`, `group_members` |
| R9 | O administrador vê as solicitações de entrada pendentes e aprova ou recusa cada uma: grava `status` (`APPROVED` ou `REJECTED`), `reviewed_by_id` e `reviewed_at`; aprovar torna o solicitante membro (`MEMBER`), restaurando a linha se ele já foi membro | Ação | `43`, FP 5; DBML `group_join_requests`; ADR-015, item 7 |
| R10 | O administrador remove um membro: a linha de `group_members` recebe `deleted_at` | Ação | `43`, FP 5; ADR-015, item 1 (L12) |
| R11 | O administrador promove um membro a administrador (`role = ADMIN`) | Ação | `43`, FP 5 (L13) |
| R12 | O administrador edita as informações do grupo: nome, descrição, capa e tipo de acesso, com as mesmas validações da criação | Ação | `43`, FP 5 (L14) |
| R13 | O administrador exclui o grupo depois de confirmar: `groups.deleted_at` é preenchido e o grupo some para todos | Ação | `43`, FP 5 e FA 2; ADR-015, itens 1 e 6; `62`, FP 8 (L21) |
| R14 | O administrador fixa e desafixa mensagens importantes do grupo (`group_messages.pinned`) | Ação | `user-stories.md`, seção 4, "Criar e Administrar Grupo"; DBML `group_messages.pinned` (L15) |
| R15 | As opções de administração ficam na página de administração do grupo: solicitações de entrada com "Aprovar" e "Recusar" e a lista de membros com função, data de entrada e "Remover" | Tela | `43`, FP 5 |
| R16 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`417-2581`, `675-16465`, `417-2915`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2–R6, R8) — **Dado** um cliente logado, **quando** ele seleciona "Criar grupo", preenche nome, descrição,
  capa e tipo fechado e confirma, **então** a API grava `groups` com `creator_id` dele, `access_type = CLOSED` e
  `status = ACTIVE`, grava `group_members` com `role = ADMIN` e a tela do grupo criado abre.
- **CA2** (R3, R6, R7) — **Dado** o formulário sem nome ou sem tipo de acesso, **quando** o cliente confirma, **então** a
  tela mostra a mensagem de validação no campo e nada é gravado; a API responde `422` se for chamada assim.
- **CA3** (R9) — **Dado** um grupo fechado com uma solicitação pendente, **quando** o administrador seleciona "Aprovar",
  **então** a solicitação fica `APPROVED` com `reviewed_by_id` e `reviewed_at`, o solicitante vira `MEMBER` e some da
  lista de solicitações.
- **CA4** (R9) — **Dado** uma solicitação pendente, **quando** o administrador seleciona "Recusar", **então** ela fica
  `REJECTED` com `reviewed_by_id` e `reviewed_at` e o solicitante não vira membro.
- **CA5** (R10) — **Dado** um membro do grupo, **quando** o administrador seleciona "Remover", **então** a linha de
  `group_members` recebe `deleted_at` e o membro sai da lista e perde o acesso ao chat.
- **CA6** (R11) — **Dado** um `MEMBER`, **quando** o administrador muda a função dele para administrador, **então**
  `role` passa a `ADMIN` e ele ganha as opções de administração.
- **CA7** (R12) — **Dado** um grupo, **quando** o administrador muda o nome e o tipo de acesso e salva, **então** os
  dados são gravados e a tela do grupo mostra os novos; sem nome, a validação do CA2 vale.
- **CA8** (R13) — **Dado** um grupo, **quando** o administrador pede para excluir, **então** a tela pede confirmação;
  **quando** ele confirma, **então** `groups.deleted_at` é preenchido e o grupo some da lista, da busca e do chat de
  todos; **quando** cancela, **então** nada muda.
- **CA9** (R14) — **Dado** uma mensagem do grupo, **quando** o administrador a fixa, **então** `pinned` fica `true` e ela
  aparece no indicador de fixada do topo do chat (CCD044); **quando** desafixa, **então** `pinned` volta a `false`.
- **CA10** (R1) — **Dado** um visitante sem login, **quando** tenta criar um grupo, **então** a API responde `401`;
  **dado** um `MEMBER`, **quando** chama aprovar, remover, promover, editar, excluir ou fixar, **então** a API responde
  `403`.
- **CA11** (R16) — **Dado** o formulário "Criar grupo" aberto em 1280 px com os mesmos dados do frame, **quando** o
  print dele é comparado lado a lado com o print do frame `417-2581`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.
- **CA12** (R16) — **Dado** a página de administração do grupo, aba "Solicitações", aberta em 1280 px com os mesmos
  dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-16465`, **então** não há
  diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design
  se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R16) — **Dado** a página "Comunidades" em 1280 px, **quando** o print do cartão "Crie seu grupo de graça"
  com o botão "Criar grupo" é comparado lado a lado com o do frame `417-2915`, **então** não há diferença; e em 375, 768
  e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `groups` | `id`, `creator_id`, `name`, `description`, `cover_image_url`, `access_type` (`group_access_type`: `OPEN`, `CLOSED`), `status` (`group_status`: `ACTIVE`), `created_at`, `deleted_at` | `creator_id`, `name` (120) e `access_type` obrigatórios; `status` default `ACTIVE`; soft delete (ADR-015) |
| `group_members` | `group_id`, `user_id`, `role` (`member_role`: `MEMBER`, `ADMIN`), `created_at`, `deleted_at` | `(group_id, user_id)` único; `role` default `MEMBER`; re-adicionar restaura (ADR-015, item 7) |
| `group_join_requests` | `group_id`, `user_id`, `status` (`request_status`: `PENDING`, `APPROVED`, `REJECTED`), `reviewed_by_id`, `reviewed_at`, `created_at` | `status` default `PENDING` |
| `group_messages` | `id`, `group_id`, `pinned` | `pinned` obrigatório, default `false` |
| `profiles` | `city`, `avatar_url` | cidade e avatar do solicitante na lista de solicitações |
| `users` | `name`, `username` | nome dos membros e solicitantes |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - Criação de grupos | [417-2581](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=417-2581) | R2–R6, R8 | ❌ Não bate: etapas (L1), sem descrição (L2), foto do grupo (L3), limites da capa (L4), cidade (L5), regras (L6), "Pública" já marcada (L7) |
| Comunidade - membros e solicitações | [675-16465](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-16465) | R9–R11, R15 | ❌ Não bate: papel "Moderador" (L8), "Banir" (L9), "Convidar membros" (L10), texto do solicitante (L11), online e visto por último (L16, L17), busca de membro (L18) |
| Comunidade - Pagina principal (cartão "Crie seu grupo de graça") | [417-2915](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=417-2915) | R2 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Criação de grupos — o formulário não tem o campo descrição, que o `43` FP 2 pede (L2).
  - Criação de grupos — a capa diz "Recomendado: 1200x400 JPG ou WebP até 5MB"; o ADR-050 aceita PNG, JPG ou WEBP até 4 MB (L4).
  - Criação de grupos — "Pública" aparece marcada, com o selo "RECOMENDADO"; o `43` FA 1 trata o tipo como obrigatório (L7).
  - Membros e solicitações — o seletor de função tem "Admin", "Moderador" e "Membro"; o `member_role` só tem `MEMBER` e `ADMIN` (L8).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Criação de grupos — etapas "1 Identificação", "2 Privacidade" e "3 Diretrizes" (L1).
  - Criação de grupos — "Foto do grupo" com "Alterar Ícone" e "PNG, SVG (512x512)" (L3).
  - Criação de grupos — "Tag de Localidade / Cidade (Opcional)" (L5) e "Regras do grupo" (L6).
  - Membros e solicitações — "Banir" (L9), "Convidar membros" (L10), o texto de apresentação de cada solicitante (L11),
    "Online", "Visto há 10 min" e "3 denúncias" na coluna Membro (L17), "Buscar membro..." (L18).
  - Membros e solicitações — cabeçalho "184 membros • 28 online • criado em 03/2025 • 2 admins, 3 moderadores", "Você é
    Admin", "Abrir chat" e "Configurações do grupo" (L16).
  - Membros e solicitações — abas "Denúncias (3)" (CCD040, L9 de lá) e "Mensagens fixadas (3)" (L15).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R7 — o formulário com as mensagens de validação.
  - R12 — a tela de editar o grupo ("Configurações do grupo" existe, mas não tem frame) (L14).
  - R13 — a confirmação de exclusão (L14, L21).
  - R14 — a ação de fixar e desafixar e a lista das fixadas (L15).

## Fora do escopo

- Listar, buscar e entrar em grupos e compartilhar o link — CCD039.
- Fila de denúncias do grupo (aba "Denúncias") — CCD040 (L9 de lá).
- Chat do grupo e o indicador de fixada — CCD044.
- Suspender, advertir e excluir grupos pela plataforma — CCD062 e CCD099.
- Franquia ou categoria do grupo e "guilda" — `escopo-adicional.md`, seção 3.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma mostra as etapas "Identificação", "Privacidade" e "Diretrizes", mas todos os campos numa tela só com "Criar grupo →". É um passo a passo ou um formulário único? (proposta: formulário único, com as etapas só como guia visual, como no frame) | pendente | — |
| L2 | O `43` FP 2 pede descrição e o formulário do Figma não tem o campo. O Gabriel acrescenta o campo ao frame? | pendente | — |
| L3 | "Foto do grupo" (ícone, "PNG, SVG (512x512)") além da capa: faz sentido implementar? O DBML só tem `cover_image_url`, e o ADR-050 não aceita SVG | pendente | — |
| L4 | Limites da capa: "JPG ou WebP até 5MB" (Figma) ou PNG, JPG ou WEBP até 4 MB (ADR-050)? (proposta: o ADR-050, com o texto do frame ajustado) | pendente | — |
| L5 | "Tag de Localidade / Cidade (Opcional)": faz sentido implementar? O DBML `groups` não tem cidade; liga à busca por cidade da CCD039 (L2 de lá). Se sim, coluna nova (PR de docs no DER e ADR) | pendente | — |
| L6 | "Regras do grupo" (texto com regras padrão): faz sentido implementar? O DBML não tem a coluna; as regras aparecem também em "Regras" no chat (CCD044) e no fundo de `675-17336`, e a FA 2 da CCD044 fala em "regras do grupo" | pendente | — |
| L7 | O tipo de acesso começa marcado em "Pública" (Figma) ou vazio, para a validação da FA 1 ter efeito? | pendente | — |
| L8 | Papel "Moderador" (Figma: seletor de função e "2 admins, 3 moderadores"): faz sentido implementar? O `member_role` só tem `MEMBER` e `ADMIN`; o que o moderador pode fazer? | pendente | — |
| L9 | "Banir" ao lado de "Remover" (Figma): faz sentido implementar? O DBML não tem banimento de grupo; banido não pode voltar nem pedir entrada? | pendente | — |
| L10 | "Convidar membros" (Figma): faz sentido implementar? Não há caso de uso nem tabela de convite; liga ao convite da CCD039 (L13 de lá) | pendente | — |
| L11 | Texto de apresentação do solicitante (“Coleciono slabs Pokémon há 6 anos…”) no Figma: o `group_join_requests` não tem a coluna e o pedido da CCD039 não pede texto. Faz sentido implementar? | pendente | — |
| L12 | O administrador pode remover outro administrador ou o criador? O grupo pode ficar sem administrador? O administrador pode sair do grupo? (proposta: o grupo sempre mantém pelo menos um `ADMIN`; o criador não é removido) | pendente | — |
| L13 | O seletor de função também permite rebaixar um administrador a membro; o `43` só fala em promover. Pode rebaixar? | pendente | — |
| L14 | A tela de editar o grupo e a confirmação de exclusão (`43` FP 5 e FA 2) não estão desenhadas. Pedir os frames ao Gabriel? | pendente | — |
| L15 | Fixar mensagem: o `43` não tem o passo (só a narrativa). Onde o administrador fixa (menu de ações da mensagem, que não está desenhado, L5 da CCD040)? Quantas podem ficar fixadas ("Ver fixadas (3)")? O "FIXADA POR @ADMIN_SP" do chat exige guardar quem fixou, e `pinned` é só booleano. A aba "Mensagens fixadas (3)" não tem frame próprio | pendente | — |
| L16 | Cabeçalho da administração: "28 online" (presença, L7 da CCD044), "2 admins, 3 moderadores" (L8), "criado em 03/2025", "Você é Admin" e "Abrir chat". Faz sentido implementar o que não depende de outra lacuna? (proposta: sim, com os dados de `groups.created_at` e `group_members`) | pendente | — |
| L17 | Coluna Membro com "Online", "Visto há 10 min" e "3 denúncias" (Figma): presença e último acesso não estão no DBML; a contagem de denúncias vem de `reports`. Faz sentido implementar? | pendente | — |
| L18 | "Buscar membro..." (Figma): faz sentido implementar? A lista de membros é paginada? | pendente | — |
| L19 | O solicitante é avisado da aprovação ou da recusa (`notifications`, CCD053 cita "convites para grupos")? O membro removido é avisado? | pendente | — |
| L20 | Mensagem de sucesso ao criar, editar e excluir não está documentada nem desenhada (proposta: aviso no padrão do app) | pendente | — |
| L21 | O `43` FA 2 diz "exclusão definitiva"; o ADR-015 manda soft delete. (proposta: definitiva para o usuário, que não vê mais o grupo; no banco, `deleted_at`, sem restaurar pela tela) | pendente | — |
