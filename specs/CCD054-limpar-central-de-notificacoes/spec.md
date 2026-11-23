# CCD054 — Limpar Central de Notificações

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1308 `CCD054 - Limpar Central de Notificações` (criada em 22/11/2026)
- **Caso de uso:** [54-limpar-central-de-notificacoes.md](../../docs/Casos-De-Uso/54-limpar-central-de-notificacoes.md)
- **Atores:** Cliente · **Pré-condições:** autenticado, com notificações na central
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso um botão de "Marcar todas como lidas" para zerar rapidamente o contador de avisos do sistema.

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
| R1 | Só usuário autenticado limpa ou marca a própria central: `401` sem token; as notificações de outros usuários não mudam | Permissão | `54`, Pré-condições; ADR-005; ADR-011 |
| R2 | A central tem a opção "Limpar notificações" | Ação | `54`, FP 1–3 (L1) |
| R3 | "Limpar notificações" pede confirmação antes de remover | Ação | `54`, FP 4 (L3) |
| R4 | Confirmada a limpeza, as notificações do usuário saem da central: `deleted_at = now()` em cada uma (soft delete) | Regra | `54`, FP 5–6; ADR-015, item 1; DBML `notifications.deleted_at` (L2, L7) |
| R5 | Depois da limpeza, a central é atualizada e informa que foi limpa | Mensagem | `54`, FP 7 (L3) |
| R6 | Cancelar a confirmação mantém as notificações sem alteração | Ação | `54`, FA 1–2 |
| R7 | Sem notificações, a opção informa que a central já está vazia | Mensagem | `54`, FA 3 (L3) |
| R8 | "Marcar todas como lidas" marca todas as notificações do usuário como lidas (`is_read = true`) e zera o contador de não lidas | Ação | user story (narrativa) (L1) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** um cliente com 4 notificações, **quando** ele seleciona "Limpar notificações" e confirma, **então** as 4 ficam com `deleted_at` preenchido, a central fica vazia e mostra o aviso de central limpa.
- **CA2** (R6) — **Dado** a confirmação aberta, **quando** o cliente cancela, **então** as 4 notificações continuam na central, sem mudança no banco.
- **CA3** (R7) — **Dado** um cliente sem notificações, **quando** seleciona "Limpar notificações", **então** vê o aviso de que a central já está vazia e nada é gravado.
- **CA4** (R8) — **Dado** 5 notificações não lidas, **quando** o cliente seleciona "Marcar todas como lidas", **então** as 5 ficam com `is_read = true`, o contador do sino e o "Não Lidas" passam a 0 e a central mostra o estado sem não lidas.
- **CA5** (R1) — **Dado** uma chamada sem token, **quando** pede para limpar ou marcar todas como lidas, **então** recebe `401`; **dado** os clientes A e B com notificações, **quando** A limpa a central, **então** as notificações de B não mudam.
- **CA6** (R4, R8) — **Dado** a API falhando ao limpar ou marcar, **quando** o cliente confirma, **então** as notificações continuam como estavam e aparece um aviso de erro no estilo da tela.
- **CA7** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `490-796`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-11716`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-12111`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `notifications` | `user_id`, `is_read`, `deleted_at` | `is_read` default `false`; `deleted_at` nulo = na central (L2) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel principal de notificações | [490-796](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=490-796) | R8 | ❌ Tem "Marcar todas como lidas"; não tem "Limpar notificações" (L1) |
| Notificações — central com todas lidas | [675-11716](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-11716) | R8 | ⚠️ Aviso "5 notificações marcadas como lidas" com "Desfazer" (L4) e comportamento das lidas (L6) |
| Notificações — ações da notificação | [675-12111](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-12111) | R4 | ⚠️ Seleção e exclusão individual só no Figma (L5) |

- Textos: "Marcar todas como lidas" (botão do topo da página e do popup do sino), "5 notificações marcadas como lidas", "Desfazer", "0 Não Lidas", "Tudo em dia!", "Você não tem notificações não lidas. Avisaremos quando chegar algo novo.", "Configurar alertas"; na seleção, "2 notificações selecionadas", "Marcar como lidas", "Excluir", "Cancelar"; no menu ⋮, "Excluir notificação".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso pede "Limpar notificações" com confirmação e remoção; o Figma tem "Marcar todas como lidas", sem confirmação e sem remover (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Desfazer" no aviso (L4); seleção de várias notificações com "Marcar como lidas", "Excluir" e "Cancelar", e "Excluir notificação" no menu ⋮ (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 a opção "Limpar notificações"; R3 a confirmação; R5 o aviso de central limpa; R7 o aviso de central já vazia.

## Fora do escopo

- Ver, abrir e marcar uma notificação como lida ao selecioná-la; filtros; menu ⋮ — CCD053.
- A aba "Meus Favoritos" — CCD055, CCD056 e CCD057.
- "Configurar alertas" — CCD053 (R11).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O caso de uso pede "Limpar notificações" (remover, com confirmação); a user story e o Figma pedem "Marcar todas como lidas" (zerar o contador, sem remover). Vale um, o outro ou os dois? | pendente | — |
| L2 | O ADR-015 (item 4) diz que `notifications` nunca é excluída, mas o DBML tem `deleted_at` em `notifications` (ADR-016 pôs `deleted_at` em todas as tabelas). Remover da central é soft delete com `deleted_at`? (proposta: sim) | pendente | — |
| L3 | Textos da confirmação, do aviso de central limpa e do aviso de central já vazia: a documentação não define e o Figma não desenha | pendente | — |
| L4 | "Desfazer" no aviso "5 notificações marcadas como lidas" (só no Figma). Faz sentido implementar? | pendente | — |
| L5 | Seleção de várias notificações ("Marcar como lidas", "Excluir", "Cancelar") e "Excluir notificação" individual (só no Figma, `675-12111`). Faz sentido implementar? | pendente | — |
| L6 | Depois de marcar todas como lidas, o Figma (`675-11716`) tira as notificações de "HOJE" e mostra "Tudo em dia!", mas mantém as "ANTERIORES". As lidas somem da central ou só perdem o destaque? | pendente | — |
| L7 | Com um filtro aplicado (CCD053, L5), limpar ou marcar todas vale só para o filtro ou para a central inteira? (proposta: a central inteira) | pendente | — |
