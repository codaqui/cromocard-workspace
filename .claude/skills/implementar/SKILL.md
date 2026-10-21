---
name: implementar
description: Implementa uma spec planejada do CromoCard seguindo o tarefas.md, num app por vez (backend ou frontend) — cria a branch, executa as tarefas em ordem com os testes dos critérios de aceite, roda as checagens e marca o progresso, sem sair da spec. Terceiro passo do SDD, depois do /planejar e antes do /revisar-codigo e do /criar-pr.
argument-hint: "<CCDnnn> <backend|frontend> [T<n>]"
---

Implementa `$ARGUMENTS`: a spec, o app e, opcionalmente, a tarefa por onde começar (ou a única a fazer).

**Princípio:** o código faz o que a spec pede, do jeito que o plano diz. Quando a spec ou o plano não fecham com o que
o código encontra, pare e corrija o documento antes do código: nunca implemente algo que nenhum requisito pede e
nunca pule um requisito sem avisar.

As rules do app (`.claude/rules/backend.md` ou `frontend.md`) carregam ao ler os arquivos dele e valem em todas as
tarefas.

## 1. Spec, plano e tarefas

- Leia `specs/CCDnnn-*/spec.md`, `plano.md` e `tarefas.md`. Sem plano, sugira o `/planejar` e pare.
- Status `Planejada` ou `Em implementação`. Se for `Rascunho` ou `Aprovada`, pare e diga o que falta.
- Separe as tarefas do app pedido. As já marcadas `[x]` ficam como estão; sem `T<n>`, comece pela primeira pendente.
- Frontend antes do backend estar pronto: tudo bem se o contrato estiver no plano; use o contrato, não o código do
  backend, como referência.

## 2. Branch

No app (`git -C apps/cromocard-<app> …`):

- `git fetch --all` e `git status`. Se houver mudança não commitada que não é desta spec, pergunte antes de seguir.
- Numa branch fixa (`main`, `homolog`, `develop`): crie `feature/<id>-<descricao>` a partir de `origin/develop`, com
  o `<id>` da user story (cabeçalho da spec) e a descrição do nome da pasta da spec. Numa branch de feature desta
  spec, continue nela.
- Pergunte **uma vez** se pode commitar ao fim de cada tarefa. Sem o sim, deixe as mudanças para o `/criar-pr`.

Mude o status da spec para `Em implementação` (workspace) e atualize o índice.

## 3. Uma tarefa por vez

Para cada tarefa pendente, em ordem:

1. Leia os arquivos que ela toca e o modelo do app (`src/domains/users/` no backend, `src/features/users/` no
   frontend), e copie o padrão.
2. Implemente só o que a tarefa descreve, com o contrato da API exatamente como está no plano (caminho, campos,
   status, códigos de erro).
3. Escreva os testes dos `CA` da tarefa, com o ID no nome do teste (`it('CA2: recusa senha incorreta com 401')`).
4. Rode as checagens rápidas sobre o que mudou: `npm run lint`, `npm run typecheck` e os testes afetados.
5. Marque `[x]` na tarefa no `tarefas.md`. Com a permissão do passo 2, commite: Conventional Commits do
   `.claude/rules/git.md`, escopo = domínio, rodapé com o `AB#` da Task (ou da user story, se a tarefa não tiver).

**Quando parar e perguntar:**

- O contrato, uma tabela ou um arquivo do plano não funciona como escrito → proponha a mudança no `plano.md` e só siga
  depois do sim.
- Falta um requisito, ou um requisito contradiz outro, o caso de uso ou um ADR → isso é da spec: volte a spec para
  `Rascunho`, registre a lacuna e pare a implementação nesse ponto.
- Precisa de uma decisão de arquitetura → ADR novo `Proposto`, não uma escolha silenciosa no código.

## 4. Fechar

- Rode as checagens completas do app, as mesmas do `/criar-pr`:
  - backend: `npm run lint && npm run typecheck && npm run test:cov` (e `npm run test:integration` com o PostgreSQL
    local de pé);
  - frontend: `npm run format:check && npm run lint && npm run typecheck && npm test && npm run build`.
- Responda:

```
## <CCDnnn> — <app> · branch <branch>
Tarefas: <n> feitas (T1–T4), <n> pendentes · Checagens: <passaram | o que falhou, com a saída>

| Requisito | Situação |
|---|---|
| R1 | ✅ T2 · ⚠️ parcial (o que falta) · ↪ outro app |

Mudanças na spec ou no plano durante a implementação: <…>
```

Próximo passo: `/revisar-codigo <app>` e depois `/criar-pr <app>`. Lembre que o `tarefas.md` e o status da spec
mudaram no workspace: entram no PR de fechamento, junto com os ponteiros `apps/*`.
