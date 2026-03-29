import { createContext, useContext } from "react";
import { UserStore } from "./UserStore";

export class RootStore {
  userStore: UserStore;

  constructor() {
    this.userStore = new UserStore(this);
  }
}

const rootStore = new RootStore();

const RootStoreContext = createContext<RootStore>(rootStore);

export const RootStoreProvider = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  return (
    <RootStoreContext.Provider value={rootStore}>
      {children}
    </RootStoreContext.Provider>
  );
};

export const useRootStore = () => useContext(RootStoreContext);
export const useUserStore = () => useContext(RootStoreContext).userStore;
