// ENHANCEMENT 3: Cart model and CartProduct model supporting API JSON structure and cart by user ID
import 'product_model.dart';

class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      products:
          (json['products'] as List?)
              ?.map((e) => CartProduct.fromJson((e)))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountedPercentage;
  final double discountedTotal;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountedPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  // ENHANCEMENT 3: Parse both discountedPercentage & discountPercentage from DummyJSON API
  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedPercentage:
          (json['discountedPercentage'] as num?)?.toDouble() ??
          (json['discountPercentage'] as num?)?.toDouble() ??
          0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'discountedPercentage': discountedPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }

  // ENHANCEMENT 1: Convert CartProduct to Product model to reuse DetailScreen widget
  Product toProduct() {
    return Product(
      id: id,
      title: title,
      description: 'Item from cart: $title. Unit Price: \$${price.toStringAsFixed(2)} | Quantity: $quantity',
      category: 'Cart Item',
      price: price,
      discountPercentage: discountedPercentage,
      rating: 4.5,
      stock: quantity,
      tags: ['Cart', 'Selected'],
      brand: 'E-Store Item',
      sku: 'CART-$id',
      weight: 1.0,
      dimensions: ProductDimensions(width: 10, height: 10, depth: 10),
      warrantyInformation: 'Standard Warranty Applicable',
      shippingInformation: 'Express Delivery Available',
      availabilityStatus: quantity > 0 ? 'In Stock' : 'Out of Stock',
      reviews: [],
      returnPolicy: '30 Days Return Policy',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        barcode: 'CART-$id',
        qrCode: '',
      ),
      images: [if (thumbnail.isNotEmpty) thumbnail],
      thumbnail: thumbnail,
    );
  }
}

