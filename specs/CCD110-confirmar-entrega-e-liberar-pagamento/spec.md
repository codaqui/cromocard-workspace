# CCD110 — Confirmar Entrega e Liberar Pagamento

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace desde 18/11/2026: legenda de `user-stories.md` e ADR-027)
- **User story:** #922 `CCD110-Confirmar Entrega e Liberar Pagamento`
- **Caso de uso:** [110-confirmar-entrega-e-liberar-pagamento.md](../../docs/Casos-De-Uso/110-confirmar-entrega-e-liberar-pagamento.md)
- **Atores:** Cliente (comprador), Sistema · **Pré-condições:** pedido Enviado (`SHIPPED`), com etiqueta gerada pelo Melhor Envio (CCD109)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente quero que o pagamento só seja liberado ao vendedor depois que a carta for entregue para comprar com segurança.

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
| R1 | O aviso de entrega do Melhor Envio (webhook `order.delivered`, com a assinatura `X-ME-Signature` conferida, resposta `200` imediata e processamento idempotente) marca o pedido Enviado como Entregue (`DELIVERED`) e grava a data da entrega | Regra | `110`, FP 1; ADR-067, itens 5 e 6; DBML `orders.delivered_at` |
| R2 | Uma consulta periódica do rastreio encontra a entrega cujo aviso se perdeu e marca o pedido como Entregue | Regra | `110`, FP 1; ADR-067, item 5; ADR-010 |
| R3 | Na entrega, o comprador recebe um e-mail, e o detalhe do pedido mostra a data da liberação: 7 dias depois da entrega (0 dias em homologação) | Mensagem | `110`, FP 2; `77`, FP 5; ADR-059 |
| R4 | No pedido Entregue e não concluído, o detalhe mostra "Confirmar recebimento"; só o comprador do pedido confirma | Ação | `110`, FP 3; `77`, FP 5 |
| R5 | "Confirmar recebimento" pede a confirmação e avisa que, depois dela, o valor é liberado ao vendedor | Tela | `110`, FP 4 |
| R6 | Confirmado, o sistema transfere ao vendedor, pela Stripe, o valor da carta menos a taxa de 5%, com a taxa arredondada para baixo (a favor do vendedor), marca o pedido como Concluído (`COMPLETED`) e avisa o vendedor por e-mail | Ação | `110`, FP 5–6; ADR-066, item 4; DBML `orders.platform_fee`, `stripe_transfer_id`, `released_at` |
| R7 | A transferência usa a cobrança do pedido como origem (`source_transaction` = `payments.charge_id`) e o id do pedido como grupo; o frete não é repassado | Regra | ADR-066, item 4; DBML `payments.charge_id` |
| R8 | Sem a confirmação do comprador, o sistema libera o pagamento sozinho quando passam os 7 dias depois da entrega | Regra | `110`, FA 1; ADR-010 |
| R9 | Pedido cancelado e reembolsado pelo administrador antes da liberação fica Cancelado e nada é transferido | Regra | `110`, FA 2; `111`, FA 1–4 |
| R10 | Se a transferência falha na Stripe, o pedido continua Entregue, o sistema tenta de novo na próxima execução e o administrador vê o pedido como pendente | Regra | `110`, FA 3; `111`, FP 2 |
| R11 | Pedido em outro status que não Entregue não pode ser confirmado: a API responde `422`; um pedido é liberado uma vez só | Regra | `110`, Pré-condições; ADR-011 |
| R12 | Confirmar exige login: `401` sem token; pedido de outro comprador responde `404` | Permissão | `110`, Atores; ADR-005, item 4; ADR-011 |
| R13 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1112-8820`, `1112-9136`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1, R3) — **Dado** um pedido `SHIPPED`, **quando** chega um `order.delivered` válido da etiqueta dele, **então** a API responde `200`, o pedido fica `DELIVERED` com `delivered_at`, o comprador recebe o e-mail e o detalhe mostra a data de liberação 7 dias depois (0 em homologação).
- **CA2** (R1) — **Dado** um `order.delivered` com assinatura inválida, **quando** chega ao webhook, **então** nada muda no pedido; **dado** o mesmo aviso válido recebido duas vezes, **então** o pedido muda uma vez e só um e-mail sai.
- **CA3** (R2) — **Dado** um pedido `SHIPPED` cujo aviso de entrega não chegou e que o rastreio já mostra entregue, **quando** a consulta periódica roda, **então** o pedido fica `DELIVERED`.
- **CA4** (R4–R7) — **Dado** um pedido `DELIVERED` de R$ 1.750,00 de carta e R$ 38,40 de frete, **quando** o comprador seleciona "Confirmar recebimento" e confirma no diálogo, **então** a Stripe (provider falso, nos testes) recebe uma transferência de R$ 1.662,50 para a conta do vendedor com a cobrança do pedido como origem, o pedido fica `COMPLETED` com `platform_fee` R$ 87,50, `stripe_transfer_id` e `released_at`, e o vendedor recebe o e-mail.
- **CA5** (R6) — **Dado** uma carta de R$ 10,99, **quando** o pagamento é liberado, **então** a taxa é R$ 0,54 (5% = 0,5495, arredondado para baixo) e o vendedor recebe R$ 10,45.
- **CA6** (R5) — **Dado** o diálogo "Confirmar recebimento?" aberto, **quando** o comprador seleciona "Cancelar", **então** o diálogo fecha, nada é transferido e o pedido continua `DELIVERED`.
- **CA7** (R8) — **Dado** um pedido `DELIVERED` há 7 dias sem confirmação, **quando** o job de liberação roda, **então** o pagamento é liberado como no CA4 e o pedido fica `COMPLETED`; com 6 dias, nada acontece.
- **CA8** (R9) — **Dado** um pedido cancelado e reembolsado pelo administrador, **quando** o job de liberação roda ou o comprador tenta confirmar, **então** nada é transferido e a API responde `422`.
- **CA9** (R10) — **Dado** a Stripe recusando a transferência, **quando** a liberação roda, **então** o pedido continua `DELIVERED` sem `stripe_transfer_id`, o administrador vê o pedido como pendente e a próxima execução tenta de novo.
- **CA10** (R11) — **Dado** um pedido `SHIPPED` ou `COMPLETED`, **quando** a API recebe a confirmação, **então** responde `422` e não cria transferência.
- **CA11** (R12) — **Dado** um visitante sem login, **quando** chama a confirmação, **então** recebe `401`; **dado** outro cliente, **quando** tenta confirmar o pedido que não é dele, recebe `404`.
- **CA12** (R5, R6) — **Dado** a confirmação em andamento, **quando** o comprador confirma, **então** o botão fica em carregamento e não aceita um segundo clique; se a API falhar, o diálogo mostra o erro e o pedido continua Entregue.
- **CA13** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-8820` (Detalhe do pedido), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-9136` (Confirmar recebimento), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `buyer_id`, `seller_id`, `status` (`order_status`: `SHIPPED`, `DELIVERED`, `COMPLETED`, `CANCELED`), `items_amount`, `shipping_label_id`, `tracking_code`, `platform_fee`, `stripe_transfer_id`, `delivered_at`, `released_at` | `platform_fee` decimal(10,2); `stripe_transfer_id` varchar(60) |
| `payments` | `order_id`, `charge_id`, `status` (`payment_status`) | `charge_id` = origem da transferência (ADR-066, item 4) |
| `users` | `email`, `stripe_account_id`, `stripe_account_status` | destino da transferência; e-mails do comprador e do vendedor |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Compras - Detalhe do pedido | [1112-8820](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-8820) | R3, R4 | ✅ Bate (salvo L1, L2) |
| Compras - Confirmar recebimento | [1112-9136](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-9136) | R5 | ✅ Bate (salvo L3) |

- Detalhe do pedido: "Status: Entregue. Confira a carta e confirme o recebimento.", o passo "Concluído" com "O valor é
  liberado ao vendedor em 27/11/2026 ou assim que você confirmar o recebimento.", o botão "Confirmar recebimento" no "Resumo"
  e "Se a carta chegou diferente do anúncio, não confirme: o suporte analisa e pode devolver seu dinheiro." com "Falar com o
  suporte".
- Confirmar recebimento: "Confirmar recebimento?", "Confira se a carta chegou como anunciada. Ao confirmar, o valor (menos a
  taxa de 5%) é liberado ao vendedor e o pedido é concluído. Depois disso não é possível pedir reembolso pela CromoCard.",
  "Cancelar" e "Confirmar recebimento".
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): orientação "Se a carta chegou diferente do
  anúncio, não confirme…" e o link "Falar com o suporte" (L1); "Depois disso não é possível pedir reembolso pela CromoCard."
  (L3).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): o detalhe do pedido depois da confirmação (Concluído)
  e o retorno de sucesso (L2); o erro ao confirmar.

## Fora do escopo

- O restante do detalhe do pedido (linha do tempo, rastreio, endereço, resumo) e a lista "Meus pedidos" — CCD077.
- Gerar a etiqueta e marcar o pedido Enviado — CCD109.
- Cancelar com reembolso e "Liberar agora" pelo administrador — CCD111.
- Avaliar o vendedor depois da entrega — fora do MVP (ADR-027).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | "Se a carta chegou diferente do anúncio, não confirme: o suporte analisa e pode devolver seu dinheiro." e "Falar com o suporte" só existem no Figma, e não há caso de uso de suporte nem de disputa. Faz sentido implementar? Para onde o link leva? (proposta: manter o texto; o link abre a Central de ajuda) | pendente | — |
| L2 | O que o detalhe mostra depois da confirmação, e com que aviso? (proposta: o passo "Concluído" marcado com a data da liberação, sem o botão, e o aviso "Recebimento confirmado. O valor foi liberado ao vendedor."; o Gabriel desenha) | pendente | — |
| L3 | "Depois disso não é possível pedir reembolso pela CromoCard." não está no caso de uso. Vale como regra? (proposta: sim; é consequência do FA 2 da CCD110 e do FA 9 da CCD111: pedido Concluído não tem mais ações) | pendente | — |
| L4 | Onde fica o prazo de liberação (7 dias, 0 em homologação)? (proposta: variável de ambiente lida pela configuração, ADR-018, e não `global_settings`) | pendente | — |
| L5 | O DBML não guarda a falha da transferência, e o administrador precisa ver "Repasse pendente • Falha na Stripe" (CCD111). Como registrar? (proposta: pedido `DELIVERED` com o prazo vencido e sem `stripe_transfer_id` é "pendente", sem coluna nova; ou coluna nova com ADR) | pendente | — |
| L6 | Frequência dos jobs de liberação automática, de nova tentativa e da consulta do rastreio (ADR-010 não os lista) (proposta: a cada hora, os três; registrar no ADR-010 ou num ADR novo) | pendente | — |
| L7 | A data de liberação conta 7 dias corridos a partir de `delivered_at`, inclusive horário? (proposta: `delivered_at` + 7 × 24 h) | pendente | — |
| L8 | A conta do vendedor deixou de estar pronta (`READY`) na hora da liberação: tenta, falha e fica pendente, ou nem tenta? (proposta: nem tenta e fica pendente, como no FA 3) | pendente | — |
| L9 | O caso 110 ganhou o "Relatar problema" (FA 4–7, decidido pelo PO em 23/11/2026): o comprador relata o problema num pedido Enviado ou Entregue, antes da liberação, e a liberação automática fica suspensa (`orders.problem_description` e `problem_reported_at`). Quais requisitos e critérios de aceite entram, e o "Falar com o suporte" da L1 vira esse botão? | pendente | — |
