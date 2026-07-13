<design-pattern-guidance>
Use design patterns only when the current problem benefits from them. Prefer direct code for simple behavior:

- **Dependency Injection**: Use when dependencies vary, need isolation, or are supplied by the surrounding framework.
- **Repository Pattern**: Use when data access has multiple consumers or a meaningful domain boundary; avoid one-method wrapper interfaces.
- **Strategy Pattern**: Use for genuinely interchangeable algorithms or providers; keep small conditionals direct.
- **Factory Pattern**: Use when object creation has material branching or setup complexity.
- **Middleware/Wrappers**: Use for cross-cutting concerns shared across multiple entry points.
</design-pattern-guidance>
