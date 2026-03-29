---
name: cicd-pipeline
description: "Create, configure, and debug CI/CD pipelines for GitHub Actions and GitLab CI. Use when setting up automated builds, tests, deployments, continuous integration, continuous deployment, or fixing broken pipelines, failed deployments, or workflow errors."
---

# CI/CD Pipeline

Create and manage CI/CD pipelines using GitHub Actions and GitLab CI.

## Quick Start

```bash
# Create GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test
EOF
```

## When to Use This Skill

- **Creating CI pipelines**: Automated testing on push/PR
- **Creating CD pipelines**: Automated deployments
- **Debugging failures**: Fix broken pipeline runs
- **Adding workflows**: New automation for builds, tests, deploys

## GitHub Actions

### Basic CI Workflow

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build
        run: npm run build
```

### Matrix Testing

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20, 22]
        operating-system: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.operating-system }}
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

### Deployment Workflow

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to production
        env:
          API_TOKEN: ${{ secrets.API_TOKEN }}
        run: |
          echo "Deploying..."
          # Add deployment commands
```

### Artifact & Cache

```yaml
steps:
  - uses: actions/checkout@v4
  
  - name: Cache dependencies
    uses: actions/cache@v4
    with:
      path: ~/.npm
      key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-npm-
  
  - name: Upload artifact
    uses: actions/upload-artifact@v4
    with:
      name: build-${{ github.sha }}
      path: dist/
```

### Secrets & Environment

```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
    run: deploy.sh
    
# Use environments for protection
# .github/workflows/deploy.yml references environment: production
```

## GitLab CI

### Basic Pipeline

```yaml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  image: node:20
  script:
    - npm ci
    - npm test
  artifacts:
    reports:
      junit: junit.xml

build:
  stage: build
  image: node:20
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  script:
    - echo "Deploying..."
  only:
    - main
```

### Multiple Environments

```yaml
deploy_staging:
  stage: deploy
  script: echo "Deploy to staging"
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_production:
  stage: deploy
  script: echo "Deploy to production"
  environment:
    name: production
    url: https://example.com
  only:
    - main
```

### Matrix Jobs

```yaml
test:
  script: npm test
  parallel:
    matrix:
      - NODE_VERSION: [18, 20, 22]
        OS: [ubuntu, windows]
```

## Common Patterns

### Run Tests & Lint

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
      
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test
```

### Conditional Execution

```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'package.json'
      - '.github/workflows/**'
```

### Manual Approval

```yaml
deploy:
  stage: deploy
  when: manual
  script: echo "Deploying..."
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Job not running | Check `on` trigger conditions |
| Permission errors | Add proper `permissions:` or check secrets |
| Timeout | Increase `timeout-minutes` |
| Cache miss | Verify cache key pattern |
| Action not found | Check action version exists |

## References

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitLab CI Docs](https://docs.gitlab.com/ee/ci/)

## See Also

- [ai-native-workflow](./ai-native-workflow) - Testing in CI/CD
- [pm2-runtime-operator](./pm2-runtime-operator) - Process deployment