# ADR-027 — Escopo do Marketplace no MVP

- **Status:** Proposto (proposta definida em 18/11/2026; aguarda a validação do PO)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

> Este ADR é diferente dos demais: não documenta uma escolha já implícita nos diagramas, e sim
> uma **inconsistência não resolvida** entre os artefatos, que precisa virar decisão formal do PO.

## Contexto

`Apresentacao-Banca/plano-apresentacao-banca.md` (item 8 da seção "Inconsistências encontradas")
identifica o seguinte conflito:

- As user stories do Marketplace **comprador** (compra, anúncios, pedidos, avaliações) estão
  marcadas com `***` (tag `futuro-marketplace`), ou seja, fora do MVP.
- As 10 user stories do **Painel do Vendedor** não têm nenhum marcador, ou seja, estariam no MVP.
- O C4 (Nível 1 e 2) já inclui o Gateway de Pagamento e a Transportadora como sistemas externos
  integrados desde já, sem distinguir MVP de futuro.

Ou seja, os artefatos hoje descrevem cenários incompatíveis entre si sobre se o marketplace faz
parte da primeira entrega.

## Decisão

Proposta definida em 18/11/2026 (alternativa 4, abaixo): entra no MVP uma **fatia mínima** do marketplace, de
ponta a ponta, só em homologação e em modo de teste:

- **Comprar:** explorar o marketplace, ver o anúncio e pagar com cartão pelo Stripe Checkout (ADR-063). O valor fica
  retido na plataforma.
- **Vender:** criar o anúncio a partir do catálogo, conectar a conta de recebimento na Stripe e gerar a etiqueta pelo
  Melhor Envio (ADR-064).
- **Liberar:** com a entrega confirmada pelo rastreio, o valor menos a taxa de 5% vai para o vendedor quando o
  comprador confirma o recebimento ou 7 dias depois da entrega.
- **Administrar:** o BackOffice acompanha os pedidos e pode cancelar com reembolso ou liberar na hora (CCD111).

As user stories da fatia perderam a marca `***` (CCD068, 069, 071, 072, 074, 075, 078, 079 e 080) e ganharam as
novas CCD108–111. Continuam fora do MVP: propostas e trocas, avaliações, saque via Pix, denúncias do marketplace e o
restante marcado `***`.

## Alternativas consideradas

1. **Marketplace completo (compra + venda) no MVP.**
2. **Marketplace inteiramente fora do MVP**, incluindo o Painel do Vendedor.
3. **Painel do Vendedor no MVP, fluxo de compra/pagamento pós-MVP** (proposta inicial deste ADR, de 29/09/2026).
4. **Fatia mínima de compra, envio e liberação no MVP** (escolhida): entrega o fluxo de custódia de ponta a ponta com o menor esforço, sem propostas, trocas nem avaliações.

## Consequências

Esta decisão impacta diretamente:

- **ADR-024** (gateway de pagamento) e **ADR-025** (transportadora) — se ficarem fora do MVP,
  essas integrações não precisam estar prontas na primeira entrega.
- O cronograma de sprints e o corte de escopo do board no Azure DevOps.
- Os slides 9, 12 e 16 da apresentação de banca (`Apresentacao-Banca/`), hoje marcados como
  pendentes exatamente por causa desta indefinição.

## Referências

- `Apresentacao-Banca/plano-apresentacao-banca.md` (seção 3, item 8, e checklist da seção 4)
- `docs/Casos-De-Uso/user-stories.md` (legenda de fases: `mvp`, `futuro`, `futuro-marketplace`)
- `docs/Diagramas/Diagramas-C4/01-contexto.puml` e `02-containers.puml`
