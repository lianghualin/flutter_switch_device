# flutter_switch_device

A Flutter widget that renders network switch devices with interactive ports — fully programmatic, no SVG assets required.

## Example

![flutter_switch_device demo](https://raw.githubusercontent.com/lianghualin/flutter_switch_device/main/doc/example.gif)

## Features

- **6 to 48 ports** — single-unit (6–28P) and stacked two-unit (30–48P) layouts
- **Interactive ports** — hover, tap callbacks, and per-port status indicators (Up / Down / Unknown)
- **22 built-in presets** — from `Switch6P` to `Switch48PStacked`
- **Auto-adaptive layout** — single-row, two-row, or stacked based on port count
- **Dark & light themes** — auto-detects from `Theme.of(context).brightness`, or pass a custom theme
- **Configuration mode** — visual indicator for setup/editing scenarios
- **Port position API** — `SwitchDeviceView.getPortPositions()` for drawing connection lines, with optional `parentOffset` for topology coordinate spaces
- **Port selection (spotlight mode)** — multi-select ports with `selectedPorts`; unselected ports dim automatically
- **Directional hover** — top-row ports float up, bottom-row ports float down
- **Stacked part toggle** — re-tap the active unit to deselect and show both at full opacity
- **Compact switch icon** — `SwitchIconWidget` for topology views (3 LEDs, 2×8 port grid, 3 sizes)
- **Zero external dependencies** — uses only Flutter's `CustomPainter` API

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_switch_device: ^0.3.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic 24-port switch

```dart
import 'package:flutter_switch_device/flutter_switch_device.dart';

SwitchDeviceView(
  size: const Size(600, 200),
  format: const Switch24P(),
  portStatuses: {
    1: PortStatus.up,
    2: PortStatus.down,
    3: PortStatus.unknown,
  },
  onPortTap: (port) => print('Tapped port $port'),
  onPortHover: (port) => print('Hovering port $port'),
)
```

### Stacked 48-port switch

```dart
SwitchDeviceView(
  size: const Size(600, 400),
  format: const Switch48PStacked(),
  portStatuses: portMap,
  stackedPart: 1, // 1 = upper unit active, 2 = lower
  onStackedPartChanged: (part) => setState(() => _stackedPart = part),
  onPortTap: (port) => print('Tapped port $port'),
)
```

### Port selection (spotlight mode)

```dart
SwitchDeviceView(
  size: const Size(600, 200),
  format: const Switch24P(),
  portStatuses: portMap,
  selectedPorts: {1, 3, 7},              // highlighted ports
  onPortSelected: (port) {               // toggle selection
    setState(() {
      if (_selected.contains(port)) {
        _selected.remove(port);
      } else {
        _selected.add(port);
      }
    });
  },
  unselectedPortOpacity: 0.15,           // dim unselected ports
)
```

### Get port positions (for topology lines)

```dart
final positions = SwitchDeviceView.getPortPositions(
  const Switch24P(),
  const Size(600, 200),
  parentOffset: switchWidgetOffset,       // optional: shift to parent coords
);
// positions => {1: Offset(x, y), 2: Offset(x, y), ...}
```

### Compact switch icon

```dart
// Auto-detects theme from context
SwitchIconWidget(size: 72)

// Explicit theme and elevation
SwitchIconWidget(
  size: 38,
  elevation: 2,
  theme: SwitchDeviceTheme.dark(),
)
```

### Select preset by port count

```dart
final format = switchFormatForPortCount(24); // returns Switch24P()
```

## Layout tiers

| Port count | Layout | Example presets |
|------------|--------|-----------------|
| 6–12 | Single-row sequential | `Switch6P`, `Switch12P` |
| 14–28 | Two-row (odd top, even bottom) | `Switch14P`, `Switch24P`, `Switch28P` |
| 30–48 | Stacked two-unit | `Switch30PStacked`, `Switch48PStacked` |

## API reference

### SwitchDeviceView

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `Size` | Viewport size for the switch |
| `format` | `SwitchFormat` | Switch preset (e.g. `Switch24P()`) |
| `portStatuses` | `Map<int, PortStatus>` | Per-port status map |
| `isConfig` | `bool` | Enable configuration mode |
| `onPortTap` | `ValueChanged<int>?` | Port tap callback |
| `onPortHover` | `ValueChanged<int>?` | Port hover callback |
| `onPortHoverExit` | `VoidCallback?` | Port hover exit callback |
| `stackedPart` | `int` | Active unit for stacked switches (0=both, 1=upper, 2=lower) |
| `onStackedPartChanged` | `ValueChanged<int>?` | Stacked unit toggle callback (re-tap deselects) |
| `selectedPorts` | `Set<int>` | Currently selected ports for spotlight mode |
| `onPortSelected` | `ValueChanged<int>?` | Port selection toggle callback |
| `unselectedPortOpacity` | `double` | Opacity for unselected ports in spotlight mode (default: 0.15) |
| `theme` | `SwitchDeviceTheme?` | Optional theme override |

### SwitchIconWidget

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `double` | Icon width; height = size / 2.5 |
| `elevation` | `double` | Material elevation (default: 5) |
| `theme` | `SwitchDeviceTheme?` | Optional theme; auto-detects from context |

### PortStatus

- `PortStatus.up` — link active (green)
- `PortStatus.down` — link inactive (grey)
- `PortStatus.unknown` — status unknown (dark grey)

## Additional information

- [Example app](example/) — interactive demo with all switch presets
- [API documentation](https://pub.dev/documentation/flutter_switch_device/latest/)
- [Issue tracker](https://github.com/lianghualin/flutter_switch_device/issues)
