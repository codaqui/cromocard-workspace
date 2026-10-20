---
name: criar-pr
description: Abre um Pull Request no padrão do CromoCard no workspace, no backend ou no frontend — confere a branch e os commits (Conventional Commits em pt-BR com AB#), roda as checagens do repo, faz push e cria o PR com o template preenchido e ligado ao work item do Azure.
argument-hint: "[backend|frontend|workspace] [#work-item]"
disable-model-invocation: true
---

Abre um PR com os argumentos `$ARGUMENTS` (todos opcionais). Invocar esta skill é o pedido para commitar, fazer
push e abrir o PR — mas nunca faça merge, nunca force push e nunca faça push direto numa branch fixa.

## 1. Repositório

| Repo | Caminho | GitHub | Base do PR |
|---|---|---|---|
| backend | `apps/cromocard-backend` | `codaqui/cromocard-backend` | `develop` |
| frontend | `apps/cromocard-frontend` | `codaqui/cromocard-frontend` | `develop` |
| workspace | `.` | `codaqui/cromocard-workspace` | `development` |

Sem o repo nos argumentos, veja onde está o trabalho (`git -C <caminho> status --short` e commits à frente da base).
Se houver em mais de um, pergunte. Cada app é um repositório próprio: rode tudo com `git -C <caminho>`.
PR de release (`develop`/`development` → `main`) só se o usuário pedir explicitamente.

## 2. Branch e tarefa

- Branches fixas: `main`, `homolog`, `develop`, `development`. Se estiver numa delas, não commite nela: proponha
  criar `feature/<id>-<descricao>` a partir da base (ou `fix/`, `docs/`, `chore/`, `infra/`), com a descrição em
  minúsculas, com hífens e sem acentos, e leve as mudanças para lá.
- Work item: argumento `#id`, número da branch ou `AB#` dos commits. Sem nenhum, pergunte — um PR = uma user story.
  Leia o título no Azure (`wit_work_item`, `action: get`, projeto `CromoCard`); se o board não responder, siga com
  o número que o usuário deu.

## 3. Commits

- Siga `.claude/rules/git.md`: formato, tipos, escopos, rodapé `AB#<id>`, um commit por mudança coerente, sem
  `Co-Authored-By`.
- Mostre o `git status`. Pergunte o que entra se houver arquivos que não parecem da tarefa. Adicione arquivo por
  arquivo — nunca `git add -A` ou `git add .` — e nunca `.env`, segredos ou arquivos gerados.
- Se commits já existentes na branch fugirem do padrão, avise; não reescreva o histórico sem o usuário pedir.

## 4. Checagens (antes do push)

| Repo | Rodar |
|---|---|
| backend | `npm run lint && npm run typecheck && npm run test:cov`; com o PostgreSQL local de pé, também `npm run test:integration` |
| frontend | `npm run format:check && npm run lint && npm run typecheck && npm test && npm run build` |
| workspace | Conferência manual: DER mudou nos três formatos (DBML, SQL, PlantUML)? ADR novo como `Proposto` e no índice? `.puml` alterado com o `.svg` exportado? Ponteiro de `apps/*` mudou de propósito? |

Se algo falhar, pare, mostre a saída e não abra o PR. Se a branch ainda não passou pelo `/revisar-codigo`,
pergunte se quer rodar antes.

## 5. Push e PR

1. `git -C <caminho> push -u origin <branch>`.
2. Título: no estilo do commit principal (`feat(collection): marca carta como possuo`).
3. Corpo: preencha o template do repo — [templates/backend.md](templates/backend.md),
   [templates/frontend.md](templates/frontend.md) ou [templates/workspace.md](templates/workspace.md).
   Marque no checklist **só o que foi verificado de verdade**; o resto fica desmarcado com uma nota do porquê.
   No frontend, inclua o link do frame do Figma e o veredito do `/conferir-tarefa`, se houver.
   Se a tarefa tiver spec em `specs/` (ADR-047), preencha a seção **Spec** com o caminho, os requisitos que o
   PR cobre e as tarefas do `tarefas.md` que ele fecha; sem spec, escreva "sem spec salva".
4. Crie o PR:
   - Com o GitHub CLI autenticado (`gh auth status`): grave o corpo num arquivo temporário (`mktemp`) e rode
     `gh pr create --repo <GitHub> --base <base> --head <branch> --title "<título>" --body-file <arquivo>`.
   - Sem o `gh`: entregue o link `https://github.com/<GitHub>/compare/<base>...<branch>?expand=1` e o corpo pronto
     num bloco para colar. Sugira instalar uma vez: `sudo apt install gh` e `gh auth login`.

## 6. Fechar

Responda com o link do PR, as checagens que rodaram e o que ficou pendente. Lembre: o merge precisa de 1 aprovação
de outra pessoa e do CI verde, e é feito com squash (regras de merge em `.claude/rules/git.md`). Se o PR for de um app, lembre que depois do merge dá para
atualizar o ponteiro do submódulo no workspace (`git add apps/<app>` num PR do workspace).
