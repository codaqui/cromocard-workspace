---
name: revisar-codigo
description: Revisa as mudanças de uma branch do CromoCard (backend, frontend ou workspace) em dois eixos separados — Padrões (ADRs, rules, Clean Code, SOLID, Object Calisthenics) e Spec (o que o caso de uso e o work item do Azure pedem) — com dois agents em paralelo. Use para revisar uma branch, um PR ou o trabalho em andamento antes do /criar-pr.
argument-hint: "[backend|frontend|workspace] [base] [#work-item]"
---

Revisa a branch atual em dois eixos, com os argumentos `$ARGUMENTS` (todos opcionais).

## 1. Repositório e base

| Repo | Caminho | Base padrão |
|---|---|---|
| backend | `apps/cromocard-backend` | `origin/develop` |
| frontend | `apps/cromocard-frontend` | `origin/develop` |
| workspace | `.` | `origin/development` |

- Sem o repo nos argumentos, descubra onde está o trabalho: `git -C <caminho> status --short` e
  `git -C <caminho> log --oneline <base>..HEAD` em cada um. Se houver trabalho em mais de um, pergunte qual revisar.
- `git -C <caminho> fetch origin` antes. Confirme que a base existe (`git rev-parse`) e que o diff não está vazio.
  Falhe aqui, não dentro dos agents.
- Diff: `git -C <caminho> diff <base>...HEAD` (merge-base). Se houver mudança não commitada, inclua também
  `git -C <caminho> diff HEAD` e diga no relatório que parte é trabalho em andamento.

## 2. Tarefa (spec)

Procure o work item nesta ordem: argumento `#id`; nome da branch (`feature/<id>-…`); rodapé `AB#<id>` dos commits.
Sem nenhum, pergunte. Se o usuário disser que não há tarefa, o eixo Spec é pulado e o relatório diz "sem spec".

Depois procure a spec salva da tarefa em `specs/` (pelo `CCDnnn` do título do work item ou pela linha
`User story: #<id>` do cabeçalho). Se existir, passe o caminho da pasta ao analista. Se não existir, o analista levanta
os requisitos da documentação, como antes, e o relatório diz "sem spec salva".

## 3. Dois agents em paralelo

Na mesma mensagem, chame:

- **`revisor-codigo`** com o caminho do repo, o comando de diff e a lista de commits
  (`git -C <caminho> log --oneline <base>..HEAD`).
- **`analista-requisitos`** com a tarefa, a pasta da spec (se houver) **e o comando de diff** (modo revisão), para
  marcar cada requisito como feito, parcial, não feito ou fora deste repo, conferir o contrato da API do `plano.md`
  e listar o que foi feito sem ser pedido.

## 4. Relatório

Apresente os dois eixos separados, sem misturar nem reordenar os achados entre eles: um código pode seguir todos
os padrões e implementar a coisa errada, ou fazer exatamente o pedido quebrando as convenções.

```
## Padrões
<resposta do revisor-codigo>

## Spec — <CCDnnn> · #<id> · <specs/<pasta>/ | sem spec salva>
<tabela de requisitos com a situação, contrato da API, "Fora do escopo" e lacunas, do analista>

**Resumo:** Padrões — <n> achados (<pior>). Spec — <n> requisitos pendentes (<pior>).
```

Não corrija nada automaticamente. Ofereça corrigir os achados bloqueantes e, depois, rodar `/criar-pr`.
