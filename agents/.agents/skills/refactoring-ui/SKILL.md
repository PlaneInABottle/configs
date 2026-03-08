---
name: refactoring-ui
description: 'Practical UI design system based on Adam Wathan & Steve Schoger''s "Refactoring UI". Use when you need to: (1) fix visual hierarchy problems, (2) choose consistent spacing and typography scales, (3) build color palettes with proper contrast, (4) add depth with shadows and layering, (5) design in grayscale first and add color last, (6) style components in Tailwind CSS, (7) make UI look professional without a designer.'
license: MIT
metadata:
  author: wondelai
  version: "1.1.0"
---

# Refactoring UI Design System

A practical, opinionated system for designing polished interfaces. Use this file for core decision-making, then open referenced files for implementation details.

## Core Principle

**Design in grayscale first. Add color last.** Build hierarchy with spacing, contrast, and type before introducing hue.

**Foundation:** Great UI comes from systems, not talent. Use constrained scales for spacing, typography, color, and shadows. Start with more whitespace than you think you need.

## Scoring

**Goal: 10/10.** Score designs from 0-10 based on the seven principles below. Always report the score and the top changes needed to reach 10/10.

## The Refactoring UI Framework

Use these seven principles for every UI:

### 1. Visual Hierarchy

Not everything can be important. Create emphasis using size, weight, and color.
- Combine levers carefully; avoid making everything large, bold, and dark.
- De-emphasize labels and metadata so content stands out.
- Keep ethical clarity: never hide critical terms with weak hierarchy.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#1-visual-hierarchy)

### 2. Spacing & Sizing

Use a constrained spacing scale; never invent random values.
- Default scale: 4, 8, 16, 24, 32, 48, 64.
- Keep spacing **between groups** larger than spacing **within groups**.
- Constrain widths (`~65ch` text blocks, ~300-500px forms).
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#2-spacing--sizing)

### 3. Typography

Use a modular type scale and context-appropriate line heights.
- Suggested scale: 12, 14, 16, 20, 24, 30, 36.
- Headings: tighter leading (1.0-1.25); body: relaxed leading (1.5-1.75).
- Keep body text ≥400 weight and limit to two font families.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#3-typography)

### 4. Color

Use systematic palettes, not ad-hoc colors.
- Build 5-9 shades per hue (50-900), including neutral grays with slight saturation.
- Keep text contrast accessible (4.5:1 body, 3:1 large text).
- Never rely on color alone; pair with text/icons.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#4-color)
Dark mode guidance: [theming-dark-mode.md](references/theming-dark-mode.md)

### 5. Depth & Shadows

Map elevation to purpose with a consistent shadow scale.
- Small shadows for raised controls; larger shadows for floating layers.
- Use layered shadows (tight + soft) for realism.
- If everything floats, nothing feels elevated.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#5-depth--shadows)

### 6. Images & Icons

Treat media as part of layout, not decoration.
- Size icons by context and keep icon style consistent.
- Use `object-fit: cover`, fixed aspect ratios, and overlays for legibility.
- Use honest visuals; never misrepresent product capabilities.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#6-images--icons)

### 7. Layout & Composition

Compose with intentional alignment and variation.
- Left-align by default; center only when context justifies it.
- Use constrained widths and selective emphasis to guide scanning.
- Never obscure user choices through layout manipulation.
Detailed patterns and examples: [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md#7-layout--composition)

## Non-Negotiables

- Keep hierarchy clear without hiding important information.
- Keep spacing and type on fixed scales.
- Keep contrast accessible in light and dark themes.
- Keep semantic meaning beyond color alone.

## Reference Map

Read these files as needed:

- [FOUNDATION_PRINCIPLES.md](references/FOUNDATION_PRINCIPLES.md): full principles with rationale, examples, CSS patterns, and ethical boundaries.
- [DIAGNOSTICS_PLAYBOOK.md](references/DIAGNOSTICS_PLAYBOOK.md): common failure modes and quick audit checklist.
- [RESOURCES_AND_ATTRIBUTION.md](references/RESOURCES_AND_ATTRIBUTION.md): books, source material, and author context.
- [advanced-patterns.md](references/advanced-patterns.md): interaction states, forms, responsive patterns, empty states.
- [animation-microinteractions.md](references/animation-microinteractions.md): animation timing and performance guidance.
- [accessibility-depth.md](references/accessibility-depth.md): WCAG 2.1 AA implementation checklist.
- [data-visualization.md](references/data-visualization.md): chart and dashboard UI guidance.
- [theming-dark-mode.md](references/theming-dark-mode.md): dark palette design and implementation.

## Execution Pattern

1. Start with grayscale composition.
2. Validate hierarchy, spacing, and typography before color.
3. Apply color and depth deliberately.
4. Run diagnostics from [DIAGNOSTICS_PLAYBOOK.md](references/DIAGNOSTICS_PLAYBOOK.md).
