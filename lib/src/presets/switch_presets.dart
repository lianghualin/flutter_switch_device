import 'dart:ui';

import '../models/switch_format.dart';

// ---------------------------------------------------------------------------
// Single-unit switch presets (6P – 28P)
// ---------------------------------------------------------------------------

class Switch6P extends SwitchFormat {
  const Switch6P()
      : super(
          evenPortOffsetR: const [
            Offset(0.53, 0.204),
            Offset(0.58, 0.204),
            Offset(0.63, 0.204),
          ],
          oddPortOffsetR: const [
            Offset(0.53, 0.204),
            Offset(0.58, 0.204),
            Offset(0.63, 0.204),
          ],
          totalPortsNum: 6,
        );
}

class Switch8P extends SwitchFormat {
  const Switch8P()
      : super(
          evenPortOffsetR: const [
            Offset(0.505, 0.204),
            Offset(0.555, 0.204),
            Offset(0.60, 0.204),
            Offset(0.65, 0.204),
          ],
          oddPortOffsetR: const [
            Offset(0.505, 0.204),
            Offset(0.555, 0.204),
            Offset(0.60, 0.204),
            Offset(0.65, 0.204),
          ],
          totalPortsNum: 8,
        );
}

class Switch10P extends SwitchFormat {
  const Switch10P()
      : super(
          evenPortOffsetR: const [
            Offset(0.47, 0.204),
            Offset(0.52, 0.204),
            Offset(0.57, 0.204),
            Offset(0.615, 0.204),
            Offset(0.68, 0.204),
          ],
          oddPortOffsetR: const [
            Offset(0.47, 0.204),
            Offset(0.52, 0.204),
            Offset(0.57, 0.204),
            Offset(0.615, 0.204),
            Offset(0.68, 0.204),
          ],
          totalPortsNum: 10,
        );
}

class Switch12P extends SwitchFormat {
  const Switch12P()
      : super(
          evenPortOffsetR: const [
            Offset(0.44, 0.204),
            Offset(0.49, 0.204),
            Offset(0.54, 0.204),
            Offset(0.59, 0.204),
            Offset(0.655, 0.204),
            Offset(0.705, 0.204),
          ],
          oddPortOffsetR: const [
            Offset(0.44, 0.204),
            Offset(0.49, 0.204),
            Offset(0.54, 0.204),
            Offset(0.59, 0.204),
            Offset(0.655, 0.204),
            Offset(0.705, 0.204),
          ],
          totalPortsNum: 12,
        );
}

class Switch14P extends SwitchFormat {
  const Switch14P()
      : super(
          evenPortOffsetR: const [
            Offset(0.415, 0.223),
            Offset(0.465, 0.223),
            Offset(0.515, 0.223),
            Offset(0.565, 0.223),
            Offset(0.63, 0.223),
            Offset(0.68, 0.223),
            Offset(0.73, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.415, 0.185),
            Offset(0.465, 0.185),
            Offset(0.515, 0.185),
            Offset(0.565, 0.185),
            Offset(0.63, 0.185),
            Offset(0.68, 0.185),
            Offset(0.73, 0.185),
          ],
          totalPortsNum: 14,
        );
}

class Switch16P extends SwitchFormat {
  const Switch16P()
      : super(
          evenPortOffsetR: const [
            Offset(0.395, 0.223),
            Offset(0.445, 0.223),
            Offset(0.495, 0.223),
            Offset(0.545, 0.223),
            Offset(0.61, 0.223),
            Offset(0.655, 0.223),
            Offset(0.705, 0.223),
            Offset(0.755, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.395, 0.185),
            Offset(0.445, 0.185),
            Offset(0.495, 0.185),
            Offset(0.545, 0.185),
            Offset(0.61, 0.185),
            Offset(0.655, 0.185),
            Offset(0.705, 0.185),
            Offset(0.755, 0.185),
          ],
          totalPortsNum: 16,
        );
}

class Switch18P extends SwitchFormat {
  const Switch18P()
      : super(
          evenPortOffsetR: const [
            Offset(0.355, 0.223),
            Offset(0.405, 0.223),
            Offset(0.455, 0.223),
            Offset(0.505, 0.223),
            Offset(0.57, 0.223),
            Offset(0.62, 0.223),
            Offset(0.67, 0.223),
            Offset(0.72, 0.223),
            Offset(0.785, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.355, 0.185),
            Offset(0.405, 0.185),
            Offset(0.455, 0.185),
            Offset(0.505, 0.185),
            Offset(0.57, 0.185),
            Offset(0.62, 0.185),
            Offset(0.67, 0.185),
            Offset(0.72, 0.185),
            Offset(0.785, 0.185),
          ],
          totalPortsNum: 18,
        );
}

class Switch20P extends SwitchFormat {
  const Switch20P()
      : super(
          evenPortOffsetR: const [
            Offset(0.33, 0.223),
            Offset(0.38, 0.223),
            Offset(0.43, 0.223),
            Offset(0.48, 0.223),
            Offset(0.55, 0.223),
            Offset(0.60, 0.223),
            Offset(0.65, 0.223),
            Offset(0.70, 0.223),
            Offset(0.77, 0.223),
            Offset(0.82, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.33, 0.185),
            Offset(0.38, 0.185),
            Offset(0.43, 0.185),
            Offset(0.48, 0.185),
            Offset(0.55, 0.185),
            Offset(0.60, 0.185),
            Offset(0.65, 0.185),
            Offset(0.70, 0.185),
            Offset(0.77, 0.185),
            Offset(0.82, 0.185),
          ],
          totalPortsNum: 20,
        );
}

class Switch22P extends SwitchFormat {
  const Switch22P()
      : super(
          evenPortOffsetR: const [
            Offset(0.30, 0.223),
            Offset(0.35, 0.223),
            Offset(0.40, 0.223),
            Offset(0.45, 0.223),
            Offset(0.52, 0.223),
            Offset(0.57, 0.223),
            Offset(0.62, 0.223),
            Offset(0.67, 0.223),
            Offset(0.735, 0.223),
            Offset(0.785, 0.223),
            Offset(0.835, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.30, 0.185),
            Offset(0.35, 0.185),
            Offset(0.40, 0.185),
            Offset(0.45, 0.185),
            Offset(0.52, 0.185),
            Offset(0.57, 0.185),
            Offset(0.62, 0.185),
            Offset(0.67, 0.185),
            Offset(0.735, 0.185),
            Offset(0.785, 0.185),
            Offset(0.835, 0.185),
          ],
          totalPortsNum: 22,
        );
}

class Switch24P extends SwitchFormat {
  const Switch24P()
      : super(
          evenPortOffsetR: const [
            Offset(0.275, 0.223),
            Offset(0.325, 0.223),
            Offset(0.375, 0.223),
            Offset(0.425, 0.223),
            Offset(0.495, 0.223),
            Offset(0.545, 0.223),
            Offset(0.595, 0.223),
            Offset(0.645, 0.223),
            Offset(0.715, 0.223),
            Offset(0.765, 0.223),
            Offset(0.815, 0.223),
            Offset(0.865, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.275, 0.185),
            Offset(0.325, 0.185),
            Offset(0.375, 0.185),
            Offset(0.425, 0.185),
            Offset(0.495, 0.185),
            Offset(0.545, 0.185),
            Offset(0.595, 0.185),
            Offset(0.645, 0.185),
            Offset(0.715, 0.185),
            Offset(0.765, 0.185),
            Offset(0.815, 0.185),
            Offset(0.865, 0.185),
          ],
          totalPortsNum: 24,
        );
}

class Switch26P extends SwitchFormat {
  const Switch26P()
      : super(
          evenPortOffsetR: const [
            Offset(0.235, 0.223),
            Offset(0.285, 0.223),
            Offset(0.335, 0.223),
            Offset(0.385, 0.223),
            Offset(0.455, 0.223),
            Offset(0.505, 0.223),
            Offset(0.555, 0.223),
            Offset(0.605, 0.223),
            Offset(0.67, 0.223),
            Offset(0.72, 0.223),
            Offset(0.77, 0.223),
            Offset(0.82, 0.223),
            Offset(0.89, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.235, 0.185),
            Offset(0.285, 0.185),
            Offset(0.335, 0.185),
            Offset(0.385, 0.185),
            Offset(0.455, 0.185),
            Offset(0.505, 0.185),
            Offset(0.555, 0.185),
            Offset(0.605, 0.185),
            Offset(0.67, 0.185),
            Offset(0.72, 0.185),
            Offset(0.77, 0.185),
            Offset(0.82, 0.185),
            Offset(0.89, 0.185),
          ],
          totalPortsNum: 26,
        );
}

class Switch28P extends SwitchFormat {
  const Switch28P()
      : super(
          evenPortOffsetR: const [
            Offset(0.215, 0.223),
            Offset(0.265, 0.223),
            Offset(0.315, 0.223),
            Offset(0.365, 0.223),
            Offset(0.43, 0.223),
            Offset(0.48, 0.223),
            Offset(0.53, 0.223),
            Offset(0.58, 0.223),
            Offset(0.645, 0.223),
            Offset(0.695, 0.223),
            Offset(0.745, 0.223),
            Offset(0.795, 0.223),
            Offset(0.86, 0.223),
            Offset(0.91, 0.223),
          ],
          oddPortOffsetR: const [
            Offset(0.215, 0.185),
            Offset(0.265, 0.185),
            Offset(0.315, 0.185),
            Offset(0.365, 0.185),
            Offset(0.43, 0.185),
            Offset(0.48, 0.185),
            Offset(0.53, 0.185),
            Offset(0.58, 0.185),
            Offset(0.645, 0.185),
            Offset(0.695, 0.185),
            Offset(0.745, 0.185),
            Offset(0.795, 0.185),
            Offset(0.86, 0.185),
            Offset(0.91, 0.185),
          ],
          totalPortsNum: 28,
        );
}

// ---------------------------------------------------------------------------
// Stacked switch presets (30P – 48P)
// ---------------------------------------------------------------------------

const List<Offset> _stackedEvenPortOffsets = [
  // Upper 24-port switch even ports (ports 2,4,6...24)
  Offset(0.275, 0.073),
  Offset(0.325, 0.073),
  Offset(0.375, 0.073),
  Offset(0.425, 0.073),
  Offset(0.495, 0.073),
  Offset(0.545, 0.073),
  Offset(0.595, 0.073),
  Offset(0.645, 0.073),
  Offset(0.715, 0.073),
  Offset(0.765, 0.073),
  Offset(0.815, 0.073),
  Offset(0.865, 0.073),
  // Lower 24-port switch even ports (ports 26,28,30...48)
  Offset(0.275, 0.273),
  Offset(0.325, 0.273),
  Offset(0.375, 0.273),
  Offset(0.425, 0.273),
  Offset(0.495, 0.273),
  Offset(0.545, 0.273),
  Offset(0.595, 0.273),
  Offset(0.645, 0.273),
  Offset(0.715, 0.273),
  Offset(0.765, 0.273),
  Offset(0.815, 0.273),
  Offset(0.865, 0.273),
];

const List<Offset> _stackedOddPortOffsets = [
  // Upper 24-port switch odd ports (ports 1,3,5...23)
  Offset(0.275, 0.035),
  Offset(0.325, 0.035),
  Offset(0.375, 0.035),
  Offset(0.425, 0.035),
  Offset(0.495, 0.035),
  Offset(0.545, 0.035),
  Offset(0.595, 0.035),
  Offset(0.645, 0.035),
  Offset(0.715, 0.035),
  Offset(0.765, 0.035),
  Offset(0.815, 0.035),
  Offset(0.865, 0.035),
  // Lower 24-port switch odd ports (ports 25,27,29...47)
  Offset(0.275, 0.235),
  Offset(0.325, 0.235),
  Offset(0.375, 0.235),
  Offset(0.425, 0.235),
  Offset(0.495, 0.235),
  Offset(0.545, 0.235),
  Offset(0.595, 0.235),
  Offset(0.645, 0.235),
  Offset(0.715, 0.235),
  Offset(0.765, 0.235),
  Offset(0.815, 0.235),
  Offset(0.865, 0.235),
];

class Switch30PStacked extends SwitchFormat {
  const Switch30PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 30,
          isStacked: true,
        );
}

class Switch32PStacked extends SwitchFormat {
  const Switch32PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 32,
          isStacked: true,
        );
}

class Switch34PStacked extends SwitchFormat {
  const Switch34PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 34,
          isStacked: true,
        );
}

class Switch36PStacked extends SwitchFormat {
  const Switch36PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 36,
          isStacked: true,
        );
}

class Switch38PStacked extends SwitchFormat {
  const Switch38PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 38,
          isStacked: true,
        );
}

class Switch40PStacked extends SwitchFormat {
  const Switch40PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 40,
          isStacked: true,
        );
}

class Switch42PStacked extends SwitchFormat {
  const Switch42PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 42,
          isStacked: true,
        );
}

class Switch44PStacked extends SwitchFormat {
  const Switch44PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 44,
          isStacked: true,
        );
}

class Switch46PStacked extends SwitchFormat {
  const Switch46PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 46,
          isStacked: true,
        );
}

class Switch48PStacked extends SwitchFormat {
  const Switch48PStacked()
      : super(
          evenPortOffsetR: _stackedEvenPortOffsets,
          oddPortOffsetR: _stackedOddPortOffsets,
          hSizeFactor: 0.4,
          totalPortsNum: 48,
          validPortsNum: 48,
          isStacked: true,
        );
}

/// Returns the appropriate [SwitchFormat] preset for the given port count.
SwitchFormat switchFormatForPortCount(int portCount, {int? validPorts}) {
  if (validPorts != null) {
    return switch (validPorts) {
      <= 30 => const Switch30PStacked(),
      32 => const Switch32PStacked(),
      34 => const Switch34PStacked(),
      36 => const Switch36PStacked(),
      38 => const Switch38PStacked(),
      40 => const Switch40PStacked(),
      42 => const Switch42PStacked(),
      44 => const Switch44PStacked(),
      46 => const Switch46PStacked(),
      _ => const Switch48PStacked(),
    };
  }
  return switch (portCount) {
    <= 6 => const Switch6P(),
    8 => const Switch8P(),
    10 => const Switch10P(),
    12 => const Switch12P(),
    14 => const Switch14P(),
    16 => const Switch16P(),
    18 => const Switch18P(),
    20 => const Switch20P(),
    22 => const Switch22P(),
    24 => const Switch24P(),
    26 => const Switch26P(),
    28 => const Switch28P(),
    _ => const Switch24P(),
  };
}
