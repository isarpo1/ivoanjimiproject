import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { useSearchParams } from 'react-router-dom';
import { api } from '../api/client';
import type { Property, PropertySearchResponse } from '../api/types';
import { useFavorites } from '../hooks/useFavorites';
import {
  EmptyState,
  ErrorNotice,
  Loading,
  PropertyCard,
} from '../components/ui';

interface Filters {
  city: string;
  minPrice: string;
  maxPrice: string;
  bedrooms: string;
  guests: string;
  checkIn: string;
  checkOut: string;
  sort: string;
}

const EMPTY: Filters = {
  city: '',
  minPrice: '',
  maxPrice: '',
  bedrooms: '',
  guests: '',
  checkIn: '',
  checkOut: '',
  sort: 'newest',
};

export default function Explore() {
  const [params] = useSearchParams();
  const [filters, setFilters] = useState<Filters>({
    ...EMPTY,
    city: params.get('city') || '',
  });
  const [applied, setApplied] = useState<Filters>({
    ...EMPTY,
    city: params.get('city') || '',
  });
  const [properties, setProperties] = useState<Property[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [dateError, setDateError] = useState('');
  const { favoriteIds, toggle, supported } = useFavorites();

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError('');
      try {
        const q = new URLSearchParams();
        if (applied.city) q.set('city', applied.city);
        if (applied.minPrice) q.set('minPrice', applied.minPrice);
        if (applied.maxPrice) q.set('maxPrice', applied.maxPrice);
        if (applied.bedrooms) q.set('bedrooms', applied.bedrooms);
        if (applied.guests) q.set('guests', applied.guests);
        if (applied.checkIn) q.set('checkIn', applied.checkIn);
        if (applied.checkOut) q.set('checkOut', applied.checkOut);
        q.set('sort', applied.sort);
        q.set('limit', '24');
        const res = await api<PropertySearchResponse>(
          `/properties?${q.toString()}`,
        );
        if (!cancelled) {
          setProperties(res.data);
          setTotal(res.pagination.total);
        }
      } catch (err: any) {
        if (!cancelled)
          setError(err?.message || 'Could not search stays.');
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [applied]);

  function onSearch(e: FormEvent) {
    e.preventDefault();
    setDateError('');
    if (filters.checkIn && filters.checkOut) {
      if (new Date(filters.checkOut) <= new Date(filters.checkIn)) {
        setDateError('Check-out must be after check-in.');
        return;
      }
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      if (new Date(filters.checkIn) < today) {
        setDateError('Check-in can’t be in the past.');
        return;
      }
    }
    setApplied({ ...filters });
  }

  function clear() {
    setFilters(EMPTY);
    setApplied(EMPTY);
    setDateError('');
  }

  const set = (k: keyof Filters) => (v: string) =>
    setFilters((f) => ({ ...f, [k]: v }));

  return (
    <div className="page">
      <h2 className="page-title">Explore stays</h2>

      <form className="filters" onSubmit={onSearch}>
        <div className="filter-row">
          <label className="field">
            <span>City</span>
            <input
              value={filters.city}
              onChange={(e) => set('city')(e.target.value)}
              placeholder="e.g. Lagos"
            />
          </label>
          <label className="field">
            <span>Check-in</span>
            <input
              type="date"
              value={filters.checkIn}
              onChange={(e) => set('checkIn')(e.target.value)}
            />
          </label>
          <label className="field">
            <span>Check-out</span>
            <input
              type="date"
              value={filters.checkOut}
              onChange={(e) => set('checkOut')(e.target.value)}
            />
          </label>
        </div>
        <div className="filter-row">
          <label className="field">
            <span>Min price ₦</span>
            <input
              type="number"
              min={0}
              value={filters.minPrice}
              onChange={(e) => set('minPrice')(e.target.value)}
              placeholder="0"
            />
          </label>
          <label className="field">
            <span>Max price ₦</span>
            <input
              type="number"
              min={0}
              value={filters.maxPrice}
              onChange={(e) => set('maxPrice')(e.target.value)}
              placeholder="No max"
            />
          </label>
          <label className="field">
            <span>Bedrooms</span>
            <input
              type="number"
              min={1}
              value={filters.bedrooms}
              onChange={(e) => set('bedrooms')(e.target.value)}
              placeholder="Any"
            />
          </label>
          <label className="field">
            <span>Guests</span>
            <input
              type="number"
              min={1}
              value={filters.guests}
              onChange={(e) => set('guests')(e.target.value)}
              placeholder="Any"
            />
          </label>
          <label className="field">
            <span>Sort</span>
            <select
              value={filters.sort}
              onChange={(e) => set('sort')(e.target.value)}
            >
              <option value="newest">Newest</option>
              <option value="price_asc">Price: low to high</option>
              <option value="price_desc">Price: high to low</option>
            </select>
          </label>
        </div>
        {dateError && (
          <div className="error-notice" role="alert">
            {dateError}
          </div>
        )}
        <div className="filter-actions">
          <button className="btn btn-primary" type="submit">
            Search
          </button>
          <button
            className="btn btn-secondary"
            type="button"
            onClick={clear}
          >
            Clear
          </button>
        </div>
      </form>

      <p className="muted small">
        {loading ? 'Searching…' : `${total} stay${total === 1 ? '' : 's'} found`}
      </p>

      {loading && <Loading label="Searching stays…" />}
      {error && (
        <ErrorNotice
          message={error}
          onRetry={() => setApplied({ ...applied })}
        />
      )}
      {!loading && !error && properties.length === 0 && (
        <EmptyState
          title="No stays match your search"
          body="Try widening your dates, raising your budget, or clearing some filters."
          actionLabel="Clear filters"
          actionTo="/explore"
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
    </div>
  );
}
