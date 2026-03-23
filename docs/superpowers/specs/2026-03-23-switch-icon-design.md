# Switch Icon (Floating Device) — Design Spec

## Goal

Add a programmatic switch icon widget to `flutter_switch_device` that replaces `switch_float.svg` in `device_topology_view`. Used as a small icon (~50-100px) representing a connected switch device in the radial ring layout.

## Style: B3 — Wider Body + 2×8 Port Grid

### Visual Structure

- **Shape:** Wider rounded rectangle chassis (aspect ratio ~2.5:1)
- **Left panel:** 3 vertically-stacked LEDs:
  - Green power LED with glow effect (`box-shadow: 0 0 3px`)
  - Yellow status LED with glow effect (`box-shadow: 0 0 2px`)
  - Grey inactive LED (no glow)
- **Divider:** Thin vertical line between LED panel and port area (`rgba(255,255,255,0.08)`)
- **Port area:** 2 rows × 8 columns of small translucent port squares:
  - Color: `rgba(255,255,255,0.3)`
  - Rounded corners: 0.5px
  - Grouped 4+4 per row with a small gap between groups
- **Body:** Gradient background matching main switch body (#5a5a6e → #44445a)
- **Edge highlight:** Subtle top-edge light reflection (linear gradient, transparent → rgba white 0.12 → transparent)
- **Shadow:** Elevation via PhysicalShape

### Sizes

| Context | Icon Width | Icon Height | Halo Size |
|---------|-----------|-------------|-----------|
| Plain (64px) | 72px | 28px | none |
| In status halo | 68px | 26px | 100px circle |
| Small/compact | 38px | 16px | 50px circle |

All sizes maintain the same visual structure — LEDs, divider, port grid remain readable at every size.

### Colors (from SwitchDeviceTheme)

- Body gradient: `theme.bodyGradientStart` → `theme.bodyGradientEnd`
- LEDs: `theme.ledGreen`, `theme.ledYellow`, `theme.ledInactive`
- Divider: `theme.dividerColor`
- Port squares: `rgba(255,255,255,0.3)` (or derived from theme)
- Edge highlight: `rgba(255,255,255,0.12)`

## Usage Context in device_topology_view

- **Compact mode:** Icon only, used for outer ring / config devices
- **Full mode:** Icon inside a green (deviceStatus=true) or red (deviceStatus=false) circular status halo, used for inner ring / real devices
- Elevation scales with hover animation: `2 + animationValue * 5`

## Implementation

### New Files

- `lib/src/painters/switch_icon_painter.dart` — CustomPainter that draws the icon
- `lib/src/widgets/switch_icon_widget.dart` — Widget wrapping painter in PhysicalShape for elevation

### Public API

```dart
SwitchIconWidget(
  size: 72,           // width; height auto-calculated from aspect ratio
  elevation: 5,
  theme: SwitchDeviceTheme.dark(),  // optional, auto-detects from context
)
```

### Painter Details

`SwitchIconPainter` draws:
1. Gradient body with rounded corners (cornerRadius = height * 0.15)
2. Left panel (~15% of width): 3 LEDs vertically centered with glow
3. Vertical divider at panel edge
4. Port area: 2 rows of 8 squares, grouped 4+4 with gap
5. Top-edge highlight line

### Export

Add to barrel file `lib/flutter_switch_device.dart`:
```dart
export 'src/widgets/switch_icon_widget.dart';
export 'src/painters/switch_icon_painter.dart';
```

## Integration with device_topology_view

Replace in `switch_dev_float.dart`:
```dart
// Before:
SvgClip(path: 'assets/images/switch_float.svg', elevation: ...)

// After:
SwitchIconWidget(size: widget.size, elevation: ...)
```

Then remove `assets/images/switch_float.svg`.
