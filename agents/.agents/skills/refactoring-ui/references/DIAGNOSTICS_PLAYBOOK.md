# Diagnostics Playbook

## Common Mistakes

| Mistake | Why It Fails | Fix |
|---------|-------------|------|
| **"Looks amateur"** | Insufficient white space, unconstrained widths | Add more white space, constrain content widths |
| **"Feels flat"** | No depth differentiation between elements | Add subtle shadows, border-bottom on sections |
| **"Text is hard to read"** | Poor line-height, too wide, low contrast | Increase line-height, constrain width, boost contrast |
| **"Everything looks the same"** | No visual hierarchy between elements | Vary size/weight/color between primary and secondary |
| **"Feels cluttered"** | Equal spacing everywhere, no grouping | Group related items, increase spacing between groups |
| **"Colors clash"** | Random color choices without a system | Reduce saturation, use more grays, limit palette to system |
| **"Buttons don't pop"** | Low contrast with surrounding elements | Increase contrast with surroundings, add shadow |
| **Using arbitrary values** | px values like 13, 17, 23 create inconsistency | Stick to the spacing and type scales |

## Quick Diagnostic

Audit any UI design:

| Question | If No | Action |
|----------|-------|--------|
| Does hierarchy read when squinting (blur test)? | Elements competing for attention | Increase contrast between primary and secondary |
| Does it work in grayscale? | Relying on color for hierarchy | Strengthen size/weight/spacing hierarchy |
| Is there enough white space? | Probably not -- most designs are too dense | Increase spacing, especially between groups |
| Are labels de-emphasized vs. their values? | Labels competing with data | Make labels smaller, lighter, or uppercase-small |
| Does spacing follow a consistent scale? | Arbitrary spacing creates visual noise | Use 4/8/16/24/32/48/64 scale only |
| Is text width constrained for readability? | Long lines cause reader fatigue | Apply `max-w-prose` (~65ch) to text blocks |
| Do colors have sufficient contrast? | Accessibility failure, hard to read | Test with WCAG contrast checker, use gray-700+ on white |
| Are shadows appropriate for elevation? | Elements floating at wrong visual level | Match shadow scale to element purpose |
