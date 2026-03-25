# Deep Crawling Reference

Complete guide to Crawl4AI's deep crawling capabilities.

## Strategy Comparison

| Strategy | Exploration Order | Best For |
|----------|------------------|----------|
| BFSDeepCrawlStrategy | Level by level (home → section → article) | Comprehensive coverage |
| DFSDeepCrawlStrategy | Deep paths first (follows one branch) | Documentation, blogs |
| BestFirstCrawlingStrategy | By relevance score | Focused, targeted crawling |

## BFSDeepCrawlStrategy

```python
from crawl4ai.deep_crawling import BFSDeepCrawlStrategy

strategy = BFSDeepCrawlStrategy(
    max_depth=2,              # Starting page + 2 levels
    include_external=False,   # Stay in same domain
    max_pages=50,            # Hard limit
    score_threshold=0.3,     # Minimum URL score
    filter_chain=filter_chain,
    url_scorer=scorer
)
```

## DFSDeepCrawlStrategy

```python
from crawl4ai.deep_crawling import DFSDeepCrawlStrategy

strategy = DFSDeepCrawlStrategy(
    max_depth=3,
    include_external=False,
    max_pages=30
)
```

## BestFirstCrawlingStrategy (Recommended)

Uses scorers to prioritize most relevant pages:

```python
from crawl4ai.deep_crawling import BestFirstCrawlingStrategy
from crawl4ai.deep_crawling.scorers import KeywordRelevanceScorer

scorer = KeywordRelevanceScorer(
    keywords=["api", "docs", "guide", "reference"],
    weight=0.7  # 0.0 to 1.0
)

strategy = BestFirstCrawlingStrategy(
    max_depth=2,
    url_scorer=scorer,
    max_pages=25
)
```

## Filters

### URLPatternFilter

```python
from crawl4ai.deep_crawling.filters import URLPatternFilter, FilterChain

filter_chain = FilterChain([
    URLPatternFilter(patterns=["*blog*", "*docs*", "*guide*"])
])
```

### DomainFilter

```python
from crawl4ai.deep_crawling.filters import DomainFilter

filter_chain = FilterChain([
    DomainFilter(
        allowed_domains=["docs.example.com", "blog.example.com"],
        blocked_domains=["old.example.com"]
    )
])
```

### ContentRelevanceFilter

```python
from crawl4ai.deep_crawling.filters import ContentRelevanceFilter

filter_chain = FilterChain([
    ContentRelevanceFilter(
        query="web scraping python",
        threshold=0.7
    )
])
```

## Scorers

### KeywordRelevanceScorer

```python
from crawl4ai.deep_crawling.scorers import KeywordRelevanceScorer

scorer = KeywordRelevanceScorer(
    keywords=["tutorial", "guide", "api", "reference"],
    weight=0.7
)
```

## Streaming vs Non-Streaming

### Non-Streaming (Default)
```python
config = CrawlerRunConfig(stream=False)  # Default
results = await crawler.arun(url, config=config)
# Wait for ALL pages, then process
```

### Streaming
```python
config = CrawlerRunConfig(stream=True)
async for result in await crawler.arun(url, config=config):
    process_result(result)  # Process each as discovered
```

## Crash Recovery

```python
import json
import redis

# Save state callback
async def save_state(state: dict):
    await redis.set("crawl_state", json.dumps(state))

# On first run
strategy = BFSDeepCrawlStrategy(
    max_depth=3,
    on_state_change=save_state
)

# Resume from checkpoint
saved_state = json.loads(await redis.get("crawl_state"))
strategy = BFSDeepCrawlStrategy(
    max_depth=3,
    resume_state=saved_state,
    on_state_change=save_state
)
```

### State Structure

```json
{
  "strategy_type": "bfs",
  "visited": ["url1", "url2"],
  "pending": [{"url": "...", "parent_url": "..."}],
  "depths": {"url1": 0, "url2": 1},
  "pages_crawled": 42
}
```

## Cancellation

```python
# Callback-based
async def check_cancelled():
    return await redis.get("job_status") == "cancelled"

strategy = BFSDeepCrawlStrategy(
    max_depth=3,
    should_cancel=check_cancelled
)

# Direct
strategy.cancel()

# Check status
if strategy.cancelled:
    print(f"Cancelled after {len(results)} pages")
```

## Prefetch Mode

5-10x faster for URL discovery:

```python
# Phase 1: Fast discovery (HTML + links only, no markdown)
prefetch_cfg = CrawlerRunConfig(prefetch=True)
discovery = await crawler.arun("https://example.com", config=prefetch_cfg)
all_urls = [link["href"] for link in discovery.links.get("internal", [])]

# Phase 2: Full crawl selected URLs
for url in all_urls:
    result = await crawler.arun(url, config=full_config)
```

**What's skipped in prefetch:**
- Markdown generation
- Content scraping
- Media extraction
- LLM extraction
