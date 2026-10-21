---
paths:
  - "specs/**"
---

# Specs (SDD) — ADR-047

- Uma pasta por user story: `specs/CCDnnn-<nome>/` com `spec.md`, `plano.md` e `tarefas.md`, a partir dos
  modelos em `specs/template/`. Fluxo e índice em `specs/README.md`.
- As specs nunca vão para `docs/`: lá fica só a documentação, que é a fonte da verdade de onde a spec deriva.
- Nome da pasta: `CCDnnn-` + o nome do arquivo do caso de uso sem o número. Nas inconsistências conhecidas do
  `CLAUDE.md` (ex.: `10-buscar-album.md` é Solicitar Álbum), use o nome do conteúdo e confirme com o usuário.
- User stories quase iguais (mesmo endpoint, como CCD014/015/016) só dividem uma spec se o usuário decidir: a pasta
  leva o primeiro código e o cabeçalho lista os outros.

## A spec não cria requisito

- Todo requisito cita a origem: arquivo e passo do caso de uso (`FP 3`, `FA 1`), campo do work item ou tabela do
  DBML. O que não tem origem vai para **Lacunas e decisões**, nunca para os requisitos.
- Lacuna decidida pelo time: regra de negócio → atualize o caso de uso (com confirmação do usuário) e cite o passo
  novo como origem; decisão técnica → ADR novo `Proposto`. A spec registra a decisão e aponta onde ela ficou.
- Figma divergente da documentação: vale a documentação. A divergência fica na seção **Telas**, para o designer
  corrigir, e não vira requisito nem lacuna.

## IDs fixos

- Requisitos `R1…`, critérios de aceite `CA1…`, lacunas `L1…`, tarefas `T1…`. Depois de publicados, não se
  renumeram: o removido fica riscado com o motivo (`~~R4~~ removido: <motivo>`) e o novo recebe o próximo número.
- Testes, commits, PRs e a revisão citam os IDs (`CA2`, `R5`), não descrições.

## Status

- `Rascunho` → `Aprovada` → `Planejada` → `Em implementação` → `Implementada` (ou `Cancelada`).
- **Só o usuário confirma `Aprovada`** (validação do PO), como nos ADRs. Ao aprovar, preencha `Aprovação` com a data
  e quem aprovou. Não aprove spec com lacuna `pendente`.
- Mudou o caso de uso, a user story ou o DER de uma spec `Aprovada` ou adiante: ela volta para `Rascunho` e o plano é
  revisto antes de continuar o código.
- A cada mudança de status, atualize a linha da spec no índice do `README.md`.

## Plano e tarefas

- O `plano.md` só planeja o que a spec pede: todo endpoint, arquivo e teste cita um `R` ou `CA`. Nada "para depois"
  (coluna, rota, tela ou parâmetro que nenhum requisito pede).
- O contrato da API segue o ADR-011 e é o combinado entre backend e frontend: mudar o contrato é mudar o plano antes
  do código.
- Tabela nova vem copiada do DBML. Se o DBML precisar mudar, isso é um PR de docs antes do plano
  (`.claude/rules/modelagem-de-dados.md`).
- Decisão de arquitetura que nenhum ADR cobre não se resolve no plano: vira ADR novo `Proposto`, citado em
  **Decisões técnicas**.
- Tarefa = uma mudança coerente (cerca de um commit), com título de Task do Azure (verbo + objeto:
  `Criar endpoint POST /auth/login`), os `R`/`CA` que cobre e um "Pronto quando" verificável. Todo requisito aparece
  em pelo menos uma tarefa (seção **Cobertura**).

## Git

- Specs entram por PR no workspace (base `development`), branch `docs/<id>-spec-<descricao>`, commit
  `docs(specs): especifica CCDnnn <nome>` com `AB#<id>` da user story. Spec e plano podem ir no mesmo PR ou em PRs
  separados.
- O código vai nos apps. O progresso (`[x]` nas tarefas, status da spec) volta ao workspace no PR de fechamento,
  junto com os ponteiros `apps/*`.
