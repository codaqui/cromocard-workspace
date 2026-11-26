# ADR-071 — Webhook da conta conectada reconsulta a Stripe

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-25
- **Decisores:** Felipe Consulim (PO), na revisão do backend codaqui/cromocard-backend#45; registro: workspace PR #59
- **Complementa:** ADR-066 (item 6)

## Contexto

O item 6 do ADR-066 pede que cada evento do webhook da Stripe seja processado uma vez só, com a idempotência garantida pelo
id do evento. Para isso seria preciso guardar os ids já processados, e o DBML não tem tabela para eles.

Na CCD108 (Conectar Conta de Recebimento), a proposta da lacuna L6 foi tratar o `account.updated` como idempotente por
natureza e gravar o estado que vem no próprio evento. Só que a Stripe não garante a ordem de entrega dos eventos. Se um
`account.updated` antigo (em verificação) chegar depois de um novo (conta pronta), a conta volta a "em verificação", e o
vendedor fica sem poder anunciar até outro evento chegar.

## Decisão

1. **O evento só avisa.** O `account.updated` não usa o estado que vem no evento. Ele acha o vendedor pelo
   `stripe_account_id`, reconsulta a conta na Stripe (`PaymentProvider.getConnectedAccount`) e grava o estado atual.
2. **Sem tabela de eventos.** Repetir o evento, ou receber eventos fora de ordem, grava sempre o estado atual. O id do
   evento vai para o log.
3. **Assinatura conferida.** O evento sem a assinatura válida do segredo do webhook continua recusado com `400`
   (ADR-066).
4. **Alcance.** A regra vale para os eventos que só informam o estado de um recurso que pode ser consultado, como a conta
   conectada. Os eventos de checkout e pagamento (CCD072) continuam seguindo o item 6 do ADR-066.

## Alternativas consideradas

- **Gravar o estado que veio no evento (proposta da L6):** simples, mas um evento atrasado rebaixa a conta.
- **Tabela de eventos processados:** resolve a repetição, mas não a ordem, e cria uma tabela fora do DER só para isso.
- **Comparar o `created` do evento com o último gravado:** exige uma coluna nova e ainda depende do conteúdo do evento.

## Consequências

- Cada `account.updated` faz uma chamada à API da Stripe. O volume é baixo, porque só acontece quando a conta do vendedor
  muda.
- Se a Stripe estiver fora do ar na reconsulta, o webhook responde erro, e a Stripe reenvia o evento depois.
- A spec da CCD108 (R6, CA5, L6) e o plano dela seguem esta decisão.
- Se o PO recusar este ADR, a L6 volta a ser lacuna e o webhook da CCD108 precisa de outra regra antes do merge do backend.

## Referências

- ADR-066 (item 6), ADR-047
- `specs/CCD108-conectar-conta-de-recebimento/` (R6, CA5, L6)
- Revisão do backend codaqui/cromocard-backend#45 e do workspace PR #59
