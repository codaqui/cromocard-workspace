---
name: planejar
description: Gera o plano técnico (plano.md) e a lista de tarefas (tarefas.md) de uma spec aprovada do CromoCard — tabelas e migrations, contrato da API, arquivos do backend e do frontend, testes e a ordem de execução —, seguindo os ADRs e os modelos users dos apps. Segundo passo do SDD, depois do /especificar e antes do /implementar. No fim, oferece criar as Tasks no Azure.
argument-hint: "<CCDnnn>"
---

Planeja a spec `$ARGUMENTS`. Siga `.claude/rules/specs.md` e os modelos `specs/template/plano.md` e
`specs/template/tarefas.md`.

**Princípio:** o plano diz **como** fazer o que a spec pede, e só isso. Todo endpoint, arquivo, teste e tarefa cita
um `R` ou um `CA`. O que a spec não pede não entra; o que a spec esqueceu volta para a spec.

Esta skill só lê os apps (não muda código) e não usa o Figma. Ela escreve em `specs/<pasta>/` e, com
confirmação, no board.

## 1. Spec

- Ache `specs/CCDnnn-*/spec.md`. Sem spec, sugira o `/especificar` e pare.
- Status `Rascunho`: pare e mostre o que falta para aprovar (lacunas pendentes). Só planeje um rascunho com pedido
  explícito, e então escreva no cabeçalho do plano `Feito sobre a spec em Rascunho`.
- Já existe `plano.md`: atualize mantendo os IDs das tarefas e preservando os `[x]` e os `AB#` já gravados.

## 2. Levantar o estado atual

Leia só o que a spec toca:

- **Dados:** as tabelas da seção Dados no `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml` e o que já existe em
  `apps/cromocard-backend/database/schema.prisma`. Tabela que falta = uma migration (`create_<tabela>_table`). Se a
  spec precisar de algo que o DBML não tem, pare: o DER muda antes, num PR de docs.
- **Backend:** `src/domains/<dominio>/` (o domínio com o mesmo nome do escopo de commit), o modelo
  `src/domains/users/`, `src/routes.ts` e `src/shared/` (middlewares, erros, respostas).
- **Frontend:** `src/features/<feature>/`, o modelo `src/features/users/`, `src/routes/paths.ts`, `src/app/router.tsx`
  e `src/components/` (para reaproveitar).
- **Outras specs** em `specs/`: dependências (ex.: login antes de rota autenticada) e contratos que esta spec
  reaproveita em vez de duplicar.
- **ADRs que mudam o plano:** 004, 005, 006, 011, 015 e 034 no backend; 040 a 044 no frontend.

Diga de que branch de cada app você leu (`git -C <app> branch --show-current`).

## 3. Escrever o `plano.md`

- **Solução** e **Dependências**.
- **Dados:** cada tabela com o que existe no `schema.prisma` e a migration que falta.
- **Contrato da API:** um bloco por endpoint, com método e caminho no padrão do ADR-011 (recurso no plural, `/me`,
  ação via `POST /:id/<acao>`), acesso (`authenticate`, `authorize`), entrada, resposta e erros (`error` em
  `SCREAMING_SNAKE_CASE`, como o `USER_NOT_FOUND` do `users.errors.ts`; `422` para regra de negócio, `409` para
  conflito). Cada erro cita o requisito.
- **Backend** e **Frontend:** os arquivos a criar ou mudar, no padrão do ADR-004 e do ADR-040, com o que muda e os
  requisitos. Inclua o registro do domínio em `src/routes.ts` e das rotas no `app/router.tsx` quando forem novos.
- **Testes:** cada `CA` com pelo menos um teste (unitário da service, integração ou componente) e onde ele fica.
- **Decisões técnicas:** o que o plano decidiu e nenhum ADR cobre. Se for decisão de arquitetura, proponha um ADR
  novo `Proposto` em vez de decidir aqui.

## 4. Escrever o `tarefas.md`

- Uma tarefa por mudança coerente (cerca de um commit), com título de Task do Azure (verbo + objeto), os `R`/`CA` que
  cobre e um "Pronto quando" verificável.
- Ordem no backend: migrations → validator e errors → repository → service com o `.spec.ts` → controller, rotas,
  swagger e module → teste de integração.
- Ordem no frontend: types, schemas e labels → `.api.ts` e `.queries.ts` → componentes → páginas e rotas → testes.
  O frontend pode começar em paralelo assim que o contrato estiver fechado: marque com `[P]`.
- Termine com a tarefa de fechamento no workspace e a tabela **Cobertura**. Requisito sem tarefa é furo do plano:
  corrija antes de entregar.

Mude o status da spec para `Planejada` e atualize o índice de `specs/README.md`.

## 5. Tasks no Azure (opcional)

Ofereça criar as tarefas como Tasks filhas da user story. Só com o sim do usuário:

- Confira antes os filhos da user story (`wit_work_item`, `action: get`, `expand: Relations`): Task com o mesmo
  título já existe e só recebe o `AB#` no `tarefas.md`, sem duplicar.
- Crie as que faltam numa chamada só: `wit_work_item_write` com `action: add_child`, `project: CromoCard`,
  `parentId: <id da user story>`, `workItemType: Task` e um item por tarefa (`title` = título da tarefa,
  `description` = "Pronto quando" + requisitos + link do `tarefas.md`).
- Grave o `AB#<id>` de cada Task criada na linha da tarefa.

Se a escrita for negada ou o board responder `401`, siga sem as Tasks e diga isso.

## 6. Responder

```
## Plano — <CCDnnn> <Nome>
specs/<pasta>/plano.md · tarefas.md — <n> endpoints, <n> migrations, <n> tarefas (backend <n>, frontend <n>)

### Contrato da API
<MÉTODO> <caminho> — <resumo>

### Dependências e riscos
### Decisões que precisam do time (ADR proposto, se houver)
```

Próximo passo: revisão do plano no PR do workspace e `/implementar <CCDnnn> backend` (e `frontend`, em paralelo).
