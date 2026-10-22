# CCD003 — Criar Conta

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #108 `CCD003-Criar Conta`
- **Caso de uso:** [03-criar-conta.md](../../docs/Casos-De-Uso/03-criar-conta.md)
- **Atores:** Visitante · **Pré-condições:** estar na Home (o texto "ou ter a barra de busca visível" foi copiado do CCD002)
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

Escopo combinado: cadastro por e-mail e senha, com tipo de usuário e aceite dos termos, e a confirmação do e-mail
(enviar o link, confirmar e reenviar). Login, inclusive o Google que cria conta, é a [CCD004](../CCD004-realizar-login/spec.md).
Recuperação de senha é a [CCD006](../CCD006-recuperar-senha/spec.md).

## Objetivo

> Como visitante eu quero me cadastrar via e-mail informando tipo de usuário, aceitando termos e confirmando o e-mail.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | O cadastro fica na área pública do SPA, sem guard, acessível sem autenticação | Permissão | `03-criar-conta.md`, Atores; ADR-038 |
| R2 | A Home oferece a opção "Cadastrar" | Ação | `03`, FP 1 |
| R3 | Formulário que pede os dados de cadastro e a seleção do tipo de usuário | Tela | `03`, FP 2 |
| R4 | Campo Nome: obrigatório, até 120 caracteres | Campo | DBML `users.name` |
| R5 | Campo E-mail: obrigatório, até 160 caracteres | Campo | user-stories.md §1; DBML `users.email` |
| R6 | Campo Senha | Campo | ADR-005, item 1; `04`, FP 3 |
| R7 | Campo Tipo de usuário, gravado em `users.role` (`CUSTOMER` ou `SELLER`) | Campo | `03`, Objetivo e FP 2; user-stories.md §1; DBML `users.role` |
| R8 | Aceite dos termos de uso | Campo | `03`, Objetivo e FP 3; user-stories.md §1 |
| R9 | O aceite é gravado em `users.terms_accepted = true` | Regra | `03`, FP 3; DBML `users.terms_accepted` |
| R10 | O sistema valida os campos antes de registrar | Regra | `03`, FP 4 |
| R11 | Entrada inválida responde `400 VALIDATION_ERROR` com `details` por campo | Regra | ADR-006; ADR-011 |
| R12 | O sistema verifica se o e-mail está disponível (único em `users`) | Regra | `03`, FP 4; DBML `users.email` |
| R13 | E-mail já cadastrado responde `409` | Regra | ADR-011 (conflito: e-mail já cadastrado) |
| R14 | E-mail de conta excluída responde `409 ACCOUNT_DELETED` | Regra | ADR-015, itens 7 e 8 |
| R15 | Diante do `409 ACCOUNT_DELETED`, o frontend sugere reativar a conta (a reativação é da CCD052) | Mensagem | ADR-015, item 8 |
| R16 | O formulário mostra o `message` da API e os `details` em cada campo | Mensagem | ADR-042; ADR-011 |
| R17 | Mensagens ao usuário e e-mails em pt-BR; o `error` é um código estável em inglês | Regra | ADR-017; ADR-011 |
| R18 | O sistema registra o usuário em `users` | Ação | `03`, FP 5 |
| R19 | A senha é gravada só como hash (argon2, ou bcrypt com custo ≥ 12) | Regra | ADR-005, item 1 |
| R20 | `users.id` é UUID v7 e as colunas de tempo são `timestamptz` | Regra | ADR-014; ADR-016 |
| R21 | O usuário novo nasce com `status = ACTIVE` | Estado | DBML `users.status` |
| R22 | No cadastro por e-mail, `oauth_provider` e `oauth_id` ficam nulos | Regra | DBML; ADR-005, item 2 |
| R23 | A criação responde `201` com o recurso em `{ data }`, sem `password_hash` | Regra | ADR-011 |
| R24 | Depois do registro, o sistema mostra uma mensagem de sucesso | Mensagem | `03`, FP 5 |
| R25 | Depois de confirmar o e-mail, o visitante é levado ao login com a mensagem "E-mail confirmado" | Ação | `03`, FP 7 |
| R26 | O cadastro fica no módulo de autenticação da API (domínio `auth`) | Regra | C4 nível 3, `compAuth`; Diagrama de Atividades ccd003 |
| R27 | O formulário mostra o estado de envio e o erro | Estado | ADR-042 |
| R28 | O cadastro inclui a confirmação do e-mail | Regra | user-stories.md §1 ("confirmando o e-mail") |
| R29 | O usuário novo fica com `email_verified = false` até confirmar | Estado | DBML `users.email_verified`; user-stories.md §1 |
| R30 | Depois do cadastro, o sistema envia um e-mail de confirmação ao endereço informado | Ação | user-stories.md §1; ADR-009, Contexto |
| R31 | O envio passa pela interface `MailProvider` (Nodemailer + Ethereal em dev, SMTP em produção) | Regra | ADR-009 |
| R32 | Ao confirmar, o sistema grava `users.email_verified = true` | Ação | user-stories.md §1; diagrama de classes, `Usuario.confirmarEmail()` |
| R33 | O visitante pode pedir o reenvio do e-mail de confirmação | Ação | `03`, FA 5–6 |
| R34 | Senha, hash, e-mail e token de confirmação não vão para o log | Regra | ADR-019 |

## Critérios de aceite

- **CA1** (R3–R9, R10, R12, R18–R23, R29, R30) — **Dado** um e-mail novo, **quando** o visitante preenche os
  campos, aceita os termos e clica em Criar conta, **então** a API responde `201`, grava o usuário com
  `terms_accepted = true`, `email_verified = false` e a senha com hash, e envia o e-mail de confirmação.
- **CA2** (R24, R25) — **Dado** o cadastro concluído, **quando** a API responde `201`, **então** a tela mostra a
  mensagem de sucesso e segue o destino decidido em L8.
- **CA3** (R10, R11, R16) — **Dado** um campo obrigatório vazio, um e-mail em formato inválido ou uma senha fora da
  regra, **quando** envia, **então** a API responde `400` e a tela mostra o erro no campo.
- **CA4** (R8, R9) — **Dado** o formulário sem o aceite dos termos, **quando** tenta enviar, **então** o cadastro
  não acontece e a tela pede o aceite.
- **CA5** (R12, R13) — **Dado** um e-mail já cadastrado, **quando** envia, **então** a API responde `409` e nenhum
  usuário é criado.
- **CA6** (R14, R15) — **Dado** o e-mail de uma conta excluída, **quando** envia, **então** a API responde `409
  ACCOUNT_DELETED` e a tela sugere reativar a conta.
- **CA7** (R7) — **Dado** o seletor de tipo de usuário, **quando** a tela abre, **então** só aparecem os tipos
  decididos em L1; um `role` fora deles enviado direto à API responde `400`.
- **CA8** (R32) — **Dado** um link de confirmação válido, **quando** o visitante o abre, **então**
  `email_verified` passa a `true` e a tela confirma.
- **CA9** (R32) — **Dado** um link expirado, inválido ou já usado, **quando** o visitante o abre, **então** a tela
  mostra o erro e oferece o reenvio.
- **CA10** (R33) — **Dado** um usuário com e-mail não confirmado, **quando** pede o reenvio, **então** um novo
  e-mail sai, dentro do limite definido.
- **CA11** (R27) — **Dado** o envio em andamento, **quando** o visitante olha a tela, **então** o botão mostra
  carregando e não aceita um segundo clique.
- **CA12** (R34) — **Dado** um cadastro, **quando** se lê o log, **então** não há senha, hash, e-mail nem token.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `email` (único), `password_hash`, `role` (`user_role`, sem default), `status` (default `ACTIVE`), `email_verified` (default `false`), `terms_accepted` (default `false`), `oauth_provider`, `oauth_id`, `deleted_at` | Já existe no `schema.prisma` |
| (token de confirmação) | — | O DBML não tem onde guardar o token de confirmação (L4) |

Enums: `user_role` (CUSTOMER, SELLER, ADMIN) · `user_status` (ACTIVE, SUSPENDED).

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Login, aba Criar Conta | [238-1204](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=238-1204) | R3–R6, R8, R24 | ❌ Não bate |

- **Onde o Figma está errado** (vale a documentação): 238-1204 — o botão "Entrar com Google" fica na aba de cadastro;
  o login com Google é da CCD004 (e ele cria a conta, ver L6 da CCD004).
- **O que falta no Figma:**
  - R7 — o seletor de tipo de usuário;
  - R28–R33 — as telas "confirme seu e-mail" (com reenviar), "e-mail confirmado" e "link inválido ou expirado";
  - R13–R15 — as mensagens de e-mail já cadastrado e de conta excluída.
- O Figma mostra nome, e-mail, senha com medidor de força, confirmar senha e aceite de "Termos de Uso" e "Política de
  Privacidade", que batem com R4–R6 e R8. A regra "mínimo 8 com números e símbolos" do Figma não está na
  documentação (L2).

## Fora do escopo

- Login, inclusive o Google que cria a conta — CCD004. Reativação de conta excluída — CCD052.
- Telas com o texto dos Termos de Uso e da Política de Privacidade: não estão na documentação.
- O fluxo alternativo do caso de uso ("Nenhum resultado encontrado para o termo pesquisado") foi copiado do CCD002 e
  não vira requisito.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais tipos de usuário podem se cadastrar? (`ADMIN` por autocadastro daria acesso ao BackOffice; o vendedor precisa de aprovação?) | Cliente ou Vendedor (`CUSTOMER`/`SELLER`); `ADMIN` só é criado pelo BackOffice (CCD059). O vendedor entra sem aprovação no MVP; o credenciamento é a CCD094 (escopo adicional) | `03`, FP 2 |
| L2 | Regra de senha (tamanho, complexidade, "confirmar senha"), a mesma para CCD003, CCD006 e CCD051 | Mínimo de 8 caracteres, com letra, número e símbolo, mais a confirmação; a mesma regra na CCD006 e na CCD051 | `03`, FP 2 e FP 4; `06`, FP 7 |
| L3 | Normalização do e-mail (trim e minúsculas), igual na CCD004 e na CCD006 | Sem espaços nas pontas e em minúsculas, igual na CCD004 e na CCD006 | `03`, FP 4; `04`, FP 4 |
| L4 | Mecanismo e armazenamento da confirmação: link com token assinado (sem tabela) ou tabela nova no DER; validade e uso único | Link com JWT assinado (`purpose: verify-email`), válido por 24 horas, sem tabela; confirmar é idempotente | ADR-048, item 1; `03`, FP 5 |
| L5 | Reenvio da confirmação: limite, se invalida o anterior, resposta genérica para e-mail inexistente ou já confirmado | Reenvio com limite de pedidos (rate limit), sem invalidar o link anterior, e resposta igual para e-mail inexistente ou já confirmado | `03`, FA 5–6; ADR-048, item 1 |
| L6 | Conta nunca confirmada: prende o e-mail? Novo cadastro com o mesmo e-mail responde `409`? | A conta não confirmada prende o e-mail; novo cadastro responde `409` e oferece o reenvio | `03`, FA 2 |
| L7 | O cadastro cria `profiles` e `collections` (1:1) junto, ou eles nascem nas stories deles? | Não: `profiles` e `collections` nascem nas stories deles | esta spec |
| L8 | Logo após o cadastro: login automático, tela de login ou tela "confirme seu e-mail"? Texto da mensagem de sucesso | Tela "Confirme seu e-mail" com reenviar; depois do link, Login com a mensagem "E-mail confirmado" | `03`, FP 5 e FP 7 |
| L9 | Falha no envio do e-mail derruba o cadastro? | Não derruba: mantém o cadastro e permite o reenvio | `03`, FA 4 |
| L10 | Detalhes técnicos sem ADR (caminho do endpoint, códigos de erro, rate limit do cadastro e do reenvio): o plano define seguindo os ADRs? | Sim, o plano define seguindo os ADRs 005, 011 e 019 | plano.md |
| L11 | E-mail que já pertence a uma conta criada pelo Google: `409` ou vincula a senha? | `409 EMAIL_ALREADY_REGISTERED`; vincular a conta Google acontece só no login com Google | `03`, FA 2; `04`, FA 6 |
