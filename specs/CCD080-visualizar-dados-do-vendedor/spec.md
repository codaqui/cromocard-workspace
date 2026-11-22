# CCD080 — Visualizar Dados do Vendedor

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027; a user story perdeu a marca `***` em 18/11/2026)
- **User story:** não encontrada no board
- **Caso de uso:** [80-visualizar-quantidade-disponivel.md](../../docs/Casos-De-Uso/80-visualizar-quantidade-disponivel.md) (o título do arquivo está errado: o conteúdo é Visualizar Dados do Vendedor, L1) · complemento: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md), EA-080-01
- **Atores:** Visitante, Cliente · **Pré-condições:** o ator está no detalhe de um anúncio ou na lista de anúncios do perfil da carta
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar os dados do vendedor para conhecer o responsável pelo anúncio.

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
| R1 | Os dados públicos do vendedor e o perfil público abrem sem login, para o visitante e para o cliente | Permissão | `80-visualizar-quantidade-disponivel.md`, Atores; EA-080-01 |
| R2 | No detalhe do anúncio, o cartão do vendedor mostra o nome de usuário e "cidade - UF" do vendedor | Tela | `80`, FP 1–3; Figma `1112-5772`, `1112-6152` |
| R3 | Na lista "Anúncios disponíveis" do perfil da carta e em "Outros anúncios desta carta" do detalhe do anúncio, cada linha mostra o nome de usuário e "cidade - UF" do vendedor | Tela | `80`, Pré-condições e FP 3; Figma `1112-4615`, `1112-5772` |
| ~~R4~~ | ~~Nota média das avaliações~~ removido em 22/11/2026: as avaliações saíram do projeto (ADR-068; decisão da L2) | — | — |
| R5 | Dado público não cadastrado não aparece: a tela mostra só o que o vendedor cadastrou, sem campo vazio nem texto de preenchimento | Estado | `80`, FA 1 |
| R6 | O nome do vendedor no anúncio e no perfil da carta, e "Ver perfil" na busca, abrem o perfil público do usuário | Ação | EA-080-01 |
| R7 | O perfil público mostra o nome de usuário, a cidade, o total de "Vendas concluídas" e o total de "Anúncios ativos" | Tela | EA-080-01; Figma `1160-1396` |
| R8 | O perfil público lista os anúncios ativos do usuário ("Anúncios ativos de <nome de usuário> (<n>)"), cada um com a categoria e a coleção da carta, o nome da carta, a condição e o preço | Tela | EA-080-01 ("anúncios ativos"); Figma `1160-1396` |
| R9 | O perfil público nunca mostra nome completo, e-mail, CPF nem endereço, e traz o aviso "O perfil público mostra só o nome de usuário, a cidade, as vendas e os anúncios ativos. Nome completo, e-mail, CPF e endereço nunca aparecem." | Regra | EA-080-01; Figma `1160-1396` |
| R10 | Enquanto carrega, a tela mostra o estado de carregamento; se a API falha, mostra a mensagem de erro que a API devolve | Estado | ADR-041 (erros e estado do servidor) |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1112-5772`, `1112-6152`, `1112-4615`, `1160-1396`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1, R2) — **Dado** um anúncio de um vendedor com nome de usuário e cidade cadastrados, **quando** um visitante
  sem login abre o detalhe do anúncio, **então** a API responde `200` e o cartão do vendedor mostra o nome de usuário e
  "cidade - UF".
- **CA2** (R3) — **Dado** uma carta com 4 anúncios ativos, **quando** o ator abre o perfil da carta, **então** cada linha de
  "Anúncios disponíveis" mostra o nome de usuário e "cidade - UF" do vendedor dela; no detalhe de um desses anúncios,
  "Outros anúncios desta carta" mostra o mesmo para os outros 3.
- **CA3** (R5) — **Dado** um vendedor sem cidade cadastrada, **quando** o ator abre o anúncio dele, **então** o cartão
  mostra só o nome de usuário, sem linha vazia nem "—".
- **CA4** (R6, R7) — **Dado** o detalhe de um anúncio, **quando** o ator clica no nome do vendedor, **então** abre o perfil
  público com o nome de usuário, a cidade, "Vendas concluídas" e "Anúncios ativos" com os totais do vendedor.
- **CA5** (R8) — **Dado** um vendedor com 1 anúncio ativo e 1 pausado, **quando** o ator abre o perfil público, **então** a
  lista mostra "Anúncios ativos de <nome de usuário> (1)" só com o anúncio ativo.
- **CA6** (R9) — **Dado** um vendedor com nome completo, e-mail, CPF e endereço cadastrados, **quando** o ator abre o perfil
  público, **então** a resposta da API e a tela não trazem nenhum desses dados, e o aviso de privacidade aparece no fim da
  página.
- **CA7** (R10) — **Dado** a API lenta, **quando** o ator abre o perfil público, **então** a tela mostra o carregamento;
  **dado** a API fora do ar, **então** a tela mostra a mensagem de erro, sem quebrar o layout.
- **CA8** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-5772` (Detalhe do anúncio), **então** não há diferença de layout,
  medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.
- **CA9** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-6152` (Detalhe do anúncio - indisponível), **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta
  sem quebra, corte nem rolagem horizontal.
- **CA10** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-4615` (Perfil da carta), **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA11** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-1396` (Perfil público do usuário), **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `id`, `username`, `role` (`user_role`), `status` (`user_status`), `created_at`, `deleted_at` | `username` é único e opcional (pode ser nulo); `name`, `email` e `cpf` nunca saem na resposta (R9) |
| `profiles` | `user_id`, `city`, `avatar_url` | 1:1 com `users` (`user_id` único); `city` opcional. Não há coluna de estado (UF) (L3) |
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `status` (`ACTIVE`), `deleted_at` | Anúncios ativos do vendedor (R7, R8) |
| `orders` | `seller_id`, `status` (`order_status`) | Base do total de vendas concluídas (L4) |
| `cards`, `albums`, `categories`, `card_conditions` | `cards.name`, `albums.name`, `categories.name`, `card_conditions.name` | Cartões dos anúncios ativos no perfil público (R8) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Detalhe do anúncio | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R2, R3, R6, R11 | ❌ Não bate (sem a nota média, L2) |
| Público - Detalhe do anúncio - indisponível | [1112-6152](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-6152) | R2, R3, R6, R11 | ❌ Não bate (sem a nota média, L2) |
| Público - Perfil da carta | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R3, R6, R11 | ❌ Não bate (sem a nota média, L2) |
| Público - Perfil público do usuário | [1160-1396](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-1396) | R7–R9, R11 | ✅ Bate com o EA-080-01 (com itens só no Figma, L5–L8) |

- O botão "Ver perfil" da busca (`1112-3970`, CCD002) leva ao perfil público (R6); a tela da busca é da CCD002.
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Detalhe do anúncio e Perfil da carta — mostram o nome de
  usuário e "cidade - UF", sem a nota média das avaliações que o caso de uso pede no FP 3 (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Perfil público `1160-1396` — selos
  "Vendedor" e "Conta de recebimento verificada" (L5); "desde mar. de 2026" (L6); avatar com as iniciais (L7); bloco
  "Conquistas" (L8); "⚑ Denunciar perfil" (Fora do escopo, L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 vendedor sem cidade; R10 carregando e erro;
  perfil público sem anúncios ativos e usuário não encontrado (L10).

## Fora do escopo

- Quantidade disponível, "Comprar" e o estado indisponível do anúncio — CCD079 e CCD072.
- "⚑ Denunciar perfil" e o modal de denúncia (`1160-17495`) — CCD050 (Denunciar Perfil) e CCD083 (Denunciar Vendedor) (L9).
- Avaliações do vendedor — removidas do projeto em 22/11/2026 (CCD081 e `reviews`, ADR-068).
- Vitrine de conquistas — CCD049 (Exibir Vitrine de Conquistas), se a L8 decidir mostrá-la no perfil público.
- Buscar anúncios por vendedor — CCD067.
- Resultados de usuários na busca ("Usuários", "Ver perfil", "312 vendas") — CCD002.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O arquivo `80-visualizar-quantidade-disponivel.md` tem o título "Visualizar Quantidade Disponível", igual ao do 79, mas o conteúdo é Visualizar Dados do Vendedor (inconsistência conhecida do `CLAUDE.md`). Renomear o arquivo e corrigir o título? (proposta: `80-visualizar-dados-do-vendedor.md`, com o título certo) | pendente | — |
| L2 | O caso de uso (FP 3) pede a nota média das avaliações (0 a 5); o Figma não mostra a nota, e o EA-080-01 (21/11/2026) e o ADR-027 tiram a avaliação do MVP. Qual vale? (proposta: tirar a nota do FP 3 e deixá-la para a CCD081, na fase Futuro Marketplace; R4 sai) | Decidida em 22/11/2026: a nota sai do FP 3 e o R4 é removido, porque as avaliações (CCD081 e `reviews`) saíram do projeto | ADR-068; `80`, FP 3 |
| L3 | O caso de uso e o Figma mostram "cidade - UF", mas `profiles` só tem `city`; o estado não existe no perfil e o endereço é privado (R9). De onde vem a UF? (proposta: coluna `state char(2)` em `profiles`, preenchida no Editar Perfil, com mudança no DER e ADR) | pendente | — |
| L4 | O que conta como "venda concluída"? (proposta: pedidos do vendedor com `status = COMPLETED`, pagamento liberado, CCD110) | pendente | — |
| L5 | Selos "Vendedor" e "Conta de recebimento verificada" no perfil público: só no Figma. Faz sentido implementar? (proposta: sim; "Vendedor" quando `role = SELLER` e "Conta de recebimento verificada" quando `stripe_account_status = READY`) | pendente | — |
| L6 | "desde mar. de 2026" (data de criação da conta) no perfil público: só no Figma. Faz sentido implementar? (proposta: sim, mês e ano de `users.created_at`) | pendente | — |
| L7 | Avatar no perfil público, no anúncio e no perfil da carta (as iniciais "TI" no Figma): só no Figma. Faz sentido implementar? (proposta: sim, foto de `profiles.avatar_url` ou as iniciais do nome de usuário) | pendente | — |
| L8 | Bloco "Conquistas" no perfil público: não está no EA-080-01. A user story da CCD049 fala da "página pública do meu perfil", mas o caso de uso 49 só trata do próprio perfil. Faz sentido mostrar aqui? Se sim, é desta story ou da CCD049? | pendente | — |
| L9 | "⚑ Denunciar perfil" no perfil público: é a CCD050 (Denunciar Perfil, alvo `PROFILE`) ou a CCD083 (Denunciar Vendedor, alvo `SELLER`)? O EA-080-01 diz que este é o "perfil público do vendedor" da CCD083 | pendente | — |
| L10 | Estados sem frame: perfil público de usuário sem anúncios ativos, de um usuário que não é vendedor (`CUSTOMER`) e de usuário inexistente, suspenso, bloqueado ou excluído (proposta: sem anúncios, a lista mostra "(0)" e some; `CUSTOMER` mostra o perfil sem os selos de vendedor; inexistente ou excluído responde `404`; suspenso ou bloqueado também `404`, e os anúncios dele saem do marketplace) | pendente | — |
| L11 | A privacidade do portfólio (`profiles.portfolio_privacy = PRIVATE`, CCD051) muda o que o perfil público mostra? | pendente | — |
| L12 | Vendedor sem nome de usuário (`username` nulo): o que aparece no anúncio e no perfil público? (proposta: o nome de usuário passa a ser obrigatório para quem tem anúncio; CCD084 bloqueia o anúncio sem ele) | pendente | — |
