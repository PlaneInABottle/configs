---
name: crawl4ai
description: Comprehensive guide for Crawl4AI - open-source LLM-friendly web crawler and scraper. Covers CLI commands, Python API, Docker, deep crawling, extraction, content filtering, and advanced features.
---

# Crawl4AI - Open Source Web Crawler

> **Full CLI docs:** [docs.crawl4ai.com/core/cli/](https://docs.crawl4ai.com/core/cli/)  
> **Ready-to-use scripts:** See [`scripts/`](scripts/) folder  
> **Detailed SDK reference:** See [`references/`](references/) folder

Crawl4AI is an open-source (Apache 2.0), LLM-friendly web crawler that transforms websites into clean Markdown or structured JSON. 62k+ GitHub stars.

---

## Installation

```bash
pip install -U crawl4ai
crawl4ai-setup
crawl4ai-doctor

# Or install with pipx for CLI usage
pipx install crawl4ai

# Docker service (optional)
# Use specific version - 0.8.5 is stable
docker pull unclecode/crawl4ai:0.8.5
docker run -d -p 11235:11235 --name crawl4ai --shm-size=1g unclecode/crawl4ai:0.8.5
```

**Docker endpoints:** Dashboard `http://localhost:11235/dashboard` · Playground `http://localhost:11235/playground` · API `http://localhost:11235/crawl`

### Default Choice

Use the interface that matches the job:

| Situation | Default |
|-----------|---------|
| Agent automation, custom scripts, extraction pipelines | **Python SDK** |
| Quick ad-hoc scrape from terminal | **CLI** |
| Shared service, remote access, dashboard, batch API | **Docker API** |

**Recommended default:** prefer the **Python SDK** when you are building repeatable automation or agent workflows. It gives more control than the CLI and avoids the operational overhead of Docker.

### Python Import Caveat

If Crawl4AI was installed with `pipx`, plain `python3` usually will **not** import `crawl4ai`.

```bash
# CLI still works
crwl https://example.com

# But python3 may not see the package
python3 -c "import crawl4ai"

# Use the pipx interpreter instead
~/.local/pipx/venvs/crawl4ai/bin/python your_script.py
```

---

## Ready-to-Use Scripts

The [`scripts/`](scripts/) folder contains ready-to-use Python scripts:

| Script | Usage |
|--------|-------|
| [`basic_crawler.py`](scripts/basic_crawler.py) | Simple markdown extraction |
| [`batch_crawler.py`](scripts/batch_crawler.py) | Batch process multiple URLs |
| [`extraction_pipeline.py`](scripts/extraction_pipeline.py) | Data extraction with auto-schema generation |

```bash
# Run scripts
python scripts/basic_crawler.py https://example.com
python scripts/batch_crawler.py urls.txt
python scripts/extraction_pipeline.py --generate-schema https://shop.com "extract products"
```

---

## Docker API Features

The Docker API provides advanced capabilities beyond the CLI:

| Feature | Description |
|---------|-------------|
| **Batch processing** | Crawl 100s of URLs in a single request |
| **Async queue** | Submit job, get task ID, check results later |
| **Dashboard UI** | Visual monitoring at http://localhost:11235 |
| **Remote deployment** | Run on server, access via API |
| **Priority queuing** | Set priority for important jobs first |
| **Better scaling** | Multiple containers, load balancing |
| **Centralized caching** | Shared cache across requests |

### Docker API Endpoints

```bash
# Health check
curl http://localhost:11235/health

# Submit crawl job
curl -X POST http://localhost:11235/crawl \
  -H "Content-Type: application/json" \
  -d '{"urls": ["https://example.com"], "priority": 10}'

# Get task status (if async)
curl http://localhost:11235/crawl/{task_id}

# Batch crawl multiple URLs
curl -X POST http://localhost:11235/crawl \
  -H "Content-Type: application/json" \
  -d '{
    "urls": [
      "https://altin.doviz.com/gram-altin",
      "https://kur.doviz.com/serbest-piyasa/amerikan-dolari"
    ]
  }'
```

### When to Use Docker vs CLI

| Use Case | Best Choice |
|----------|-------------|
| Quick one-off scrape | CLI (`crwl`) |
| Production monitoring | Docker API |
| Batch URLs (100s) | Docker API |
| Local dev/testing | CLI |
| Schedule recurring jobs | Docker API |
| LLM extraction with schema | Docker API |

---

## Quick CLI Reference

```bash
# Basic crawl
crwl https://example.com

# Output formats: all, json, markdown, md-fit (markdown-fit)
crwl https://example.com -o json
crwl https://example.com -o markdown-fit

# Output to file
crwl https://example.com -o json -O output.json

# Bypass cache (force fresh crawl)
crwl https://example.com -bc

# Deep crawl: bfs, dfs, best-first
crwl https://docs.site.com --deep-crawl bfs --max-pages 10

# LLM Q&A - ask questions about page content
crwl https://example.com -q "What is the main topic?"

# LLM extraction - extract structured data with AI
crwl https://example.com -j "extract all prices and dates"

# JSON schema extraction - extract with CSS selectors
crwl https://example.com -s schema.json -o json

# With config files
crwl https://example.com -B browser.yml -C crawler.yml

# Browser parameters inline
crwl https://example.com -b "headless=true,timeout=30000"

# Crawler parameters (user-agent, etc.)
crwl https://example.com -c "user_agent_mode=random"

# Anti-bot bypass for protected sites (Reddit, etc.)
crwl https://www.reddit.com/r/politics/hot/ -o markdown -c "user_agent_mode=random"
```

---

## Python API

**Use this as the default programmable interface.** It worked in session for both normal pages and protected Reddit URLs/search pages when using `user_agent_mode="random"`.

### Basic Usage

```python
import asyncio
from crawl4ai import AsyncWebCrawler

async def main():
    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(url="https://example.com")
        print(result.markdown)

asyncio.run(main())
```

### With Configuration

```python
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, CacheMode

config = BrowserConfig(headless=True, user_agent_mode="random")
run_cfg = CrawlerRunConfig(
    cache_mode=CacheMode.BYPASS,
    wait_until="networkidle",
    word_count_threshold=100
)

async with AsyncWebCrawler(config=config) as crawler:
    result = await crawler.arun(url="https://example.com", config=run_cfg)
```

### Recommended Default Pattern

```python
import asyncio
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig

async def main():
    browser = BrowserConfig(headless=True, user_agent_mode="random")
    run_cfg = CrawlerRunConfig(wait_until="networkidle")

    async with AsyncWebCrawler(config=browser) as crawler:
        result = await crawler.arun(
            url="https://www.reddit.com/search/?q=gold%20price%20drop&sort=relevance",
            config=run_cfg,
        )
        print(result.success)
        print(result.metadata.get("title"))
        print(result.markdown[:1000])

asyncio.run(main())
```

Use this pattern first, then add extraction, proxies, hooks, or deep crawling as needed.

### CrawlResult Properties

| Property | Description |
|----------|-------------|
| `url` | Crawled URL |
| `markdown` | Clean markdown content |
| `html` | Raw HTML |
| `success` | Boolean success status |
| `links` | Internal/external links dict |
| `metadata` | Page metadata |
| `extracted_content` | Structured data (if extraction enabled) |

---

## Deep Crawling

For detailed deep crawling documentation, see [`references/deep-crawling.md`](references/deep-crawling.md).

### Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| `BFSDeepCrawlStrategy` | Breadth-first (level by level) | Comprehensive coverage |
| `DFSDeepCrawlStrategy` | Depth-first (follows one path) | Documentation sites |
| `BestFirstCrawlingStrategy` | Priority-based with scorers | Focused relevance |

See [`references/deep-crawling.md`](references/deep-crawling.md) for streaming, filtering, crash recovery, and prefetch mode.

---

## Extraction Strategies

For detailed extraction docs, see [`references/extraction.md`](references/extraction.md).

| Strategy | Use Case |
|----------|----------|
| **CSS-based** | Fast, no AI needed - define JSON schema |
| **LLM-based** | Complex pages, AI extracts structured data |

```python
# CSS extraction example
schema = {"name": "Products", "baseSelector": ".product", 
    "fields": [{"name": "title", "selector": "h3", "type": "text"}]}
config = CrawlerRunConfig(extraction_strategy=JsonCssExtractionStrategy(schema))
```

---

## Advanced Features

For complete advanced features (proxy, session, hooks, anti-bot), see [`references/config.md`](references/config.md).

### Proxy Configuration

```python
from crawl4ai.async_configs import ProxyConfig

config = CrawlerRunConfig(
    proxy_config=[
        ProxyConfig.DIRECT,
        ProxyConfig(server="http://proxy:8080", username="user", password="pass"),
    ],
    max_retries=2
)
```

### Session Management

```python
browser_config = BrowserConfig(
    user_data_dir="/path/to/profile",
    use_persistent_context=True
)
```

### Page Interaction (JavaScript)

```python
config = CrawlerRunConfig(
    js_code=["(async () => { await document.querySelector('button').click(); })()"],
    wait_until="networkidle"
)
```

### Hooks

```python
async def on_page_created(page, context, **kwargs):
    await context.route("**/*.png", lambda r: r.abort())
    return page

config = CrawlerRunConfig(hooks={"on_page_context_created": on_page_created})
```

### Anti-Bot (v0.8.5+)

```python
config = CrawlerRunConfig(
    proxy_config=[ProxyConfig.DIRECT, ProxyConfig(server="http://residential-proxy:8080")],
    max_retries=2,
    flatten_shadow_dom=True
)
```

---

## Docker API

```python
import requests

# Single URL crawl
resp = requests.post("http://localhost:11235/crawl", json={
    "urls": ["https://example.com"],
    "priority": 10
})
result = resp.json()

# Batch multiple URLs (recommended for parallel crawling)
resp = requests.post("http://localhost:11235/crawl", json={
    "urls": [
        "https://www.reddit.com/r/politics/hot/",
        "https://www.reddit.com/r/politics/new/",
        "https://www.reddit.com/r/politics/top/?t=week"
    ],
    "options": {
        "output_format": "markdown",
        "user_agent_mode": "random"
    }
})
results = resp.json()["results"]  # Array of crawl results
```

## CLI vs Python SDK vs Docker

| Aspect | CLI | Python SDK | Docker API |
|--------|-----|------------|------------|
| **Best for** | Quick terminal use | Programmable automation | Shared service/API |
| **Speed** | Fastest for one-offs | Fast | Slightly slower (HTTP overhead) |
| **Control** | Lowest | Highest | Medium |
| **Batch URLs** | Limited | Full control in code | Yes (JSON array) |
| **Web UI** | No | No | Dashboard + Playground |
| **REST API** | No | No | Yes |
| **Deep crawl** | Simple flags | Full strategy objects | Request payload |
| **Anti-bot tuning** | Basic | Better | Better |
| **Operational overhead** | Lowest | Low | Highest |

### When to Use Which

| Use Case | Choose |
|----------|--------|
| Quick one-off scrape | CLI |
| Scripted automation | Python SDK |
| Build custom extraction pipeline | Python SDK |
| Repeatable agent workflow | Python SDK |
| API for other services | Docker API |
| Dashboard / playground / remote service | Docker API |
| Batch parallel crawl from another app | Docker API |
| Fast terminal debugging | CLI |

---

## Common Use Cases

| Use Case | Approach |
|----------|----------|
| **RAG Pipeline** | `crwl <url> -o markdown-fit` |
| **News Aggregation** | Batch crawl multiple sources |
| **Documentation** | Deep crawl with BFS |
| **Site Mapping** | Prefetch mode |
| **Price Monitoring** | Scheduled crawl + extraction |
| **Lead Generation** | LLM extraction for contact info |

---

## Best Practices

1. **Start simple** - test single page before deep crawl
2. **Use filters** - target specific content
3. **Limit scope** - use `max_pages` to control costs
4. **Handle blocks** - add proxies for protected sites
5. **Monitor** - use dashboard for production runs

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `python3` cannot import `crawl4ai` | If installed via `pipx`, use `~/.local/pipx/venvs/crawl4ai/bin/python` or install into a project venv |
| No output | Check browser accessibility, try `CacheMode.BYPASS` |
| Anti-bot blocks (Reddit, etc.) | Use `user_agent_mode=random` (CLI: `-c "user_agent_mode=random"`, Docker: `"user_agent_mode": "random"`) |
| Need a default interface | Use Python SDK for automation, CLI for quick manual runs, Docker API for service-style usage |
| Reddit shows "Prove your human" | Add `user_agent_mode=random` - works reliably |
| Slow performance | Use prefetch mode, enable caching |
| JS not rendering | Increase timeout, check `wait_until` |
