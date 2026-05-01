import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class BelezeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? avatar;
  final VoidCallback? onAvatarPressed;
  final bool showLogo;
  final String? title;

  const BelezeTopBar({
    super.key,
    this.avatar,
    this.onAvatarPressed,
    this.showLogo = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: showLogo
          ? Text(
              'BELEZE',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryContainer,
                letterSpacing: 0.2,
              ),
            )
          : Text(
              title ?? '',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
      actions: [
        if (avatar != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: onAvatarPressed,
              child: avatar!,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
