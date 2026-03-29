import React, { createContext, useContext, useEffect, useState } from 'react';
import { Session, User } from '@supabase/supabase-js';
import { supabase } from './supabase-client';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface AuthState {
  session: Session | null;
  user: User | null;
  loading: boolean;
}

interface AuthContextValue extends AuthState {
  signOut: () => Promise<void>;
}

// ---------------------------------------------------------------------------
// Context
// ---------------------------------------------------------------------------

const AuthContext = createContext<AuthContextValue>({
  session: null,
  user: null,
  loading: true,
  signOut: async () => {},
});

export function useAuth(): AuthContextValue {
  return useContext(AuthContext);
}

export function useSession(): Session | null {
  const { session } = useContext(AuthContext);
  return session;
}

export function useUser(): User | null {
  const { user } = useContext(AuthContext);
  return user;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    session: null,
    user: null,
    loading: true,
  });

  useEffect(() => {
    // Restore persisted session on mount
    supabase.auth.getSession().then(({ data: { session } }) => {
      setState({ session, user: session?.user ?? null, loading: false });
    });

    // Listen for auth events (sign in, sign out, token refresh)
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setState({ session, user: session?.user ?? null, loading: false });
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const signOut = async () => {
    await supabase.auth.signOut();
    setState({ session: null, user: null, loading: false });
  };

  return (
    <AuthContext.Provider value={{ ...state, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

// ---------------------------------------------------------------------------
// Route guard hook (for navigation-based auth)
// ---------------------------------------------------------------------------

/**
 * Call in a root layout/screen to redirect unauthenticated users.
 * Returns the current loading state so you can show a spinner.
 *
 * @example
 * ```tsx
 * export default function HomeScreen() {
 *   const loading = useRequireAuth('/login');
 *   if (loading) return <ActivityIndicator />;
 *   return <Text>Welcome!</Text>;
 * }
 * ```
 */
export function useRequireAuth(redirectTo: string): boolean {
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading && !user) {
      // Replace with your router push:
      // router.replace(redirectTo);
      console.log(`Not authenticated — redirect to ${redirectTo}`);
    }
  }, [user, loading, redirectTo]);

  return loading;
}
