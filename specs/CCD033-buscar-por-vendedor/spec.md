# CCD033 — Buscar por Vendedor

- **Status:** Rascunho
- **Fase:** Futuro Marketplace
- **User story:** #166 `CCD033 - Ordenar Coleção` ⚠️ o título do board não é o deste caso de uso (L1)
- **Caso de uso:** [33-buscar-por-vendedor.md](../../docs/Casos-De-Uso/33-buscar-por-vendedor.md) · duplicado em [67-buscar-por-vendedor.md](../../docs/Casos-De-Uso/67-buscar-por-vendedor.md) (L2)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela de pesquisa do marketplace
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso buscar cartas por vendedor para visualizar os anúncios disponibilizados por um usuário específico.

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

> **Fase Futuro Marketplace** (`***` no caso de uso e na user story). A busca por vendedor não está na fatia mínima do
> marketplace que entrou no MVP em 18/11/2026 (ADR-027).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | A busca por vendedor exige login: sem token, a API responde `401` | Permissão | `33`, Pré-condições (L2) |
| R2 | Na tela de pesquisa do marketplace, o cliente informa o nome ou o nome de usuário do vendedor no campo de busca | Campo | `33`, FP 1 (L4, L5) |
| R3 | O sistema pesquisa os anúncios cadastrados pelo vendedor informado | Regra | `33`, FP 2 (L2) |
| R4 | O sistema exibe a lista de anúncios encontrados | Tela | `33`, FP 3 |
| R5 | Selecionar um anúncio da lista abre o detalhe do anúncio | Ação | `33`, FP 4 |
| R6 | Se nenhum vendedor corresponde ao termo, a tela mostra "Nenhum resultado encontrado" | Mensagem | `33`, FA 1 (L2) |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. A busca por vendedor não tem frame (L3): o requisito vale quando o frame existir | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** o vendedor "tiago_trocas" com um anúncio ativo, **quando** o cliente logado busca "tiago_trocas"
  pelo vendedor, **então** a lista mostra o anúncio dele.
- **CA2** (R5) — **Dado** a lista de anúncios do vendedor, **quando** o cliente seleciona um anúncio, **então** abre o detalhe
  dele.
- **CA3** (R6) — **Dado** nenhum vendedor com o termo, **quando** o cliente busca, **então** a tela mostra "Nenhum resultado
  encontrado".
- **CA4** (R1) — **Dado** uma requisição sem token, **quando** chama a busca por vendedor, **então** a API responde `401`.
- **CA5** (R7 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print
  dela é comparado lado a lado com o print do frame da busca por vendedor (a desenhar, L3), **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA6** (R7 de Fidelidade) — Idem ao CA5, com o campo de busca do Explorar e o frame `1112-3281`, se a L3 decidir pôr a
  busca por vendedor nele.
- **CA7** (R7 de Fidelidade) — Idem ao CA5, com o grupo "Usuários" da busca global e o frame `1112-3970`, se a L3 decidir
  pelo caminho da busca global.
- **CA8** (R7 de Fidelidade) — Idem ao CA5, com os anúncios ativos do vendedor no perfil público e o frame `1160-1396`, se a
  L3 decidir pelo caminho do perfil público.

- **CA9** (R7) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-3281`, `1112-3970`, `1160-1396`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `username`, `role` (`user_role.SELLER`), `status`, `deleted_at` | `username` único; `name` obrigatório (L5) |
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `status` (`listing_status`), `deleted_at` | "cadastrados" ou "ativos" (L2) |
| `cards` | `name`, `front_image_url`, `album_id` | cartão do anúncio |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Explorar marketplace (campo "Buscar por carta ou coleção") | [1112-3281](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3281) | R2 | ❌ Não bate: o campo não busca por vendedor (L3) |
| Público - Busca (grupo "Usuários", "Ver perfil") | [1112-3970](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3970) | R2 | ⚠️ Caminho alternativo, da CCD002 (L3) |
| Público - Perfil público do usuário ("Anúncios ativos de <usuário> (<n>)") | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R4, R5 | ⚠️ Caminho alternativo, da CCD080 (L3) |

- **Não há frame de busca por vendedor** (L3). O Figma chega aos anúncios de um vendedor pela busca global (grupo "Usuários"
  → "Ver perfil") e pelo perfil público, com "Anúncios ativos de tiago_trocas (1)".
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 a opção de buscar por vendedor; R6 a mensagem
  "Nenhum resultado encontrado".

## Fora do escopo

- Busca global de usuários — CCD002; perfil público do vendedor — CCD080 (EA-080-01).
- Detalhe do anúncio — CCD079, CCD080 e CCD072.
- Explorar marketplace com filtros e ordenação — CCD078 e CCD068.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | No board, a user story #166 se chama "CCD033 - Ordenar Coleção", e o arquivo 33 é "Buscar por Vendedor" (divergência conhecida entre o board e a planilha `CromoCard 1.xlsx`). Qual vale? (proposta: o arquivo; corrigir o título no board) | pendente | — |
| L2 | **Duplicidade:** "Buscar por Vendedor" está no `33` e no `67` (CCD067), com diferenças: o `33` exige login e o `67` só pede estar na listagem do marketplace; o `33` traz os anúncios "cadastrados" e o `67`, os "ativos"; o `33` mostra "Nenhum resultado encontrado" e o `67`, “Nenhum vendedor encontrado.” e “Este vendedor não possui anúncios ativos.”; o `67` lista os vendedores antes dos anúncios. Qual caso de uso fica? (proposta: manter o `67`, que é mais completo, e cancelar o `33`) | pendente | — |
| L3 | O Figma não tem busca por vendedor no Explorar ("Buscar por carta ou coleção"). O caminho é a busca global → "Ver perfil" → anúncios ativos no perfil público (`1112-3970`, `1160-1396`), ou uma opção nova no Explorar (falta o desenho)? (proposta: o caminho que o Figma já tem, sem tela nova) | pendente | — |
| L4 | "Tela de pesquisa do marketplace" é o Explorar marketplace (`1112-3281`) ou a página Pesquisar (`1112-3970`)? | pendente | — |
| L5 | Buscar pelo nome completo (`users.name`) expõe um dado que o perfil público não mostra ("Nome completo, e-mail, CPF e endereço nunca aparecem", EA-080-01). A busca usa só o nome de usuário? (proposta: só `username`) | pendente | — |
