# CCD107 — Consultar Histórico de Relatórios

- **Status:** Implementada
- **Fase:** Escopo Adicional
- **User story:** #611 `CCD107-Consultar Histórico de Relatórios` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [107-consultar-historico-de-relatorios.md](../../docs/Casos-De-Uso/107-consultar-historico-de-relatorios.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; as decisões L5–L9 (o caso de uso 107 mudou: FP 2, FP 5 e FP 6) foram validadas em 2026-11-22 por Felipe Consulim (PO); as decisões L10 e L11 (revisão do PR #28) são do PO, em 2026-11-22

## Objetivo

> Como Administrador eu quero ver os relatórios exportados recentemente e baixar de novo um arquivo já gerado para não precisar exportar outra vez.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `107`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Histórico com código, tipo e período do relatório, solicitante, data e hora, formato e tamanho, e a coluna "Disponível até" (ou "Expirado") | Tela | `107`, FP 2 e FP 5 (L4) |
| R3 | "Baixar" entrega o mesmo arquivo gerado na exportação | Ação | `107`, FP 3–4 |
| R4 | Cada arquivo fica disponível por 90 dias | Regra | `107`, FP 5; ADR-053, item 9 |
| R5 | Arquivo vencido: informa e oferece gerar de novo com os mesmos filtros | Regra | `107`, FA 1–2 |
| R6 | Histórico vazio mostra a mensagem | Estado | `107`, FA 3–4 |
| R7 | Um job apaga do storage os arquivos vencidos; a linha continua no histórico como "Expirado" (L5) | Regra | `107`, FP 5 (L5); ADR-053, item 9; ADR-010; ADR-068 |
| R8 | A confirmação da exportação avisa que "o arquivo fica no histórico por 90 dias" e o aviso de exportado diz que ele "está no topo do histórico" (L7) | Tela | `107`, FP 6 (L7); Figma `843-442` e `843-1246` |
| R9 | O cabeçalho do histórico tem o botão "Atualizar histórico", que busca a lista de novo (L10) | Ação | `107`, FP 7–8 (L10); Figma `228-1236` e `843-2068` |

## Critérios de aceite

- **CA1** (R2) — **Dado** três exportações feitas por admins diferentes, **quando** o admin abre Relatórios, **então** vê as três com código, tipo, período, solicitante, data, formato e tamanho.
- **CA2** (R3) — **Dado** uma exportação de ontem, **quando** o admin clica em "Baixar", **então** recebe o mesmo arquivo.
- **CA3** (R5) — **Dado** uma exportação com mais de 90 dias, **quando** o admin clica em "Baixar", **então** a API responde `410` e a tela oferece gerar de novo.
- **CA4** (R7) — **Dado** arquivos vencidos, **quando** o job roda, **então** os arquivos somem do storage e as linhas continuam no histórico, marcadas como "Expirado" (sem `deleted_at`).
- **CA5** (R6) — **Dado** nenhuma exportação, **quando** o admin abre Relatórios, **então** vê a mensagem de histórico vazio.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.
- **CA7** (R8) — **Dado** o admin na tela de exportação, **quando** confirma e a exportação termina, **então** a confirmação fala dos 90 dias no histórico e o aviso diz que o arquivo está no topo do histórico, que já mostra a nova linha.
- **CA8** (R9) — **Dado** o histórico aberto e uma exportação nova feita por outro admin, **quando** o admin clica em "Atualizar histórico", **então** a lista é buscada de novo e mostra a exportação nova.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `report_exports` | todas | tabela nova (ADR-053) |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Relatórios — histórico | `228-1236` | R2, R3 | ✅ Bate |
| Arquivo expirado | `843-844` | R5 | ⚠️ Difere só no "×" de fechar (L11) |
| Histórico vazio | `843-2068` | R6, R9 | ✅ Bate |

- "Assinado HSM" e "Digest SHA-256" saíram do Figma em 12/11/2026.
- Reconferidas em 18/11/2026: o diálogo de `843-844` diz que o arquivo "passou dos 90 dias e foi apagado" e oferece "Fechar" e "Gerar de novo" (L5); o vazio de `843-2068` diz "Ainda não há relatórios exportados. Os relatórios que a equipe exportar aparecem aqui por 90 dias."; o código do Figma é numérico (L6).
- Revisão do PR #28 (22/11/2026): a tabela passou a seguir o Figma (ícone de histórico, código e data em fonte mono, chip de formato por cor, ponto na coluna "Disponível até", "Baixar" com fundo, cabeçalho escuro) e ganhou o botão de atualizar do cabeçalho (R9, L10). O "×" do diálogo de expirado não existe no Figma, mas fica (L11).
- Confirmação (`843-442`) e aviso de exportado (`843-1246`): as frases do histórico voltam com esta story (R8, L7).

## Fora do escopo

- Gerar e exportar relatórios — CCD063.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Histórico só do próprio admin ou de todos? (proposta: de todos, como o "pela equipe diretiva" do Figma) | De todos, como o "pela equipe diretiva" do Figma | `107`, FP 2 |
| L2 | Substitui o histórico lido de `audit_logs` na CCD063? (proposta: sim; a CCD063 continua gravando `EXPORT_REPORT`) | Sim; a CCD063 continua gravando `EXPORT_REPORT` | plano.md; ADR-053, item 9 |
| L3 | Como o arquivo é servido? (proposta: rota autenticada `GET /admin/reports/exports/:id/file`, sem URL pública) | Rota autenticada `GET /admin/reports/exports/:id/file`, sem URL pública | plano.md |
| L4 | O que a coluna de status do histórico mostra? (o Figma tinha "Assinado HSM") | "Disponível até DD/MM/AAAA" ou "Expirado", a partir de `expires_at`. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | esta spec (R2) |
| L5 | A CA4 mandava preencher `deleted_at` nas linhas vencidas, o que as tiraria do histórico; o Figma (`228-1236`, `843-844`) mostra a linha "Expirado" e o diálogo "Gerar de novo" | O job apaga só o arquivo do storage; a linha fica, sem `deleted_at`, e o download responde `410 EXPORT_EXPIRED`. Decisão de Lucca Rocha (18/11/2026), na conferência da spec com o Figma; validada pelo PO (Felipe Consulim, 22/11/2026) | esta spec (R7, CA4) |
| L6 | Como montar o código `#REP-9482` do Figma, se `report_exports` não tem coluna sequencial? | `#REP-` + os 4 últimos caracteres do `id`, em maiúsculas, como o `#SOL-` da CCD064; o DER não muda. Decisão de Lucca Rocha (18/11/2026); validada pelo PO (Felipe Consulim, 22/11/2026) | esta spec (R2) |
| L7 | As frases do histórico na confirmação (`843-442`) e no aviso de exportado (`843-1246`) ficaram de fora na CCD063 até existir o histórico | Voltam nesta story; o aviso provisório "O histórico de exportações chega em breve" dá lugar ao histórico e ao vazio de `843-2068`. Decisão de Lucca Rocha (18/11/2026); validada pelo PO (Felipe Consulim, 22/11/2026) | esta spec (R8, CA7) |
| L8 | Quantas linhas por página no histórico? (o Figma mostra 4, sem paginação visível) | 10 por página, paginação offset `page`/`pageSize` (ADR-011), com o paginador do BackOffice. Validada pelo PO (Felipe Consulim, 22/11/2026) | plano.md |
| L9 | Se guardar o arquivo no histórico falhar (storage ou banco), a exportação também falha? (revisão do Lucas no backend#36) | Não: o admin recebe o arquivo como antes (CCD063), o erro vai para o log e o arquivo que ficou sem linha é apagado do storage. A exportação não aparece no histórico nesse caso. Proposta de Lucca Rocha (22/11/2026); validada pelo PO (Felipe Consulim, 22/11/2026) | esta spec; plano.md |
| L10 | O Figma (`228-1236`, `843-2068`) mostra um botão de atualizar ao lado de "Arquivos disponíveis por 90 dias", e a spec não tinha esse botão. Implementar? | Sim: o botão "Atualizar histórico" refaz a busca da lista (R9, CA8). Decisão do PO (Felipe Consulim, 22/11/2026), na revisão do PR #28 | esta spec (R9, CA8); caso de uso 107 (FP 7–8) |
| L11 | O diálogo de arquivo expirado (`843-844`) não tem o "×" de fechar, e o `ConfirmDialog` compartilhado o tem. Tirar? | Não: o "×" fica, para não mexer num componente usado em outras telas; é a única diferença da tela para o frame, e o Gabriel é avisado. Decisão do PO (Felipe Consulim, 22/11/2026), na revisão do PR #28 | esta spec (Telas) |
