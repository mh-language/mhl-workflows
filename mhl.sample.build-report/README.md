# Sample: build-report

Exemplo mínimo e didático de MHL: uma `pipeline` com 3 steps, mostrando
`spawn`/`wait` (paralelismo dentro de um step) e `timeout` (de espera e de step).

## Rodar

```bash
mhl lint .
mhl run main.mh --input projeto=checkout-api
mhl run main.mh --resume   # se um step tiver estourado o tempo
```

Não precisa de nenhuma CLI de IA: os agents são processos `sh` e os `sleep`
apenas simulam trabalho.

## O que cada peça ensina

| Peça | Onde | Ideia |
| --- | --- | --- |
| `agent` | topo do arquivo | Um processo que recebe `prompt` e devolve stdout. `.run(prompt:)` chama. |
| `pipeline` | `RelatorioDeBuild` | Steps rodam na ordem declarada; sem `goto`. |
| `input` | `projeto: string` | Argumento da run (`--input projeto=...`). |
| `var` de pipeline | `resumo` | Estado compartilhado: um step escreve, os próximos leem. |
| `spawn` / `wait` | step `Verificacoes` | Dispara 3 chamadas de agent em paralelo e junta os handles. |
| `wait ... timeout: 10s` | step `Verificacoes` | Limita a espera do grupo inteiro. |
| `spawn: { max_concurrency }` | header da pipeline | Teto de agents simultâneos na run. |
| `step X timeout 3s` | step `Publicar` | Orçamento de tempo do passo; ao estourar, o step se auto-encerra e a run fica retomável. |

## Fluxo

```
Preparar ──> Verificacoes ──> Publicar
                 │ spawn l = Lint.run(...)
                 │ spawn t = Testes.run(...)   (paralelo)
                 │ spawn b = Build.run(...)
                 └ wait l, t, b timeout: 10s
```

## Variações úteis

- Tolerar falha em vez de `fail-fast`:
  `wait l, t, b on_error: "collect"` e depois checar `l.ok` / `l.error`.
- Primeiro que terminar: `wait any q1, q2`.
- Fan-out sobre uma lista:
  `spawn xs = Lint.run(prompt: item) for item in ["a", "b", "c"]`.
- Ver o `timeout` de step disparar: troque o corpo de `Publicar` por
  `cmd.exec(["sh", "-c", "sleep 5; echo ok"])` — o step falha mencionando o
  timeout; `--resume` re-entra com orçamento novo.
