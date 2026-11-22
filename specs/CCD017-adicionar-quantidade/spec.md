# CCD017 — Adicionar Quantidade

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #123 `CCD017 -Adicionar Quantidade`
- **Caso de uso:** [17-adicionar-quantidade.md](../../docs/Casos-De-Uso/17-adicionar-quantidade.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e acessando o gerenciamento da sua coleção
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso adicionar a quantidade de uma carta para registrar quantas unidades possuo.

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
| R1 | Alterar a quantidade exige login e só vale para a coleção do próprio cliente: sem token, a API responde `401` | Permissão | `17`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | Cada carta tem o botão de aumentar a quantidade ("+") | Ação | `17`, FP 1 |
| R3 | O "+" atualiza no banco a quantidade registrada da carta (`collection_cards.quantity`) (efeito no status: L2) | Regra | `17`, FP 2 |
| R4 | A carta mostra o novo valor numérico logo depois | Tela | `17`, FP 3 |
| R5 | Valor manual inválido é bloqueado: nada é salvo e a tela mostra um alerta de valor incorreto (o que é inválido e o texto: L4); a API responde `400 VALIDATION_ERROR` a um valor inválido | Regra | `17`, FA 1–2; ADR-011 |
| R6 | Se a API falha ao salvar, a tela mostra a mensagem de erro da API e a quantidade anterior continua | Estado | ADR-041, Erros |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-23696`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** uma carta possuída com "Qtd: 1", **quando** o cliente seleciona "+", **então** a API grava `quantity = 2` e a carta mostra "Qtd: 2".
- **CA2** (R5) — **Dado** uma carta com quantidade 3, **quando** o cliente informa manualmente um valor inválido (por exemplo, "-1" ou "abc"), **então** nada é salvo, a quantidade continua 3 e a tela mostra o alerta de valor incorreto; a API, chamada com o valor inválido, responde `400 VALIDATION_ERROR`.
- **CA3** (R1) — **Dado** um visitante sem login, **quando** chama a API de quantidade, **então** recebe `401`; **dado** uma carta da coleção de outro cliente, **quando** o cliente tenta alterá-la, **então** a coleção do outro não muda.
- **CA4** (R6) — **Dado** a API fora do ar, **quando** o cliente seleciona "+", **então** vê a mensagem de erro e a quantidade anterior continua na carta.
- **CA5** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem no controle "Qtd:" com "−", o número e "+" (normal e desabilitado); e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `quantity` `integer`, obrigatória, default 1; único por (`collection_id`, `card_id`) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R4, R7 | ✅ Bate no "+" e no número ("Qtd:", "−", valor, "+"); a entrada manual do FA não está desenhada (L4) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso fala em valor manual (FA 1); no frame, o número entre "−" e "+" não parece editável (L4).
- **Só no Figma**: nada.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R5 alerta de valor incorreto (L4).
  - R6 mensagem de erro ao salvar.

## Fora do escopo

- Diminuir a quantidade ("−") — CCD018.
- Marcar Possuo, Falta ou Repetida — spec CCD014 (CCD014, CCD015 e CCD016).
- Contador de repetidas do álbum ("REPETIDAS <n> a mais") — CCD019.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` altera quantidades pelo Painel Cliente? (proposta: não, `403`, como na CCD007, L1) | pendente | — |
| L2 | Passar de 1 para 2 unidades muda o status para `DUPLICATE` (selo "<n> REPETIDAS")? Voltar a 1 pelo "−" é da CCD018. (proposta: sim, a regra da CCD014, L4: 2 ou mais unidades = repetida) | pendente | — |
| L3 | O "+" funciona numa carta faltante (quantidade 0)? No frame, o "+" da carta faltante parece apagado. (proposta: desabilitado em carta faltante; o cliente marca "Possuo" antes) | pendente | — |
| L4 | O número é editável? O que é um valor inválido (negativo, zero, decimal, texto, acima de um máximo)? Qual é o texto do alerta? (proposta: campo numérico editável ao clicar no número; inteiro de 1 a 999; alerta "Informe um número inteiro de 1 a 999." abaixo do controle; o Gabriel desenha o estado de erro) | pendente | — |
| L5 | "Gerenciamento da sua coleção": o controle de quantidade fica só no detalhe do álbum? (proposta: sim, como no Figma) | pendente | — |
