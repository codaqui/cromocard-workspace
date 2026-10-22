# ADR-052 — Credenciamento de vendedor no modelo de dados

- **Status:** Aceito (validado pelo PO em 22/10/2026)
- **Data:** 2026-10-22
- **Decisores:** Daniel Andrade (PO), equipe CromoCard

## Contexto

O PO puxou para a Sprint 06 o escopo adicional vindo do protótipo (`docs/Casos-De-Uso/escopo-adicional.md`), e
duas user stories novas tratam do credenciamento de vendedor: CCD094 (Validar Cadastro de Vendedor) e CCD095
(Notificar Pendência Cadastral). O protótipo mostra, para cada lojista, um dossiê com os dados da empresa, o
responsável legal, os dados bancários e a chave Pix, o endereço comercial, os documentos enviados com a validação de
cada um, as anotações internas da moderação e o status da análise (Em análise, Pendente, Aprovado, Reprovado).

O DER não tem onde guardar nada disso: `users` só tem o papel `SELLER`, e o ADR-027 deixou o marketplace fora do
MVP. O envio dos dados pelo próprio vendedor não existe na documentação nem no Figma; por enquanto os dados vêm do
seed.

## Decisão

1. Crie **`seller_verifications`**, 1:1 com `users` (`user_id` único): dados da empresa (`legal_name`, `trade_name`,
   `cnpj` único, `state_registration`, `opening_date`, `company_size`, `cnae`), responsável legal
   (`responsible_name`, `responsible_cpf`, `responsible_phone`), dados bancários (`bank_name`, `bank_branch`,
   `bank_account`, `pix_key`), endereço comercial por FK para `addresses`, `status`, `rejection_reason`,
   `regularization_deadline` (prazo da pendência), `reviewed_by_id` e `reviewed_at`.
2. Crie o enum **`seller_verification_status`**: `UNDER_REVIEW`, `PENDING`, `APPROVED`, `REJECTED`.
3. Crie **`seller_documents`** (N:1 com `seller_verifications`): `type`, `file_url` (pelo `StorageProvider`,
   ADR-009), `file_size`, `status` (enum **`seller_document_status`**: `SUBMITTED`, `VALIDATED`), `validated_by_id` e
   `validated_at`.
4. Crie **`seller_verification_notes`** (N:1 com `seller_verifications`): `author_id` e `content`. As notas nunca
   aparecem para o vendedor.
5. O papel continua em `users.role`: só um vendedor com `seller_verifications.status = APPROVED` é "lojista
   certificado" nos indicadores (CCD096) e no relatório de auditoria de lojistas.

## Alternativas consideradas

- **Colunas em `users`:** cerca de 18 colunas que só valem para vendedores, quase todas nulas para clientes.
- **Dados da empresa em `catalog_requests.data` (jsonb):** reaproveita a fila de solicitações, mas mistura dois
  fluxos de análise e perde o `cnpj` único e as FKs.
- **Deixar o credenciamento fora:** era a proposta original da CCD058 (L2); o PO decidiu incluir como escopo
  adicional.

## Consequências

- O DER passa a ter 3 tabelas e 2 enums a mais no módulo 8, nos três formatos e no diagrama de classes
  (`VerificacaoVendedor`, `DocumentoVendedor`, `NotaVerificacao`).
- CPF e CNPJ são dados pessoais (LGPD): só o BackOffice lê, e os logs não registram o valor (ADR-019).
- Falta um caso de uso para o vendedor enviar os dados e os documentos. Até lá, o seed cria os cadastros de teste.

## Referências

- Casos de uso 94 e 95; `docs/Casos-De-Uso/escopo-adicional.md`
- Figma: `208-1240`, `246-1201`, `246-2038`, `252-1375`, `252-1723`, `252-2837`
- ADR-009 (storage), ADR-015 (soft delete), ADR-019 (logs), ADR-027 (marketplace no MVP)
