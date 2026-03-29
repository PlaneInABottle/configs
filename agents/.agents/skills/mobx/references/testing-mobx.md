# Testing MobX Stores

## Testing Stores in Isolation

Stores are plain classes — no React, no DOM needed.

```ts
import { TodoStore } from '../stores/TodoStore'

describe('TodoStore', () => {
  let store: TodoStore

  beforeEach(() => {
    store = new TodoStore()
  })

  it('starts empty', () => {
    expect(store.todos).toEqual([])
  })

  it('adds a todo', () => {
    store.addTodo('Buy milk')
    expect(store.todos).toHaveLength(1)
    expect(store.todos[0].text).toBe('Buy milk')
    expect(store.todos[0].done).toBe(false)
  })

  it('toggles done', () => {
    store.addTodo('Buy milk')
    store.toggleTodo(store.todos[0].id)
    expect(store.todos[0].done).toBe(true)
  })
})
```

## Testing Computed Values

Computed getters behave like pure functions — assert their output after mutations.

```ts
it('filters active todos', () => {
  store.addTodo('A')
  store.addTodo('B')
  store.toggleTodo(store.todos[0].id)

  expect(store.filteredTodos).toHaveLength(1)
  expect(store.filteredTodos[0].text).toBe('B')
})

it('counts incomplete', () => {
  store.addTodo('A')
  store.addTodo('B')
  store.addTodo('C')
  store.toggleTodo(store.todos[0].id)

  expect(store.incompleteCount).toBe(2)
})
```

## Testing Async Actions with Fake Timers

Mock API calls and use `runInAction`-compatible patterns. Flush promises to observe final state.

```ts
import { runInAction } from 'mobx'

// Mock API
const mockApi = {
  getUsers: jest.fn()
}

describe('UserStore async', () => {
  let store: UserStore

  beforeEach(() => {
    store = new UserStore(rootStore)
    jest.clearAllMocks()
  })

  it('loads users', async () => {
    const users = [{ id: 1, name: 'Alice' }]
    mockApi.getUsers.mockResolvedValue(users)

    await store.fetchUsers()

    expect(store.loading).toBe(false)
    expect(store.users).toEqual(users)
    expect(store.error).toBeNull()
  })

  it('handles errors', async () => {
    mockApi.getUsers.mockRejectedValue(new Error('Network error'))

    await store.fetchUsers()

    expect(store.loading).toBe(false)
    expect(store.error).toContain('Network error')
    expect(store.users).toEqual([])
  })
})
```

## Testing Observer Components

Use `@testing-library/react` to render and assert DOM updates when store state changes.

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Counter } from './Counter'
import { CounterStore } from '../stores/CounterStore'

it('re-renders on increment', () => {
  const store = new CounterStore()
  render(<Counter store={store} />)

  expect(screen.getByText(/0/)).toBeTruthy()

  fireEvent.click(screen.getByRole('button'))

  expect(screen.getByText(/1/)).toBeTruthy()
})
```

**Key pattern:** Create a fresh store per test, pass it as a prop (or via context). The component's `observer` wrapper handles reactivity automatically — no need for `act()` when using MobX with React Testing Library.

## Tips

- **No React needed for store tests** — test stores as plain classes for speed
- **Assert computed values** after state changes, not during
- **Mock at the API boundary**, not inside the store
- **One store per test** — avoid shared state between tests
- **Use `runInAction`** in test helpers that set observable state directly
