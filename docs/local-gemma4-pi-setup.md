# Local Gemma 4 12B with llama.cpp and Pi

This setup runs Gemma locally through `llama-server` and uses Pi as the coding agent.

## Start llama-server

Use this command for Pi thinking-level toggle support:

```bash
llama-server \
  -hf google/gemma-4-12B-it-qat-q4_0-gguf:Q4_0 \
  --alias gemma \
  -c 8192 \
  --parallel 1 \
  --no-context-shift
```

Do not add `--reasoning off` or `--reasoning-budget ...` if you want Pi to toggle thinking per request.

## Verify Server

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma",
    "messages": [
      { "role": "user", "content": "Say hello in one sentence." }
    ],
    "temperature": 0.7,
    "thinking_budget_tokens": 0
  }'
```

## Run Pi

Basic local Pi session:

```bash
pi --model llama.cpp/gemma
```

Lower-context coding session:

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --tools read,bash,edit,write,grep,find,ls
```

Clean chat/image test with no tools or saved session:

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --no-tools \
  --no-session
```

## Thinking Toggle

The Pi extension at `pi/.pi/agent/extensions/llama-thinking-budget.ts` maps Pi thinking levels to llama.cpp `thinking_budget_tokens`.

```bash
pi --model llama.cpp/gemma --thinking off
pi --model llama.cpp/gemma --thinking low
pi --model llama.cpp/gemma --thinking high
```

Inside Pi:

```text
/llama-thinking off
/llama-thinking low
/llama-thinking high
```

Budget mapping:

```text
off     -> 0
minimal -> 64
low     -> 128
medium  -> 256
high    -> 512
xhigh   -> 1024
```

Use `off` or `low` for normal work on an 8K context. Use `high` only when the task really needs deeper reasoning.

## Tools

Pi built-in tools:

```text
read
bash
edit
write
```

Useful read-only tools that are off unless explicitly enabled:

```text
grep
find
ls
```

Safe read-only mode:

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --tools read,grep,find,ls
```

Full local coding mode:

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --tools read,bash,edit,write,grep,find,ls
```

## Images

Pi supports image attachments with `@file`.

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --no-tools \
  @~/Downloads/screenshot.png \
  "Describe this image."
```

Interactive Pi:

```text
@/Users/Y_ALTAY1/Downloads/screenshot.png what is shown here?
```

The model is multimodal only if llama.cpp loaded the `mmproj` file. The server log should mention:

```text
mmproj-gemma-4-12b-it-qat-q4_0.gguf
```

## Internet Access

`--offline` only disables Pi startup network checks. It does not block `bash`, and it does not automatically provide web-search tools.

Current simple option: allow `bash` and ask Pi to use `curl` for direct URLs.

For proper `web_search` and `web_fetch` tools, install an existing Pi package such as:

```bash
pi install npm:@juicesharp/rpiv-web-tools
```

Then restart Pi and configure it with:

```text
/web-tools
```

That package supports Brave, Tavily, Serper, Exa, You.com, Jina, Firecrawl, Perplexity, SearXNG, and Ollama-backed web tools.

## Common Problems

### Pi sends huge prompts for "hello"

Pi may load project context, tools, skills, prompt templates, or session history. For a minimal test use:

```bash
pi --model llama.cpp/gemma \
  --offline \
  --no-context-files \
  --no-skills \
  --no-prompt-templates \
  --no-tools \
  --no-session \
  --system-prompt "You are concise." \
  -p "hello"
```

### Context Error

If you see:

```text
request exceeds the available context size (8192 tokens)
```

use fewer tools, disable context files, start a fresh session, or increase llama-server context if memory allows.

### Slow Responses

Look for this in llama-server logs:

```text
forcing full prompt re-processing
```

That means llama.cpp had to reprocess the prompt instead of using cache. Keep prompts smaller, use fewer tools, start fresh sessions, and keep thinking low/off.

### Stop Processes

Stop Pi:

```text
Ctrl+C
```
or:

```text
/exit
```

Stop llama-server:

```text
Ctrl+C
```
