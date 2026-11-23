# CCD012 — Compartilhar Coleção

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #118 `CCD012 -Compartilhar Coleção`
- **Caso de uso:** [12-compartilhar-colecao.md](../../docs/Casos-De-Uso/12-compartilhar-colecao.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com uma coleção cadastrada
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso compartilhar minha coleção para permitir que outros usuários visualizem meus álbuns e itens cadastrados.

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
| R1 | Gerar o link de compartilhamento exige login e uma coleção cadastrada: sem token, a API responde `401` | Permissão | `12`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | A página da coleção tem a opção "Compartilhar" (rótulo e onde aparece: L11) | Ação | `12`, FP 1 |
| R3 | A opção gera o link de compartilhamento da coleção, guardado em `collections.share_link` (único) (formato: L2) | Regra | `12`, FP 2; DBML `collections.share_link` |
| R4 | Junto do link, a tela mostra as opções de redes sociais | Tela | `12`, FP 2 |
| R5 | O cliente copia o link | Ação | `12`, FP 3 |
| R6 | O cliente escolhe uma rede social e o compartilhamento dela abre com o link (redes e como abre: L9) | Ação | `12`, FP 3 |
| R7 | A tela confirma que o link foi copiado ou que o compartilhamento foi iniciado (texto: L8) | Mensagem | `12`, FP 4 |
| R8 | Com a coleção privada (`collections.is_public = false`), a tela avisa que é preciso torná-la pública primeiro (como no Figma: L4; qual coluna vale: L5) | Regra | `12`, FA 1; DBML `collections.is_public` (default `false`) |
| R9 | Quem abre o link de uma coleção pública vê os álbuns e os itens dela (desenho da página: L3) | Tela | `12`, Finalidade; `user-stories.md`, narrativa da CCD012 |
| R10 | Se a API falha ao gerar o link, a tela mostra a mensagem de erro da API | Estado | ADR-041, Erros |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. A página pública aberta pelo link segue o frame quando ele existir (L3) | Fidelidade | Figma (frames da seção Telas: `1160-9616`, `1122-17812`, `1160-23080`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** um cliente com a coleção pública, **quando** ele seleciona "Compartilhar coleção", **então** vê o link da coleção e as opções de redes sociais, e `collections.share_link` fica preenchido.
- **CA2** (R3) — **Dado** um cliente que já gerou o link, **quando** abre o compartilhamento de novo, **então** vê o mesmo link.
- **CA3** (R5, R7) — **Dado** o compartilhamento aberto, **quando** o cliente seleciona "Copiar link", **então** o link vai para a área de transferência e a tela confirma a cópia.
- **CA4** (R6, R7) — **Dado** o compartilhamento aberto, **quando** o cliente seleciona "WhatsApp", **então** abre o compartilhamento do WhatsApp com o link já preenchido.
- **CA5** (R8) — **Dado** um cliente com a coleção privada, **quando** abre o compartilhamento, **então** vê o aviso de que precisa tornar a coleção pública primeiro, e o link e as redes não ficam disponíveis.
- **CA6** (R9) — **Dado** uma coleção pública com 4 álbuns, **quando** outra pessoa abre o link, **então** vê os 4 álbuns e as cartas da coleção; **dado** a coleção tornada privada depois, **quando** abre o mesmo link, **então** não vê os álbuns.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a API que gera o link, **então** recebe `401`.
- **CA8** (R10) — **Dado** a API fora do ar, **quando** o cliente abre o compartilhamento, **então** vê a mensagem de erro.
- **CA9** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-9616`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R11) — **Dado** o Início aberto em 1280 px, **quando** o print é comparado lado a lado com o frame `1122-17812`, **então** o botão "Compartilhar coleção" não tem diferença; e em 375, 768 e 1024 px se adapta sem quebra, corte nem rolagem horizontal.
- **CA11** (R11) — **Dado** "Meus álbuns" aberto em 1280 px, **quando** o print é comparado lado a lado com o frame `1160-23080`, **então** o botão "Compartilhar coleção" não tem diferença; e em 375, 768 e 1024 px se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collections` | `user_id`, `is_public`, `share_link` | `is_public` obrigatório, default `false`; `share_link` `varchar(120)`, único, opcional |
| `users` | `username` | se o link usar o nome de usuário (L2, L10); `username` é único e opcional |
| `profiles` | `portfolio_privacy` (`privacy`: `PUBLIC`, `PRIVATE`) | só se decidir que ela governa a coleção (L5) |
| `user_albums`, `albums`, `collection_cards`, `cards` | `album_id`, `title`, `progress_percentage`, `status`, `quantity`, `deleted_at` | o que a página pública mostra (R9) e o resumo do modal (L6) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Início - compartilhar coleção | [1160-9616](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-9616) | R3–R8, R11 | ❌ Não bate: interruptor "Coleção pública" no lugar do aviso (L4) e blocos só no Figma (L6, L7) |
| Cliente - Início (botão de entrada) | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R2, R11 | ✅ Bate: botão "Compartilhar coleção" |
| Álbuns - Meus álbuns (botão de entrada) | [1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080) | R2, R11 | ✅ Bate: botão "Compartilhar coleção" |

- Textos do modal `1160-9616`: "Compartilhar coleção", "Envie o link da sua coleção para outras pessoas verem seus álbuns e cartas.", "LINK PÚBLICO", "cromocard.com.br/u/<nome de usuário>", "Copiar link", "COMPARTILHAR EM", "WhatsApp", "X", "Facebook", "Baixar imagem", "Coleção pública", "Desligada, o link deixa de funcionar. Você muda isso também em Configurações.", "Fechar" e "✕".
- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Compartilhar coleção — o caso de uso pede um aviso para tornar a coleção pública primeiro; o Figma põe o interruptor "Coleção pública" dentro do modal e não desenha o estado privado (L4).
  - Compartilhar coleção — o link é `cromocard.com.br/u/<nome de usuário>`, o mesmo endereço do perfil (`1160-37708`) e do perfil público (`1160-1396`, CCD080), que não mostra a coleção (L2, L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Compartilhar coleção — resumo "Coleção de @<nome de usuário>", "<n> álbuns • <n> cartas • <n> repetidas", o progresso de cada álbum e as iniciais (L6).
  - Compartilhar coleção — "Baixar imagem" (L7).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R7 confirmação de link copiado (L8).
  - R8 estado da coleção privada (L4).
  - R9 página pública aberta pelo link (L3).
  - R10 mensagem de erro.

## Fora do escopo

- Compartilhar o progresso de um álbum — CCD020.
- Interruptor "Coleção pública" em Configurações — CCD051 (usa o mesmo dado, L5).
- Perfil público do usuário — CCD080 (EA-080-01).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` compartilha coleção? (proposta: não, como na CCD007, L1) | pendente | — |
| L2 | Formato do link: o Figma usa `/u/<nome de usuário>`, o mesmo endereço do perfil público; o DBML tem `collections.share_link`. O `share_link` guarda o nome de usuário ou um código próprio? (proposta: `share_link` = nome de usuário, e a página `/u/<nome de usuário>` mostra o perfil público e, com a coleção pública, os álbuns) | pendente | — |
| L3 | Falta o desenho da página que quem abre o link vê, e o perfil público (`1160-1396`) não mostra a coleção. O visitante precisa de login? (proposta: sem login; álbuns com capa, título e progresso, e as cartas de cada um; o Gabriel desenha) | pendente | — |
| L4 | Coleção privada: o caso de uso avisa para torná-la pública primeiro; o Figma deixa ligar e desligar dentro do modal ("Coleção pública"). Qual vale? (proposta: o Figma; com o interruptor desligado, o link e as redes ficam desabilitados com o aviso "Ligue Coleção pública para compartilhar"; o Gabriel desenha o estado) | pendente | — |
| L5 | O DBML tem duas colunas de privacidade: `collections.is_public` (default `false`) e `profiles.portfolio_privacy` (default `PUBLIC`). Qual governa a coleção e o interruptor de Configurações (CCD051)? (proposta: `collections.is_public`; `portfolio_privacy` fica com o portfólio da CCD036) | pendente | — |
| L6 | O resumo da coleção no modal só existe no Figma. Faz sentido? (proposta: sim; álbuns e cartas possuídas como na CCD007, L3, e o progresso de cada álbum) | pendente | — |
| L7 | "Baixar imagem" só existe no Figma. Faz sentido? O que a imagem mostra? (proposta: sim, um PNG gerado no navegador com o resumo do modal) | pendente | — |
| L8 | Texto da confirmação do FP 4: o Figma não desenha. (proposta: o botão troca para "Link copiado" por 2 segundos; nas redes, a janela da rede abrindo já confirma) | pendente | — |
| L9 | Quais redes e como abrem? (proposta: WhatsApp, X e Facebook, como no Figma, pelos links de compartilhamento de cada rede numa nova aba, sem SDK) | pendente | — |
| L10 | O `users.username` é opcional no DBML. Sem nome de usuário, qual é o link? (proposta: o modal pede para definir o nome de usuário no Perfil antes de compartilhar) | pendente | — |
| L11 | O caso de uso chama a opção de "Compartilhar" na "página da sua coleção"; o Figma tem "Compartilhar coleção" no Início e em "Meus álbuns". (proposta: como no Figma, nos dois lugares) | pendente | — |
