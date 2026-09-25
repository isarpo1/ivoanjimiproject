import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import type { ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  api,
  AUTH_EXPIRED_EVENT,
  authEvents,
  clearSession,
  getStoredUser,
  getToken,
  setSession,
} from '../api/client';
import type { LoginResponse, User } from '../api/types';

interface AuthContextValue {
  user: User | null;
  token: string | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: (reason?: string) => void;
  refreshMe: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const [user, setUser] = useState<User | null>(() =>
    getStoredUser<User>(),
  );
  const [token, setToken] = useState<string | null>(() => getToken());
  const [loading, setLoading] = useState(true);

  const logout = useCallback(
    (reason?: string) => {
      clearSession();
      setUser(null);
      setToken(null);
      navigate(
        reason ? `/login?reason=${encodeURIComponent(reason)}` : '/login',
      );
    },
    [navigate],
  );

  // Expired/invalid token anywhere in the app -> force re-login.
  useEffect(() => {
    const handler = () => logout('expired');
    authEvents.addEventListener(AUTH_EXPIRED_EVENT, handler);
    return () =>
      authEvents.removeEventListener(AUTH_EXPIRED_EVENT, handler);
  }, [logout]);

  // Validate the stored token on boot.
  useEffect(() => {
    let cancelled = false;
    (async () => {
      if (!getToken()) {
        setLoading(false);
        return;
      }
      try {
        const me = await api<User>('/users/me');
        if (!cancelled) {
          setUser(me);
          const t = getToken();
          if (t) setSession(t, me);
        }
      } catch {
        if (!cancelled) {
          clearSession();
          setUser(null);
          setToken(null);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const res = await api<LoginResponse>('/auth/login', {
      method: 'POST',
      public: true,
      body: { email, password },
    });
    setSession(res.accessToken, res.user);
    setUser(res.user);
    setToken(res.accessToken);
  }, []);

  const refreshMe = useCallback(async () => {
    const me = await api<User>('/users/me');
    setUser(me);
    const t = getToken();
    if (t) setSession(t, me);
  }, []);

  const value = useMemo(
    () => ({ user, token, loading, login, logout, refreshMe }),
    [user, token, loading, login, logout, refreshMe],
  );

  return (
    <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
