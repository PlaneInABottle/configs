import { makeAutoObservable } from "mobx";
import type { RootStore } from "./RootStore";

export interface User {
  id: string;
  name: string;
  email: string;
}

export class UserStore {
  user: User | null = null;
  isLoggedIn = false;

  constructor(private root: RootStore) {
    makeAutoObservable(this);
  }

  setUser(user: User) {
    this.user = user;
    this.isLoggedIn = true;
  }

  clearUser() {
    this.user = null;
    this.isLoggedIn = false;
  }
}
