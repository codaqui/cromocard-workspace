# ADR-073 — Prints como evidência da denúncia do chat pessoal

- **Status:** Aceito (validado pelo PO, Felipe Consulim, em 2026-11-28)
- **Data:** 2026-11-26
- **Decisores:** Daniel Andrade (proposta, na CCD047 Moderar Contatos Privados, lacunas L3 e L7); validação: Felipe Consulim (PO), que decidiu o storage privado (L13)
- **Complementa:** ADR-032 (alvo polimórfico de `reports`), ADR-050 (upload de arquivos) e ADR-068 (storage privado)

## Contexto

A denúncia feita pelo chat pessoal grava em `reports` o contato denunciado, o motivo e a descrição. Isso não basta para a
moderação decidir: a conversa é privada, e ninguém do BackOffice a vê. O protótipo (frame `1160-34298`) propunha
"Anexar as últimas 20 mensagens", mas o DBML não tem onde guardar essa ligação (`reports` não aponta para `messages`).

Toda denúncia do chat precisa levar evidência, e a evidência é o print que o próprio usuário envia (proposta do Daniel,
validada pelo PO). O print mostra uma conversa privada, que pode ter telefone, endereço ou dados de pagamento: ele não
pode ter URL pública.

## Decisão

1. **Crie a tabela `report_evidences`** (módulo 8, Moderação e Administração): `id`, `report_id` (FK para `reports`),
   `url`, `sort_order` e as colunas de tempo (ADR-016). Uma denúncia tem várias evidências; a evidência não existe sem a
   denúncia.
2. **Exija de 1 a 3 prints** na denúncia feita pelo chat pessoal (`target_type = USER`). Sem print, a API
   responde `400`.
3. **Aplique as regras de arquivo do ADR-050 e grave no storage privado do ADR-068:** PNG, JPG ou WEBP até 4 MB cada, enviados no mesmo
   pedido da denúncia (`multipart`), gravados no storage privado (`visibility: 'private'`, pasta `report-evidences`),
   que nunca é servido por `/uploads`. A coluna `url` guarda a chave do arquivo no storage privado, como
   `seller_documents.file_url`, e nunca uma URL pública. A denúncia e as evidências são gravadas na mesma transação.
4. **Mostre o print só a quem pode vê-lo:** só o denunciante (ao enviar) e o administrador, na Fila de moderação da Gestão de Comunidade (CCD062),
   que mostra as miniaturas no card da denúncia. O print só sai pela rota autenticada `GET /api/v1/admin/community/reports/:id/evidences/:evidenceId`,
   só para `ADMIN`, que lê o arquivo com `read(key)` (ADR-068) e o devolve com o tipo da imagem; o frontend baixa o
   arquivo com o token e o mostra como `blob`.
5. **Limite o alcance à denúncia do chat:** as outras denúncias (perfil, anúncio, vendedor e mensagem de grupo) podem adotar a mesma tabela quando
   as suas specs decidirem; esta decisão não as obriga.

## Alternativas consideradas

- **Anexar as últimas 20 mensagens pelo servidor:** vantagem: a prova não pode ser forjada. Desvantagem: exige ligar
  `reports` a `messages` (tabela associativa) e expõe uma conversa privada inteira ao BackOffice. Ficou fora por decisão do Daniel.
- **Prints opcionais:** a denúncia sem evidência continuaria chegando à fila, sem como a moderação decidir.
- **Coluna JSON com as URLs em `reports`:** evita a tabela, mas foge do padrão do DER (as fotos do anúncio já usam
  `listing_photos`) e não guarda a ordem nem o soft delete por arquivo.

## Consequências

- O DER passa a 49 tabelas e 86 FKs, com a FK `report_evidences.report_id → reports.id`; o diagrama de classes ganha
  `EvidenciaDenuncia`.
- A rota de denúncia do chat recebe `multipart/form-data`, com o limite de 4 MB por arquivo e no máximo 3 arquivos.
- Um print pode ser montado: a moderação decide olhando o print, o motivo e o histórico do usuário (advertências da
  CCD099).
