import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

/// ENHANCEMENT 2: Modern Minimalist Sign-in Screen
/// Implements user_service authentication, form validation, theme-aware styling,
/// and icon-based e-commerce layout without emojis.
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(
    text: 'emilys',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'emilyspass',
  );
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ENHANCEMENT 2: User authentication logic integrating UserService
  void _login() async {
    final UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final response = await userService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        // Save user data to SharedPreferences
        await userService.saveUserData(response);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Login failed: ${e.toString().replaceAll("Exception: ", "")}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ENHANCEMENT 2: Minimalist E-Commerce Header Badge
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 40.sp,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Center(
                    child: CustomText(
                      text: 'Welcome Back',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  Center(
                    child: CustomText(
                      text: 'Sign in to continue to NUBD Exchange',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Username input
                  CustomText(
                    text: 'Username',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: primaryColor,
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter your username'
                        : null,
                  ),

                  SizedBox(height: 18.h),

                  // Password input
                  CustomText(
                    text: 'Password',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: primaryColor,
                        size: 20.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter your password'
                        : null,
                  ),

                  SizedBox(height: 28.h),

                  // Sign In button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.login_rounded,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              CustomText(
                                text: 'Sign In',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
