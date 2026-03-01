# Playbook: Universal Data Generation & State Assertion

**Goal:** Generate realistic, deterministic data for *any* system boundary (Files, APIs, Queues, Databases) without relying on language-specific factories (like Python's `factory_boy`). Bypass the application layer to assert state directly.

**Tools:** Dockerized Node.js (`node:lts-alpine`), `@faker-js/faker`, Docker, `psql`/`mysql`, `redis-cli`

---

## 1. Universal Fixture Generation (Node.js via Docker)

Use lightweight TypeScript scripts executed via an ephemeral Docker container to generate deterministic payloads for API requests, mock server responses (`db.json`), or file fixtures. **Never require a local Node.js installation or a host `package.json`.**

### Action: Generating Specific Edge-Case Payloads
When you need exact, hardcoded data to trigger specific business logic branches:

```typescript
// scripts/generate-specific-fixture.ts
import fs from 'fs';

const exactPayload = {
  id: "user_exact_match_999",
  email: "trigger-boundary@test.com",
  role: "super_admin",
  metadata: { exact_scenario: true }
};

// Write to a mock file for testing or API submission
fs.mkdirSync('tests/fixtures', { recursive: true });
fs.writeFileSync('tests/fixtures/test-payload.json', JSON.stringify(exactPayload, null, 2));
```

### Action: Generating Randomized Bulk Mocks (Faker.js)
When you need volume for load testing or list UI verification. Note that `@faker-js/faker` and `tsx` are loaded dynamically by `npx -y` inside the Docker container, so you don't need a host `package.json`.

```typescript
// scripts/generate-bulk.ts
import { faker } from "@faker-js/faker";

// CRITICAL: Always use a seed for deterministic, reproducible output across CI runs!
faker.seed(42); 

const users = Array.from({ length: 50 }, () => ({
  name: faker.person.fullName(),
  email: faker.internet.email(),
  role: faker.helpers.arrayElement(["admin", "user"]),
}));

console.log(JSON.stringify(users, null, 2));
```

**Execution & Injection via Bash:**
```bash
# Pipe directly to the API boundary using a pristine node container
set -euo pipefail
docker run --rm -v $(pwd)/scripts:/scripts node:lts-alpine npx -y -p tsx -p @faker-js/faker tsx /scripts/generate-bulk.ts | curl -sSf -X POST http://localhost:8000/api/users/bulk -H "Content-Type: application/json" -d @-
```

---

## 2. Queue & Event Bus Injection

True universal data generation requires pushing data into asynchronous boundaries (Redis, Kafka).

### Action: Piping Payloads to Workers
Generate the event payload using Dockerized Node, and pipe it directly into the Redis queue bypassing the API:

```bash
# Assuming the script outputs a JSON event string
set -euo pipefail
docker run --rm -v $(pwd)/scripts:/scripts node:lts-alpine npx -y -p tsx -p @faker-js/faker tsx /scripts/generate-event.ts | docker exec -i my_redis redis-cli -x LPUSH worker_queue
```

---

## 3. Direct-to-Database SQL Injection

If the backend doesn't have a bulk HTTP endpoint, generate raw SQL and inject it directly into the running database container.

### Action: Generating and Executing SQL

```typescript
// scripts/generate-sql.ts
import { faker } from "@faker-js/faker";
faker.seed(123);

for (let i = 0; i < 50; i++) {
  const name = faker.person.fullName().replace(/'/g, "''"); // escape quotes
  const email = faker.internet.email();
  console.log(`INSERT INTO users (name, email) VALUES ('${name}', '${email}');`);
}
```

```bash
# Execute directly against the container, bypassing host files
set -euo pipefail
docker run --rm -v $(pwd)/scripts:/scripts node:lts-alpine npx -y -p tsx -p @faker-js/faker tsx /scripts/generate-sql.ts | docker exec -i my_postgres_container psql -U postgres -d my_app_db
```

---

## 4. Direct State Assertion

After *any* operation (whether an API `.hurl` test, a UI interaction, or a queue injection), do not rely solely on the application's REST APIs to verify data persistence. Go straight to the underlying boundary.

### Action: Querying Docker State

**Verify a Database Soft-Delete:**
```bash
docker exec -i my_postgres_container psql -U postgres -d my_app_db -c "SELECT email, deleted_at FROM users WHERE email = 'target@test.com';"
```

**Verify a Redis Cache Eviction / Queue Processing:**
```bash
docker exec -i my_redis_container redis-cli LPOP analytics_queue
```