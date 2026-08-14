## Laboratory Activity 3:

## 📑 Table of Contents

1. [Interaction Architecture: Cart Model, Services & Cart Screen](#1-interaction-architecture-cart-model-services--cart-screen)
2. [Updated Design Patterns in this Activity](#2-updated-design-patterns-in-this-activity)
3. [DummyJSON Carts API: `getById` & `getByUserId` Integration](#3-dummyjson-carts-api-getbyid--getbyuserid-integration)
4. [Project Overview & Setup Guide](#4-project-overview--setup-guide)

---

## 1. Interaction Architecture: Cart Model, Services & Cart Screen

This activity implements a decoupled architecture connecting data models, API repository services, and UI screens in Flutter.

### Component Roles & Communication Flow

1. **Data Models (`lib/models/cart.dart`)**:
   - `Cart`: Holds cart metadata (`id`, `userId`, `total`, `discountedTotal`, `totalProducts`, `totalQuantity`) and a list of `CartProduct` items.
   - `CartProduct`: Deserializes individual cart items from JSON via `CartProduct.fromJson()`, supporting both `discountedPercentage` and `discountPercentage` API keys.
   - **Model Adapter (`toProduct()`)**: Transforms a `CartProduct` into a `Product` model instance. This allows `DetailScreen` to reuse its layout, hero animations, and stock/warranty widgets without modifying its constructor interface.

2. **API Service Layer (`lib/services/cart_service.dart`)**:
   - `CartService` serves as the centralized HTTP networking gateway.
   - `getCartByUserId(int userId)` executes `http.get` to `$host/carts/user/$userId`, validates HTTP 200 responses, and extracts the first cart object (`data['carts'][0]`).
   - `addToCart({required int userId, required int productId, required int quantity})` issues a `POST` request to `$host/carts/add` sending `{"userId": userId, "products": [{"id": productId, "quantity": quantity}]}`.

3. **User Interface (`lib/screens/cart_screen.dart`)**:
   - Asynchronously loads cart data using `FutureBuilder<Cart>`.
   - Utilizes system `ThemeProvider` tokens (`theme.colorScheme.primary`, `theme.cardTheme.color`, `theme.scaffoldBackgroundColor`) to render item tiles, steppers (`+` / `-`), and order checkout summaries.
   - **Clickable Item Navigation**: Each item tile wraps in an `InkWell`. When clicked, it converts `cartProduct.toProduct()` and invokes `Navigator.push(...)` to navigate directly to `DetailScreen`.

---

## 2. Updated Design Patterns in this Activity

### A. Model Adapter / DTO Mapping Pattern

- **Problem**: `CartScreen` operates on `CartProduct` items from `/carts`, while `DetailScreen` expects a `Product` model from `/products`.
- **Solution**: Implemented `toProduct()` inside `CartProduct`. This acts as an **Adapter Pattern**, converting `CartProduct` attributes (`id`, `title`, `price`, `thumbnail`, `discountedPercentage`, `quantity`) into a compatible `Product` DTO for `DetailScreen`.

### B. Repository / Service Separation Pattern

- **Problem**: Inlining `http` networking logic directly inside Flutter widgets causes code duplication, tight coupling, and difficult testing.
- **Solution**: Encapsulated network requests into `CartService`. Widgets only request futures (e.g. `CartService().getCartByUserId(1)`), maintaining clean separation of concerns.

### C. Dynamic Navigation & Conditional FloatingActionButton Pattern

- **Problem**: Moving `Chat` from the `BottomNavigationBar` into a `FloatingActionButton` required hiding the FAB specifically when viewing `CartScreen`.
- **Solution**: In `HomeScreen`, updated bottom tabs to `[Shop, Cart, Profile]`. Controlled FAB rendering dynamically using state condition `floatingActionButton: _selectedIndex == 1 ? null : FloatingActionButton(...)`.

### D. Theme Tokenization Pattern

- **Problem**: Hardcoding static color hexes breaks theme responsiveness when switching between Light Mode and Dark Mode.
- **Solution**: Replaced hardcoded values in `CartScreen` with dynamic tokens from `Theme.of(context)` (`primary`, `cardColor`, `scaffoldBackgroundColor`, `surface`), ensuring instant compatibility with `ThemeProvider`.

---

## 3. DummyJSON Carts API: `getById` & `getByUserId` Integration

According to the official [DummyJSON Carts Documentation](https://dummyjson.com/docs/carts), cart retrieval can be performed by **User ID** or by **Cart ID**:

### 1. Fetching Cart by User ID (`GET /carts/user/{userId}`)

To render only one specific user's cart (e.g. User ID `1`):

- **Endpoint**: `GET https://dummyjson.com/carts/user/1`
- **Response Structure**:

  ```json
  {
    "carts": [
      {
        "id": 1,
        "products": [
          {
            "id": 162,
            "title": "Blue Frock",
            "price": 29.99,
            "quantity": 4,
            "total": 119.96,
            "discountPercentage": 12.13,
            "discountedTotal": 105.41,
            "thumbnail": "https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp"
          }
        ],
        "total": 13037.88,
        "discountedTotal": 11510.81,
        "userId": 1,
        "totalProducts": 4,
        "totalQuantity": 12
      }
    ],
    "total": 1,
    "skip": 0,
    "limit": 1
  }
  ```

- **Dart Implementation in `CartService`**:

  ```dart
  // ENHANCEMENT 3: Render single user cart by user ID (GET /carts/user/{userId})
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
      throw Exception('Failed to load cart for user $userId');
    }
  }
  ```

---

### 2. Fetching Single Cart by Cart ID (`GET /carts/{cartId}`)

To query a single cart directly by its Cart ID (e.g., Cart ID `1`):

- **Endpoint**: `GET https://dummyjson.com/carts/1`
- **Response Structure**:

  ```json
  {
    "id": 1,
    "products": [ ... ],
    "total": 13037.88,
    "discountedTotal": 11510.81,
    "userId": 1,
    "totalProducts": 4,
    "totalQuantity": 12
  }
  ```

- **Dart Implementation**:
  ```dart
  Future<Cart> getCartById(int cartId) async {
    final response = await http.get(Uri.parse('$host/carts/$cartId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to load cart #$cartId');
    }
  }
  ```

---

### 3. Adding Products to Cart (`POST /carts/add`)

To push new product entries to a cart:

- **Endpoint**: `POST https://dummyjson.com/carts/add`
- **Request Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "userId": 1,
    "products": [
      {
        "id": 1,
        "quantity": 1
      }
    ]
  }
  ```
- **Dart Implementation**:
  ```dart
  // ENHANCEMENT 3: Add to cart by passing product values to POST /carts/add
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
          {'id': productId, 'quantity': quantity}
        ],
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to add product to cart');
    }
  }
  ```
