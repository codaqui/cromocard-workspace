# Tarefas — CCD095 Notificar Pendência Cadastral

- **Plano:** [plano.md](plano.md) · **User story:** AB#599
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/599-notificar-pendencia-cadastral`

- [x] **T1** · Criar seed dos modelos de pendência e o schema da chave — R4, R12 · AB#621
  - Pronto quando: a chave existe depois do seed e o schema Zod valida a lista de modelos.
  - **Revista em 19/11/2026:** refeita sobre o `develop` com a CCD094 e a CCD066 mescladas. A chave entra em `SETTING_KEYS` (`setting-schemas.ts`, com `pendingTemplatesSchema`) e no seed de `admin.seed.ts`/`global-settings.json`, que é onde a CCD066 grava as configurações; ela não é editável pela tela de Configurações (Fora do escopo).
- [x] **T2** · Criar service de pendência com notificação, e-mail, prazo e auditoria — R5–R8, R11 · CA3, CA5, CA6 · AB#622
  - Pronto quando: `pending-notice.service.spec.ts` cobre CA3, CA5 e CA6.
  - **Revista em 19/11/2026:** o cadastro passa a `PENDING` por um update condicional (`markPendingIfUndecided`, como a decisão da CCD094): se outro admin decidiu antes, responde `409` e nada é enviado. A notificação no site e a auditoria (com modelo, prazo e data limite em `details`) ficam na mesma transação, e o e-mail sai depois do commit. Os dublês de teste do credenciamento foram para `seller-verifications.doubles.ts`, usados pelos dois specs.
  - **Revista em 14/11/2026:** CA6 (e-mail fora do ar) coberto no teste de unidade, injetando um `MailProvider` que falha; o `InMemoryMailProvider` usado na integração não tem como simular falha, então CA6 não entra no teste de integração.
- [x] **T3** · Criar rotas de modelos e de envio da pendência — R1 · CA7 · AB#623
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/599-notificar-pendencia-cadastral`

- [x] **T4** [P] · Criar api e queries da notificação de pendência — R4–R8 · AB#624
  - Pronto quando: o typecheck passa.
- [x] **T5** · Criar modal Notificar Lojista com modelos, prazo e confirmação — R2–R6, R9, R10 · CA1, CA2, CA4 · AB#625
  - Pronto quando: `PendingNoticeModal.spec.tsx` cobre escolher modelo, enviar e cancelar.
  - **Revista em 14/11/2026 (substituída pela revisão de 19/11/2026):** existe uma implementação de referência numa branch antiga (`feature/599-notificar-pendencia-cadastral-referencia`), divergente demais do `develop` atual para reaproveitar direto; usada só como consulta, inclusive a troca do `<select>` dos modelos por uma lista com check, como no Figma.
  - **Revista em 14/11/2026 (2, substituída pela revisão de 19/11/2026):** validada ponta a ponta no navegador (backend + frontend reais, admin de teste): abre pela lista e pelo dossiê, modelo preenche o corpo, envio muda o cadastro para Pendente e mostra a confirmação com destinatário, canais, horário e prévia. Responsividade conferida em 375, 768 e 1920.
  - **Revista em 19/11/2026:** refeita sobre o `develop` com a CCD094. Abre só por "Notificar Pendência" no rodapé do dossiê (L5). Segue o `246-2038`: título "Notificar Lojista — Pendência Cadastral" com o destinatário no subtítulo, canais em selos, modelos de 1 clique com check e "Preenchimento Dinâmico", "Corpo da mensagem transacional", "Prazo para regularização (SLA)" e "Enviar Notificação & Registrar Log". O `{prazo}` sai sem o "(padrão)" da opção, trocar o prazo refaz o texto do modelo enquanto o admin não o editou, a confirmação mostra o horário com hora, e "Voltar ao Dashboard" fecha o dossiê. Validada ponta a ponta no navegador e na matriz 320, 360, 768, 1024, 1366 e 1920.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#626
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R3, R9, R10 | T5 |
| R4 | T1, T4, T5 |
| R5, R6 | T2, T4, T5 |
| R7, R8 | T2, T4 |
| R11 | T2 |
| R12 | T1 |
