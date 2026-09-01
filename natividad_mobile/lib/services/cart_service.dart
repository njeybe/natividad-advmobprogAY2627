import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constant.dart';
import '../models/cart.dart';

// ENHANCEMENT 3: Read the Cart documentation https://dummyjson.com/docs/carts and check how to integrate cart by user id. To render only one user cart. Also try to use add to cart by passing the values of the product => cart https://dummyjson.com/carts/add
class CartService {
  /// ENHANCEMENT 3: Render only one user cart by user ID endpoint GET /carts/user/{userId}
  Future<Cart> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsList = data['carts'] ?? [];
      if (cartsList.isNotEmpty) {
        return Cart.fromJson(cartsList.first as Map<String, dynamic>);
      }
      throw Exception('No cart found for user $userId');
    } else {
      throw Exception('Failed to load cart for user $userId (Status Code: ${response.statusCode})');
    }
  }

  /// ENHANCEMENT 3: Add to cart by passing product values to POST /carts/add
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {
            'id': productId,
            'quantity': quantity,
          }
        ],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to add product to cart (Status Code: ${response.statusCode})');
    }
  }

  /// Fetch all carts endpoint GET /carts
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }
}
