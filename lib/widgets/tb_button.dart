import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TbButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool secondary;

  const TbButton({super.key, required this.text, this.onPressed, this.icon, this.loading = false, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon ?? Icons.check_circle_outline),
      label: Text(text),
      style: FilledButton.styleFrom(
        backgroundColor: secondary ? AppColors.leaf : AppColors.forest,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
