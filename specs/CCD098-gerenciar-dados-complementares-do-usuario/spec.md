# CCD098 — Gerenciar Dados Complementares do Usuário

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #602 `CCD098-Gerenciar Dados Complementares do Usuário` · responsável Felipe Consulim · Sprint 06
- **Caso de uso:** [98-gerenciar-dados-complementares-do-usuario.md](../../docs/Casos-De-Uso/98-gerenciar-dados-complementares-do-usuario.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero registrar e buscar usuários por nome de usuário (@), telefone e CPF e ver o último acesso de cada um para identificar a conta com rapidez.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `98`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A lista mostra o nome de usuário (@) e o ID, o telefone, a data e o IP do último acesso | Tela | `98`, FP 2 |
| R3 | Busca por nome, nome de usuário, e-mail, CPF ou CNPJ e ID | Campo | `98`, FP 3–4 |
| R4 | O formulário de usuário ganha nome de usuário, CPF e telefone com DDD | Campo | `98`, FP 5–7; DBML `users` |
| R5 | "Enviar link de ativação de conta por e-mail" (24 horas) no cadastro; sem marcar, a conta é criada sem e-mail | Ação | `98`, FP 8, FP 11 e FA 5–6 |
| R6 | Nome de usuário e CPF únicos; repetido responde `409` dizendo qual campo | Regra | `98`, FP 10 e FA 1–2; DBML `users.username`, `users.cpf` |
| R7 | CPF (com dígitos verificadores) e telefone com formato validado | Regra | `98`, FA 3–4 |
| R8 | O login grava `last_login_at` e `last_login_ip` | Regra | `98`, FP 2; ADR-053, Consequências |
| R9 | Criar e alterar dados complementares grava `audit_logs` | Regra | `98`, FP 12 |
| R10 | O login aceita e-mail ou nome de usuário | Ação | EA-004-01 |
| R11 | Excluir pede digitar o texto de confirmação e marcar "Estou ciente"; o texto diz que a conta pode ser restaurada | Ação | EA-059-01; ADR-015 |
| R12 | Total de usuários no cabeçalho da Gestão de Usuários | Campo | EA-059-02 |
| R13 | Clicar na linha abre o detalhe do usuário com todos os dados e as ações | Tela | EA-059-03 |
| R14 | O CPF não aparece nos logs da aplicação | Regra | ADR-019 |
| R15 | Reenviar o link de ativação de uma conta que ainda não definiu a senha | Ação | `98`, FA 6 |

## Critérios de aceite

- **CA1** (R2, R12) — **Dado** usuários com dados complementares, **quando** o admin abre a Gestão de Usuários, **então** vê @, telefone, último acesso e IP, e o total no cabeçalho.
- **CA2** (R3) — **Dado** um usuário com CPF, **quando** o admin busca pelo CPF, **então** a lista mostra só esse usuário.
- **CA3** (R4, R5, R9) — **Dado** o formulário de novo usuário, **quando** o admin preenche @, CPF e telefone, marca o link e confirma, **então** a conta é criada, o e-mail com o link de 24 horas sai e o log registra.
- **CA4** (R6) — **Dado** um @ já usado, **quando** o admin tenta cadastrar com ele, **então** a API responde `409` com o campo `username`.
- **CA5** (R7) — **Dado** um CPF com dígito errado, **quando** o admin confirma, **então** a API responde `400` no campo `cpf`.
- **CA6** (R8, R10) — **Dado** um usuário com @, **quando** ele entra informando o @ e a senha, **então** o login funciona e grava a data e o IP.
- **CA7** (R11) — **Dado** o diálogo de exclusão, **quando** o admin não digita o texto de confirmação, **então** o botão de excluir fica desabilitado.
- **CA8** (R15) — **Dado** uma conta criada sem o link, **quando** o admin reenvia o link, **então** o e-mail sai e o log registra.
- **CA9** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `users` | `username`, `phone`, `cpf`, `last_login_at`, `last_login_ip` | colunas novas (ADR-053) |
| `seller_verifications` | `cnpj` | busca por CNPJ (CCD094) |
| `password_reset_tokens` | token do link | mesmo token da CCD059 e da CCD006 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Gestão de usuários | [208-1793](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-1793) | R2, R3, R12, R13 | ⚠️ Divergente |
| Adicionar novo usuário | [276-1202](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=276-1202) | R4, R5 | ✅ Bate |
| Remover usuário | [276-1735](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=276-1735) | R11 | ❌ Não bate |

- "Excluir Usuário Definitivamente" e "irreversível" contrariam o soft delete (ADR-015): o texto muda para "Excluir usuário (pode ser restaurado)".
- Os status "Suspenso (7d)" e "Bloqueado" são da CCD099; "Em análise", da CCD094.

## Fora do escopo

- Sanções — CCD099.
- Editar o próprio perfil (@ e telefone) pelo cliente — CCD091.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Formato do nome de usuário (proposta: 3 a 30 caracteres, minúsculas, números, ponto e `_`, guardado sem o `@`) | pendente — proposta | — |
| L2 | Busca por CNPJ (proposta: pelo `seller_verifications.cnpj` da CCD094) | pendente — proposta | — |
| L3 | Login com @ inexistente (proposta: a mesma mensagem genérica de credenciais inválidas) | pendente — proposta | — |
| L4 | Detalhe do usuário não tem frame (proposta: gaveta lateral com os dados e as ações; o Gabriel desenha) | pendente — proposta | — |
| L5 | Texto de confirmação da exclusão (proposta: `EXCLUIR-` + o primeiro nome em maiúsculas, como no Figma) | pendente — proposta | — |
