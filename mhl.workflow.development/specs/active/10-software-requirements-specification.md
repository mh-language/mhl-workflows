# Software Requirements Specification

## Functional Requirements
- **RF-1** [G-1]: Criar tarefa normalizada e pendente.
- **RF-2** [G-1]: Listar e filtrar tarefas ordenadas por id.
- **RF-3** [G-1]: Concluir tarefa de forma idempotente.
- **RF-4** [G-1]: Editar título preservando status.
- **RF-5** [G-1]: Remover tarefa existente.
- **RF-6** [G-2, G-3]: Inicializar esquema Postgres e preservar dados após reinício da API.
- **RF-7** [G-3]: Fornecer Compose, configuração, init idempotente e comando agregado de testes.
- **RF-8** [G-4]: Validar antes de mutar, parametrizar SQL e sanitizar indisponibilidade.

## Quality Requirements
- **RQ-1** [G-3]: Integração usa HTTP/Postgres reais, serialização e isolamento por caso.
- **RQ-2** [G-4]: Respostas e logs não expõem segredos, detalhes internos ou títulos.
- **RQ-3** [G-1, G-2]: Cada endpoint permanece em seu vertical slice e o kernel é mínimo.

## Acceptance Criteria
- **AC-1** (RF-1) — Given Banco vazio e título válido, When POST /tasks é enviado, Then Retorna 201, Location, título normalizado e status pendente.
- **AC-2** (RF-2) — Given Há tarefas em ambos os estados, When GET /tasks é chamado, Then Retorna conjuntos corretos ordenados; filtro inválido retorna 400.
- **AC-3** (RF-3) — Given Existe tarefa e id inexistente, When Complete é repetido, Then A tarefa fica concluída com 200 e o inexistente retorna 404.
- **AC-4** (RF-4) — Given Existe tarefa, When PUT envia título válido e inválido, Then Título válido muda preservando status; inválido não altera.
- **AC-5** (RF-5) — Given Existe tarefa, When DELETE é enviado, Then Retorna 204 e remove; id inexistente retorna 404.
- **AC-6** (RF-6) — Given Postgres fresco, When API inicia e reinicia mantendo volume, Then Esquema é criado e tarefa permanece.
- **AC-7** (RF-7) — Given Ambiente local, When init é executado duas vezes, Then É idempotente e só passa com as duas suítes verdes.
- **AC-8** (RF-8) — Given Entrada inválida ou banco indisponível, When Operação é executada, Then Não há mutação indevida e falha retorna Problem Details 503 sanitizado.
- **AC-9** (RQ-1) — Given Suíte repetida, When Cada caso executa, Then Usa HTTP/Postgres reais, serial e sem vazamento.
- **AC-10** (RQ-2) — Given Falha de banco, When Resposta e logs são inspecionados, Then Não contêm segredos, stack trace, driver, payload ou título.
- **AC-11** (RQ-3) — Given Estrutura é revisada, When Slices são inspecionados, Then Cada endpoint está isolado sem camadas genéricas.

## Interfaces
- **IF-1** (RF-1, RF-2, RF-3, RF-4, RF-5) Task HTTP API: Interface HTTP/JSON para operações de tarefas.
- **IF-2** (RF-6, RF-7, RF-8) Database configuration: Interface de configuração da conexão por ambiente.

## Data Rules
- **DR-1** (RF-1, RF-2, RF-3, RF-4, RF-5): Id gerado; título obrigatório e trimado; status pendente/concluída; conclusão idempotente.
- **DR-2** (RF-6, RF-8): Esquema idempotente e SQL parametrizado; validação precede mutação.

## Delivery
- **Target:** WebAPI ASP.NET Core local com Postgres Compose e testes
- **Verification Strategy:** Executar init repetido e validar contrato, regras, persistência, isolamento e sanitização.
- **Bootstrap:** yes
