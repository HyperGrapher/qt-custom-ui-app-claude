# Implementation Plan — "Lumina" Qt Quick UI Proof of Concept

Status: **Approved and implemented.** See section 8 for decisions made during implementation.

Source requirements: [`docs/PRD.md`](PRD.md).

---

## 1. The idea in one paragraph

Lumina is a desktop shell that feels alive but calm. A frameless, rounded window floats
over the desktop with a soft shadow. Behind everything sits a living **aurora**: a GPU
shader of slow, glowing color blobs. Each of the four sections has its own color "mood".
When you click a section, the new mood does not just fade in — it **spreads out like ink
in water** from the icon you clicked, while a liquid selection pill stretches down the
sidebar and the page content leaves and arrives in a short, staggered wave. The whole UI
(buttons, rings, toggles, glass cards) takes its accent color from the current mood, so
every switch re-tints the entire app in one smooth movement.

The name "Lumina" and all content are placeholders. Nothing copies CleanMyMac branding.

---

## 2. Visual concept

### 2.1 Layout

```
 ╭──────────────────────────────────────────────────────────────────────╮  ← real rounded
 │ ◉ Lumina                                          ─    ▢    ✕        │    corners (alpha)
 │ ┌──────────────┐                                                     │
 │ │  ╭────────╮  │   Good evening                                      │
 │ │  │◆ Overview│◀─┼── liquid pill        ╭─────────╮                    │
 │ │  ╰────────╯  │                       │  ORB    │   ← shader "energy │
 │ │  ▦ Collections│                       │ (shader)│     orb" hero      │
 │ │  ◔ Activity  │                       ╰─────────╯                    │
 │ │  ⚙ Preferences│          [  Run demo  ]   ← glowing primary button  │
 │ │              │   ┌────────┐ ┌────────┐ ┌────────┐                   │
 │ │              │   │ stat   │ │ stat   │ │ stat   │  ← glass cards    │
 │ │  ◐ Reduced   │   └────────┘ └────────┘ └────────┘                   │
 │ │    motion    │                                                     │
 │ └──────────────┘                                                     │
 ╰──────────────────────────────────────────────────────────────────────╯
     ░░░░░ aurora shader background fills the whole window, behind all ░░░░░
```

- The sidebar is a translucent "glass" column floating on the aurora, not a solid bar.
- The title area is part of the same surface (no visible separate title bar).
- Content sits directly on the aurora with glass panels where grouping is needed.

### 2.2 Section moods (palettes)

Each section defines 4 blob colors, a base (darkest) color and an accent for controls.
All values live in one file (`Palettes.qml`) and are easy to tune.

| Section      | Mood name | Blobs (example values)                         | Base      | Accent    |
|--------------|-----------|------------------------------------------------|-----------|-----------|
| Overview     | Nebula    | `#6A3DF0` `#C13CFF` `#2D1B69` `#FF6FB5`          | `#120A2A` | `#B58CFF` |
| Collections  | Lagoon    | `#00B3A4` `#1FD1F9` `#0B3D5C` `#7CF5C8`          | `#04161F` | `#4BE3D0` |
| Activity     | Ember     | `#FF7A45` `#FF3D6E` `#FFC15E` `#5A1A3A`          | `#1E0A12` | `#FF9A6B` |
| Preferences  | Glacier   | `#5B8CFF` `#8FB8FF` `#2A3A7A` `#B7A6FF`          | `#0A1024` | `#8FB0FF` |

Text is always light on these dark bases. A gentle dark scrim (vignette) inside the
background shader keeps the content area readable even where blobs are bright.

### 2.3 Signature effects (the "wow" list)

1. **Aurora background** — 5 soft blobs moving on slow, never-repeating paths, with
   light domain warping so shapes slowly "breathe". One fragment shader.
2. **Ink-spread mood change** — on tab switch, the new palette expands as a soft-edged
   circle from the clicked sidebar icon across the window (~900 ms, ease-out). The edge is
   wobbly (low-frequency warp), so it looks like liquid, not a geometric wipe.
3. **Liquid selection pill** — the active-tab indicator moves with its leading edge faster
   than its trailing edge, so it stretches and then settles (like a drop of liquid).
   A soft glow under it uses the current accent.
4. **Energy orb** — the Overview hero is a shader sphere with a slow inner swirl, rim light
   and a glow halo, colored by the current mood. It "pulses" when the demo runs.
5. **Glass cards with light play** — cards have a rim highlight and a specular spot that
   follows the mouse; on hover they tilt by a few degrees toward the cursor and lift.
6. **Shader progress ring** — antialiased arc drawn with a signed-distance function:
   gradient along the arc, rounded caps, and a small bright "comet head" at the tip.
7. **Staggered content entrance** — page elements arrive one after another (30 ms apart,
   capped), each with opacity + small rise.

All of this must stay subtle. Motion rules: ambient motion is very slow (one blob crosses
the screen in ~30–60 s); UI transitions are short (120–350 ms); nothing flashes.

---

## 3. Architecture

### 3.1 Folder layout (follows `AGENTS.md`)

```
CMakeLists.txt
src/
  main.cpp                     app setup, surface format, command-line flags
  AppSettings.h/.cpp           persisted settings (QSettings): reduced motion, last tab…
  WindowChrome.h/.cpp          frameless-window behavior exposed to QML (cross-platform)
  WindowChromeWin.cpp          Windows-only native part (DWM corners, hit testing)
  FrameStats.h/.cpp            FPS / frame-time counter for the debug overlay
  TaskSimulator.h/.cpp         mock "long task" state machine for the Activity page
  CollectionModel.h/.cpp       mock card data (QAbstractListModel)
  qml/
    Main.qml                   root window, wires everything together
    theme/                     Theme.qml, Motion.qml, Palettes.qml   (singletons)
    shell/                     WindowFrame, TitleBar, WindowButton, ResizeBorder
    navigation/                Sidebar, SidebarItem, LiquidIndicator
    pages/                     PageHost, OverviewPage, CollectionsPage,
                               ActivityPage, PreferencesPage
    controls/                  Button styles, IconButton, ToggleSwitch, ProgressRing,
                               StatusCard, GlassCard, SegmentedControl, Slider style,
                               Reveal (stagger helper), Icon, PerformanceOverlay
    effects/                   AuroraBackground, EnergyOrb, WindowShadow
  shaders/                     *.frag / *.vert (compiled with qt_add_shaders)
resources/
  fonts/                       Inter (UI text), Phosphor icon font (icons)
tests/
  CMakeLists.txt
  tst_tasksimulator.cpp
  tst_appsettings.cpp
docs/
  PRD.md, IMPLEMENTATION_PLAN.md
```

The old root `main.cpp` and `Main.qml` are removed (no backward compatibility needed).

### 3.2 Responsibilities

| Area | C++ | QML |
|------|-----|-----|
| Window behavior | `WindowChrome`: move/resize/maximize, platform detection, Windows native hooks | `shell/*` draws frame, shadow, buttons, and calls `WindowChrome` |
| Navigation | — | `Sidebar` owns `currentIndex`; `PageHost` reacts to it |
| Theme & motion | `AppSettings` stores the reduced-motion choice | `Theme`, `Motion`, `Palettes` singletons are the single source of all visual values |
| Mock logic | `TaskSimulator`, `CollectionModel` | Pages bind to them |
| Diagnostics | `FrameStats` (only counts when the overlay is visible) | `PerformanceOverlay` |

C++ classes are registered with `QML_ELEMENT` / `QML_SINGLETON` through `qt_add_qml_module`
(no manual `qmlRegisterType` calls). No inheritance hierarchies; every class is small.

### 3.3 Centralized design tokens

- **`Theme.qml`** — spacing scale (4/8/12/16/24/32), radii (window 14, card 16, button 10,
  pill 12), typography (Inter; sizes for display/title/body/caption), text colors,
  glass fill/stroke opacity, and the **animated current palette** (blob colors, base,
  accent). Controls bind to `Theme.accent`, so the whole app re-tints with each tab.
- **`Motion.qml`** — named durations (`fast 120`, `normal 220`, `page 320`,
  `moodSpread 900`, `ambientCycle` …), named easing curves, stagger step and cap, and
  `reducedMotion`. In reduced-motion mode the same names resolve to shorter or zero values,
  so components do not need their own `if` checks.
- **`Palettes.qml`** — the four section moods (table in 2.2).

### 3.4 Qt version and modules

- Target **Qt 6.8 LTS** (used by the release workflow). Keep code compatible with
  **Qt 6.4**, because that is what this cloud environment has for building and testing.
  This means: no `MultiEffect` (6.5+), no `QtCore.Settings` (6.5+); effects are our own
  shaders anyway, and settings are in C++.
- Modules: `Quick`, `QuickControls2`, `ShaderTools` (build-time `qsb`), `Test` (tests).
- Icons use an **icon font** (Phosphor, MIT license) instead of SVG files: no Qt Svg
  dependency, sharp at every scale factor, and recoloring/color animation is just
  `Text.color`.

---

## 4. Feature design

### 4.1 Frameless rounded window (PRD §2)

Rounded corners must be real, not painted on an opaque rectangle. The approach differs per
platform, hidden behind `WindowChrome`:

**Linux (X11 with compositor, Wayland)**
- Window flags: `Qt.Window | Qt.FramelessWindowHint`, window color `transparent`, surface
  format with an 8-bit alpha channel. Corners are real per-pixel transparency.
- `WindowFrame` paints the rounded content surface plus a soft drop shadow in a ~16 px
  transparent margin. The shadow is a single cheap SDF shader (rounded-rectangle distance
  → gaussian-like falloff), no blur passes.
- The shadow margin doubles as the **resize border** (same as GNOME client-side
  decorations). Edges/corners call `QWindow::startSystemResize(edges)`; title area drag
  calls `startSystemMove()`. Both work on X11 and Wayland, and the compositor handles
  snapping/tiling.
- When maximized or fullscreen: margin → 0, corner radius → 0, shadow hidden, so the
  window fills the work area exactly.
- Limitation: on X11 **without** a compositor, transparency is not possible; corners
  will show black. We detect what we can and document it. A `--no-translucency` flag
  forces a square-corner opaque mode.

**Windows 11**
- Use the native, supported route: keep the native frame styles (`WS_THICKFRAME`,
  `WS_CAPTION`) for Aero Snap, Snap Layouts, minimize/maximize animations and native
  shadow, but remove the visible frame by handling `WM_NCCALCSIZE`.
- Ask DWM for rounded corners: `DwmSetWindowAttribute(DWMWA_WINDOW_CORNER_PREFERENCE,
  DWMWCP_ROUND)`. Corners are rounded and antialiased by the OS, and the shadow is native,
  so no transparent margin is needed.
- `WM_NCHITTEST` returns `HTCAPTION` for the title area (excluding interactive controls
  registered from QML) and resize codes for the edges. Correct maximized sizing is handled
  in `WM_NCCALCSIZE` (inset by the frame thickness so content is not cut off).
- Stretch goal: return `HTMAXBUTTON` over our maximize button to get the Windows 11
  Snap Layouts flyout.

**Windows 10**
- Windows 10 has no native rounded corners. Plan: reuse the Linux translucent path
  (alpha surface + painted shadow + rounded alpha). Risk: per-pixel alpha with the
  Direct3D backend depends on the Qt version (DirectComposition support). If it does not
  work reliably, fallback is OpenGL backend for that case, or square corners on Windows 10
  with a clear note. See *Open questions*.

**Common rules**
- Double-click on the title area toggles maximize/restore.
- Interactive controls in the title area (window buttons, any future search field) are
  excluded from dragging: drag uses a `DragHandler`/`TapHandler` on a background item, so
  child controls receive events first.
- Window buttons are drawn as vector shapes (crisp at 100–200% scaling), with hover/press
  states; the close button turns red on hover. They are at least 40×32 logical px.
- High DPI: Qt 6 scaling enabled with `PassThrough` rounding policy so 125%/150% look
  correct. Everything is sized in logical pixels; shaders use `devicePixelRatio`.

### 4.2 Sidebar and the liquid selection pill (PRD §3)

- Four items: **Overview**, **Collections**, **Activity**, **Preferences**. Each has an
  icon and label.
- Item states: normal, hover (soft highlight, icon nudges 2 px right), pressed (scale
  0.97), keyboard focus (accent focus ring), selected.
- **LiquidIndicator**: one pill item behind the items. It has two edges (`top` and
  `bottom`) animated with different durations: the edge in the direction of travel moves
  first (~180 ms), the other edge follows (~300 ms). The pill stretches, then settles.
  Animations use `Behavior`, so a new click simply retargets from the current position —
  no queue.
- Selected icon gets a small "pop" (scale 1 → 1.12 → 1) and changes to accent color.
- Keyboard: Up/Down to move, Ctrl+1…4 shortcuts, Tab focus works.
- Bottom of sidebar: a compact **Reduced motion** toggle (also in Preferences).

### 4.3 Page transitions (PRD §3)

`PageHost` keeps each page alive after first creation (`Loader` + `active` once visited),
so pages are never reset and state (toggle positions, scroll) is kept.

Each page has a `presence` value (0 = gone, 1 = shown). Only the selected page has target 1.
`presence` is animated with a `Behavior`, so:
- **Rapid switching** just retargets values from where they are. No transition queue.
- **Input safety**: a page is `enabled` only when it is the selected page, and
  `visible` only while `presence > 0`. Outgoing pages lose input at once.
- **No blank flash**: outgoing and incoming overlap (cross-fade), never "out then in".

Choreography (normal motion):

| Time        | What happens |
|-------------|--------------|
| 0 ms        | Pill starts moving; mood spread starts at the clicked icon; accent color starts changing (300 ms). |
| 0–160 ms    | Outgoing page: opacity 1→0, moves 12 px against the travel direction. |
| 60–380 ms   | Incoming page: opacity 0→1, moves from 16 px to 0 (OutCubic). Direction depends on whether the new tab is above or below. |
| 60 ms + n×30 | Incoming elements (`Reveal` helper): opacity + 8 px rise, staggered, max 8 steps. |
| 0–900 ms    | Background mood finishes spreading. |

Reduced motion: 120 ms cross-fade only; no movement, no stagger; palette cross-fades
evenly in 200 ms instead of spreading.

### 4.4 Aurora background shader (PRD §4)

- `AuroraBackground.qml` → `ShaderEffect` with `aurora.frag`.
- Inputs: `time`, two palettes (`from` and `to`, 4 blob colors + base each), mood-spread
  `progress` and `origin`, `resolution`, `intensity`.
- Each blob: position from slow, combined sine paths with different periods (never visibly
  repeats), smooth falloff `exp(-d²/r²)`, radius slowly breathing. Light domain warping
  (two low-frequency sines) bends the field so shapes look organic.
- Colors are mixed in a perceptually smoother space (approx. linear light), plus a soft
  vignette scrim for readability and **tiny dithering** (±0.5/255) to prevent visible
  color banding on gradients (not visible as noise).
- **Mood spread**: per pixel, `mix(fromPalette, toPalette, smoothstep(edge))` where the
  edge is the distance from `origin` compared with an expanding radius, warped by a
  low-frequency wave. If a new switch happens mid-spread, the current `from`/`to` mix is
  folded into the new `from` and a new spread starts from the new icon.
- **Performance**: the shader is rendered into a **reduced-resolution texture**
  (`layer.enabled` with a smaller `textureSize`, e.g. ½ or ⅓) and scaled up with linear
  filtering. The image is very soft, so this is visually identical and cuts GPU work
  4–9×. This is the main reason no blur is needed anywhere.
- **Frame rate**: ambient motion is so slow that we can drive `time` at 30 Hz instead of
  every vsync. We will measure both (30 Hz timer vs. per-frame) and pick the cheaper one
  that still looks smooth. Transitions always run at full frame rate.

### 4.5 Buttons and widgets (PRD §5)

All controls are styled Qt Quick Controls (`Button`, `Switch`, `Slider`, …) with custom
`background`/`contentItem`, so they keep keyboard and accessibility behavior.

| Component | States and motion |
|-----------|-------------------|
| **PrimaryButton** | Accent gradient pill. Hover: brighter + glow grows. Pressed: scale 0.97, glow shrinks. Focus: 2 px outer ring. Disabled: desaturated, 40% opacity, no glow. Optional slow "breathing" glow for the hero button (off in reduced motion). |
| **SecondaryButton / GhostButton** | Glass fill or outline; same state model, smaller changes. |
| **IconButton** | Round, used in toolbar spots and title bar style. |
| **ToggleSwitch** | Track color cross-fades to accent; knob slides with a small squash-and-stretch (knob widens mid-travel). |
| **ProgressRing** | SDF arc shader: gradient along arc, round caps, comet head, soft glow; value animates with a smooth spring; center number counts up. |
| **StatusCard** | States: Idle → Running → Success / Warning. Icon morph (rotate + cross-fade), color change, a pulsing halo while running, details area expands with height animation. |
| **GlassCard** | Glass fill + rim light shader; hover: lift (shadow grows), tilt up to ~4° toward cursor, specular spot follows mouse. |
| **SegmentedControl** | Sliding selection pill (same liquid feel as sidebar, simpler). |
| **Slider** | Accent fill, handle grows on hover/drag. |

### 4.6 Pages and mock content

1. **Overview (summary)** — greeting, the **Energy Orb** hero, a big "Run demo" primary
   button, three stat glass cards with count-up numbers. "Run demo" makes the orb pulse,
   numbers roll, and switches the Activity task to running.
2. **Collections (card collection)** — filter chips (sliding pill) + grid of ~12 glass
   cards from `CollectionModel` (icon, title, size, small sparkline). Hover tilt/lift.
   "Shuffle" and filter actions show `GridView` add/remove/move transitions.
3. **Activity (progress/status)** — large ProgressRing, a vertical step timeline whose
   connector lines fill as steps complete, a StatusCard, and Start / Pause / Reset
   buttons. Driven by `TaskSimulator` (C++): states Idle, Running, Paused, Completed,
   Failed (a "Simulate warning" button forces Failed). Its timer runs only while Running.
4. **Preferences (settings)** — Reduced motion, Ambient background on/off, Glass effects
   on/off, Show performance overlay, Ambient speed (Calm / Normal / Lively segmented),
   Background intensity slider, and a disabled button example. Settings persist via
   `AppSettings`.

### 4.7 Performance and motion rules (PRD §6)

- **Pause when hidden**: all decorative animation (`time` driver, orb swirl, breathing
  glow) is bound to `ambientActive = window visible && not minimized && background enabled
  && !reducedMotion`. When nothing animates, Qt Quick renders **no frames**, so idle cost
  is near zero.
- **Reduced motion**: from settings or `--reduced-motion` flag. Static aurora frame,
  cross-fades only, no stagger/tilt/breathing.
- No polling timers. The only timers are the optional 30 Hz ambient driver (only while
  `ambientActive`) and `TaskSimulator`'s timer (only while Running).
- Shader effects use fixed small uniform sets; no runtime texture caches; the background
  layer is the only offscreen texture besides the orb (small, fixed size).
- Avoid layout thrash: fixed-size sidebar; pages use anchors and fixed rows; transitions
  only animate `opacity`, `x/y` and `scale` (no width/height animation during page
  switches, except the StatusCard details which is local).

### 4.8 Performance overlay and measurement

`FrameStats` (C++) connects to `QQuickWindow::frameSwapped` only while the overlay is
visible and reports FPS and average/max frame interval. The overlay shows FPS, frame
time, and current mode (ambient on/off, reduced motion).

Measurement plan (results will be reported as *measured* vs *estimated*):
- Linux (this environment): Xvfb + Mesa software rendering → CPU/RAM with `ps`/`/proc`,
  for idle, ambient, and rapid switching. Software rendering is much slower than a GPU,
  so these numbers are an upper bound, and will be labeled as such.
- Real GPU numbers (Linux desktop, Windows) must be measured by you; I will give exact
  steps (`QSG_RENDER_TIMING=1`, Task Manager / `Get-Process`, `top`).
- Targets (estimates, to be verified): idle with no animation ≈ 0% CPU; ambient running
  < 3% CPU on a modern desktop; RAM < 150 MB; background shader < 1 ms/frame at 1080p
  (thanks to reduced-resolution rendering).

---

## 5. Delivery phases

Each phase ends with a building, runnable app and a commit pushed to
`claude/ecstatic-bell-j6yd7x`.

| # | Phase | Main output |
|---|-------|-------------|
| 1 | **Restructure & foundation** | Move to `src/`, `src/qml/`, `resources/`, `tests/`; CMake with `qt_add_qml_module`, `qt_add_shaders`, fonts as resources; `Theme`/`Motion`/`Palettes` singletons; `.clang-format`; release workflow updated (`qtshadertools` module, new QML path). |
| 2 | **Window shell** | `WindowChrome` (Linux path + Windows native path), `WindowFrame` with shadow + real rounded alpha, title area, window buttons, resize borders, maximize/restore, double-click, DPI. |
| 3 | **Aurora background** | `aurora.frag`, reduced-resolution layer, palette uniforms, pause logic, ambient-speed setting. |
| 4 | **Navigation & transitions** | Sidebar, liquid pill, `PageHost` with presence model, `Reveal` stagger, mood spread from clicked icon, accent re-tint, keyboard navigation, reduced motion. |
| 5 | **Controls library** | Buttons, toggle, progress ring shader, status card, glass card (tilt + specular), segmented control, slider. |
| 6 | **Pages & mock logic** | Four pages, `TaskSimulator`, `CollectionModel`, `AppSettings`, energy orb shader, unit tests. |
| 7 | **Polish, verification, docs** | Performance overlay + measurements, rapid-switch/resize/scale tests (`QT_SCALE_FACTOR` 1, 1.25, 1.5, 2), screenshots, README update (build/run, where visual settings live, platform limits, measured vs estimated numbers). Optional: Windows 11 Snap Layouts on maximize button. |

### Verification checklist (Phase 7)

- [ ] Tab switching: all 12 directional pairs, no blank frame, no layout jump.
- [ ] Rapid switching: 10+ clicks/second for several seconds → no queued animations,
      ends on the last clicked tab within one transition time.
- [ ] Outgoing page cannot be clicked during transition (scripted test with clicks).
- [ ] Widgets: every state of every control, keyboard focus visible.
- [ ] Resize from all 8 edges/corners; maximize/restore via button and double-click;
      maximized window fills work area with square corners.
- [ ] Scaling 100/125/150/200% — no clipping, crisp icons and window buttons.
- [ ] Minimize → frame rendering stops (checked with the overlay/`QSG_RENDER_TIMING`).
- [ ] Reduced motion → no continuous rendering.
- [ ] Screenshots of each page captured under Xvfb and attached to the final report.

What I **can** test here: Linux X11 under Xvfb (software rendering, Qt 6.4). What I
**cannot** test here: Windows 10/11, Wayland, real GPU performance, real multi-monitor
DPI. The Windows code will at least be compiled by GitHub Actions (see open question 4).

---

## 6. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Transparent windows on X11 without compositor | Detect + `--no-translucency` square fallback; documented. |
| Windows 10 per-pixel alpha with Direct3D | Test early in Phase 2 via CI build + your manual run; fallback options listed in 4.1. |
| Local Qt 6.4 lacks some QML modules (Layouts, Shapes are not installed here) | Use anchors/positioners and shaders; install packages if possible. Code stays compatible with 6.4–6.11. |
| Software rendering in this environment is slow | Use it for correctness and screenshots; GPU performance verified by you on real hardware. |
| Mood-spread retarget mid-animation could show a small color jump | Fold current mix into new `from` palette; colors are soft so the jump is minimal; tune in Phase 4. |
| Visual effects become "too much" | Every effect has an intensity token in `Theme`/`Motion`; reduced motion turns them off. |

---

## 7. Decisions on the open questions

1. Name: "Lumina" is fine.
2. Windows 10: square corners are acceptable; no extra complexity for rounding there.
3. Fonts: Inter and the Phosphor icon font are bundled in `resources/fonts/` with licenses.
4. CI: `.github/workflows/ci.yml` builds and tests on every push (Linux and Windows).
5. Qt version: target Qt 6.8 (CI and releases); the code still builds with Qt 6.4 for local
   testing here. The author will also build with Qt 6.11 on Windows.

---

## 8. Implementation notes (changes from the plan, with reasons)

| Topic | Plan | Implemented | Why |
|---|---|---|---|
| Ambient clock | QML timer or per-frame driver, pick by measurement | C++ `AmbientClock` with a plain `QTimer` (30 Hz) | A QML `Timer` runs on Qt Quick's animation driver and kept rendering at full display rate (measured 60–100 FPS instead of 30). |
| Background resolution | Aurora rendered at ½–⅓ resolution through a layer | One full-resolution pass (`aurora.frag` also does vignette, rim, dithering, rounded corners) | The updating layer made Qt Quick render an extra frame per update (measured 60 instead of 30 FPS). The full-resolution shader was made cheaper instead: gamma 2.0 math, and the mood-spread math is skipped when no spread runs. |
| Button breathing glow | Own looping animation | Driven from the ambient clock | A looping animation (and a `Behavior` reacting to each tick) forces full-rate rendering; the clock-driven pulse pauses with all ambient motion. |
| Windows frame | Native frame styles + `WM_NCCALCSIZE` / `WM_NCHITTEST` | `Qt::FramelessWindowHint` + DWM corner preference; move/resize via `startSystemMove` / `startSystemResize` | Same user-visible result on Windows 11 (OS-rounded corners, Aero Snap by drag, edge resize) with far less native code, and no way to test native hit-testing here. Snap Layouts flyout remains a stretch goal. |
| Window buttons | Vector shapes | Icon-font glyphs (Phosphor) | Also vector and sharp at any scale, and consistent with all other icons. |
| X11 compositor detection | Detect what we can | Not detected; `--no-translucency` flag documented | Reliable detection needs X11-specific code; the flag is the simple, explicit way out. |
| Local Qt | Install Qt 6.8 | Ubuntu's Qt 6.4.2 locally; Qt 6.8.3 in CI | Qt's download servers are blocked in this environment. CI runs the same build, tests and tour on 6.8.3. |
