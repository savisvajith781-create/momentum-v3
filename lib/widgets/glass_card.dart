import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;
  final bool highlight;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.blur = 12,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: highlight
                  ? AppColors.primary.withOpacity(0.4)
                  : (borderColor ?? AppColors.glassBorder),
              width: highlight ? 1.5 : 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}
