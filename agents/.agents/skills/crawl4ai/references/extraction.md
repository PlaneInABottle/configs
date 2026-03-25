# Extraction Strategies Reference

Crawl4AI provides multiple extraction strategies for getting structured data from web pages.

## CSS-Based Extraction (No LLM)

Fast, schema-based extraction using CSS selectors:

```python
from crawl4ai import JsonCssExtractionStrategy, CrawlerRunConfig

schema = {
    "name": "Products",           # Name for the extraction
    "baseSelector": ".product",   # Container element
    "fields": [
        {
            "name": "title",
            "selector": "h3.product-title",
            "type": "text"
        },
        {
            "name": "price",
            "selector": ".price-value",
            "type": "text"
        },
        {
            "name": "image",
            "selector": "img.product-img",
            "type": "attribute",
            "attribute": "src"
        },
        {
            "name": "link",
            "selector": "a",
            "type": "attribute", 
            "attribute": "href"
        },
        {
            "name": "rating",
            "selector": ".stars .active",
            "type": "text"
        }
    ]
}

strategy = JsonCssExtractionStrategy(schema, verbose=True)
config = CrawlerRunConfig(extraction_strategy=strategy)
result = await crawler.arun(url, config=config)
print(result.extracted_content)
```

### Field Types

| Type | Description |
|------|-------------|
| `text` | Extract text content |
| `attribute` | Extract attribute value |
| `html` | Extract inner HTML |
| `outer_html` | Extract outer HTML |

## LLM-Based Extraction

Uses AI to understand and extract structured data:

```python
from crawl4ai import LLMExtractionStrategy, LLMConfig
from pydantic import BaseModel

class Product(BaseModel):
    name: str
    price: str
    description: str

class Article(BaseModel):
    title: str
    author: str
    date: str
    content: str

# Basic usage
config = CrawlerRunConfig(
    extraction_strategy=LLMExtractionStrategy(
        llm_config=LLMConfig(
            provider="openai/gpt-4o",
            api_key="your-key"
        ),
        schema=Product.schema(),
        instruction="Extract all product details from the page"
    )
)

result = await crawler.arun(url, config=config)
print(result.extracted_content)
```

### Supported LLM Providers

```python
# OpenAI
LLMConfig(provider="openai/gpt-4o", api_key="key")
LLMConfig(provider="openai/gpt-4o-mini", api_key="key")

# Anthropic
LLMConfig(provider="anthropic/claude-3-sonnet", api_key="key")

# Ollama (local)
LLMConfig(provider="ollama/llama2", api_token="no-token")

# See LiteLLM docs for full list
```

### Extraction with Custom Schema

```python
from pydantic import BaseModel, Field
from typing import List, Optional

class Product(BaseModel):
    name: str = Field(description="Product name")
    price: str = Field(description="Product price")
    description: Optional[str] = Field(description="Product description")
    features: List[str] = Field(description="List of features")
    rating: Optional[float] = Field(description="Average rating out of 5")

strategy = LLMExtractionStrategy(
    llm_config=LLMConfig(provider="openai/gpt-4o", api_key="key"),
    schema=Product.schema(),
    instruction="Extract complete product information including name, price, description, features list, and rating"
)
```

### JSON Schema Format

You can also use raw JSON schema:

```python
schema = {
    "type": "object",
    "properties": {
        "title": {"type": "string", "description": "Article title"},
        "author": {"type": "string", "description": "Author name"},
        "date": {"type": "string", "description": "Publication date"},
        "content": {"type": "string", "description": "Main content"}
    },
    "required": ["title", "content"]
}

strategy = LLMExtractionStrategy(
    llm_config=LLMConfig(provider="openai/gpt-4o", api_key="key"),
    schema=schema,
    instruction="Extract article details"
)
```

## Table Extraction

```python
from crawl4ai import LLMTableExtraction, LLMConfig

table_strategy = LLMTableExtraction(
    llm_config=LLMConfig(provider="openai/gpt-4o-mini"),
    enable_chunking=True,
    chunk_token_threshold=5000,
    overlap_threshold=100,
    extraction_type="structured"  # or "markdown"
)

config = CrawlerRunConfig(table_extraction_strategy=table_strategy)
```

## Content Filtering with Extraction

Combine extraction with content filtering:

```python
from crawl4ai import LLMExtractionStrategy, LLMConfig
from crawl4ai.content_filter_strategy import BM25ContentFilter

config = CrawlerRunConfig(
    extraction_strategy=LLMExtractionStrategy(
        llm_config=LLMConfig(provider="openai/gpt-4o", api_key="key"),
        schema=schema,
        instruction="Extract product data"
    ),
    # Also apply content filtering
    markdown_generator=DefaultMarkdownGenerator(
        content_filter=BM25ContentFilter(
            user_query="product information",
            bm25_threshold=1.0
        )
    )
)
```

## Extraction Parameters

| Parameter | Description |
|-----------|-------------|
| `schema` | Pydantic model or JSON schema |
| `instruction` | Natural language instructions |
| `extraction_type` | "schema" or "chunk" |
| `input_format` | "html", "markdown", or "fit_markdown" |

## Best Practices

1. **Use CSS extraction** for structured sites with consistent HTML
2. **Use LLM extraction** for unstructured or complex pages
3. **Be specific** in your instruction to the LLM
4. **Test first** with a single URL before batch
5. **Handle errors** - extraction can fail on some pages
