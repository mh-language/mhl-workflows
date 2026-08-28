# Product Requirements Document

## Vision
Uma WebAPI local, demonstrativa e reproduzível para uma lista única de tarefas, permitindo gestão por HTTP com persistência real em Postgres, contrato claro, inicialização idempotente e verificação automatizada segura.

## Goals
- **G-1:** Disponibilizar criação, listagem, filtragem, conclusão, edição e remoção de tarefas por HTTP, com validação e erros consistentes.
- **G-2:** Garantir persistência local em Postgres, esquema criado automaticamente e preservação dos dados após reinício somente da API.
- **G-3:** Oferecer um fluxo local idempotente que aguarde o Postgres e execute testes unitários e de integração reais com resultado agregado.
- **G-4:** Manter a solução segura dentro do limite local, com conexão externalizada, operações parametrizadas e respostas sem detalhes internos.

## Success Metrics
- **M-1** (G-1): Cenários de integração cobrindo cada endpoint e seus casos válidos e inválidos sobre HTTP real. → Todos os endpoints e cenários definidos no contrato passam em uma execução completa.
- **M-2** (G-2): Consulta da mesma tarefa depois de reiniciar apenas o host da API mantendo Postgres e volume. → Id, título normalizado e status permanecem equivalentes após o reinício.
- **M-3** (G-3): Execuções consecutivas do script idempotente de inicialização e verificação. → Duas execuções sucessivas, sem intervenção manual, concluem com sucesso quando as duas suítes estão verdes.
- **M-4** (G-4): Inspeção de respostas e logs nos cenários de falha de banco e configuração. → Nenhuma resposta expõe credenciais, connection string, stack trace, mensagem de driver ou payload/título.

## Non-Goals
- Migração, leitura ou compatibilidade com JSON ou dados legados
- Frontend, múltiplos usuários, login, autenticação, autorização e sincronização
- Cloud, produção, CI, Kubernetes, Postgres gerenciado, múltiplos serviços, backup/restore e alta disponibilidade
- Paginação, SLA, metas de desempenho, concorrência forte, lembretes, prioridades, tags e dados regulados
- Exposição externa do serviço ou uso com dados sensíveis

## Scope
- API ASP.NET Core em .NET/C\# com endpoints POST /tasks, GET /tasks com filtro, PATCH /tasks/{id}/complete, PUT /tasks/{id} e DELETE /tasks/{id}
- Tarefa com id gerado pelo Postgres, título normalizado e status pendente/concluída; conclusão idempotente e edição preservando status
- Postgres local em Docker Compose com volume persistente, healthcheck, criação idempotente de esquema e configuração TODO\_DB\_CONNECTION com default local
- Arquitetura Vertical Slice com kernel compartilhado mínimo, testes unitários de regras e integração serial sobre HTTP/Postgres reais
- init.sh e um comando agregado para preparar a infraestrutura, aguardar dependência e executar toda a verificação

## Risks
- **R-1** (medium): Contrato HTTP inconsistente entre slices pode quebrar consumidores e testes. — mitigation: Fixar casing, campos, estados, status codes, Problem Details e ordenação no SRS/SDD e revisar cada slice.
- **R-2** (high): Estado compartilhado pode contaminar testes de integração. — mitigation: Usar limpeza/reset determinístico antes de cada caso, execução serial e testes repetidos.
- **R-3** (high): A API não autenticada pode ser exposta além do ambiente local. — mitigation: Documentar explicitamente o limite local/não produtivo e exigir nova refinamento antes de exposição externa.
- **R-4** (high): Falhas de banco ou títulos podem revelar detalhes internos ou dados sensíveis. — mitigation: Usar configuração por ambiente, parâmetros Npgsql, logs sem payload e Error Boundary com respostas sanitizadas; manter títulos como dados demonstrativos.

## Decisions
- **D-1:** Adotar .NET/C\#, ASP.NET Core, Postgres e Docker Compose local como stack base. — rationale: É a stack obrigatória do escopo aprovado e atende a persistência e verificação local.
- **D-2:** Adotar Vertical Slice Architecture e um kernel compartilhado mínimo, sem camadas genéricas. — rationale: Mantém cada endpoint coeso e evita crescimento acidental de abstrações compartilhadas.
- **D-3:** Usar Postgres real com Npgsql e testes de integração por HTTP, sem mocks ou banco em memória. — rationale: Prova o comportamento de persistência e do contrato no ambiente efetivamente suportado.
- **D-4:** Padronizar Problem Details e 503 para indisponibilidade da dependência. — rationale: Torna falhas previsíveis para o consumidor e evita exposição de detalhes internos.

## Open Questions
_None._
