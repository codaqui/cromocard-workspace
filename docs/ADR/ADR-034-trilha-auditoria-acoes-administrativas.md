# ADR-034 — Trilha de auditoria obrigatória para ações administrativas

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O `CLAUDE.md` (seção "Padrões de código") estabelece que "Ações administrativas devem gerar
registro em `log_auditoria`". O DER inclui `log_auditoria` no módulo 8 (Moderação e
Administração), rastreado ao caso de uso 65 "Log de Auditoria Admin"
(`docs/Diagramas/DER/README.md`).

## Decisão

Toda ação administrativa sensível (moderação de conteúdo, aprovação/rejeição de solicitação de
cadastro, alteração de configuração global, banimento de usuário, etc.) deve gravar um registro
em `log_auditoria`, de forma consistente em todos os módulos do backend.

## Alternativas consideradas

- **Log apenas em ferramenta externa de observabilidade** (ex.: agregador de logs), sem
  persistência em banco relacional.
- **Sem trilha de auditoria estruturada**, confiando apenas em logs de aplicação não indexados.

## Consequências

**Positivas**
- Rastreabilidade e compliance para ações sensíveis, essencial numa plataforma com marketplace,
  moderação de comunidade e dados pessoais de usuários.
- Base para o dashboard gerencial e para investigação de denúncias (caso de uso 65).

**Negativas / riscos**
- Overhead de escrita adicional em toda ação administrativa.
- Ainda não está definido, nos artefatos existentes, o schema exato de `log_auditoria` (quais
  campos: ator, ação, entidade afetada, payload antes/depois, timestamp) nem a política de
  retenção dos registros — esta ADR também sinaliza a necessidade de detalhar isso.

## Referências

- `CLAUDE.md` (seção "Padrões de código")
- `docs/Diagramas/DER/README.md` (módulo 8 — Moderação e Administração)
