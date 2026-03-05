# Playbook: Load & Performance Testing

**Goal:** Verify API performance and behavior under load using lightweight, language-agnostic tools.

---

## Basic Load with Hurl

```bash
# Run same request multiple times
for i in {1..100}; do
  hurl --test tests/api/get_users.hurl &
done
wait
```

---

## Using hey (Go-based)

```bash
# Install hey
go install github.com/rakyll/hey@latest

# Basic load test
hey -n 1000 -c 10 http://localhost:8000/api/users

# With POST body
hey -n 1000 -c 10 -m POST -D tests/payloads/user.json http://localhost:8000/api/users

# Custom headers
hey -n 1000 -c 10 -H "Authorization: Bearer token" http://localhost:8000/api/profile
```

---

## Using k6 (JavaScript-based)

```javascript
// tests/load/script.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  const res = http.get('http://localhost:8000/api/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  sleep(1);
}
```

```bash
k6 run tests/load/script.js
```

---

## Using wrk

```bash
brew install wrk

# Basic benchmark
wrk -t12 -c400 -d30s http://localhost:8000/api/users

# With Lua script for custom timing
wrk -t4 -c100 -d30s -s tests/load/api.lua http://localhost:8000/api/graphql
```

---

## Concurrent API Tests

```bash
# Run multiple Hurl tests in parallel
for test in tests/api/*.hurl; do
  hurl --test "$test" &
done
wait

# Or use xargs for controlled parallelism
ls tests/api/*.hurl | xargs -P 5 -I {} hurl --test {}
```

---

## Quick Reference

| Tool | Command |
|------|---------|
| hey | `hey -n 1000 -c 10 url` |
| k6 | `k6 run script.js` |
| wrk | `wrk -t12 -c400 -d30s url` |
