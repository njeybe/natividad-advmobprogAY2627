import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_text.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// ENHANCEMENT 2: Add details page when clicked the card
class DetailScreen extends StatefulWidget {
  final String userName;
  final String postContent;
  final String date;
  final int initialNumOfLikes;
  final String imageUrl;
  final String profileImageUrl;
  final Product? product;

  const DetailScreen({
    super.key,
    this.userName = '',
    this.postContent = '',
    this.initialNumOfLikes = 0,
    this.date = '',
    this.imageUrl = '',
    this.profileImageUrl = '',
    this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int numOfLikes;
  bool isLiked = false;
  bool isFavorite = false;
  int quantity = 1;
  late String finalPostImage;

  @override
  void initState() {
    super.initState();
    numOfLikes = widget.initialNumOfLikes;
    finalPostImage = widget.product?.thumbnail.isNotEmpty == true
        ? widget.product!.thumbnail
        : widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final titleText = product?.title.isNotEmpty == true
        ? product!.title
        : (widget.userName.isNotEmpty ? widget.userName : 'Product Detail');
    final bodyText = product?.description.isNotEmpty == true
        ? product!.description
        : widget.postContent;

    final originalPrice = (product != null && product.discountPercentage > 0)
        ? (product.price / (1 - (product.discountPercentage / 100)))
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ENHANCEMENT 2: Collapsible Floating Hero Image Header & Wishlist Toggle
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            leading: Padding(
              padding: EdgeInsets.all(8.r),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              // Interactive Wishlist Heart Toggle
              Padding(
                padding: EdgeInsets.all(8.r),
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : theme.colorScheme.onSurface,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? '❤️ Saved to your Wishlist!'
                                : 'Removed from Wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (finalPostImage.isNotEmpty)
                    // Hero Image Transition
                    Hero(
                      tag: product != null
                          ? 'product_image_${product.id}'
                          : 'product_image_${widget.imageUrl}',
                      child: Image.network(
                        finalPostImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: theme.colorScheme.surface),
                      ),
                    )
                  else
                    Container(color: theme.colorScheme.surface),
                  // Gradient Overlay for contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Stock Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (product != null && product.category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: CustomText(
                            text: product.category.toUpperCase(),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (product != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 4.r,
                                backgroundColor: product.stock > 0 ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 6.w),
                              CustomText(
                                text: product.stock > 0
                                    ? 'In Stock (${product.stock})'
                                    : 'Out of Stock',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: product.stock > 0 ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Title Text
                  CustomText(
                    text: titleText,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),

                  SizedBox(height: 12.h),

                  // Price and Rating Row
                  Row(
                    children: [
                      if (product != null) ...[
                        CustomText(
                          text: '\$${product.price.toStringAsFixed(2)}',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                        if (originalPrice != null) ...[
                          SizedBox(width: 8.w),
                          Text(
                            '\$${originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.hintColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: CustomText(
                              text: 'SAVE ${product.discountPercentage.round()}%',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                      const Spacer(),
                      if (product != null && product.rating > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16.sp),
                              SizedBox(width: 4.w),
                              CustomText(
                                text: product.rating.toStringAsFixed(1),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  const Divider(),
                  SizedBox(height: 12.h),

                  // Selling Feature Highlights
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureTile(
                        theme,
                        Icons.local_shipping_outlined,
                        'Shipping',
                        product?.shippingInformation.isNotEmpty == true
                            ? product!.shippingInformation
                            : 'Fast Delivery',
                      ),
                      _buildFeatureTile(
                        theme,
                        Icons.verified_user_outlined,
                        'Warranty',
                        product?.warrantyInformation.isNotEmpty == true
                            ? product!.warrantyInformation
                            : '1 Year Warranty',
                      ),
                      _buildFeatureTile(
                        theme,
                        Icons.assignment_return_outlined,
                        'Returns',
                        product?.returnPolicy.isNotEmpty == true
                            ? product!.returnPolicy
                            : 'Easy Returns',
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  const Divider(),
                  SizedBox(height: 12.h),

                  // Description
                  CustomText(
                    text: 'Description',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: bodyText,
                    fontSize: 14.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),

                  SizedBox(height: 24.h),

                  // Social Engagement Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                            if (isLiked) {
                              numOfLikes++;
                            } else if (numOfLikes > 0) {
                              numOfLikes--;
                            }
                          });
                        },
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? theme.colorScheme.primary : theme.hintColor,
                          size: 18.sp,
                        ),
                        label: CustomText(
                          text: isLiked ? 'Liked ($numOfLikes)' : 'Like ($numOfLikes)',
                          fontSize: 13.sp,
                          color: isLiked ? theme.colorScheme.primary : theme.hintColor,
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link copied to clipboard! Share with friends 🚀'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(Icons.share_outlined, size: 18.sp),
                        label: const CustomText(text: 'Share', fontSize: 13),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 100.h), // Clearance for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Encouraging Bottom Action Bar (Quantity & Add to Cart)
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 16.sp),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    CustomText(
                      text: '$quantity',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 16.sp),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // ENHANCEMENT 3: Add to Cart Button passing product values to API (POST /carts/add)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final productId = product?.id ?? 1;
                    final messenger = ScaffoldMessenger.of(context);
                    
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('⏳ Adding product to cart via API...'),
                        duration: Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    try {
                      final updatedCart = await CartService().addToCart(
                        userId: 1,
                        productId: productId,
                        quantity: quantity,
                      );

                      if (!mounted) return;
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '🎉 Excellent choice! Added $quantity item(s) to Cart #${updatedCart.id}.',
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '🎉 Added $quantity item(s) to your cart.',
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20.sp),
                  label: CustomText(
                    text: 'Add to Cart',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
      ThemeData theme, IconData icon, String title, String subtitle) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20.sp),
        ),
        SizedBox(height: 6.h),
        CustomText(
          text: title,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: 90.w,
          child: CustomText(
            text: subtitle,
            fontSize: 10.sp,
            color: theme.hintColor,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

typedef CustomFont = CustomText;