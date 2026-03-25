# Web Scraping with agent-browser

agent-browser can function as a browser-based scraper/crawler, offering advantages over traditional HTTP scrapers for certain use cases.

## When to Use agent-browser for Scraping

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Static HTML pages | ❌ Use curl/cheerio | Faster, lower resource usage |
| JavaScript-rendered SPAs | ✅ agent-browser | Executes JS, renders full content |
| Pages requiring login | ✅ agent-browser | Handles auth + sessions |
| Infinite scroll/pagination | ✅ agent-browser | Can interact to load more |
| Anti-bot protected sites | ❌ Use specialized tools | May still get blocked |

## Basic Scraping Workflow

```bash
# 1. Open the target page
agent-browser open https://example.com

# 2. Inspect the page structure
agent-browser snapshot -i

# 3. Extract data using JavaScript
agent-browser eval --stdin <<'EOF'
// Extract all article titles and links
const articles = Array.from(document.querySelectorAll('article a')).map(a => ({
  title: a.textContent.trim(),
  url: a.href
}));
JSON.stringify(articles, null, 2)
EOF

# 4. Take a screenshot for verification
agent-browser screenshot

# 5. Close when done
agent-browser close
```

## Data Extraction Techniques

### Extract all links
```bash
agent-browser eval --stdin <<'EOF'
JSON.stringify(
  Array.from(document.querySelectorAll('a[href]'))
    .map(a => a.href)
    .filter(h => h.startsWith('http'))
    .slice(0, 100) // limit to first 100
, null, 2)
EOF
```

### Extract text content
```bash
agent-browser eval --stdin <<'EOF'
JSON.stringify(
  Array.from(document.querySelectorAll('h1, h2, h3, p'))
    .map(el => el.textContent.trim())
    .filter(t => t.length > 0)
    .slice(0, 50)
, null, 2)
EOF
```

### Extract structured data (tables, cards)
```bash
agent-browser eval --stdin <<'EOF'
const items = Array.from(document.querySelectorAll('.product-card')).map(card => ({
  name: card.querySelector('.title')?.textContent?.trim(),
  price: card.querySelector('.price')?.textContent?.trim(),
  url: card.querySelector('a')?.href
}));
JSON.stringify(items, null, 2)
EOF
```

### Pagination/Scroll
```bash
# Click "Next" button to load more content
agent-browser click @e15
agent-browser wait --load networkidle
agent-browser snapshot -i
# Then extract again...
```

## Important Considerations

### 1. Rate Limiting
- Add delays between requests: `sleep 2` or `wait --load networkidle`
- Many sites block aggressive scraping
- Consider `--session` for isolated requests

### 2. Anti-Bot Detection
- Sites may detect headless browsers via:
  - `navigator.webdriver` flag
  - Canvas fingerprinting
  - Automation-specific CSS/JS markers
- Use `--headed` for more realistic browser signature
- Some sites require additional measures beyond agent-browser

### 2.1 Handling Blocked Sites (Advanced Protection)

Some sites like **Reuters** use enterprise-grade bot protection (DataDome, Cloudflare Enterprise, PerimeterX) that blocks even headed browsers. If you encounter a blank page or CAPTCHA:

1. **Try `--headed` mode first** - may bypass basic detection:
   ```bash
   agent-browser --headed open https://www.reuters.com/
   ```

2. **Add stealth arguments** - reduces automation fingerprints:
   ```bash
   agent-browser --headed --args "--disable-blink-features=AutomationControlled" open <url>
   ```

3. **Close existing sessions first** - stale sessions may be flagged:
   ```bash
   agent-browser close
   agent-browser --headed open <url>
   ```

4. **Wait for page load** - some sites render after initial load:
   ```bash
   agent-browser wait --load networkidle
   agent-browser snapshot -i
   ```

5. **If blocked by DataDome/advanced CAPTCHA** (shows geo.captcha-delivery.com):
   - Cannot be solved programmatically - requires human interaction or specialized services
   - Use RSS feeds (e.g., Reuters Agency RSS: https://www.reutersagency.com/tools/rss/)
   - Use official APIs if available
   - Consider scraping services (ScrapingBee, Bright Data, ScraperAPI)

### 3. Paywalls
- Cannot bypass subscription/paywalled content
- Some sites offer RSS feeds or API access as alternatives

### 4. Dynamic Content
- Re-snapshot after any interaction
- Wait for lazy-loaded images: `wait --load networkidle`
- Handle modals/overlays that may block content

### 5. Legal/Ethical
- Respect `robots.txt` and Terms of Service
- Do not scrape personal data without consent
- Use data responsibly and per applicable laws

## Scaling to Multiple Pages

For crawling multiple pages, script the process:

```bash
# Example: crawl a list of URLs
URLS=("https://example.com/page1" "https://example.com/page2" "https://example.com/page3")

for url in "${URLS[@]}"; do
  agent-browser open "$url"
  agent-browser eval --stdin <<'EOF'
    // extraction logic here
  EOF
  sleep 2 # rate limit
done
agent-browser close
```

## Limitations Compared to HTTP Scrapers

| Aspect | agent-browser | HTTP Scraper |
|--------|--------------|--------------|
| Speed | Slower (full browser) | Faster |
| Resources | Higher (GPU, memory) | Lower |
| Stealth | More detectable | Easier to mask |
| Complexity | Simpler for JS sites | More setup for SPAs |

## See Also

- [commands.md](commands.md) - Full command reference
- [session-management.md](session-management.md) - Browser persistence options
- [authentication.md](authentication.md) - Login flow handling