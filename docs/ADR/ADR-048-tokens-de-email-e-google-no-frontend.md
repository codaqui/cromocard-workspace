# ADR-048 — Tokens de confirmação de e-mail e de redefinição de senha, e client ID do Google no frontend

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-10-21
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

As specs CCD003, CCD004 e CCD006 decidiram que o e-mail precisa ser confirmado antes do login, que o link de
redefinição vale 1 hora e uso único, e que o login com Google fica na tela de Login. Três pontos técnicos não são
cobertos pelos ADRs:

- o DER não tem onde guardar o token de confirmação de e-mail;
- `password_reset_tokens.token` sugere guardar o valor puro, enquanto `refresh_tokens` guarda só o hash (ADR-005) e o
  ADR-019 trata tokens como segredo;
- o Google Identity Services precisa do client ID no navegador, e o ADR-045 só prevê `API_URL` no runtime.

## Decisão

1. **Confirmação de e-mail com token assinado, sem tabela.** O link leva um JWT HS256 assinado com `JWT_SECRET`,
   com `sub` (id do usuário), `purpose: "verify-email"` e validade de 24 horas (`EMAIL_VERIFICATION_TTL`). Confirmar
   é idempotente: um link antigo ainda válido só confirma de novo. O token nunca vale como access token, porque o
   `authenticate` recusa qualquer `purpose`.
2. **Token de redefinição opaco, guardado com hash.** 32 bytes aleatórios (`crypto.randomBytes`) em base64url no
   link; o banco guarda só o SHA-256 em `password_reset_tokens.token`. Validade de 1 hora (`PASSWORD_RESET_TTL`),
   uso único (`used`), e um pedido novo marca os pendentes do usuário como usados.
3. **Índice único em `users (oauth_provider, oauth_id)`**, para a busca do login com Google (ADR-005, item 2).
4. **`GOOGLE_CLIENT_ID` no runtime do frontend**, no mesmo `/env.js` da `API_URL` (ADR-045). O client ID é público;
   não é segredo.

## Alternativas consideradas

- **Tabela `email_verification_tokens`:** permitiria revogar links antigos, mas exige mudar o DER nos três formatos e
  um job de limpeza a mais, para um link cujo único efeito é idempotente.
- **Guardar o token de redefinição puro:** quem lê o banco poderia trocar a senha de qualquer conta.

## Consequências

- O `.env.example` do backend ganha `EMAIL_VERIFICATION_TTL`, `PASSWORD_RESET_TTL`, `FRONTEND_URL` (base dos links)
  e `GOOGLE_CLIENT_ID`; o do frontend ganha `VITE_GOOGLE_CLIENT_ID`.
- Trocar o `JWT_SECRET` invalida os links de confirmação pendentes; a pessoa pede o reenvio.
- O DER foi ajustado: nota em `password_reset_tokens.token` e o índice único em `users`.
