import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdminRole = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        final route = authProvider.isAdmin 
            ? AppRoutes.adminDashboard 
            : AppRoutes.userHome;
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      final route = authProvider.isAdmin 
          ? AppRoutes.adminDashboard 
          : AppRoutes.userHome;
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title & Subtitle
                Text(AppStrings.appName, style: AppStyles.heading1Of(context)),
                const SizedBox(height: 8),
                Text(AppStrings.appTagline, style: AppStyles.subtitleOf(context)),
                const SizedBox(height: 48),

                // Login Card
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildRoleButton(AppStrings.user, !_isAdminRole),
                      _buildRoleButton(AppStrings.admin, _isAdminRole),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Inputs
                CustomTextField(
                  label: AppStrings.email,
                  hint: AppStrings.emailPlaceholder,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.mail_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextField(
                      label: AppStrings.password,
                      hint: AppStrings.passwordPlaceholder,
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      validator: Validators.validatePassword,
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset link sent to your email.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: AppStrings.login,
                      isLoading: auth.isLoading,
                      icon: Icons.arrow_forward,
                      onPressed: _handleLogin,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.orDivider,
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.dividerColor)),
                  ],
                ),
                const SizedBox(height: 32),

                // Google Sign In Button
                CustomButton(
                  text: AppStrings.continueWithGoogle,
                  isOutlined: true,
                  assetIcon: 'assets/icons/google_logo.png',
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: AppStyles.bodySmallOf(context),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: Text(
                        AppStrings.register,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink(AppStrings.privacyPolicy),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('•', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ),
                    _buildFooterLink(AppStrings.termsOfService),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('•', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ),
                    _buildFooterLink(AppStrings.support),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String title, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isAdminRole = title == AppStrings.admin),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? theme.colorScheme.surface : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [
              BoxShadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
            ] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
