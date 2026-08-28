# Readiness Handoff

## Verdict
READY

## Conflicts
_None._

## Residuals
- Versões exatas de SDK, imagem Postgres e biblioteca ainda devem ser fixadas na implementação.
- A API continua sem autenticação e não pode ser exposta externamente; qualquer expansão exige novo refinamento.
- Não há SLA, paginação, backup ou concorrência forte no baseline.

## Slices
### SL-1 — infrastructure
- **Goal:** Disponibilizar Postgres local, esquema e verificação inicial reproduzível.
- **In Scope:** Compose com Postgres, volume e healthcheck, Bootstrap idempotente do esquema, TODO\_DB\_CONNECTION, init.sh e comando agregado
- **Out of Scope:** Endpoints de negócio, Produção, cloud e CI
- **Observable Outcome:** Um ambiente fresco inicia o banco, cria o esquema e fica pronto para testes sem setup manual.
- **Requirements:** RF-6, RF-7
- **ADRs:** ADR-2, ADR-3, ADR-5
- **Depends On:** 
- **Contracts:** Banco saudável antes da API/testes, Schema idempotente, Exit code agregado só passa com duas suítes verdes
- **Happy Path:** Duas execuções de init aguardam healthcheck e completam com sucesso.
- **Failure Path:** Banco indisponível ou conexão inválida interrompe o fluxo sem expor credenciais.
- **Acceptance Criterion:** Fresh database e duas execuções sucessivas demonstram bootstrap, configuração e persistência do esquema.
- **Suggested Target:** Primeiro incremento de infraestrutura local
- **Suggested Verification Strategy:** Teste de healthcheck, banco fresco, override de conexão e duas execuções do agregado.

### SL-2 — task-api
- **Goal:** Entregar o contrato funcional completo de tarefas com slices verticais.
- **In Scope:** Criar, listar/filtrar, concluir, editar e remover, Validação, normalização, estados e Problem Details, SQL parametrizado por slice
- **Out of Scope:** Autenticação, frontend, paginação e múltiplos usuários
- **Observable Outcome:** Consumidor HTTP pode executar todos os fluxos definidos e recebe respostas determinísticas.
- **Requirements:** RF-1, RF-2, RF-3, RF-4, RF-5, RF-8, RQ-3
- **ADRs:** ADR-1, ADR-2, ADR-4, ADR-6
- **Depends On:** SL-1
- **Contracts:** POST/GET/PATCH/PUT/DELETE em /tasks, id/titulo/status, Problem Details e 503 sanitizado
- **Happy Path:** Tarefas são criadas pendentes, consultadas por id, concluídas idempotentemente, editadas sem mudar status e removidas.
- **Failure Path:** Entradas inválidas e ids ausentes não mutam dados; falha do banco retorna 503 sem detalhes internos.
- **Acceptance Criterion:** Testes HTTP cobrem casos válidos, filtros, repetição, erros, ordenação e ausência de mutação indevida.
- **Suggested Target:** Slices verticais de endpoint após infraestrutura
- **Suggested Verification Strategy:** Unit tests para regras e integração HTTP contra Postgres real para cada endpoint.

### SL-3 — quality-resilience
- **Goal:** Provar isolamento, persistência após reinício e proteção de informações.
- **In Scope:** Reset por caso e execução serial, Recriação da API mantendo volume, Inspeção de respostas, headers e logs
- **Out of Scope:** Backup, alta disponibilidade, desempenho e exposição externa
- **Observable Outcome:** Execuções repetidas são determinísticas, a tarefa sobrevive ao restart e falhas permanecem sanitizadas.
- **Requirements:** RQ-1, RQ-2
- **ADRs:** ADR-5, ADR-6
- **Depends On:** SL-2
- **Contracts:** Isolamento determinístico, Persistência com volume retido, Logs sem payload/título/segredo
- **Happy Path:** Criar tarefa, recriar host da API e listar a mesma tarefa; repetir a suíte permanece verde.
- **Failure Path:** Vazamento, contaminação entre testes ou perda inesperada faz a verificação falhar.
- **Acceptance Criterion:** Cenários de restart, repetição, reset, redaction e falha de dependência passam em conjunto.
- **Suggested Target:** Incremento de resiliência e qualidade após os endpoints
- **Suggested Verification Strategy:** Integração serial repetida, inspeção de logs/respostas e teste de API-only restart.

