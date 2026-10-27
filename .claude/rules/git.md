# Git: branches, commits e Pull Requests (ADR-013)

Vale para o workspace e para os dois apps. Cada app é um repositório próprio: rode git com `git -C apps/<app> …`.

## Branches

| Repositório | Branch de trabalho | Estável |
|---|---|---|
| Workspace (`.`) | `development` | `main` |
| Backend e frontend (`apps/*`) | `develop` | `main` (com `homolog` entre as duas quando o deploy existir) |

- Ninguém faz push direto numa branch fixa (`main`, `homolog`, `develop`, `development`): toda mudança entra por PR.
- Trabalho novo sai da branch de trabalho, numa branch curta: `feature/<id>-<descricao>` (user story ou task),
  `fix/<id>-<descricao>` (bug), `docs/<id>-<descricao>`, `chore/<descricao>`, `infra/<descricao>`.
  `<id>` é o número do work item no Azure Boards; a descrição vai em minúsculas, com hífens e sem acentos
  (`feature/120-marcar-carta-possuo`).
- `pr-assets` (só nos apps) é uma branch órfã com os GIFs e prints dos critérios de aceite que a `/criar-pr` põe na
  descrição dos PRs. Ela não sai de nenhuma branch e não entra em nenhuma.
- `hotfix/<descricao>` sai de `main`, entra em `main` e **volta** para `homolog` e para a branch de trabalho.
- Antes de começar e antes de commitar: `git fetch --all` e `git status`, para não divergir do que outra pessoa
  já subiu. Branch de feature é apagada depois do merge.

## Commits — Conventional Commits em português

```
<tipo>(<escopo>): <descrição curta no imperativo>

<corpo opcional: o porquê, não o que o diff já mostra>

AB#<id>
```

| Tipo | Quando usar |
|---|---|
| `feat` | Funcionalidade nova (código dos apps) |
| `fix` | Correção de bug |
| `docs` | Documentação: casos de uso, diagramas, ADRs, READMEs |
| `refactor` | Reorganização sem mudar comportamento (renomear pasta, reestruturar diagrama) |
| `test` | Só testes |
| `chore` | Manutenção: configuração do workspace, `.gitignore`, dependências, Claude Code |
| `ci` / `build` | Pipeline e build |
| `perf` / `style` | Performance / formatação, sem mudança de lógica |

- **Escopo** — nos apps, o domínio em inglês, igual à pasta do código: `auth`, `users`, `catalog`, `collection`,
  `community`, `chat`, `marketplace`, `notifications`, `admin`. No workspace, a área: `adr`, `der`, `c4`,
  `diagrama-classes`, `casos-de-uso`, `specs`, `banca`, `claude`. Ajuda a filtrar o histórico (`git log --grep="docs(adr)"`).
- **Descrição**: verbo no imperativo, minúscula, sem ponto final. ✅ `adiciona`, `corrige`, `remove` —
  ❌ `Adicionado`, `Adiciona.`, `ADICIONA`.
- **Rodapé `AB#<id>`** sempre que o commit avança ou fecha um work item: liga o commit ao card do Azure Boards
  (app Azure Boards no GitHub). Vários itens: `AB#270 AB#272`. Não use `Refs #` nem `Closes #`: no GitHub isso
  aponta para issues do próprio GitHub, não para o board.
- **Um commit = uma mudança coerente.** Não misture assuntos só porque foram feitos no mesmo dia (ex.: ADRs e
  diagrama de classes são revisões diferentes).
- **Nunca** `git add -A` ou `git add .` sem olhar o `git status`: adicione arquivo por arquivo, e nunca `.env`,
  tokens ou arquivos gerados.
- Sem `Co-Authored-By` e sem rodapé de ferramenta ("Generated with Claude Code").
- O ADR-013 prevê `commitlint` no hook `commit-msg` do husky; ainda não está configurado, então o padrão depende
  de quem commita.

Exemplos:

```
docs(adr): adiciona ADRs iniciais de arquitetura

AB#270 AB#272 AB#273
```

```
feat(collection): marca carta como possuo

AB#120
```

## Pull Requests

- Um PR = uma user story. PR grande demais é dividido.
- Base: a branch de trabalho do repositório (`development` no workspace, `develop` nos apps). Promoções
  (`develop`/`development` → `homolog` → `main`) só quando o time decidir publicar.
- Título no estilo do commit (`feat(collection): marca carta como possuo`); descrição com o que mudou, por quê e o
  `AB#<id>`. O `/criar-pr` faz isso com o template de cada repositório.
- Merge com **1 aprovação** e **CI verde**. Quem revisa não é quem escreveu.
- **Squash merge** de feature para a branch de trabalho (1 commit por feature); **merge commit** nas promoções,
  para preservar o histórico. Cada merge em `main` gera uma tag SemVer `vX.Y.Z`.
- Critério de revisão: Clean Code, SOLID, Object Calisthenics e os ADRs (`/revisar-codigo`, agent `revisor-codigo`).
