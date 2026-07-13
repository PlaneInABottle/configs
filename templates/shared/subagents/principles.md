<core-principles>

<solid-guidance>
Apply SOLID principles when they simplify current requirements. YAGNI and KISS take precedence over speculative extension points or unnecessary abstractions:

- SRP (Single Responsibility): Keep units focused; split them when multiple responsibilities create concrete maintenance problems.
- OCP (Open/Closed): Add extension points only when current requirements need multiple implementations or known variation.
- LSP (Liskov Substitution): Ensure subtypes preserve the contracts of their parent abstractions.
- ISP (Interface Segregation): Keep interfaces focused when interfaces are justified; do not create interfaces solely for compliance.
- DIP (Dependency Inversion): Introduce abstractions or injection when they reduce coupling or enable required testing, not by default.
</solid-guidance>

<general-architecture-commands>
- SoC (Separation of Concerns): Separate concerns when doing so makes behavior clearer and easier to change.
- DRY (Don't Repeat Yourself): Remove meaningful duplication after the shared concept is clear; do not abstract incidental similarity.
- KISS (Keep It Simple, Stupid): PRIORITIZE the simplest solution that works. REJECT complexity unless absolutely required.
- YAGNI (You Aren't Gonna Need It): IMPLEMENT ONLY what is requested NOW. REJECT speculative features.
</general-architecture-commands>

</core-principles>
