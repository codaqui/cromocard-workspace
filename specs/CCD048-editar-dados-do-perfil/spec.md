# CCD048 — Editar Dados do Perfil

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1242 `CCD048 - Editar Dados do Perfil` (criada em 22/11/2026)
- **Caso de uso:** [48-editar-dados-do-perfil.md](../../docs/Casos-De-Uso/48-editar-dados-do-perfil.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com perfil cadastrado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso editar minhas informações, alterar minha foto (avatar) e gerenciar meus endereços cadastrados.

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
| R1 | O perfil exige login (`401` sem token); o usuário só lê e altera os próprios dados e endereços (endereço de outra pessoa responde `404`) | Permissão | `48`, Pré-condições; ADR-005, item 4 |
| R2 | Página "Perfil" (item "Perfil" no menu), com o topo "MINHA CONTA", "Perfil" e "Seus dados, sua foto, os endereços de entrega e a acessibilidade." | Tela | `48`, FP 1; Figma `1160-37708` (L1) |
| R3 | O cartão do usuário mostra a foto (ou as iniciais), o nome, o @, o link "cromocard.com.br/u/<nome de usuário>", "Alterar Foto" e "Recomendado 500x500px (PNG ou JPG até 4MB)", "STATUS" e "MEMBRO Desde <ano de criação da conta>" | Tela | `48`, FP 2; user story (foto); DBML `profiles.avatar_url`, `users.created_at`; Figma `1160-37708` (L5, L11) |
| R4 | "Informações pessoais" com os dados atuais: "Nome Completo *" (`users.name`, até 120), "Nome de usuário" (`users.username`), "E-mail" com o selo "Verificado" quando `email_verified`, "Celular" (`users.phone`) e "Conte um pouco sobre você" (`profiles.bio`) com o contador "<n> / 300 caracteres" | Campo | `48`, FP 2–3; DBML `users`, `profiles`; Figma `1160-37708` (L3, L4) |
| R5 | O sistema valida os dados: dado inválido ou incompleto impede salvar e o rótulo do campo indica o erro (no frame, "Nome completo • informe o nome" em vermelho) | Mensagem | `48`, FP 4 e FA 1–2; Figma `1160-38269` |
| R6 | Nome de usuário repetido responde `409` com o campo `username` | Regra | DBML `users.username` (único); `03`, FP 4 (disponibilidade) (L3) |
| R7 | "Salvar alterações" grava os dados e mostra o aviso "Perfil atualizado" com "Suas alterações foram salvas." | Ação | `48`, FP 5–7; Figma `1160-38711` |
| R8 | "Descartar" desfaz as alterações não salvas e volta aos dados anteriores | Ação | `48`, FA 3–4 |
| R9 | "Alterar Foto" abre o modal "Alterar Foto do Perfil" ("A foto aparece no seu perfil público, nos grupos e nas mensagens."), com a área "Clique ou arraste um novo arquivo aqui", "Cancelar" e "Aplicar e Salvar Foto"; a foto vai para o `StorageProvider` e a URL para `profiles.avatar_url` | Ação | user story (alterar foto); ADR-050, item 1; ADR-009; Figma `1160-39158` |
| R10 | A foto aceita PNG, JPG ou WEBP até 4 MB; fora disso, a API recusa e a tela avisa | Regra | ADR-050, item 1 (L5) |
| R11 | "Endereços de entrega" ("Usados para calcular o frete e receber as compras.") lista os endereços não excluídos: selo "Endereço Principal (Padrão)" ou "SECUNDÁRIO", identificação, logradouro, número, complemento, bairro, cidade - UF e CEP, com editar, remover e, no secundário, "Tornar Padrão" | Tela | user story (gerenciar endereços); DBML `addresses`; Figma `1160-37708` (L7) |
| R12 | "+ Adicionar Novo Endereço" abre "Novo endereço" com CEP, logradouro, número, complemento (opcional), bairro, cidade, estado (UF), identificação e "Definir como Endereço Principal" ("Vem escolhido no checkout."); obrigatórios como no DBML; "Cancelar" e "Salvar Endereço" | Ação | user story; DBML `addresses` (obrigatórias: `label`, `zip_code`, `street`, `number`, `neighborhood`, `city`, `state`); Figma `1160-39672` (L7, L8) |
| R13 | O editar abre "Editar Endereço" com os mesmos campos preenchidos, "Remover este Endereço", "Cancelar" e "Salvar Alterações" | Ação | user story; DBML `addresses`; Figma `1160-40220` (L9) |
| R14 | Só um endereço é o principal: "Tornar Padrão" ou "Definir como Endereço Principal" marca `is_primary` nele e tira do anterior | Regra | `48`, FA 6; DBML `addresses.is_primary` (L10) |
| R15 | Remover pede confirmação no modal "Remover este endereço de entrega?" ("Tem certeza de que deseja remover o endereço cadastrado da sua conta?"), com "Cancelar" e "Remover endereço"; confirmar preenche `addresses.deleted_at` | Ação | user story; ADR-015, itens 1 e 2; Figma `1160-40789` |
| R16 | O endereço principal não é removido: a tela pede que outro seja escolhido como principal antes ("Se este for o seu endereço principal, escolha outro como principal antes de remover."); a API recusa com `409` | Regra | `48`, FA 5–6; Figma `1160-40789` (L10) |
| R17 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-37708`, `1160-38269`, `1160-38711`, `1160-39158`, `1160-39672`, `1160-40220`, `1160-40789`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4, R7) — **Dado** Gabriel logado, **quando** abre "Perfil", troca o texto de "Conte um pouco sobre você" e seleciona "Salvar alterações", **então** `profiles.bio` é gravado e aparece o aviso "Perfil atualizado" com "Suas alterações foram salvas.".
- **CA2** (R5) — **Dado** "Nome Completo" vazio, **quando** Gabriel seleciona "Salvar alterações", **então** nada é gravado, o rótulo mostra "Nome completo • informe o nome" em vermelho e a API responde `400` com o campo `name`.
- **CA3** (R6) — **Dado** o @ `marcos_tcg` já usado por outra conta, **quando** Gabriel salva com ele, **então** a API responde `409` com o campo `username` e a tela indica o campo.
- **CA4** (R8) — **Dado** alterações não salvas, **quando** Gabriel seleciona "Descartar", **então** os campos voltam aos valores gravados.
- **CA5** (R9, R10) — **Dado** o modal "Alterar Foto do Perfil", **quando** Gabriel envia um JPG de 2 MB e seleciona "Aplicar e Salvar Foto", **então** `profiles.avatar_url` é gravado e a foto substitui as iniciais; **quando** envia um GIF ou um arquivo de 6 MB, **então** a API recusa e a tela avisa.
- **CA6** (R12, R14) — **Dado** um endereço principal, **quando** Gabriel cria um endereço novo com "Definir como Endereço Principal" marcado, **então** o novo é gravado com `is_primary = true` e o anterior passa a `false`.
- **CA7** (R12) — **Dado** o modal "Novo endereço" sem número, **quando** Gabriel seleciona "Salvar Endereço", **então** nada é gravado e o campo "Número" indica o erro.
- **CA8** (R13) — **Dado** o endereço "Studio Campinas", **quando** Gabriel o edita, troca o complemento e seleciona "Salvar Alterações", **então** o endereço é atualizado na lista.
- **CA9** (R14) — **Dado** o endereço secundário, **quando** Gabriel seleciona "Tornar Padrão", **então** ele recebe o selo "Endereço Principal (Padrão)" e o outro passa a "SECUNDÁRIO".
- **CA10** (R15) — **Dado** um endereço secundário, **quando** Gabriel seleciona remover e confirma "Remover endereço", **então** `addresses.deleted_at` é preenchido e o endereço some da lista; com "Cancelar", nada muda.
- **CA11** (R16) — **Dado** o endereço principal, **quando** Gabriel tenta removê-lo, **então** ele não é removido, a tela pede que outro seja escolhido como principal e a API responde `409`.
- **CA12** (R1) — **Dado** um visitante sem login, **quando** chama as rotas do perfil, **então** recebe `401`; **dado** Gabriel, **quando** edita o endereço de outra conta, **então** recebe `404`.
- **CA13** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-37708` (meu perfil), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-38269` (erros de validação), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA15** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-38711` (alterações salvas), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA16** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-39158` (alterar foto), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA17** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-39672` (novo endereço), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA18** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-40220` (editar endereço), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA19** (R17) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-40789` (remover endereço), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `username`, `email`, `email_verified`, `phone`, `role`, `created_at` | `name` obrigatório (120); `username` único (30); `phone` até 20 |
| `profiles` | `bio`, `avatar_url` | 1:1 com `users`; `bio` é `text`, sem limite no DBML (L4) |
| `addresses` | `label`, `zip_code`, `street`, `number`, `complement`, `neighborhood`, `city`, `state`, `is_primary`, `deleted_at` | obrigatórias todas menos `complement`; `state` `char(2)`; `zip_code` 9; `is_primary` default `false`; só um `label` (L7) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Perfil - meu perfil | [1160-37708](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37708) | R2–R4, R11 | ❌ Não bate: sem "Editar perfil" (L1); dois rótulos no endereço (L7) |
| Perfil - erros de validação | [1160-38269](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-38269) | R5 | ✅ Bate |
| Perfil - alterações salvas | [1160-38711](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-38711) | R7 | ✅ Bate |
| Perfil - alterar foto | [1160-39158](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-39158) | R9, R10 | ❌ Não bate: limite de 5 MB e 800x800 contra os 4 MB do ADR-050 e o 500x500 do cartão (L5); zoom e remover foto só no Figma (L6) |
| Perfil - novo endereço | [1160-39672](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-39672) | R12, R14 | ❌ Não bate: "Buscar CEP" só no Figma (L8); identificação "Casa / Empresa" (L7) |
| Perfil - editar endereço | [1160-40220](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-40220) | R13, R14 | ❌ Não bate: estilo diferente do "Novo endereço", "LOGÍSTICA SEGURADA", "Validado pelos Correios", "Casa / Trabalho" (L7–L9) |
| Perfil - remover endereço | [1160-40789](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-40789) | R15, R16 | ❌ Não bate: mostra a remoção do principal com o botão ativo, e o `48`, FA 5–6, não remove (L10) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): meu perfil — o `48`, FP 1–2, tem a opção "Editar perfil"
  que abre o modo de edição; no Figma, a página já está editável, com "Descartar" e "Salvar alterações" (L1). Alterar
  foto — "PNG, JPG ou WEBP (Resolução recomendada 800x800, máx. 5MB)" no modal e "Recomendado 500x500px (PNG ou JPG até
  4MB)" no cartão; o ADR-050 diz PNG, JPG ou WEBP até 4 MB (L5). Remover endereço — o frame remove o "ENDEREÇO PADRÃO"
  com "Remover endereço" ativo (L10).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "AJUSTE DE ESCALA & ZOOM", "Enquadramento
  1:1 Circular", "Remover Foto Atual" e a lixeira do cartão (L6); "Buscar CEP", "Preenche a rua pelo CEP" e "Atualizar
  CEP" (L8); "LOGÍSTICA SEGURADA" e "Validado pelos Correios" (L9); "STATUS Colecionador" (L11); limite de 300 caracteres
  na bio (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 erros dos outros campos e dos modais de
  endereço; R10 aviso de arquivo recusado; R16 o bloqueio da remoção do principal.

## Fora do escopo

- Seção "Conquistas" — CCD049. Seção "Acessibilidade" — CCD038.
- Alterar e-mail e senha, privacidade da coleção e cidade no perfil público — CCD051.
- Página pública do usuário (`cromocard.com.br/u/<nome de usuário>`) — CCD080 (EA-080-01) e CCD049.
- Editar perfil pelo Painel do vendedor — CCD091 (L2).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `48`, FP 1–2, abre o modo de edição por "Editar perfil"; o Figma (`1160-37708`) já mostra os campos editáveis, sem esse botão. Qual vale? (proposta: o Figma, ajustando o caso de uso) | pendente | — |
| L2 | O ator é Cliente: o `SELLER` usa esta página ou a do Painel do vendedor (CCD091, `675-4627`)? A CCD098 diz que editar @ e telefone pelo cliente é da CCD091. E o `ADMIN`? | pendente | — |
| L3 | O usuário pode trocar o nome de usuário (muda o link público)? Valem as regras do cadastro (`03`, FP 4: 3 a 30 caracteres, minúsculas, números, ponto e `_`)? Formato do celular (como na CCD098)? E o e-mail é só leitura aqui (a troca fica em "Alterar e-mail", CCD051)? | pendente | — |
| L4 | Só no Figma: limite de 300 caracteres na bio ("162 / 300 caracteres"); o DBML não limita (`text`). Faz sentido? | pendente | — |
| L5 | Foto: o cartão diz "PNG ou JPG até 4MB" e 500x500; o modal diz "PNG, JPG ou WEBP", 800x800 e 5 MB; o ADR-050 diz PNG, JPG ou WEBP até 4 MB. Qual vale? (proposta: o ADR-050, ajustando os textos do Figma) | pendente | — |
| L6 | Só no Figma: zoom ("AJUSTE DE ESCALA & ZOOM"), recorte circular 1:1, "Remover Foto Atual" e a lixeira do cartão. Faz sentido implementar? | pendente | — |
| L7 | O DBML tem um só `label` por endereço; o Figma mostra um nome ("Apartamento Bela Vista") e um tipo ("Residencial", "Escritório" no cartão; "Casa / Empresa" no novo; "Casa / Trabalho" no editar), e os modais não têm campo para o nome. O que é o `label`? Precisa de coluna nova (ADR e DER)? | pendente | — |
| L8 | Só no Figma: "Buscar CEP" que preenche o endereço. Precisa de serviço externo (provider, ADR-009) que nenhum ADR escolhe. Faz sentido implementar? | pendente | — |
| L9 | O "Editar Endereço" tem outro estilo (rótulos, ícones, "LOGÍSTICA SEGURADA", "Validado pelos Correios") que o "Novo endereço". Qual é o contrato? Pedir ao Gabriel que alinhe os dois modais | pendente | — |
| L10 | Remover o principal: o botão fica desabilitado ou a tela avisa depois do clique (e o "Remover este Endereço" do editar)? O primeiro endereço vira principal sozinho? Quem tem um endereço só nunca consegue removê-lo? | pendente | — |
| L11 | Só no Figma: "STATUS Colecionador". O que mostra (o papel: Colecionador para `CUSTOMER`, Vendedor para `SELLER`)? | pendente | — |
| L12 | A cidade do perfil público (`profiles.city`, EA-080-01) não tem campo nesta página. Onde o usuário a informa (campo novo aqui ou a cidade do endereço principal)? | pendente | — |
