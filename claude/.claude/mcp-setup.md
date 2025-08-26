# MCP Server Setup Commands

These commands will install all MCP servers in user scope for Claude Code.

## Installation Commands

```bash
# Zen MCP Server (with Gemini API)
claude mcp add-json zen '{"type":"stdio","command":"sh","args":["-c","exec $(which uvx || echo uvx) --from git+https://github.com/BeehiveInnovations/zen-mcp-server.git zen-mcp-server"],"env":{"GEMINI_API_KEY":"YOUR_GEMINI_API_KEY"}}' --scope user

# Serena MCP Server
claude mcp add-json serena '{"type":"stdio","command":"$HOME/.local/bin/uvx","args":["--from","git+https://github.com/oraios/serena","serena","start-mcp-server","--enable-web-dashboard","False"]}' --scope user

# Playwright MCP Server
claude mcp add-json playwright '{"type":"stdio","command":"npx","args":["@playwright/mcp@latest"]}' --scope user

# Context7 MCP Server
claude mcp add-json Context7 '{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp"]}' --scope user

# Maestro MCP Server
claude mcp add-json maestro '{"type":"stdio","command":"maestro","args":["mcp"]}' --scope user
```

## Server Descriptions

- **zen**: Multi-model AI analysis and debugging tools
- **serena**: Code analysis and semantic understanding
- **playwright**: Browser automation and testing
- **Context7**: Library documentation and code examples
- **maestro**: Mobile app testing and automation

## Notes

- All servers are configured for user scope (available across all projects)
- The Serena command uses `$HOME` for cross-platform compatibility
- Zen server includes Gemini API key for enhanced functionality