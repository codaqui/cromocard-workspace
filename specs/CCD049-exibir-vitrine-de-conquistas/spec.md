# CCD049 — Exibir Vitrine de Conquistas

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** não encontrada no board
- **Caso de uso:** [49-exibir-vitrine-de-conquistas.md](../../docs/Casos-De-Uso/49-exibir-vitrine-de-conquistas.md)
- **Atores:** Cliente (dono do perfil); Visitante e Cliente veem a vitrine no perfil público · **Pré-condições:** autenticado e com perfil cadastrado (para o próprio perfil)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso que as medalhas/badges que eu ganhei (ex: "Colecionador Veterano") fiquem em destaque na página pública do meu perfil.

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
| R1 | A vitrine do próprio perfil exige login (`401` sem token); a vitrine do perfil público não exige login | Permissão | `49`, Pré-condições; user story (página pública); EA-080-01 |
| R2 | As conquistas obtidas são as linhas de `user_achievements` do usuário, não excluídas, cujas `achievements` não estão excluídas | Regra | `49`, FP 2; DBML `achievements`, `user_achievements` |
| R3 | Na página "Perfil" (CCD048), a seção "🏅 Conquistas" mostra a vitrine do usuário | Tela | `49`, FP 1 e FP 3; Figma `1160-37708` (L3) |
| R4 | Cada conquista aparece num cartão com ícone, nome e descrição | Tela | `49`, FP 3; DBML `achievements.icon_url`, `name`, `description`; Figma `1160-37708`, `1160-1396` (L5) |
| R5 | No perfil público do usuário, a seção "Conquistas" mostra só as conquistas obtidas | Tela | user story (destaque na página pública); EA-080-01; Figma `1160-1396` |
| R6 | Selecionar uma conquista mostra os detalhes dela | Ação | `49`, FP 4–5 (L6) |
| R7 | Sem nenhuma conquista obtida, a vitrine mostra "Nenhuma conquista obtida" | Estado | `49`, FA 1 (L7) |
| R8 | Conquista que deixou de existir (`achievements.deleted_at`): a tela informa que os detalhes não podem ser exibidos | Mensagem | `49`, FA 2; ADR-015 |
| R9 | O perfil público de conta excluída não mostra a vitrine (a página não aparece) | Regra | ADR-015, item 8 |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-37708`, `1160-1396`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** Gabriel com 3 conquistas obtidas, **quando** abre "Perfil", **então** a seção "🏅 Conquistas" mostra as 3 com ícone, nome e descrição.
- **CA2** (R5) — **Dado** tiago_trocas com 3 conquistas obtidas, **quando** um visitante abre o perfil público dele, **então** a seção "Conquistas" mostra só as 3 obtidas, sem login.
- **CA3** (R6) — **Dado** a vitrine com "Álbum completo", **quando** o usuário seleciona a conquista, **então** vê os detalhes dela (conteúdo sujeito à L6).
- **CA4** (R7) — **Dado** um usuário sem conquistas, **quando** ele abre "Perfil", **então** a vitrine mostra "Nenhuma conquista obtida".
- **CA5** (R8) — **Dado** uma conquista excluída depois que a página abriu, **quando** o usuário a seleciona, **então** a tela informa que os detalhes não podem ser exibidos.
- **CA6** (R2) — **Dado** uma linha de `user_achievements` com `deleted_at` preenchido, **quando** a vitrine carrega, **então** essa conquista não aparece.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a rota das conquistas do próprio perfil, **então** recebe `401`.
- **CA8** (R9) — **Dado** uma conta excluída, **quando** alguém abre o perfil público dela, **então** a página não é encontrada e a vitrine não aparece.
- **CA9** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print da seção "🏅 Conquistas" é comparado lado a lado com o do frame `1160-37708` (meu perfil), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print da seção "Conquistas" é comparado lado a lado com o do frame `1160-1396` (perfil público do usuário), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `achievements` | `id`, `name`, `description`, `icon_url`, `criteria`, `deleted_at` | `name` único (90); `description` (255) e `criteria` (255) obrigatórias; `icon_url` opcional |
| `user_achievements` | `user_id`, `achievement_id`, `created_at`, `deleted_at` | PK composta; `created_at` = quando a conquista foi obtida |
| `users` | `username`, `deleted_at` | perfil público por nome de usuário; conta excluída não aparece |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Perfil - meu perfil (seção "🏅 Conquistas") | [1160-37708](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37708) | R3, R4 | ❌ Não bate: mostra também as não obtidas, apagadas, e o contador "3 de 5" (L3) |
| Público - Perfil público do usuário (seção "Conquistas") | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R4, R5 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): os ícones são emojis (🏁 🏆 🃏 👥 ⭐); o DBML guarda
  `icon_url` (L5).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): meu perfil — as conquistas ainda não obtidas
  ("Primeiro grupo", "Veterano") apagadas e o contador "3 de 5 • aparecem no seu perfil público" (L3).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 detalhes da conquista; R7 "Nenhuma conquista
  obtida"; R8 aviso de conquista indisponível.

## Fora do escopo

- O resto da página "Perfil" — CCD048. O resto do perfil público (dados, vendas, anúncios) — CCD080 (EA-080-01).
- Denunciar o perfil — CCD050.
- Compartilhar uma conquista no Instagram ou WhatsApp — user story "Compartilhar Conquista Externa" (fase Futuro).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Como e quando o usuário ganha uma conquista? O caso de uso só diz que o sistema "identifica as conquistas obtidas"; nenhum caso de uso grava `user_achievements` (proposta: a service de cada ação confere o critério na hora, ou um job do ADR-010) | pendente | — |
| L2 | Quais conquistas existem? O Figma mostra 5: "Primeiro álbum" (Adicionou o primeiro álbum), "Álbum completo" (Completou um álbum), "100 cartas" (Marcou 100 cartas como possuo), "Primeiro grupo" (Entrou num grupo da comunidade) e "Veterano" (1 ano na CromoCard); a user story cita "Colecionador Veterano". Vão para o seed com esses nomes? O que vai em `criteria`? | pendente | — |
| L3 | Só no Figma (`1160-37708`): as conquistas não obtidas, apagadas, e o contador "3 de 5 • aparecem no seu perfil público". Faz sentido implementar? | pendente | — |
| L4 | O perfil público sem conquistas esconde a seção ou mostra "Nenhuma conquista obtida"? | pendente | — |
| L5 | Ícone: emoji, como no Figma, ou imagem em `icon_url`, como no DBML? | pendente | — |
| L6 | Quais detalhes a conquista mostra ao ser selecionada (proposta: nome, descrição, critério e data em que foi obtida) e em que formato (modal ou expandir o cartão)? Pedir o frame ao Gabriel | pendente | — |
| L7 | O estado "Nenhuma conquista obtida" e o aviso de conquista indisponível (FA 2) não têm frame, e o aviso não tem texto exato: pedir ao Gabriel | pendente | — |
| L8 | Coleção privada (CCD051) esconde as conquistas do perfil público? | pendente | — |
| L9 | Ordem das conquistas na vitrine (proposta: a do seed) | pendente | — |
