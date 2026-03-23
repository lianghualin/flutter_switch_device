# flutter_switch_device

A Flutter widget that renders network switch devices with interactive ports — fully programmatic, no SVG assets required.

## Features

- **6 to 48 ports** — single-unit (6–28P) and stacked two-unit (30–48P) layouts
- **Interactive ports** — hover, tap callbacks, and per-port status indicators (Up / Down / Unknown)
- **22 built-in presets** — from `Switch6P` to `Switch48PStacked`
- **Auto-adaptive layout** — single-row, two-row, or stacked based on port count
- **Dark & light themes** — auto-detects from `Theme.of(context).brightness`, or pass a custom theme
- **Configuration mode** — visual indicator for setup/editing scenarios
- **Port position API** — `SwitchDeviceView.getPortPositions()` for drawing connection lines
- **Zero external dependencies** — uses only Flutter's `CustomPainter` API

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_switch_device: ^0.1.0
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

### Get port positions (for topology lines)

```dart
final positions = SwitchDeviceView.getPortPositions(
  const Switch24P(),
  const Size(600, 200),
);
// positions => {1: Offset(x, y), 2: Offset(x, y), ...}
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
| `stackedPart` | `int` | Active unit for stacked switches (0, 1, 2) |
| `onStackedPartChanged` | `ValueChanged<int>?` | Stacked unit toggle callback |
| `theme` | `SwitchDeviceTheme?` | Optional theme override |

### PortStatus

- `PortStatus.up` — link active (green)
- `PortStatus.down` — link inactive (grey)
- `PortStatus.unknown` — status unknown (dark grey)

## Additional information

- [Example app](example/) — interactive demo with all switch presets
- [API documentation](https://pub.dev/documentation/flutter_switch_device/latest/)
- [Issue tracker](https://github.com/lianghualin/flutter_switch_device/issues)
