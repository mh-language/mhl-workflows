# MHL Workflows

![MHL Workflows](assets/repository-open-graph.png)

Coleção de workflows escritos em [MHL](https://github.com/mh-language/mhl-core-runtime) para orquestrar agentes de IA em processos de engenharia de software reproduzíveis.

O repositório mantém a definição dos pipelines separada dos projetos em que eles atuam. Cada workflow pode reunir prompts, agentes, ferramentas, memória persistente e documentos de entrada próprios.

## Workflows disponíveis

| Workflow | Finalidade | Documentação |
| --- | --- | --- |
| `development-workflow` | Converte especificações em um plano de features e coordena preparação, implementação, testes, correções, replanejamento e commits com o Codex. | [Ver documentação](development-workflow/README.md) |

Atualmente, `development-workflow/specs/` contém um exemplo completo para uma WebAPI de tarefas em ASP.NET Core e Postgres. Esses documentos são entradas demonstrativas e podem ser substituídos pelas especificações do projeto que será desenvolvido.

## Pré-requisitos

- [MHL CLI](https://github.com/mh-language/mhl-core-runtime) disponível como `mhl` no `PATH`;
- [Codex CLI](https://github.com/openai/codex) instalado e autenticado;
- Git e Bash;
- ferramentas exigidas pelo projeto-alvo, como Docker, .NET, Node.js ou Python.

## Instalando o MHL

O instalador oficial baixa o binário da [versão mais recente do MHL](https://github.com/mh-language/mhl-core-runtime/releases). Se o VS Code estiver instalado, ele também instala a extensão `mhl-language`, com destaque de sintaxe, diagnósticos e autocompletar.

### macOS ou Linux

```bash
curl -fsSL https://raw.githubusercontent.com/mh-language/mhl-core-runtime/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/mh-language/mhl-core-runtime/main/install.ps1 | iex
```

O binário é instalado em:

- `~/.mhl/bin` no macOS e Linux;
- `%LOCALAPPDATA%\mhl\bin` no Windows.

O instalador adiciona esse diretório ao `PATH`. Abra um novo terminal após a instalação e confirme:

```bash
mhl version
```

As plataformas atualmente suportadas são `linux-amd64`, `darwin-arm64` (macOS com Apple Silicon) e `windows-amd64`.

### Instalação manual

Também é possível baixar o binário e a extensão `.vsix` diretamente na [página de releases](https://github.com/mh-language/mhl-core-runtime/releases).

Para compilar o projeto a partir do código-fonte:

```bash
git clone https://github.com/mh-language/mhl-core-runtime.git
cd mhl-core-runtime

# Runtime: gera src/mhl-runtime/dist/mhl
cd src/mhl-runtime
make build

# Extensão do VS Code: gera mhl-language-<versão>.vsix
cd ../../vscode-mhl
npm install
npx @vscode/vsce package
```

No VS Code, instale o `.vsix` por **Extensions → ⋯ → Install from VSIX...**. Como alternativa, execute `vscode-mhl/install.sh` a partir da raiz do código-fonte para compilar e instalar a extensão em uma única etapa.

Consulte a [referência completa da linguagem](https://mh-language.github.io/mhl-core-runtime/reference.html) para conhecer agentes, ferramentas, memória, prompts, servidores MCP e pipelines.

## Verificando os pré-requisitos

Confirme o ambiente:

```bash
mhl version
codex --version
git --version
```

## Início rápido

Clone o repositório, entre no workflow desejado e valide os arquivos MHL:

```bash
git clone https://github.com/mh-language/mhl-workflows.git
cd mhl-workflows/development-workflow
mhl lint .
```

Para executar o pipeline de desenvolvimento:

```bash
mhl run main.mh
```

Caso uma execução tenha sido interrompida, use os checkpoints persistidos:

```bash
mhl run main.mh --resume
```

Antes da primeira execução, leia o [README do development workflow](development-workflow/README.md). Ele explica como preparar as especificações, quais arquivos serão gerados e quais alterações o agente poderá realizar.

## Estrutura do repositório

```text
.
├── development-workflow/
│   ├── main.mh              # pipeline principal
│   ├── modules/
│   │   ├── agents/          # integração com o Codex CLI
│   │   ├── prompts/         # instruções de cada etapa
│   │   └── tools/           # plano, estado, testes e handoff
│   └── specs/
│       ├── active/          # especificações aprovadas para execução
│       └── sources/         # material-fonte para gerar um plano
└── LICENSE
```

## Adicionando um workflow

Crie um diretório próprio com um `main.mh` e mantenha seus módulos, prompts e exemplos junto dele. O workflow deve poder ser validado a partir de seu diretório com:

```bash
mhl lint .
```

Inclua também um README específico e adicione o novo workflow à tabela deste documento.

## Licença

Este repositório é disponibilizado sob [CC0 1.0 Universal](LICENSE).
