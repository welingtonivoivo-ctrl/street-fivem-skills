# Where the patch landed in the 1.12.0 build

Read this only to find the matching spots in the source. Names are minified and change on
every build; the anchors are strings and shapes that survive.

| Change | Anchor in the build | Source component |
|---|---|---|
| Store + context | right after `displayName="Items"` | new module |
| Load on open | the section component with `useState(0)` that dispatches `mri_appearance_subtab_change` | section with side tabs |
| Tab + ★ button | the `map` over the tabs that renders the tab button with `label`, `isActive`, `skeleton` | same section |
| Context provider | the active tab content wrapped in the element with class `section-items` | same section |
| Cell star | the memoized cell (`displayName="GridCell"`), after the active dot `absolute top-2 left-2 w-2 h-2 rounded-full bg-primary` | `GridCell` |
| Grid filter + hint | the grid component with class `grid grid-cols-3 gap-1.5 p-1 pb-4`, next to `Cores / Texturas` | grid list |
| Blacklist filter | every `items:` that builds drawables from `drawable.min` to `drawable.max` (11 components, 5 props) | components and props sections |

Each patch block was a unique find/replace on the build; a block that matched 0 or 2+ times
meant the build changed and the block had to be redone.
