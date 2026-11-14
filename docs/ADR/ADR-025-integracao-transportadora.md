# ADR-025 — Integração com transportadora terceirizada para entrega física

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard; validação: Felipe Consulim (PO)

## Contexto

O Diagrama de Contexto define "Transportadora" como sistema externo, "empresa terceirizada
responsável pela entrega física das cartas compradas no marketplace". No C4 Nível 3, o Módulo de
Pagamentos e Pedidos "solicita entrega da carta via" essa transportadora.

## Decisão

Delegar toda a logística de entrega física (coleta, transporte, rastreamento) a uma transportadora
terceirizada integrada via API/serviço externo, sem gestão própria de frota ou centro de
distribuição.

## Alternativas consideradas

- **Retirada em ponto físico apenas** (sem entrega), eliminando a integração.
- **Marketplace de frete com múltiplas transportadoras** (ex.: Melhor Envio, Frenet), permitindo
  ao vendedor escolher a transportadora por pedido.
- **Processo manual** (vendedor gera etiqueta por conta própria, sem integração automática).

## Consequências

**Positivas**
- Sem necessidade de operar logística própria, reduzindo escopo do MVP.

**Negativas / riscos**
- A transportadora específica não está definida, nem o contrato/API de integração — bloqueia o
  detalhamento do fluxo "Solicitar entrega" no Módulo de Pagamentos e Pedidos.
- Acoplamento a um único fornecedor externo sem alternativa definida em caso de indisponibilidade.

## Referências

- `docs/Diagramas/Diagramas-C4/01-contexto.puml`
- `docs/Diagramas/Diagramas-C4/02-containers.puml`
- `docs/Diagramas/Diagramas-C4/03-componentes.puml`
