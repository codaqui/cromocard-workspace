# ADR-068 — Remover avaliações e propostas do projeto

- **Status:** Proposto (aguardando validação do PO)
- **Substitui parcialmente:** ADR-010 (job de expirar propostas), ADR-015 (item 4) e ADR-054 (item 1)
- **Data:** 2026-11-22
- **Decisores:** Daniel Andrade (pedido em 22/11/2026); validação pendente do PO, Felipe Consulim

## Contexto

Quatro casos de uso não têm tela no Figma ou repetem outro caso de uso:

- **CCD081 Visualizar Avaliações:** as telas de avaliações do vendedor foram para o Arquivo do Figma em 20/11/2026, e
  nenhuma tela ativa deixa o comprador dar nota.
- **CCD089 Visualizar Propostas:** as telas de propostas recebidas também foram para o Arquivo em 20/11/2026. Nenhuma
  tela deixa o comprador fazer uma proposta, e o ADR-027 já mantinha propostas fora do MVP.
- **CCD070 Ordenar por Avaliações:** sem avaliações, não há por que ordenar.
- **CCD033 Buscar por Vendedor:** é a mesma funcionalidade da CCD067.

Mesmo assim, o DER guarda `offers`, `reviews` e o enum `offer_status`, e três ADRs aceitos citam essas tabelas:

- o ADR-054, item 1, manda a CCD097 criar `reviews` para calcular a reputação do vendedor;
- o ADR-010 prevê o job de expirar `offers` pendentes;
- o ADR-015, item 4, lista `reviews` e `offers` entre as tabelas de histórico.

Sem uma tela que grave nota, a reputação da CCD097 ficaria sempre vazia.

## Decisão

1. Remova do projeto a CCD033, a CCD070, a CCD081 e a CCD089, com o caso de uso, a user story, a aba da planilha, os
   diagramas e a spec de cada uma. Os números não são reaproveitados. No Azure, a user story #348 (CCD089) vai para
   `Removed`.
2. Remova do DER as tabelas `offers` e `reviews` e o enum `offer_status`, com as 5 FKs ligadas a elas. Isso vale para os
   três `.dbml`, os prints e o diagrama de classes, de onde saem `Proposta`, `Avaliação` e `StatusProposta`. O DER fica
   com 48 tabelas, 85 FKs e 26 enums.
3. Este ADR substitui somente estes trechos dos ADRs aceitos:
   - **ADR-054, item 1:** a CCD097 cria `listings`, `orders`, `payments` e `price_history`, sem `reviews`, e a lista de
     vendedores da CCD097 perde a coluna de reputação;
   - **ADR-010:** sai o job "Expirar `offers` pendentes";
   - **ADR-015, item 4:** `reviews` e `offers` saem da lista de tabelas de histórico.

   O resto de cada um continua valendo.
4. A CCD034, a CCD067 e a CCD082 tinham parte da tela no Figma. As telas foram completadas no Figma em 22/11/2026, e as
   três passam a ser MVP.
5. Puxe para o MVP as seis stories futuras que já tinham tela completa no Figma: CCD032, CCD037, CCD038, CCD073, CCD076 e
   CCD083. Com isso, nenhuma story com spec fica fora do MVP.

## Alternativas consideradas

- **Manter `reviews` no DER, sem uso:** a CCD097 continuaria mostrando uma reputação que nunca recebe dados. É uma
  tabela morta, que confunde quem implementa.
- **Desenhar as telas de avaliação e de proposta:** aumenta o escopo do marketplace, que o ADR-027 manteve mínimo.

## Consequências

- O marketplace fica só com anúncio, compra, envio e liberação do pagamento, sem nota nem negociação.
- Todas as specs do plano final passam a ser MVP. Isso aumenta o trabalho da equipe até a entrega.
- **CCD097 (Aprovada):** sai a coluna de reputação. A spec registra a mudança, e o PO valida este ADR.
- **CCD080:** o perfil público do vendedor fica sem nota (a L2 dela já propunha isso).
- **Volta no futuro:** avaliações ou propostas pedem casos de uso novos, telas no Figma e um ADR que reintroduza as
  tabelas.

## Referências

- `docs/Diagramas/DER/03-der-completo.dbml`; ADR-010, ADR-015, ADR-027, ADR-054
- Figma: seção "Arquivo (versões antigas e referências)", frames `675-5041`, `675-5692` e `675-9717`
