---
title: Hoist callbacks to the root of lists
impact: MEDIUM
impactDescription: Fewer re-renders and faster lists
tags: lists, callbacks, rendering
---

## List performance callbacks

**Impact: HIGH (Fewer re-renders and faster lists)**

When callback identity causes memoized list items to rerender, pass one parent
handler plus the item identifier. Do not add `useCallback` by default when the
project uses React Compiler or profiling shows no callback-related cost.

**Incorrect (creates a new callback on each render):**

```typescript
return (
  <LegendList
    renderItem={({ item }) => {
      // bad: creates a new callback on each render
      const onPress = () => handlePress(item.id)
      return <Item key={item.id} item={item} onPress={onPress} />
    }}
  />
)
```

**Correct (pass the parent handler and item identifier):**

```typescript
return (
  <LegendList
    renderItem={({ item }) => (
      <Item id={item.id} item={item} onPress={handlePress} />
    )}
  />
)
```

The item can call `onPress(id)`. Stabilize `handlePress` only when required by
the surrounding code or supported by profiling.
