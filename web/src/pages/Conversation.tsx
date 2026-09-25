import { useCallback, useEffect, useRef, useState } from 'react';
import type { FormEvent } from 'react';
import { Link, useParams } from 'react-router-dom';
import { api, formatDate } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import type { Conversation, ConversationMessage } from '../api/types';
import {
  EmptyState,
  ErrorNotice,
  Loading,
} from '../components/ui';

export default function ConversationThread() {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const [conversation, setConversation] =
    useState<Conversation | null>(null);
  const [messages, setMessages] = useState<ConversationMessage[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [draft, setDraft] = useState('');
  const [sending, setSending] = useState(false);
  const [sendError, setSendError] = useState('');
  const bottomRef = useRef<HTMLDivElement>(null);

  const load = useCallback(async () => {
    if (!id) return;
    try {
      const [conv, msgs] = await Promise.all([
        api<Conversation>(`/conversations/${id}`),
        api<ConversationMessage[]>(`/conversations/${id}/messages`),
      ]);
      setConversation(conv);
      setMessages(msgs);
      // Best-effort mark-as-read; ignore failures.
      api(`/conversations/${id}/read`, { method: 'PATCH' }).catch(
        () => undefined,
      );
    } catch (err: any) {
      setError(err?.message || 'Could not load this conversation.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  async function onSend(e: FormEvent) {
    e.preventDefault();
    const text = draft.trim();
    if (!text || !id) return;
    setSendError('');
    setSending(true);
    try {
      const msg = await api<ConversationMessage>(
        `/conversations/${id}/messages`,
        { method: 'POST', body: { message: text } },
      );
      setMessages((m) => [...m, msg]);
      setDraft('');
    } catch (err: any) {
      setSendError(err?.message || 'Could not send your message.');
    } finally {
      setSending(false);
    }
  }

  if (loading) return <Loading label="Loading conversation…" />;
  if (error)
    return (
      <div className="page narrow">
        <ErrorNotice message={error} onRetry={load} />
      </div>
    );
  if (!conversation)
    return (
      <div className="page narrow">
        <EmptyState
          title="Conversation not found"
          actionLabel="Back to messages"
          actionTo="/messages"
        />
      </div>
    );

  const other =
    conversation.guestId === user?.id
      ? conversation.host
      : conversation.guest;

  return (
    <div className="page narrow thread-page">
      <Link to="/messages" className="back-link">
        ← All messages
      </Link>
      <div className="thread-head">
        <h2>
          {other.firstName} {other.lastName}
        </h2>
        <p className="muted small">
          {conversation.property.title}
          {conversation.booking &&
            ` · ${formatDate(conversation.booking.checkIn)} → ${formatDate(
              conversation.booking.checkOut,
            )}`}
        </p>
      </div>

      <div className="thread" aria-live="polite">
        {messages.length === 0 && (
          <p className="muted center">
            No messages yet — say hello to{' '}
            {other.firstName}.
          </p>
        )}
        {messages.map((m) => {
          const mine = m.senderId === user?.id;
          return (
            <div
              key={m.id}
              className={`bubble ${mine ? 'mine' : 'theirs'}`}
            >
              <p>{m.message}</p>
              <span className="muted small">
                {formatDate(m.createdAt)}
              </span>
            </div>
          );
        })}
        <div ref={bottomRef} />
      </div>

      {sendError && (
        <div className="error-notice" role="alert">
          {sendError}
        </div>
      )}

      <form className="composer" onSubmit={onSend}>
        <input
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="Write a message…"
          maxLength={2000}
          aria-label="Message"
        />
        <button
          className="btn btn-primary"
          type="submit"
          disabled={sending || !draft.trim()}
        >
          {sending ? '…' : 'Send'}
        </button>
      </form>
    </div>
  );
}
