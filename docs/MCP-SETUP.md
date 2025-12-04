# MCP Server Setup Guide

Comprehensive setup instructions for MCP servers across different AI development environments.

## Claude Code Installation

### Core MCP Servers

```bash
# Context7 MCP Server (Library documentation)
claude mcp add-json Context7 '{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp"]}' --scope user
```

### Optional MCP Servers (Add as needed)

```bash
# Zen MCP Server (Multi-model AI analysis with optimized tools)
claude mcp add-json zen '{"type":"stdio","command":"sh","args":["-c","exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"],"env":{"GEMINI_API_KEY":"YOUR_GEMINI_API_KEY","DISABLED_TOOLS":"analyze,refactor,testgen,secaudit,docgen,thinkdeep,planner,consensus"}}' --scope user

# Serena MCP Server (Semantic code analysis)
claude mcp add-json serena '{"type":"stdio","command":"sh","args":["-c","exec $(which uvx || echo uvx) --from git+https://github.com/oraios/serena serena start-mcp-server --enable-web-dashboard False"]}' --scope user

# Playwright MCP Server (Browser automation)
claude mcp add-json playwright '{"type":"stdio","command":"npx","args":["@playwright/mcp@latest"]}' --scope user

# Maestro MCP Server (Mobile app testing)
claude mcp add-json maestro '{"type":"stdio","command":"maestro","args":["mcp"]}' --scope user
```

## Qwen Code Configuration

Add to your `qwen/.qwen/settings.json` file:

```json
{
  "selectedAuthType": "qwen-oauth",
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "timeout": 30000,
      "trust": false
    }
  }
}
```

**Optional additions**: Zen and Serena MCP servers can be added using the commands above when you need their advanced capabilities. Qwen does not support Serena MCP due to architectural differences, so rely on native tools for semantic exploration.

## OpenCode Configuration

Add to your `opencode.jsonc` file:

```jsonc
{
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true,
      "environment": {}
    },
    }
  }
}
```

To enable Zen or Serena in OpenCode, copy the relevant `mcp` block from the optional commands above into your configuration when needed.

## Environment Setup

### API Keys

**Qwen Code**: Create a `.env` file in your `qwen/.qwen/` directory:

```bash
# Qwen Code Environment Variables
GEMINI_API_KEY=your-gemini-api-key-here
```

**OpenCode**: Create a `.env` file in your OpenCode configuration directory:

```bash
# OpenCode Environment Variables
GEMINI_API_KEY=your-gemini-api-key-here
```

### Prerequisites

```bash
# Install uvx (Python package runner)
pip install --user uv

# Verify uvx is available
which uvx || echo "Add ~/.local/bin to your PATH"
```

## MCP Server Descriptions

### Core Servers

- **Context7**: Up-to-date library documentation and examples
  - Tools: Library resolution, documentation retrieval
  - Coverage: Popular frameworks, APIs, and development tools

### Optional Servers

- **Zen**: Multi-model AI analysis, debugging, code review, and systematic problem-solving
  - Tools: `chat`, `codereview`, `debug`, `tracer`, `precommit`
  - Model: Gemini 2.5 Pro with thinking mode
  - Optimized: Disabled unnecessary tools for token efficiency

- **Serena**: Semantic code analysis and intelligent navigation
  - Tools: Symbol search, reference finding, code editing, memory management
  - Features: Project onboarding, architectural understanding

- **Playwright**: Browser automation and end-to-end testing
- **Maestro**: Mobile app testing and automation

## Configuration Notes

### Portability
- Commands use `$(which uvx || echo uvx)` for cross-system compatibility
- Environment variables used for sensitive data (API keys)
- No hard-coded home directory paths

### Security
- API keys stored in environment variables or `.env` files
- `.env` files excluded from version control
- User-scoped installations for isolation

### Performance
- Optional Zen tools can be configured to disable unused functionality
- Optional Serena web dashboard can remain disabled for faster startup
- Context7 uses `-y` flag for non-interactive installation
