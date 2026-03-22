import 'package:flutter/material.dart';
import '../models/port_data.dart';
import '../models/switch_device_theme.dart';
import '../painters/port_painter.dart';

/// Renders a single port with hover float animation and tap handling.
class PortWidget extends StatefulWidget {
  const PortWidget({
    super.key,
    required this.data,
    required this.theme,
    this.onHover,
    this.onHoverExit,
    this.onTap,
    this.isConfig = false,
  });

  final PortData data;
  final SwitchDeviceTheme theme;
  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;
  final VoidCallback? onTap;
  final bool isConfig;

  @override
  State<PortWidget> createState() => _PortWidgetState();
}

class _PortWidgetState extends State<PortWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatOffset = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final portColor = widget.theme.portColorForStatus(
      d.status,
      isConfig: widget.isConfig,
      isInvalid: d.isInvalid,
    );
    final labelColor = widget.theme.labelColorFor(portColor);

    return Positioned(
      left: d.position.dx,
      top: d.position.dy,
      child: MouseRegion(
        onEnter: (_) {
          _controller.forward();
          widget.onHover?.call();
        },
        onExit: (_) {
          _controller.reverse();
          widget.onHoverExit?.call();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _floatOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatOffset.value),
              child: child,
            ),
            child: Opacity(
              opacity: d.opacity * (d.isInvalid ? 0.4 : 1.0),
              child: SizedBox(
                width: d.width,
                height: d.height,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: PortPainter(color: portColor),
                      child: const SizedBox.expand(),
                    ),
                    if (d.showLabel)
                      Center(
                        child: Text(
                          d.label ?? '${d.portNumber}',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: (d.width * 0.38).clamp(6.0, 12.0),
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
