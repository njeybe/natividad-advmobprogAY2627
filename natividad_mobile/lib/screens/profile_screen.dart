import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

/// LAB ACT 4 & 5 - ENHANCEMENT 3: ProfileScreen displaying user details depending on LoginType
/// and enabling update username, change password, and delete account.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // LAB ACT 5 - ENHANCEMENT 3: Fetch user data via UserService().getUserData()
  void _loadUserProfile() {
    setState(() {
      _userDataFuture = _userService.getUserData();
    });
  }

  // LAB ACT 5 - ENHANCEMENT 3: Dialog to Update User (Full Name & Username) in Firebase
  Future<void> _showUpdateUserDialog({
    required String currentFullName,
    required String currentUsername,
  }) async {
    final fullNameController = TextEditingController(text: currentFullName);
    final usernameController = TextEditingController(text: currentUsername);
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: CustomText(
            text: 'Update User Profile',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Full name cannot be empty'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter username',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Username cannot be empty'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final trimmedFullName = fullNameController.text.trim();
                  final cleanUsername = usernameController.text.trim().replaceFirst(RegExp(r'^@'), '');

                  String newFirstName = trimmedFullName;
                  String newLastName = '';
                  if (trimmedFullName.contains(' ')) {
                    final index = trimmedFullName.indexOf(' ');
                    newFirstName = trimmedFullName.substring(0, index).trim();
                    newLastName = trimmedFullName.substring(index + 1).trim();
                  }

                  try {
                    await _userService.updateUserProfile(
                      firstName: newFirstName,
                      lastName: newLastName,
                      username: cleanUsername,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Failed to update profile: $e'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    fullNameController.dispose();
    usernameController.dispose();

    if (updated == true) {
      _loadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // LAB ACT 5 - ENHANCEMENT 3: Dialog to Change Password in Firebase
  Future<void> _showChangePasswordDialog(String email) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final changed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: CustomText(
            text: 'Change Password',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter current password'
                      : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter new password';
                    }
                    if (val.length < 6) {
                      return 'Must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _userService.resetPasswordFromCurrentPassword(
                      currentPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text,
                      email: email,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Failed: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Update Password'),
            ),
          ],
        );
      },
    );

    if (changed == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // LAB ACT 5 - ENHANCEMENT 3: Dialog to Delete Firebase Account
  Future<void> _showDeleteAccountDialog(String email) async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8.w),
              CustomText(
                text: 'Delete Account',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'This action is permanent and cannot be undone. Enter your password to confirm.',
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter your password'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _userService.deleteAccount(
                      email: email,
                      password: passwordController.text,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Delete failed: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    }
  }

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
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
            child: Icon(icon, color: primaryColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: value,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
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

          final data = snapshot.data!;
          final isFirebase = data['loginType'] == 'firebase';
          final String username = data['username'] ?? '';
          final String email = data['email'] ?? '';
          final String firstName = data['firstName'] ?? '';
          final String lastName = data['lastName'] ?? '';
          final String fullName = '$firstName $lastName'.trim();
          final String displayName = fullName.isNotEmpty
              ? fullName
              : (username.isNotEmpty ? username : email.split('@').first);
          final String image = data['image'] ?? '';

          return RefreshIndicator(
            onRefresh: () async => _loadUserProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  // Profile Avatar
                  Center(
                    child: Container(
                      width: 96.r,
                      height: 96.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.15),
                        border: Border.all(color: primaryColor, width: 2.5),
                      ),
                      child: ClipOval(
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.person,
                                  size: 48.sp,
                                  color: primaryColor,
                                ),
                              )
                            : Icon(
                                isFirebase ? Icons.person : Icons.face,
                                size: 48.sp,
                                color: primaryColor,
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Display Name
                  CustomText(
                    text: displayName,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),

                  if (username.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    CustomText(
                      text: '@$username',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],

                  SizedBox(height: 6.h),

                  // LAB ACT 5 - ENHANCEMENT 3: LoginType Indicator Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isFirebase
                          ? const Color(0xFFFFA000).withValues(alpha: 0.15)
                          : primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFirebase ? Icons.local_fire_department : Icons.api_rounded,
                          size: 14.sp,
                          color: isFirebase ? const Color(0xFFFF8F00) : primaryColor,
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: isFirebase ? 'Logged in with Firebase' : 'DummyJSON User',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isFirebase ? const Color(0xFFD87C00) : primaryColor,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // LAB ACT 5 - ENHANCEMENT 3: User details depending on LoginType
                  if (isFirebase) ...[
                    // Firebase Fields
                    _buildInfoCard(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Firebase Email',
                      value: email.isNotEmpty ? email : 'Not available',
                    ),
                    if (data['age'] != null && data['age'].toString().isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      _buildInfoCard(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Age',
                        value: data['age'].toString(),
                      ),
                    ],
                    if (data['contactNo'] != null &&
                        data['contactNo'].toString().isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      _buildInfoCard(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Contact Number',
                        value: data['contactNo'].toString(),
                      ),
                    ],

                    SizedBox(height: 22.h),

                    // LAB ACT 5 - ENHANCEMENT 3: Firebase Account Management Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showUpdateUserDialog(
                              currentFullName: fullName.isNotEmpty ? fullName : displayName,
                              currentUsername: username,
                            ),
                            icon: Icon(Icons.edit_outlined, size: 16.sp),
                            label: const Text('Update User'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showChangePasswordDialog(email),
                            icon: Icon(Icons.key_outlined, size: 16.sp),
                            label: const Text('Password'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // Delete Account Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _showDeleteAccountDialog(email),
                        icon: Icon(Icons.delete_forever_outlined,
                            size: 16.sp, color: Colors.redAccent),
                        label: CustomText(
                          text: 'Delete Account',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ] else ...[
                    // DummyJSON Mock Account Details
                    _buildInfoCard(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'User ID',
                      value: '#${data['id']}',
                    ),
                    SizedBox(height: 10.h),
                    _buildInfoCard(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email.isNotEmpty ? email : 'Not provided',
                    ),
                    SizedBox(height: 10.h),
                    _buildInfoCard(
                      context,
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value: data['gender'] ?? 'Not specified',
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
