import 'package:flutter/material.dart';

// https://stackoverflow.com/a/66854056
class GradientButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient? gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width = 225,
    this.height = 55,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(20);
    final gradient = this.gradient ??
        LinearGradient(
          stops: const [0.1, 1],
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        );
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}
