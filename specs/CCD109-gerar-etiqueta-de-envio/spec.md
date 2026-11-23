# CCD109 — Gerar Etiqueta de Envio

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace desde 18/11/2026: legenda de `user-stories.md` e ADR-027)
- **User story:** #921 `CCD109-Gerar Etiqueta de Envio`
- **Caso de uso:** [109-gerar-etiqueta-de-envio.md](../../docs/Casos-De-Uso/109-gerar-etiqueta-de-envio.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`, com um pedido Pago (`PAID`) ainda não enviado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso gerar a etiqueta de envio de um pedido pago para despachar a carta com rastreio.

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
| R1 | Só o `SELLER` vendedor do pedido vê e gera a etiqueta: `401` sem token, `403` para outro papel, `404` para pedido de outro vendedor | Permissão | `109`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Pedidos e envios" no Painel do vendedor lista as vendas por status: Aguardando envio, Em trânsito, Entregues e Cancelados | Tela | `109`, FP 1–2; DBML `order_status` |
| R3 | Cada venda aguardando envio mostra o prazo de 2 dias para enviar, contado do pagamento | Regra | `109`, FP 2; `72`, FP 9; DBML `orders.paid_at` |
| R4 | "Gerar etiqueta" num pedido aguardando envio mostra a carta, o comprador, o endereço de entrega, o frete escolhido pelo comprador, o pacote padrão (envelope de 16 × 11 × 2 cm, 100 g, valor declarado igual ao preço da carta) e o remetente (o endereço principal do vendedor) | Tela | `109`, FP 3–4; ADR-067, item 3 |
| R5 | Confirmar "Gerar etiqueta" compra a etiqueta no Melhor Envio, no serviço escolhido no checkout, como envio não comercial com declaração de conteúdo, com o CPF do vendedor como remetente e o do comprador como destinatário | Ação | `109`, FP 5–6; ADR-067, item 4; DBML `orders.shipping_service` |
| R6 | Com a etiqueta comprada, o pedido fica Enviado (`SHIPPED`), com o id da etiqueta, o código e o link de rastreio e a data do envio | Regra | `109`, FP 6; ADR-067, item 6; DBML `orders` |
| R7 | O comprador recebe por e-mail o aviso do envio com o código de rastreio | Ação | `109`, FP 6; ADR-059 |
| R8 | Depois da compra, o sistema mostra "Etiqueta gerada", com o código de rastreio e o botão "Imprimir etiqueta" | Tela | `109`, FP 7 |
| R9 | Se o Melhor Envio recusa a etiqueta, o sistema informa o motivo e mantém o pedido Pago, para tentar de novo | Regra | `109`, FA 1 |
| R10 | Pedido Pago há mais de 2 dias sem etiqueta ganha o selo "atrasado" para o administrador | Regra | `109`, FA 2; `111`, FP 2 |
| R11 | Só pedido `PAID` gera etiqueta; em outro status a API responde `422` | Regra | `109`, Pré-condições; ADR-011 |
| R12 | O Melhor Envio fica atrás do `ShippingProvider`, com um provider falso (frete fixo e entrega simulada) no PC de cada pessoa e nos testes | Regra | ADR-067, item 1; ADR-009 |
| R13 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `675-7139`, `675-7788`, `1112-9466`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um vendedor com 2 pedidos `PAID`, 1 `SHIPPED`, 1 `DELIVERED` e 1 `CANCELED`, **quando** abre "Pedidos e envios", **então** vê as abas "Aguardando envio (2)", "Em trânsito (1)", "Entregues (1)" e "Cancelados (1)", e cada pedido aguardando envio mostra quanto falta do prazo de 2 dias ("Envie em até 47h").
- **CA2** (R4) — **Dado** um pedido `PAID`, **quando** o vendedor seleciona "Gerar etiqueta", **então** vê a carta, o comprador, o endereço de entrega, o frete escolhido com o valor pago pelo comprador, "Envelope 16 × 11 × 2 cm, 100 g • valor declarado <preço da carta>" e o remetente com o endereço principal dele.
- **CA3** (R5–R8) — **Dado** o modal "Gerar etiqueta" aberto, **quando** o vendedor confirma, **então** a etiqueta é comprada no provider (falso, nos testes), o pedido fica `SHIPPED` com `shipping_label_id`, `tracking_code`, `tracking_url` e `shipped_at`, o comprador recebe o e-mail com o código, e o modal mostra "Etiqueta gerada" com o código e "Imprimir etiqueta".
- **CA4** (R8) — **Dado** a etiqueta gerada, **quando** o vendedor seleciona "Imprimir etiqueta", **então** abre a etiqueta para impressão.
- **CA5** (R9) — **Dado** o Melhor Envio recusando a etiqueta com um motivo, **quando** o vendedor confirma, **então** vê o motivo, o pedido continua `PAID`, nenhum e-mail sai e ele pode tentar de novo.
- **CA6** (R10) — **Dado** um pedido `PAID` há 3 dias sem etiqueta, **quando** o administrador abre "Pedidos e pagamentos", **então** o pedido tem o selo "Atrasado".
- **CA7** (R11) — **Dado** um pedido `SHIPPED`, **quando** a API recebe o pedido de gerar etiqueta, **então** responde `422` e não compra outra etiqueta.
- **CA8** (R1) — **Dado** um visitante sem login, **quando** chama a lista ou a etiqueta, **então** recebe `401`; **dado** um `CUSTOMER`, recebe `403`; **dado** outro vendedor, **quando** tenta gerar a etiqueta do pedido, recebe `404`.
- **CA9** (R2) — **Dado** um vendedor sem vendas, **quando** abre "Pedidos e envios", **então** vê o estado vazio (L9); durante o carregamento, vê o carregamento; se a API falhar, vê o erro com a opção de tentar de novo.
- **CA10** (R5) — **Dado** a compra em andamento, **quando** o vendedor confirma "Gerar etiqueta", **então** o botão fica em carregamento e não aceita um segundo clique, para não comprar duas etiquetas.
- **CA11** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-7139` (Pedidos e envios), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-7788` (Gerar etiqueta), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-9466` (Etiqueta gerada), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `seller_id`, `buyer_id`, `listing_id`, `shipping_address_id`, `items_amount`, `shipping_amount`, `shipping_method`, `shipping_service`, `status` (`order_status`), `shipping_label_id`, `tracking_code`, `tracking_url`, `platform_fee`, `paid_at`, `shipped_at`, `created_at` | `PAID` → `SHIPPED`; `shipping_label_id` varchar(60), `tracking_code` varchar(40), `tracking_url` varchar(255) |
| `addresses` | `user_id`, `zip_code`, `street`, `number`, `complement`, `neighborhood`, `city`, `state`, `is_primary` | destino (`orders.shipping_address_id`) e remetente (endereço principal do vendedor) |
| `users` | `name`, `username`, `email`, `cpf`, `phone` | CPF do vendedor e do comprador na declaração de conteúdo (ADR-067, item 4); e-mail do comprador |
| `listings` / `cards` / `card_conditions` | `card_id`, `condition_id`; `name`, `front_image_url`; `name` | carta, miniatura e condição na lista e no modal |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor - pedidos e envios | [675-7139](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-7139) | R2, R3 | ❌ Não bate (L1–L4, L6) |
| Painel Vendedor - gerar etiqueta | [675-7788](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-7788) | R4, R5 | ✅ Bate (salvo L5, L7) |
| Painel Vendedor - gerar etiqueta - etiqueta gerada | [1112-9466](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-9466) | R6–R8 | ✅ Bate (salvo L8) |

- Lista: título "Pedidos & Envios", "Acompanhe suas vendas, gere a etiqueta e poste a carta no prazo. O pagamento é liberado
  depois da entrega.", selo "3 aguardando envio", cartões "Aguardando envio" ("Prazo de até 48h"), "Em trânsito" ("Correios e
  Jadlog"), "Entregues no mês" ("+9 esta semana") e "Valor retido" ("Liberado após a entrega"), abas, filtro "Últimos 30 dias
  ▾", colunas "Pedido", "Carta", "Comprador", "Valor", "Status" e "Ações", ações "Gerar etiqueta", "Acompanhar" e "Ver
  detalhes".
- Gerar etiqueta: "Gerar etiqueta", "Pedido #PED-88241 • prazo para envio: 47h", "Comprador: … • R$ …", selo "🔒 Pagamento
  retido", "Endereço de entrega", "Frete escolhido pelo comprador" ("Correios SEDEX • R$ 38,40 pago pelo comprador • entrega
  em até 2 dias úteis"), "PACOTE PADRÃO", "Remetente: seu endereço principal (…)", o aviso "A etiqueta é comprada pelo Melhor
  Envio e o código de rastreio entra no pedido. O valor líquido de R$ 1.662,50 (menos a taxa de 5%) vai para sua conta Stripe
  quando o comprador confirmar o recebimento, ou 7 dias após a entrega.", "Cancelar" e "Gerar etiqueta".
- Etiqueta gerada: "Etiqueta gerada", "CÓDIGO DE RASTREIO", "<código> • <serviço>", "Imprima a etiqueta, cole no envelope e
  poste até 21/11/2026. O comprador recebe o código por e-mail.", "Fechar" e "Imprimir etiqueta".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): prazo — o caso de uso diz 2 dias, o Figma mostra horas ("Envie
  em até 47h", "Prazo de até 48h") e a tela pública "Como funciona - quero vender" (`1160-2268`) diz "2 dias úteis" (L4).
  Número do pedido — "#PED-88241" aqui e "#CC-10482" no BackOffice (L6). Na aba "Aguardando envio" selecionada, a lista do
  frame mostra também pedidos em trânsito e concluídos, e a mesma linha aparece como "Concluído" em `675-7139` e como
  "Entregue • Pagamento liberado" em `675-7788` (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): cartões de contagem e "Valor retido", filtro
  "Últimos 30 dias", "Imprimir etiquetas" e "Exportar Fiscal/CSV" (L1); ações "Acompanhar" e "Ver detalhes" (L2); "entrega em
  até 2 dias úteis" do frete (L5); o aviso do valor líquido no modal e o selo "Pagamento retido" (L7); "poste até <data>"
  (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R9 a recusa da etiqueta com o motivo; o estado vazio
  da lista (L9).

## Fora do escopo

- Pagamento do pedido e cotação do frete no checkout — CCD072.
- Entrega, confirmação do recebimento e liberação do pagamento — CCD110.
- Lista do BackOffice com o selo "Atrasado" e o cancelamento com reembolso — CCD111 (aqui só a regra do atraso, R10).
- Renovação automática do token do Melhor Envio — plano técnico (ADR-067, item 2).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Cartões "Aguardando envio", "Em trânsito", "Entregues no mês" e "Valor retido", filtro "Últimos 30 dias", "Imprimir etiquetas" (em lote) e "Exportar Fiscal/CSV" só existem no Figma. Faz sentido implementar? (proposta: sim para os cartões e o filtro; não para impressão em lote e exportação) | pendente | — |
| L2 | O que fazem "Acompanhar" (em trânsito) e "Ver detalhes" (entregue/concluído)? Não há caso de uso de detalhe do pedido para o vendedor (proposta: "Acompanhar" abre o `tracking_url`; "Ver detalhes" abre o mesmo modal só de leitura, com o código de rastreio) | pendente | — |
| L3 | Em qual aba entram `COMPLETED` e como o status aparece para o vendedor ("Concluído" ou "Entregue • Pagamento liberado")? E `AWAITING_PAYMENT` aparece? (proposta: "Entregues" mostra `DELIVERED` e `COMPLETED`, com o selo "Entregue" e a linha "Pagamento liberado" quando concluído; `AWAITING_PAYMENT` não aparece; a lista filtra pela aba selecionada) | pendente | — |
| L4 | O prazo é de 2 dias corridos (48 h, como no Figma) ou 2 dias úteis (tela pública `1160-2268`)? (proposta: 48 h corridas desde `paid_at`; o Gabriel ajusta o texto da tela pública) | pendente | — |
| L5 | "entrega em até 2 dias úteis" vem da cotação do checkout, mas o DBML não guarda o prazo do frete. Faz sentido implementar? (proposta: não mostrar o prazo, ou guardar com coluna nova e ADR) | pendente | — |
| L6 | O DBML não tem número legível do pedido, e o Figma usa "#PED-88241" no site e "#CC-10482" no BackOffice. Qual formato e onde fica? (proposta: um só formato, derivado do id, sem coluna nova; a mesma decisão vale para CCD072, CCD077 e CCD111) | pendente | — |
| L7 | O aviso do valor líquido ("vai para sua conta Stripe quando o comprador confirmar o recebimento, ou 7 dias após a entrega") e o selo "Pagamento retido" só existem no Figma. Faz sentido implementar? (proposta: sim; o valor é `items_amount` menos a taxa, como na CCD110) | pendente | — |
| L8 | "poste até <data>" no frame de etiqueta gerada não está no caso de uso. Faz sentido implementar? (proposta: sim, a data do fim do prazo da L4) | pendente | — |
| L9 | Texto do estado vazio de "Pedidos e envios" e de cada aba (proposta: "Nenhuma venda por aqui ainda") | pendente | — |
| L10 | O pedido fica Enviado na compra da etiqueta (`109`, FP 6) ou quando a transportadora registra a postagem (webhook `order.posted`, ADR-067, item 5)? (proposta: na compra, como no caso de uso; o `order.posted` só atualiza `shipped_at`) | pendente | — |
| L11 | Vendedor sem CPF ou sem telefone, exigidos pelo Melhor Envio como remetente: o que acontece? (proposta: o modal pede o dado que falta antes de comprar) | pendente | — |
| L12 | Como "Imprimir etiqueta" chega ao arquivo? O DBML guarda só `shipping_label_id` (proposta: a API pede ao Melhor Envio o link de impressão na hora, sem coluna nova) | pendente | — |
