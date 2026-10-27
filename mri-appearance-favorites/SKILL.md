---
name: mri-appearance-favorites
description: "Adds favorite clothes to mri_Qappearance (fork of illenium-appearance) in its source code - a star on each piece of the clothing grid, a star button next to each side tab that filters the tab to favorites only, saved per character and per ped model on the server, keyed by collection + local drawable so new clothing packs don't shift them. Also fixes the 1.12.0 clothing grid ignoring blacklist.drawables. Ships the Lua callbacks, the React store and the edits for the section, grid and cell. Use when asked to \"add favorites to the clothing store\", \"favorite clothes\", \"star on clothes\", \"filter by favorites in the appearance menu\", \"the blacklist doesn't hide clothes\", \"hidden clothes still show in the store\" (pt-BR: \"favoritar roupa\", \"favoritos na loja de roupa\", \"estrela nas roupas\", \"só mostrar favoritos\", \"a blacklist não esconde a roupa\", \"peça escondida ainda aparece na loja\")."
---

# Favorite clothes in mri_Qappearance

Built and played at Street Roleplay as a patch on the compiled `html/assets/index.js` of
mri_Qappearance 1.12.0 plus a side resource. This skill moves it into the source, so the
server can drop the patch. What was tested in game: the behavior below, on the minified
build. The source version written from this skill still needs a browser check and a game
test.

## What the player gets

- A star in the top right corner of every piece in the clothing and props grid: `☆` empty,
  `★` yellow. Clicking it toggles the favorite and does **not** select the piece
  (`stopPropagation`).
- A `★` button right of every side tab (Masks, Jackets, Hats...). It opens that tab showing
  only its favorites. Yellow when the tab has favorites, filled with the primary color while
  the filter is on. Clicking the tab name goes back to the full list.
- Filter on and no favorites: one line across the grid, "Nenhum favorito aqui ainda. Toque na
  ☆ no canto de uma peça para favoritar." (locale key, not fixed text).
- Saved per character and per ped model: male and female drawables are different pieces.

## Data

- Server side, per `citizenid` + model hash. KVP is enough (`fav:<citizenid>:<model>`); a
  table is fine if the resource already creates its own on start.
- Shape: `{ [section]: { [pieceKey]: true } }`. `section` is the side tab id the NUI already
  uses (`masks`, `jackets`, `hats`, `glasses`...).
- **Key by collection + local drawable**, not the global drawable number: a pack added
  before a piece moves its global number and the favorite would point to another piece. The
  NUI already converts (`toCollection` / `toGlobal`, used by the studio photos). Keep the
  global number only when the piece has no collection (`base`).
- Cap each section (300 worked) and validate everything the NUI sends.

## Steps

1. **Lua**: copy `templates/favorites_server.lua` and `templates/favorites_client.lua` into
   the resource (server and client script lists of the `fxmanifest`). Server validates
   `section` (`^[%w_]+$`, up to 32 chars) and the key; client only forwards with the ped model.
2. **Store**: copy `templates/favorites.ts` into the NUI (next to the appearance components).
   One module-level store, a `useFavorites()` hook that re-renders on change, and a
   `SectionIdContext`. Toggle is optimistic and reloads from the server when it fails.
3. **Section with side tabs** (the component that dispatches `mri_appearance_subtab_change`):
   - on mount: `store.view = {}` and `store.load()`;
   - each tab becomes `[tab button][★ button]`: tab `isActive = active && !store.view[id]`,
     click = `setView(id, false)` + select; star click = `setView(id, true)` + select,
     `title = "Favoritos (" + count + ")"`;
   - wrap the active tab content in `<SectionIdContext.Provider value={tab.props.id}>`.
4. **Grid** (the list that renders the cells and the "Cores / Texturas" block):
   read `sectionId` from the context; when `store.view[sectionId]`, filter items with
   `store.has`; empty + filter shows the hint with `gridColumn: '1 / -1'`; pass
   `sectionId` and `isFavorite` to each cell.
5. **Cell** (`GridCell`, memoized): add the star button with `style={{ zIndex: 20 }}` so it
   stays above the photo, and add `isFavorite` and `sectionId` to the memo comparison or the
   star never updates.
6. Fix the blacklist (below), build the NUI, test in the browser mock, then in game.

## Pitfalls seen in the patch

- Tailwind only ships classes used somewhere in the source. Classes added only for this
  (`z-[20]`, `col-span-3`, `text-yellow-300`) were missing from the 1.12.0 CSS: use inline
  style for layout that must work (`zIndex`, `gridColumn`) or make sure the build sees them.
- Reset `view` when the menu opens, or the filter stays on from the last visit.
- The store is module-level on purpose: the section and the grid are far apart in the tree
  and both must re-render on the same toggle.

## Clothing grid ignores the blacklist (1.12.0)

The grid builds every drawable from `drawable.min` to `drawable.max`; only the position
counter reads `blacklist.drawables`. So `Config.Blacklist` and any piece Lua hides in
`blacklist.drawables` still show and can be clicked. Filter the item list before it reaches
the grid, for every component and prop:

```ts
const withoutBlacklist = (items, blacklist) => {
  const hidden = new Set(blacklist?.drawables ?? []);
  return hidden.size ? items.filter(i => !hidden.has(Number(i.id))) : items;
};
```

`references/minified-patch.md` shows where each change landed in the 1.12.0 build, to locate
the same spots in the source.

## Migration

Servers that ran the patch keep favorites in KVP `fav:<citizenid>:<model>` keyed by global
number. Keep that key and shape to inherit them, or convert once to collection + local with
the layout of the day.
