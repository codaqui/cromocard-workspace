# ADR-036 — Granularidade do diagrama de classes (1:1 com as tabelas do DER)

- **Status:** Aceito (validado pelo PO em 29/10/2026, na revisão da issue #2)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

A primeira versão do diagrama de classes (`blank.c4`) cobria só 16 classes — essencialmente a
fatia do Marketplace — deixando de fora módulos inteiros já modelados no DER (Comunidade, Chat
Pessoal, Notificações, Moderação/Administração) e tabelas de apoio técnico (`log_auditoria`,
`configuracao_global`, `token_recuperacao_senha`). Isso criava uma divergência de escopo entre o
DER (43 tabelas) e o diagrama de classes (16), que a banca tende a questionar — o mesmo tipo de
inconsistência de números já apontado em `Apresentacao-Banca/plano-apresentacao-banca.md` ("a
banca costuma cruzar números entre slides").

## Decisão

Modelar o diagrama de classes com fidelidade 1:1 ao DER: uma classe por tabela e uma enumeração por enum,
organizadas nos mesmos 8 módulos (na criação, 43 classes e 22 enumerações; hoje, 49 classes e 27 enumerações,
porque o DER chegou a 50 tabelas e só o `refresh_tokens` ficou sem classe), incluindo as entidades técnicas
(`LogAuditoria`, `ConfiguracaoGlobal`, `TokenRecuperacaoSenha`) mesmo com pouco comportamento de
negócio.

## Alternativas consideradas

- **Modelo de domínio reduzido**: excluir do diagrama de classes as entidades puramente técnicas
  (log, configuração, token de recuperação), por terem pouco valor como "classe de negócio" —
  mais enxuto e focado em comportamento rico, mas quebra a rastreabilidade 1:1 com o DER e exige
  justificar, para cada tabela ausente, por que ela "não é uma classe".
- **Diagrama só do MVP**: cobrir apenas as entidades das user stories sem marcador `**`/`***`
  (tag `mvp`) — reduziria o diagrama, mas colide com a ADR-027 (escopo do Marketplace no MVP),
  que ainda está em aberto; fazer isso agora seria decidir os dois problemas ao mesmo tempo.

## Consequências

**Positivas**
- Nenhuma pergunta de "por que o DER tem 43 tabelas e o diagrama de classes só N" na banca.
- Uma única tabela de rastreabilidade (a do DER) serve para os dois artefatos.

**Negativas / riscos**
- Diagrama grande (hoje 49 classes) não cabe em uma única view legível — mitigado com views separadas
  por módulo (as views do `docs/Diagramas/Diagrama-de-Classe/cromocard-diagrama-classes.v2.c4`), como o DER,
  que também é dividido em três diagramas.
- Classes técnicas (ex.: `LogAuditoria`) têm poucos métodos de negócio — aceitável, pois o valor
  aqui é rastreabilidade, não riqueza comportamental.

## Referências

- `docs/Diagramas/Diagrama-de-Classe/cromocard-diagrama-classes.v2.c4`
- `docs/Diagramas/DER/README.md`
- `Apresentacao-Banca/plano-apresentacao-banca.md`
