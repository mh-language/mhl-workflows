# Wikipedia brief: Model Context Protocol

## Executive summary

The article describes the Model Context Protocol (MCP) as an open standard introduced by Anthropic in November 2024 for connecting AI systems, including large language models, with external tools, systems, and data sources.

According to the article, MCP standardizes tool and resource discovery, execution, and contextual data exchange. It uses a host–client–server model and JSON-RPC 2.0. The article also reports adoption by major AI providers, expansion into interactive interfaces through MCP Apps, governance under the Linux Foundation’s Agentic AI Foundation, and security concerns including prompt injection and data exfiltration.

The interpretation that MCP functions as a common integration layer—sometimes compared with OpenAPI or “USB-C for AI”—is contextual framing rather than a formal definition.

## Key findings

### Origin and purpose

- Anthropic announced MCP in November 2024.
- Engineers David Soria Parra and Justin Spahr-Summers created the protocol at Anthropic.
- Its stated purpose is to reduce information silos and the “N×M” integration problem caused by separate custom connectors.
- MCP reuses message-flow ideas from the Language Server Protocol (LSP).

### Architecture and mechanisms

- An MCP host—typically an AI agent—interacts with an LLM and one or more MCP servers.
- The host creates a dedicated MCP client for each server.
- Servers may be local or remote and can expose:
  - Tools, such as databases, calculators, and code repositories.
  - Resources, such as FAQ documents.
- Clients retrieve descriptions of available capabilities and provide them to the LLM.
- The host directs clients to invoke tools, receives results from servers, and injects those results into the LLM conversation.
- Client–server communication uses JSON-RPC 2.0.
- SDKs were released for languages including Python, TypeScript, C#, and Java.

### Adoption and applications

- The article reports adoption in AI-assisted development tools, IDEs, Replit, and Sourcegraph.
- OpenAI officially adopted MCP in March 2025, including in the ChatGPT desktop app.
- ChatGPT apps gained MCP support in September 2025.
- The article also identifies integrations with Microsoft Semantic Kernel, Azure OpenAI, and Cloudflare deployments.
- MCP Apps extends MCP to interactive interfaces such as dashboards, forms, and data visualizations.

### Governance and scale

- Anthropic donated MCP to the Agentic AI Foundation in December 2025.
- The foundation operates under the Linux Foundation and was co-founded by Anthropic, Block, and OpenAI.
- The article reports that, by mid-2026, more than 10,000 MCP servers were deployed in production and SDK downloads exceeded 97 million per month.

### July 2026 specification revision

- The July 28, 2026 revision removed protocol-level session tracking and made MCP stateless at that layer.
- Request metadata, including protocol version, client identity, and capabilities, is carried in a `_meta` parameter.
- Sampling and roots were deprecated.
- Tasks were moved from the base protocol to optional extensions.
- The article states that some changes are not backward compatible and may require compatibility layers.

### Security and reception

- The article reports security concerns involving prompt injection, poisoned tools, and possible data exfiltration through connected tools.
- The Verge reportedly viewed MCP as addressing demand for context-aware AI agents.
- The article compares MCP conceptually with OpenAPI, while noting that OpenAPI describes APIs rather than providing the same AI-oriented integration framework.

## Timeline or structured facts

| Date | Event |
|---|---|
| November 2024 | Anthropic announces MCP. |
| March 2025 | OpenAI officially adopts MCP, including in the ChatGPT desktop app. |
| April 2025 | Security researchers report outstanding MCP security issues. |
| September 2025 | OpenAI adds MCP support to ChatGPT apps. |
| December 2025 | Anthropic donates MCP to the Agentic AI Foundation. |
| April 2026 | AAIF holds the MCP Dev Summit North America in New York City, with approximately 1,200 attendees reported. |
| July 28, 2026 | Maintainers finalize a major revision making the protocol layer stateless and changing or deprecating several features. |
| Mid-2026 | The article reports more than 10,000 production MCP servers and over 97 million monthly SDK downloads. |

## Context and limitations

- This brief reflects the supplied Wikipedia article and does not independently verify its claims.
- Adoption figures, production deployment counts, SDK download totals, and Salesforce usage figures are reported by the article but their underlying methodology is not provided in the retrieved text.
- The article includes events dated through July 2026; these should be understood as claims made in the supplied article snapshot.
- The retrieved content does not provide complete inline citation details for every claim.
- Wikipedia may change over time, and the article’s accuracy depends on the quality and currency of its references.
- The article does not provide a complete technical specification, implementation guide, or detailed comparison with competing protocols.

## References

- [Wikipedia: Model Context Protocol](https://en.wikipedia.org/wiki/Model_Context_Protocol)

Sources listed in the article but not independently consulted for this brief:

- Hou, Xinyi; Zhao, Yanjie; Wang, Shenao; Wang, Haoyu. “Model Context Protocol (MCP): Landscape, Security Threats, and Future Research Directions.” arXiv:2503.23278.
- Benj Edwards, “MCP: The new ‘USB-C for AI’ that's bringing fierce rivals together,” Ars Technica, April 1, 2025.
- Fiona Jackson, “OpenAI Agents Now Support Rival Anthropic's Protocol, Making Data Access ‘Simpler, More Reliable’,” TechRepublic, March 28, 2025.