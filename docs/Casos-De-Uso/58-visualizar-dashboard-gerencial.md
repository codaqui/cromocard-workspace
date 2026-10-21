| Nome do Caso de Uso | Visualizar Dashboard Gerencial |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador visualize informações gerenciais na plataforma, facilitando o acompanhamento dos principais indicadores e dados do sistema |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para acessar o dashboard gerencial. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Dashboard Gerencial". |  |
|  | 2. O sistema carrega os dados gerenciais disponíveis. |
|  | 3. O sistema apresenta os principais indicadores e informações da plataforma. |
| 4. O administrador visualiza os indicadores apresentados. |  |
| 5. O administrador seleciona um período ou filtro, quando disponível. |  |
|  | 6. O sistema processa o filtro selecionado. |
|  | 7. O sistema atualiza os indicadores e informações conforme os filtros aplicados. |
| 8. O administrador consulta os dados apresentados no dashboard. |  |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o dashboard e não existem dados disponíveis. |  |
|  | 2. O sistema informa que não existem dados para apresentação. |
| 3. O administrador seleciona um período ou filtro sem informações disponíveis. |  |
|  | 4. O sistema informa que não foram encontrados dados para os filtros selecionados. |
| 5. O administrador altera os filtros de consulta. |  |
|  | 6. O sistema atualiza o dashboard com os dados correspondentes aos novos filtros. |

### Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | Os indicadores consideram apenas registros não excluídos (`deleted_at` nulo). |
| RN02 | Os períodos disponíveis são: Hoje, Últimos 7 dias, Últimos 30 dias e Último ano. O padrão é Últimos 30 dias. |
| RN03 | Os indicadores de total (usuários, cartas, álbuns) mostram o valor atual; os indicadores de "novos" contam os registros criados dentro do período. |

### Critérios de Aceite (MVP)

- [ ] Exibe o total de usuários, separado por papel (Cliente, Vendedor, Administrador).
- [ ] Exibe os novos cadastros de usuários no período selecionado.
- [ ] Exibe o total de cartas e de álbuns do catálogo.
- [ ] Exibe a quantidade de solicitações de catálogo pendentes (fica zerado até o CCD064 existir).
- [ ] O filtro de período (RN02) atualiza os indicadores sem recarregar a página.
- [ ] Sem dados no período, mostra a mensagem do fluxo alternativo em vez de gráficos vazios.
- [ ] Rota acessível apenas para `role = ADMIN`; outros papéis recebem `403`.

### Fora do Escopo do MVP

Indicadores financeiros e de marketplace (custódia, volume em R$, leilões), meta mensal,
cadastros de lojistas aguardando auditoria e o botão "Exportar Dados" (ver CCD063). Decisão no ADR-038.

### Referências

- Figma: `Administração - dashboard geral` e `Administração - dashboard geral - filtro de 7 dias`
