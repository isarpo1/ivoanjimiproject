import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  api,
  formatDate,
  formatNaira,
  imageUrl,
} from '../api/client';
import type { Booking } from '../api/types';
import {
  EmptyState,
  ErrorNotice,
  Loading,
  StatusPill,
} from '../components/ui';

export default function Trips() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const data = await api<Booking[]>('/bookings/me');
        if (!cancelled) setBookings(data);
      } catch (err: any) {
        if (!cancelled)
          setError(err?.message || 'Could not load your trips.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  if (loading) return <Loading label="Loading your trips…" />;

  return (
    <div className="page">
      <h2 className="page-title">Trips</h2>
      {error && (
        <ErrorNotice
          message={error}
          onRetry={() => window.location.reload()}
        />
      )}
      {!error && bookings.length === 0 && (
        <EmptyState
          title="No trips yet"
          body="When you book a stay, it will show up here."
          actionLabel="Explore stays"
          actionTo="/explore"
        />
      )}
      <div className="trip-list">
        {bookings.map((b) => {
          const cover =
            b.property.images?.find((i) => i.isCover) ??
            b.property.images?.[0];
          return (
            <Link
              key={b.id}
              to={`/trips/${b.id}`}
              className="trip-card"
            >
              <div className="trip-media">
                {cover ? (
                  <img
                    src={imageUrl(cover.imageUrl)}
                    alt={b.property.title}
                    loading="lazy"
                  />
                ) : (
                  <div className="img-placeholder">No photo</div>
                )}
              </div>
              <div className="trip-body">
                <div className="trip-top">
                  <strong>{b.property.title}</strong>
                  <StatusPill status={b.status} />
                </div>
                <p className="muted small">
                  {b.property.city}, {b.property.state}
                </p>
                <p className="small">
                  {formatDate(b.checkIn)} → {formatDate(b.checkOut)} ·{' '}
                  {b.guestCount} guest{b.guestCount === 1 ? '' : 's'}
                </p>
                <p className="small">
                  <strong>{formatNaira(b.total)}</strong>
                </p>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
