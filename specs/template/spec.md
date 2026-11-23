# CCDnnn — <Nome do caso de uso>

- **Status:** Rascunho
- **Fase:** MVP | Futuro | Futuro Marketplace | Escopo Adicional
- **User story:** #<id> `CCDnnn - <Nome>` <!-- ou: não encontrada no board -->
- **Caso de uso:** [NN-<nome>.md](../../docs/Casos-De-Uso/NN-<nome>.md)
- **Atores:** <…> · **Pré-condições:** <…>
- **Data:** AAAA-MM-DD · **Autor:** <nome>
- **Aprovação:** — <!-- AAAA-MM-DD, <quem> (PO) -->

## Objetivo

> <narrativa da user story, copiada de `docs/Casos-De-Uso/user-stories.md`>

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
| R1 | <uma frase verificável> | Ação | `NN-<nome>.md`, FP 1 |
| R<n> | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R1, R2) — **Dado** <contexto>, **quando** <ação>, **então** <resultado observável>.
- **CA<n>** (R<n> de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame,
  **quando** o print dela é comparado lado a lado com o print do frame `<node-id>`, **então** não há diferença de layout,
  medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal. <!-- um CA de fidelidade por tela/estado desenhado -->

<!-- Um critério para o fluxo principal, um para cada fluxo alternativo, os de permissão e de estado (vazio, erro, carregando) e um de fidelidade ao Figma para cada frame. -->

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `<tabela>` | `<coluna>`, `<enum>` | <regra do DBML: obrigatória, única, default> |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| <nome do frame> | [<node-id>](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=<node-id>) | R1, R3 | ✅ Bate · ❌ Não bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): <tela> — "<elemento>": mostra <X>; a documentação pede <Y> (L<n>).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): <tela> — "<elemento>" (L<n>).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R<n> <requisito>.

## Fora do escopo

- <elemento ou comportamento> — pertence a <CCDnnn | fase Futuro> | não está na documentação.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | <o que a documentação não diz> | pendente | — |

<!-- Spec com lacuna pendente não é aprovada. Regra de negócio decidida vai para o caso de uso; decisão técnica, para um ADR. -->
