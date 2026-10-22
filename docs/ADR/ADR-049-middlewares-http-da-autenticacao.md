# ADR-049 — Middlewares HTTP da autenticação: `express-rate-limit` e `cookie-parser`

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

Os planos das specs CCD003, CCD004 e CCD006 (aprovadas em 22/10/2026) precisam de duas coisas que o esqueleto do
backend não tem e que nenhum ADR escolhe:

- **limite de tentativas** no login, no login com Google, no cadastro, no reenvio da confirmação e no pedido de
  redefinição de senha, contra força bruta e envio de e-mail em massa;
- **leitura do cookie `httpOnly`** do refresh token (ADR-005, item 3; ADR-043), que o Express 5 não faz sozinho.

O ADR-005 e o ADR-008 já escolhem `argon2`, `google-auth-library`, `nodemailer` (ADR-009) e `node-cron` (ADR-010);
estas duas bibliotecas ficaram de fora.

## Decisão

1. Use **`express-rate-limit`** nas rotas públicas de autenticação, com o limite de cada rota definido no plano da
   spec (ex.: 5 pedidos por minuto por IP no login). A resposta acima do limite é `429` com o envelope de erro do
   ADR-011 (`code: "TOO_MANY_REQUESTS"`).
2. Use **`cookie-parser`** só no roteador de `/api/v1/auth`, que é o único que lê o cookie `cromocard_refresh`.
3. Em teste (`NODE_ENV=test`), o rate limit fica desligado, para os testes de integração não dependerem de tempo.

## Alternativas consideradas

- **Rate limit próprio em memória:** pouco código, mas reimplementa janela, cabeçalhos `RateLimit-*` e limpeza que a
  biblioteca já tem testados.
- **Rate limit no proxy (nginx) ou no provedor:** não existe proxy no ambiente local nem em homologação ainda.
- **Ler o cookie à mão (`req.headers.cookie`):** evita uma dependência, mas o parse e a decodificação ficam por conta
  do time.

## Consequências

- `package.json` do backend ganha `express-rate-limit` e `cookie-parser` (e `@types/cookie-parser`).
- O armazenamento do rate limit é em memória: com mais de uma instância da API, cada uma conta separado. Quando
  houver mais de uma instância, troca-se o store por Redis num ADR novo.
- Os números de cada limite ficam nos planos das specs e no `.env.example` quando forem configuráveis.

## Referências

- ADR-005 (autenticação), ADR-011 (envelope de erro), ADR-043 (sessão no frontend)
- `specs/CCD003-criar-conta/plano.md`, `specs/CCD004-realizar-login/plano.md`, `specs/CCD006-recuperar-senha/plano.md`
