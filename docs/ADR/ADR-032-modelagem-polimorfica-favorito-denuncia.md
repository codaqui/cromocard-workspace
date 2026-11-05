# ADR-032 — Modelagem polimórfica para alvos de `favorito` e `denuncia`

- **Status:** Aceito (validado pelo PO em 29/10/2026, na revisão da issue #2)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O DER (`docs/Diagramas/DER/README.md`) define dois "alvos polimórficos":

- `favorito`: coluna `tipo` + `album_id`/`carta_id`/`grupo_id`, exatamente um preenchido.
- `denuncia`: coluna `tipo_alvo` + `anuncio_id`/`usuario_alvo_id`/`mensagem_grupo_id`.

Ou seja, uma entidade pode se referir a mais de um tipo de "alvo", modelado com uma coluna
discriminadora mais múltiplas chaves estrangeiras opcionais (apenas uma preenchida por linha).

## Decisão

Modelar entidades que se referem a múltiplos tipos de alvo (favoritar álbum/carta/grupo, denunciar
anúncio/usuário/mensagem) usando coluna discriminadora + FKs opcionais (uma preenchida por
registro), mantendo a integridade referencial via chave estrangeira nativa do PostgreSQL.

## Alternativas consideradas

- **Tabela separada por tipo de alvo** (ex.: `favorito_album`, `favorito_carta`,
  `favorito_grupo`), evitando colunas nulas, ao custo de mais tabelas e mais joins na aplicação.
- **FK genérica** (`target_type` + `target_id`) sem constraint de integridade referencial no
  banco, delegando a validação inteiramente à aplicação.

## Consequências

**Positivas**
- Uma única tabela por conceito (`favorito`, `denuncia`), reduzindo duplicação de estrutura.
- Integridade referencial garantida pelo banco (cada FK aponta para uma tabela real).

**Negativas / riscos**
- A regra "exatamente um alvo preenchido" não é garantida nativamente pelo PostgreSQL/Prisma —
  requer `CHECK constraint` no banco ou validação na camada de aplicação, ainda não especificada.
- Índices e queries ficam mais amplos (várias colunas anuláveis por linha), exigindo atenção ao
  desempenho em tabelas de alto volume.

## Referências

- `docs/Diagramas/DER/README.md` (seção "Convenções")
- `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml`
- `CLAUDE.md` (seção "Modelo de dados", "Alvos polimórficos")
