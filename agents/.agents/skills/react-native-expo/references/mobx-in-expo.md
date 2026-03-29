# MobX in Expo Reference

## RootStore Pattern

```tsx
// stores/RootStore.ts
import { createContext, useContext } from "react";
import { AuthStore } from "./AuthStore";
import { TodoStore } from "./TodoStore";

export class RootStore {
  authStore: AuthStore; todoStore: TodoStore;
  constructor() { this.authStore = new AuthStore(this); this.todoStore = new TodoStore(this); }
}
const rootStore = new RootStore();
const RootStoreContext = createContext(rootStore);
export const useStore = () => useContext(RootStoreContext);
export const RootStoreProvider = RootStoreContext.Provider;
```

```tsx
// app/_layout.tsx
const store = new RootStore();
export default function RootLayout() {
  return <RootStoreProvider value={store}>{/* app */}</RootStoreProvider>;
}
```

## makeAutoObservable vs makeObservable

| Method | When | Pros | Cons |
|--------|------|------|------|
| `makeAutoObservable(this)` | Most cases | Zero boilerplate | Less override control |
| `makeObservable(this, {})` | Override specific fields | Explicit | Verbose |

```tsx
// Auto (preferred)
import { makeAutoObservable } from "mobx";
class CounterStore {
  count = 0;
  constructor() { makeAutoObservable(this); }
  increment() { this.count++; }
  get doubled() { return this.count * 2; }
}

// Manual (overrides needed)
import { makeObservable, observable, action, computed } from "mobx";
class CounterStore {
  count = 0;
  constructor() {
    makeObservable(this, { count: observable, increment: action, doubled: computed });
  }
  increment() { this.count++; }
  get doubled() { return this.count * 2; }
}
```

## Computed Values

Cached derived state — recomputes only when dependencies change.

```tsx
class TodoStore {
  todos: Todo[] = [];
  filter: "all" | "active" | "done" = "all";
  constructor() { makeAutoObservable(this); }

  get filteredTodos() {
    if (this.filter === "active") return this.todos.filter(t => !t.done);
    if (this.filter === "done") return this.todos.filter(t => t.done);
    return this.todos;
  }
  get remaining() { return this.todos.filter(t => !t.done).length; }
}
```

## Actions (Sync & Async)

```tsx
import { runInAction } from "mobx";

class AuthStore {
  token: string | null = null; loading = false; error: string | null = null;
  constructor(private root: RootStore) { makeAutoObservable(this); }

  logout() { this.token = null; }

  async login(email: string, password: string) {
    this.loading = true; this.error = null;
    try {
      const res = await api.login(email, password);
      runInAction(() => { this.token = res.token; }); // required after await
    } catch (e: any) {
      runInAction(() => { this.error = e.message; });
    } finally {
      runInAction(() => { this.loading = false; });
    }
  }
}
```

**Key rule:** After any `await`, wrap mutations in `runInAction()`.

## observer() HOC

Components reading observables **must** use `observer()` to re-render.

```tsx
import { observer } from "mobx-react-lite";
import { useStore } from "@/stores/RootStore";

const TodoList = observer(() => {
  const { todoStore } = useStore();
  return <FlatList data={todoStore.filteredTodos}
    renderItem={({ item }) => (
      <TouchableOpacity onPress={() => todoStore.toggle(item.id)}>
        <Text className={item.done ? "line-through opacity-50" : ""}>{item.title}</Text>
      </TouchableOpacity>
    )} keyExtractor={item => item.id} />;
});
```

## Reactions

| Reaction | Runs When | RN Safe? |
|----------|-----------|----------|
| `autorun(fn)` | Any observed change | Use sparingly |
| `reaction(() => data, fn)` | Specific data changes | Yes |
| `when(() => pred, fn)` | Predicate true (once) | Yes |

```tsx
// Persist token on change — dispose in useEffect
const disposer = reaction(() => this.token, (token) => {
  if (token) AsyncStorage.setItem("token", token);
  else AsyncStorage.removeItem("token");
});
// Cleanup: disposer() in component's useEffect return

// Run once when ready
when(() => this.isAuthenticated, () => this.loadUserData());
```

**Avoid `autorun` in RN** — fire-hose behavior. Prefer `reaction`.

### Disposal in React Native

Reactions must be disposed when components unmount to prevent memory leaks:

```tsx
import { useEffect } from "react";
import { reaction } from "mobx";

// In a component or hook
useEffect(() => {
  const dispose = reaction(
    () => store.someValue,
    (value) => { /* side effect */ }
  );
  return dispose; // cleanup on unmount
}, []);
```

**Rule:** Always return the disposer from `useEffect`. Without this, navigation between screens leaks reactions.

## Store Composition

Stores reference siblings through RootStore — never directly.

```tsx
class TodoStore {
  constructor(private root: RootStore) { makeAutoObservable(this); }
  async fetchTodos() {
    const token = this.root.authStore.token;
    if (!token) return;
  }
}
```

## Async Template

```tsx
async someAction(args: Args) {
  this.loading = true; this.error = null;
  try {
    const result = await apiCall(args);
    runInAction(() => { this.data = result; });
  } catch (e: any) {
    runInAction(() => { this.error = e.message; });
  } finally { runInAction(() => { this.loading = false; }); }
}
```

## Testing

```tsx
it("increments", () => {
  const store = new CounterStore(null as any);
  store.increment();
  expect(store.count).toBe(1);
});

it("async action", async () => {
  const store = new AuthStore(null as any);
  jest.spyOn(api, "login").mockResolvedValue({ token: "abc" });
  await store.login("a@b.com", "pass");
  expect(store.token).toBe("abc");
  expect(store.loading).toBe(false);
});
```

## Common Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Forgetting `observer()` | Component won't re-render | Wrap with `observer()` |
| New objects in render | Excessive re-renders | Move to store or `useMemo` |
| Mutation after `await` without `runInAction` | "Computed leaked" warning | Wrap in `runInAction()` |
| Deep nested observables | Slow, hard to debug | Flatten state |
| Reading in non-observer | Stale UI | Wrap parent with `observer` |
| `useMemo` on observable deps | Won't track | Use `computed` in store |
