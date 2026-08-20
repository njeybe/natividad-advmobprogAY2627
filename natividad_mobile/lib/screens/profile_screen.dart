import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

/// ENHANCEMENT 3: Profile Screen rendering User model data from SharedPreferences/API
/// Features full profile information cards, avatar rendering, theme integration,
/// and secure logout functionality.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ENHANCEMENT 3: Load user data into typed User model
  void _loadUserProfile() {
    setState(() {
      _userFuture = _userService.getUser();
    });
  }

  // Handle logout with confirmation dialog
  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
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
            text: 'Are you sure you want to sign out of your account?',
            fontSize: 13.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: CustomText(
                text: 'Cancel',
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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
      await _userService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.redAccent),
                  SizedBox(height: 12.h),
                  CustomText(
                    text: 'Failed to load profile data',
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          final String fullName = '${user.firstName} ${user.lastName}'.trim();
          final String displayName = fullName.isNotEmpty ? fullName : user.username;

          return RefreshIndicator(
            onRefresh: () async => _loadUserProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  // ENHANCEMENT 3: Avatar with fallback
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100.r,
                          height: 100.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: primaryColor,
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: user.image.isNotEmpty
                                ? Image.network(
                                    user.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: 50.sp,
                                      color: primaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: primaryColor,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Full name
                  CustomText(
                    text: displayName,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),

                  SizedBox(height: 4.h),

                  // Username badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CustomText(
                      text: '@${user.username}',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ENHANCEMENT 3: Profile Info Cards (Email, Gender, User ID)
                  _buildInfoCard(
                    context,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email.isNotEmpty ? user.email : 'Not provided',
                  ),

                  SizedBox(height: 12.h),

                  _buildInfoCard(
                    context,
                    icon: Icons.person_outline,
                    label: 'Gender',
                    value: user.gender.isNotEmpty ? user.gender : 'Not specified',
                  ),

                  SizedBox(height: 12.h),

                  _buildInfoCard(
                    context,
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: '#${user.id}',
                  ),

                  SizedBox(height: 32.h),

                  // ENHANCEMENT 3: Logout Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: Icon(Icons.logout_rounded, size: 18.sp, color: Colors.white),
                      label: CustomText(
                        text: 'Log Out',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE55858),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Reusable Info Card Widget
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: primaryColor,
            ),
          ),
          SizedBox(width: 14.w),
          CustomText(
            text: label,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: CustomText(
              text: value,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
