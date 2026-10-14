# Guia de Contribuição — CromoCard

Este documento define como a equipe **CromoCard Team** trabalha neste repositório e nos
repositórios de aplicação (`cromocard-backend`, `cromocard-frontend`). Objetivo: qualquer
integrante commitar de um jeito que os outros cinco entendam sem precisar perguntar no grupo.

## 1. Branches

- **`development`** — branch de trabalho. Todo mundo commita/dá push aqui no dia a dia.
- **`main`** — branch estável. Só recebe merge via Pull Request vindo de `development`.
- Cada aplicação (`apps/cromocard-backend`, `apps/cromocard-frontend`) é um repositório Git
  próprio, ligado a este como submódulo — a mesma regra de branch vale dentro de cada um,
  independentemente.

## 2. Padrão de commits — Conventional Commits (em português)

Antes de commitar, rode `git fetch --all` e confira se `development` local está atualizado
(`git status`) — evita divergir do que outra pessoa já subiu.

**Formato:**

```
<tipo>(<escopo opcional>): <descrição curta no imperativo>

<corpo opcional — explica o porquê, não o que já está óbvio no diff>

Refs #<work item do Azure DevOps>
```

### Tipos

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade (código dos apps) |
| `fix` | Correção de bug |
| `docs` | Documentação — casos de uso, diagramas, ADRs, READMEs |
| `refactor` | Reorganização sem mudar comportamento (ex.: renomear pasta, reestruturar diagrama) |
| `chore` | Manutenção sem impacto em código/doc (config de workspace, `.gitignore`, dependências) |
| `test` | Testes automatizados (quando existirem) |
| `style` | Formatação/lint, sem mudança de lógica |
| `perf` | Melhoria de performance |

### Escopo (opcional, recomendado)

Use o nome da pasta/módulo afetado entre parênteses — ajuda a filtrar o histórico depois
(`git log --grep="docs(adr)"`). Exemplos usados neste repositório: `adr`, `der`, `c4`,
`diagrama-classes`, `casos-de-uso`, `banca`. Nos apps de código, use o módulo da API (`auth`,
`colecao`, `comunidade`, `chat`, `pagamentos`, `admin` — ver `CLAUDE.md`).

### Regras

- Descrição curta: verbo no imperativo, minúscula, sem ponto final no fim.
  ✅ `adiciona`, `corrige`, `remove` — ❌ `Adicionado`, `Adiciona.`, `ADICIONA`.
- Um commit = uma mudança coerente. Não misture, por exemplo, ADRs com o diagrama de classes só
  porque foram feitos no mesmo dia — são revisões e assuntos diferentes.
- Sempre que o commit fechar ou avançar um work item do Azure DevOps, referencie no rodapé:
  `Refs #270` (relacionado) ou `Closes #275` (fecha a task). Isso dá rastreabilidade sem precisar
  abrir o board toda vez.
- **Nunca** use `git add -A` ou `git add .` sem antes rodar `git status` e olhar o que vai entrar
  — evita subir arquivo sensível ou lixo de editor por engano.

### Exemplos reais deste repositório

```
docs(adr): adiciona ADRs iniciais de arquitetura

Refs #270, #272, #273
```

```
docs(diagrama-classes): refatora diagrama de classes com fidelidade ao DER

Refs #271, #275
```

```
fix(colecao): corrige cálculo de progresso do álbum ao remover carta

Closes #143
```

## 3. Pull Requests (`development` → `main`)

- Título do PR: mesmo estilo do commit (`docs: ...`, `feat: ...`).
- Descrição: o que mudou e por quê, com link/referência ao work item do Azure DevOps.
- Critério de revisão de código (quando os apps tiverem código): Clean Code, SOLID, Object
  Calisthenics e os design patterns adequados — mesmo critério usado nos code reviews do projeto
  (skill `code-review-daniel`).
- Quem revisa **não** deve ser quem escreveu o PR.

## 4. ADRs (Architecture Decision Records)

- Ficam em `docs/ADR/`, uma por arquivo (`ADR-XXX-titulo.md`), indexadas em `docs/ADR/README.md`,
  que também traz o modelo.
- Toda ADR nasce com **`Status: Proposto`** — só vira `Aceito`/`Rejeitado`/`Substituído por ADR-XXX`
  depois de validada com o PO.
- Crie uma ADR nova quando: escolher uma tecnologia/biblioteca nova, mudar algo que os diagramas
  (C4/DER/diagrama de classes) já davam como decidido, ou resolver uma decisão que hoje está em
  aberto (como a ADR-027, escopo do marketplace no MVP).

## 5. Manter os diagramas sincronizados

- `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml` é a fonte da verdade do modelo de dados —
  os `.sql` e `.puml` são derivados dele.
- `docs/Diagrama-de-Classe/cromocard-diagrama-classes.c4` deve continuar 1:1 com o DER (ver
  ADR-036). Se uma entidade for criada/alterada no DER, atualize a classe correspondente.
- Exporte diagramas em **SVG**, nunca PNG (o servidor público do PlantUML corta PNG em 4096px —
  ver `docs/Diagramas/DER/README.md`).
