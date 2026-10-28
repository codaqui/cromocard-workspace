# CCD004 — Realizar Login

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #109 `CCD004-Realizar Login`
- **Caso de uso:** [04-realizar-login.md](../../docs/Casos-De-Uso/04-realizar-login.md)
- **Atores:** Visitante · **Pré-condições:** possuir cadastro ativo e estar na tela de Login
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

Escopo combinado: login com e-mail e senha, "lembrar de mim", login com Google, renovação do access token, logout e
a sessão real no frontend (substitui o token de desenvolvimento). Cadastro é a [CCD003](../CCD003-criar-conta/spec.md)
e recuperação de senha é a [CCD006](../CCD006-recuperar-senha/spec.md).

## Objetivo

> Como visitante eu quero fazer login com e-mail/senha ou Google, com a opção de lembrar usuário.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Tela de Login na área pública do SPA, sem guard | Tela | `04-realizar-login.md`, FP 1; ADR-038 (área Pública) |
| R2 | Campo E-mail | Campo | `04`, FP 2 e FP 3 |
| R3 | Campo Senha | Campo | `04`, FP 2 e FP 3 |
| R4 | Botão que envia e-mail e senha | Ação | `04`, FP 3 |
| R5 | Opção "lembrar de mim" | Campo | user-stories.md §1 "Realizar Login"; ADR-005, item 3 |
| R6 | Login social com Google | Ação | `04`, FP 2; user-stories.md §1; ADR-005, item 2 |
| R7 | Link "Esqueci minha senha", que leva à recuperação (CCD006) | Ação | `06-recuperar-senha.md`, Pré-condições e FP 1 |
| R8 | A API valida os campos antes de autenticar | Regra | `04`, FP 4; ADR-006 |
| R9 | Entrada inválida responde `400 VALIDATION_ERROR` com `details` por campo | Regra | ADR-006; ADR-011 |
| R10 | A senha é conferida com `users.password_hash` (argon2, ou bcrypt com custo ≥ 12) | Regra | ADR-005, item 1; DBML `users.password_hash` |
| R11 | Credenciais que não batem mostram "E-mail ou senha incorretos", a mesma mensagem para e-mail inexistente e senha errada | Mensagem | `04`, FA 1 |
| R12 | Usuário com `status = SUSPENDED` não loga | Regra | ADR-005, item 6; DBML `user_status` |
| R13 | Usuário com `deleted_at` preenchido não loga | Regra | ADR-005, item 6; ADR-015, item 8 |
| R14 | Login em conta excluída responde `403 ACCOUNT_DELETED` | Mensagem | ADR-015, item 8 |
| R15 | O login emite um access token JWT HS256 assinado com `JWT_SECRET` | Regra | ADR-005, item 3; ADR-018 |
| R16 | O access token vale 15 min (`JWT_ACCESS_TTL`) | Regra | ADR-005, item 3; ADR-018 |
| R17 | O payload do access token tem só `sub` e `role` | Regra | ADR-005, item 3 |
| R18 | O login emite um refresh token aleatório e opaco (não é JWT) | Regra | ADR-005, item 3 |
| R19 | O refresh é salvo só como hash SHA-256 em `refresh_tokens.token_hash` | Regra | ADR-005, item 3; DBML `refresh_tokens` |
| R20 | Sem "lembrar", o refresh vale 1 dia (`REFRESH_TTL`) | Regra | ADR-005, item 3; ADR-018 |
| R21 | Com "lembrar", o refresh vale 30 dias (`REFRESH_TTL_REMEMBER`) | Regra | ADR-005, item 3; DBML nota de `refresh_tokens.expires_at` |
| R22 | Na web, o refresh vai em cookie `httpOnly` + `Secure` + `SameSite` | Regra | ADR-005, item 3; ADR-043 |
| R23 | As rotas de login têm rate limit; passar do limite responde `429` | Regra | ADR-002 (segurança HTTP); ADR-011 |
| R24 | O frontend obtém o `id_token` pelo Google Identity Services e envia à API | Ação | ADR-005, item 2 |
| R25 | A API valida o `id_token` com `google-auth-library` (assinatura, `aud` = `GOOGLE_CLIENT_ID`, `exp`) | Regra | ADR-005, item 2; ADR-018 |
| R26 | A API procura o usuário por `oauth_provider = 'google'` + `oauth_id = sub` | Regra | ADR-005, item 2; DBML `users.oauth_*` |
| R27 | Se o usuário Google não existir, a API cria a conta (`CUSTOMER`, e-mail confirmado, termos aceitos) | Regra | ADR-005, item 2; `04`, FA 6 |
| R28 | O login com Google segue o mesmo fluxo do login com senha: mesmos tokens e mesmos bloqueios | Regra | ADR-005, itens 2, 3 e 6 |
| R29 | A renovação emite um novo access token a partir do refresh do cookie | Ação | ADR-005, item 3; ADR-043 |
| R30 | Rotação: cada renovação revoga o refresh usado (`revoked_at`) e emite um novo | Regra | ADR-005, item 3; DBML `refresh_tokens.revoked_at` |
| R31 | Reusar um refresh já revogado revoga todas as sessões do usuário | Regra | ADR-005, item 3 |
| R32 | O reuso de refresh é registrado no log em nível `warn` | Regra | ADR-019 |
| R33 | Refresh expirado ou inválido não renova e responde `401` | Regra | ADR-005, item 3; ADR-011 |
| R34 | Usuário suspenso ou excluído não renova o token | Regra | ADR-005, item 6 |
| R35 | O logout revoga o refresh token (`revoked_at`) | Ação | ADR-005, item 3 |
| R36 | No frontend, o `signOut` apaga o access token da memória e limpa o cache do TanStack Query | Ação | ADR-043 |
| R37 | O access token fica só em memória, nunca em `localStorage` ou `sessionStorage` | Regra | ADR-043 |
| R38 | O cliente HTTP envia o cookie do refresh (`withCredentials: true`) | Regra | ADR-041; ADR-043 |
| R39 | O cliente HTTP envia `Authorization: Bearer <access token>` | Regra | ADR-041; ADR-005, item 3 |
| R40 | O `user` (`{ id, role }`) sai do payload do JWT validado com Zod; token expirado, malformado ou com papel desconhecido conta como "sem sessão" | Regra | ADR-043 |
| R41 | Ao iniciar, o app tenta renovar a sessão pelo cookie, e a sessão sobrevive ao F5 | Estado | ADR-043, Consequências |
| R42 | Num `401`, o cliente renova o token e repete a requisição; se a renovação falhar, encerra a sessão | Regra | ADR-005, ADR-041 e ADR-043, Consequências |
| R43 | Depois do login, cada papel vai para a home da sua área; `ADMIN` vai para `/backoffice` | Estado | ADR-038; `04`, FP 5 |
| R44 | `RequireAuth` manda quem não tem sessão para fora da área autenticada | Permissão | ADR-043, Guards |
| R45 | `RequireRole` manda quem não tem sessão para fora e quem tem outro papel para a home do próprio papel | Permissão | ADR-043, Guards |
| R46 | Quem autoriza é a API (`authorize(...roles)`); o guard do frontend só controla a navegação | Permissão | ADR-005, item 4; ADR-038; ADR-043 |
| R47 | Remover o `VITE_DEV_ACCESS_TOKEN` (`DEV_ACCESS_TOKEN` no runtime) e a seção "Sessão de desenvolvimento" do README do frontend | Regra | ADR-043, Consequências; ADR-045 |
| R48 | A tela mostra o `message` de erro que vem da API, em pt-BR | Mensagem | ADR-041; ADR-011 |
| R49 | Rotas sob `/api/v1`; sucesso em `{ data }` e erro em `{ error, message, details? }` | Regra | ADR-011; ADR-006 |
| R50 | Senhas, hashes, tokens, o header `Authorization`, cookies e e-mail nunca vão para o log | Regra | ADR-019 |
| R51 | `JWT_ACCESS_TTL`, `REFRESH_TTL`, `REFRESH_TTL_REMEMBER` e `GOOGLE_CLIENT_ID` são validadas no `env`; a API não sobe se faltar alguma | Regra | ADR-005, Consequências; ADR-018 |
| R52 | Um job diário apaga fisicamente os `refresh_tokens` expirados | Regra | ADR-010; ADR-015, item 9 |

## Critérios de aceite

- **CA1** (R1–R4, R8, R10, R15–R20, R22, R43) — **Dado** um cliente ativo com e-mail confirmado, **quando** informa
  e-mail e senha corretos e clica em Entrar, **então** a API responde `200` com o access token, grava um
  `refresh_tokens` com `expires_at` em 1 dia, envia o cookie httpOnly e o app abre a home da área Cliente.
- **CA2** (R5, R21) — **Dado** o mesmo cliente, **quando** entra com "lembrar de mim" marcado, **então** o refresh
  gravado expira em 30 dias.
- **CA3** (R43) — **Dado** um usuário `ADMIN`, **quando** faz login, **então** o app abre `/backoffice`.
- **CA4** (R11) — **Dado** um e-mail inexistente ou uma senha errada, **quando** tenta entrar, **então** a API
  responde `401` e a tela mostra "E-mail ou senha incorretos", a mesma mensagem nos dois casos.
- **CA5** (R8, R9) — **Dado** o formulário com e-mail em formato inválido ou campo vazio, **quando** envia, **então**
  a API responde `400 VALIDATION_ERROR` e a tela mostra o erro no campo.
- **CA6** (R12) — **Dado** um usuário `SUSPENDED`, **quando** informa a senha correta, **então** a API responde
  `403` e a tela mostra a mensagem de conta suspensa; nenhum token é emitido.
- **CA7** (R13, R14) — **Dado** um usuário com `deleted_at` preenchido, **quando** tenta entrar, **então** a API
  responde `403 ACCOUNT_DELETED` e nenhum token é emitido.
- **CA8** (R23) — **Dado** um mesmo IP que passou do limite de tentativas, **quando** tenta de novo, **então** a API
  responde `429`.
- **CA9** (R6, R24–R28) — **Dado** um `id_token` válido de uma conta Google já vinculada, **quando** o visitante
  entra com o Google, **então** recebe os mesmos tokens do login com senha.
- **CA10** (R27) — **Dado** um `id_token` válido de um e-mail sem conta, **quando** entra com o Google, **então** a
  conta é criada com os valores decididos em L6 e o login acontece.
- **CA11** (R25) — **Dado** um `id_token` inválido ou expirado, **quando** é enviado, **então** a API responde `401`
  e nenhuma conta é criada.
- **CA12** (R29, R30) — **Dado** um refresh válido no cookie, **quando** o app pede a renovação, **então** recebe um
  novo access token, o refresh antigo fica com `revoked_at` e um novo é gravado.
- **CA13** (R31, R32) — **Dado** um refresh já revogado, **quando** alguém tenta renová-lo, **então** a API responde
  `401`, todas as sessões do usuário são revogadas e o log registra `warn`.
- **CA14** (R33, R34) — **Dado** um refresh expirado, ou o usuário suspenso ou excluído, **quando** o app pede a
  renovação, **então** a API responde `401`.
- **CA15** (R35, R36) — **Dado** um usuário logado, **quando** clica em Sair, **então** o refresh é revogado, o
  cookie é limpo, o access token sai da memória e o app volta para a área pública.
- **CA16** (R37, R41) — **Dado** um usuário logado, **quando** recarrega a página, **então** a sessão continua, sem
  nenhum token em `localStorage` ou `sessionStorage`.
- **CA17** (R42) — **Dado** um access token expirado e um refresh válido, **quando** o app faz uma requisição,
  **então** ela recebe `401`, o app renova o token e a requisição é repetida com sucesso.
- **CA18** (R44, R45) — **Dado** um visitante sem sessão, **quando** abre uma rota da área Cliente ou do BackOffice,
  **então** é levado ao login; **dado** um `CUSTOMER`, **quando** abre `/backoffice`, **então** volta para a home dele.
- **CA19** (R46) — **Dado** um token de `CUSTOMER`, **quando** chama uma rota `authorize('ADMIN')`, **então** a API
  responde `403`.
- **CA20** (R47) — **Dado** o build do frontend, **quando** se procura `DEV_ACCESS_TOKEN`, **então** não há
  referência no código nem no README.
- **CA21** (R50) — **Dado** um login com sucesso e um com falha, **quando** se lê o log, **então** não há senha,
  token, cookie nem e-mail.
- **CA22** (R52) — **Dado** refresh tokens expirados, **quando** o job diário roda, **então** eles são apagados e os
  válidos continuam.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `id`, `name`, `email` (único), `password_hash` (anulável: conta só Google), `role` (`user_role`), `status` (`user_status`), `email_verified`, `terms_accepted`, `oauth_provider`, `oauth_id`, `deleted_at` | Já existe no `schema.prisma`. O DBML não tem índice único em (`oauth_provider`, `oauth_id`) (L15) |
| `refresh_tokens` | `user_id` (FK), `token_hash` (único), `expires_at`, `revoked_at`, `user_agent`, `ip_address` | Tabela nova. Não há coluna para guardar o "lembrar" (L14) |

Enums: `user_role` (CUSTOMER, SELLER, ADMIN) · `user_status` (ACTIVE, SUSPENDED).

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Login (com abas Fazer Login / Criar Conta) | [152-2587](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=152-2587) | R1–R7 | ⚠️ Divergente |
| Painel Login (versão antiga, sem abas) | [77-533](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=77-533) | R1–R7 | Substituída pela 152-2587 (L3) |

- **Onde o Figma está errado** (vale a documentação): 152-2587 — o campo "E-mail ou ID colecionador" aceita ID; a
  documentação pede e-mail (R2) e o DER não tem ID de colecionador.
- **O que falta no Figma:** mensagens de conta suspensa e de conta excluída (R12–R14), estado de carregando no botão e
  o "Sair" nos cabeçalhos das áreas Cliente e BackOffice (R35).
- O Figma mostra "Lembrar de mim por 30 dias", "Esqueceu a senha?" e "Google", que batem com R5–R7. Não mostra
  Facebook (ver L1).

## Fora do escopo

- Cadastro (aba Criar Conta) — CCD003. Recuperação e redefinição de senha — CCD006.
- Reativação de conta excluída (`POST /api/v1/auth/restore`) — CCD052.
- Autenticação do WebSocket (ADR-005, item 5) e armazenamento seguro no mobile.
- Registrar login de admin em `audit_logs`: o ADR-034 trata de ações administrativas, não de login.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Facebook: o caso de uso 04 e o #109 citam; a user story, o ADR-005 e o Figma têm só Google. Sai do caso de uso? | Facebook sai; o login social é só o Google | `04`, Finalidade e FA 5–6 |
| L2 | Home de cada papel depois do login: o FP 5 manda todos para a Dashboard do Painel Cliente (CCD007, sem rota ainda); o ADR-038 manda o `ADMIN` para `/backoffice` | Cliente e Vendedor vão para o Painel Cliente; `ADMIN` vai para `/backoffice` | `04`, FP 5; ADR-038 |
| L3 | Rotas e navegação: rota da tela (`/login`), qual versão do Figma vale, se `RequireAuth` leva ao login e volta à URL pedida, e se quem já está logado é redirecionado ao abrir o login | Rota `/login`; vale o frame 152-2587; `RequireAuth` leva ao login e volta à URL pedida; quem já está logado é redirecionado para a sua home | `04`, FP 5; plano.md |
| L4 | Conta `SUSPENDED`: mensagem, e se o bloqueio é checado antes ou depois da senha | Mensagem "Sua conta está suspensa. Entre em contato com o suporte.", checada depois da senha | `04`, FA 3 |
| L5 | Conta excluída: texto da tela para o `403 ACCOUNT_DELETED` (a reativação é da CCD052) | Informa que a conta foi excluída e oferece a reativação (CCD052) | `04`, FA 4 |
| L6 | Conta criada pelo Google: `role`, `terms_accepted`, `email_verified` e `name`; cria `profiles`/`collections`? | `CUSTOMER`, `terms_accepted = true`, `email_verified = true`, `name` do Google; `profiles` e `collections` nascem nas stories deles | `04`, FA 6 |
| L7 | Login Google com e-mail que já tem conta com senha: vincula (preenche `oauth_*`) ou recusa com `409`? | Vincula (preenche `oauth_*`) e entra | `04`, FA 6 |
| L8 | Login com senha numa conta só Google (`password_hash` nulo): mesma mensagem genérica do FA 1? | Sim, a mesma mensagem genérica | `04`, FA 1 |
| L9 | E-mail não confirmado (`email_verified = false`, CCD003) bloqueia o login? | Bloqueia, com "Confirme seu e-mail para entrar" e o reenvio | `04`, FA 2; Pré-condições |
| L10 | Comparação do e-mail: ignora maiúsculas e espaços? (igual na CCD003 e na CCD006) | Ignora maiúsculas e espaços nas pontas | `04`, FP 4 |
| L11 | "Lembrar de mim": vem desmarcado? Sem ele, o cookie some ao fechar o navegador? Vale também para o Google? | Vem desmarcado; sem ele, a sessão dura até fechar o navegador; vale também para o Google | `04`, FP 2 e FP 5 |
| L12 | Logout: onde fica o "Sair", se tem confirmação e se existe "sair de todos os dispositivos" | "Sair" no cabeçalho das áreas Cliente e BackOffice, sem confirmação e sem "sair de todos os dispositivos" | `04`, FA 7–8 |
| L13 | Detalhes técnicos sem ADR: contrato (caminhos, status, corpo da resposta), códigos de erro, cookie (nome, `Path`, `SameSite`), números do rate limit, um só refresh em andamento, `user_agent`/`ip_address`, nome no cabeçalho (`GET /users/me`) e argon2 ou bcrypt — o plano define seguindo os ADRs? | Sim, o plano define seguindo os ADRs (argon2id, cookie `cromocard_refresh`, 5 pedidos por minuto) | plano.md, Decisões técnicas |
| L14 | Rotação sem coluna de "lembrar": o novo refresh herda o `expires_at` do anterior? | Sim, o refresh rotacionado herda o `expires_at` do anterior | plano.md, Decisões técnicas (ADR-005, item 3) |
| L15 | Índice único em (`oauth_provider`, `oauth_id`) no DER | Índice único em (`oauth_provider`, `oauth_id`) | ADR-048, item 3; DBML `users` |
| L16 | Variável de runtime do frontend para o client ID do Google: o ADR-045 só prevê `API_URL` | `GOOGLE_CLIENT_ID` no `/env.js` do frontend | ADR-048, item 4 |
| L17 | O job de limpeza dos refresh tokens (R52) entra nesta story? | Sim, o job diário entra nesta story (R52) | R52; ADR-010 |
