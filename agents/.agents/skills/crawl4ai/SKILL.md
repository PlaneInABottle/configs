---
name: crawl4ai
description: Crawl websites into Markdown or structured data with Crawl4AI using its CLI, Python SDK, or self-hosted API. Use for repeatable scraping, deep crawls, batch extraction, browser-rendered pages, or RAG ingestion when simple HTTP fetching or interactive agent-browser work is insufficient.
---

# Crawl4AI

Prefer `webfetch` for one known public page and `agent-browser` for interactive or authenticated browsing. Use Crawl4AI for repeatable extraction, batches, deep traversal, or browser-rendered content.

## Preflight

```bash
command -v crwl
crwl crawl -h
python3 -c 'import crawl4ai; print(crawl4ai.__version__)'
```

The CLI subcommand is `crwl crawl URL`; do not use the obsolete `crwl URL` form. If the Python import fails, use a project virtual environment containing Crawl4AI rather than hardcoding a machine-specific pipx interpreter path.

## Interface Choice

| Need | Interface |
|---|---|
| One terminal crawl | CLI |
| Repeatable extraction or custom control | Python SDK |
| Shared remote service | Self-hosted API |

## CLI

```bash
crwl crawl https://example.com -o markdown
crwl crawl https://example.com -o json -O result.json
crwl crawl https://docs.example.com --deep-crawl bfs --max-pages 20
```

Run `crwl crawl -h` before using less common flags because the CLI changes between releases.

## Python SDK

```python
import asyncio
from crawl4ai import AsyncWebCrawler, BrowserConfig, CacheMode, CrawlerRunConfig

async def main() -> None:
    browser = BrowserConfig(headless=True)
    run = CrawlerRunConfig(cache_mode=CacheMode.BYPASS)
    async with AsyncWebCrawler(config=browser) as crawler:
        result = await crawler.arun(url="https://example.com", config=run)
        if not result.success:
            raise RuntimeError(result.error_message)
        print(result.markdown)

asyncio.run(main())
```

- Inspect installed signatures before copying advanced configuration.
- Configure per-run proxies through `CrawlerRunConfig.proxy_config`.
- Use a supported dispatcher for batch concurrency; do not assume `max_concurrent` is an `arun_many` parameter.
- Register hooks through the crawler's supported hook API. Do not pass an undocumented `hooks` argument to `CrawlerRunConfig`.
- Build self-hosted request payloads from current server docs or its OpenAPI schema; do not assume old `options` or task-status payloads.

## Guardrails

- Respect robots directives, site terms, authentication boundaries, and rate limits.
- Do not claim random user agents reliably bypass bot protection.
- Bound page counts, concurrency, retries, and output size.
- Never put proxy credentials or API tokens in committed examples.

## References

- Load [references/config.md](references/config.md) for configuration concepts, then verify fields against the installed version.
- Load [references/deep-crawling.md](references/deep-crawling.md) for traversal strategies.
- Load [references/extraction.md](references/extraction.md) for CSS and LLM extraction.
- Treat [scripts/](scripts/) as maintained examples and run them in an environment where `crawl4ai` imports successfully.
