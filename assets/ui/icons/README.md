# Upgrade Icon Concept Atlases

These SVG atlases are first-pass, transparent-background pixel concept assets used to lock silhouette, rarity composition, and atlas coordinates.

They are not the final cleaned runtime PNGs. Rarity frames and timer badges are separate overlays; never bake the timer badge into every item.

After visual approval:

1. export or redraw each 64×64 cell as an independent PNG;
2. remove anti-aliased edge pixels;
3. preserve the atlas IDs and coordinates in `atlas_map.json`;
4. import into Godot with Filter Off, Lossless compression, and no mipmaps;
5. compose neutral item icon + rarity frame + optional timer badge at runtime.

Source of truth: `docs/design/15_武器道具与升级图标资产设计.md`.
