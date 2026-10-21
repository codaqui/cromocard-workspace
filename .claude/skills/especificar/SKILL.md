---
name: especificar
description: Cria ou atualiza a spec de uma user story do CromoCard (specs/CCDnnn-*/spec.md) a partir da documentação e do Figma — requisitos com origem e IDs fixos, critérios de aceite, dados, telas, fora do escopo e lacunas. Primeiro passo do SDD, antes do /planejar. Use quando pedirem para especificar uma tarefa, user story ou caso de uso, ou para guardar o resultado do /conferir-tarefa.
argument-hint: "<CCDnnn | #work-item> [link do frame no Figma]"
---

Especifica a tarefa `$ARGUMENTS`. Siga `.claude/rules/specs.md` (formato, IDs, status) e o modelo
`specs/template/spec.md`.

**Princípio:** a spec junta o que a documentação já pede, com IDs fixos, e acrescenta critérios de aceite. Ela não
cria requisito: o que a documentação não diz vira lacuna para o time decidir.

Esta skill escreve só em `specs/`. Não edite casos de uso, o Figma nem o board sem pedido explícito.

## 1. Entender a entrada

- Tarefa: `CCDnnn`, `#123`/`AB#123` (work item) ou o nome do caso de uso. Sem tarefa, pergunte qual é.
- Pasta: `specs/CCDnnn-<nome do arquivo do caso de uso sem o número>/` (regras de nome em `.claude/rules/specs.md`).
- Se já existir `spec.md` na pasta:
  - `Rascunho`: atualize mantendo os IDs (os removidos ficam riscados, os novos recebem o próximo número).
  - `Aprovada` ou adiante: não reescreva. Mostre o que mudaria e pergunte; se o usuário confirmar, a spec volta para
    `Rascunho` (e o plano, se houver, precisa ser revisto).

## 2. Requisitos e Figma

Siga os passos 2 a 4 do `/conferir-tarefa` (`.claude/skills/conferir-tarefa/SKILL.md`): o agent
`analista-requisitos` levanta os requisitos e as lacunas, o agent `leitor-figma` lê as telas pelo Chrome e você
monta a matriz requisito × Figma e os extras.

- Fase **Futuro** ou **Futuro Marketplace**: avise e pergunte se é para especificar mesmo assim.
- Sem Chrome conectado (e o usuário não quer usar o MCP do Figma): siga sem as telas, preencha a seção **Telas**
  com "não conferida" e crie uma lacuna `L<n>` para isso. Spec com tela não conferida não é aprovada.

## 3. Escrever o `spec.md`

A partir do modelo, preencha:

- **Cabeçalho:** status `Rascunho`, fase, work item (`#id` e título no Azure, ou "não encontrada no board"), link
  do caso de uso, atores, pré-condições, data de hoje e o autor (`git config user.name`).
- **Objetivo:** a narrativa da user story, copiada de `docs/Casos-De-Uso/user-stories.md`.
- **Requisitos:** a tabela do analista, um requisito atômico e verificável por linha, com tipo e origem.
- **Critérios de aceite:** um `CA` para o fluxo principal, um para cada fluxo alternativo e um para cada requisito
  de permissão e de estado (vazio, erro, carregando). Formato **Dado / quando / então**, com o resultado observável
  (o que a tela mostra, o status HTTP, o dado gravado) e os `R` que ele confere. Critério sem requisito não entra.
- **Dados:** as tabelas, colunas e enums do DBML que a tarefa lê ou grava, com as regras (obrigatória, única,
  default). Migrations e arquivos ficam para o plano.
- **Telas:** a matriz resumida por tela (requisitos que ela mostra e o veredito), o que o Figma mostra errado e o que
  falta nele.
- **Fora do escopo:** os extras do Figma (com a user story a que pertencem, ou "não está na documentação") e o que o
  analista apontou como fora.
- **Lacunas e decisões:** os conflitos e as lacunas do analista, todos `pendente`. Não preencha decisão por
  suposição.

Acrescente ou atualize a linha da spec no índice de `specs/README.md`.

## 4. Responder

```
## <CCDnnn> — <Nome> · #<work item> · fase <fase>
Spec: specs/<pasta>/spec.md (Rascunho) — <n> requisitos, <n> critérios de aceite

### Para aprovar
- L1 <pergunta> — precisa de decisão do PO
(ou: nenhuma lacuna; pronta para o PO validar)

### Figma
<veredito; onde está errado e o que falta, para o designer>
```

Depois, ofereça (sem fazer):

- levar as lacunas ao PO; com as decisões em mãos, atualizar o caso de uso (regra de negócio) e a spec;
- publicar as divergências do Figma como comentário no work item (escrita no board: só com pedido explícito);
- abrir o PR da spec no workspace (`/criar-pr workspace`).

Quando o usuário disser que o PO aprovou: status `Aprovada`, linha **Aprovação** com a data e quem aprovou, índice
atualizado. O próximo passo é o `/planejar`.
