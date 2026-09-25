import { ApiError } from './types';

const API_URL =
  (import.meta as any).env?.VITE_API_URL || 'http://localhost:3000';

const TOKEN_KEY = 'nesti_token';
const USER_KEY = 'nesti_user';

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setSession(token: string, user: unknown) {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function getStoredUser<T>(): T | null {
  try {
    const raw = localStorage.getItem(USER_KEY);
    return raw ? (JSON.parse(raw) as T) : null;
  } catch {
    return null;
  }
}

/** Fired when the API returns 401 so the app can redirect to login. */
export const authEvents = new EventTarget();
export const AUTH_EXPIRED_EVENT = 'auth-expired';

export function isOnline(): boolean {
  return typeof navigator === 'undefined' ? true : navigator.onLine;
}

interface RequestOptions {
  method?: string;
  body?: unknown;
  /** Skip attaching the auth token (for login/register). */
  public?: boolean;
}

export async function api<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  if (!isOnline()) {
    throw new ApiError(
      0,
      'You appear to be offline. Check your internet connection and try again.',
    );
  }

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  if (!options.public) {
    const token = getToken();
    if (token) headers['Authorization'] = `Bearer ${token}`;
  }

  let res: Response;
  try {
    res = await fetch(`${API_URL}${path}`, {
      method: options.method || 'GET',
      headers,
      body:
        options.body !== undefined
          ? JSON.stringify(options.body)
          : undefined,
    });
  } catch (e) {
    throw new ApiError(
      0,
      'Could not reach the server. Check your connection and try again.',
    );
  }

  if (res.status === 401) {
    if (!options.public) {
      clearSession();
      authEvents.dispatchEvent(new Event(AUTH_EXPIRED_EVENT));
    }
    let data: any = null;
    try {
      data = await res.json();
    } catch {
      // non-JSON body
    }
    const message =
      (data && (data.message || data.error)) ||
      'Your session has expired. Please log in again.';
    const msg = Array.isArray(message) ? message.join(', ') : message;
    throw new ApiError(401, msg);
  }

  if (res.status === 204) return undefined as T;

  let data: any = null;
  try {
    data = await res.json();
  } catch {
    // non-JSON body
  }

  if (!res.ok) {
    const message =
      (data && (data.message || data.error)) ||
      `Request failed (${res.status})`;
    const msg = Array.isArray(message) ? message.join(', ') : message;
    throw new ApiError(res.status, msg);
  }

  return data as T;
}

export function imageUrl(url: string | null | undefined): string {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) return url;
  return `${API_URL}${url.startsWith('/') ? '' : '/'}${url}`;
}

export function formatNaira(amount: string | number): string {
  const n = typeof amount === 'string' ? Number(amount) : amount;
  if (Number.isNaN(n)) return '₦0';
  return '₦' + n.toLocaleString('en-NG', { maximumFractionDigits: 0 });
}

export function formatDate(iso: string): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString('en-NG', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

export function nightsBetween(checkIn: string, checkOut: string): number {
  const ms = new Date(checkOut).getTime() - new Date(checkIn).getTime();
  return Math.max(0, Math.round(ms / (1000 * 60 * 60 * 24)));
}
