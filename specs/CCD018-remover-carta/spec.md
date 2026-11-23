# CCD018 — Remover Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #124 `CCD018 -Remover Carta`
- **Caso de uso:** [18-remover-carta.md](../../docs/Casos-De-Uso/18-remover-carta.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com a carta na sua coleção
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso remover uma carta da minha coleção para manter meus registros atualizados.

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
| R1 | Remover exige login e só vale para carta da coleção do próprio cliente: sem token, a API responde `401` | Permissão | `18`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | Cada carta tem o botão de diminuir a quantidade ("−") e a opção "Remover" (qual elemento é o "Remover": L2) | Ação | `18`, FP 1 |
| R3 | A API subtrai a quantidade informada de `collection_cards.quantity` (quanto cada ação tira: L3) | Regra | `18`, FP 2 |
| R4 | Quando a quantidade chega a zero, o status da carta passa a Faltante (`MISSING`) | Regra | `18`, FP 3 |
| R5 | Depois da remoção, a carta e o progresso do álbum (`user_albums.progress_percentage`) são atualizados na tela | Regra | `18`, FP 4; `19`, FP 2 |
| R6 | Com a quantidade já em zero, a ação de remover fica desabilitada (ou um aviso diz que ela não é possível: L5); a API responde `422` | Estado | `18`, FA 1–2; ADR-011 |
| R7 | Se a API falha ao salvar, a tela mostra a mensagem de erro da API e a quantidade anterior continua | Estado | ADR-041, Erros |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-23696`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5) — **Dado** uma carta com "Qtd: 3", **quando** o cliente seleciona "−", **então** a API grava `quantity = 2` e a carta mostra "Qtd: 2".
- **CA2** (R3, R4, R5) — **Dado** uma carta possuída com "Qtd: 1" num álbum de 54 cartas com 44 possuídas, **quando** o cliente seleciona "−", **então** a API grava `quantity = 0` e status `MISSING`, a carta aparece como faltante e o progresso do álbum cai para 79,63%.
- **CA3** (R2, R3, R4) — **Dado** uma carta com "Qtd: 3", **quando** o cliente usa "Remover" e confirma, **então** a carta fica faltante com quantidade 0 (conforme a decisão da L3).
- **CA4** (R6) — **Dado** uma carta com "Qtd: 0", **quando** o cliente olha o controle, **então** o "−" está desabilitado; a API, chamada para remover, responde `422`.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama a API de remoção, **então** recebe `401`; **dado** uma carta que não está na coleção do cliente, **quando** ele tenta removê-la, **então** nenhuma coleção muda.
- **CA6** (R7) — **Dado** a API fora do ar, **quando** o cliente seleciona "−", **então** vê a mensagem de erro e a quantidade anterior continua.
- **CA7** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem no "−" (normal e desabilitado em "Qtd: 0") e no ícone de lixeira do cartão; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `quantity` obrigatória, default 1; zerar muda o status para `MISSING` e mantém a linha (L6) |
| `user_albums` | `album_id`, `progress_percentage` | recalculado (R5) |
| `albums` | `total_cards` | denominador do progresso |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R6, R8 | ❌ Não bate: não há botão "Remover"; há um ícone de lixeira sem texto no canto do cartão (L2) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso pede o "−" ou "Remover"; o frame tem o "−" e um ícone de lixeira no canto de cada cartão, sem rótulo e sem modal (L2).
- **Só no Figma**: ícone de lixeira (L2).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - Confirmação do "Remover", se decidida (L4).
  - R7 mensagem de erro ao salvar.
- O "−" desabilitado em "Qtd: 0" (carta faltante) bate com o FA 1–2.

## Fora do escopo

- Aumentar a quantidade ("+") — CCD017.
- Marcar Faltante pelo marcador "Falta" — spec CCD014 (CCD015).
- Remover o álbum inteiro da coleção — CCD011.
- Zerar todas as marcações do álbum — CCD035.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` remove cartas pelo Painel Cliente? (proposta: não, `403`, como na CCD007, L1) | pendente | — |
| L2 | O ícone de lixeira no canto do cartão (só no Figma, sem rótulo) é o "Remover" do caso de uso? (proposta: sim, com o texto de ajuda "Remover da coleção" ao passar o mouse) | pendente | — |
| L3 | "Subtrai a quantidade informada": o "−" tira 1 e o "Remover" tira todas as unidades? (proposta: sim; o "Remover" zera a quantidade e marca a carta como faltante) | pendente | — |
| L4 | O "Remover" pede confirmação? O Figma não tem o modal. (proposta: sim, um modal no estilo de "Remover o álbum da sua coleção?", `1160-27915`: "Remover <carta> da sua coleção?", "Cancelar" e "Remover carta"; o Gabriel desenha) | pendente | — |
| L5 | Com quantidade zero: o caso de uso aceita ação desabilitada ou aviso; o Figma desenha o "−" desabilitado. E a lixeira numa carta já faltante? (proposta: os dois desabilitados, sem aviso) | pendente | — |
| L6 | O ADR-015 cita a CCD018 entre as exclusões com `deleted_at`, mas o caso de uso muda o status para Faltante (FP 3). Remover a carta preenche `deleted_at` ou só grava `MISSING` com 0? (proposta: segue o caso de uso: `MISSING` com quantidade 0, sem `deleted_at`; a citação do ADR-015 é revista num ADR novo) | pendente | — |
| L7 | Descer de 2 para 1 unidade volta a carta de Repetida para Possuo? (proposta: sim, a regra da CCD014, L4) | pendente | — |
