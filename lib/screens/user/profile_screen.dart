import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.myProfile,
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Info
            Container(
              padding: const EdgeInsets.all(32),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surfaceLight,
                        child: Text(
                          user?.name[0].toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'User Name', style: AppStyles.heading2),
                  const SizedBox(height: 4),
                  Text(user?.email ?? 'user@example.com', style: AppStyles.subtitle),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'USER',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings List
            _buildSettingsGroup([
              _buildSettingItem(Icons.person_outline, AppStrings.editProfile, () {}),
              _buildSettingItem(Icons.notifications_none_outlined, AppStrings.notifications, () {}),
              _buildSettingItem(Icons.dark_mode_outlined, AppStrings.darkMode, () {}, trailing: Switch(value: false, onChanged: (v) {})),
            ]),

            const SizedBox(height: 16),

            _buildSettingsGroup([
              _buildSettingItem(Icons.help_outline, AppStrings.helpCenter, () {}),
              _buildSettingItem(Icons.info_outline, AppStrings.aboutApp, () {}),
            ]),

            const SizedBox(height: 32),

            // Sign Out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton(
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text(AppStrings.signOut, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(AppStrings.version, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: AppStyles.cardDecoration,
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
