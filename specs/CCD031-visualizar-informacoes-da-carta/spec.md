# CCD031 — Visualizar Informações da Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #164 `CCD031 - Visualizar Informações da Carta`
- **Caso de uso:** [31-visualizar-informacoes-da-carta.md](../../docs/Casos-De-Uso/31-visualizar-informacoes-da-carta.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** o ator está no perfil da carta (CCD030)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar as informações da carta para conhecer suas características e identificação.

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
| R1 | As informações são públicas, como o perfil da carta: o visitante as vê sem login | Permissão | `31`, Atores e Pré-condições; `30`, Pré-condições |
| R2 | O perfil da carta mostra o nome da carta como título | Tela | `31`, FP 2; Figma `1112-4615` |
| R3 | O bloco de identificação mostra "Número", "Coleção", "Categoria", "Raridade" e "Idioma" | Tela | `31`, FP 2; Figma `1112-4615` |
| R4 | "Coleção" é o título do álbum da carta, "Categoria" é o nome da categoria dela, "Raridade" o nome da raridade e "Idioma" o nome do idioma | Regra | `31`, FP 2; DBML `cards.album_id`, `category_id`, `rarity_id`, `language_id` (L1) |
| R5 | A carta do catálogo não mostra condição: a condição é de cada anúncio | Regra | `31`, FP 2 |
| R6 | Campo sem valor cadastrado (carta avulsa sem álbum, sem raridade ou sem idioma) aparece com um marcador de vazio, sem quebrar o bloco | Estado | DBML `cards` (colunas opcionais: `album_id` nulo = carta avulsa) (L2) |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frame `1112-4615`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** a carta "Lionel Messi", Nº 10, do álbum "Copa do Mundo 2026", categoria "Seleções", raridade
  "Lendária" e idioma "Português - Brasil", **quando** o ator abre o perfil, **então** vê o título "Lionel Messi" e o bloco
  com Número 10, Coleção Copa do Mundo 2026, Categoria Seleções, Raridade Lendária e Idioma Português - Brasil.
- **CA2** (R1) — **Dado** um visitante sem login, **quando** abre o perfil da carta, **então** vê o bloco de identificação.
- **CA3** (R5) — **Dado** uma carta com anúncios em condições diferentes, **quando** o ator abre o perfil, **então** o bloco
  de identificação não tem condição; a condição só aparece em cada anúncio.
- **CA4** (R6) — **Dado** uma carta avulsa, sem álbum e sem idioma, **quando** o ator abre o perfil, **então** "Coleção" e
  "Idioma" mostram o marcador de vazio decidido na L2 e o bloco mantém o layout.
- **CA5** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-4615`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no título e no bloco de identificação; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `cards` | `name`, `number`, `album_id`, `category_id`, `rarity_id`, `language_id` | `name` obrigatório; as demais aceitam nulo |
| `albums` | `title` | "Coleção" |
| `categories` | `name`, `parent_category_id` | "Categoria" (L1) |
| `rarities` | `name` | "Raridade" |
| `languages` | `name` | "Idioma" |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Perfil da carta | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R2–R5 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): nenhuma no bloco de identificação.
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): os selos acima do título e o subtítulo
  "Nº 10 • Argentina • Panini Copa do Mundo 2026" repetem dados da identificação e acrescentam "Argentina" e a editora
  (decisão na L6 da CCD030; reflexo aqui na L3).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 o campo sem valor (L2).

## Fora do escopo

- Imagens, preços, anúncios e histórico do perfil da carta — CCD030 e CCD075.
- Condição de cada anúncio — CCD030 (lista) e CCD084 (o vendedor informa no anúncio).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | "Categoria" mostra a categoria da carta ("Seleções") ou a franquia raiz do álbum ("Futebol", como no caminho do topo)? Com subcategoria, mostrar a hierarquia (ex.: "Futebol › Seleções")? O ADR-063 (Proposto, ainda fora da `development`) diz que a carta com álbum tem a franquia do álbum | pendente | — |
| L2 | O que mostrar no campo sem valor (carta avulsa, sem raridade ou sem idioma)? O Figma não desenha. (proposta: "—") | pendente | — |
| L3 | O subtítulo do topo traz "Argentina" e a editora ("Panini"), que não estão no FP 2. Eles entram na identificação? De que coluna vem "Argentina"? (ligada à L6 da CCD030) | pendente | — |
