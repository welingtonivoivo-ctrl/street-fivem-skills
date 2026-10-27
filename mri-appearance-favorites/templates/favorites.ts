// Favorite clothes store. Module-level on purpose: the side tabs and the grid are far apart
// in the tree and both re-render on the same toggle.
import { createContext, useEffect, useState } from 'react';
import { fetchNui } from '../utils/fetchNui'; // adjust to the resource's NUI fetch helper

type Favorites = Record<string, Record<string, true>>;

// pieceKey: "<collection>:<localDrawable>", or the global number for the base game.
// Use the same conversion the studio photos use (toCollection).
export const store = {
  fav: {} as Favorites,
  view: {} as Record<string, boolean>, // section -> "favorites only" on
  listeners: new Set<() => void>(),

  emit() { this.listeners.forEach((fn) => fn()); },
  has(section: string, piece: string) { return !!this.fav[section]?.[piece]; },
  count(section: string) { return Object.keys(this.fav[section] ?? {}).length; },
  setView(section: string, on: boolean) { this.view[section] = on; this.emit(); },

  async load() {
    const data = await fetchNui<Favorites>('appearance_fav_get');
    this.fav = data && typeof data === 'object' && !Array.isArray(data) ? data : {};
    this.emit();
  },

  async toggle(section: string, piece: string) {
    const on = !this.has(section, piece);
    this.fav[section] ??= {};
    if (on) this.fav[section][piece] = true;
    else delete this.fav[section][piece];
    this.emit(); // optimistic
    const ok = await fetchNui<boolean>('appearance_fav_toggle', { section, piece, on });
    if (ok !== true) this.load(); // server refused (limit, invalid): back to the truth
  },
};

export function useFavorites() {
  const [, tick] = useState(0);
  useEffect(() => {
    const fn = () => tick((n) => n + 1);
    store.listeners.add(fn);
    return () => { store.listeners.delete(fn); };
  }, []);
  return store;
}

// Side tab id of the content being rendered (masks, jackets...), set by the section.
export const SectionIdContext = createContext('');
