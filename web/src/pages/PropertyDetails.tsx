import { useCallback, useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  api,
  formatDate,
  formatNaira,
  imageUrl,
  nightsBetween,
} from '../api/client';
import type {
  Booking,
  Property,
  PropertyReviewsResponse,
} from '../api/types';
import { useFavorites } from '../hooks/useFavorites';
import {
  EmptyState,
  ErrorNotice,
  Loading,
  RatingBadge,
  Stars,
} from '../components/ui';

export default function PropertyDetails() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { favoriteIds, toggle, supported } = useFavorites();

  const [property, setProperty] = useState<Property | null>(null);
  const [reviews, setReviews] = useState<PropertyReviewsResponse | null>(
    null,
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [photoIndex, setPhotoIndex] = useState(0);

  const [checkIn, setCheckIn] = useState('');
  const [checkOut, setCheckOut] = useState('');
  const [guests, setGuests] = useState('2');
  const [bookingError, setBookingError] = useState('');
  const [bookingBusy, setBookingBusy] = useState(false);

  const load = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    setError('');
    try {
      const [p, r] = await Promise.all([
        api<Property>(`/properties/${id}`),
        api<PropertyReviewsResponse>(
          `/properties/${id}/reviews`,
        ).catch(() => null),
      ]);
      setProperty(p);
      setReviews(r);
    } catch (err: any) {
      setError(err?.message || 'Could not load this stay.');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const nights =
    checkIn && checkOut ? nightsBetween(checkIn, checkOut) : 0;
  const nightly = property ? Number(property.pricePerNight) : 0;
  const subtotal = nightly * nights;
  const serviceFee = Math.round(subtotal * 0.1);
  const total = subtotal + serviceFee;

  async function onReserve(e: FormEvent) {
    e.preventDefault();
    setBookingError('');
    if (!property) return;
    if (!checkIn || !checkOut) {
      setBookingError('Pick your check-in and check-out dates.');
      return;
    }
    const ci = new Date(checkIn);
    const co = new Date(checkOut);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (ci < today) {
      setBookingError('Check-in can’t be in the past.');
      return;
    }
    if (co <= ci) {
      setBookingError('Check-out must be after check-in.');
      return;
    }
    const g = Number(guests);
    if (!g || g < 1) {
      setBookingError('Add at least 1 guest.');
      return;
    }
    if (g > property.maxGuests) {
      setBookingError(
        `This stay allows a maximum of ${property.maxGuests} guests.`,
      );
      return;
    }

    setBookingBusy(true);
    try {
      const booking = await api<Booking>('/bookings', {
        method: 'POST',
        body: {
          propertyId: property.id,
          checkIn,
          checkOut,
          guestCount: g,
        },
      });
      // Mock payment flow: initialize then simulate success for the demo.
      const payment = await api<{ id: string }>(
        '/payments/mock/initialize',
        { method: 'POST', body: { bookingId: booking.id } },
      );
      await api(`/payments/${payment.id}/mock-success`, {
        method: 'POST',
      });
      navigate(`/trips/${booking.id}`, {
        state: { justBooked: true },
      });
    } catch (err: any) {
      setBookingError(
        err?.message || 'Booking failed. Please try again.',
      );
    } finally {
      setBookingBusy(false);
    }
  }

  async function messageHost() {
    if (!property) return;
    try {
      const conv = await api<{ id: string }>('/conversations', {
        method: 'POST',
        body: { propertyId: property.id },
      });
      navigate(`/messages/${conv.id}`);
    } catch (err: any) {
      setBookingError(
        err?.message || 'Could not start a conversation.',
      );
    }
  }

  if (loading) return <Loading label="Loading stay…" />;
  if (error)
    return (
      <div className="page">
        <ErrorNotice message={error} onRetry={load} />
      </div>
    );
  if (!property)
    return (
      <div className="page">
        <EmptyState title="Stay not found" actionLabel="Explore stays" actionTo="/explore" />
      </div>
    );

  const images = property.images ?? [];
  const cover = images[photoIndex] ?? images[0];
  const isFav = favoriteIds.has(property.id);

  return (
    <div className="page property-page">
      <div className="gallery">
        <div className="gallery-main">
          {cover ? (
            <img src={imageUrl(cover.imageUrl)} alt={property.title} />
          ) : (
            <div className="img-placeholder tall">No photos yet</div>
          )}
          {supported && (
            <button
              className={`fav-btn large ${isFav ? 'active' : ''}`}
              onClick={() => toggle(property)}
              aria-label={isFav ? 'Remove from favorites' : 'Save to favorites'}
            >
              {isFav ? '♥' : '♡'}
            </button>
          )}
        </div>
        {images.length > 1 && (
          <div className="gallery-thumbs">
            {images.map((img, i) => (
              <button
                key={img.id}
                className={`thumb ${i === photoIndex ? 'active' : ''}`}
                onClick={() => setPhotoIndex(i)}
                aria-label={`Photo ${i + 1}`}
              >
                <img src={imageUrl(img.imageUrl)} alt="" loading="lazy" />
              </button>
            ))}
          </div>
        )}
      </div>

      <div className="property-layout">
        <div className="property-main">
          <div className="property-head">
            <div>
              <h2>{property.title}</h2>
              <p className="muted">
                {property.address} · {property.city}, {property.state}
              </p>
              <p className="muted small">
                {property.bedrooms} bedrooms · {property.bathrooms} bathrooms
                · up to {property.maxGuests} guests
              </p>
            </div>
            <RatingBadge
              average={property.averageRating}
              count={property.reviewCount}
            />
          </div>

          <section>
            <h3>About this stay</h3>
            <p className="description">{property.description}</p>
          </section>

          {property.amenities && property.amenities.length > 0 && (
            <section>
              <h3>Amenities</h3>
              <ul className="amenity-list">
                {property.amenities.map((a) => (
                  <li key={a.amenity.id}>{a.amenity.name}</li>
                ))}
              </ul>
            </section>
          )}

          {property.host && (
            <section className="host-card">
              <h3>Meet your host</h3>
              <div className="host-row">
                <div className="avatar">
                  {property.host.profilePhotoUrl ? (
                    <img
                      src={imageUrl(property.host.profilePhotoUrl)}
                      alt=""
                    />
                  ) : (
                    <span>
                      {property.host.firstName[0]}
                      {property.host.lastName[0]}
                    </span>
                  )}
                </div>
                <div>
                  <p>
                    <strong>
                      {property.host.firstName} {property.host.lastName}
                    </strong>{' '}
                    {property.host.isVerified && (
                      <span className="verified">✓ Verified</span>
                    )}
                  </p>
                  <button
                    className="btn btn-secondary btn-sm"
                    onClick={messageHost}
                  >
                    Message host
                  </button>
                </div>
              </div>
            </section>
          )}

          <section id="reviews">
            <div className="section-head">
              <h3>
                Reviews{' '}
                {reviews && (
                  <span className="muted">
                    ({reviews.summary.reviewCount})
                  </span>
                )}
              </h3>
              {reviews && reviews.summary.reviewCount > 0 && (
                <Stars rating={reviews.summary.averageRating} />
              )}
            </div>
            {!reviews || reviews.reviews.length === 0 ? (
              <p className="muted">No reviews yet — be the first to stay here.</p>
            ) : (
              <ul className="review-list">
                {reviews.reviews.map((r) => (
                  <li key={r.id} className="review">
                    <div className="review-head">
                      <strong>
                        {r.user
                          ? `${r.user.firstName} ${r.user.lastName}`
                          : 'Guest'}
                      </strong>
                      <Stars rating={r.rating} />
                    </div>
                    {r.comment && <p>{r.comment}</p>}
                    <p className="muted small">{formatDate(r.createdAt)}</p>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </div>

        <aside className="booking-widget">
          <p className="booking-price">
            <strong>{formatNaira(property.pricePerNight)}</strong>
            <span className="muted"> / night</span>
          </p>
          <form onSubmit={onReserve}>
            <div className="booking-dates">
              <label className="field">
                <span>Check-in</span>
                <input
                  type="date"
                  value={checkIn}
                  onChange={(e) => setCheckIn(e.target.value)}
                />
              </label>
              <label className="field">
                <span>Check-out</span>
                <input
                  type="date"
                  value={checkOut}
                  onChange={(e) => setCheckOut(e.target.value)}
                />
              </label>
            </div>
            <label className="field">
              <span>Guests</span>
              <input
                type="number"
                min={1}
                max={property.maxGuests}
                value={guests}
                onChange={(e) => setGuests(e.target.value)}
              />
            </label>

            {nights > 0 && (
              <div className="price-breakdown">
                <div>
                  <span>
                    {formatNaira(nightly)} × {nights} night
                    {nights === 1 ? '' : 's'}
                  </span>
                  <span>{formatNaira(subtotal)}</span>
                </div>
                <div>
                  <span>Service fee</span>
                  <span>{formatNaira(serviceFee)}</span>
                </div>
                <div className="total">
                  <span>Total</span>
                  <span>{formatNaira(total)}</span>
                </div>
              </div>
            )}

            {bookingError && (
              <div className="error-notice" role="alert">
                {bookingError}
              </div>
            )}

            <button
              className="btn btn-primary btn-block"
              type="submit"
              disabled={bookingBusy}
            >
              {bookingBusy ? 'Reserving…' : 'Reserve'}
            </button>
            <p className="muted small center">
              Demo checkout — payment is simulated.
            </p>
          </form>
        </aside>
      </div>
    </div>
  );
}
