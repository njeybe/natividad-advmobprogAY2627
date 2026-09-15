import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

/// LAB ACT 2 & 5 - ENHANCEMENT 3: Settings screen housing Dark/Light mode switch and Logout action
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final UserService userService = UserService();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: CustomText(
            text: 'Log Out',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          content: CustomText(
            text: 'Are you sure you want to log out of your account?',
            fontSize: 13.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: CustomText(
                text: 'Cancel',
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: CustomText(
                text: 'Log Out',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await userService.logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Setting Tile
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                secondary: Icon(
                  themeModel.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                title: CustomText(
                  text: 'Dark Mode',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: CustomText(
                  text: themeModel.isDark ? 'Dark theme enabled' : 'Light theme enabled',
                  fontSize: 11.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                value: themeModel.isDark,
                onChanged: (_) => themeModel.toggleTheme(),
              ),
            ),

            SizedBox(height: 16.h),

            // LAB ACT 5 - ENHANCEMENT 3: Include Logout in settings -> back to login
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 22.sp,
                  ),
                ),
                title: CustomText(
                  text: 'Log Out',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
                subtitle: CustomText(
                  text: 'Clears session/token and redirects to login',
                  fontSize: 11.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef SettingScreen = SettingsScreen;
