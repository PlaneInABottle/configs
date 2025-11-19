---
description: "Global AI development standards and best practices for all projects"
applyTo: "**"
---

# Global AI Development Standards

**Version:** 1.0.0
**Last Updated:** 2025-11-19
**Purpose:** Establish consistent coding practices, architecture patterns, and development standards across all projects using GitHub Copilot

---

## Core Philosophy

1. **Simplicity First** - Always choose the simplest solution that works
2. **Truth Always** - Never guess, invent, or assume. Always verify claims
3. **Escalate Gradually** - Simple → Refactor → New feature → Complex solutions
4. **Quality Over Speed** - Code is read more than it's written

---

## Project Structure & Organization

### File Organization
- Use feature-based folder structures (not layer-based)
- Co-locate related components, hooks, utilities, and tests
- Create barrel exports (`index.ts/index.js`) for clean imports
- Keep configuration files at the root level

### Naming Conventions
- **Components/Classes:** PascalCase (e.g., `UserProfile`, `ApiClient`)
- **Functions/Variables:** camelCase (e.g., `getUserData`, `isActive`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `MAX_RETRIES`, `API_BASE_URL`)
- **Files:** Match their primary export name

### TypeScript Guidelines
- Always enable strict mode: `"strict": true`
- Prefer explicit types over `any`
- Use interfaces for public APIs, types for internal details
- Annotate function parameters and return types
- Use generics for reusable logic

---

## Code Quality Standards

### Testing
- Write tests BEFORE implementation (TDD when possible)
- Test behavior, not implementation details
- Aim for >80% coverage on business logic
- Use descriptive test names that explain the "why"
- Mock external dependencies and side effects
- Test error scenarios and edge cases

### Code Style
- Use automated formatting (Prettier, gofmt, Black, etc.)
- Follow language-specific linting rules (ESLint, Pylint, etc.)
- Keep functions small and focused (single responsibility)
- Extract magic numbers and strings to named constants
- Write self-documenting code; let comments explain "why", not "what"

### Comments & Documentation
- Avoid obvious comments ("increment counter")
- Explain non-obvious decisions and trade-offs
- Document public APIs, complex algorithms, and gotchas
- Keep README files up-to-date with actual code
- Use type annotations instead of JSDoc type comments

---

## Architecture Patterns

### Separation of Concerns
- Keep business logic separate from UI/HTTP/Storage layers
- Use service/repository patterns for data access
- Implement middleware for cross-cutting concerns (auth, logging, error handling)
- Dependency injection for testability

### State Management
- Choose based on complexity: Props → Context/Local State → State Library
- Avoid prop drilling; use context or state management
- Keep state as close to usage as possible
- Centralize global state; decentralize component state

### Error Handling
- Fail fast with clear error messages
- Use custom error types for different scenarios
- Log errors with context (what operation, what data, what user)
- Return meaningful HTTP status codes
- Never swallow exceptions silently

---

## Dependency Management

### Selection Criteria
- Use built-ins and standard library first
- Check bundle size impact (bundlephobia.com)
- Prefer fewer, well-maintained dependencies over many small ones
- Document WHY each major dependency is needed
- Avoid dependencies for single functions

### Versioning Strategy
- Pin major versions for stability
- Allow patch updates for bug fixes
- Use `npm audit` or equivalent regularly
- Remove unused dependencies (dependency-cruiser, depcheck)
- Keep dependencies up-to-date

### Production vs Development
- Keep development-only packages separate
- Minimize production bundle size
- Tree-shake unused code
- Use dynamic imports for large optional features

---

## Development Workflow

### Git Practices
- Write clear commit messages (imperative mood, descriptive)
- Commit frequently with logical, atomic changes
- Create feature branches for non-trivial work
- Use PRs for code review and discussion
- Keep git history clean and linear when possible

### Code Review
- Review for correctness, maintainability, and consistency
- Check that tests exist and cover the changes
- Ensure documentation is updated
- Verify no secrets or sensitive data are committed
- Ask questions instead of demanding changes

### Before Committing
- Run all tests locally
- Run linting and formatting tools
- Verify the build succeeds
- Check that no debug code is included
- Review your own changes first

---

## Performance Guidelines

### Web Applications
- Lazy load large components and routes
- Use React.memo for expensive components
- Implement virtual scrolling for long lists
- Minimize main thread blocking
- Monitor Core Web Vitals (LCP, FID, CLS)

### Mobile Applications
- Minimize APK/IPA size
- Use efficient image formats and sizes
- Implement pagination for large lists
- Profile battery and memory usage
- Test on low-end devices

### Backend Services
- Use connection pooling for databases
- Implement caching strategies (Redis, CDN)
- Optimize database queries (indexes, eager loading)
- Use async/await and non-blocking operations
- Monitor and log slow operations

---

## Security Best Practices

### Data Protection
- Never log passwords, tokens, or sensitive data
- Use environment variables for secrets
- Encrypt sensitive data at rest and in transit
- Validate all user inputs
- Use parameterized queries (prepared statements)

### Authentication & Authorization
- Use established libraries (Passport, Auth0, Cognito)
- Implement rate limiting on auth endpoints
- Use strong password requirements
- Support multi-factor authentication when possible
- Store tokens securely (httpOnly cookies for web)

### Common Vulnerabilities
- Prevent SQL injection with parameterized queries
- Prevent XSS with proper HTML escaping
- Prevent CSRF with token validation
- Avoid hardcoded credentials
- Keep dependencies patched (npm audit)

---

## Language-Specific Guidelines

### TypeScript/JavaScript
- Use async/await over `.then()` chains
- Prefer `const` over `let` over `var`
- Use optional chaining (`?.`) and nullish coalescing (`??`)
- Avoid callback hell; use promises or async/await
- Use destructuring for cleaner code

### React
- Use functional components with hooks (no class components)
- Extract custom hooks for reusable logic
- Memoize expensive computations
- Use keys correctly in lists
- Keep components focused and testable

### Python
- Follow PEP 8 style guide (use black, pylint)
- Use type hints for all function signatures
- Use `async/await` for I/O-bound operations
- Avoid mutable default arguments
- Use context managers for resource management

### Go
- Use gofmt for formatting (enforced by tooling)
- Follow idiomatic Go patterns
- Use interfaces for abstraction
- Handle errors explicitly (no exceptions)
- Use goroutines carefully (avoid goroutine leaks)

### Rust
- Use rustfmt for formatting
- Follow Rust naming conventions
- Leverage the type system for safety
- Use `?` operator for error propagation
- Avoid `unwrap()` in library code

---

## AI Development Principles

### When Using AI Assistants
- Verify all code before accepting it
- Test the code thoroughly
- Understand what the code does (don't copy-paste blindly)
- Check for security vulnerabilities
- Ensure it follows project standards
- Ask for explanations of complex logic
- Use AI for ideas and exploration, not just code generation

### Effective Prompting
- Be specific about requirements and constraints
- Include relevant context (framework, patterns, style guide)
- Ask for code samples if learning something new
- Request explanations, not just code
- Iterate and refine prompts based on results
- Specify the "why" behind your request

### Code Review of AI Output
- Check error handling and edge cases
- Verify it follows the project style guide
- Ensure tests cover the functionality
- Look for security vulnerabilities
- Check performance implications
- Verify it integrates well with existing code

---

## Documentation Standards

### README.md
- Clear project description and purpose
- Quick start guide with concrete steps
- Architecture overview
- Contributing guidelines
- License information
- Links to additional resources

### Code Comments
- Explain WHY, not WHAT
- Document non-obvious algorithms
- Include examples for complex functions
- Note performance implications
- Reference related issues or discussions

### Commit Messages
Format: `<type>: <subject>`
Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- Use imperative mood ("add" not "added")
- First line ≤ 50 characters
- Wrap body at 72 characters
- Explain what and why, not how

---

## Continuous Integration & Deployment

### Automated Checks
- Linting and formatting on every commit
- Tests on every pull request
- Build verification before merge
- Security scanning (dependencies, secrets)
- Code coverage reporting

### Deployment Practices
- Automate deployment processes
- Use feature flags for safe rollouts
- Implement health checks and monitoring
- Have rollback procedures ready
- Track deployments and errors

---

## Team Collaboration

### Code Ownership
- Define ownership clearly (CODEOWNERS file)
- Balance autonomy with consistency
- Share knowledge through code reviews
- Document decisions in commit messages and PRs
- Celebrate improvements and learning

### Communication
- Keep issues and PRs focused and clear
- Use descriptive titles and comments
- Link related issues and PRs
- Prefer async communication (written over meetings)
- Document decisions for future reference

---

## Continuous Learning

### Stay Current
- Follow security advisories for dependencies
- Review library release notes quarterly
- Experiment with new patterns in side projects
- Share learnings with the team
- Attend relevant conferences or courses

### Technical Debt
- Schedule regular refactoring work
- Pay down accumulated debt proactively
- Document why you chose the quick fix
- Plan improvements for next sprint
- Keep "complexity hotspots" visible

---

## Red Flags & Anti-Patterns

### Code Smells
- God objects (doing too much)
- Deep nesting (>3 levels)
- Copy-paste code (refactor to functions)
- Long parameter lists (use objects)
- Comments that restate code

### Architecture Red Flags
- Tight coupling between modules
- Circular dependencies
- Global state everywhere
- Magic strings and numbers
- No clear separation of concerns

### Process Red Flags
- Frequent production bugs
- Slow test suites
- Difficult onboarding
- Knowledge locked in individuals
- Outdated documentation

---

## Decision-Making Framework

When facing a technical decision, ask:

1. **Simplicity:** Is this the simplest solution that works?
2. **Maintenance:** Will future developers understand this?
3. **Performance:** Does this meet performance requirements?
4. **Security:** Are there security implications?
5. **Testing:** Can this be tested thoroughly?
6. **Scalability:** Will this scale with the project?
7. **Cost:** What's the total cost of ownership?

**Rule of thumb:** If a decision doesn't clearly win on 4+ criteria, go with the simpler option.

---

## Quick Reference Checklist

Before submitting code:
- [ ] Code passes linting and formatting
- [ ] Tests are written and passing
- [ ] No console logs or debug code
- [ ] No hardcoded secrets or credentials
- [ ] Error handling is implemented
- [ ] Documentation is updated
- [ ] Commit message is clear
- [ ] Code follows project style guide
- [ ] No unnecessary dependencies added
- [ ] Performance impact considered
