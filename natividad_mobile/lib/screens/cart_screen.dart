import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

// ENHANCEMENT 1: Created CartScreen to render cart API data with clickable items navigating to DetailScreen
// ENHANCEMENT 3: Integrated user-specific cart fetching (GET /carts/user/{userId}) to render a single user cart
class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, this.userId = 1});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart> _cartFuture;
  late Map<int, int> _itemQuantities;

  @override
  void initState() {
    super.initState();
    _itemQuantities = {};
    _loadUserCart();
  }

  // ENHANCEMENT 3: Fetch single user cart by user ID
  void _loadUserCart() {
    setState(() {
      _cartFuture = CartService().getCartByUserId(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUserCart();
        },
        child: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: 'Failed to load cart',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: '${snapshot.error}',
                        fontSize: 12.sp,
                        color: theme.hintColor,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: _loadUserCart,
                        icon: const Icon(Icons.refresh),
                        label: const CustomText(text: 'Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64.sp,
                      color: theme.disabledColor,
                    ),
                    SizedBox(height: 16.h),
                    CustomText(
                      text: 'Your cart is empty',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                    ),
                  ],
                ),
              );
            }

            final cart = snapshot.data!;

            return Column(
              children: [
                SizedBox(height: 12.h),
                // ENHANCEMENT 1: List of clickable cart items using the system Theme palette
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: cart.products.length,
                    itemBuilder: (context, index) {
                      final cartProduct = cart.products[index];
                      return _buildCartItemTile(context, cartProduct, theme);
                    },
                  ),
                ),

                // Bottom Subtotal, Delivery Fee & Confirm Order Button adhering to Theme system
                _buildCheckoutBar(context, cart, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  // ENHANCEMENT 1: Clickable Cart Item tile strictly using system Theme tokens
  Widget _buildCartItemTile(
    BuildContext context,
    CartProduct cartProduct,
    ThemeData theme,
  ) {
    final qty = _itemQuantities[cartProduct.id] ?? cartProduct.quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          // ENHANCEMENT 1: Clicking the item navigates to DetailScreen utilizing the converted Product widget
          onTap: () {
            final convertedProduct = cartProduct.toProduct();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  userName: cartProduct.title,
                  postContent:
                      'Cart item price: \$${cartProduct.price.toStringAsFixed(2)} | Quantity in Cart: $qty | Total: \$${cartProduct.total.toStringAsFixed(2)}',
                  imageUrl: cartProduct.thumbnail,
                  date: 'Cart Item #${cartProduct.id}',
                  product: convertedProduct,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Item Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: Image.network(
                      cartProduct.thumbnail,
                      width: 75.w,
                      height: 75.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 75.w,
                        height: 75.h,
                        color: theme.colorScheme.surface,
                        child: Icon(Icons.image_not_supported, size: 28.sp, color: theme.hintColor),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Title, Price & Discount Info adhering to system Theme palette
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: cartProduct.title,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        text: '\$${cartProduct.price.toStringAsFixed(2)}',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text:
                            '${cartProduct.discountedPercentage.round()}% off • \$${(cartProduct.price * qty).toStringAsFixed(2)} total',
                        fontSize: 11.sp,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? theme.hintColor,
                      ),
                    ],
                  ),
                ),

                // Stepper Column: Plus (+), Quantity Number, Minus (-) using theme colors
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _itemQuantities[cartProduct.id] = qty + 1;
                        });
                      },
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.add, size: 16.sp, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: CustomText(
                        text: '$qty',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (qty > 1) {
                          setState(() {
                            _itemQuantities[cartProduct.id] = qty - 1;
                          });
                        }
                      },
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Checkout Bottom Bar adhering strictly to system Theme palette
  Widget _buildCheckoutBar(
    BuildContext context,
    Cart cart,
    ThemeData theme,
  ) {
    double calculatedTotal = 0;
    for (var product in cart.products) {
      int qty = _itemQuantities[product.id] ?? product.quantity;
      calculatedTotal += product.price * qty;
    }
    double finalSubtotal = calculatedTotal > 0 ? calculatedTotal : cart.discountedTotal;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Subtotal:',
                  fontSize: 14.sp,
                  color: theme.hintColor,
                ),
                CustomText(
                  text: '\$${finalSubtotal.toStringAsFixed(2)}',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Delivery Fee Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Delivery Fee:',
                  fontSize: 14.sp,
                  color: theme.hintColor,
                ),
                CustomText(
                  text: '\$0.00',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Confirm Order Full-Width Primary Theme Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 Order Confirmed! Total: \$${finalSubtotal.toStringAsFixed(2)}',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green.shade700,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: CustomText(
                  text: 'Confirm Order',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
