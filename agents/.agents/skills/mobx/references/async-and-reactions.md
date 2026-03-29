# Async Actions and Reactions

## runInAction — The Only Correct Pattern

MobX tracks observable access synchronously. After `await`, the tracking context is lost. **Always** wrap post-await mutations in `runInAction`.

```ts
import { runInAction } from 'mobx'

class UserStore {
  users: User[] = []
  loading = false
  error: string | null = null

  async fetchUsers() {
    this.loading = true  // ✅ inside synchronous action boundary
    try {
      const users = await api.getUsers()
      // ❌ this.users = users  — tracking context lost after await
      runInAction(() => {
        this.users = users       // ✅
        this.loading = false     // ✅
      })
    } catch (e) {
      runInAction(() => {
        this.error = String(e)   // ✅
        this.loading = false     // ✅
      })
    }
  }
}
```

Multiple mutations after one `await` go in a single `runInAction` call.

## autorun vs reaction vs when

| | `autorun` | `reaction` | `when` |
|---|-----------|-----------|--------|
| **Triggers on** | Any tracked observable change | Change to specifically tracked expression | Predicate becomes truthy |
| **Runs immediately** | Yes | No (first change only) | No |
| **Runs repeatedly** | Yes | Yes | Once, then disposes |
| **Best for** | Logging, syncing to external systems | Debounced saves, targeted side effects | One-time init, waiting for a condition |

### autorun
```ts
// Runs immediately, then on every change to any tracked observable
const dispose = autorun(() => console.log('Todos:', store.todos.length))
dispose()
```

### reaction
```ts
// Does NOT run immediately — fires only when data expression changes
const dispose = reaction(
  () => store.todos.length,
  (count, prev) => console.log(`Count: ${prev} → ${count}`)
)
dispose()
```

### when
```ts
// Returns a promise — resolves once when predicate is true, then auto-disposes
await when(() => store.isReady)
// Or manual dispose for cleanup
const dispose = when(() => store.todos.length > 10, () => console.log('Hit 10!'))
dispose()
```

## Disposing Reactions

Every reaction returns a disposer. Call it in `useEffect` cleanup or when the owning object is destroyed.

```tsx
import { useEffect } from 'react'
import { autorun } from 'mobx'

const MyComponent = observer(({ store }) => {
  useEffect(() => {
    const dispose = autorun(() => {
      localStorage.setItem('todos', JSON.stringify(store.todos))
    })
    return dispose // cleanup on unmount
  }, [store])

  return <div>{store.todos.length}</div>
})
```

**Rule:** If a reaction is tied to a component lifecycle, use `useEffect` to create and dispose it. If it's app-global, dispose it when the app shuts down.

## Common Async Pitfalls

### 1. Awaiting outside action
```ts
// ❌ Bad — tracking context lost after await
async load() {
  this.loading = true
  const data = await fetch(url)
  this.items = data
}
// ✅ Good
async load() {
  this.loading = true
  const data = await fetch(url)
  runInAction(() => { this.items = data })
}
```

### 2. Forgetting `runInAction` in `.then()` chains
```ts
// ❌ Bad:  fetch(url).then(data => { this.items = data })
// ✅ Good: fetch(url).then(data => runInAction(() => { this.items = data }))
```

### 3. Side effects in computed getters
```ts
// ❌ Bad — computed must be pure, no mutations
get sortedTodos() {
  this.lastAccessed = Date.now()  // side effect!
  return this.todos.slice().sort(...)
}
```

### 4. Creating reactions without cleanup
```tsx
// ❌ Bad — new reaction every render, leaks
const Component = observer(({ store }) => {
  autorun(() => console.log(store.count))
  return <div />
})
// ✅ Good — disposed on unmount
const Component = observer(({ store }) => {
  useEffect(() => { const d = autorun(() => console.log(store.count)); return d }, [store])
  return <div />
})
