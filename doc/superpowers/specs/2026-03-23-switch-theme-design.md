# SwitchDeviceTheme — Design Spec

## Goal

Add dark and light theme support to `flutter_switch_device`. The widget auto-detects the app's theme via `Theme.of(context).brightness` and can be overridden with an explicit `theme` parameter.

## Public API Changes

### New: `SwitchDeviceTheme`

```dart
class SwitchDeviceTheme {
  const SwitchDeviceTheme({
    required this.bodyGradientStart,
    required this.bodyGradientEnd,
    required this.portUp,
    required this.portDown,
    required this.portUnknown,
    required this.portLabelOnLight,
    required this.portLabelOnDark,
    required this.activeColor,
    required this.ledGreen,
    required this.ledYellow,
    required this.ledInactive,
    required this.dividerColor,
    required this.shadowOpacity,
  });

  final Color bodyGradientStart;
  final Color bodyGradientEnd;
  final Color portUp;
  final Color portDown;
  final Color portUnknown;
  final Color portLabelOnLight;   // text color on down/unknown ports
  final Color portLabelOnDark;    // text color on up/active ports
  final Color activeColor;        // green border for stacked active unit
  final Color ledGreen;
  final Color ledYellow;
  final Color ledInactive;
  final Color dividerColor;
  final double shadowOpacity;

  const SwitchDeviceTheme.dark()
      : bodyGradientStart = const Color(0xFF5A5A6E),
        bodyGradientEnd = const Color(0xFF44445A),
        portUp = const Color(0xFF2CC339),
        portDown = const Color(0xFF9E9E9E),
        portUnknown = const Color(0xFF333333),
        portLabelOnLight = const Color(0xFFFFFFFF),
        portLabelOnDark = const Color(0xFFFFFFFF),
        activeColor = const Color(0xFF2CC339),
        ledGreen = const Color(0xFF49B87D),
        ledYellow = const Color(0xFFF0CC18),
        ledInactive = const Color(0xFF414142),
        dividerColor = const Color(0xFF414142),
        shadowOpacity = 0.4;

  const SwitchDeviceTheme.light()
      : bodyGradientStart = const Color(0xFFD8DAE0),
        bodyGradientEnd = const Color(0xFFC2C4CC),
        portUp = const Color(0xFF34A853),
        portDown = const Color(0xFFBDBDBD),
        portUnknown = const Color(0xFFE0E0E0),
        portLabelOnLight = const Color(0xFF444444),
        portLabelOnDark = const Color(0xFFFFFFFF),
        activeColor = const Color(0xFF34A853),
        ledGreen = const Color(0xFF34A853),
        ledYellow = const Color(0xFFE8A317),
        ledInactive = const Color(0xFFB0B2BA),
        dividerColor = const Color(0xFFB0B2BA),
        shadowOpacity = 0.12;
}
```

### Modified: `SwitchDeviceView`

```dart
SwitchDeviceView(
  ...existing params unchanged...,
  theme: SwitchDeviceTheme.light(),  // NEW — optional
)
```

When `theme` is null (default), the widget reads `Theme.of(context).brightness`:
- `Brightness.dark` → `SwitchDeviceTheme.dark()`
- `Brightness.light` → `SwitchDeviceTheme.light()`

When `theme` is provided, it is used directly regardless of the app theme.

## Color Mapping

### Dark Theme (current values preserved)

| Element | Color |
|---------|-------|
| Body gradient | #5A5A6E → #44445A |
| Port Up | #2CC339 (green) |
| Port Down | #9E9E9E (grey) |
| Port Unknown | #333333 (dark) |
| Port labels | White on all ports |
| Active border | #2CC339 |
| LEDs | Green #49B87D, Yellow #F0CC18, Inactive #414142 |
| Shadow | opacity 0.4 |

### Light Theme (new)

| Element | Color |
|---------|-------|
| Body gradient | #D8DAE0 → #C2C4CC |
| Port Up | #34A853 (green, adjusted for light bg) |
| Port Down | #BDBDBD (light grey) |
| Port Unknown | #E0E0E0 (very light grey) |
| Port labels | White on green (up) ports, #444 on light (down/unknown) ports |
| Active border | #34A853 |
| LEDs | Green #34A853, Yellow #E8A317, Inactive #B0B2BA |
| Shadow | opacity 0.12 |

### Port Label Color Logic

The label color depends on whether the port's background is light or dark:
- **Up ports (green):** always use `portLabelOnDark` (white) — green is dark enough
- **Down/Unknown ports:** use `portLabelOnLight` in light theme (#444), `portLabelOnDark` in dark theme (white)
- **Invalid ports:** same as unknown but with reduced opacity
- **Config mode ports:** same as down

Implementation: `PortPainter.colorForStatus` gains a theme parameter and returns both the port color and the appropriate label color together. Or simpler: derive label color from port color brightness.

Recommended approach: compute label color from port background brightness:
```dart
Color labelColor = portColor.computeLuminance() > 0.5
    ? theme.portLabelOnLight
    : theme.portLabelOnDark;
```

This is self-correcting — no need to manually map each status to a label color.

## Architecture

### Theme Propagation

```
SwitchDeviceView (resolves theme from context or explicit param)
  ├── SwitchBodyPainter (receives theme for body, LED, divider colors)
  └── PortWidget (receives theme)
       └── PortPainter (receives port color from theme)
           └── Port label text (receives label color derived from port color + theme)
```

### Files Changed

| Action | File | Change |
|--------|------|--------|
| Create | `lib/src/models/switch_device_theme.dart` | Theme data class with dark/light constructors, `==`/`hashCode` |
| Modify | `lib/src/painters/switch_body_painter.dart` | `SwitchBodyPainter`: accept `SwitchDeviceTheme`, replace all hardcoded colors, update `shouldRepaint` to compare theme. `SwitchBodyWidget`: accept theme, pass `theme.bodyGradientEnd` to `PhysicalShape(color:)` and `Colors.black.withValues(alpha: theme.shadowOpacity)` to `shadowColor` |
| Modify | `lib/src/painters/port_painter.dart` | `colorForStatus` takes theme instead of hardcoded colors |
| Modify | `lib/src/widgets/port_widget.dart` | Accept theme, derive label color from port color brightness |
| Modify | `lib/src/widgets/switch_device_view.dart` | Accept optional `theme`, resolve from `BuildContext` |
| Modify | `lib/flutter_switch_device.dart` | Export `SwitchDeviceTheme` |
| Modify | `example/lib/main.dart` | Add dark/light theme toggle |

### Implementation Details

**`SwitchDeviceTheme` equality:** The class must implement `operator ==` and `hashCode` (comparing all fields) so that `shouldRepaint` and Flutter's widget rebuild diffing work correctly.

**`SwitchBodyPainter.shouldRepaint`:** Must compare `theme` in addition to `totalPorts` and `isActive`. With `==` on the theme class, this becomes: `old.totalPorts != totalPorts || old.isActive != isActive || old.theme != theme`.

**`PhysicalShape` shadow wiring:** `SwitchBodyWidget.build` currently passes `SwitchBodyPainter._bodyGradientEnd` as `PhysicalShape(color:)` and `Colors.black` as `shadowColor`. Both must update:
- `color: theme.bodyGradientEnd`
- `shadowColor: Colors.black.withValues(alpha: theme.shadowOpacity)`

### What Does NOT Change

- `SwitchFormat`, `PortData`, `PortStatus` — unchanged
- All presets — unchanged
- Layout engine — unchanged (no color logic)
- Existing `SwitchDeviceView` constructor params — all preserved, `theme` is additive

## Example App Enhancement

Add a theme toggle to the example app controls:

```dart
SegmentedButton<ThemeMode>(
  segments: [
    ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
  ],
  ...
)
```

When "Auto" is selected, `theme` parameter is omitted (auto-detects). When "Dark" or "Light" is selected, pass the explicit theme.
