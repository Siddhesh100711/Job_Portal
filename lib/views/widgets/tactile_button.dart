import 'package:flutter/material.dart';

class TactileButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const TactileButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    // Use a listener for the scale effect to avoid conflicts with FilledButton's internal gesture handling
    return Listener(
      onPointerDown: isEnabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onPointerUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onPointerCancel: isEnabled
          ? (_) => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: FilledButton(
          onPressed: widget
              .onPressed, // Wire the onPressed directly to the FilledButton
          child: widget.child,
        ),
      ),
    );
  }
}
