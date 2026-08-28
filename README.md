# MHL Workflows

![MHL Workflows](assets/repository-open-graph.png)

A collection of workflows written in [MHL](https://github.com/mh-language/mhl-core-runtime) for orchestrating AI agents in reproducible software engineering processes.

The repository keeps pipeline definitions separate from the projects they operate on. Each workflow can bring together its own prompts, agents, tools, persistent memory, and input documents.

## Available workflows

| Workflow | Purpose | Documentation |
| --- | --- | --- |
| `development-workflow` | Converts specifications into a feature plan and coordinates setup, implementation, testing, fixes, replanning, and commits with Codex. | [View documentation](mhl.workflow.development/README.md) |

Currently, `mhl.workflow.development/specs/` contains a complete example for a task-management Web API built with ASP.NET Core and Postgres. These documents are sample inputs and can be replaced with the specifications of the project to be developed.

## Prerequisites

- [MHL CLI](https://github.com/mh-language/mhl-core-runtime) available as `mhl` on the `PATH`;
- [Codex CLI](https://github.com/openai/codex) installed and authenticated;
- Git and Bash;
- tools required by the target project, such as Docker, .NET, Node.js, or Python.

## Installing MHL

The official installer downloads the binary from the [latest MHL release](https://github.com/mh-language/mhl-core-runtime/releases). If VS Code is installed, it also installs the `mhl-language` extension, which provides syntax highlighting, diagnostics, and autocomplete.

### macOS or Linux

```bash
curl -fsSL https://raw.githubusercontent.com/mh-language/mhl-core-runtime/main/install.sh | sh
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/mh-language/mhl-core-runtime/main/install.ps1 | iex
```

The binary is installed in:

- `~/.mhl/bin` on macOS and Linux;
- `%LOCALAPPDATA%\mhl\bin` on Windows.

The installer adds this directory to the `PATH`. Open a new terminal after installation and confirm:

```bash
mhl version
```

The currently supported platforms are `linux-amd64`, `darwin-arm64` (macOS on Apple Silicon), and `windows-amd64`.

### Manual installation

You can also download the binary and the `.vsix` extension directly from the [releases page](https://github.com/mh-language/mhl-core-runtime/releases).

To build the project from source:

```bash
git clone https://github.com/mh-language/mhl-core-runtime.git
cd mhl-core-runtime

# Runtime: generates src/mhl-runtime/dist/mhl
cd src/mhl-runtime
make build

# VS Code extension: generates mhl-language-<version>.vsix
cd ../../vscode-mhl
npm install
npx @vscode/vsce package
```

In VS Code, install the `.vsix` through **Extensions → ⋯ → Install from VSIX...**. Alternatively, run `vscode-mhl/install.sh` from the source root to build and install the extension in a single step.

See the [complete language reference](https://mh-language.github.io/mhl-core-runtime/reference.html) to learn about agents, tools, memory, prompts, MCP servers, and pipelines.

## Verifying the prerequisites

Verify the environment:

```bash
mhl version
codex --version
git --version
```

## Quick start

Clone the repository, enter the desired workflow, and validate the MHL files:

```bash
git clone https://github.com/mh-language/mhl-workflows.git
cd mhl-workflows/mhl.workflow.development
mhl lint .
```

To run the development pipeline:

```bash
mhl run main.mh
```

If a run was interrupted, use the persisted checkpoints:

```bash
mhl run main.mh --resume
```

Before the first run, read the [development workflow README](mhl.workflow.development/README.md). It explains how to prepare the specifications, which files will be generated, and which changes the agent may make.

## Repository structure

```text
.
├── mhl.workflow.development/
│   ├── main.mh              # main pipeline
│   ├── modules/
│   │   ├── agents/          # Codex CLI integration
│   │   ├── prompts/         # instructions for each stage
│   │   └── tools/           # plan, state, tests, and handoff
│   └── specs/
│       ├── active/          # approved specifications for execution
│       └── sources/         # source material used to generate a plan
└── LICENSE
```

## Adding a workflow

Create a dedicated directory with a `main.mh` file, and keep its modules, prompts, and examples alongside it. The workflow must be validatable from its directory with:

```bash
mhl lint .
```

Also include a dedicated README and add the new workflow to the table in this document.

## License

This repository is released under [CC0 1.0 Universal](LICENSE).
