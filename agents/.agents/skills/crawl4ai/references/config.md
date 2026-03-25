# Configuration Reference

Complete configuration options for Crawl4AI.

## BrowserConfig

```python
from crawl4ai import BrowserConfig

config = BrowserConfig(
    # Basic
    headless=True,
    verbose=True,
    
    # Viewport
    viewport_width=1280,
    viewport_height=720,
    
    # User Agent
    user_agent_mode="random",  # or specific UA string
    
    # Security
    ignore_https_errors=False,
    
    # JavaScript
    java_script_enabled=True,
    
    # Proxy
    proxy={"server": "http://proxy:8080", "username": "user", "password": "pass"}
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `headless` | bool | True | Run without visible browser |
| `verbose` | bool | False | Enable verbose logging |
| `viewport_width` | int | 1280 | Browser width |
| `viewport_height` | int | 720 | Browser height |
| `user_agent_mode` | str | None | "random" or UA string |
| `ignore_https_errors` | bool | False | Ignore cert errors |
| `java_script_enabled` | bool | True | Enable JS |
| `proxy` | dict | None | Proxy config |

## CrawlerRunConfig

```python
from crawl4ai import CrawlerRunConfig, CacheMode

config = CrawlerRunConfig(
    # Timeout & Delays
    page_timeout=30000,
    delay_before_return_html=0.5,
    
    # Content
    word_count_threshold=100,
    scan_full_page=True,
    
    # Behavior
    wait_until="networkidle",
    scroll_delay=0.3,
    
    # Cache
    cache_mode=CacheMode.ENABLED,
    
    # Cleanup
    remove_overlay_elements=True,
    
    # Output
    screenshot=False,
    
    # Deep crawl
    deep_crawl_strategy=strategy,
    stream=False,
    prefetch=False,
    
    # Extraction
    extraction_strategy=extraction_strategy,
    markdown_generator=markdown_gen,
    
    # Advanced
    js_code=None,
    hooks={},
    proxy_config=[]
)
```

### CacheMode Options

| Mode | Behavior |
|------|----------|
| `ENABLED` | Use cache if available |
| `BYPASS` | Always fetch fresh |
| `DISABLED` | No caching |

### wait_until Options

| Option | Description |
|--------|-------------|
| `load` | Page loaded (HTML) |
| `domcontentloaded` | DOM ready |
| `networkidle` | No network for 500ms |
| `networkidle2` | Max 2 connections |

### Deep Crawl Options

| Parameter | Description |
|-----------|-------------|
| `deep_crawl_strategy` | BFS, DFS, or BestFirst strategy |
| `stream` | Enable streaming results |
| `prefetch` | Fast URL discovery mode |
| `max_depth` | Max crawl depth |
| `max_pages` | Max pages to crawl |

## Proxy Configuration

```python
from crawl4ai.async_configs import ProxyConfig

# Single proxy
proxy = ProxyConfig(
    server="http://proxyhost:8080",
    username="user",
    password="pass"
)

# Multiple (fallback chain)
proxy_config = [
    ProxyConfig.DIRECT,  # Try direct first
    ProxyConfig(server="http://proxy1:8080"),
    ProxyConfig(server="http://proxy2:8080"),
]

config = CrawlerRunConfig(
    proxy_config=proxy_config,
    max_retries=2
)
```

## Hooks

Execute code at crawl stages:

```python
async def on_page_context_created(page, context, **kwargs):
    # Block images for speed
    await context.route("**/*.{png,jpg,jpeg}", lambda r: r.abort())
    return page

async def before_goto(page, context, url, **kwargs):
    # Add custom headers
    await page.set_extra_http_headers({"X-Custom": "Header"})
    return page

async def on_result(result, **kwargs):
    # Process result
    print(f"Crawled: {result.url}")

config = CrawlerRunConfig(
    hooks={
        "on_page_context_created": on_page_context_created,
        "before_goto": before_goto,
        "on_result": on_result
    }
)
```

### Available Hooks

| Hook | Timing |
|------|--------|
| `on_page_context_created` | After browser context created |
| `before_goto` | Before navigating to URL |
| `after_goto` | After navigation complete |
| `on_result` | After crawl completes |
| `before_exit` | Before crawler closes |

## Markdown Generation

```python
from crawl4ai.markdown_generation_strategy import DefaultMarkdownGenerator

config = CrawlerRunConfig(
    markdown_generator=DefaultMarkdownGenerator(
        options={
            "markdown": {
                "exclude_internal_links": True,
                "exclude_external_links": False,
                "ignore_images": False
            }
        }
    )
)
```

## Content Filters

### BM25ContentFilter

```python
from crawl4ai.content_filter_strategy import BM25ContentFilter

filter = BM25ContentFilter(
    user_query="search terms",
    bm25_threshold=1.0,
    target_version="v2"
)
```

### PruningContentFilter

```python
from crawl4ai.content_filter_strategy import PruningContentFilter

filter = PruningContentFilter(
    threshold=0.48,
    threshold_type="fixed",  # or "dynamic"
    min_word_threshold=0
)
```

## Complete Example

```python
from crawl4ai import AsyncWebCrawler, BrowserConfig, CrawlerRunConfig, CacheMode
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy
from crawl4ai.deep_crawling.filters import FilterChain, URLPatternFilter

browser_config = BrowserConfig(
    headless=True,
    verbose=True,
    user_agent_mode="random",
    viewport_width=1920
)

crawler_config = CrawlerRunConfig(
    cache_mode=CacheMode.BYPASS,
    wait_until="networkidle",
    page_timeout=60000,
    word_count_threshold=50,
    remove_overlay_elements=True,
    scan_full_page=True,
    deep_crawl_strategy=BFSDeepCrawlStrategy(
        max_depth=2,
        max_pages=30,
        filter_chain=FilterChain([
            URLPatternFilter(patterns=["*blog*", "*post*"])
        ])
    )
)

async with AsyncWebCrawler(config=browser_config) as crawler:
    result = await crawler.arun(url, config=crawler_config)
```
