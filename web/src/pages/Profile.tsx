import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { api, imageUrl } from '../api/client';

export default function Profile() {
  const { user, logout, refreshMe } = useAuth();
  const [becomingHost, setBecomingHost] = useState(false);
  const [hostError, setHostError] = useState('');
  const [confirmLogout, setConfirmLogout] = useState(false);

  async function becomeHost() {
    setHostError('');
    setBecomingHost(true);
    try {
      await api('/users/me/become-host', { method: 'PATCH' });
      await refreshMe();
    } catch (err: any) {
      setHostError(err?.message || 'Could not activate host mode.');
    } finally {
      setBecomingHost(false);
    }
  }

  if (!user) return null;

  return (
    <div className="page narrow">
      <h2 className="page-title">Profile</h2>

      <section className="detail-card profile-card">
        <div className="host-row">
          <div className="avatar large">
            {user.profilePhotoUrl ? (
              <img src={imageUrl(user.profilePhotoUrl)} alt="" />
            ) : (
              <span>
                {user.firstName[0]}
                {user.lastName[0]}
              </span>
            )}
          </div>
          <div>
            <h3>
              {user.firstName} {user.lastName}
            </h3>
            <p className="muted small">{user.email}</p>
            {user.isVerified && (
              <span className="verified">✓ Verified guest</span>
            )}
          </div>
        </div>
      </section>

      <section className="detail-card">
        <h3>Account details</h3>
        <dl className="detail-list">
          <div>
            <dt>First name</dt>
            <dd>{user.firstName}</dd>
          </div>
          <div>
            <dt>Last name</dt>
            <dd>{user.lastName}</dd>
          </div>
          <div>
            <dt>Email</dt>
            <dd>{user.email}</dd>
          </div>
          <div>
            <dt>Phone</dt>
            <dd>{user.phone || '—'}</dd>
          </div>
          <div>
            <dt>Member since</dt>
            <dd>
              {new Date(user.createdAt).toLocaleDateString('en-NG', {
                month: 'long',
                year: 'numeric',
              })}
            </dd>
          </div>
        </dl>
      </section>

      <section className="detail-card">
        <h3>Settings</h3>
        <ul className="settings-list">
          <li>
            <Link to="/messages">Messages</Link>
          </li>
          <li>
            <Link to="/favorites">Saved stays</Link>
          </li>
          <li>
            <Link to="/trips">My trips</Link>
          </li>
        </ul>

        {!user.isHost && (
          <div className="host-cta">
            <p className="small">
              Have a place to share? Become a host and list your property.
            </p>
            {hostError && (
              <div className="error-notice" role="alert">
                {hostError}
              </div>
            )}
            <button
              className="btn btn-secondary"
              onClick={becomeHost}
              disabled={becomingHost}
            >
              {becomingHost ? 'Activating…' : 'Become a host'}
            </button>
          </div>
        )}
        {user.isHost && (
          <p className="muted small">✓ Host mode is active on your account.</p>
        )}
      </section>

      <section className="detail-card">
        {confirmLogout ? (
          <div className="action-row">
            <button
              className="btn btn-danger"
              onClick={() => logout()}
            >
              Yes, log me out
            </button>
            <button
              className="btn btn-secondary"
              onClick={() => setConfirmLogout(false)}
            >
              Stay logged in
            </button>
          </div>
        ) : (
          <button
            className="btn btn-danger-outline btn-block"
            onClick={() => setConfirmLogout(true)}
          >
            Log out
          </button>
        )}
      </section>
    </div>
  );
}
