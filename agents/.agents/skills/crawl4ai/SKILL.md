---
name: crawl4ai
description: Comprehensive guide for Crawl4AI - open-source LLM-friendly web crawler and scraper. Covers CLI commands, Python API, Docker, deep crawling, extraction, content filtering, and advanced features.
---

# Crawl4AI - Open Source Web Crawler

> **Full CLI docs:** [docs.crawl4ai.com/core/cli/](https://docs.crawl4ai.com/core/cli/)  
> **Deep dive:** [Deep Crawling](references/deep-crawling.md) · [Extraction](references/extraction.md) · [Configuration](references/config.md)

Crawl4AI is an open-source (Apache 2.0), LLM-friendly web crawler that transforms websites into clean Markdown or structured JSON. 62k+ GitHub stars.

---

## Installation

```bash
pip install -U crawl4ai
crawl4ai-setup
crawl4ai-doctor

# Docker (recommended)
docker pull unclecode/crawl4ai:latest
docker run -d -p 11235:11235 --name crawl4ai --shm-size=1g unclecode/crawl4ai:latest
```

**Docker endpoints:** Dashboard `http://localhost:11235/dashboard` · Playground `http://localhost:11235/playground` · API `http://localhost:11235/crawl`

---

## Quick CLI Reference

```bash
# Basic crawl
crwl https://example.com

# Output formats: all, json, markdown, markdown-fit
crwl https://example.com -o json
crwl https://example.com -o markdown-fit

# Deep crawl: bfs, dfs, best-first
crwl https://docs.site.com --deep-crawl bfs --max-pages 10

# LLM Q&A
crwl https://example.com -q "What is the main topic?"

# With config files
crwl https://example.com -B browser.yml -C crawler.yml
```

---

## Python API

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

### Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| `BFSDeepCrawlStrategy` | Breadth-first (level by level) | Comprehensive coverage |
| `DFSDeepCrawlStrategy` | Depth-first (follows one path) | Documentation sites |
| `BestFirstCrawlingStrategy` | Priority-based with scorers | Focused relevance |

```python
from crawl4ai import CrawlerRunConfig
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy, BestFirstCrawlingStrategy
from crawl4ai.deep_crawling.scorers import KeywordRelevanceScorer

# BFS - explore all pages level by level
config = CrawlerRunConfig(
    deep_crawl_strategy=BFSDeepCrawlStrategy(
        max_depth=2,
        include_external=False,
        max_pages=50
    )
)

# Best-first - prioritize relevant pages
scorer = KeywordRelevanceScorer(keywords=["api", "docs"], weight=0.7)
config = CrawlerRunConfig(
    deep_crawl_strategy=BestFirstCrawlingStrategy(
        max_depth=2,
        url_scorer=scorer,
        max_pages=25
    ),
    stream=True  # Process as discovered
)
```

### Streaming Results

```python
config = CrawlerRunConfig(stream=True)
async with AsyncWebCrawler() as crawler:
    async for result in await crawler.arun(url, config=config):
        process_result(result)  # Process each page as discovered
```

### Filtering

```python
from crawl4ai.deep_crawling.filters import FilterChain, URLPatternFilter, DomainFilter

filter_chain = FilterChain([
    URLPatternFilter(patterns=["*blog*", "*docs*"]),
    DomainFilter(allowed_domains=["docs.example.com"])
])

config = CrawlerRunConfig(
    deep_crawl_strategy=BFSDeepCrawlStrategy(
        max_depth=2,
        filter_chain=filter_chain
    )
)
```

### Crash Recovery

```python
# Save state
async def save_state(state):
    await redis.set("crawl_state", json.dumps(state))

strategy = BFSDeepCrawlStrategy(
    max_depth=3,
    on_state_change=save_state
)

# Resume
saved = json.loads(await redis.get("crawl_state"))
strategy = BFSDeepCrawlStrategy(max_depth=3, resume_state=saved)
```

### Prefetch Mode (Fast URL Discovery)

```python
# Phase 1: Discover URLs (5-10x faster)
prefetch_cfg = CrawlerRunConfig(prefetch=True)
discovery = await crawler.arun(url, config=prefetch_cfg)
urls = [link["href"] for link in discovery.links.get("internal", [])]

# Phase 2: Full crawl selected URLs
for url in urls:
    result = await crawler.arun(url, config=full_config)
```

---

## Extraction Strategies

### CSS-Based Extraction

```python
from crawl4ai import JsonCssExtractionStrategy, CrawlerRunConfig

schema = {
    "name": "Products",
    "baseSelector": ".product",
    "fields": [
        {"name": "title", "selector": "h3", "type": "text"},
        {"name": "price", "selector": ".price", "type": "text"},
        {"name": "image", "selector": "img", "type": "attribute", "attribute": "src"}
    ]
}

config = CrawlerRunConfig(extraction_strategy=JsonCssExtractionStrategy(schema))
result = await crawler.arun(url, config=config)
print(result.extracted_content)
```

### LLM-Based Extraction

```python
from crawl4ai import LLMExtractionStrategy, LLMConfig
from pydantic import BaseModel

class Product(BaseModel):
    name: str
    price: str
    description: str

config = CrawlerRunConfig(
    extraction_strategy=LLMExtractionStrategy(
        llm_config=LLMConfig(provider="openai/gpt-4o", api_key="key"),
        schema=Product.schema(),
        instruction="Extract product details"
    )
)
```

**Supported LLM providers:** `openai/gpt-4o`, `anthropic/claude-3-sonnet`, `ollama/llama2` (see LiteLLM for full list)

---

## Content Filtering

```python
from crawl4ai.content_filter_strategy import BM25ContentFilter, PruningContentFilter
from crawl4ai.markdown_generation_strategy import DefaultMarkdownGenerator

# Fit markdown - removes noise
result = await crawler.arun(url, config=CrawlerRunConfig(
    markdown_generator=DefaultMarkdownGenerator(
        options={"markdown": {"exclude_internal_links": True}}
    )
))

# BM25 - algorithm-based relevance
config = CrawlerRunConfig(
    markdown_generator=DefaultMarkdownGenerator(
        content_filter=BM25ContentFilter(user_query="search terms", bm25_threshold=1.0)
    )
)
```

---

## Advanced Features

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

# Submit job
resp = requests.post("http://localhost:11235/crawl", json={
    "urls": ["https://example.com"],
    "priority": 10
})
task_id = resp.json().get("task_id")

# Get results
result = requests.get(f"http://localhost:11235/crawl/{task_id}")
```

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
| No output | Check browser accessibility, try `CacheMode.BYPASS` |
| Anti-bot blocks | Add proxies, use random user-agent |
| Slow performance | Use prefetch mode, enable caching |
| JS not rendering | Increase timeout, check `wait_until` |
