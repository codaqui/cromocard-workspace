---
name: conferir-tarefa
description: Confere se a tela do protótipo no Figma cobre o que a documentação do CromoCard pede para uma tarefa (work item do Azure, código CCDnnn ou nome do caso de uso). Se bater, confirma; se não, aponta onde o Figma está errado, o que falta e o que sobra. A documentação é a fonte da verdade. Use antes de implementar uma tela ou quando pedirem para comparar doc e Figma.
argument-hint: "<#work-item | CCDnnn> [link do frame no Figma]"
---

Confere a tarefa `$ARGUMENTS` comparando a documentação com o protótipo no Figma.

**Princípio:** a documentação (caso de uso, user story, work item, DER, ADRs) é a fonte da verdade. O Figma é o
design a seguir na implementação e foi feito a partir da documentação. Então:

- requisito da documentação que o Figma não mostra **continua valendo** — o Figma está incompleto;
- quando os dois divergem, **vale a documentação** — o Figma está errado naquele ponto;
- o que o Figma mostra e a documentação não pede **não entra** na implementação até a documentação ser atualizada.

Esta skill só lê. Não edite o Figma, os docs nem o board.

## 1. Entender a entrada

- Tarefa: `#123`/`AB#123` (work item), `CCD014` ou o nome do caso de uso. Sem tarefa, pergunte qual é.
- Tela: um ou mais links do Figma com `node-id`, ou o nome da tela. Sem nenhum dos dois, procure no índice
  de telas da skill `/analisar-figma-chrome` a tela que corresponde à área do caso de uso (ex.: chat → "Comunidade -
  chat"). Se houver mais de uma candidata e não der para decidir pelo nome, pergunte qual usar.

## 2. Levantar os requisitos

Chame o agent `analista-requisitos` com a tarefa. Ele devolve a tabela de requisitos (R1, R2…), os dados
envolvidos, os conflitos e as lacunas da documentação.

Se a fase for **Futuro** ou **Futuro Marketplace**, avise antes de seguir: a tarefa está fora do MVP.

## 3. Ler o Figma

Chame o agent `leitor-figma` com o(s) frame(s) **e a tabela de requisitos**, pedindo o inventário da tela e a
localização de cada requisito. Ele lê pelo Claude in Chrome, no modo protótipo, sem gastar a cota do MCP do Figma.
Várias telas vão na mesma chamada (ele usa uma aba só).

Se o agent voltar dizendo que o Chrome não está conectado, peça ao usuário para abrir o Chrome e rodar `/chrome` →
*Reconnect extension* (com o Chrome já aberto) e chame o agent de novo. Se o usuário pedir o MCP do Figma, use a skill
`/analisar-figma-mcp` no lugar do agent.

## 4. Comparar

Monte a matriz requisito × Figma com uma destas situações:

| Situação | Quando |
|---|---|
| ✅ Coberto | O Figma mostra o requisito como a documentação descreve |
| ⚠️ Divergente | O Figma mostra, mas diferente (rótulo, regra, campo, fluxo, permissão) — vale a documentação |
| ❌ Faltando | O Figma não mostra o requisito |

Depois liste os **extras do Figma**: elementos da tela que nenhum requisito pede. Para cada um, veja em
`docs/Casos-De-Uso/user-stories.md` se pertence a outra user story (outra tarefa, ou fase Futuro): se sim, diga
qual; se não, é algo fora da documentação.

Elementos puramente visuais (ícones, ilustrações, layout, cores) não são requisitos: só entram se contradisserem
uma regra (ex.: botão de excluir visível para quem não tem permissão).

## 5. Responder

```
## <CCDnnn> — <Nome> · #<work item> · fase <MVP|…>
Tela: <nome do frame> — <link>

**Veredito: ✅ Bate** | **Veredito: ❌ Não bate (<n> divergências, <n> faltando)**

| ID | Requisito (documentação) | Figma | Situação |
|---|---|---|---|

### Onde o Figma está errado
- <tela> — "<texto ou elemento no Figma>": mostra <X>; a documentação pede <Y> (<origem>).

### O que falta no Figma
- R<n> <requisito> — implementar mesmo assim, no estilo visual da tela.

### Extras do Figma fora desta tarefa
- <tela> — "<texto ou elemento>": pertence a <CCDnnn / Futuro> | não está na documentação.

### Lacunas e conflitos na documentação
(do analista — precisam de decisão do time)
```

- **Bate**: confirme que dá para implementar seguindo o Figma e cite as telas (com o link do protótipo).
- **Não bate**: o relatório acima é o que o designer (Gabriel) precisa corrigir. Ofereça, sem fazer, publicar o
  resumo como comentário no work item (escrita no board: só com pedido explícito).
- Lacunas da documentação não se resolvem olhando o Figma: elas vão para o time decidir e, se for o caso, viram
  ajuste no caso de uso.
- Para guardar este resultado como a spec da tarefa (`specs/`, ADR-047), ofereça o `/especificar`: ele segue
  estes mesmos passos e grava o `spec.md`.
