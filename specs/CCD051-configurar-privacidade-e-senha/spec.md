# CCD051 — Configurar Privacidade e Senha

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** não encontrada no board
- **Caso de uso:** [51-configurar-privacidade-e-senha.md](../../docs/Casos-De-Uso/51-configurar-privacidade-e-senha.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com conta ativa
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso alterar minha senha e configurar as opções de privacidade do meu portfólio (público/privado).

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
| R1 | As configurações exigem login (`401` sem token) e só mudam a conta do próprio usuário | Permissão | `51`, Pré-condições; ADR-005 |
| R2 | Página "Configurações" (item "Configurações" no menu), com o topo "MINHA CONTA", "Configurações" e "Senha, privacidade e onde receber cada aviso: no site ou por e-mail.", e os blocos "Conta e segurança" e "Privacidade" | Tela | `51`, FP 1–2; Figma `1160-41305` |
| R3 | Em "Privacidade" ("Quem pode ver sua coleção."), a chave "Coleção pública" ("Outros colecionadores veem seus álbuns e o link de compartilhar funciona. Desligada, só você vê.") mostra e troca a privacidade do portfólio entre público e privado | Campo | `51`, FP 3; user story (público/privado); DBML `profiles.portfolio_privacy` (`PUBLIC`, `PRIVATE`, default `PUBLIC`) (L1) |
| R4 | O sistema valida e grava a nova preferência de privacidade e confirma ao usuário | Ação | `51`, FP 4 (L5) |
| R5 | Com a coleção privada, os álbuns e as cartas do usuário não aparecem para outras pessoas | Regra | user story ("privacidade do meu portfólio"); `51`, Finalidade (L2) |
| R6 | Em "Conta e segurança", a linha "Senha" tem "Alterar senha", que abre o modal "Alterar senha" com "Use pelo menos 8 caracteres, com letra, número e símbolo.", os campos "SENHA ATUAL", "NOVA SENHA" e "CONFIRMAR NOVA SENHA", "Cancelar" e "Alterar senha" | Tela | `51`, FP 5; Figma `1160-41859` |
| R7 | O sistema confere a senha atual com o hash gravado | Regra | `51`, FP 6; ADR-005, item 1 |
| R8 | A nova senha segue a regra do cadastro: no mínimo 8 caracteres, com letra, número e símbolo, e a confirmação igual | Regra | `51`, FP 6; `03`, FP 4; CCD003, L2 |
| R9 | Confirmar grava a nova senha só como hash (argon2, ou bcrypt com custo ≥ 12) e mostra o aviso "Senha alterada" com "Use a senha nova no próximo login." | Ação | `51`, FP 7–8; ADR-005, item 1; Figma `1160-42817` |
| R10 | Senha atual incorreta: a senha não muda e o rótulo do campo mostra "Senha atual • senha atual incorreta" em vermelho | Mensagem | `51`, FA 1–2; Figma `1160-42338` |
| R11 | Nova senha fora da regra: a senha não muda e a tela informa os requisitos da nova senha | Mensagem | `51`, FA 3–4 |
| R12 | "Cancelar" ou o "✕" do modal fecha sem alterar a senha; desistir da privacidade mantém a configuração anterior | Ação | `51`, FA 5–6 |
| R13 | Senha e hash não vão para o log | Regra | ADR-019; CCD003, R34 |
| R14 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-41305`, `1160-41859`, `1160-42338`, `1160-42817`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** Gabriel com a coleção pública, **quando** desliga "Coleção pública" e salva, **então** `profiles.portfolio_privacy` passa a `PRIVATE` e a tela confirma.
- **CA2** (R5) — **Dado** a coleção de Gabriel privada, **quando** outra pessoa tenta ver os álbuns dele, **então** não os vê.
- **CA3** (R6–R9) — **Dado** o modal "Alterar senha", **quando** Gabriel informa a senha atual certa e uma nova senha válida igual à confirmação, e seleciona "Alterar senha", **então** o hash é trocado, o modal fecha e aparece "Senha alterada" com "Use a senha nova no próximo login."; o login seguinte só funciona com a senha nova.
- **CA4** (R10) — **Dado** uma senha atual errada, **quando** Gabriel seleciona "Alterar senha", **então** a senha não muda, a API recusa e o rótulo mostra "Senha atual • senha atual incorreta" em vermelho.
- **CA5** (R8, R11) — **Dado** a nova senha "abc12345" (sem símbolo) ou uma confirmação diferente, **quando** Gabriel seleciona "Alterar senha", **então** a senha não muda, a API responde `400` e a tela informa os requisitos.
- **CA6** (R12) — **Dado** o modal preenchido, **quando** Gabriel seleciona "Cancelar" ou o "✕", **então** o modal fecha e a senha continua a mesma.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama as rotas de privacidade ou de senha, **então** recebe `401`.
- **CA8** (R13) — **Dado** uma troca de senha, **quando** se lê o log, **então** não há senha nem hash.
- **CA9** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-41305` (Configurações), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-41859` (alterar senha), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-42338` (senha atual incorreta), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-42817` (senha alterada), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `profiles` | `portfolio_privacy` (`privacy`: `PUBLIC`, `PRIVATE`) | obrigatória, default `PUBLIC` |
| `collections` | `is_public`, `share_link` | `is_public` default `false`: sobrepõe `portfolio_privacy` (L1) |
| `users` | `password_hash`, `oauth_provider` | `password_hash` opcional (conta só Google, L7) |
| `refresh_tokens` | `revoked_at` | só se a L6 decidir encerrar as outras sessões |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | R2–R4, R6 | ❌ Não bate: "Mostrar a cidade no perfil público", "Alterar e-mail" e "Alterada há 3 meses" só no Figma (L3, L4, L8) |
| Configurações - alterar senha | [1160-41859](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41859) | R6, R8 | ❌ Não bate: medidor "Senha forte" só no Figma (L9) |
| Configurações - senha atual incorreta | [1160-42338](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-42338) | R10 | ✅ Bate |
| Configurações - senha alterada | [1160-42817](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-42817) | R9 | ✅ Bate |

- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Mostrar a cidade no perfil público" ("Aparece
  abaixo do seu nome de usuário.") (L3); "E-mail" com "Alterar e-mail" (L4); "Alterada há 3 meses" (L8); o medidor "Senha
  forte" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 confirmação da privacidade salva; R11 aviso da
  regra da nova senha e da confirmação diferente.

## Fora do escopo

- "Contatos bloqueados" e "Ver bloqueados" — CCD047.
- "Canais de aviso", "Categorias e Eventos", "Canais ativos: 2" e "Restaurar Padrões" — CCD053 (EA-053-01).
- "Excluir conta" — CCD052.
- Recuperar a senha esquecida, sem login — CCD006.
- Compartilhar a coleção pelo link — CCD012.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O DBML tem duas colunas para a mesma coisa: `profiles.portfolio_privacy` (default `PUBLIC`) e `collections.is_public` (default `false`). Qual a chave "Coleção pública" grava? (proposta: uma só, com ajuste no DER e ADR) | pendente | — |
| L2 | O que a coleção privada esconde: álbuns e cartas no perfil público, a busca e o link de compartilhar ("o link de compartilhar funciona", só no Figma)? Isso muda a CCD012 | pendente | — |
| L3 | Só no Figma: "Mostrar a cidade no perfil público". O DBML não tem coluna para isso. Faz sentido implementar? | pendente | — |
| L4 | Só no Figma: "Alterar e-mail" (aqui e em "Canais de aviso"). Nenhum caso de uso trata a troca de e-mail (nova confirmação, ADR-048). Faz sentido implementar? Em qual story? | pendente | — |
| L5 | A privacidade grava na hora da chave ou só em "Salvar Preferências" (o rodapé "Cancelar" / "Salvar Preferências" parece ser das preferências de aviso, CCD053)? | pendente | — |
| L6 | Trocar a senha encerra as outras sessões (como a CCD006, FP 7) e manda e-mail avisando? | pendente | — |
| L7 | Conta criada pelo Google, sem senha: o que "Alterar senha" faz? (a CCD006, FA 4, cria a senha pelo link) | pendente | — |
| L8 | Só no Figma: "Alterada há 3 meses". O DBML não guarda a data da troca de senha. Faz sentido implementar (coluna nova)? | pendente | — |
| L9 | Só no Figma: o medidor "Senha forte" no modal. O EA-003-01 trouxe o medidor só para o cadastro. Faz sentido aqui também (só visual)? | pendente | — |
| L10 | A nova senha pode ser igual à atual? | pendente | — |
| L11 | O ator é Cliente: `SELLER` e `ADMIN` também usam esta página? (proposta: `CUSTOMER` e `SELLER`) | pendente | — |
