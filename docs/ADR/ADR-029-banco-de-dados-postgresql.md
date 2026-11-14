# ADR-029 — Banco de dados relacional: PostgreSQL via Prisma ORM

- **Status:** Substituído por ADR-003 e ADR-014
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O `ContainerDb` do C4 é PostgreSQL, acessado via Prisma ORM por toda a API e pelo serviço de
tempo real. O DER (`docs/Diagramas/DER/`) modela 43 tabelas, 76 chaves estrangeiras e 22 enums,
com forte necessidade de integridade referencial (marketplace, pagamentos, pedidos) e uso de
recursos específicos do Postgres: `CREATE TYPE ... AS ENUM` e coluna `jsonb`
(`solicitacao_cadastro.dados`).

## Decisão

Usar PostgreSQL como único banco de dados do sistema, para todos os 8 módulos do domínio
(usuários, catálogo, coleção, comunidade, chat, marketplace, notificações, administração).

## Alternativas consideradas

- **MySQL/MariaDB** — relacional, mas com suporte mais limitado a enums nativos e `jsonb`.
- **Banco poliglota**: NoSQL (ex.: MongoDB) dedicado a chat/notificações, mantendo Postgres para
  o restante — descartado pela documentação atual, que centraliza tudo em um único
  `ContainerDb`.

## Consequências

**Positivas**
- Enums nativos e `jsonb` cobrem os casos especiais do modelo sem tabelas extras.
- Consistência ACID garantida para fluxos sensíveis (pagamento, pedido, estoque de anúncio).
- Integridade referencial via 76 FKs, incluindo os alvos polimórficos (ver ADR-032).

**Negativas / riscos**
- Todas as cargas caem no mesmo banco relacional, incluindo mensagens de chat em potencial alto
  volume — o serviço de tempo real e a API concorrem pelo mesmo `ContainerDb` sem estratégia de
  particionamento/réplica definida nos diagramas atuais.

## Referências

- `docs/Diagramas/Diagramas-C4/02-containers.puml`
- `docs/Diagramas/DER/README.md`
- `docs/Diagramas/DER/03-der-completo.dbml`
