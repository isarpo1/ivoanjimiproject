import { useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { ApiError } from '../api/types';

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const reason = params.get('reason');

  const [email, setEmail] = useState('customer@example.com');
  const [password, setPassword] = useState('Customer123!');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setBusy(true);
    try {
      await login(email.trim(), password);
      navigate('/', { replace: true });
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.message
          : 'Login failed. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-brand">
          <span className="auth-logo">⌂</span>
          <h1>Nesti</h1>
          <p className="muted">Find your next stay in Nigeria</p>
        </div>

        {reason === 'expired' && (
          <div className="info-notice" role="alert">
            Your session expired. Please log in again.
          </div>
        )}

        <form onSubmit={onSubmit} noValidate>
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              autoComplete="email"
              required
            />
          </label>
          <label className="field">
            <span>Password</span>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              autoComplete="current-password"
              required
            />
          </label>

          {error && (
            <div className="error-notice" role="alert">
              {error}
            </div>
          )}

          <button
            className="btn btn-primary btn-block"
            type="submit"
            disabled={busy}
          >
            {busy ? 'Logging in…' : 'Log in'}
          </button>
        </form>

        <p className="muted small center">
          Demo account is pre-filled — just hit Log in.
        </p>
      </div>
    </div>
  );
}
