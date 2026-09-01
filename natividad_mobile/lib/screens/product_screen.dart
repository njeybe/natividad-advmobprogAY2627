import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final allProducts = snapshot.data!;

        // Extract unique categories for filter chips
        final rawCategories = allProducts
            .map((p) => p.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
        final categories = ['All', ...rawCategories];

        // Filter products based on search query & selected category
        final filteredProducts = allProducts.where((product) {
          final matchesCategory =
              _selectedCategory == 'All' ||
              product.category.toLowerCase() == _selectedCategory.toLowerCase();
          final matchesSearch =
              _searchQuery.isEmpty ||
              product.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return Column(
          children: [
            // ENHANCEMENT 2: Real-Time Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products, brands...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: theme.hintColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: theme.hintColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18.sp),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ),

            // ENHANCEMENT 2: Horizontal Category Filter Chips
            if (categories.length > 1)
              SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected =
                        _selectedCategory.toLowerCase() ==
                        category.toLowerCase();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ChoiceChip(
                        label: Text(
                          category[0].toUpperCase() + category.substring(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surface,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 8.h),

            // ENHANCEMENT 1: 2-Column Product Grid or Empty Search State
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48.sp,
                            color: theme.disabledColor,
                          ),
                          SizedBox(height: 12.h),
                          CustomText(
                            text: 'No products match your search',
                            fontSize: 14.sp,
                            color: theme.disabledColor,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.66,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(context, product, theme);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              userName: product.title,
              postContent: product.description,
              imageUrl: product.thumbnail,
              date: 'Product #${product.id}',
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENHANCEMENT 1: Product Image with Rating & Discount Badges
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: Container(
                        width: double.infinity,
                        color: theme.colorScheme.surface,
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 2.w),
                          CustomText(
                            text: product.rating.toStringAsFixed(1),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Discount Badge
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: CustomText(
                          text: '-${product.discountPercentage.round()}%',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Details (Brand/Category, Title, Price & Cart Icon)
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand.isNotEmpty)
                    CustomText(
                      text: product.brand.toUpperCase(),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (product.category.isNotEmpty)
                    CustomText(
                      text: product.category.toUpperCase(),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.hintColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 2.h),
                  CustomText(
                    text: product.title,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(2)}',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      Icon(
                        Icons.add_shopping_cart,
                        size: 16.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
