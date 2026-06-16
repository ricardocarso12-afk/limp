import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.softCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sage.withOpacity(.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: card);
  }
}
