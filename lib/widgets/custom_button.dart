import 'package:flutter/material.dart';
import '../core/constants/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final String? assetIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: AppStyles.outlinedButtonStyle.copyWith(
          foregroundColor: WidgetStateProperty.all(theme.colorScheme.onSurface),
          side: WidgetStateProperty.all(BorderSide(color: theme.dividerColor, width: 1.5)),
        ),
        child: _buildContent(context),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppStyles.primaryButtonStyle,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null || assetIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetIcon != null) ...[
            Image.asset(assetIcon!, width: 22, height: 22),
            const SizedBox(width: 10),
          ],
          Text(text),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      );
    }

    return Text(text);
  }
}
