import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TbAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const TbAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.forest,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/tb_logo.jpg', height: 32, width: 32, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
