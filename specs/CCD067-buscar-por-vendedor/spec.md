# CCD067 — Buscar por Vendedor

- **Status:** Rascunho
- **Fase:** Futuro Marketplace (L3)
- **User story:** não encontrada no board
- **Caso de uso:** [67-buscar-por-vendedor.md](../../docs/Casos-De-Uso/67-buscar-por-vendedor.md) · duplicado em [33-buscar-por-vendedor.md](../../docs/Casos-De-Uso/33-buscar-por-vendedor.md) (L1)
- **Atores:** Cliente · **Pré-condições:** na listagem de cartas do marketplace
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso buscar cartas por vendedor para visualizar os anúncios disponibilizados por um usuário específico.

(`user-stories.md` tem uma linha só de "Buscar por Vendedor", marcada `***`; a finalidade do `67` diz "para localizar
anúncios de um vendedor específico na plataforma".)

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

> **Fase Futuro Marketplace** (L3): a busca por vendedor não está na fatia mínima do marketplace que entrou no MVP em
> 18/11/2026 (ADR-027).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | A busca por vendedor fica na seção de busca da listagem de cartas do marketplace | Tela | `67`, Pré-condições e FP 1 (L4) |
| R2 | O cliente seleciona a opção de busca por vendedor | Ação | `67`, FP 2 (L4) |
| R3 | O cliente informa o nome do vendedor, e o sistema busca os vendedores que correspondem ao nome | Ação | `67`, FP 3–4 (L5, L6) |
| R4 | O sistema localiza e exibe os anúncios ativos (`listings.status = ACTIVE`) do vendedor selecionado | Regra | `67`, FP 5–6 (L6) |
| R5 | Sem vendedor encontrado, a tela mostra “Nenhum vendedor encontrado.” | Mensagem | `67`, FA 1 |
| R6 | Vendedor sem anúncios ativos: a tela mostra “Este vendedor não possui anúncios ativos.” | Mensagem | `67`, FA 2 |
| R7 | Só usuários com papel `SELLER` contam como vendedores | Regra | `67`, FP 4; DBML `user_role` |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. A busca por vendedor não tem frame (L4): o requisito vale quando o frame existir | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1–R4) — **Dado** o vendedor "tiago_trocas" com um anúncio ativo e um pausado, **quando** o cliente escolhe a
  busca por vendedor, digita "tiago" e seleciona "tiago_trocas", **então** vê só o anúncio ativo.
- **CA2** (R5) — **Dado** nenhum vendedor com "zzz" no nome, **quando** o cliente busca "zzz", **então** a tela mostra “Nenhum
  vendedor encontrado.”
- **CA3** (R6) — **Dado** um vendedor só com anúncios pausados, **quando** o cliente o seleciona, **então** a tela mostra
  “Este vendedor não possui anúncios ativos.”
- **CA4** (R7) — **Dado** um `CUSTOMER` chamado "tiago", **quando** o cliente busca "tiago", **então** esse usuário não aparece
  entre os vendedores.
- **CA5** (R8 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print
  dela é comparado lado a lado com o print do frame da busca por vendedor (a desenhar, L4), **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA6** (R8 de Fidelidade) — Idem ao CA5, com a seção de busca do Explorar e o frame `1112-3281`, se a L4 decidir pôr a
  opção nele.
- **CA7** (R8 de Fidelidade) — Idem ao CA5, com o grupo "Usuários" da busca global e o frame `1112-3970`, se a L4 decidir
  pelo caminho da busca global.
- **CA8** (R8 de Fidelidade) — Idem ao CA5, com os anúncios ativos do vendedor e o frame `1160-1396`, se a L4 decidir pelo
  caminho do perfil público.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `username`, `role` (`user_role.SELLER`), `status`, `deleted_at` | `username` único (L5) |
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `status` (`listing_status.ACTIVE`), `deleted_at` | só ativos |
| `cards` | `name`, `front_image_url`, `album_id` | cartão do anúncio |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Explorar marketplace (seção de busca: "Buscar por carta ou coleção") | [1112-3281](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3281) | R1, R2 | ❌ Não bate: sem a opção de busca por vendedor (L4) |
| Público - Busca (grupo "Usuários") | [1112-3970](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3970) | R3 | ⚠️ Caminho alternativo, da CCD002 (L4) |
| Público - Perfil público do usuário ("Anúncios ativos de <usuário> (<n>)") | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R4 | ⚠️ Caminho alternativo, da CCD080 (L4) |

- **Não há frame de busca por vendedor** (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 a opção de busca por vendedor; R3 a lista de
  vendedores encontrados; R5 e R6 as duas mensagens.

## Fora do escopo

- Busca global — CCD002; perfil público do vendedor — CCD080 (EA-080-01).
- Detalhe do anúncio — CCD079, CCD080 e CCD072.
- Explorar marketplace, filtros e ordenação — CCD078 e CCD068.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | **Duplicidade:** "Buscar por Vendedor" está no `67` e no `33` (CCD033, #166). Diferenças: o `33` exige login e traz os anúncios "cadastrados", com a mensagem "Nenhum resultado encontrado"; o `67` não exige login, traz os anúncios ativos, lista os vendedores antes e tem duas mensagens. Qual caso de uso fica? (proposta: manter o `67` e cancelar o `33`) | pendente | — |
| L2 | O caso de uso não tem user story no board. Criar a user story ou usar a #166 da CCD033 (que no board se chama "Ordenar Coleção")? | pendente | — |
| L3 | O arquivo `67` não tem marcador de fase, mas a linha "Buscar por Vendedor" de `user-stories.md` está marcada `***` e a CCD067 não está na fatia mínima do ADR-027. A fase é Futuro Marketplace? | pendente | — |
| L4 | O Figma não tem a opção de busca por vendedor no Explorar. O caminho é a busca global → "Ver perfil" → anúncios ativos no perfil público (`1112-3970`, `1160-1396`), ou uma opção nova no Explorar (falta o desenho)? (proposta: o caminho que o Figma já tem) | pendente | — |
| L5 | "Nome do vendedor" é o nome de usuário ou o nome completo (`users.name`)? O perfil público nunca mostra o nome completo (EA-080-01). (proposta: só `username`) | pendente | — |
| L6 | Entre o FP 4 (vendedores encontrados) e o FP 5 (anúncios "do vendedor selecionado") falta o passo em que o cliente escolhe o vendedor. Com um vendedor só, a lista abre direto? Vendedor suspenso aparece? (proposta: o cliente escolhe na lista; só `status = ACTIVE`) | pendente | — |
