---
name: api-discovery
description: Research and compare current public APIs for a specific development need. Use when selecting an external provider, checking authentication, pricing or free-tier constraints, rate limits, CORS, licensing, data quality, SDK support, or operational fit before integration.
---

# API Discovery

Treat provider capabilities, free tiers, quotas, and endpoint availability as volatile. Verify them from current official documentation during every selection; do not rely on a static catalog.

## Workflow

1. Define the required capability, geography, freshness, volume, latency, and legal constraints.
2. Identify two or three plausible providers from official sources or maintained directories.
3. Verify authentication, HTTPS, rate limits, pricing, licensing, retention, CORS, uptime commitments, and deprecation policy from official documentation.
4. Test the smallest non-sensitive request with `curl` or the provider's documented explorer.
5. Compare failure behavior, response shape, pagination, and rate-limit headers.
6. Recommend one provider with dated evidence and note any unverified claims.

## Selection Criteria

| Concern | Verify |
|---|---|
| Security | HTTPS, credential placement, OAuth or key scope |
| Reliability | Status history, documented limits, retry guidance |
| Product fit | Coverage, freshness, fields, localization |
| Operations | Quotas, rate-limit headers, webhooks, pagination |
| Legal | License, attribution, storage, redistribution |
| Cost | Current pricing and expected request volume |

## Guardrails

- Do not place API keys in URLs when headers are supported.
- Do not recommend plain-HTTP endpoints for production integrations.
- Do not describe an API as free, unlimited, CORS-enabled, or attribution-free without current official evidence.
- Avoid providers that require scraping when a documented API is available.
- Record the verification date because commercial terms change.

Maintained directories such as `public-apis/public-apis` can provide candidates, but official provider documentation remains authoritative.
