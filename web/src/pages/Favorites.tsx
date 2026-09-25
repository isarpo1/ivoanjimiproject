import {
  EmptyState,
  ErrorNotice,
  Loading,
  PropertyCard,
} from '../components/ui';
import { useFavorites } from '../hooks/useFavorites';

export default function Favorites() {
  const { stays, loading, supported, favoriteIds, toggle } =
    useFavorites();

  if (loading) return <Loading label="Loading saved stays…" />;

  if (!supported)
    return (
      <div className="page">
        <ErrorNotice message="Saved stays aren’t available on this server yet." />
      </div>
    );

  return (
    <div className="page">
      <h2 className="page-title">Saved stays</h2>
      {stays.length === 0 ? (
        <EmptyState
          title="Nothing saved yet"
          body="Tap the heart on any stay to keep it here for later."
          actionLabel="Explore stays"
          actionTo="/explore"
        />
      ) : (
        <div className="card-grid">
          {stays.map((s) => (
            <PropertyCard
              key={s.id}
              property={s.property}
              isFavorite={favoriteIds.has(s.propertyId)}
              onToggleFavorite={toggle}
            />
          ))}
        </div>
      )}
    </div>
  );
}
