---
name: api-discovery
description: "Discover and select high-quality public APIs for development needs. Use when: (1) You need an API for a specific functionality (weather, geocoding, email validation, etc.), (2) Looking for free-tier APIs that work well in AI agent workflows, (3) Need quick reference to reliable public APIs with authentication and rate limit info."
---

# API Discovery

Find and select the best public API for your development needs. This skill maps common development tasks to reliable, well-documented public APIs.

## When to Use This Skill

Load this skill when you need to:
- Find an API for a specific functionality (weather, maps, email, etc.)
- Discover free public APIs for a project
- Get quick reference to API endpoints, auth, and limits
- Validate if an API is suitable for AI agent integration

## Category Quick Reference

| Development Need | Recommended APIs |
|-----------------|------------------|
| **Weather** | Open-Meteo (free, no key), OpenWeatherMap (free tier) |
| **Geocoding** | Nominatim (OpenStreetMap), OpenCage (free tier) |
| **Email Validation** | Abstract API (free tier), Hunter (free tier) |
| **IP Geolocation** | ip-api.com (free), IPStack (free tier) |
| **Stock Data** | Alpha Vantage (free tier), Yahoo Finance |
| **Images/Photos** | Pexels (use pexels-media skill), Unsplash |
| **Currency Exchange** | ExchangeRate-API (free tier), Open Exchange Rates |
| **News** | NewsAPI (free tier), GNews (free tier) |
| **Maps** | OpenStreetMap (Nominatim), Mapbox (free tier) |
| **Anime/Manga** | Jikan (MyAnimeList), Kitsu, AniList |
| **Random Data** | RandomUSER.me, JSONPlaceholder, Mockaroo |
| **Dictionary** | Free Dictionary API, Oxford Dictionaries |
| **OCR/Image** | OCR.space (free tier), Google Vision (free tier) |
| **Sentiment** | Twinword (free tier), MeaningCloud (free tier) |
| **QR Codes** | QRServer (free), GoQR |
| **URL Shorteners** | TinyURL (no auth), CleanURI (no auth) |

## Weather APIs

### Open-Meteo (Recommended - No API Key Required)

```bash
# Current weather
curl "https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&current_weather=true"

# Forecast
curl "https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&daily=temperature_2m_max,temperature_2m_min&timezone=auto"
```

**Auth:** None | **HTTPS:** Yes | **Rate:** 10,000/day | **CORS:** Yes

### OpenWeatherMap

```bash
# Current weather by city
curl "https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_API_KEY&units=metric"
```

**Auth:** API Key (free tier: 60 calls/min) | **HTTPS:** Yes | **CORS:** Yes

---

## Geocoding APIs

### Nominatim (OpenStreetMap - No Auth)

```bash
# Forward geocoding
curl "https://nominatim.openstreetmap.org/search?q=1600+Pennsylvania+Ave+Washington+DC&format=json"

# Reverse geocoding
curl "https://nominatim.openstreetmap.org/reverse?lat=38.8977&lon=-77.0365&format=json"
```

**Auth:** None | **Rate:** 1 req/sec | **HTTPS:** Yes | **CORS:** No

### OpenCage

```bash
curl "https://api.opencagedata.com/geocode/v1/json?q=London&key=YOUR_API_KEY"
```

**Auth:** API Key | **Free tier:** 2,500/day | **HTTPS:** Yes

---

## Email Validation APIs

### Abstract API

```bash
curl "https://emailvalidation.abstractapi.com/v1/?api_key=YOUR_KEY&email=test@example.com"
```

**Auth:** API Key | **Free tier:** 100/month | **HTTPS:** Yes

### Hunter

```bash
curl "https://api.hunter.io/v2/email-verifier?email=test@example.com&api_key=YOUR_KEY"
```

**Auth:** API Key | **Free tier:** 50/month | **HTTPS:** Yes

---

## IP Geolocation APIs

### ip-api.com (No Auth - Limited)

```bash
curl "http://ip-api.com/json/8.8.8.8"
```

**Auth:** None | **Rate:** 45 req/min (no key), unlimited with key | **HTTPS:** Yes (with key) | **CORS:** No

### IPStack

```bash
curl "http://api.ipstack.com/8.8.8.8?access_key=YOUR_KEY"
```

**Auth:** API Key | **Free tier:** 10,000/month | **HTTPS:** Yes

---

## Stock/Crypto Data APIs

### Alpha Vantage

```bash
curl "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=IBM&interval=5min&apikey=YOUR_KEY"
```

**Auth:** API Key (free) | **Rate:** 25 req/day (free) | **HTTPS:** Yes

### CoinGecko (Crypto)

```bash
curl "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
```

**Auth:** None | **Rate:** 10-50 req/min | **HTTPS:** Yes | **CORS:** Yes

---

## News APIs

### NewsAPI

```bash
curl "https://newsapi.org/v2/top-headlines?country=us&apiKey=YOUR_KEY"
```

**Auth:** API Key | **Free tier:** 100/day | **HTTPS:** Yes

### GNews

```bash
curl "https://gnews.io/api/v4/top-headlines?country=us&apikey=YOUR_KEY"
```

**Auth:** API Key | **Free tier:** 100/day | **HTTPS:** Yes

---

## Dictionary/Text APIs

### Free Dictionary API

```bash
curl "https://api.dictionaryapi.dev/api/v2/entries/en/hello"
```

**Auth:** None | **HTTPS:** Yes | **CORS:** Yes

### Datamuse (Word relationships)

```bash
curl "https://api.datamuse.com/words?rel_trg=cat"
```

**Auth:** None | **HTTPS:** Yes | **CORS:** Yes

---

## Test Data APIs

### JSONPlaceholder

```bash
# Posts
curl "https://jsonplaceholder.typicode.com/posts/1"
# Users
curl "https://jsonplaceholder.typicode.com/users"
# Comments
curl "https://jsonplaceholder.typicode.com/comments?postId=1"
```

**Auth:** None | **HTTPS:** Yes | **CORS:** Yes

### RandomUSER.me

```bash
curl "https://randomuser.me/api/?results=5"
```

**Auth:** None | **HTTPS:** Yes | **CORS:** Yes

---

## Movie/Entertainment APIs

### OMDb API

```bash
curl "http://www.omdbapi.com/?t=Inception&apikey=YOUR_KEY"
```

**Auth:** API Key (free) | **HTTPS:** Yes

### TVmaze

```bash
curl "https://api.tvmaze.com/shows/216"
curl "https://api.tvmaze.com/search/shows?q=battlestar"
```

**Auth:** None | **HTTPS:** Yes | **CORS:** Yes

---

## Selection Criteria for AI Agent Integration

When choosing a public API for AI workflows, prioritize:

1. **No auth or simple API key** - OAuth flows are complex for agents
2. **HTTPS with CORS enabled** - Makes browser/agent testing easier
3. **Generous free tier** - 1000+ requests/day minimum
4. **JSON response** - Easy to parse
5. **Stable/Well-documented** - Check GitHub stars and last commit date
6. **Rate limit headers** - Helps with request throttling

## Finding More APIs

For the full curated list (1000+ APIs), check:
- [public-apis/public-apis](https://github.com/public-apis/public-apis) - Main collection
- Categories: Animals, Anime, Art, Books, Business, Cryptocurrency, Data Validation, Development, Entertainment, Finance, Games, Government, Health, Machine Learning, Music, News, Science, Security, Social, Sports, Transportation, Weather

## Checklist

- [ ] Identify the functional need (what problem to solve)
- [ ] Check category quick reference above
- [ ] Verify auth requirements (prefer no auth or simple API key)
- [ ] Test with curl before integrating
- [ ] Check rate limits and CORS support
- [ ] Review documentation for endpoint changes