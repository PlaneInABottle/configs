# Playbook: Mocking External Dependencies

**Goal:** Test your application without hitting real external APIs (e.g., Stripe, SendGrid, GitHub). 

**Core Principle:** *The Only Thing That Changes is the URL.* 
Never alter application code to support testing. Use environment variables to point the application to local mock servers.

---

## 1. Instant CRUD Mocks with JSON-Server

When you need a quick, generic REST API that maintains state (Create, Read, Update, Delete) for testing your frontend or backend integration.

### Action: Spinning up JSON-Server

1. Create a `db.json` file representing the initial state:
   ```json
   {
     "posts": [
       { "id": 1, "title": "Hello World", "author": "Agent" }
     ],
     "comments": []
   }
   ```

2. Run the mock server via Docker to ensure it doesn't pollute your host environment:
   ```bash
   # Use Docker to keep the host environment pure
   docker rm -f mock_json_server 2>/dev/null || true
   docker run -d --rm --name mock_json_server -p 4000:80 -v $(pwd)/db.json:/data/db.json clue/json-server
   
   # After testing: docker stop mock_json_server
   ```

3. Configure your app to point to it:
   ```env
   # .env
   EXTERNAL_BLOG_API_URL=http://localhost:4000
   ```

---

## 2. Strict Contract Mocking with Prism

When you need to mock a strict, complex 3rd-party API (like Stripe or GitHub) and ensure your application is sending the exact right payload shapes.

### Action: Spinning up Prism

1. Obtain the OpenAPI Specification (OAS) file for the 3rd party (e.g., `stripe-spec.json`).
2. Run Prism via Docker to generate a mock server that strictly enforces the schema:
   ```bash
   docker rm -f mock_prism 2>/dev/null || true
   docker run -d --rm --name mock_prism -p 4010:4010 -v $(pwd)/stripe-spec.json:/tmp/stripe-spec.json stoplight/prism mock -h 0.0.0.0 /tmp/stripe-spec.json
   ```
3. Update environment variables:
   ```env
   # .env
   STRIPE_API_URL=http://localhost:4010
   ```
*(Prism will now return dynamic, realistic mock data based on the OAS schema, and throw errors if your app sends invalid requests).*

### Debugging Prism Mocks
Because Prism is running detached, if your application fails to communicate with the mock (e.g., throwing 400 Bad Request), you **must** read the container logs to see the strict schema validation errors:
```bash
docker logs --tail 50 mock_prism
```

---

## 3. Simulating Network Faults with WireMock

When you need to verify how your application handles timeouts, 500 errors, or malformed responses.

### Action: Simulating a Timeout

1. Start WireMock via Docker (YAGNI: only do this if specifically testing faults). **Always use `-d` (detached) rather than `-it` to prevent blocking the agent's shell:**
   ```bash
   docker rm -f wiremock_test 2>/dev/null || true
   docker run -d --name wiremock_test --rm -p 8080:8080 wiremock/wiremock:latest
   ```

2. Wait for WireMock to become ready before configuring it:
   ```bash
   curl --retry 10 --retry-connrefused --retry-delay 1 --retry-max-time 30 -sSf http://localhost:8080/__admin/docs > /dev/null
   ```

3. Configure a delayed response via its Admin API:
   ```bash
   curl -sSf -X POST http://localhost:8080/__admin/mappings \
     -d '{
           "request": {
             "method": "GET",
             "url": "/api/flaky-service"
           },
           "response": {
             "status": 200,
             "fixedDelayMilliseconds": 5000,
             "body": "{\"status\":\"success\"}"
           }
         }'
   ```
4. Trigger your application and verify it gracefully handles the 5-second delay.
5. Cleanup: `docker stop wiremock_test`
