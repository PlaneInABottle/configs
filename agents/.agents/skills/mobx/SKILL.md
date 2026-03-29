---
name: mobx
description: "Implement reactive state management with MobX. Use when: creating observable stores, defining actions and computed values, connecting stores to React components with observer, handling async state updates, designing store architecture (RootStore pattern), or debugging reactivity issues. Triggers on 'add mobx store', 'create observable', 'mobx observer', 'state management', 'store pattern', or any MobX-related task."
---

# MobX

## Overview

MobX provides transparent reactive state management. Observable state automatically triggers re-renders in `observer`-wrapped components. Works with React, React Native, and vanilla JS/TS. Composes with react-native-expo (mobile) projects.

## Quick Start

```bash
npm install mobx mobx-react-lite
```

```ts
import { makeAutoObservable } from 'mobx'
import { observer } from 'mobx-react-lite'

// Store
class CounterStore {
  count = 0
  constructor() { makeAutoObservable(this) }
  increment() { this.count++ }
  get doubled() { return this.count * 2 }
}

const store = new CounterStore()

// React component
const Counter = observer(() => (
  <button onClick={() => store.increment()}>
    {store.count} (doubled: {store.doubled})
  </button>
))
```

## Core Concepts

| Concept | MobX Primitive | Purpose |
|---------|---------------|---------|
| **Observable** | `observable`, `makeObservable`, `makeAutoObservable` | Reactive state that triggers tracking |
| **Action** | `action`, `makeAutoObservable` | Functions that mutate state |
| **Computed** | `computed` (getters) | Derived values, cached automatically |
| **Observer** | `observer()` from `mobx-react-lite` | React binding — subscribes to observables used in render |

## Creating Stores

Use class-based stores with `makeAutoObservable` — it auto-infers `observable` fields, `action` methods, and `computed` getters.

```ts
import { makeAutoObservable } from 'mobx'

class TodoStore {
  todos: Todo[] = []
  filter: 'all' | 'active' | 'done' = 'all'

  constructor() {
    makeAutoObservable(this)
  }

  addTodo(text: string) {
    this.todos.push({ id: Date.now(), text, done: false })
  }

  get filteredTodos() {
    if (this.filter === 'active') return this.todos.filter(t => !t.done)
    if (this.filter === 'done') return this.todos.filter(t => t.done)
    return this.todos
  }
}
```

**Rule:** Every method that mutates state must be an action. Every derived value should be a computed getter.

## RootStore Pattern

Use a singleton `RootStore` that owns all feature stores and passes itself for cross-store communication.

```ts
class RootStore {
  userStore: UserStore
  todoStore: TodoStore

  constructor() {
    this.userStore = new UserStore(this)
    this.todoStore = new TodoStore(this)
    makeAutoObservable(this)
  }
}
```

Expose via React context. See `references/store-patterns.md` for full RootStore + context setup, feature store separation, and store-to-store communication patterns.

## Async Actions

Async updates **must** wrap mutations in `runInAction` — MobX cannot track async boundaries automatically.

```ts
import { runInAction } from 'mobx'

async loadUsers() {
  this.loading = true
  try {
    const users = await api.getUsers()
    runInAction(() => {
      this.users = users
      this.loading = false
    })
  } catch (e) {
    runInAction(() => {
      this.error = String(e)
      this.loading = false
    })
  }
}
```

See `references/async-and-reactions.md` for the `runInAction` pattern, `autorun`/`reaction`/`when` comparison, disposal, and common async pitfalls.

## Computed Values

Computed getters are **cached** and only re-evaluate when their dependencies change. Use them for any derived data.

```ts
get incompleteCount() {
  return this.todos.filter(t => !t.done).length
}
```

**When to use computed vs action:** If it derives from existing state → computed. If it sets new state → action. Never store what you can derive.

## Observer Pattern

`observer()` wraps a React component so it re-renders when any observable accessed during render changes.

```tsx
import { observer } from 'mobx-react-lite'

const TodoList = observer(({ store }: { store: TodoStore }) => (
  <ul>
    {store.filteredTodos.map(t => <li key={t.id}>{t.text}</li>)}
  </ul>
))
```

**Why it matters:** Observer subscribes at the *component* level. Wrap every component that reads observables — not just top-level ones. This is MobX's main performance win: fine-grained reactivity.

**Common mistakes:**
- Forgetting `observer()` on a component that reads observables (no re-renders)
- Destructuring props outside render (breaks tracking)
- Passing observable objects through non-observer intermediate components

## Reactions

`autorun`, `reaction`, and `when` run side effects when observables change. Use sparingly in React — most needs are covered by `observer` + `useEffect`.

| Reaction | Runs when | Use case |
|----------|-----------|----------|
| `autorun` | Any tracked observable changes | Logging, syncing to localStorage |
| `reaction` | Specific tracked value changes | Debounced saves, specific side effects |
| `when` | Predicate becomes true once | One-time initialization |

**Rule of thumb:** Prefer `observer` for rendering. Use reactions only for non-UI side effects. Always dispose reactions in cleanup. See `references/async-and-reactions.md` for disposal patterns.

## Testing Stores

Stores are plain classes — test them without React. See `references/testing-mobx.md` for patterns covering unit tests, computed values, async actions, and observer components.

## Debugging

- **`trace()`** — call inside a computed or reaction to log why it re-evaluated
- **`spy()`** — global listener for all MobX events (actions, reactions, observables)
- **`mobx-react-lite` + React DevTools** — observer components show re-render reasons when `observer({})` debugging is enabled

## Composing With Other Skills

| Skill | How it composes |
|-------|----------------|
| `ai-native-workflow` | MobX stores tested via the workflow's Hurl/Faker toolchain |
| `agent-browser` | Verify observer components render and update via browser automation |
| `react-native-expo` | MobX stores in Expo projects — see `references/store-patterns.md` for RootStore + React Context |

## Anti-patterns

- **Mutating state outside actions** — works but breaks devtools and strict mode
- **Storing derived data** — use computed getters instead
- **Over-using reactions** — prefer `observer` for UI, `useEffect` for non-MobX side effects
- **Observable for everything** — primitives like booleans are fine; don't over-wrap
- **Deep nesting** — keep observable trees flat; use maps/arrays at the top level
- **Forgetting `observer`** — the #1 cause of "MobX doesn't re-render" bugs

## References

- **`references/store-patterns.md`** — RootStore, feature stores, store-to-store, async stores, form stores
- **`references/async-and-reactions.md`** — runInAction, autorun/reaction/when, disposal, async pitfalls
- **`references/testing-mobx.md`** — Testing stores, computed values, async actions, observer components
