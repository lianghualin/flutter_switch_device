# flutter_switch_device — Design Spec

## Goal

A standalone Flutter package that renders network switch devices with ports, fully programmatic (no SVG assets). Designed for pub.dev publishing and to be consumed by `device_topology_view`.

## Package Scope

The package owns:
- Switch body rendering (programmatic CustomPainter)
- Port rendering (programmatic CustomPainter)
- Port positioning engine (normalized offsets → absolute positions)
- Adaptive layout (auto-selects layout tier based on port count)
- Stacked switch support (two-body, tap-to-toggle)
- All 22 switch presets (6P–28P single, 30P–48P stacked)

The package does NOT own:
- Radial ring layout (floating devices around the switch)
- Connection lines
- Host/DPU device rendering
- Spotlight/dim logic for connected devices

## Dependencies

Flutter only. No `flutter_svg`, no `path_drawing`, no external packages.

## Public API

### Main Widget

```dart
SwitchDeviceView(
  size: Size(800, 400),
  format: const Switch24P(),              // named preset classes
  portStatuses: {1: PortStatus.up, 2: PortStatus.down, ...},  // int keys
  isConfig: false,
  onPortHover: (int portNum) {},
  onPortHoverExit: () {},
  onPortTap: (int portNum) {},
  onSwitchHover: () {},
  onSwitchHoverExit: () {},
  // Stacked only:
  stackedPart: 1,
  onStackedPartChanged: (int part) {},
)
```

### Port Position API

For consumers that need port coordinates (e.g. drawing connection lines):

```dart
static Map<int, Offset> SwitchDeviceView.getPortPositions(
  SwitchFormat format,
  Size viewportSize,
);
```

Synchronous and deterministic — returns the **center** position of each port in the coordinate space of the viewport. No layout timing dependency. Internal widget positioning adjusts to top-left by subtracting half the port width/height.

### Models

```dart
enum PortStatus { up, down, unknown }

class SwitchFormat {
  final List<Offset> evenPortOffsetR;   // normalized (0.0–1.0)
  final List<Offset> oddPortOffsetR;    // normalized (0.0–1.0)
  final int totalPortsNum;
  final int? validPortsNum;            // null for single-unit
  final bool isStacked;
  final double hSizeFactor;            // height as fraction of center size
  final double wSizeFactor;            // width as fraction of center size
  final double minWidth;
  final double minHeight;
}
```

### Presets

Named preset classes (e.g. `Switch6P()`, `Switch24P()`, `Switch48PStacked()`):
- Single-unit: 6P, 8P, 10P, 12P, 14P, 16P, 18P, 20P, 22P, 24P, 26P, 28P
- Stacked: 30P, 32P, 34P, 36P, 38P, 40P, 42P, 44P, 46P, 48P
- Helper: `switchFormatForPortCount(int portCount, {int? validPorts})`

## Visual Design

### Style: B2 — Clean Modern

- **Switch body:** Gradient background (#5a5a6e → #44445a), rounded corners, elevation shadow via PhysicalShape. (Note: this is a visual enhancement over the existing flat-color #555557 body.)
- **LED indicators:** Left side — green (power), yellow (status), grey (inactive)
- **Ports:** Rounded rectangles with pin detail lines and port number labels inside
- **Port grouping:** Grouped by 4s with small gaps between groups

### Port Colors

| State | Color |
|-------|-------|
| Up | Green (#2CC339) |
| Down | Grey (#9E9E9E) |
| Unknown | Black (#333) |
| Invalid | Black + semi-transparent |
| Config mode | All grey |

### Adaptive Layout

The widget auto-selects layout tier based on port count:

| Port Count | Layout | Port Arrangement | Port Size |
|------------|--------|------------------|-----------|
| 6–12 | Single body | 1 row (sequential) | Spacious (18–20px) |
| 14–28 | Single body | 2 rows (odd top, even bottom) | Scales with count (15–18px) |
| 30–48 | Stacked two-body | 2 rows per body (odd top, even bottom, 24 per body) | Compact (13px) |

**Note on Tier 1 (6–12P):** This is a deliberate visual change from the existing `device_topology_view` system, which uses two rows for all port counts. The new single-row layout for small switches is cleaner and was chosen during design brainstorming. The presets for 6–12P will have new single-row offset data (all ports at the same Y position). Port sizes are derived dynamically from the offset spacing and port count, not from a preset field.

### Stacked Switch Behavior

- One `SwitchDeviceView` widget renders two switch bodies vertically with a gap
- Active unit: full opacity + green border highlight (new visual enhancement; existing code only uses opacity)
- Inactive unit: 30% opacity
- Tap on either body to toggle active unit
- `stackedPart` controls which unit is active (1 = upper, 2 = lower, 0 = none)
- Ports exceeding `validPortsNum` are rendered as invalid (black + semi-transparent)

## Architecture

```
lib/
  flutter_switch_device.dart              # barrel export
  src/
    models/
      switch_format.dart                  # format model
      port_status.dart                    # enum
    presets/
      switch_presets.dart                 # all 22 presets
    painters/
      switch_body_painter.dart            # CustomPainter for chassis
      port_painter.dart                   # CustomPainter for port icon
    widgets/
      switch_device_view.dart             # main public widget
      port_widget.dart                    # single port with animation
    layout/
      switch_layout.dart                  # position calculator
```

### Component Boundaries

- **`switch_layout.dart`** — Pure calculation. `SwitchFormat` + viewport `Size` → `Map<int, Offset>` port center positions. Also determines adaptive tier. No widget dependencies.
- **`switch_body_painter.dart`** — Draws chassis only (gradient body, LEDs, rounded corners). Parameterized by `totalPorts` (LED count), tier (body height), and `isActive` (green border for stacked selection). No port drawing.
- **`port_painter.dart`** — Draws one port icon. Parameterized by color, pin detail visibility. Static helper `colorForStatus()` maps state to color.
- **`port_widget.dart`** — Wraps `port_painter` with hover float animation (300ms easeInOut), tap handler, port number label overlay. Positioned absolutely in parent Stack.
- **`switch_device_view.dart`** — Composes body + ports in a Stack. Owns: hover/tap state management, stacked toggle logic, adaptive tier selection, `getPortPositions()` static method.

### Port Position Calculation

The existing normalized offset system is preserved inside the package:

1. Calculate center device size from viewport: `centerSize = 500.0 × scaleFactor`
2. For each port, look up normalized offset from `SwitchFormat`
3. Scale: `portX = centerPosition.dx + centerSize × offset.dx`
4. Scale: `portY = centerPosition.dy + centerSize × offset.dy`
5. Return map of portNumber → center Offset

For Tier 1 (6–12P), presets will use single-row offset data (all ports at the same Y position) so the odd/even lookup still works — both arrays share the same Y value. All tiers use the same offset-based calculation; the visual difference comes from the preset data itself.

## Integration Plan

After `flutter_switch_device` is complete, `device_topology_view` will:

1. Add `flutter_switch_device` as a dependency
2. Replace `SvgClip`-based switch rendering with `SwitchDeviceView`
3. Replace `SwitchDeviceFormat` with `SwitchFormat` (or map between them)
4. Call `SwitchDeviceView.getPortPositions()` for connection line endpoints
5. Remove switch and port SVG files from `assets/images/`
6. Remove `PortWidget` (now owned by `flutter_switch_device`)

What stays in `device_topology_view`: radial ring layout, connection lines, floating devices, host/DPU rendering, spotlight/dim logic.

## Example App

The example app provides:
- Dropdown scenario selector (different port counts: 6P, 12P, 24P, 28P, 48P stacked)
- Port status randomizer button
- Config mode toggle
- Stacked part toggle (for stacked scenarios)
- Event log showing port hover/tap callbacks
