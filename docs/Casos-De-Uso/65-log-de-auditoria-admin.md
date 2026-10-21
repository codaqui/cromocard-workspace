| Nome do Caso de Uso | Log de Auditoria Admin |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador consulte o histórico das ações administrativas realizadas na plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para consultar os registros de auditoria. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Log de Auditoria". |  |
|  | 2. O sistema apresenta os registros de ações administrativas. |
| 3. O administrador aplica filtros de pesquisa, quando necessário. |  |
|  | 4. O sistema processa os filtros informados. |
|  | 5. O sistema apresenta os registros correspondentes. |
| 6. O administrador seleciona um registro. |  |
|  | 7. O sistema apresenta os detalhes da ação registrada. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador realiza uma pesquisa sem resultados. |  |
|  | 2. O sistema informa que nenhum registro foi encontrado. |
| 3. O administrador altera os filtros. |  |
|  | 4. O sistema realiza uma nova pesquisa e apresenta os registros encontrados. |

### Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | O log é somente leitura: nenhum registro pode ser editado ou excluído pela interface ou pela API. |
| RN02 | Cada registro guarda quem fez (`admin_id`), o que fez (`action`), em qual entidade (`entity_type`, `entity_id`), quando (`created_at`) e os detalhes (`details`, com os valores antes e depois quando houver). |
| RN03 | As ações seguem o padrão `ENTIDADE_ACAO` em maiúsculas, por exemplo `USER_SUSPENDED`, `CARD_CREATED`, `SETTINGS_UPDATED`, `EXPORT_REPORT`. |
| RN04 | O registro é gravado na mesma transação da ação auditada: se a ação falhar, não há registro (ADR-034). |
| RN05 | Ordenação padrão: mais recentes primeiro. |

### Critérios de Aceite (MVP)

- [ ] Lista paginada com data e hora, administrador responsável, ação, entidade afetada e resumo.
- [ ] Filtros por administrador responsável, tipo de ação, período (Hoje, 7 dias, 30 dias ou intervalo de datas) e busca pelo id da entidade.
- [ ] Ao selecionar um registro, mostra os detalhes completos (`details`).
- [ ] As ações dos CCD059, CCD061 e CCD066 aparecem no log com os códigos da RN03.
- [ ] Não existe rota de edição ou exclusão de registros (RN01).

### Fora do Escopo do MVP

Botão "Extrair Logs" (exportação em CSV), que entra junto com o CCD063 se houver tempo.

### Referências

- Figma: `administração - logs do sistema`
- DER: `audit_logs` · ADR-034 (trilha de auditoria)
