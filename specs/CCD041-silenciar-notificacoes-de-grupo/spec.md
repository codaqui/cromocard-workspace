# CCD041 — Silenciar Notificações de Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #144 `CCD041 - Silenciar Notificações de Grupo`
- **Caso de uso:** [41-silenciar-notificacoes-de-grupo.md](../../docs/Casos-De-Uso/41-silenciar-notificacoes-de-grupo.md)
- **Atores:** Cliente · **Pré-condições:** usuário autenticado e membro do grupo que deseja silenciar
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso silenciar temporariamente um grupo muito ativo para não receber alertas dele a todo momento.

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
| R1 | Silenciar e reativar exige login e ser membro do grupo: sem token, `401`; quem não é membro, `403` | Permissão | `41`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | As opções do grupo, na tela do grupo, têm "Silenciar Notificações" | Ação | `41`, FP 1–2 |
| R3 | A opção mostra os períodos 8 horas, 1 semana e até eu reativar | Tela | `41`, FP 3 (L1) |
| R4 | Escolher o período grava em `group_members.muted_until` o fim do silêncio do membro | Regra | `41`, FP 4–5; DBML `group_members.muted_until` (L2) |
| R5 | Enquanto `muted_until` estiver no futuro, o grupo não gera alertas de novas mensagens e atividades para esse membro | Regra | `41`, Finalidade e FP 5 (L5, L8) |
| R6 | Passado o período, os alertas voltam sozinhos, sem ação do membro | Regra | `41`, FP 5 ("pelo período selecionado") |
| R7 | O grupo silenciado mostra um indicador visual de silenciado | Estado | `41`, FP 5 (L6) |
| R8 | Com o grupo silenciado, as opções do grupo têm "Reativar Notificações", que limpa `muted_until` na hora e tira o indicador | Ação | `41`, FA 1–2 |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`675-15445`, `675-14037`, `417-2915`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2–R5, R7) — **Dado** um membro com o grupo sem silêncio, **quando** ele abre as opções do grupo, seleciona
  "Silenciar Notificações" e escolhe 8 horas, **então** `muted_until` fica em agora + 8 horas, o indicador de silenciado
  aparece e uma mensagem nova no grupo não gera aviso para ele em `notifications`.
- **CA2** (R4) — **Dado** o modal aberto, **quando** o membro escolhe 1 semana, **então** `muted_until` fica em agora + 7
  dias; **quando** escolhe "Até eu reativar", **então** o grupo fica silenciado sem prazo, como a L2 decidir.
- **CA3** (R6) — **Dado** um grupo silenciado por 8 horas, **quando** o prazo passa e chega uma mensagem nova, **então** o
  membro recebe o aviso e o indicador de silenciado some.
- **CA4** (R8) — **Dado** um grupo silenciado, **quando** o membro seleciona "Reativar Notificações", **então**
  `muted_until` volta a nulo, o indicador some e a próxima mensagem gera aviso.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama silenciar, **então** a API responde `401`; **dado** um
  usuário logado que não é membro, **então** a API responde `403`.
- **CA6** (R9) — **Dado** o modal "Silenciar grupo" aberto em 1280 px com os mesmos dados do frame, **quando** o print
  dele é comparado lado a lado com o print do frame `675-15445`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.
- **CA7** (R9) — **Dado** a tela do grupo aberta em 1280 px, **quando** o print do topo do chat (ícone do sino) é
  comparado lado a lado com o do frame `675-14037`, **então** não há diferença; e em 375, 768 e 1024 px o mesmo design se
  adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R7, R9) — **Dado** a seção "Meus grupos" aberta em 1280 px com um grupo silenciado, **quando** o print do
  cartão é comparado lado a lado com o cartão "Figurinhas Panini" do frame `417-2915` (sino cortado), **então** não há
  diferença; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `group_members` | `group_id`, `user_id`, `muted_until`, `deleted_at` | `muted_until` opcional (nulo = não silenciado), nota "Silenciar notificacoes do grupo"; `(group_id, user_id)` único |
| `notifications` | `user_id`, `type` | os avisos do grupo deixam de ser criados para o membro silenciado (R5) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - silenciar grupo | [675-15445](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-15445) | R3, R4, R5 | ❌ Não bate: "1 hora" (L1), "Mesmo silenciado, me avise sobre" (L3), mensagens por dia (L4), texto sobre o que pausa (L5), Cancelar (L10) |
| Comunidade - chat do grupo (sino no topo) | [675-14037](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-14037) | R2 | ⚠️ O sino abre o modal; falta o estado silenciado com "Reativar Notificações" (L6, L7) |
| Comunidade - Pagina principal (cartões de "Meus grupos") | [417-2915](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=417-2915) | R7 | ✅ O sino cortado no cartão marca o grupo silenciado |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Silenciar grupo — "Silenciar por": o frame tem "1 hora", "8 horas", "1 semana" e "Até eu reativar"; o `41` FP 3 pede
    8 horas, 1 semana e até eu reativar (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Silenciar grupo — "Mesmo silenciado, me avise sobre", com "Menções a mim (@gabriel12) — Quando alguém citar você" e
    "Respostas às minhas mensagens — Replies diretos" (L3).
  - Silenciar grupo — subtítulo "<grupo> • cerca de 340 mensagens por dia" (L4).
  - Silenciar grupo — "As mensagens continuam chegando no grupo. Só os alertas do sino ficam pausados até 23:12." e o
    botão "Silenciar por 8 horas", que muda com o período (L5, L9).
  - Silenciar grupo — "Cancelar" e "✕" (L10).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R7 — o indicador de silenciado na tela do grupo (o frame `675-14037` só mostra o sino normal) (L6).
  - R8 — "Reativar Notificações" nas opções do grupo silenciado (L7).

## Fora do escopo

- Preferências gerais de aviso por tipo ("grupos", no site e por e-mail) — CCD053 (EA-053-01).
- "Silenciado" e "Notificações ativas" na lista de grupos favoritos (`675-11250`) — CCD057.
- Push no celular — não existe (ADR-058).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O período "1 hora" só existe no Figma: faz sentido implementar? (proposta: sim, com o `41` FP 3 ajustado) | pendente | — |
| L2 | Como gravar "Até eu reativar" num `muted_until` do tipo `timestamptz`? (proposta: uma data distante fixa, documentada num ADR, sem coluna nova) | pendente | — |
| L3 | "Mesmo silenciado, me avise sobre" com menções e respostas (Figma): faz sentido implementar? Menção (@) não existe em nenhum caso de uso e o DBML não tem onde guardar as duas escolhas | pendente | — |
| L4 | "cerca de 340 mensagens por dia" no subtítulo (Figma): faz sentido implementar? Qual o cálculo (média de quantos dias)? | pendente | — |
| L5 | O que o silêncio pausa? O Figma diz "Só os alertas do sino ficam pausados"; o `41` diz "alertas de novas mensagens e atividades". Também pausa o e-mail do tipo "grupos" (EA-053-01)? (proposta: pausa o sino e o e-mail desse grupo; as mensagens continuam no chat) | pendente | — |
| L6 | Onde fica o indicador de silenciado na tela do grupo? O frame `675-14037` não desenha o estado silenciado (proposta: o sino cortado no topo do chat, como no cartão de `417-2915`; pedir o frame) | pendente | — |
| L7 | "Reativar Notificações" (`41` FA 1) não está desenhado: é o mesmo sino abrindo um modal com "Reativar" ou uma opção do menu "⋯"? | pendente | — |
| L8 | Como o silêncio do grupo convive com a preferência geral "grupos" da CCD053? (proposta: o aviso só sai se a preferência estiver ligada e o grupo não estiver silenciado) | pendente | — |
| L9 | Texto do botão de confirmar para "Até eu reativar" e para "1 semana" (o Figma só mostra "Silenciar por 8 horas"). (proposta: "Silenciar por 1 semana" e "Silenciar até eu reativar") | pendente | — |
| L10 | "Cancelar" e "✕" (Figma) fecham sem mudar nada? (proposta: sim) | pendente | — |
| L11 | Quem sai do grupo e volta (linha restaurada, ADR-015, item 7) mantém o silêncio antigo? (proposta: não; `muted_until` volta a nulo ao restaurar) | pendente | — |
