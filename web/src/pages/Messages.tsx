import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api, formatDate, imageUrl } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import type { Conversation } from '../api/types';
import {
  EmptyState,
  ErrorNotice,
  Loading,
} from '../components/ui';

export default function Messages() {
  const { user } = useAuth();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await api<Conversation[]>('/conversations/me');
        if (!cancelled) setConversations(data);
      } catch (err: any) {
        if (!cancelled)
          setError(err?.message || 'Could not load messages.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) return <Loading label="Loading messages…" />;

  return (
    <div className="page narrow">
      <h2 className="page-title">Messages</h2>
      {error && (
        <ErrorNotice
          message={error}
          onRetry={() => window.location.reload()}
        />
      )}
      {!error && conversations.length === 0 && (
        <EmptyState
          title="No conversations yet"
          body="Message a host from any stay or booking to start chatting."
          actionLabel="Explore stays"
          actionTo="/explore"
        />
      )}
      <ul className="conversation-list">
        {conversations.map((c) => {
          const other = c.guestId === user?.id ? c.host : c.guest;
          const lastMessage = c.lastMessage ?? c.messages?.[0] ?? null;
          const cover =
            c.property.images?.find((i) => i.isCover) ??
            c.property.images?.[0];
          return (
            <li key={c.id}>
              <Link to={`/messages/${c.id}`} className="conversation-row">
                <div className="conv-avatar">
                  {cover ? (
                    <img
                      src={imageUrl(cover.imageUrl)}
                      alt=""
                      loading="lazy"
                    />
                  ) : (
                    <span>
                      {other.firstName[0]}
                      {other.lastName[0]}
                    </span>
                  )}
                </div>
                <div className="conv-body">
                  <div className="conv-top">
                    <strong>
                      {other.firstName} {other.lastName}
                    </strong>
                    <span className="muted small">
                      {formatDate(c.updatedAt)}
                    </span>
                  </div>
                  <p className="muted small">{c.property.title}</p>
                  {lastMessage && (
                    <p className="conv-preview">
                      {lastMessage.senderId === user?.id ? 'You: ' : ''}
                      {lastMessage.message}
                    </p>
                  )}
                </div>
              </Link>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
