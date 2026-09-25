import { useCallback, useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { Link, useLocation, useNavigate, useParams } from 'react-router-dom';
import {
  api,
  formatDate,
  formatNaira,
  imageUrl,
  nightsBetween,
} from '../api/client';
import type { Booking } from '../api/types';
import {
  EmptyState,
  ErrorNotice,
  Loading,
  Stars,
  StatusPill,
} from '../components/ui';

export default function BookingDetails() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const location = useLocation() as {
    state?: { justBooked?: boolean };
  };

  const [booking, setBooking] = useState<Booking | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actionError, setActionError] = useState('');
  const [cancelling, setCancelling] = useState(false);
  const [confirmCancel, setConfirmCancel] = useState(false);
  const [messaging, setMessaging] = useState(false);

  // Leave-a-review state
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState('');
  const [reviewBusy, setReviewBusy] = useState(false);
  const [reviewDone, setReviewDone] = useState(false);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError('');
    try {
      const data = await api<Booking>(`/bookings/${id}`);
      setBooking(data);
      if (data.review) setReviewDone(true);
    } catch (err: any) {
      setError(err?.message || 'Could not load this booking.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  async function onCancel() {
    if (!booking) return;
    setActionError('');
    setCancelling(true);
    try {
      await api(`/bookings/${booking.id}/cancel`, { method: 'PATCH' });
      await load();
      setConfirmCancel(false);
    } catch (err: any) {
      setActionError(
        err?.message || 'Could not cancel this booking.',
      );
    } finally {
      setCancelling(false);
    }
  }

  async function messageHost() {
    if (!booking) return;
    setActionError('');
    setMessaging(true);
    try {
      const conv = await api<{ id: string }>('/conversations', {
        method: 'POST',
        body: {
          propertyId: booking.propertyId,
          bookingId: booking.id,
        },
      });
      navigate(`/messages/${conv.id}`);
    } catch (err: any) {
      setActionError(
        err?.message || 'Could not open a conversation with the host.',
      );
    } finally {
      setMessaging(false);
    }
  }

  async function submitReview(e: FormEvent) {
    e.preventDefault();
    if (!booking) return;
    setActionError('');
    setReviewBusy(true);
    try {
      await api('/reviews', {
        method: 'POST',
        body: {
          bookingId: booking.id,
          rating,
          comment: comment.trim() || undefined,
        },
      });
      setReviewDone(true);
      await load();
    } catch (err: any) {
      setActionError(
        err?.message || 'Could not submit your review.',
      );
    } finally {
      setReviewBusy(false);
    }
  }

  if (loading) return <Loading label="Loading booking…" />;
  if (error)
    return (
      <div className="page">
        <ErrorNotice message={error} onRetry={load} />
      </div>
    );
  if (!booking)
    return (
      <div className="page">
        <EmptyState
          title="Booking not found"
          actionLabel="Back to trips"
          actionTo="/trips"
        />
      </div>
    );

  const p = booking.property;
  const cover =
    p.images?.find((i) => i.isCover) ?? p.images?.[0];
  const nights = nightsBetween(booking.checkIn, booking.checkOut);
  const canCancel = booking.status === 'PENDING';
  const canReview =
    booking.status === 'COMPLETED' && !reviewDone && !booking.review;

  return (
    <div className="page narrow">
      <Link to="/trips" className="back-link">
        ← Back to trips
      </Link>

      {location.state?.justBooked && (
        <div className="info-notice" role="status">
          Booking confirmed — we’re looking forward to hosting you!
        </div>
      )}

      <div className="booking-head">
        <h2>{p.title}</h2>
        <StatusPill status={booking.status} />
      </div>
      <p className="muted">
        {p.address} · {p.city}, {p.state}
      </p>

      {cover && (
        <img
          className="booking-cover"
          src={imageUrl(cover.imageUrl)}
          alt={p.title}
        />
      )}

      <section className="detail-card">
        <h3>Trip details</h3>
        <dl className="detail-list">
          <div>
            <dt>Check-in</dt>
            <dd>{formatDate(booking.checkIn)}</dd>
          </div>
          <div>
            <dt>Check-out</dt>
            <dd>{formatDate(booking.checkOut)}</dd>
          </div>
          <div>
            <dt>Nights</dt>
            <dd>{nights}</dd>
          </div>
          <div>
            <dt>Guests</dt>
            <dd>{booking.guestCount}</dd>
          </div>
          <div>
            <dt>Nightly rate</dt>
            <dd>{formatNaira(booking.nightlyRate)}</dd>
          </div>
          <div>
            <dt>Service fee</dt>
            <dd>{formatNaira(booking.serviceFee)}</dd>
          </div>
          <div className="total">
            <dt>Total paid</dt>
            <dd>{formatNaira(booking.total)}</dd>
          </div>
        </dl>
      </section>

      {actionError && (
        <div className="error-notice" role="alert">
          {actionError}
        </div>
      )}

      <div className="action-row">
        <button
          className="btn btn-secondary"
          onClick={messageHost}
          disabled={messaging}
        >
          {messaging ? 'Opening…' : 'Message host'}
        </button>
        <Link
          className="btn btn-secondary"
          to={`/properties/${p.id}`}
        >
          View stay
        </Link>
        {canCancel &&
          (confirmCancel ? (
            <>
              <button
                className="btn btn-danger"
                onClick={onCancel}
                disabled={cancelling}
              >
                {cancelling ? 'Cancelling…' : 'Confirm cancellation'}
              </button>
              <button
                className="btn btn-secondary"
                onClick={() => setConfirmCancel(false)}
                disabled={cancelling}
              >
                Keep booking
              </button>
            </>
          ) : (
            <button
              className="btn btn-danger-outline"
              onClick={() => setConfirmCancel(true)}
            >
              Cancel booking
            </button>
          ))}
      </div>

      {booking.status === 'CANCELLED' && (
        <div className="info-notice">
          This booking was cancelled. No further charges apply.
        </div>
      )}

      {canReview && (
        <section className="detail-card">
          <h3>How was your stay?</h3>
          <p className="muted small">
            Your review helps other guests and your host.
          </p>
          <form onSubmit={submitReview}>
            <div className="rating-input" role="radiogroup" aria-label="Rating">
              {[1, 2, 3, 4, 5].map((n) => (
                <button
                  key={n}
                  type="button"
                  className={`rate-star ${n <= rating ? 'on' : ''}`}
                  onClick={() => setRating(n)}
                  aria-label={`${n} star${n === 1 ? '' : 's'}`}
                  aria-pressed={n === rating}
                >
                  ★
                </button>
              ))}
            </div>
            <label className="field">
              <span>Comment (optional)</span>
              <textarea
                value={comment}
                onChange={(e) => setComment(e.target.value)}
                placeholder="What did you love about this stay?"
                rows={4}
                maxLength={2000}
              />
            </label>
            <button
              className="btn btn-primary"
              type="submit"
              disabled={reviewBusy}
            >
              {reviewBusy ? 'Submitting…' : 'Submit review'}
            </button>
          </form>
        </section>
      )}

      {reviewDone && booking.review && (
        <section className="detail-card">
          <h3>Your review</h3>
          <Stars rating={booking.review.rating} />
          {booking.review.comment && <p>{booking.review.comment}</p>}
          <p className="muted small">
            Submitted {formatDate(booking.review.createdAt)}
          </p>
        </section>
      )}
    </div>
  );
}
