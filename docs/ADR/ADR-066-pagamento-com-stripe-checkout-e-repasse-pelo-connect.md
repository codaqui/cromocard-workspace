# ADR-066 — Pagamento com Stripe Checkout, valor retido na plataforma e repasse pelo Connect

- **Status:** Proposto
- **Data:** 2026-11-20
- **Decisores:** Daniel Andrade (proposta); validação: Felipe Consulim (PO)

## Contexto

O ADR-024 decidiu terceirizar o pagamento a um gateway, sem escolher qual. A fatia mínima do marketplace (CCD072,
CCD108, CCD110, CCD111) precisa cobrar o comprador, reter o valor até a carta ser entregue e repassar ao vendedor o
valor menos a taxa de 5%. O projeto roda só em homologação até a entrega, sem dinheiro real, e não pode depender de
aprovação comercial de um gateway. Pagar.me exige contrato de PSP para dividir pagamentos e o Asaas só cria subcontas
a partir de conta com CNPJ; a Stripe libera o modo de teste na hora e aceita cobranças e transferências separadas no
Brasil.

## Decisão

1. **Gateway:** Stripe, em modo de teste em homologação. Só cartão: Pix e boleto ficam fora.
2. **Cobrança:** Stripe Checkout hospedado. O backend cria a sessão (`mode: payment`, moeda `brl`, uma linha com a
   carta e outra com o frete, `expires_at` de 30 minutos) e redireciona o comprador para a URL da sessão.
3. **Retenção:** a cobrança é feita na conta da plataforma ("cobranças e transferências separadas"). O valor fica no
   saldo da plataforma até a liberação (CCD110).
4. **Repasse:** cada vendedor tem uma conta conectada **Express**, criada pela API e completada na página de cadastro
   da Stripe (CCD108). A liberação cria uma `Transfer` para a conta conectada com o valor da carta menos 5%
   (arredondado para baixo, a favor do vendedor), `source_transaction` = id da cobrança (obrigatório no Brasil) e
   `transfer_group` = id do pedido. O frete não é repassado: paga a etiqueta (ADR-067).
5. **Conta pronta:** a conta conectada fica "pronta" quando a Stripe informa que ela pode receber transferências
   (evento `account.updated`). Sem conta pronta, o vendedor não publica anúncio.
6. **Webhooks:** `checkout.session.completed` (pedido Pago), `checkout.session.expired` (pedido Cancelado e carta de
   volta ao estoque), `account.updated` (estado da conta conectada). Toda chamada tem a assinatura conferida com o
   segredo do webhook e é processada uma vez só (idempotente pelo id do evento).
7. **Reembolso:** o administrador pode cancelar e reembolsar um pedido enquanto o valor não foi liberado (CCD111),
   pela API de reembolso da Stripe.
8. **Dados guardados:** `payments.gateway_reference` = id da sessão do Checkout; `payments.charge_id` = id da
   cobrança; `users.stripe_account_id` e `users.stripe_account_status`; `orders.stripe_transfer_id` e
   `orders.platform_fee`.
9. **Provider:** a Stripe fica atrás do `PaymentProvider` do ADR-009, com uma implementação falsa para os testes.

## Alternativas consideradas

- **Pagar.me:** a divisão de pagamentos exige cliente PSP, com contrato comercial.
- **Asaas:** a Conta Escrow encaixaria, mas subcontas só saem de conta com CNPJ, e não está claro se a Conta Escrow
  funciona no sandbox.
- **Mercado Pago:** a divisão acontece no pagamento e o dinheiro vai direto ao vendedor; reter até a entrega não é o
  fluxo padrão.
- **Registrar o repasse só no banco, sem transferência:** mais simples, mas o vendedor nunca receberia de fato.

## Consequências

**Positivas**
- Nada de dado de cartão no CromoCard (a página é da Stripe).
- O fluxo inteiro roda em homologação sem dinheiro e sem aprovação.

**Negativas / riscos**
- Produção exigiria ativar a conta Stripe e revisar a regulação de guardar dinheiro de terceiros.
- Webhook só chega em endereço público: no PC de cada pessoa é preciso a Stripe CLI (`stripe listen`).
- A tarifa da Stripe de cada cobrança sai dos 5% da plataforma: o vendedor recebe o valor da carta menos 5%, e o que
  sobra para a plataforma é a taxa menos a tarifa.
- O ADR-024 fica decidido por este ADR.

## Referências

- ADR-009, ADR-024, ADR-027
- Casos de uso 72, 84, 108, 110 e 111
- https://docs.stripe.com/connect/separate-charges-and-transfers
