#!/bin/bash
# Web Scraping Template using agent-browser
# Usage: ./scraping-workflow.sh <url> [output-file]
# Example: ./scraping-workflow.sh https://example.com results.json

set -e

URL="${1:-https://example.com}"
OUTPUT="${2:-./scraped-data.json}"

echo "Opening $URL..."
agent-browser open "$URL"

echo "Waiting for page load..."
agent-browser wait --load networkidle

echo "Inspecting page structure..."
agent-browser snapshot -i

echo "Extracting data..."
agent-browser eval --stdin <<'EOF' > "$OUTPUT"
const data = {
  url: window.location.href,
  title: document.title,
  links: Array.from(document.querySelectorAll('a[href]'))
    .map(a => a.href)
    .filter(h => h.startsWith('http'))
    .slice(0, 100),
  headings: Array.from(document.querySelectorAll('h1, h2, h3'))
    .map(h => h.textContent.trim())
    .filter(t => t.length > 0),
  timestamp: new Date().toISOString()
};
JSON.stringify(data, null, 2);
EOF

echo "Taking screenshot..."
agent-browser screenshot

echo "Data saved to $OUTPUT"
agent-browser close

echo "Done!"