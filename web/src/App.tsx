import { NavLink, Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { OfflineBanner } from './components/ui';
import Login from './pages/Login';
import Home from './pages/Home';
import Explore from './pages/Explore';
import PropertyDetails from './pages/PropertyDetails';
import Trips from './pages/Trips';
import BookingDetails from './pages/BookingDetails';
import Messages from './pages/Messages';
import ConversationThread from './pages/Conversation';
import Favorites from './pages/Favorites';
import Profile from './pages/Profile';

const TABS = [
  { to: '/', label: 'Home', icon: '⌂', end: true },
  { to: '/explore', label: 'Explore', icon: '⚲' },
  { to: '/trips', label: 'Trips', icon: '🧳' },
  { to: '/messages', label: 'Messages', icon: '✉' },
  { to: '/favorites', label: 'Saved', icon: '♥' },
  { to: '/profile', label: 'Profile', icon: '◉' },
];

function Shell() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="loading-wrap full">
        <div className="spinner" />
        <p>Starting Nesti…</p>
      </div>
    );
  }

  if (!user && location.pathname !== '/login') {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="app">
      <OfflineBanner />
      {user && (
        <header className="topbar">
          <NavLink to="/" className="brand small">
            <span className="brand-mark">⌂</span> Nesti
          </NavLink>
          <nav className="topnav">
            {TABS.map((t) => (
              <NavLink
                key={t.to}
                to={t.to}
                end={t.end}
                className={({ isActive }) =>
                  `topnav-link ${isActive ? 'active' : ''}`
                }
              >
                {t.label}
              </NavLink>
            ))}
          </nav>
        </header>
      )}

      <main className="main">
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Home />} />
          <Route path="/explore" element={<Explore />} />
          <Route path="/properties/:id" element={<PropertyDetails />} />
          <Route path="/trips" element={<Trips />} />
          <Route path="/trips/:id" element={<BookingDetails />} />
          <Route path="/messages" element={<Messages />} />
          <Route path="/messages/:id" element={<ConversationThread />} />
          <Route path="/favorites" element={<Favorites />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>

      {user && (
        <nav className="tabbar" aria-label="Primary">
          {TABS.map((t) => (
            <NavLink
              key={t.to}
              to={t.to}
              end={t.end}
              className={({ isActive }) =>
                `tab ${isActive ? 'active' : ''}`
              }
            >
              <span className="tab-icon" aria-hidden>
                {t.icon}
              </span>
              <span className="tab-label">{t.label}</span>
            </NavLink>
          ))}
        </nav>
      )}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <Shell />
    </AuthProvider>
  );
}
