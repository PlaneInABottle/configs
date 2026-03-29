# Store Patterns

## RootStore + React Context

Singleton root store passed via React context. Every feature store receives the root for cross-store access.

```ts
// stores/RootStore.ts
import { makeAutoObservable } from 'mobx'
import { createContext, useContext } from 'react'

class UserStore {
  user: User | null = null
  constructor(private root: RootStore) { makeAutoObservable(this) }
  get isLoggedIn() { return this.user !== null }
}

class TodoStore {
  todos: Todo[] = []
  constructor(private root: RootStore) { makeAutoObservable(this) }
  get userTodos() {
    if (!this.root.userStore.isLoggedIn) return []
    return this.todos.filter(t => t.userId === this.root.userStore.user!.id)
  }
}

class RootStore {
  userStore: UserStore
  todoStore: TodoStore
  constructor() {
    this.userStore = new UserStore(this)
    this.todoStore = new TodoStore(this)
    makeAutoObservable(this)
  }
}

const rootStore = new RootStore()
const RootStoreContext = createContext(rootStore)

export const useStore = () => useContext(RootStoreContext)
export { RootStore }
```

Usage in components:

```tsx
import { useStore } from '../stores/RootStore'
import { observer } from 'mobx-react-lite'

const TodoCount = observer(() => {
  const { todoStore } = useStore()
  return <span>{todoStore.userTodos.length} todos</span>
})
```

## Feature Store Pattern

Separate stores by domain (user, todo, notification). Each store owns its state, actions, and computed values. Cross-store communication goes through the root store reference — never import one store into another directly.

```
stores/
├── RootStore.ts      (composition root)
├── UserStore.ts
├── TodoStore.ts
└── NotificationStore.ts
```

## Store-to-Store Communication

Access sibling stores via `this.root`. Keep cross-store reads in computed values; keep cross-store writes in actions.

```ts
class NotificationStore {
  constructor(private root: RootStore) { makeAutoObservable(this) }

  // Read from sibling store
  get unreadForCurrentUser() {
    const userId = this.root.userStore.user?.id
    return this.notifications.filter(n => n.userId === userId && !n.read)
  }

  // Write triggered by sibling store event
  notifyTodoAssigned(todo: Todo) {
    this.addNotification(`Todo assigned: ${todo.title}`)
  }
}
```

## Async Store Pattern

Stores that fetch data should track `loading`, `error`, and `data` as separate observables.

```ts
class UserStore {
  users: User[] = []
  loading = false
  error: string | null = null

  constructor(private root: RootStore) { makeAutoObservable(this) }

  get hasLoaded() { return !this.loading && this.error === null }

  async fetchUsers() {
    this.loading = true
    this.error = null
    try {
      const users = await api.getUsers()
      runInAction(() => { this.users = users; this.loading = false })
    } catch (e) {
      runInAction(() => { this.error = String(e); this.loading = false })
    }
  }
}
```

## Form Store Pattern

Dedicated store per form. Tracks field values, validation errors, and submission state.

```ts
import { makeAutoObservable, runInAction } from 'mobx'

class LoginFormStore {
  email = ''
  password = ''
  errors: Record<string, string> = {}
  submitting = false

  constructor() { makeAutoObservable(this) }

  setField(field: string, value: string) {
    (this as any)[field] = value
    delete this.errors[field]
  }

  validate() {
    this.errors = {}
    if (!this.email.includes('@')) this.errors.email = 'Invalid email'
    if (this.password.length < 8) this.errors.password = 'Min 8 chars'
    return Object.keys(this.errors).length === 0
  }

  async submit() {
    if (!this.validate()) return
    this.submitting = true
    try {
      await api.login(this.email, this.password)
      runInAction(() => { this.submitting = false })
    } catch (e) {
      runInAction(() => {
        this.errors.form = String(e)
        this.submitting = false
      })
    }
  }

  reset() {
    this.email = ''
    this.password = ''
    this.errors = {}
    this.submitting = false
  }
}
```

**Tip:** Create form stores per-use (`new LoginFormStore()`), not as singletons. Dispose when the form unmounts.
