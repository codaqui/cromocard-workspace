# CCD094 — Validar Cadastro de Vendedor

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #598 `CCD094-Validar Cadastro de Vendedor` · responsável Daniel Andrade · Sprint 06
- **Caso de uso:** [94-validar-cadastro-de-vendedor.md](../../docs/Casos-De-Uso/94-validar-cadastro-de-vendedor.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero analisar os dados e os documentos de um vendedor e aprovar ou reprovar o credenciamento dele para que só lojistas verificados vendam na plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `94`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Lista "Cadastros dos Vendedores Recentes" no Dashboard com nome, e-mail, CNPJ ou CPF, status da análise (Em análise, Pendente, Aprovado, Reprovado) e total de pendentes; ações por linha só "Ver informações" e, em análise, "Validar Cadastro" | Tela | `94`, FP 1–2, FP 5 e FA 4; EA-058-05; `escopo-adicional.md` §3 |
| R3 | Filtro por status e botão "Atualizar Fila" | Campo | `94`, FP 3–4; EA-058-05 |
| R4 | Card "Lojistas & Credenciamento" com aprovados, pendentes e conversão (aprovados ÷ analisados) e o atalho "Analisar Fila" | Campo | EA-058-06; EA-058-07 |
| R5 | Dossiê com dados da empresa, responsável legal, dados bancários e Pix, endereço comercial e documentos | Tela | `94`, FP 5–6; DBML `seller_verifications`, `seller_documents` |
| R6 | Visualizar e validar cada documento (`VALIDATED`, com quem e quando) | Ação | `94`, FP 7–8; DBML `seller_documents` |
| R7 | Anotações internas com autor e data, nunca mostradas ao vendedor | Ação | `94`, FP 9–10; DBML `seller_verification_notes` |
| R8 | "Validar Lojista" muda o status para `APPROVED` e grava `reviewed_by_id` e `reviewed_at` | Ação | `94`, FP 11–12 |
| R9 | "Rejeitar" com motivo obrigatório: `REJECTED`, `rejection_reason` e aviso ao vendedor por notificação | Ação | `94`, FA 1–4 |
| R10 | Fechar o dossiê sem decidir mantém o status | Ação | `94`, FA 7–8 |
| R11 | Validar documento, aprovar e rejeitar gravam `audit_logs` com o motivo | Regra | `94`, FP 13 e FA 4; ADR-034; ADR-051, item 5 |
| R12 | Na Gestão de Usuários, o vendedor com análise aberta mostra o selo "Em análise" ao lado do papel, sem mudar o status da conta | Campo | `59`, FP 2; EA-059-04 (L6) |
| R13 | Relatório "Auditoria de Lojistas" (cadastros por status no período) em Exportar Relatórios | Ação | EA-063-02 |
| R14 | Só se decide cadastro `UNDER_REVIEW` ou `PENDING`; outro status responde `409` | Regra | `94`, Pré-condições |
| R15 | CPF e CNPJ não aparecem nos logs da aplicação | Regra | ADR-019; ADR-052, Consequências |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** cadastros em análise, pendentes e aprovados, **quando** o admin filtra por "Em análise", **então** a lista mostra só esses, com CNPJ e status, e o total de pendentes.
- **CA2** (R5) — **Dado** um cadastro em análise, **quando** o admin abre "Validar Cadastro", **então** vê empresa, responsável, dados bancários, endereço e documentos.
- **CA3** (R6, R11) — **Dado** um documento enviado, **quando** o admin marca como validado, **então** o documento fica `VALIDATED` com quem e quando, e o log registra.
- **CA4** (R8, R11) — **Dado** um cadastro em análise, **quando** o admin clica em "Validar Lojista", **então** o status vira `APPROVED` e o log registra.
- **CA5** (R9, R11) — **Dado** um cadastro em análise, **quando** o admin rejeita informando o motivo, **então** o status vira `REJECTED`, o vendedor recebe a notificação e o log registra o motivo.
- **CA6** (R9) — **Dado** o diálogo de rejeição, **quando** o admin confirma sem motivo, **então** a API responde `400` e nada muda.
- **CA7** (R14) — **Dado** um cadastro já aprovado, **quando** o admin tenta rejeitar, **então** a API responde `409`.
- **CA8** (R4) — **Dado** 3 aprovados e 1 reprovado, **quando** o admin abre o Dashboard, **então** o card mostra 3 aprovados e conversão de 75%.
- **CA9** (R13) — **Dado** cadastros no período, **quando** o admin exporta "Auditoria de Lojistas" em CSV, **então** o arquivo lista os cadastros com o status.
- **CA10** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.
- **CA11** (R12) — **Dado** um vendedor ativo com cadastro em análise, **quando** o admin abre a Gestão de Usuários, **então** a linha mostra o papel Vendedor com o selo "Em análise" e o status Ativo.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `seller_verifications` | todas | tabela nova (ADR-052) |
| `seller_documents` | todas | tabela nova (ADR-052) |
| `seller_verification_notes` | todas | tabela nova (ADR-052) |
| `addresses` | endereço comercial | já existe no DER |
| `notifications` | `type = SELLER_REVIEW` | aviso da rejeição (ADR-051, item 2) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Dashboard, lista de vendedores (30 dias, 7D, Hoje) | `208-1240`, `247-2499`, `247-3539` | R2–R4 | ✅ Bate (ajustado em 11/11/2026) |
| Dashboard, filtro de status aberto | `795-3961` | R3 | ✅ Bate |
| Gestão de Usuários, selo "Em análise" | `208-1793` | R12 | ✅ Bate (ajustado em 11/11/2026) |
| Validar Cadastro (painel) | `246-1201` | R5–R10 | ⚠️ Divergente (ainda não revisado no Figma) |
| Dossiê do vendedor (Em análise e Aprovado) | `252-1723`, `252-2837` | R5–R8 | ⚠️ Divergente (ainda não revisado no Figma) |

Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

- O painel mostra "Anunciada", "Score de Reputação" e "Chargebacks", que dependem do marketplace (CCD097).
- As abas "Segurança" e "Auditoria" e o botão "Consultar" (Receita Federal) não têm conteúdo desenhado nem documentação.

## Fora do escopo

- O envio dos dados e documentos pelo vendedor: não há caso de uso nem tela (L1).
- Consulta automática do CNPJ na Receita Federal e as abas "Segurança" e "Auditoria".
- Reputação, volume anunciado e chargebacks — CCD097.
- Notificar pendência — CCD095 (pelo dossiê, não pela linha da lista).
- Botões "Logs" e "Notificar Lojista" e status com motivo ("Pendente Doc Pix") na lista do Dashboard: retirados do Figma em 11/11/2026.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quem cria `seller_verifications`, se não há caso de uso do vendedor? (proposta: o seed cria cadastros de teste; o caso de uso do vendedor fica para outra story) | O seed cria cadastros de teste; o caso de uso do vendedor fica para outra story | esta spec (Fora do escopo); ADR-052, Consequências |
| L2 | A "Taxa de Autenticação" do Figma (EA-058-07) não tem origem de dado (proposta: não entra) | Não entra | esta spec (Fora do escopo); `escopo-adicional.md`, EA-058-07 |
| L3 | Vendedor não aprovado pode anunciar? (proposta: sem efeito até o marketplace existir) | Sem efeito até o marketplace existir | `94`, FP 12 |
| L4 | Tipos de documento (proposta: `CNPJ_CARD` e `ADDRESS_PROOF`, como no Figma) | `CNPJ_CARD` e `ADDRESS_PROOF`, como no Figma | `94`, FP 6 |
| L5 | "Analisar Fila" (proposta: abre a lista filtrada em pendentes) | Abre a lista filtrada em pendentes | `94`, FP 3 |
| L6 | Onde aparece o "Em análise" na Gestão de Usuários (EA-059-04)? | Como selo ao lado do papel Vendedor; a coluna Status continua só com Ativo, Suspenso e Bloqueado. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `59`, FP 2; EA-059-04 |
