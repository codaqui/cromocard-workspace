# ADR-054 — Tabelas do marketplace criadas para os indicadores financeiros

- **Status:** Aceito (validado pelo PO em 22/10/2026, na aprovação da spec CCD097)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

O ADR-027 deixou o marketplace fora do MVP: as user stories `***` (comprar, anúncios, pedidos, avaliações) ficam
para depois e as tabelas `listings`, `orders`, `payments`, `reviews` e `price_history` existem só no DER. A user
story CCD097 (Visualizar Indicadores Financeiros), do escopo adicional puxado para a Sprint 06, mostra custódia,
valor liquidado, valor retido, volume e reputação de vendedores, população e preço médio de cartas e volume por
grupo. Todos esses números saem dessas tabelas, que ainda não estão no banco.

## Decisão

1. A CCD097 cria `listings`, `orders`, `payments`, `reviews` e `price_history` no banco, copiadas do DBML, uma
   migration por tabela.
2. Nesta fase as tabelas são **só de leitura** para a aplicação: nenhum caso de uso grava nelas, e os dados vêm do
   seed (`database/seeds/marketplace.seed.ts`).
3. Quando o marketplace entrar (CCD072 e seguintes), as stories dele passam a gravar nessas mesmas tabelas, sem
   migration nova para criá-las.

## Alternativas consideradas

- **Deixar a CCD097 para depois do marketplace:** era o caminho natural, mas o PO puxou o escopo adicional inteiro
  para a Sprint 06.
- **Tabelas próprias de indicadores (agregados):** evitariam criar as tabelas do marketplace, mas duplicariam o
  modelo e teriam de ser trocadas quando o marketplace existir.

## Consequências

- O `schema.prisma` ganha 5 tabelas antes das stories que as usam para gravar; o DER não muda.
- Os indicadores mostram os dados do seed até o marketplace existir.
- O ADR-027 continua valendo para as funcionalidades do marketplace.

## Referências

- ADR-027 (marketplace no MVP), ADR-053 (escopo adicional)
- `specs/CCD097-visualizar-indicadores-financeiros/` (lacuna L2)
