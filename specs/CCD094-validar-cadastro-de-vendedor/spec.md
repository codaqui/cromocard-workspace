# CCD094 — Validar Cadastro de Vendedor

- **Status:** Em implementação
- **Fase:** Escopo Adicional
- **User story:** #598 `CCD094-Validar Cadastro de Vendedor` · responsável Daniel Andrade · Sprint 06
- **Caso de uso:** [94-validar-cadastro-de-vendedor.md](../../docs/Casos-De-Uso/94-validar-cadastro-de-vendedor.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; revista em 2026-11-13 (L7, Felipe Consulim), em 2026-11-16 (L8, Felipe Consulim) em 2026-11-17 (L9 e L10, Felipe Consulim) e em 2026-11-18 (L11 a L13, Felipe Consulim, na revisão do Daniel nos PRs backend#26 e frontend#19)

## Objetivo

> Como Administrador eu quero analisar os dados e os documentos de um vendedor e aprovar ou reprovar o credenciamento dele para que só lojistas verificados vendam na plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `94`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Lista "Cadastros dos Vendedores Recentes" no Dashboard com nome, e-mail, CNPJ ou CPF, status da análise (Em análise, Pendente, Aprovado, Reprovado) e total de pendentes; ações por linha só "Ver informações" e, em análise, "Validar Cadastro" | Tela | `94`, FP 1–2, FP 5 e FA 4; EA-058-05; `escopo-adicional.md` §3 |
| R3 | Filtro por status e botão "Atualizar Fila" | Campo | `94`, FP 3–4; EA-058-05 |
| R4 | Card "Lojistas & Credenciamento" com aprovados, pendentes e conversão (aprovados ÷ analisados, contando os cadastros decididos no período pela data da decisão — L8) e o atalho "Analisar Fila" | Campo | EA-058-06; EA-058-07; L8; L12 |
| R5 | Dossiê com dados da empresa, responsável legal, dados bancários e Pix, endereço comercial e documentos | Tela | `94`, FP 5–6; DBML `seller_verifications`, `seller_documents` |
| R6 | Visualizar e validar cada documento (`VALIDATED`, com quem e quando) | Ação | `94`, FP 7–8; DBML `seller_documents` |
| R7 | Anotações internas com autor e data, nunca mostradas ao vendedor | Ação | `94`, FP 9–10; DBML `seller_verification_notes` |
| R8 | "Validar Lojista" muda o status para `APPROVED` e grava `reviewed_by_id` e `reviewed_at` | Ação | `94`, FP 11–12 |
| R9 | "Rejeitar" com motivo obrigatório: `REJECTED`, `rejection_reason` e aviso ao vendedor por notificação | Ação | `94`, FA 1–4 |
| R10 | Fechar o dossiê sem decidir mantém o status | Ação | `94`, FA 7–8 |
| R11 | Validar documento, aprovar e rejeitar gravam `audit_logs` com o motivo | Regra | `94`, FP 13 e FA 4; ADR-034; ADR-051, item 5 |
| R12 | Na Gestão de Usuários, o vendedor com análise aberta mostra o selo "Em análise" ao lado do papel, sem mudar o status da conta | Campo | `59`, FP 2; EA-059-04 (L6) |
| R13 | Relatório "Auditoria de Lojistas" em Exportar Relatórios (CCD063): os cadastros criados no período, sem os excluídos, com loja, CNPJ, e-mail do vendedor, status e data do cadastro, com prévia e exportação em CSV e PDF | Ação | EA-063-02 (L9, L10) |
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
- **CA8** (R4) — **Dado** 3 aprovados e 1 reprovado decididos no período, **quando** o admin abre o Dashboard, **então** o card mostra 3 aprovados e conversão de 75%.
- **CA9** (R13) — **Dado** cadastros criados no período, **quando** o admin exporta "Auditoria de Lojistas" em CSV, **então** o arquivo lista os cadastros com loja, CNPJ, e-mail, status (em português) e data do cadastro, sem os criados fora do período nem os excluídos.
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
| Dashboard, lista de vendedores (30 dias, 7D, Hoje) | `208-1240`, `247-2499`, `247-3539` | R2–R4 | ✅ Bate (ajustado em 11/11/2026; em 18/11/2026 o card "Lojistas & Credenciamento" passou a ser o 4º da linha de indicadores, L12) |
| Dashboard, filtro de status aberto | `795-3961` | R3 | ✅ Bate |
| Gestão de Usuários, selo "Em análise" | `208-1793` | R12 | ✅ Bate (ajustado em 11/11/2026) |
| Validar Cadastro (painel, gaveta sobre o Dashboard) | `246-1201` | R5–R10 | ✅ Bate (revisado em 13/11/2026, L7; em 18/11/2026 ganhou a largura do frame, as abas "Dados Cadastrais & Fiscais" e "Docs", os campos em caixas e os ícones das seções, L11 e L13) |
| Exportar Relatórios, card "Auditoria de Lojistas" | `228-1236` | R13 | ✅ Bate (revisado em 12/11/2026; conferido de novo em 17/11/2026 com o card habilitado, 5 colunas, L9) |

Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

- O painel mostra "Anunciada", "Score de Reputação" e "Chargebacks", que dependem do marketplace (CCD097).
- O painel tem as abas "Dados Cadastrais & Fiscais" (empresa, responsável, dados bancários e endereço) e "Docs" (documentos, com a contagem, e as anotações internas), como no frame (L11). As abas "Segurança" e "Auditoria" e o botão "Consultar" (Receita Federal) não têm conteúdo desenhado nem documentação.
- O selo "Validado" da seção de dados bancários e o "Split" do título não entram: a seção se chama "Dados Bancários & Pix" (L13).
- O mapa e "Raio de entrega Express" no endereço comercial não têm origem na documentação nem no DER (L7).

## Fora do escopo

- O envio dos dados e documentos pelo vendedor: não há caso de uso nem tela (L1).
- Consulta automática do CNPJ na Receita Federal e as abas "Segurança" e "Auditoria" (L11).
- Selo "Validado" nos dados bancários e o "Split Pix" (frame `246-1201`): sem origem no DER, que só valida documentos (L13).
- Reputação, volume anunciado e chargebacks — CCD097.
- Notificar pendência — CCD095 (pelo dossiê, não pela linha da lista).
- Botões "Logs" e "Notificar Lojista" e status com motivo ("Pendente Doc Pix") na lista do Dashboard: retirados do Figma em 11/11/2026.
- Frames `252-1723`/`252-2837` ("Dossiê do vendedor", página cheia via Gestão de Usuários): exploração anterior do mesmo R5, não usada — ver L7.
- Mapa e "Raio de entrega Express" no endereço comercial (frame `246-1201`): sem origem na documentação nem no DER.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quem cria `seller_verifications`, se não há caso de uso do vendedor? (proposta: o seed cria cadastros de teste; o caso de uso do vendedor fica para outra story) | O seed cria cadastros de teste; o caso de uso do vendedor fica para outra story | esta spec (Fora do escopo); ADR-052, Consequências |
| L2 | A "Taxa de Autenticação" do Figma (EA-058-07) não tem origem de dado (proposta: não entra) | Não entra | esta spec (Fora do escopo); `escopo-adicional.md`, EA-058-07 |
| L3 | Vendedor não aprovado pode anunciar? (proposta: sem efeito até o marketplace existir) | Sem efeito até o marketplace existir | `94`, FP 12 |
| L4 | Tipos de documento (proposta: `CNPJ_CARD` e `ADDRESS_PROOF`, como no Figma) | `CNPJ_CARD` e `ADDRESS_PROOF`, como no Figma | `94`, FP 6 |
| L5 | "Analisar Fila" (proposta: abre a lista filtrada em pendentes) | Abre a lista filtrada em pendentes | `94`, FP 3 |
| L6 | Onde aparece o "Em análise" na Gestão de Usuários (EA-059-04)? | Como selo ao lado do papel Vendedor; a coluna Status continua só com Ativo, Suspenso e Bloqueado. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `59`, FP 2; EA-059-04 |
| L7 | O Figma tem duas telas pro dossiê do vendedor (R5): a gaveta sobre o Dashboard (`246-1201`, já decidida no `plano.md`) e uma página cheia via Gestão de Usuários (`252-1723`/`252-2837`), incompatíveis entre si. Qual seguir? | A gaveta sobre o Dashboard (`246-1201`); os frames `252-1723`/`252-2837` ficam fora de uso, como exploração anterior do mesmo requisito. Decisão do PO (Felipe Consulim, 13/11/2026) | esta spec (Fora do escopo); `plano.md`, Decisões técnicas |
| L8 | A conversão conta os cadastros criados no período ou os decididos no período? (apontado na revisão do backend, PR #26: um cadastro de 40 dias aprovado ontem ficava fora de "Últimos 30 dias") | Os decididos: aprovados e reprovados entram pelo `reviewed_at` dentro do período; em análise e pendentes continuam pelo `created_at`. Decisão do PO (Felipe Consulim, 16/11/2026) | esta spec (R4, CA8); `plano.md`, contrato do `summary`; `escopo-adicional.md`, EA-058-07 |
| L9 | Quais as 5 colunas do relatório "Auditoria de Lojistas"? O card do Figma (`228-1236`) diz só "Cadastros de vendedores por status no período · 5 colunas", sem nomeá-las | Loja (razão social), CNPJ, e-mail do vendedor, status da análise (Em análise, Pendente, Aprovado, Reprovado) e data do cadastro. Decisão do PO (Felipe Consulim, 17/11/2026) | esta spec (R13, CA9); `plano.md`; `escopo-adicional.md`, EA-063-02 |
| L10 | O relatório filtra o período pela data do cadastro ou pela data da decisão (a L8 usa a decisão na conversão do card)? | Pela data do cadastro: lista os cadastros criados no período, com o status atual, inclusive os ainda em análise, como dizem o card do Figma e o CA9. Decisão do PO (Felipe Consulim, 17/11/2026) | esta spec (R13, CA9); `plano.md`; `escopo-adicional.md`, EA-063-02 |
| L11 | O painel `246-1201` tem a barra de abas "Dados Cadastrais & Fiscais", "Segurança", "Docs" e "Auditoria", que nenhuma documentação cita (apontado pelo Daniel na revisão do frontend#19). Seguir o Figma? | Segue o Figma nas abas que têm conteúdo: "Dados Cadastrais & Fiscais" (empresa, responsável, dados bancários e endereço) e "Docs N" (documentos e anotações internas). "Segurança" e "Auditoria" continuam fora, sem conteúdo desenhado. Decisão do PO (Felipe Consulim, 18/11/2026) | esta spec (Telas, Fora do escopo) |
| L12 | Onde fica o card "Lojistas & Credenciamento"? Os frames `247-2499` e `247-3539` o mostram como o 4º card da linha de indicadores, e o MVP da CCD058 pôs "Novos vendedores" nesse lugar (L10 da CCD058) | O card ocupa o 4º lugar da linha de indicadores, no estilo dos outros, com o selo "N Pendentes", os aprovados, "Conversão de X% (aprovados ÷ analisados)" e o rodapé "Fila pendente · Analisar Fila"; enquanto o resumo do credenciamento não carrega, o lugar mostra "Novos vendedores", cujo total também está no rodapé de "Total de usuários". Decisão do PO (Felipe Consulim, 18/11/2026), seguindo o Figma | esta spec (R4, Telas) |
| L13 | A seção "Dados Bancários & Split Pix" do `246-1201` mostra o selo "Validado", mas o DER não tem validação de dados bancários (só de documentos). Entra? | Não entra, como a "Taxa de Autenticação" (L2): sem origem de dado. A seção se chama "Dados Bancários & Pix"; o split de pagamento é do marketplace (CCD097). Decisão do PO (Felipe Consulim, 18/11/2026) | esta spec (Telas, Fora do escopo) |
