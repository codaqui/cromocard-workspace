# ADR-067 — Frete, etiqueta e rastreio pelo Melhor Envio

- **Status:** Aceito (validado pelo PO, Felipe Consulim, em 2026-11-23)
- **Data:** 2026-11-20
- **Decisores:** Daniel Andrade (proposta); validação: Felipe Consulim (PO)

## Contexto

O ADR-025 decidiu terceirizar a entrega, sem escolher a transportadora nem a forma de integração. A fatia mínima do
marketplace precisa cotar o frete no checkout (CCD072), gerar a etiqueta com o vendedor como remetente (CCD109) e
saber quando a carta foi entregue, para liberar o pagamento (CCD110). A API dos Correios exige contrato; o Melhor
Envio cota e gera etiquetas de várias transportadoras numa API só e tem sandbox com saldo fictício, em que a etiqueta
muda de status sozinha até "entregue".

## Decisão

1. **Integração:** Melhor Envio, no sandbox em homologação, atrás do `ShippingProvider` do ADR-009. No PC de cada
   pessoa e nos testes, um provider falso com frete fixo e entrega simulada.
2. **Autenticação:** OAuth2. A conta da plataforma autoriza o app uma vez; o `access_token` (30 dias) e o refresh
   (45 dias) ficam em secret do ambiente. A renovação automática fica no plano.
3. **Cotação:** por CEP de origem (endereço principal do vendedor), CEP de destino e pacote padrão de uma carta:
   envelope de 16 × 11 × 2 cm e 100 g, com valor declarado igual ao preço da carta. Opções exibidas: Correios e
   Jadlog.
4. **Etiqueta:** colocada no carrinho e comprada no mesmo passo ("Gerar etiqueta"), paga com o saldo da conta da
   plataforma, como envio **não comercial** com declaração de conteúdo (sem nota fiscal), com o CPF do vendedor como
   remetente e o do comprador como destinatário.
5. **Entrega:** webhook do app (`order.posted`, `order.delivered`), com a assinatura `X-ME-Signature` (HMAC-SHA256
   do corpo) conferida; resposta `200` imediata e processamento idempotente. Uma consulta periódica do status da
   etiqueta cobre o aviso que se perder.
6. **Dados guardados:** `orders.shipping_service`, `shipping_label_id`, `tracking_code`, `tracking_url`,
   `shipped_at` e `delivered_at`.

## Alternativas consideradas

- **API dos Correios direto:** exige contrato e só cobre os Correios.
- **Frete fixo e rastreio digitado pelo vendedor:** mais simples, mas a entrega não seria confirmada pela
  transportadora.

## Consequências

**Positivas**
- O código de rastreio vem da etiqueta: o vendedor não digita nada.
- A demonstração anda sozinha no sandbox (cerca de 30 minutos da etiqueta à entrega).

**Negativas / riscos**
- O webhook só dispara para etiquetas geradas pelo mesmo app e precisa de endereço público (só em homologação).
- O CPF do comprador passa a ser obrigatório na primeira compra.
- O ADR-025 fica decidido por este ADR.

## Referências

- ADR-009, ADR-025, ADR-027, ADR-066
- Casos de uso 72, 109 e 110
- https://docs.melhorenvio.com.br/docs/webhooks
