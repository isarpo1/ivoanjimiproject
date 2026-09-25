import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/client';
import type { Property, SavedStay } from '../api/types';

/**
 * Saved stays (favorites) shared across listing screens.
 * Requires the backend favorites endpoints (GET/POST/DELETE /favorites).
 */
export function useFavorites() {
  const [ids, setIds] = useState<Set<string>>(new Set());
  const [stays, setStays] = useState<SavedStay[]>([]);
  const [loading, setLoading] = useState(true);
  const [supported, setSupported] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const data = await api<SavedStay[]>('/favorites/me');
      setStays(data);
      setIds(new Set(data.map((s) => s.propertyId)));
      setSupported(true);
    } catch (err: any) {
      // Backend without the favorites module -> hide favorite UI gracefully.
      if (err?.status === 404) setSupported(false);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const toggle = useCallback(
    async (property: Property) => {
      if (!supported) return;
      const saved = ids.has(property.id);
      // Optimistic update
      setIds((prev) => {
        const next = new Set(prev);
        if (saved) next.delete(property.id);
        else next.add(property.id);
        return next;
      });
      try {
        if (saved) {
          await api(`/favorites/${property.id}`, { method: 'DELETE' });
        } else {
          await api('/favorites', {
            method: 'POST',
            body: { propertyId: property.id },
          });
        }
        refresh();
      } catch {
        // Roll back on failure
        setIds((prev) => {
          const next = new Set(prev);
          if (saved) next.add(property.id);
          else next.delete(property.id);
          return next;
        });
      }
    },
    [ids, refresh, supported],
  );

  return { favoriteIds: ids, stays, loading, supported, toggle, refresh };
}
