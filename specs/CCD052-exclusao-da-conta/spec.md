# CCD052 — Exclusão da Conta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1284 `CCD052 - Exclusão da Conta` (criada em 22/11/2026)
- **Caso de uso:** [52-exclusao-da-conta.md](../../docs/Casos-De-Uso/52-exclusao-da-conta.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com conta ativa (para excluir); conta excluída (para reativar)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso poder solicitar a exclusão definitiva da minha conta e dados da plataforma.

## Fidelidade ao Figma (obrigatória)

> ⚠️ **A tela implementada tem que ficar IGUAL ao Figma.** Os frames listados em **Telas (Figma)** são o contrato visual
> desta user story: não são referência, sugestão nem inspiração. Layout, ordem dos blocos, medidas, espaçamentos,
> alinhamentos, cores, tipografia (fonte, peso, tamanho e altura de linha), raios, bordas, sombras, ícones, imagens, textos
> (letra por letra) e estados (vazio, erro, carregando, hover, foco, desabilitado) seguem o frame. Medidas e cores saem do
> Figma, nunca "a olho".
>
> - Nada é inventado, trocado ou "melhorado" fora do frame. Diferença entre o Figma e a documentação vira lacuna em
>   **Lacunas e decisões** e é decidida antes do código (ADR-060). Até a decisão, vale a documentação.
> - O que o Figma não desenha (R marcado em "O que falta no Figma") segue o estilo da própria tela: os mesmos componentes,
>   tokens e espaçamentos.
> - A tela só está pronta quando o print dela em 1280 px, lado a lado com o print do frame, não mostra diferença. Em
>   celular (375 px), tablet (768 px) e laptop (1024 px), mantém o mesmo design adaptado, sem quebra, corte nem rolagem
>   horizontal.
> - A revisão (`/cromocard-revisor`) reprova o PR que não estiver igual ao Figma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Excluir a conta exige login (`401` sem token) e vale só para a própria conta | Permissão | `52`, Pré-condições; ADR-005 |
| R2 | Em "Configurações", o bloco "Excluir conta" mostra "Sua conta é desativada e some da plataforma. Você pode reativá-la entrando de novo com o mesmo e-mail." e o botão "Excluir minha conta" | Tela | `52`, FP 1–2; ADR-015, item 8; Figma `1160-41305` |
| R3 | "Excluir minha conta" abre o modal "Excluir sua conta?" com as consequências da exclusão ("Sua conta é desativada e some da plataforma. Para voltar, entre de novo com o mesmo e-mail e reative.") | Tela | `52`, FP 3–4; ADR-015, item 8; Figma `1160-43273` (L3) |
| R4 | O modal pede a confirmação de segurança antes de liberar "Confirmar Exclusão da Conta" ("Para confirmar, digite EXCLUIR ou insira sua senha atual:" e "Entendi o que acontece com a minha conta."); o botão fica desabilitado até a confirmação | Ação | `52`, FP 5–7; Figma `1160-43273` (L2) |
| R5 | Confirmar preenche `users.deleted_at`, revoga todos os refresh tokens do usuário e encerra a sessão no frontend | Regra | `52`, FP 8; ADR-015, item 8; ADR-005, itens 3 e 6 |
| R6 | Depois da exclusão, o perfil público, os anúncios e a coleção pública do usuário somem das consultas públicas | Regra | ADR-015, item 8 |
| R7 | Sem a confirmação de segurança válida, a conta não é excluída e a tela informa que a confirmação é necessária; a API responde `400` (ou `422 CURRENT_PASSWORD_INCORRECT` (não `401`, que faz o frontend tentar renovar a sessão) para senha errada) | Mensagem | `52`, FA 3–4 (L2) |
| R8 | "Cancelar" ou o "✕" fecha o modal e a conta continua ativa | Ação | `52`, FA 1–2 |
| R9 | No login de uma conta excluída (`403 ACCOUNT_DELETED`, CCD004), a tela de login oferece "Reativar conta" ("Esta conta foi excluída. Quer voltar? Reativar conta.") | Tela | ADR-015, item 8; CCD004, R14 e L5; Figma `1160-561` |
| R10 | "Reativar conta" chama `POST /api/v1/auth/restore` com as mesmas credenciais, que limpa `users.deleted_at` | Ação | ADR-015, item 8 (L7) |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-41305`, `1160-43273`, `1160-561`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** Gabriel logado, **quando** seleciona "Excluir minha conta", faz a confirmação de segurança, marca "Entendi o que acontece com a minha conta." e seleciona "Confirmar Exclusão da Conta", **então** `users.deleted_at` é preenchido, todos os `refresh_tokens` dele ficam com `revoked_at` e a sessão é encerrada.
- **CA2** (R4) — **Dado** o modal aberto sem a confirmação feita, **quando** Gabriel olha o botão, **então** "Confirmar Exclusão da Conta" está desabilitado.
- **CA3** (R7) — **Dado** uma senha atual errada (ou um texto diferente de "EXCLUIR"), **quando** Gabriel confirma, **então** a conta não é excluída e a tela informa que a confirmação é necessária.
- **CA4** (R8) — **Dado** o modal aberto, **quando** Gabriel seleciona "Cancelar" ou o "✕", **então** o modal fecha e a conta continua ativa.
- **CA5** (R6) — **Dado** a conta de um vendedor excluída, **quando** alguém abre o perfil público ou busca os anúncios dele, **então** não encontra nem o perfil nem os anúncios.
- **CA6** (R9, R10) — **Dado** a conta excluída, **quando** Gabriel tenta entrar, **então** a tela mostra "Esta conta foi excluída. Quer voltar? Reativar conta."; ao selecionar "Reativar conta" com as mesmas credenciais, `users.deleted_at` volta a `NULL`.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a rota de exclusão, **então** recebe `401`.
- **CA8** (R5) — **Dado** um refresh token emitido antes da exclusão, **quando** ele é usado em `POST /auth/refresh`, **então** a API recusa.
- **CA9** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print do bloco "Excluir conta" é comparado lado a lado com o do frame `1160-41305` (Configurações), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-43273` (excluir conta), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem (salvo os textos decididos na L3); e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-561` (login de conta excluída), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `deleted_at`, `password_hash`, `oauth_provider` | excluir = preencher `deleted_at`; reativar = voltar a `NULL` (ADR-015) |
| `refresh_tokens` | `user_id`, `revoked_at` | todas as sessões revogadas na exclusão |
| `profiles`, `listings`, `collections` | — (leitura) | as consultas públicas filtram o dono excluído (ADR-015, item 8) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações (bloco "Excluir conta") | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | R2 | ✅ Bate |
| Configurações - excluir conta | [1160-43273](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-43273) | R3, R4, R8 | ❌ Não bate: textos de trocas, ofertas e "serão apagadas" contrariam o escopo e o ADR-015 (L3); "EXCLUIR" como confirmação de segurança (L2) |
| Painel Login - conta excluída | [1160-561](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-561) | R9 | ✅ Bate (a mensagem é da CCD004; o "Reativar conta" é desta story) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): excluir conta — "Todas as 3 trocas pendentes e ofertas
  ativas serão revogadas instantaneamente." (trocas não existem no MVP e ofertas são fase Futuro) e "Catalogação digital e
  serializações vinculadas à sua carteira serão apagadas." (o ADR-015 não apaga nada e permite reativar; "carteira" está
  fora do escopo) (L3). O `52`, FP 6, pede "autenticação ou confirmação de segurança"; o Figma aceita digitar "EXCLUIR"
  ou a senha atual (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): a caixa "Entendi o que acontece com a minha
  conta." e o selo "Autenticação de Segurança" (L2).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 aviso de confirmação necessária; a tela depois
  da exclusão (L5); a reativação concluída (L7).

## Fora do escopo

- A mensagem de conta excluída no login e o `403 ACCOUNT_DELETED` — CCD004. Cadastro com e-mail de conta excluída (`409 ACCOUNT_DELETED`) — CCD003.
- Excluir a conta de outra pessoa pelo BackOffice — CCD059 e CCD098.
- Eliminar os dados de vez (anonimização, LGPD) — fora do MVP pelo ADR-015 (L1).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | A narrativa pede a "exclusão definitiva" da conta e dos dados; o ADR-015 (aceito) decide soft delete com reativação, e o Figma segue o ADR. Ajustar a narrativa e o `52`, FP 8 ("exclui ou desativa conforme as regras definidas")? | pendente | — |
| L2 | Confirmação de segurança: o Figma aceita digitar "EXCLUIR" ou a senha atual, mais a caixa "Entendi o que acontece com a minha conta.". Digitar uma palavra não é autenticação. Qual vale? E na conta só Google, sem senha? (proposta: senha atual; na conta Google, "EXCLUIR") | pendente | — |
| L3 | Os textos do modal citam trocas pendentes, ofertas e "serão apagadas" na "carteira", que contrariam o escopo e o ADR-015. Pedir ao Gabriel textos que digam o que acontece de fato (conta, anúncios, coleção e pedidos) | pendente | — |
| L4 | O que acontece com pedidos em andamento (`PAID`, `SHIPPED`), anúncios ativos, a conta Stripe do vendedor, grupos que a pessoa criou e as mensagens dela em conversas e grupos? A exclusão é bloqueada com pedido em andamento? | pendente | — |
| L5 | Para onde o usuário vai depois de excluir (proposta: tela de login com um aviso)? Não há frame | pendente | — |
| L6 | O ator é Cliente: `SELLER` exclui por aqui com as mesmas regras? O `ADMIN` pode excluir a própria conta? | pendente | — |
| L7 | Reativar: o usuário já entra logado depois do `restore`? E a conta criada pelo Google, sem senha, reativa como (`POST /auth/google`)? Não há frame da reativação concluída | pendente | — |
| L8 | A exclusão vai para o `audit_logs`? (o ADR-034 cobre ações administrativas) | pendente | — |
