import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_text.dart';

/// HomeScreen hosting the primary navigation: Shop, Cart (by userId), and Profile.
class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final UserService _userService = UserService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ENHANCEMENT 3: Fetch authenticated user data to bind cart and profile
  Future<void> _fetchUserData() async {
    try {
      final user = await _userService.getUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (_) {
      // Fallback if data is not yet parsed
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: (_selectedIndex == 0)
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                  errorBuilder: (context, error, stackTrace) => CustomText(
                    text: 'NUBD Exchange',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                          ? (_currentUser != null && _currentUser!.firstName.isNotEmpty
                              ? _currentUser!.firstName
                              : 'Profile')
                          : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.appBarTheme.foregroundColor ?? Colors.white,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined, size: 24.sp),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ],
        ),

        // ENHANCEMENT 3: Dynamic binding of CartScreen by User ID & ProfileScreen tab
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: <Widget>[
            const ProductScreen(),
            CartScreen(userId: _currentUser?.id ?? 1),
            const ProfileScreen(),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
        ),

        // ENHANCEMENT 2: Make the chat bottom navigation as FloatingActionButton. When in the cart_screen the FloatingActionButton must be hidden.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.support_agent_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Opening Customer Support Chat...'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
              ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}
