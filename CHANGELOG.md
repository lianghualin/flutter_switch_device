## 0.2.0

* Add `SwitchIconWidget` — a compact switch icon for topology views and device lists.
* Add `SwitchIconPainter` — CustomPainter rendering a miniature switch with gradient body, 3 LEDs with glow, divider, and 2×8 port grid.
* Width-driven sizing with 2.5:1 aspect ratio; three target sizes: 72px (plain), 68px (halo), 38px (compact).
* Optional theme with auto-detection from `Theme.of(context).brightness`.
* Material elevation via `PhysicalShape`.
* Theme-aware port grid colors for visibility on both dark and light backgrounds.
* **Port selection (spotlight mode)** — `selectedPorts`, `onPortSelected`, and `unselectedPortOpacity` parameters on `SwitchDeviceView`. Multi-select support; unselected ports dim when any are selected; selected ports keep their float animation.
* **Directional hover animation** — top-row (odd) ports float up, bottom-row (even) ports float down on hover, matching the two-row physical layout.
* **Stacked part deselect** — re-tapping the active stacked switch body now deselects it (sets `stackedPart` to 0), showing both units at full opacity.
* **`getPortPositions()` offset** — optional `parentOffset` parameter shifts all returned positions into the parent's coordinate space for topology line drawing.

## 0.1.0

* Initial release.
* Render network switch devices with 6–48 ports using Flutter's CustomPainter API.
* 22 built-in presets: single-unit (6–28P) and stacked two-unit (30–48P).
* Interactive ports with hover, tap callbacks, and status indicators (Up/Down/Unknown).
* Auto-adaptive layout engine: single-row, two-row, and stacked layouts.
* Dark and light theme support with automatic brightness detection.
* Configuration mode for setup/editing scenarios.
* Port position API for topology consumers.
