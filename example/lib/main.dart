import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_switch_device/flutter_switch_device.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_switch_device demo',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: DemoPage(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _scenarios = <String, SwitchFormat>{
    '6P': Switch6P(),
    '12P': Switch12P(),
    '24P': Switch24P(),
    '28P': Switch28P(),
    '48P Stacked': Switch48PStacked(),
    '30P Stacked': Switch30PStacked(),
  };

  String _selectedScenario = '24P';
  Map<int, PortStatus> _portStatuses = {};
  bool _isConfig = false;
  int _stackedPart = 1;
  final List<String> _eventLog = [];

  SwitchFormat get _format => _scenarios[_selectedScenario]!;

  void _randomizeStatuses() {
    final rng = Random();
    final statuses = <int, PortStatus>{};
    final total = _format.totalPortsNum;
    for (int i = 1; i <= total; i++) {
      statuses[i] = PortStatus.values[rng.nextInt(PortStatus.values.length)];
    }
    setState(() => _portStatuses = statuses);
  }

  void _log(String event) {
    setState(() {
      _eventLog.insert(0, event);
      if (_eventLog.length > 20) _eventLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStacked = _format.isStacked;

    return Scaffold(
      appBar: AppBar(title: const Text('flutter_switch_device demo')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _selectedScenario,
                  items: _scenarios.keys
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedScenario = v!;
                    _portStatuses = {};
                    _stackedPart = _format.isStacked ? 1 : 0;
                  }),
                ),
                ElevatedButton(
                  onPressed: _randomizeStatuses,
                  child: const Text('Randomize statuses'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Config mode'),
                    Switch(
                      value: _isConfig,
                      onChanged: (v) => setState(() => _isConfig = v),
                    ),
                  ],
                ),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                  ],
                  selected: {widget.themeMode},
                  onSelectionChanged: (s) =>
                      widget.onThemeModeChanged(s.first),
                ),
                if (isStacked)
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Upper')),
                      ButtonSegment(value: 2, label: Text('Lower')),
                    ],
                    selected: {_stackedPart},
                    onSelectionChanged: (s) =>
                        setState(() => _stackedPart = s.first),
                  ),
              ],
            ),
          ),

          // Switch icon (compact representation)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Icon sizes:  ',
                    style: TextStyle(fontSize: 12)),
                const SwitchIconWidget(size: 72),
                const SizedBox(width: 16),
                const SwitchIconWidget(size: 68, elevation: 2),
                const SizedBox(width: 16),
                const SwitchIconWidget(size: 38, elevation: 1),
              ],
            ),
          ),

          // Switch view
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewSize = Size(
                    constraints.maxWidth.clamp(400, 1500),
                    constraints.maxHeight.clamp(200, 800),
                  );
                  return SwitchDeviceView(
                    size: viewSize,
                    format: _format,
                    portStatuses: _portStatuses,
                    isConfig: _isConfig,
                    stackedPart: _stackedPart,
                    onStackedPartChanged: (part) {
                      setState(() => _stackedPart = part);
                      _log('Stacked part changed: $part');
                    },
                    onPortHover: (port) => _log('Hover: port $port'),
                    onPortHoverExit: () {},
                    onPortTap: (port) => _log('Tap: port $port'),
                    onSwitchHover: () {},
                    onSwitchHoverExit: () {},
                  );
                },
              ),
            ),
          ),

          // Event log
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event Log',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: _eventLog
                        .map((e) => Text(e,
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace')))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
