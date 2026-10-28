# CCD006 — Recuperar Senha

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #111 `CCD006-Recuperar Senha`
- **Caso de uso:** [06-recuperar-senha.md](../../docs/Casos-De-Uso/06-recuperar-senha.md)
- **Atores:** Visitante · **Pré-condições:** estar na tela de Login e selecionar a opção de recuperação
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

Escopo combinado: pedir a recuperação pelo e-mail, receber o link, redefinir a senha e o que acontece depois. A tela
de Login é da [CCD004](../CCD004-realizar-login/spec.md).

## Objetivo

> Como visitante eu quero solicitar a recuperação da minha senha caso eu a esqueça.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | A tela de Login oferece "Esqueci minha senha", que abre a recuperação | Ação | `06-recuperar-senha.md`, Pré-condição e FP 1; `.puml` (UC004 extend UC006) |
| R2 | Tela de recuperação que pede o e-mail cadastrado | Tela | `06`, FP 2 |
| R3 | Campo E-mail | Campo | `06`, FP 2–3; DBML `users.email` |
| R4 | O visitante envia o pedido | Ação | `06`, FP 3 |
| R5 | O formato do e-mail é validado no formulário e na API | Regra | `06`, FA 1; ADR-006; ADR-042 |
| R6 | Com formato inválido, aparece uma mensagem de erro; a API responde `400 VALIDATION_ERROR` | Mensagem | `06`, FA 1; ADR-011 |
| R7 | O sistema verifica se o e-mail existe em `users` | Regra | `06`, FP 4 |
| R8 | Se o e-mail existe, o sistema envia um link de redefinição para ele | Ação | `06`, FP 5 |
| R9 | Depois do pedido, a tela mostra uma confirmação genérica de envio | Mensagem | `06`, FP 5 e FA 1 |
| R10 | A resposta não revela se o e-mail existe: cadastrado e não cadastrado recebem a mesma mensagem | Regra | `06`, FA 1 |
| R11 | Cada pedido gera um token em `password_reset_tokens`, ligado ao usuário | Regra | DBML `password_reset_tokens`; diagrama de classes `TokenRecuperacaoSenha.gerar()` |
| R12 | O token é único | Regra | DBML `password_reset_tokens.token` (unique) |
| R13 | Todo token tem data de expiração | Regra | DBML `password_reset_tokens.expires_at` |
| R14 | O token nasce como não usado | Regra | DBML `password_reset_tokens.used` (default false) |
| R15 | O e-mail sai pela interface `MailProvider` | Regra | ADR-009; ADR-018 (`MAIL_*`) |
| R16 | A rota de recuperação tem rate limit; passar do limite responde `429` | Regra | ADR-002; ADR-011 |
| R17 | Pedido e redefinição funcionam sem autenticação, em rotas públicas | Permissão | `06`, Atores; ADR-038 |
| R18 | O link abre uma tela de redefinição de senha | Tela | `06`, FP 5 ("link de redefinição") |
| R19 | Na redefinição, o token precisa existir, não estar usado e não estar expirado | Regra | DBML `token`, `used`, `expires_at`; classes `TokenRecuperacaoSenha.validar()` |
| R20 | Com token válido, o visitante define a senha nova, que substitui `users.password_hash` | Ação | `06`, FP 5; DBML `users.password_hash` |
| R21 | A senha nova é guardada só como hash (argon2, ou bcrypt com custo ≥ 12) | Regra | ADR-005, item 1 |
| R22 | Depois da redefinição, o token passa a `used = true` e não é aceito de novo | Regra | DBML `used`; classes `marcarComoUsado()` |
| R23 | Os tokens expirados são apagados fisicamente pelo job diário de limpeza | Regra | ADR-015, item 9; ADR-010 |
| R24 | O log nunca registra token, senha, hash nem e-mail | Regra | ADR-019 |
| R25 | Rotas sob `/api/v1`, como ações `POST`, com erros `{ error, message, details? }` | Regra | ADR-011; ADR-006 |
| R26 | Os formulários de pedido e de redefinição mostram o estado de envio e o erro da API | Estado | ADR-042 |

## Critérios de aceite

- **CA1** (R1–R4, R7, R8, R11–R15) — **Dado** um usuário ativo, **quando** pede a recuperação com o e-mail dele,
  **então** um token é gravado com expiração, sem uso, e o e-mail com o link sai pelo `MailProvider`.
- **CA2** (R9, R10) — **Dado** um e-mail cadastrado e outro não cadastrado, **quando** pede a recuperação com cada
  um, **então** a API responde igual e a tela mostra a mesma confirmação genérica.
- **CA3** (R5, R6) — **Dado** um e-mail em formato inválido, **quando** envia, **então** a API responde `400` e a
  tela mostra o erro no campo.
- **CA4** (R16) — **Dado** um IP que passou do limite de pedidos, **quando** pede de novo, **então** a API responde
  `429`.
- **CA5** (R18–R22) — **Dado** um link válido, **quando** o visitante define a senha nova, **então** o
  `password_hash` muda, o token fica com `used = true` e a tela segue o destino decidido em L5.
- **CA6** (R19) — **Dado** um link expirado, inválido ou já usado, **quando** o visitante tenta redefinir, **então**
  a API recusa, a senha não muda e a tela oferece pedir um link novo.
- **CA7** (R20, R21) — **Dado** uma senha nova fora da regra de senha, **quando** envia, **então** a API responde
  `400` e o token continua válido.
- **CA8** (R23) — **Dado** tokens de recuperação expirados, **quando** o job diário roda, **então** eles são
  apagados.
- **CA9** (R24) — **Dado** um pedido e uma redefinição, **quando** se lê o log, **então** não há token, senha, hash
  nem e-mail.
- **CA10** (R26) — **Dado** um envio em andamento, **quando** o visitante olha a tela, **então** o botão mostra
  carregando e não aceita um segundo clique.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `email`, `password_hash`, `status`, `email_verified`, `oauth_provider`, `deleted_at` | Já existe no `schema.prisma` |
| `password_reset_tokens` | `user_id` (FK), `token` (único), `expires_at`, `used` | Tabela nova. O nome `token` sugere valor puro; o `refresh_tokens` guarda hash (L3) |
| `refresh_tokens` | `revoked_at` | Só se a redefinição revogar as sessões (L5). Tabela da CCD004 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Login, link "Esqueceu a senha?" | [152-2587](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=152-2587) | R1 | ✅ Bate |

- **O que falta no Figma:** R2–R9 (tela "Esqueci minha senha" com o campo e a confirmação genérica) e R18–R22 (tela
  "Redefinir senha", a mensagem de link inválido ou expirado e a de sucesso). Implementar no estilo da tela de Login.

## Fora do escopo

- Trocar a senha estando logado — CCD051.
- Reativação de conta excluída — CCD052.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Fluxo da redefinição (vai para o caso de uso): campos (senha nova e confirmação), quando o token é validado, mensagens | Senha nova e confirmação; o link é validado ao abrir e ao gravar; mensagens de sucesso e de link inválido | `06`, FP 6–8 e FA 3 |
| L2 | Validade do link, uso único, e se um pedido novo invalida os links anteriores | 1 hora, uso único, e um pedido novo invalida os links anteriores | `06`, FP 5; ADR-048, item 2 |
| L3 | O token é guardado puro ou com hash (SHA-256, como no `refresh_tokens`)? Como é gerado? | 32 bytes aleatórios no link; o banco guarda só o SHA-256 | ADR-048, item 2 |
| L4 | Regra da senha nova: a mesma da CCD003 (L2 de lá)? Senha igual à atual é aceita? | A mesma regra do cadastro; senha igual à atual é aceita | `06`, FP 7 |
| L5 | Depois de redefinir: revoga as sessões abertas? Login automático ou volta ao login? | Revoga todas as sessões e volta ao login com "Senha alterada" | `06`, FP 7–8 |
| L6 | Conta `SUSPENDED` ou excluída: recebe o link? | Não recebe; a resposta é a mesma confirmação genérica | `06`, FA 2 |
| L7 | Conta só Google (`password_hash` nulo): recebe o link e passa a ter senha? | Recebe e passa a ter senha, entrando dos dois jeitos | `06`, FA 4 |
| L8 | E-mail não confirmado: usar o link confirma o e-mail? | Sim, usar o link confirma o e-mail | `06`, FP 7 |
| L9 | E-mail avisando "sua senha foi alterada"? | Sim, um e-mail avisa da troca | `06`, FP 7 |
| L10 | Detalhes técnicos sem ADR (caminhos, status do pedido, tempo de resposta igual para e-mail existente e inexistente, números do rate limit, formato do link): o plano define seguindo os ADRs? | Sim, o plano define seguindo os ADRs 005, 011 e 019 | plano.md |
| L11 | O caso de uso junta dois desvios no FA 1 (formato inválido e e-mail inexistente): separar em FA 1 e FA 2? | Sim: FA 1 (formato inválido) e FA 2 (e-mail inexistente, conta suspensa ou excluída) | `06`, FA 1–2 |
