# Wikipedia Research Workflow

An MHL pipeline that retrieves a Wikipedia article through the
`mcp/wikipedia-mcp` Docker server and asks Codex to produce a concise,
structured Markdown brief.

## How it works

```text
title
  ↓
GetArticle  ── Wikipedia MCP / get_article
  ↓
research.json  ── persisted query and article response
  ↓
Synthesize  ── Codex research agent
  ↓
wikipedia-report.md
```

The research agent also has access to the same Wikipedia MCP server for
focused follow-up lookups when the retrieved article needs additional
context.

## Requirements

- MHL CLI `v0.4.2-alpha` or newer;
- Docker running and reachable by the current user;
- the `mcp/wikipedia-mcp` image;
- Codex CLI installed and authenticated;
- network access for the Wikipedia server and Codex.

Python is not required by this workflow. The MCP server is started directly
by MHL with Docker.

Pull the image before the first run:

```bash
docker pull mcp/wikipedia-mcp
```

## MCP configuration

The server is declared in [`main.mh`](main.mh) with the legacy MCP handshake
protocol currently supported by the Docker image:

```mh
mcp_server wikipedia {
    transport: "stdio"
    protocol: "2025-06-18"
    command: "docker"
    args: ["run", "-i", "--rm", "mcp/wikipedia-mcp"]
}
```

The explicit `protocol` setting is intentional. It prevents the runtime from
trying the newer stateless protocol before connecting to this server.

## Run

From this directory:

```bash
mhl version
mhl lint .
mhl run main.mh --input title="Model Context Protocol"
```

Replace the title with the Wikipedia article to research. The input is a
single string named `title`.

## Outputs

After a successful run:

- `wikipedia-report.md` contains the generated brief;
- `.mhl/research.json` stores the latest query, raw article response, and
  generated report;
- `.mhl/logs/researcher.log` stores the raw Codex event stream used to
  diagnose synthesis failures.

The pipeline does not currently declare MHL checkpoints. To research another
article, run it again with a new `title`.

## Troubleshooting

### MCP handshake failure

Confirm that Docker is running and that the image starts independently:

```bash
docker run --rm mcp/wikipedia-mcp --help
```

The current image requires a non-empty `clientInfo.version` during the MCP
handshake. If `GetArticle` fails with `Invalid request parameters`, the MHL
runtime must send that field; changing the workflow protocol alone does not
remove this requirement.

### Codex does not return a report

Check Codex authentication and inspect:

```text
.mhl/logs/researcher.log
```

The report file is updated only after both `GetArticle` and `Synthesize`
complete successfully.

## Source files

```text
mhl.workflow.wikipedia-research/
├── main.mh
├── modules/
│   ├── agents/researcher.agent.mh
│   ├── prompts/research.prompt.md
│   └── tools/research.tool.mh
└── README.md
```
