import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import type { Property, PropertySearchResponse } from '../api/types';
import { useFavorites } from '../hooks/useFavorites';
import {
  EmptyState,
  ErrorNotice,
  Loading,
  PropertyCard,
} from '../components/ui';

const CITIES = ['Lagos', 'Abuja', 'Port Harcourt', 'Ibadan'];

export default function Home() {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const { favoriteIds, toggle, supported } = useFavorites();

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const res = await api<PropertySearchResponse>(
          '/properties?limit=8&sort=newest',
        );
        if (!cancelled) setProperties(res.data);
      } catch (err: any) {
        if (!cancelled)
          setError(err?.message || 'Could not load stays.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <div className="page">
      <section className="hero">
        <h2>Find a place you’ll love to stay</h2>
        <p className="muted">
          Handpicked short-term rentals across Nigeria.
        </p>
        <Link to="/explore" className="btn btn-primary">
          Explore stays
        </Link>
      </section>

      <section>
        <div className="section-head">
          <h3>Browse by city</h3>
        </div>
        <div className="city-chips">
          {CITIES.map((city) => (
            <Link
              key={city}
              to={`/explore?city=${encodeURIComponent(city)}`}
              className="city-chip"
            >
              {city}
            </Link>
          ))}
        </div>
      </section>

      <section>
        <div className="section-head">
          <h3>Fresh stays</h3>
          <Link to="/explore" className="link">
            See all
          </Link>
        </div>
        {loading && <Loading label="Finding stays…" />}
        {error && (
          <ErrorNotice
            message={error}
            onRetry={() => window.location.reload()}
          />
        )}
        {!loading && !error && properties.length === 0 && (
          <EmptyState
            title="No stays yet"
            body="Check back soon — new listings are on the way."
          />
        )}
        <div className="card-grid">
          {properties.map((p) => (
            <PropertyCard
              key={p.id}
              property={p}
              isFavorite={favoriteIds.has(p.id)}
              onToggleFavorite={supported ? toggle : undefined}
            />
          ))}
        </div>
      </section>
    </div>
  );
}
