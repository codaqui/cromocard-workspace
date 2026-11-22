# CCD040 — Denunciar Mensagem no Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #143 `CCD040 - Denunciar Mensagem no Grupo`
- **Caso de uso:** [40-denunciar-mensagem-no-grupo.md](../../docs/Casos-De-Uso/40-denunciar-mensagem-no-grupo.md)
- **Atores:** Cliente · **Pré-condições:** usuário autenticado e membro do grupo onde a mensagem foi enviada
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso poder reportar uma mensagem ofensiva ou spam dentro do grupo para que os administradores a avaliem e excluam.

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
| R1 | Denunciar exige login e ser membro do grupo da mensagem: sem token, `401`; quem não é membro, `403` | Permissão | `40`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O menu de ações de cada mensagem do grupo tem a opção "Denunciar Mensagem" | Ação | `40`, FP 1–2 |
| R3 | A opção abre o formulário de denúncia com os motivos spam, conteúdo ofensivo, golpe, assédio e outro | Tela | `40`, FP 3 (L1) |
| R4 | O motivo é obrigatório (um só) e a descrição é opcional, com até 500 caracteres | Campo | `40`, FP 4; DBML `reports.reason` (obrigatório), `reports.description` (`varchar(500)`) |
| R5 | Confirmar grava a denúncia em `reports` com `target_type = GROUP_MESSAGE`, `group_message_id`, `reporter_id`, `reason`, `description` e `status = PENDING` | Ação | `40`, FP 5–6; DBML `reports`; ADR-032 |
| R6 | Ao registrar, os administradores do grupo (`group_members.role = ADMIN`) recebem um aviso em `notifications` | Regra | `40`, FP 6; DBML `notifications` |
| R7 | A denúncia entra na fila de mensagens denunciadas da moderação da plataforma (CCD062), e a moderação é avisada | Regra | `40`, FP 6; `62`, FP 10–11 (L7) |
| R8 | Depois de registrar, a tela confirma que a denúncia foi registrada com sucesso | Mensagem | `40`, FP 7 (L6) |
| R9 | Cancelar antes de confirmar fecha o formulário, volta à tela do grupo e não grava nada | Ação | `40`, FA 1–2 |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`675-14942`, `675-16922`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2–R6, R8) — **Dado** um membro do grupo e uma mensagem de outro membro, **quando** ele abre o menu da
  mensagem, seleciona "Denunciar Mensagem", escolhe um motivo, escreve uma descrição e confirma, **então** a API grava
  `reports` com `target_type = GROUP_MESSAGE`, o `group_message_id`, o motivo, a descrição e `status = PENDING`, cada
  `ADMIN` do grupo recebe um aviso e a tela confirma o registro.
- **CA2** (R4) — **Dado** o formulário aberto, **quando** o membro confirma sem escolher motivo, **então** a tela indica
  que o motivo é obrigatório e nada é gravado; **quando** a descrição passa de 500 caracteres, **então** a API responde
  `400 VALIDATION_ERROR` e nada é gravado.
- **CA3** (R4) — **Dado** o formulário aberto, **quando** o membro escolhe um motivo e confirma sem descrição, **então**
  a denúncia é gravada com `description` nula.
- **CA4** (R7) — **Dado** uma denúncia registrada, **quando** o administrador da plataforma abre a fila de mensagens
  denunciadas da CCD062, **então** ela aparece como pendente, com o autor, o grupo, a mensagem, o motivo e quem denunciou.
- **CA5** (R9) — **Dado** o formulário preenchido, **quando** o membro seleciona "Cancelar" ou o "✕", **então** o
  formulário fecha, a tela do grupo continua e nenhuma linha é gravada em `reports`.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a denúncia, **então** a API responde `401`; **dado**
  um usuário logado que não é membro do grupo, **então** a API responde `403`.
- **CA7** (R10) — **Dado** o modal "Denunciar mensagem" aberto em 1280 px com os mesmos dados do frame, **quando** o
  print dele é comparado lado a lado com o print do frame `675-14942`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.
- **CA8** (R10) — Se a L9 decidir implementar a fila do grupo: **dado** a aba "Denúncias" aberta em 1280 px com os mesmos
  dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-16922`, **então** não há
  diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design
  se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reports` | `reporter_id`, `group_message_id`, `target_type` (`report_target_type`: `GROUP_MESSAGE`), `reason`, `description`, `status` (`report_status`: `PENDING`), `created_at` | `reason` obrigatório (`varchar(90)`); `description` opcional (`varchar(500)`); `status` default `PENDING`; sem `deleted_at` (ADR-015, item 4); alvo polimórfico, só `group_message_id` preenchido (ADR-032) |
| `group_messages` | `id`, `group_id`, `author_id`, `content`, `created_at`, `deleted_at` | a mensagem denunciada, citada no topo do modal |
| `group_members` | `group_id`, `user_id`, `role` (`member_role`: `ADMIN`), `deleted_at` | confere se quem denuncia é membro (R1) e acha os administradores do grupo (R6) |
| `notifications` | `user_id`, `title`, `message`, `type`, `reference_link` | aviso aos administradores do grupo (R6); `title` (120) e `message` (500) obrigatórios |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - denunciar mensagem | [675-14942](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-14942) | R3, R4, R5, R9 | ❌ Não bate: motivos diferentes (L1), "Ocultar esta mensagem para mim" (L3), aviso de anonimato (L4) |
| Comunidade - fila de denúncias do grupo | [675-16922](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-16922) | — | ❌ Só no Figma (L9, L10) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Denunciar mensagem — "Por que você está denunciando?": o frame tem "Golpe ou pagamento fora da plataforma", "Spam ou
    divulgação repetida", "Ofensa, assédio ou discurso de ódio", "Carta falsificada ou réplica" e "Outro motivo"; o `40`
    FP 3 pede spam, conteúdo ofensivo, golpe, assédio e outro (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Denunciar mensagem — chave "Ocultar esta mensagem para mim" com "Ela continua visível para os outros até a moderação
    decidir" (L3).
  - Denunciar mensagem — "Quem enviou não saberá quem denunciou." (L4).
  - Fila de denúncias do grupo — aba "Denúncias (3)" da administração do grupo, com os indicadores "Pendentes",
    "Resolvidas no mês", "Mensagens removidas", "Membros banidos", "Revisar em até 24h" e "Tempo médio: 2h", e um cartão por
    mensagem com o motivo, "<n> denúncias", "Conta nova", "Pendente", "Excluir mensagem", "Banir do grupo", "Ignorar
    denúncia" e "Ver no chat" (L9, L10).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R2 — o menu de ações da mensagem com "Denunciar Mensagem": o chat do grupo (`675-14037`) não desenha menu por mensagem
    (L5).
  - R8 — a confirmação de que a denúncia foi registrada (L6).
  - R4 — o estado de erro do formulário sem motivo.

## Fora do escopo

- Moderar as mensagens denunciadas pela plataforma (remover, advertir, dispensar, sancionar) — CCD062 e CCD099.
- Denunciar usuário, perfil ou anúncio — CCD047, CCD050 e CCD090.
- "Advertir usuário" na fila do grupo — `escopo-adicional.md`, seção 3 (a advertência é da plataforma, CCD099).
- Tela do grupo e chat — CCD044.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais motivos valem: os cinco do `40` FP 3 (spam, conteúdo ofensivo, golpe, assédio, outro) ou os cinco do Figma (golpe ou pagamento fora da plataforma; spam ou divulgação repetida; ofensa, assédio ou discurso de ódio; carta falsificada ou réplica; outro motivo)? O `reports.reason` guarda um código estável ou o texto? (proposta: os do Figma, com o caso de uso ajustado, gravando um código em inglês) | pendente | — |
| L2 | "Outro motivo" exige descrição? (proposta: sim) | pendente | — |
| L3 | "Ocultar esta mensagem para mim" (Figma): faz sentido implementar? O DBML não tem onde guardar a mensagem oculta por usuário | pendente | — |
| L4 | "Quem enviou não saberá quem denunciou." (Figma): vira regra (o autor nunca vê o `reporter_id`)? (proposta: sim; o caso de uso ganha a regra) | pendente | — |
| L5 | O menu de ações da mensagem (`40` FP 2) não está desenhado no chat do grupo (`675-14037`). Pedir o desenho ao Gabriel ou reaproveitar o "ações da mensagem" do chat pessoal (`1160-33616`)? | pendente | — |
| L6 | Texto e formato da confirmação (`40` FP 7) não estão desenhados (proposta: aviso "Denúncia enviada" no padrão do app) | pendente | — |
| L7 | Como a "equipe de moderação da plataforma" é notificada (`40` FP 6)? Só pela fila da CCD062 ou também com um aviso em `notifications` para cada `ADMIN`? | pendente | — |
| L8 | O membro pode denunciar a própria mensagem? Pode denunciar a mesma mensagem duas vezes? (proposta: não aos dois; `422 CANNOT_REPORT_OWN_MESSAGE` e `409 ALREADY_REPORTED`; vários membros podem denunciar a mesma mensagem, como o "3 denúncias" do Figma) | pendente | — |
| L9 | Fila de denúncias do grupo para o administrador do grupo (`675-16922`): faz sentido implementar? O `40` só notifica o administrador do grupo, mas a narrativa diz "para que os administradores a avaliem e excluam". Se sim: é desta story ou da CCD043? Como convive com a moderação da CCD062, se `reports` tem um só `moderator_id` e um só `status`? E os indicadores ("Resolvidas no mês", "Tempo médio", "Revisar em até 24h") e o selo "Conta nova", de onde vêm? | pendente | — |
| L10 | "Banir do grupo" (na fila e na lista de membros da CCD043): o DBML não tem banimento de grupo (mesma pergunta na L9 da CCD043) | pendente | — |
