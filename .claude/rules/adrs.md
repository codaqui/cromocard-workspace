---
paths:
  - "docs/ADR/**"
---

# ADRs

- Um ADR registra **uma** decisão. Modelo e índice em `docs/ADR/README.md`; nome do arquivo
  `ADR-NNN-titulo-em-minusculas.md`, com o próximo número livre.
- Crie um ADR quando: escolher uma tecnologia ou biblioteca nova; mudar algo que os diagramas (C4, DER, diagrama
  de classes) davam como decidido; ou resolver uma decisão que está em aberto (como o ADR-027, escopo do
  marketplace no MVP).
- **Todo ADR nasce `Proposto (aguardando validação do PO)`.** Só vira `Aceito`, `Rejeitado` ou
  `Substituído por ADR-XXX` depois que o usuário confirmar a validação. Nunca marque como aceito por conta própria.
- Não edite o conteúdo de um ADR aceito. Se a decisão mudar, crie um ADR novo com o campo
  `**Substitui:** ADR-XXX` (ou `Substitui parcialmente`) e, quando o novo for aceito, troque o status do antigo
  para `Substituído por ADR-YYY`. Num ADR aceito, só são permitidas essa troca de status e a correção de um
  caminho de arquivo que mudou de lugar (não muda a decisão e evita link quebrado); número ou contagem desatualizados
  não se corrigem no ADR, ficam no `CLAUDE.md` ou no README do artefato.
- Ao criar ou mudar o status de um ADR, atualize a linha dele no índice do `README.md` (número, área, decisão, status).
- Seções, nesta ordem: Contexto · Decisão (no imperativo) · Alternativas consideradas · Consequências ·
  Referências (opcional). Cite os ADRs relacionados pelo número e os arquivos de código pelo caminho.
- Decisão que já está no código (ex.: o esqueleto de um app) também vira ADR: descreva o que foi implementado,
  sem inventar justificativas que a equipe não deu.
