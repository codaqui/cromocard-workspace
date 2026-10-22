---
paths:
  - "docs/Casos-De-Uso/**"
---

# Casos de uso e user stories

- O código `CCDnnn` é o número do arquivo: `CCD014` → `docs/Casos-De-Uso/14-*.md`. O arquivo não repete o
  código. No Azure, a user story correspondente tem o título `CCD014 - <Nome>`.
- Formato de cada caso de uso (tabelas Markdown), igual aos existentes:

  ```markdown
  | Nome do Caso de Uso | <Nome> |
  |---|---|
  | Finalidade/Objetivo | <para que serve> |
  | Atores | <Visitante, Cliente, Vendedor, Administrador, Administrador do Grupo> |
  | Pré Condições | <o que precisa ser verdade antes> |

  ### Fluxo Principal

  | Ações do Ator | Ações do Sistema |
  |---|---|
  | 1. <ação do ator> |  |
  |  | 2. <resposta do sistema> |

  ### Fluxo Alternativo

  | Ações do Ator | Ações do Sistema |
  |---|---|
  |  | 1. <exceção ou caminho alternativo> |
  ```

- Os passos são numerados em sequência, alternando colunas entre ator e sistema. Cada passo é uma frase
  verificável: é dela que sai o requisito na conferência com o Figma e na revisão de código.
- User stories em `user-stories.md`: tabela `| User Story | Narrativa |` por área funcional, narrativa
  "Como <ator> preciso/quero … para …". A marcação `**` (Futuro), `***` (Futuro Marketplace) ou `++` (Escopo Adicional, vindo do
  Figma — índice em `escopo-adicional.md`) no fim da narrativa define a fase.
- Caso de uso novo: próximo número livre, nome do arquivo em minúsculas com hífens e sem acentos, e uma linha
  correspondente em `user-stories.md` e `resumo-user-stories.md`.
- Ao ler um caso de uso, confira as inconsistências conhecidas listadas no `CLAUDE.md` antes de concluir algo.
  Não corrija essas inconsistências sem confirmar com o usuário.
