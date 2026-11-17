# Guide for agents: driving FigCraft

This guide shows how to draw UI in the FigCraft desktop app from a script. It comes from building the Hanna Bus auth screens (school transportation app) in this folder.

## What FigCraft is

FigCraft is a native macOS design app, a Figma-style editor written in Rust. It lives at `/Applications/FigCraft.app` and saves `.figcraft` files.

It is not the Figma plugin "FigCraft" by DivikWu. Do not clone that repo or look for `manifest.json`.

## Connect

1. Start the app with its control port. Run it as a background process:

   ```bash
   /Applications/FigCraft.app/Contents/MacOS/FigCraft --control 7979
   ```

   It prints `FigCraft control server listening on 127.0.0.1:7979`.
2. Talk to the port with [lib/fc.py](lib/fc.py). It sends one JSON line and reads one JSON line back:

   ```python
   import fc
   fc.call("window.list")                      # open windows and documents
   fc.ex("shape.rectangle", x=0, y=0, width=100, height=60)   # engine command
   ```

3. Wire format, if you need it: `{"id":1,"method":"engine.execute","params":{"command":"...","params":{...}}}`. The reply is `{"id":1,"ok":true,"result":{...}}` or `{"ok":false,"error":"..."}`.

Only use this documented port. Do not touch the app's files or processes to work around errors.

## Discover commands

The app has 640+ commands. Ask it, do not guess:

```python
cmds = fc.call("engine.commands")["result"]   # [{id, label, params, ...}]
[c for c in cmds if "effect" in c["id"]]
```

Each entry has a `params` string that lists accepted keys. Unknown keys are rejected with a clear message, so read the error and adjust.

## Commands that matter

| Task | Command |
|---|---|
| Frame (a screen or card) | `frame.create {x,y,width,height,name,parent,props}` |
| Rectangle | `shape.rectangle {x,y,width,height,parent,name,props,select}` |
| Text | `text.create {text,x,y,width?,parent,name,props,select}` |
| Vector from SVG path | `vector.create {path,x,y,width,height,parent,name,props,select}` |
| Image | `image.place {path,x,y,width,height,parent,name,mode}` |
| Put an image fill on an existing layer | `image.place {path,target:<id>,mode:"fill"}` |
| Change anything | `node.set {id, ...}` |
| Read a layer | `node.get {id}` |
| Find layers | `node.find {name?,type?,text?,limit?}` returns `{ids,total}` |
| Delete | `edit.delete {ids:[...]}` |
| Zoom to fit | `view.zoomFit` |
| Save | `file.saveAs {path}` (adds `.figcraft`), or `file.save` |

Every create command returns `{"id": N}`. Keep the id.

## Rules learned the hard way

- `props` takes `node.set` keys. Use `fill`, `stroke`, `strokeWeight`, `strokeAlign`, `cornerRadius`, `clip`, `opacity`, `rotation`, `effects`, `fontSize`, `fontFamily`, `fontWeight`, `textAlign`.
- A drop shadow is `{"type":"dropShadow","offset":[0,10],"radius":30,"color":"#00000014"}`. `offset` is a two item list, not an object. There is no `blur`, `x` or `y`.
- `image.place` does not accept `select`. `shape.*`, `text.create` and `frame.create` do. Pass `select=False` to keep the selection stable.
- `x` and `y` are relative to the `parent` frame.
- Text hugs its content. To center or right align a text without a fixed width, create it, read its `width` with `node.get`, then set `x`.
- With a fixed `width`, use `textAlign: "center"` and set `x = (frame_width - width) / 2`.
- `fontWeight` (400, 600, 700) maps to a style such as Bold. `Inter` works as a font family.
- Scaling a vector: set both `width` and `height`. Setting only the width stretches it.
- A photo slot is a frame with `clip: true` and a `cornerRadius`, with the image added as its fill through `image.place` and `target`. The user replaces the fill to swap the photo.
- Make scripts idempotent. At the start, find old frames by name with `node.find` and remove them with `edit.delete`, then rebuild.

## Icons

[lib/phosphor.py](lib/phosphor.py) places Phosphor Regular icons as vectors:

```python
from phosphor import icon
icon(parent_frame_id, "arrow-left", x, y, 22, "#111111")   # name, x, y, size, color
```

- SVGs are in `design/icons/svg`. The set is the MIT-licensed `@phosphor-icons/core`.
- To add more, copy `assets/regular/<name>.svg` from that npm package into `design/icons/svg`. Use single path icons from the Regular weight.
- The helper reads the path, measures the unscaled box, then scales it so the icon fits a `size` square.

## Exporting previews & screenshots

Prefer `file.export` over `ui.screenshot`. It renders selected frames (or the whole page when `ids` is omitted) directly to disk in under a second:

```python
import fc
fc.ex("file.export", ids=[frame_id1, frame_id2], format="png", scale=1.5,
      path="/Users/bmg/Documents/ui/output/screenshots/preview.png")
```

- Pass `ids` to export specific frames, or omit `ids` to export the entire page.
- `ui.screenshot` captures the full application window and can take 40-60 seconds on a busy canvas; only use it when you specifically need the surrounding FigCraft UI chrome.
- Inspect the exported PNG after every build. Layout bugs are easy to miss in raw coordinates.

## Files here

```
ui/
  AGENTS.md                       this guide
  lib/                            shared Python helpers
    fc.py                         control port client (call, ex)
    phosphor.py                   Phosphor icon helper
    theme.py                      palette loader + contrast check (python3 lib/theme.py)
    ui.py                         shared Screen builder + FigCraft page & section helpers
  scripts/                        modular builders (each creates its own FigCraft page + EN/AR sections)
    build_all.py                  builds all 3 pages (36 frames), exports PNGs, and saves output/hanna-bus.figcraft
    build_auth.py                 Page "01 · Auth & Onboarding" (7 screens x 2 langs = 14 frames)
    build_profile.py              Page "02 · Profile & Family"  (5 screens x 2 langs = 10 frames)
    build_settings.py             Page "03 · Settings & Account" (6 screens x 2 langs = 12 frames)
    build_children.py             Page "04 · My Children"        (7 screens x 2 langs = 14 frames)
    build_tracking.py             Page "05 · Live & History Tracking" (6 screens x 2 langs = 12 frames)
    build_home.py                 Page "06 · Home Dashboard"         (5 screens x 2 langs = 10 frames)
  design/                         inputs the scripts read
    palettes/                     DTCG color files (hanna-bus-mustard.json, hanna-bus-teal-gray.json)
    assets/brand/                 logo (hanna-bus-logo.png)
    icons/svg/                    Phosphor SVGs in use, plus LICENSE
  output/                         generated results
    hanna-bus-auth.figcraft       saved document
    screenshots/                  latest screenshots (auth-en-ar.png)
  archive/tripstar-reference/     first TripStar draft and its photo crops, kept for reference
```

Scripts find their files from their own location, so run them from any folder. Choose a palette with `HANNA_PALETTE=teal-gray` (default `mustard`). Save new documents and screenshots under `output/`.

## Design conventions used

- Screen size is 393 by 852. Screens sit side by side with a 60 px gap.
- Colors come from `design/palettes/`. The default is Mustard, palette 6 (`#2B2B2B`, `#D4A017`, `#F0C94C`, `#F7E7B5`, `#FFFDF5`) plus derived text tokens. Primary action is `#D4A017` with charcoal label text, because white on mustard fails contrast. Links use the derived dark mustard `#7A5A00`. Teal/Gray (palette 7) is the alternate. Never hardcode hex in build scripts.
- Title is two lines: grey first line, dark second line, 38 px bold, centered.
- Inputs are white, 56 px tall, radius 16, with a Phosphor icon on the left. Primary buttons are 60 px tall with radius 20.
- No emoji. No dashes in copy. No one-sided colored borders.

## Adding a screen

1. Copy the `Screen` class pattern in `scripts/build_screens.py`. It has helpers for status bar, back button, title, field, button, footer and social row.
2. Give the frame a name like `Auth / <Screen>` and add that name to the cleanup list.
3. Place it at the next free x (previous x + 453).
4. Run it, screenshot it, fix what looks off, then run `file.saveAs`.

## Known gaps

- Eye icon is static. There is no show or hide state, and no `eye-slash` version.
- Fields have no focus, filled or error states.
- Screens are not linked as a prototype.
- Social buttons use Phosphor logo glyphs, not official brand artwork.
- The app must be running for scripts to work. If port 7979 refuses the connection, start it again.

## Arabic and RTL

`scripts/build_screens.py` draws both languages from one set of layout code. Strings live in the `STR` dict. To add a screen, add its strings for `en` and `ar`, then draw it with the `Screen` helpers.

- Font: `IBM Plex Sans Arabic` (already installed on this Mac; `text.fonts` lists installed families). Arabic text is shaped correctly. English uses Inter.
- Set paragraph direction with `text.direction {direction:"rtl", ids:[...]}`. `node.set direction=...` does nothing.
- Mirror layout by flipping x: `x' = frame_width - x - width`. The `Screen.ax()` helper does this. `rect`, `icon` and `text` mirror by default. Pass `mirror=False` for centered or symmetric items.
- Text `align`: `start` (left in LTR, right in RTL), `center`, `end`. Hug-width text is placed after measuring its width.
- Directional icons swap: `arrow-left` becomes `arrow-right`, `caret-right` becomes `caret-left`. The logo, the envelope and the status bar are not mirrored.
- Social labels (Apple, Google) and email placeholders stay in Latin script.
- Arabic text gets +1 px at 17 px and below, because the script reads smaller at the same size.
- Frames are named `EN / Auth / <Screen>` and `AR / Auth / <Screen>`. Re-running replaces them.

## Full-stack runtime (`backend/` + `hanna_bus_parent/`)

- **Laravel API (`backend/`):** Sanctum + SQLite backend at `/api/v1` with demo seed (`k.mansouri@mail.dz` / `Password123!`, student code `HB-2026-9911`). Run locally via `cd backend && php artisan serve` and verify with `php artisan test`.
- **Flutter Parent App (`hanna_bus_parent/`):** Multi-palette (`Mustard`, `Teal-Gray`, `Ocean Blue`), light/dark modes, trilingual (`en` LTR, `ar` RTL, `fr` LTR), Emil Kowalski motion tokens, and offline demo fallback when API is unreachable. Run with `cd hanna_bus_parent && flutter run --dart-define=HANNA_API_URL=http://127.0.0.1:8000/api/v1` and verify with `flutter analyze && flutter test`.
