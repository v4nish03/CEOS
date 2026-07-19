import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumGlass {
  static const Color canvas = Color(0xFFF1F5F9);
  static const Color canvasLight = Color(0xFFF8FAFC);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate500 = Color(0xFF64748B);
  static const Color glassBorder = Color(0xE6FFFFFF);

  static BoxDecoration glassDecoration({
    double radius = 16,
    Color color = const Color(0xB4FFFFFF),
    Color borderColor = glassBorder,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.white.withAlpha(160),
          blurRadius: 10,
          offset: const Offset(-3, -3),
        ),
      ],
    );
  }

  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: color.withAlpha(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
    );
  }
}

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PremiumGlass.canvas,
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _BlurOrb(color: Theme.of(context).colorScheme.secondary.withAlpha(46), size: 230),
          ),
          const Positioned(
            top: 190,
            left: -120,
            child: _BlurOrb(color: Color(0x6693C5FD), size: 260),
          ),
          const Positioned(
            bottom: -80,
            right: -90,
            child: _BlurOrb(color: Color(0x66CCFBF1), size: 260),
          ),
          Positioned.fill(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: PremiumGlass.glassDecoration(radius: borderRadius, color: color ?? Colors.white.withAlpha(180)),
          child: child,
        ),
      ),
    );
  }
}

class PremiumSectionTitle extends StatelessWidget {
  const PremiumSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: PremiumGlass.slate800,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(color: PremiumGlass.slate500, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
