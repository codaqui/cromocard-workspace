# CCD072 — Comprar

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027)
- **User story:** não encontrada no board
- **Caso de uso:** [72-comprar.md](../../docs/Casos-De-Uso/72-comprar.md) · decisões: ADR-066 (Stripe), ADR-067 (Melhor Envio)
- **Atores:** Cliente (vendedores também compram, como clientes) · **Pré-condições:** autenticado, com a conta ativa; anúncio ativo, com quantidade disponível e que não é do próprio cliente
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso comprar uma carta para adquirir o item disponibilizado no marketplace.

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
| R1 | Comprar exige login com a conta ativa (`users.status = ACTIVE`): `401` sem token, `403` com a conta suspensa ou bloqueada. `CUSTOMER` e `SELLER` compram | Permissão | `72`, Pré-condições; ADR-005; ADR-011 |
| R2 | Só compra anúncio `ACTIVE`, com `available_quantity > 0`, não excluído e de outro usuário (`seller_id` diferente do comprador); fora disso a API responde `422` | Regra | `72`, Pré-condições; ADR-011 |
| R3 | "Comprar" no detalhe do anúncio abre o checkout | Ação | `72`, FP 1 |
| R4 | O checkout mostra a carta, a condição, o vendedor, o endereço de entrega e as opções de frete, e um resumo com o valor da carta, o frete e o total | Tela | `72`, FP 2 |
| R5 | Cada pedido tem uma unidade de um anúncio (`orders.quantity = 1`) | Regra | `72`, FP 2 |
| R6 | O cliente escolhe um dos endereços dele (`addresses`) ou cadastra um novo | Campo | `72`, FP 3 (L7, L8) |
| R7 | O CPF do comprador é pedido só quando o cadastro não tem (`users.cpf` nulo) e fica gravado em `users.cpf` | Campo | `72`, FP 3; ADR-067, item 4 e Consequências (L9) |
| R8 | O frete é cotado no Melhor Envio com o CEP do endereço principal do vendedor (`addresses.is_primary`), o CEP de entrega e o pacote padrão de uma carta (envelope de 16 × 11 × 2 cm, 100 g, valor declarado igual ao preço da carta); as opções são de Correios e Jadlog, cada uma com preço e prazo | Regra | `72`, FP 4; ADR-067, itens 1 e 3 (L10, L12) |
| R9 | O cliente escolhe o frete e seleciona "Ir para o pagamento" | Ação | `72`, FP 5 |
| R10 | Ao ir para o pagamento, o sistema confere de novo a disponibilidade e cria o pedido `AWAITING_PAYMENT` com `buyer_id`, `seller_id`, `listing_id`, `shipping_address_id`, `items_amount` (preço da carta), `shipping_amount`, `total_amount` (carta + frete, em reais) e o serviço de frete escolhido, e reserva a carta por 30 minutos | Regra | `72`, FP 6; DBML `orders`; ADR-067, item 6 (L1, L2, L3) |
| R11 | O pagamento é só com cartão, no Stripe Checkout hospedado: o backend cria a sessão (`mode: payment`, moeda `brl`, uma linha com a carta e outra com o frete, `expires_at` de 30 minutos), grava `payments` (`method = CREDIT_CARD`, `status = PENDING`, `value` = total, `gateway_reference` = id da sessão) e leva o cliente à URL da sessão | Regra | `72`, FP 6–7; ADR-066, itens 1, 2 e 8 |
| R12 | Com o evento `checkout.session.completed`, o pedido fica `PAID` (`paid_at`), o pagamento fica `APPROVED` (`charge_id` = id da cobrança, `paid_at`), o valor fica retido no saldo da plataforma e o vendedor recebe um e-mail avisando que há uma venda paga para enviar | Regra | `72`, FP 8; ADR-066, itens 3, 6 e 8 (L11) |
| R13 | Todo webhook da Stripe tem a assinatura conferida com o segredo do webhook e é processado uma vez só (idempotente pelo id do evento) | Regra | ADR-066, item 6 |
| R14 | Depois do pagamento, o cliente vê "Pagamento confirmado", com o número do pedido e o prazo de 2 dias para o vendedor enviar | Tela | `72`, FP 9 (L1, L5) |
| R15 | O visitante que seleciona "Comprar" vê "Entre para continuar"; depois do login, volta para o anúncio | Permissão | `72`, FA 1–2 (L13) |
| R16 | Anúncio esgotado ou pausado mostra "Indisponível" no lugar de "Comprar" e os outros anúncios da carta; no anúncio do próprio cliente, "Comprar" não aparece | Estado | `72`, FA 3 |
| R17 | Se a carta esgota antes do pagamento (passo 6), o sistema informa que ela não está mais disponível, não cria o pedido e volta ao anúncio | Mensagem | `72`, FA 4; ADR-011 (`422`) |
| R18 | Sem frete para o CEP de entrega, o checkout informa e pede outro endereço, e o cliente não segue para o pagamento | Mensagem | `72`, FA 5 |
| R19 | Se o cliente cancela na página da Stripe ou não paga em 30 minutos, o pedido fica `CANCELED` com `cancel_reason` "pagamento não concluído" e a carta volta ao estoque (evento `checkout.session.expired`) | Regra | `72`, FA 6–7; ADR-066, item 6 (L4, L14) |
| R20 | O cliente vê "Pagamento não concluído", com "Tentar de novo"; o pedido cancelado continua em Meus pedidos | Tela | `72`, FA 7 (L6) |
| R21 | Cartão recusado é tratado na própria página da Stripe, que permite usar outro cartão; o pedido continua `AWAITING_PAYMENT` | Regra | `72`, FA 8 |
| R22 | A Stripe fica atrás do `PaymentProvider` e o Melhor Envio atrás do `ShippingProvider`, cada um com uma implementação falsa para os testes e o PC de cada pessoa | Regra | ADR-066, item 9; ADR-067, item 1; ADR-009 |
| R23 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R3–R9) — **Dado** o cliente logado no detalhe de um anúncio ativo de outro usuário, **quando** seleciona "Comprar", **então** vê o checkout com a carta, a condição, o vendedor, os endereços dele e as opções de frete de Correios e Jadlog com preço e prazo; **quando** escolhe um frete, **então** o resumo mostra carta, frete e total (carta + frete).
- **CA2** (R10, R11) — **Dado** o checkout preenchido, **quando** o cliente seleciona "Ir para o pagamento", **então** um pedido `AWAITING_PAYMENT` com `quantity = 1` e os valores do resumo é gravado, um `payments` `PENDING` com `method = CREDIT_CARD` e o id da sessão é gravado, a carta fica reservada e o navegador vai para a página da Stripe.
- **CA3** (R12, R14) — **Dado** o pedido `AWAITING_PAYMENT`, **quando** chega o `checkout.session.completed`, **então** o pedido fica `PAID` com `paid_at`, o pagamento fica `APPROVED` com `charge_id`, o vendedor recebe o e-mail e o cliente vê "Pagamento confirmado" com o número do pedido e o prazo de 2 dias.
- **CA4** (R13) — **Dado** um evento já processado, **quando** a Stripe o envia de novo, **então** nada muda e a resposta é `200`; **dado** um evento com assinatura inválida, **então** a API responde `400` e nada muda.
- **CA5** (R7) — **Dado** um cliente sem CPF, **quando** tenta ir para o pagamento sem informar, **então** o campo mostra erro e nada é gravado; **quando** informa e paga, **então** o CPF fica em `users.cpf`; **dado** um cliente com CPF, **então** o checkout não pede o CPF.
- **CA6** (R15) — **Dado** um visitante no detalhe do anúncio, **quando** seleciona "Comprar", **então** vê "Entre para continuar"; **quando** entra, **então** volta para o mesmo anúncio.
- **CA7** (R16) — **Dado** um anúncio `PAUSED` ou com `available_quantity = 0`, **quando** o detalhe abre, **então** mostra "Indisponível" no lugar de "Comprar" e os outros anúncios da carta; **dado** o anúncio do próprio cliente, **então** "Comprar" não aparece.
- **CA8** (R2) — **Dado** o próprio anúncio, um anúncio pausado ou esgotado, **quando** o cliente chama a API do checkout, **então** recebe `422` e nenhum pedido é criado.
- **CA9** (R17) — **Dado** o checkout aberto e a última unidade comprada por outra pessoa, **quando** o cliente seleciona "Ir para o pagamento", **então** vê que a carta não está mais disponível, volta ao anúncio e nenhum pedido é criado.
- **CA10** (R18) — **Dado** um endereço com CEP sem frete, **quando** o cliente o escolhe, **então** vê "Não há frete disponível para o CEP …" e "Escolha outro endereço ou cadastre um novo para ver as opções de frete.", o frete do resumo fica "—" e "Ir para o pagamento" não segue.
- **CA11** (R19, R20) — **Dado** um pedido `AWAITING_PAYMENT`, **quando** a sessão expira em 30 minutos ou o cliente cancela na Stripe, **então** o pedido fica `CANCELED` com `cancel_reason` "pagamento não concluído", a quantidade do anúncio volta, o cliente vê "Pagamento não concluído" com "Tentar de novo" e o pedido aparece em Meus pedidos como Cancelado.
- **CA12** (R21) — **Dado** a página da Stripe aberta, **quando** o cartão é recusado, **então** a Stripe mostra o erro e o pedido continua `AWAITING_PAYMENT`.
- **CA13** (R1) — **Dado** uma chamada sem token, **quando** pede o checkout, **então** recebe `401`; **dado** um cliente com `status = SUSPENDED`, **então** recebe `403`; **dado** um `SELLER` comprando o anúncio de outro, **então** compra normalmente.
- **CA14** (R22) — **Dado** os testes e o ambiente local, **quando** rodam o fluxo inteiro, **então** usam os providers falsos de pagamento e de frete, sem chamar a Stripe nem o Melhor Envio.
- **CA15** (R4, R8) — **Dado** o checkout abrindo, **quando** a cotação ainda não respondeu, **então** o bloco "3. Frete" mostra o carregamento e "Ir para o pagamento" não segue.
- **CA16** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-5772`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA17** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-6152`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA18** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-5461`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA19** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-7309`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA20** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-7631`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA21** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-7935`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA22** (R23) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-8190`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `listing_id`, `buyer_id`, `seller_id`, `shipping_address_id`, `quantity`, `items_amount`, `shipping_amount`, `total_amount`, `shipping_method`, `shipping_service`, `status` (`order_status`: `AWAITING_PAYMENT`, `PAID`, `CANCELED`), `cancel_reason`, `paid_at`, `created_at` | `shipping_address_id`, `items_amount`, `total_amount` e `shipping_method` obrigatórios; `quantity` default 1; `shipping_amount` default 0; `status` default `AWAITING_PAYMENT`; sem `deleted_at` em uso (histórico, ADR-015, item 4); sem coluna de número do pedido nem de reserva (L1, L2) |
| `payments` | `order_id`, `method` (`payment_method`: `CREDIT_CARD`), `value`, `status` (`payment_status`: `PENDING`, `APPROVED`, `REJECTED`), `gateway_reference`, `charge_id`, `paid_at` | `order_id` único (1:1 com o pedido); `status` default `PENDING` (L14) |
| `listings` | `id`, `seller_id`, `card_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status`: `ACTIVE`, `PAUSED`, `CLOSED`), `deleted_at` | disponibilidade e reserva (R2, R10, L2) |
| `addresses` | `user_id`, `label`, `zip_code`, `street`, `number`, `complement`, `neighborhood`, `city`, `state`, `is_primary`, `deleted_at` | endereço de entrega do comprador e CEP de origem do vendedor (`is_primary`) |
| `users` | `status` (`user_status`), `cpf`, `username` | `cpf` varchar(14), único (L9) |
| `cards`, `card_conditions` | `name`, `number`, `album_id`, `front_image_url`; `name` | resumo do checkout |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público — Detalhe do anúncio | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R3 | ✅ Bate ("Comprar" e o aviso do frete) |
| Público — Detalhe do anúncio — indisponível | [1112-6152](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6152) | R16 | ✅ Bate |
| Público — Entre para continuar | [1112-5461](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5461) | R15 | ⚠️ Desenhado sobre o perfil da carta, não sobre o anúncio (L13) |
| Compras — Checkout | [1112-7309](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-7309) | R4–R9 | ⚠️ Bate; pré-seleção e cadastro de endereço em aberto (L7, L8) |
| Compras — Checkout — sem frete | [1112-7631](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-7631) | R18 | ✅ Bate |
| Compras — Pagamento confirmado | [1112-7935](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-7935) | R14 | ⚠️ Bate; número do pedido em aberto (L1) |
| Compras — Pagamento não concluído | [1112-8190](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-8190) | R19, R20 | ⚠️ "Voltar ao anúncio" só no Figma (L6) |

- Detalhe do anúncio: "Comprar", "Pagamento retido pela CromoCard até você receber a carta. O frete (Correios ou Jadlog) é calculado no checkout."; indisponível: "Indisponível", "Este anúncio está esgotado ou pausado pelo vendedor. Veja os outros anúncios desta carta abaixo.", "Outros anúncios desta carta (3)", "Compare com os outros vendedores".
- Checkout: "COMPRA", "Checkout", "Confira o endereço e escolha o frete. O pagamento é feito na página segura da Stripe.", "1. Endereço de entrega", "+ Cadastrar novo endereço", "2. CPF do comprador", "O CPF vai na declaração de conteúdo do envio. Pedimos uma vez só.", "000.000.000-00", "3. Frete", "Entrega em até N dias úteis", "Resumo", "Carta", "Frete", "Total", "Ir para o pagamento", "Você paga com cartão na página segura da Stripe. A carta fica reservada por 30 minutos. O valor fica retido pela CromoCard até a entrega."
- Sem frete: "Não há frete disponível para o CEP 69900-000.", "Escolha outro endereço ou cadastre um novo para ver as opções de frete.", frete "—", "Ir para o pagamento" desabilitado e "Escolha um endereço com frete disponível para continuar."
- Pagamento confirmado: "Pagamento confirmado", "Pedido #PED-88213 • Lionel Messi • R$ 1.788,40", "O vendedor tem até 2 dias para enviar a carta. Você recebe o código de rastreio por e-mail e acompanha tudo em Meus pedidos.", "Ver pedido", "Continuar comprando".
- Pagamento não concluído: "Pagamento não concluído", "Pedido #PED-88213 cancelado: pagamento não concluído", "O pagamento foi cancelado ou os 30 minutos de reserva acabaram. A carta voltou a ficar disponível e nada foi cobrado.", "Tentar de novo", "Voltar ao anúncio".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o checkout sempre mostra "2. CPF do comprador"; o caso de uso só pede o CPF quando o cadastro não tem (L9).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Voltar ao anúncio" em "Pagamento não concluído" (L6); "Continuar comprando" em "Pagamento confirmado" (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 o checkout de quem já tem CPF; R17 o aviso de carta esgotada antes do pagamento; o cadastro de endereço no checkout (L7); a espera pelo webhook na volta da Stripe (L5); a cotação carregando (CA15).

## Fora do escopo

- Perfil da carta e o restante do detalhe do anúncio (quantidade, vendedor, outros anúncios) — CCD030, CCD031, CCD079 e CCD080; fotos — CCD074; "Favoritar" — CCD056.
- Meus pedidos e o detalhe do pedido — CCD077.
- Gerar a etiqueta — CCD109; liberar o pagamento — CCD110; cancelar e reembolsar — CCD111; conectar a conta de recebimento — CCD108.
- Cadastrar e editar endereço no Perfil — CCD048.
- Pix e boleto (ADR-066, item 1); propostas e trocas (fora do MVP, ADR-027).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma mostra o número "#PED-88213"; o DBML não tem coluna de número do pedido (o `id` é UUID v7). Como gerar e guardar o número? (mesma pergunta da CCD077, L1) | pendente | — |
| L2 | Reserva de 30 minutos: o DBML não tem coluna de reserva. Reservar = baixar `available_quantity` ao criar o pedido e devolver ao cancelar? O anúncio com 0 fica "esgotado", que não existe em `listing_status` (`ACTIVE`, `PAUSED`, `CLOSED`)? | pendente | — |
| L3 | `orders.shipping_method` (obrigatório) e `orders.shipping_service` (ADR-067): o que vai em cada um? (proposta: `shipping_method` = transportadora, ex. "Correios"; `shipping_service` = id do serviço no Melhor Envio, ex. SEDEX) | pendente | — |
| L4 | Cancelar na página da Stripe: o caso de uso cancela o pedido na hora (FA 6–7), mas a Stripe só envia `checkout.session.expired` quando a sessão expira. Expirar a sessão pela API quando o cliente volta pelo `cancel_url`? (proposta: sim) | pendente | — |
| L5 | O cliente pode voltar da Stripe antes do `checkout.session.completed` chegar, com o pedido ainda `AWAITING_PAYMENT`. O que a tela mostra enquanto espera? Não há desenho. E "Continuar comprando" (só no Figma) leva para onde? | pendente | — |
| L6 | "Tentar de novo" cria outro pedido do mesmo anúncio (volta ao checkout)? E se o anúncio esgotou? "Voltar ao anúncio" (só no Figma) faz sentido? | pendente | — |
| L7 | "+ Cadastrar novo endereço" no checkout: abre o formulário do Perfil (`1160-39672`, CCD048) ou um próprio do checkout? Não há desenho | pendente | — |
| L8 | Pré-seleção: o Figma mostra o primeiro endereço e o "Correios SEDEX" marcados. Qual endereço e qual frete vêm marcados? (proposta: o endereço principal e nenhum frete) | pendente | — |
| L9 | CPF: o Figma sempre mostra o bloco "2. CPF do comprador"; com CPF no cadastro, o bloco some (FP 3)? Qual validação (dígitos verificadores) e qual mensagem quando o CPF já é de outra conta (`users.cpf` é único)? | pendente | — |
| L10 | Vendedor sem endereço principal (sem CEP de origem): o anúncio pode estar ativo? O checkout faz o quê? | pendente | — |
| L11 | Texto do e-mail ao vendedor e se ele também recebe uma notificação no site (tipo novo em `notifications.type`, ADR-051, item 2). O caso de uso só fala em e-mail | pendente | — |
| L12 | Melhor Envio fora do ar ou com erro: mostra o mesmo aviso de "sem frete" ou outro? | pendente | — |
| L13 | O "Entre para continuar" do anúncio usa o mesmo modal do perfil da carta (`1112-5461`)? Não há frame sobre o detalhe do anúncio | pendente | — |
| L14 | Pagamento de pedido cancelado por expiração: `payments.status` fica `REJECTED` ou continua `PENDING`? | pendente | — |
