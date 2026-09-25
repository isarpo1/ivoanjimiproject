import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { formatNaira, imageUrl } from '../api/client';
import type { Property } from '../api/types';

export function Loading({ label = 'Loading…' }: { label?: string }) {
  return (
    <div className="loading-wrap" role="status" aria-live="polite">
      <div className="spinner" />
      <p>{label}</p>
    </div>
  );
}

export function EmptyState({
  title,
  body,
  actionLabel,
  actionTo,
}: {
  title: string;
  body?: string;
  actionLabel?: string;
  actionTo?: string;
}) {
  return (
    <div className="empty-state">
      <div className="empty-icon">◌</div>
      <h3>{title}</h3>
      {body && <p>{body}</p>}
      {actionLabel && actionTo && (
        <Link className="btn btn-primary" to={actionTo}>
          {actionLabel}
        </Link>
      )}
    </div>
  );
}

export function ErrorNotice({
  message,
  onRetry,
}: {
  message: string;
  onRetry?: () => void;
}) {
  return (
    <div className="error-notice" role="alert">
      <p>{message}</p>
      {onRetry && (
        <button className="btn btn-secondary btn-sm" onClick={onRetry}>
          Try again
        </button>
      )}
    </div>
  );
}

export function OfflineBanner() {
  const [online, setOnline] = useState(
    typeof navigator === 'undefined' ? true : navigator.onLine,
  );
  useEffect(() => {
    const goOnline = () => setOnline(true);
    const goOffline = () => setOnline(false);
    window.addEventListener('online', goOnline);
    window.addEventListener('offline', goOffline);
    return () => {
      window.removeEventListener('online', goOnline);
      window.removeEventListener('offline', goOffline);
    };
  }, []);
  if (online) return null;
  return (
    <div className="offline-banner" role="alert">
      You’re offline — some actions won’t work until you reconnect.
    </div>
  );
}

export function Stars({
  rating,
  size = 14,
}: {
  rating: number;
  size?: number;
}) {
  const full = Math.round(rating);
  return (
    <span
      className="stars"
      style={{ fontSize: size }}
      aria-label={`${rating.toFixed(1)} out of 5 stars`}
    >
      {[1, 2, 3, 4, 5].map((i) => (
        <span key={i} className={i <= full ? 'star on' : 'star'}>
          ★
        </span>
      ))}
    </span>
  );
}

export function RatingBadge({
  average,
  count,
}: {
  average?: number;
  count?: number;
}) {
  if (!average || !count) return <span className="rating-new">New</span>;
  return (
    <span className="rating-badge">
      ★ {average.toFixed(1)} <span className="muted">({count})</span>
    </span>
  );
}

export function StatusPill({ status }: { status: string }) {
  const cls = `pill pill-${status.toLowerCase()}`;
  const label = status
    .toLowerCase()
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (c) => c.toUpperCase());
  return <span className={cls}>{label}</span>;
}

export function PropertyCard({
  property,
  isFavorite,
  onToggleFavorite,
}: {
  property: Property;
  isFavorite?: boolean;
  onToggleFavorite?: (property: Property) => void;
}) {
  const cover =
    property.images?.find((i) => i.isCover) ?? property.images?.[0];
  return (
    <article className="property-card">
      <Link
        to={`/properties/${property.id}`}
        className="property-card-media"
        aria-label={property.title}
      >
        {cover ? (
          <img
            src={imageUrl(cover.imageUrl)}
            alt={property.title}
            loading="lazy"
          />
        ) : (
          <div className="img-placeholder">No photo</div>
        )}
        <span className="price-tag">
          {formatNaira(property.pricePerNight)}
          <span className="muted"> / night</span>
        </span>
      </Link>
      {onToggleFavorite && (
        <button
          className={`fav-btn ${isFavorite ? 'active' : ''}`}
          onClick={() => onToggleFavorite(property)}
          aria-label={
            isFavorite ? 'Remove from favorites' : 'Save to favorites'
          }
          aria-pressed={!!isFavorite}
        >
          {isFavorite ? '♥' : '♡'}
        </button>
      )}
      <div className="property-card-body">
        <div className="property-card-top">
          <span className="muted small">
            {property.city}, {property.state}
          </span>
          <RatingBadge
            average={property.averageRating}
            count={property.reviewCount}
          />
        </div>
        <Link
          to={`/properties/${property.id}`}
          className="property-card-title"
        >
          {property.title}
        </Link>
        <p className="muted small">
          {property.bedrooms} bed · {property.bathrooms} bath · up to{' '}
          {property.maxGuests} guests
        </p>
      </div>
    </article>
  );
}
