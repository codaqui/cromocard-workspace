# CCD103 — Votar em Solicitação de Catálogo

- **Status:** Em implementação
- **Fase:** Escopo Adicional
- **User story:** #607 `CCD103-Votar em Solicitação de Catálogo` · responsável Daniel Andrade (tela de Solicitações; no Azure ainda consta Gabriel Nascimento) · Sprint 06
- **Caso de uso:** [103-votar-em-solicitacao-de-catalogo.md](../../docs/Casos-De-Uso/103-votar-em-solicitacao-de-catalogo.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Cliente, Administrador · **Pré-condições:** `CUSTOMER` ou `SELLER` autenticado para votar; `ADMIN` para ver o quórum
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; revista e reaprovada em 2026-11-17 (L7–L10)

## Objetivo

> Como Cliente preciso votar a favor, neutro ou contra uma sugestão de nova categoria para ajudar o administrador a decidir o que entra no catálogo.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Votar exige login como `CUSTOMER` ou `SELLER`, inclusive quem sugeriu; `ADMIN` não vota (`403`). Ver o quórum exige `ADMIN` | Permissão | `103`, Atores e Pré-condições (L8); ADR-005, item 4 |
| R2 | Página "Sugestões da comunidade" (`/sugestoes`, item "Sugestões" no menu do site) com as sugestões de categoria pendentes: protocolo, quem sugeriu, descrição, contagem a favor, neutros e contra, e o voto do cliente; sem nenhuma, "Nenhuma sugestão em votação" | Tela | `103`, FP 1–2 (L7) |
| R3 | Voto a favor, neutro ou contra, um por cliente em cada sugestão | Ação | `103`, FP 3–4; DBML `catalog_request_votes` |
| R4 | A contagem é atualizada depois do voto | Regra | `103`, FP 5 |
| R5 | O admin vê o quórum: total, percentual a favor (selo "340 votos • 97,4% a favor"), meta, percentual da meta e a divisão entre a favor, neutros e contra | Tela | `103`, FP 6–7 |
| R6 | Aprovar ou recusar encerra a votação | Regra | `103`, FP 8–9 |
| R7 | Votar de novo troca o voto anterior | Regra | `103`, FA 1–2 |
| R8 | Sugestão encerrada não aceita voto: a tela avisa "Votação encerrada" | Regra | `103`, FA 3–4 |
| R9 | A meta de votos vem de `global_settings` (`catalog.voting_goal`) | Regra | ADR-053, item 7 |
| R10 | Na sugestão de carta: ilustrador, população estimada, justificativa e fontes (frente e verso, álbum, raridade, franquia e idioma passaram para a CCD064, L8, em 16/11/2026) | Tela | EA-064-02; DBML `catalog_requests.data` |
| R11 | Na sugestão de álbum: resumo com o total e as três raridades mais altas do seed presentes, e checklist (Nº, código, nome, raridade, variantes) com "Baixar Planilha .CSV" (editora e ano já vêm da CCD064) | Ação | EA-064-03 (L10) |
| R12 | Na sugestão de categoria: as subcategorias a criar; aprovar cria todas | Ação | EA-064-04; DBML `categories.parent_category_id` |
| R13 | Capa sugerida do álbum (com "Volume Total: <n> Cartas no Checklist") e logo enviado da categoria, quando a sugestão trouxer a imagem | Tela | EA-064-03, EA-064-04 (L9) |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** uma sugestão de categoria pendente, **quando** o cliente vota a favor, **então** o voto é gravado e a contagem sobe.
- **CA2** (R7) — **Dado** um cliente que votou contra, **quando** ele vota a favor, **então** o voto é trocado e o total não muda.
- **CA3** (R8) — **Dado** uma sugestão aprovada, **quando** o cliente tenta votar, **então** a API responde `409 VOTING_CLOSED`.
- **CA4** (R5, R9) — **Dado** meta de 200 e 340 votos, **quando** o admin abre a sugestão, **então** vê 340/200 (170%) e a divisão dos votos.
- **CA5** (R12) — **Dado** uma sugestão de categoria com 3 subcategorias, **quando** o admin aprova, **então** a categoria e as 3 subcategorias são criadas.
- **CA6** (R11) — **Dado** uma sugestão de álbum com checklist, **quando** o admin baixa a planilha, **então** recebe um CSV com as cartas.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** tenta votar, **então** a API responde `401`.
- **CA8** (R1) — **Dado** um `ADMIN`, **quando** tenta votar, **então** a API responde `403`; um `SELLER` vota normalmente.
- **CA9** (R2) — **Dado** nenhuma sugestão de categoria pendente, **quando** o cliente abre `/sugestoes`, **então** vê "Nenhuma sugestão em votação".
- **CA10** (R8) — **Dado** a sugestão aprovada depois que o cliente abriu a página, **quando** ele vota, **então** vê o aviso "Votação encerrada" e a sugestão sai da lista.
- **CA11** (R13) — **Dado** uma sugestão de álbum com capa e uma de categoria com logo, **quando** o admin abre a fila, **então** vê a capa com o total do checklist e o logo; sem imagem, o bloco não aparece.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `catalog_request_votes` | todas | tabela nova (ADR-053) |
| `catalog_requests` | `type`, `data`, `status` | MVP |
| `categories` | `parent_category_id` | subcategorias |
| `global_settings` | `catalog.voting_goal` | chave nova, criada pelo seed |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Fila de solicitações de cartas | [228-1804](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=228-1804) | R5, R10–R13 | ✅ Bate (ajustado em 12/11/2026) |
| Sugestões da comunidade | [1038-1750](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1038-1750) | R1–R4, R7 | ✅ Desenhada em 17/11/2026 (L7) |
| Sugestões da comunidade — votação encerrada | [1038-2242](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1038-2242) | R8 | ✅ Desenhada em 17/11/2026 (L7) |
| Sugestões da comunidade — sem sugestões | [1038-2740](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1038-2740) | R2 | ✅ Desenhada em 17/11/2026 (L7) |

- A tela de votação do cliente foi desenhada em 17/11/2026 a partir do layout de "Painel principal de notificações" (`490-796`), com o item "Sugestões" no menu (L7).
- Na implementação, o aviso de votação encerrada (`1038-2242`) ganhou o "×" de fechar, igual ao componente de aviso do sistema; o frame foi ajustado no mesmo dia.
- Os cartões da fila mantêm os campos que a CCD064 já mostrava e o frame `228-1804` não desenha: "Número" na carta, "Franquia" no álbum e "Tipo" na categoria.
- "Arquivos criptográficos de autenticação", "API GraphQL e Banco Central", "Fórum de Curadoria" e as projeções da categoria
  saíram do Figma em 12/11/2026. O selo de votos mostra "340 votos • 97,4% a favor".

## Fora do escopo

- Votar em sugestões de carta e de álbum (L2).
- Criar a solicitação — CCD010 e CCD023.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Onde o cliente vota, se não há tela? (proposta: página "Sugestões da comunidade" em `/sugestoes` no Painel Cliente; o Gabriel desenha) | Página "Sugestões da comunidade" em `/sugestoes` no Painel Cliente; o Gabriel desenha | `103`, FP 1 |
| L2 | Só categorias ou também cartas e álbuns? (proposta: só categorias, como no Figma e no caso de uso) | Só categorias, como no Figma e no caso de uso | `103`, Finalidade |
| L3 | Meta padrão (proposta: 200, do Figma) | 200, do Figma | `103`, FP 7 |
| L4 | Campos extras das sugestões dependem de quem cria a solicitação (proposta: lidos de `data` quando existirem) | Lidos de `data` quando existirem | `escopo-adicional.md`, EA-064-02 |
| L5 | Raridades da sugestão e do checklist (o Figma usava "Secret Promo", "L", "SR", "SEC") | Os nomes do seed (Comum, Incomum, Rara, Épica, Lendária). Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `escopo-adicional.md`, EA-064-02 |
| L6 | A tela de votação do cliente (L1) continua sem desenho | Fica para a revisão do painel do cliente. Decisão do PO (Daniel, 12/11/2026) | `escopo-adicional.md`, seção 4 |
| L7 | Fazer agora a página do cliente, que não tinha desenho (L6)? | Sim, no estilo do painel do cliente, com o item "Sugestões" no menu; o PO autorizou desenhar no Figma (`1038-1750`, `1038-2242`, `1038-2740`). Substitui a L6. Decisão do PO (Daniel, 17/11/2026) | `103`, FP 1–2; `escopo-adicional.md`, linha da CCD103 e seção 4 |
| L8 | Quem vota? | `CUSTOMER` e `SELLER`, inclusive quem sugeriu; `ADMIN` não vota, porque é quem decide. Decisão do PO (Daniel, 17/11/2026) | `103`, Pré-condições |
| L9 | Capa sugerida e logo enviado (só no Figma, `228-1804`) | Implementar, lidos de `data` quando existirem. Decisão do PO (Daniel, 17/11/2026) | `escopo-adicional.md`, EA-064-03 e EA-064-04 |
| L10 | Quais raridades no resumo do álbum (o Figma mostra Total, Lendárias, Épicas, Raras)? | O total e as três raridades mais altas do seed presentes no checklist. Decisão do PO (Daniel, 17/11/2026) | `escopo-adicional.md`, EA-064-03 |
