# CCD095 — Notificar Pendência Cadastral

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #599 `CCD095-Notificar Pendência Cadastral` · responsável Felipe Broetto Araujo · Sprint 06
- **Caso de uso:** [95-notificar-pendencia-cadastral.md](../../docs/Casos-De-Uso/95-notificar-pendencia-cadastral.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero avisar um vendedor, no site e por e-mail, sobre uma pendência no cadastro e o prazo para regularizar para que ele corrija os dados sem precisar recomeçar.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `95`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Notificar Lojista" na lista e "Notificar Pendência" no dossiê abrem o formulário de pendência | Ação | `95`, FP 1 |
| R3 | Formulário com o destinatário (nome e e-mail) e os canais notificação no site e e-mail | Tela | `95`, FP 2 |
| R4 | Modelos de mensagem prontos que preenchem o corpo com os dados do vendedor | Campo | `95`, FP 3–4 |
| R5 | Corpo da mensagem obrigatório e editável | Campo | `95`, FP 5 e FA 1–2 |
| R6 | Prazo para regularização | Campo | `95`, FP 6 |
| R7 | O envio cria uma notificação para o vendedor e manda o e-mail pelo `MailProvider` | Regra | `95`, FP 9; ADR-009 |
| R8 | O cadastro fica `PENDING`, com `regularization_deadline`, e a ação vai para `audit_logs` | Regra | `95`, FP 10; DBML `seller_verifications`; ADR-051, item 5 |
| R9 | Confirmação com destinatário, assunto, canais, horário e prévia, e as opções "Voltar ao Dashboard" e "Ver perfil do lojista" | Tela | `95`, FP 11 |
| R10 | Cancelar fecha sem enviar | Ação | `95`, FA 3–4 |
| R11 | Se o e-mail falhar, a notificação no site continua e o admin é avisado | Regra | `95`, FA 5–6 |
| R12 | Os modelos ficam em `global_settings` (`seller.pending_templates`) | Regra | ADR-051, item 1 |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um cadastro em análise, **quando** o admin clica em "Notificar Lojista", **então** o formulário mostra nome, e-mail e os dois canais.
- **CA2** (R4, R5) — **Dado** o formulário aberto, **quando** o admin escolhe "Chave Pix divergente do CNPJ", **então** o corpo vem preenchido com o nome e o CNPJ do vendedor e pode ser editado.
- **CA3** (R6–R8) — **Dado** o corpo preenchido e o prazo de 48 horas, **quando** o admin envia, **então** o vendedor recebe a notificação e o e-mail, o cadastro fica `PENDING` com o prazo e o log registra.
- **CA4** (R9) — **Dado** o envio concluído, **quando** a confirmação aparece, **então** mostra destinatário, assunto, canais, horário e a prévia.
- **CA5** (R5) — **Dado** o corpo vazio, **quando** o admin envia, **então** a API responde `400` e nada é enviado.
- **CA6** (R11) — **Dado** o servidor de e-mail fora do ar, **quando** o admin envia, **então** a notificação no site é criada e a tela avisa que o e-mail não foi entregue.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `seller_verifications` | `status`, `regularization_deadline` | da CCD094 |
| `notifications` | `type = SELLER_PENDING` | ADR-051, item 2 |
| `global_settings` | `seller.pending_templates` | chave nova, criada pelo seed |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificar lojista — pendência cadastral | [246-2038](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=246-2038) | R3–R6 | ⚠️ Divergente |
| Notificação enviada ao lojista | [252-1375](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=252-1375) | R9 | ✅ Bate |

- "Protocolo de auditoria" e "Padrão Bacen" são efeito visual (`escopo-adicional.md`, seção 3).

## Fora do escopo

- Editar os modelos pela tela de Configurações.
- Ação automática quando o prazo vence.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Prazos disponíveis (proposta: 24 horas, 48 horas — padrão —, 72 horas e 7 dias) | pendente — proposta | — |
| L2 | Modelos iniciais (proposta: "Chave Pix divergente do CNPJ" e "Endereço não informado", do Figma, criados pelo seed e sem edição nesta story) | pendente — proposta | — |
| L3 | Variáveis do modelo (proposta: `{nome}`, `{cnpj}` e `{prazo}`) | pendente — proposta | — |
| L4 | O que acontece quando o prazo vence? (proposta: nada automático; o admin decide pela CCD094) | pendente — proposta | — |
