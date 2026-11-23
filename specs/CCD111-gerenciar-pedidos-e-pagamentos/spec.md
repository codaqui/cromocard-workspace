# CCD111 — Gerenciar Pedidos e Pagamentos

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace desde 18/11/2026: legenda de `user-stories.md` e ADR-027)
- **User story:** #923 `CCD111-Gerenciar Pedidos e Pagamentos`
- **Caso de uso:** [111-gerenciar-pedidos-e-pagamentos.md](../../docs/Casos-De-Uso/111-gerenciar-pedidos-e-pagamentos.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero acompanhar os pedidos e pagamentos do marketplace e cancelar com reembolso ou liberar o pagamento de um pedido para resolver problemas entre comprador e vendedor.

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
| R1 | Só `ADMIN`: `401` sem token, `403` para outro papel | Permissão | `111`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Item "Pedidos e pagamentos" no menu do BackOffice, logo abaixo de Catálogo | Tela | `111`, FP 1; `escopo-adicional.md`, BackOffice, pedidos e pagamentos (20/11/2026) |
| R3 | Totais: em custódia, a liberar nos próximos 7 dias, liberado no mês e repasses pendentes | Tela | `111`, FP 2 (L1) |
| R4 | Lista de pedidos do mais recente para o mais antigo, com número, data, carta, comprador, vendedor, valor e status (Aguardando pagamento, Pago, Enviado, Entregue, Concluído ou Cancelado) | Tela | `111`, FP 2; DBML `orders`, `order_status` |
| R5 | Selo "Atrasado" no pedido Pago há mais de 2 dias sem etiqueta | Regra | `111`, FP 2; `109`, FA 2; DBML `orders.paid_at`, `shipping_label_id` |
| R6 | Filtro por status e busca pelo número do pedido, pelo comprador ou pelo vendedor atualizam a lista | Ação | `111`, FP 3–4 |
| R7 | O detalhe do pedido mostra a linha do tempo (pago, enviado, entregue e concluído, com as datas), o pagamento (valor da carta, frete, taxa de 5%, líquido do vendedor e os identificadores do pagamento e da transferência na Stripe) e o envio (serviço, código e link do rastreio) | Tela | `111`, FP 5–6; DBML `orders`, `payments` |
| R8 | "Cancelar e reembolsar" aparece no pedido Pago, Enviado ou Entregue e pede o motivo, avisando que o comprador recebe de volta o valor total (carta e frete) | Tela | `111`, FA 1–2 |
| R9 | Confirmado com o motivo, o sistema reembolsa pela Stripe, marca o pedido como Cancelado com o motivo, avisa o comprador e o vendedor por e-mail e registra a ação no log de auditoria | Ação | `111`, FA 3–4; ADR-066, item 7; ADR-034; ADR-059; DBML `orders.cancel_reason`, `payments.refunded_at` |
| R10 | Confirmar sem motivo não cancela e informa que o motivo é obrigatório ("O motivo é obrigatório.") | Mensagem | `111`, FA 5–6 |
| R11 | "Liberar agora" aparece no pedido Entregue (inclusive com repasse automático que falhou), pede a confirmação, transfere ao vendedor como na liberação normal, marca o pedido como Concluído e registra a ação no log de auditoria | Ação | `111`, FA 7–8; `110`, FP 6; ADR-034 |
| R12 | Pedido Concluído ou Cancelado não oferece ações e informa que o pedido já foi encerrado; a API responde `422` a qualquer ação nele | Regra | `111`, FA 9; ADR-011 |
| R13 | Busca ou filtro sem resultado mostra "Nenhum pedido encontrado" e oferece "Limpar filtros" | Estado | `111`, FA 10–11 |
| R14 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1157-29979`, `1157-30793`, `1157-31707`, `1157-32634`, `1157-33562`, `1157-34488`, `1157-35305`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** pedidos do seed em todos os status, um deles `PAID` há 3 dias sem etiqueta, **quando** o admin abre "Pedidos e pagamentos", **então** vê os 4 totais e a lista do mais recente para o mais antigo com número, data, carta, comprador, vendedor, valor e status, e o pedido atrasado tem o selo "Atrasado".
- **CA2** (R6) — **Dado** a lista aberta, **quando** o admin seleciona a aba "Entregue", **então** só aparecem pedidos `DELIVERED`; **quando** busca pelo nome de usuário de um vendedor, **então** só aparecem os pedidos dele; **quando** busca pelo número de um pedido, **então** só ele aparece.
- **CA3** (R7) — **Dado** um pedido `DELIVERED`, **quando** o admin seleciona "Ver", **então** o detalhe mostra pago, enviado e entregue com as datas e a liberação prevista, carta, frete, total, taxa de 5%, líquido do vendedor, o identificador do pagamento na Stripe, a transferência ("Aguardando liberação"), o serviço, o código e o link do rastreio.
- **CA4** (R8, R9) — **Dado** um pedido `DELIVERED` de R$ 1.788,40, **quando** o admin seleciona "Cancelar e reembolsar", escreve o motivo e confirma, **então** a Stripe (provider falso, nos testes) recebe o reembolso de R$ 1.788,40, o pedido fica `CANCELED` com `cancel_reason`, o pagamento fica `REFUNDED` com `refunded_at`, comprador e vendedor recebem o e-mail com o motivo, `audit_logs` registra a ação e a tela mostra "Pedido #… cancelado e reembolsado. O comprador e o vendedor foram avisados por e-mail."
- **CA5** (R10) — **Dado** o diálogo de cancelamento aberto, **quando** o admin confirma com o motivo vazio, **então** vê "O motivo é obrigatório.", nada é reembolsado e a API responde `400` se chamada direto.
- **CA6** (R11) — **Dado** um pedido `DELIVERED` com a liberação automática falhada, **quando** o admin seleciona "Liberar agora" e confirma, **então** a transferência de carta menos 5% é criada para a conta do vendedor, o pedido fica `COMPLETED` com `stripe_transfer_id` e `released_at`, e `audit_logs` registra a ação.
- **CA7** (R8, R11) — **Dado** um pedido `PAID`, **quando** o admin abre o detalhe, **então** vê "Cancelar e reembolsar" e não vê "Liberar agora"; **dado** um `DELIVERED`, vê os dois.
- **CA8** (R12) — **Dado** um pedido `COMPLETED` ou `CANCELED`, **quando** o admin abre o detalhe, **então** não vê nenhuma ação e vê o aviso de pedido encerrado; chamando a API direto, ela responde `422`.
- **CA9** (R13) — **Dado** a busca "CC-99999" sem pedido correspondente, **quando** o admin busca, **então** vê "Nenhum pedido encontrado", "Confira o número do pedido ou o nome de usuário, ou limpe os filtros." e "Limpar filtros", que volta à lista completa.
- **CA10** (R1) — **Dado** um visitante sem login, **quando** chama qualquer rota de pedidos do admin, **então** recebe `401`; **dado** um `CUSTOMER` ou `SELLER`, recebe `403`.
- **CA11** (R9) — **Dado** a Stripe recusando o reembolso, **quando** o admin confirma o cancelamento, **então** vê o erro, o pedido continua no status anterior e nada é registrado como cancelado.
- **CA12** (R4) — **Dado** a lista carregando, **quando** a tela abre, **então** mostra o carregamento; se a API falhar, mostra o erro com a opção de tentar de novo.
- **CA13** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-29979` (Pedidos e pagamentos), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-30793` (detalhe do pedido), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA15** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-31707` (cancelar e reembolsar), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA16** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-32634` (motivo obrigatório), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA17** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-33562` (liberar agora), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA18** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-34488` (operação concluída), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA19** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1157-35305` (nenhum pedido encontrado), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `id`, `listing_id`, `buyer_id`, `seller_id`, `items_amount`, `shipping_amount`, `total_amount`, `shipping_service`, `status` (`order_status`), `shipping_label_id`, `tracking_code`, `tracking_url`, `platform_fee`, `stripe_transfer_id`, `cancel_reason`, `paid_at`, `shipped_at`, `delivered_at`, `released_at`, `created_at` | `cancel_reason` varchar(255); `CANCELED` no reembolso; `COMPLETED` no "Liberar agora" |
| `payments` | `order_id`, `value`, `status` (`payment_status`: `APPROVED` → `REFUNDED`), `gateway_reference`, `charge_id`, `refunded_at` | `gateway_reference` = sessão do Checkout; `charge_id` = cobrança (ADR-066, item 8; L5) |
| `users` | `name`, `username`, `email`, `stripe_account_status` | comprador e vendedor; e-mails do cancelamento |
| `listings` / `cards` | `card_id`; `name`, `front_image_url` | carta da linha |
| `audit_logs` | `admin_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address` | uma linha por cancelamento e por liberação (ADR-034; nomes das ações no plano) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Administração - pedidos e pagamentos | [1157-29979](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-29979) | R2–R6 | ✅ Bate (salvo L1–L4) |
| Administração - pedidos e pagamentos - detalhe do pedido | [1157-30793](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-30793) | R7, R8, R11 | ✅ Bate (salvo L5, L6) |
| Administração - pedidos e pagamentos - cancelar e reembolsar | [1157-31707](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-31707) | R8, R9 | ✅ Bate |
| Administração - pedidos e pagamentos - cancelar e reembolsar - motivo obrigatório | [1157-32634](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-32634) | R10 | ✅ Bate |
| Administração - pedidos e pagamentos - liberar agora | [1157-33562](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-33562) | R11 | ✅ Bate |
| Administração - pedidos e pagamentos - operação concluída | [1157-34488](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-34488) | R9 | ✅ Bate |
| Administração - pedidos e pagamentos - nenhum pedido encontrado | [1157-35305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1157-35305) | R13 | ✅ Bate |

- Lista: "BACKOFFICE • MARKETPLACE", "Pedidos e pagamentos", "Acompanhe o pagamento, o envio e o repasse de cada pedido e
  resolva as exceções.", totais "Em custódia" ("23 pedidos"), "A liberar em 7 dias" ("9 pedidos entregues"), "Liberado no
  mês" ("38 pedidos concluídos") e "Repasses pendentes" ("Falha na transferência"); "Buscar por pedido, comprador ou
  vendedor", "Período: Últimos 30 dias ▾", abas com contagem, "PEDIDOS" com "8 de 312 pedidos", colunas "Pedido", "Carta",
  "Comprador e vendedor" ("vendido por @…"), "Valor" e "Status" (selo e linha de apoio: "Libera em 25/11", "Sem etiqueta há
  3 dias", "Falha na Stripe", "Reembolsado", "Reserva até 10:42"…), selos "Atrasado" e "Repasse pendente", "Ver", e a
  paginação "Mostrando 1 a 8 de 312 pedidos", "Anterior", "Próximo".
- Detalhe (painel lateral): "PEDIDO", número e selo, carta com "<categoria> • <álbum> • <condição>", "Linha do tempo" (Pago,
  "Etiqueta gerada e enviado", Entregue, "Liberação automática" "Prevista para … (7 dias após a entrega)"), "Pagamento"
  (Carta, "Frete (<serviço>)", "Total pago pelo comprador", "Taxa CromoCard (5%)", "Líquido do vendedor", "Pagamento na
  Stripe", "Transferência"), "Envio" ("Serviço", "Código de rastreio", "Abrir rastreio no Melhor Envio ↗"), "Comprador e
  vendedor", "Cancelar e reembolsar", "Liberar agora" e "Cancelar e reembolsar fica disponível até a liberação. Depois de
  Concluído, o pedido não tem mais ações."
- Diálogos: "Cancelar e reembolsar o pedido #…?", "O comprador recebe de volta R$ … (carta e frete) no cartão usado na
  compra. O pedido fica Cancelado e nada é transferido ao vendedor. Essa ação não pode ser desfeita.", "Motivo
  (obrigatório)", "Descreva o motivo do cancelamento (o comprador e o vendedor recebem este texto por e-mail)", "Voltar",
  "Cancelar e reembolsar", "O motivo é obrigatório."; "Liberar o pagamento agora?", "R$ … vão para a conta Stripe de @…
  (R$ … da carta menos a taxa de 5%). O pedido fica Concluído e não pode mais ser cancelado.", "Use quando o comprador
  confirmou fora da plataforma ou quando o repasse automático falhou.", "Voltar", "Liberar agora".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): número do pedido "#CC-10482" aqui e "#PED-…" no site (L3).
  "Pagamento na Stripe" mostra um id `pi_…` (PaymentIntent); o DBML guarda a sessão do Checkout e a cobrança (L5).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): filtro "Período: Últimos 30 dias" e contagem nas
  abas (L2); selo "Repasse pendente" e as linhas de apoio do status (L4); bloco "Comprador e vendedor" e a linha
  "<categoria> • <álbum> • <condição>" (L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R12 o detalhe de pedido encerrado, sem ações, com o
  aviso (L7); o retorno de sucesso de "Liberar agora" (L8); o erro do reembolso ou da transferência na Stripe.

## Fora do escopo

- Indicadores financeiros do Dashboard — CCD097 (custódia, liquidado e retido).
- Liberação automática e confirmação do comprador — CCD110 (aqui só o "Liberar agora").
- Gerar a etiqueta — CCD109; checkout e pagamento — CCD072.
- Exportar os pedidos em relatório — não está no caso de uso.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Como calcular cada total? (proposta: "Em custódia" = soma de `total_amount` dos pedidos `PAID`, `SHIPPED` e `DELIVERED`, alinhada à CCD097, R2, que hoje só conta `PAID` e `SHIPPED`; "A liberar em 7 dias" = líquido dos `DELIVERED` com liberação nos próximos 7 dias; "Liberado no mês" = líquido dos `COMPLETED` com `released_at` no mês; "Repasses pendentes" = quantidade de `DELIVERED` com a liberação vencida e sem transferência) | pendente | — |
| L2 | Filtro "Período: Últimos 30 dias" e a contagem em cada aba só existem no Figma. Faz sentido implementar? O período afeta os totais? (proposta: sim aos dois; o período filtra só a lista, por `created_at`) | pendente | — |
| L3 | O DBML não tem número legível do pedido, e o Figma usa "#CC-10482" aqui e "#PED-…" no site. Qual formato? (mesma pergunta da CCD109, L6) | pendente | — |
| L4 | Selo "Repasse pendente" e as linhas de apoio do status ("Libera em …", "Correios PAC", "Sem etiqueta há 3 dias", "Prazo até …", "Falha na Stripe", "Liberado em …", "Reembolsado", "Reserva até …") só existem no Figma. Faz sentido implementar? (proposta: sim; "Falha na Stripe" depende da CCD110, L5) | pendente | — |
| L5 | Qual identificador aparece em "Pagamento na Stripe": o `pi_…` do Figma (não guardado), a sessão (`gateway_reference`) ou a cobrança (`charge_id`)? (proposta: `charge_id`, sem coluna nova; o Gabriel ajusta o exemplo) | pendente | — |
| L6 | Bloco "Comprador e vendedor" (nome, @usuário, "conta Stripe pronta") e a linha "<categoria> • <álbum> • <condição>" no detalhe não estão no FP 6. Faz sentido implementar? (proposta: sim) | pendente | — |
| L7 | Texto do aviso de pedido encerrado (FA 9), sem frame (proposta: "Pedido encerrado: não há ações disponíveis.") | pendente | — |
| L8 | Texto do sucesso de "Liberar agora", sem frame (proposta: "Pagamento do pedido #… liberado. O vendedor foi avisado por e-mail.") | pendente | — |
| L9 | No cancelamento de um pedido Enviado, a etiqueta é cancelada no Melhor Envio? A carta volta ao estoque do anúncio? (proposta: não cancelar a etiqueta já postada; devolver a unidade ao estoque só se o pedido não foi enviado) | pendente | — |
| L10 | "Liberar agora" sem a conta do vendedor pronta: bloqueia com aviso? (proposta: sim, `422` com "A conta Stripe do vendedor não está pronta") | pendente | — |
| L11 | A busca pelo comprador ou vendedor é por nome de usuário, nome ou e-mail? (proposta: nome de usuário e nome, sem diferenciar maiúsculas) | pendente | — |
| L12 | Quantos pedidos por página? O frame mostra 8 (proposta: 8, como no frame) | pendente | — |
| L13 | O caso 111 ganhou o selo e o filtro "Problema relatado", a descrição do problema no detalhe e o "Liberar agora" depois de resolver o problema (decidido pelo PO em 23/11/2026, CCD110 FA 4–7). Quais requisitos e critérios de aceite entram? O reembolso depois do envio (devolver a carta ou só o valor da carta, e quem paga a etiqueta) continua em aberto com o Daniel | pendente | — |
