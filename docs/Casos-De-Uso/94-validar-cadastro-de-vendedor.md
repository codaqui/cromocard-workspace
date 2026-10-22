| Nome do Caso de Uso | Validar Cadastro de Vendedor |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador analise os dados e os documentos enviados por um vendedor e aprove ou reprove o credenciamento dele na plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e existir pelo menos um cadastro de vendedor aguardando análise. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a lista "Cadastros dos Vendedores Recentes" no Dashboard. |  |
|  | 2. O sistema apresenta os cadastros de vendedores com nome, e-mail, CNPJ ou CPF, status da análise (Em análise, Pendente, Aprovado) e a quantidade de cadastros pendentes. |
| 3. O administrador filtra a lista por status, quando necessário, ou usa o atalho "Analisar Fila", que abre a lista filtrada nos pendentes. |  |
|  | 4. O sistema atualiza a lista conforme o filtro. |
| 5. O administrador seleciona a opção "Validar Cadastro" de um vendedor em análise. |  |
|  | 6. O sistema apresenta o dossiê do vendedor: dados da empresa (razão social, nome fantasia, CNPJ, inscrição estadual, data de abertura, porte e CNAE), responsável legal (nome, CPF, e-mail e telefone), dados bancários e chave Pix, endereço comercial e documentos enviados (cartão CNPJ e comprovante de endereço). |
| 7. O administrador visualiza cada documento enviado e marca o documento como validado. |  |
|  | 8. O sistema registra a validação do documento. |
| 9. O administrador registra uma anotação interna sobre o cadastro, quando necessário. |  |
|  | 10. O sistema grava a anotação com o autor e a data, sem exibi-la ao vendedor. |
| 11. O administrador seleciona a opção "Validar Lojista". |  |
|  | 12. O sistema muda o status do cadastro para Aprovado e o vendedor passa a contar como lojista certificado; as restrições de venda para quem não foi aprovado entram com o marketplace. |
|  | 13. O sistema registra a ação no log de auditoria. |
|  | 14. O sistema informa que o cadastro foi aprovado. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona a opção "Rejeitar". |  |
|  | 2. O sistema solicita o motivo da reprovação. |
| 3. O administrador informa o motivo e confirma. |  |
|  | 4. O sistema muda o status do cadastro para Reprovado, registra a ação no log de auditoria e avisa o vendedor. |
| 5. O administrador encontra uma pendência nos dados ou nos documentos. |  |
|  | 6. O sistema oferece a opção "Notificar Pendência" (Notificar Pendência Cadastral). |
| 7. O administrador fecha o dossiê sem decidir. |  |
|  | 8. O sistema mantém o cadastro com o status atual e volta para a lista. |
