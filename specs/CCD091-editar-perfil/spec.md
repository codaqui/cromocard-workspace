# CCD091 — Editar Perfil

- **Status:** Rascunho
- **Fase:** MVP (sem marca nas user stories do Painel Vendedor)
- **User story:** #350 `CCD091-Editar Perfil`
- **Caso de uso:** [91-editar-perfil.md](../../docs/Casos-De-Uso/91-editar-perfil.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER` e na tela "Meu Perfil"
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso editar meu perfil para manter minhas informações atualizadas.

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
| R1 | Só `SELLER` edita o perfil de vendedor, e só o próprio: `401` sem token, `403` para outro papel | Permissão | `91`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Editar Perfil" habilita os campos de dados pessoais, foto e meios de recebimento | Tela | `91`, FP 1–2 |
| R3 | "Salvar" valida os dados e atualiza o cadastro | Ação | `91`, FP 3–4; DBML `users`, `profiles` |
| R4 | E-mail ou documento que já pertence a outra conta não é salvo e mostra "Esta informação já está em uso por outro usuário" (`409`) | Mensagem | `91`, FA 1–2; DBML `users.email` e `users.cpf` (únicos) |
| R5 | A foto aceita PNG, JPG ou WEBP de até 4 MB e é gravada pelo `StorageProvider`; o banco guarda a URL | Regra | `91`, FP 2; ADR-050, item 1; DBML `profiles.avatar_url` |
| R6 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frame `675-4627`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um vendedor no perfil, **quando** seleciona "Editar Perfil", altera os dados permitidos (L1) e seleciona "Salvar", **então** a API grava as alterações e a tela mostra os dados novos com a confirmação (L6).
- **CA2** (R4) — **Dado** outro usuário com o e-mail `ana@email.com`, **quando** o vendedor tenta salvar esse e-mail (ou um CPF já usado), **então** vê "Esta informação já está em uso por outro usuário", nada é gravado e a API responde `409`.
- **CA3** (R5) — **Dado** o modal de edição, **quando** o vendedor envia uma imagem PNG de 1 MB, **então** ela é gravada e aparece no perfil; **quando** envia um PDF ou uma imagem maior que 4 MB, **então** o arquivo é recusado com erro e nada é gravado.
- **CA4** (R3) — **Dado** um campo inválido (L7), **quando** o vendedor salva, **então** o campo mostra o erro, nada é gravado e a API responde `400`.
- **CA5** (R2) — **Dado** o modal com alterações, **quando** o vendedor seleciona "Cancelar", **então** o modal fecha e os dados continuam os anteriores.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a edição, **então** recebe `401`; **dado** um `CUSTOMER` ou `ADMIN`, recebe `403`.
- **CA7** (R3) — **Dado** o salvamento em andamento, **quando** o vendedor seleciona "Salvar Perfil", **então** o botão fica em carregamento; se a API falhar, os campos continuam preenchidos e o erro aparece.
- **CA8** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `675-4627` (Editar perfil do vendedor), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `email`, `cpf`, `phone`, `username`, `role` | `email` obrigatório e único; `cpf` e `username` únicos; `phone` varchar(20) |
| `profiles` | `user_id`, `bio`, `avatar_url` | 1:1 com `users` |
| `seller_verifications` | `trade_name`, `cnpj` | nome fantasia e CNPJ (único) do vendedor (ADR-052); só se a L2 decidir usar |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor - editar perfil | [675-4627](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-4627) | R2, R3, R5 | ❌ Não bate (L1–L5) |

- O modal abre sobre a Visão geral: "Editar Perfil do Vendedor", "Atualize as informações da sua loja pública e os dados de
  recebimento.", "Nome da loja" com "Endereço da loja: cromocard.com.br/u/rodrigo_slabs", "Logo e Banner da Loja" com "Logo
  (1:1)" ("Arraste ou clique para enviar") e "Banner (16:9)" ("Arraste ou selecione arquivo", "Recomendado 1600×900"),
  "Especialidades da loja" (Pokémon TCG, Futebol, Graduadas, Anime, Vintage), "WhatsApp de contato", "Bio da loja", "Dados
  de recebimento criptografados", "Cancelar" e "Salvar Perfil".
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o Figma edita a loja (nome, logo, banner, especialidades,
  WhatsApp, bio); o caso de uso pede dados pessoais, foto e meios de recebimento (L1). O FA cita e-mail e documento, que o
  modal não tem (L1). Os meios de recebimento agora são a conta Stripe da CCD108 (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Nome da loja", "Banner (16:9)",
  "Especialidades da loja", "WhatsApp de contato" e "Graduadas" (L2, L4); "Dados de recebimento criptografados" (L3).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 o botão "Editar Perfil" (L5); R4 o erro de
  informação em uso; a confirmação de salvo (L6).

## Fora do escopo

- Dados pessoais, foto, e-mail e endereços do usuário na tela "Perfil" (`1160-37708`) — CCD048, se a L1 decidir assim.
- Conectar ou trocar a conta de recebimento — CCD108.
- Visão geral ao fundo do modal — CCD092 e CCD093; "Ver Loja Pública" — CCD080.
- Saque via Pix, chave Pix e dados bancários — fora do MVP (ADR-027; `escopo-adicional.md`, 20/11/2026).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma edita a loja pública; o caso de uso edita dados pessoais, foto e meios de recebimento, com erro de e-mail ou documento em uso — e isso já é a CCD048 na tela "Perfil" (`1160-37708`). Qual vale? (proposta: a CCD091 edita o perfil da loja, como no Figma; dados pessoais, e-mail e CPF ficam na CCD048; ajustar o FP 2 e o FA do `91`) | pendente | — |
| L2 | O DBML não tem nome da loja, banner nem especialidades. Faz sentido implementar? Se sim, onde gravar? (proposta: nome da loja em `seller_verifications.trade_name`, logo em `profiles.avatar_url`, bio em `profiles.bio`; banner e especialidades saem do frame ou viram colunas novas com ADR) | pendente | — |
| L3 | "Meios de recebimento" e "Dados de recebimento criptografados": o repasse agora vai para a conta Stripe (CCD108, ADR-066) e o vendedor não digita dados bancários. O que fica? (proposta: tirar os meios de recebimento do FP 2 e o selo do frame; o modal pode ter um link para a conta Stripe) | pendente | — |
| L4 | "WhatsApp de contato" e a especialidade "Graduadas" saíram das outras telas em 20/11/2026 (fora do escopo). Faz sentido implementar aqui? (proposta: não; o Gabriel tira do frame) | pendente | — |
| L5 | De onde abre o modal? O caso de uso fala em "Meu Perfil" e "Editar Perfil", mas a Visão geral (`492-2007`) não tem esse botão (proposta: botão "Editar perfil da loja" na Visão geral, perto de "Ver Loja Pública"; o Gabriel desenha) | pendente | — |
| L6 | Texto da confirmação de salvo, que não tem frame (proposta: "Perfil da loja atualizado") | pendente | — |
| L7 | Regras dos campos (tamanho do nome da loja e da bio, formato do telefone)? (proposta: nome da loja até 160, igual a `trade_name`; bio até 300, igual ao Perfil do cliente) | pendente | — |
| L8 | "Endereço da loja: cromocard.com.br/u/<usuário>" usa o nome de usuário (`users.username`). Ele é editável aqui? (proposta: não; só aparece, e muda na CCD048) | pendente | — |
