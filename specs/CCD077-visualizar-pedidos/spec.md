# CCD077 — Visualizar Pedidos

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027)
- **User story:** não encontrada no board
- **Caso de uso:** [77-visualizar-pedidos.md](../../docs/Casos-De-Uso/77-visualizar-pedidos.md) · relacionado: [110-confirmar-entrega-e-liberar-pagamento.md](../../docs/Casos-De-Uso/110-confirmar-entrega-e-liberar-pagamento.md)
- **Atores:** Cliente · **Pré-condições:** autenticado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar meus pedidos para acompanhar as compras e vendas realizadas na plataforma.

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
| R1 | Só usuário autenticado vê os pedidos, e só os que ele comprou (`orders.buyer_id`): `401` sem token; o pedido de outra pessoa responde `404` | Permissão | `77`, Pré-condições; ADR-005; ADR-011 |
| R2 | "Meus pedidos" abre pelo menu lateral ou por Perfil e configurações | Ação | `77`, FP 1 (L6) |
| R3 | A lista mostra, para cada pedido, o número, a carta, o vendedor, a data, o total e o status (Aguardando pagamento, Pago, Enviado, Entregue, Concluído ou Cancelado) | Tela | `77`, FP 2; DBML `order_status` (L1) |
| R4 | Abas por status, cada uma com a quantidade de pedidos | Ação | `77`, FP 2 (L2) |
| R5 | "Ver pedido" abre o detalhe do pedido | Ação | `77`, FP 3 |
| R6 | O detalhe mostra a linha do tempo pago, enviado, entregue e concluído, com data e hora de cada etapa (`paid_at`, `shipped_at`, `delivered_at`, `released_at`) | Tela | `77`, FP 4; DBML `orders` |
| R7 | O detalhe mostra a transportadora, o código e o link de rastreio (`tracking_code`, `tracking_url`) | Campo | `77`, FP 4; ADR-067, item 6 (L9) |
| R8 | O detalhe mostra o endereço de entrega, o vendedor e os valores da carta, do frete e o total (`items_amount`, `shipping_amount`, `total_amount`) | Campo | `77`, FP 4 |
| R9 | Pedido entregue e ainda não concluído (`DELIVERED`) mostra a data em que o valor será liberado ao vendedor (7 dias depois de `delivered_at`; 0 dias em homologação) e o botão "Confirmar recebimento" | Estado | `77`, FP 5; `110`, FP 2 |
| R10 | Sem pedidos, a lista mostra "Você ainda não possui pedidos." | Mensagem | `77`, FA 1 |
| R11 | Pedido cancelado mostra o motivo (`cancel_reason`: "pagamento não concluído" ou o motivo informado pelo administrador) e, se houve pagamento, que o valor foi reembolsado no cartão (`payments.status = REFUNDED`, `refunded_at`) | Estado | `77`, FA 2 |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um cliente com 5 pedidos, **quando** ele seleciona "Meus pedidos" no menu lateral, **então** vê os 5 com número, carta, vendedor, data, total e status.
- **CA2** (R4) — **Dado** os 5 pedidos, 1 Enviado e 1 Cancelado, **quando** o cliente seleciona a aba "Enviado", **então** vê só o pedido enviado, e cada aba mostra a quantidade certa.
- **CA3** (R5–R8) — **Dado** um pedido `DELIVERED`, **quando** o cliente seleciona "Ver pedido", **então** vê a linha do tempo com data e hora de pago, enviado e entregue, a transportadora, o código e o link de rastreio, o endereço de entrega, o vendedor e os valores da carta, do frete e o total.
- **CA4** (R9) — **Dado** um pedido `DELIVERED` em 20/11/2026 às 10:05, fora de homologação, **quando** o cliente abre o detalhe, **então** vê que o valor é liberado ao vendedor em 27/11/2026 e o botão "Confirmar recebimento"; **dado** um pedido `COMPLETED`, **então** o botão não aparece e a etapa "Concluído" mostra a data e a hora.
- **CA5** (R7) — **Dado** um pedido `SHIPPED`, **quando** o cliente seleciona o link de rastreio, **então** a página da transportadora abre com o código do pedido.
- **CA6** (R10) — **Dado** um cliente sem pedidos, **quando** abre "Meus pedidos", **então** vê "Você ainda não possui pedidos."
- **CA7** (R11) — **Dado** um pedido cancelado por expiração do pagamento, **quando** o cliente abre o detalhe, **então** vê o motivo "pagamento não concluído" e nenhuma menção a reembolso; **dado** um pedido pago e cancelado pelo administrador, **então** vê o motivo do administrador e que o valor foi reembolsado no cartão.
- **CA8** (R1) — **Dado** uma chamada sem token, **quando** pede a lista, **então** recebe `401`; **dado** o cliente A, **quando** pede o detalhe de um pedido do cliente B, **então** recebe `404`.
- **CA9** (R3) — **Dado** a lista abrindo, **quando** a busca não respondeu ou falhou, **então** a tela mostra o carregamento ou um aviso de erro no estilo da tela, e não a mensagem de lista vazia.
- **CA10** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-8445`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-8820`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `id`, `listing_id`, `buyer_id`, `seller_id`, `shipping_address_id`, `items_amount`, `shipping_amount`, `total_amount`, `shipping_method`, `shipping_service`, `status` (`order_status`: `AWAITING_PAYMENT`, `PAID`, `SHIPPED`, `DELIVERED`, `COMPLETED`, `CANCELED`), `tracking_code`, `tracking_url`, `cancel_reason`, `paid_at`, `shipped_at`, `delivered_at`, `released_at`, `created_at` | sem coluna de número do pedido (L1) |
| `payments` | `order_id`, `status` (`payment_status`: `REFUNDED`), `refunded_at` | reembolso no cancelado (R11); não guarda o final do cartão (L3) |
| `listings`, `cards`, `card_conditions` | `card_id`, `condition_id`; `name`, `number`, `front_image_url`; `name` | carta do pedido |
| `users` | `username`, `name` | vendedor (`@usuario`) e destinatário |
| `addresses` | `street`, `number`, `complement`, `neighborhood`, `city`, `state`, `zip_code` | endereço de entrega, mesmo se excluído depois (o pedido aponta para ele) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Compras — Meus pedidos | [1112-8445](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-8445) | R2–R5 | ⚠️ Bate; aba "Todos" só no Figma (L2) |
| Compras — Detalhe do pedido | [1112-8820](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-8820) | R6–R9 | ⚠️ Bate; final do cartão e "Falar com o suporte" só no Figma (L3, L4) |

- Lista: "COMPRAS", "Meus pedidos", "Acompanhe o pagamento, o envio e a entrega das suas compras.", abas "Todos (12)", "Aguardando pagamento (1)", "Pago (2)", "Enviado (3)", "Entregue (1)", "Concluído (4)", "Cancelado (1)", colunas "Pedido", "Carta", "Vendedor", "Data", "Total", "Status", "Ver pedido".
- Detalhe: "Meus pedidos / #PED-88213", "Status: Entregue. Confira a carta e confirme o recebimento.", "Acompanhamento", "Pago", "Enviado", "Entregue", "Concluído", "valor retido pela CromoCard", "confirmado pela transportadora", "O valor é liberado ao vendedor em 27/11/2026 ou assim que você confirmar o recebimento.", "Acompanhar entrega nos Correios →", "Endereço de entrega", "Resumo", "Carta", "Frete", "Total", "Confirmar recebimento", "Se a carta chegou diferente do anúncio, não confirme: o suporte analisa e pode devolver seu dinheiro.", "Falar com o suporte".
- O modal "Confirmar recebimento?" (`1112-9136`) é da CCD110 (Fora do escopo).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): aba "Todos" (L2); "cartão final 4242" (L3); "Falar com o suporte" e o aviso antes dele (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 o acesso por Perfil e configurações (L6); R10 a lista vazia; R11 o detalhe do pedido cancelado; o detalhe nos outros status (L7, L10).

## Fora do escopo

- Confirmar o recebimento (o modal `1112-9136`) e liberar o pagamento — CCD110.
- Cancelar e reembolsar — CCD111; gerar a etiqueta — CCD109; comprar — CCD072.
- Vendas do vendedor ("Pedidos e envios") — CCD109 (L5).
- Avaliar o pedido — fora do MVP (ADR-027).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma mostra o número "#PED-88213"; o DBML não tem coluna de número do pedido (o `id` é UUID v7). Como gerar e guardar? (mesma pergunta da CCD072, L1) | pendente | — |
| L2 | Aba "Todos" (só no Figma; o caso de uso fala em abas por status). Faz sentido implementar? Qual aba abre primeiro? | pendente | — |
| L3 | "cartão final 4242" (só no Figma): o DBML não guarda o final do cartão. Faz sentido implementar (coluna nova ou leitura na Stripe)? | pendente | — |
| L4 | "Falar com o suporte" e "Se a carta chegou diferente do anúncio, não confirme: o suporte analisa e pode devolver seu dinheiro." (só no Figma): não há caso de uso de suporte (o chat do suporte saiu, `escopo-adicional.md`, seção 3). Faz sentido implementar? Leva para onde? | pendente | — |
| L5 | A narrativa da user story fala em "compras e vendas"; o caso de uso e o Figma só mostram compras. As vendas ficam em "Pedidos e envios" do vendedor (CCD109)? | pendente | — |
| L6 | O FP 1 diz que "Meus pedidos" abre também por Perfil e configurações; as telas Perfil e Configurações do Figma não têm esse acesso (só o menu lateral). Onde fica? | pendente | — |
| L7 | Detalhe do pedido "Aguardando pagamento": o que mostra? Dá para retomar o pagamento na Stripe enquanto a reserva vale? Não documentado e sem desenho | pendente | — |
| L8 | Paginação: o Figma não desenha; o ADR-011 pagina de 20 em 20. Como fica a lista com mais de 20 pedidos? | pendente | — |
| L9 | A transportadora vem de `shipping_method` ou de `shipping_service` (CCD072, L3)? O link "Acompanhar entrega nos Correios →" muda com a transportadora (Jadlog)? | pendente | — |
| L10 | Subtítulo de status: o Figma só desenha "Status: Entregue. Confira a carta e confirme o recebimento."; os textos dos outros status não estão definidos | pendente | — |
| L11 | A legenda de `user-stories.md` não lista a CCD077 entre as que perderam a marca `***`, mas o ADR-027 lista e a narrativa está sem marca. A fase é MVP; corrigir a legenda? | pendente | — |
