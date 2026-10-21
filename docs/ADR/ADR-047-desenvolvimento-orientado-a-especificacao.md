# ADR-047 — Desenvolvimento orientado a especificação (SDD): spec, plano e tarefas por user story

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-10-19
- **Decisores:** Equipe CromoCard

## Contexto

O ADR-026 define o workspace como o lugar do SDD, mas não diz como uma user story vira código. A documentação
(casos de uso, user stories, DER, ADRs) já é a fonte da verdade e o Figma é o design a seguir. Faltava a camada entre
os dois e o código:

- os requisitos de uma tarefa eram levantados a cada conversa pelo agent `analista-requisitos` e pelo
  `/conferir-tarefa`, e o resultado não ficava salvo: duas pessoas podiam chegar a listas diferentes;
- não havia um plano técnico nem um contrato de API combinado entre backend e frontend, que estão em repositórios
  separados (risco já apontado no ADR-026);
- a revisão (`/revisar-codigo`, eixo Spec) levantava os requisitos de novo, sem IDs estáveis para citar.

## Decisão

Adotar SDD com uma pasta por user story em `specs/CCDnnn-<nome>/`, com três arquivos:

| Arquivo | Conteúdo |
|---|---|
| `spec.md` | O quê: requisitos `R` com a origem na documentação, critérios de aceite `CA` (Dado/quando/então), dados, telas do Figma com o veredito, fora do escopo e lacunas `L` |
| `plano.md` | Como: tabelas e migrations, contrato da API (ADR-011), arquivos do backend (ADR-004) e do frontend (ADR-040), testes e decisões técnicas |
| `tarefas.md` | Em que ordem: tarefas `T` por repositório, cada uma com os requisitos que cobre, um "Pronto quando" e o `AB#` da Task no Azure |

- **Fora de `docs/`:** as specs ficam em `specs/`, na raiz do workspace. `docs/` é a fonte da verdade e só guarda
  documentação.
- **Fluxo:** `/especificar` → aprovação do PO → `/planejar` → `/implementar` → `/revisar-codigo` → `/criar-pr`.
- **Status da spec:** `Rascunho` → `Aprovada` → `Planejada` → `Em implementação` → `Implementada` (ou `Cancelada`).
  Só o PO aprova, e nenhuma spec com lacuna pendente é aprovada. Se a documentação mudar, a spec volta para `Rascunho`.
- **A spec não cria requisito:** todo requisito cita a origem. Lacuna decidida pelo time volta para o caso de uso
  (regra de negócio) ou vira ADR (decisão técnica), para a documentação continuar sendo a única fonte da verdade.
- **IDs fixos** (`R`, `CA`, `L`, `T`), citados em testes, commits, PRs e na revisão.
- **Uma spec por user story**, como o PR (ADR-013). User stories quase iguais podem dividir uma spec, por decisão do time.
- **Tarefas locais:** o `tarefas.md` é a lista; o `/planejar` oferece criar as Tasks filhas da user story no Azure,
  com confirmação a cada escrita.

O formato e as regras ficam em `.claude/rules/specs.md`, e os modelos em `specs/template/`.

## Alternativas consideradas

- **Continuar sem spec salva** (só `/conferir-tarefa` e revisão): mais leve, mas a lista de requisitos muda a cada
  conversa e o contrato da API fica implícito entre duas pessoas.
- **Uma spec por área funcional** (ex.: Coleção, CCD014–019): menos pastas, mas a spec fica grande, a aprovação trava
  a área inteira e deixa de ser 1:1 com a user story e o PR.
- **Specs dentro de cada app:** a user story atravessa os dois repositórios, e a documentação de origem já está no
  workspace (ADR-026).
- **Specs dentro de `docs/`** (`docs/Specs/`): misturaria um artefato derivado e de trabalho (com status e progresso
  das tarefas) com a fonte da verdade, e daria a entender que a spec também é fonte.
- **GitHub Spec Kit ou ferramenta parecida:** traz CLI, constituição e estrutura próprias que duplicam o que o
  `CLAUDE.md`, os ADRs e as rules já fazem. O formato adotado é inspirado nele, mas usa as skills e os agents do time.

## Consequências

- Os requisitos de cada tarefa ficam estáveis e revisáveis num PR do workspace antes do código.
- O backend e o frontend trabalham em paralelo a partir do contrato no `plano.md`.
- A revisão e o PR citam os IDs da spec; o `analista-requisitos` usa a spec salva em vez de levantar tudo de novo.
- Custo: cada user story ganha um PR de documentação (spec e plano) e um passo de aprovação do PO, e o progresso
  volta ao workspace num PR de fechamento, junto com os ponteiros dos submódulos.
- Novas skills: `/especificar`, `/planejar` e `/implementar`. O `/revisar-codigo`, o `/criar-pr` e o
  `analista-requisitos` passam a ler a spec.

## Referências

- ADR-011, ADR-013, ADR-026, ADR-040
- `specs/README.md`, `.claude/rules/specs.md`
