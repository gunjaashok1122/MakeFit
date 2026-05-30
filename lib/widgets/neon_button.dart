import 'package:flutter/material';
import '../themes/app_theme.dart';

class NeonButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double? height;
  final double? width;
  final double borderRadius;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final bool isSecondary;

  const NeonButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.height = 52.0,
    this.width = double.infinity,
    this.borderRadius = 26.0,
    this.gradient,
    this.shadows,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final finalGradient = gradient ??
        (isSecondary ? AppTheme.accentGradient : AppTheme.primaryGradient);

    final finalShadows = shadows ??
        [
          BoxShadow(
            color: (isSecondary ? AppTheme.neonPink : AppTheme.neonPurple)
                .withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: isSecondary && gradient == null ? null : finalGradient,
        color: isSecondary && gradient == null ? Colors.transparent : null,
        border: isSecondary && gradient == null
            ? Border.all(color: AppTheme.neonPink, width: 1.5)
            : null,
        boxShadow: isSecondary && gradient == null ? [] : finalShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
