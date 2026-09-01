# NUBD Exchange - Mobile Application

**Student Name:** Joseph Brian Natividad  
**Course Code:** INF231  
**Course Name:** CTAMOBL - Advanced Mobile Programming  

---

## 📱 Laboratory Activity 1: Flutter State Management Fundamentals

### 🎯 Goal
Understand the core differences between local (ephemeral) UI state and global (application-wide) state management in Flutter.

### ✨ Key Highlights & Implementation
* **Ephemeral State Management:** Implemented an interactive counter page utilizing `setState` to manage local, widget-level state.
* **Application-Wide State Management:** Built a theme toggle page using `Provider` and `ChangeNotifier` to control global Light and Dark mode.
* **Multi-Screen Navigation:** Seamless transition connecting the counter view to the theme settings page.

---

## 🛍️ Laboratory Activity 2: UI & Marketplace Enhancements

### 🎯 Goal
Enhance the product catalog into an interactive marketplace UI with real-time search, dedicated product detail navigation, and centralized settings.

### ✨ Key Enhancements
* **Enhancement 1 (Search Bar):** Added a real-time search bar above the product list for instant keyword and category filtering.
* **Enhancement 2 (Product Details Page):** Implemented an interactive details screen (`DetailScreen`) when clicking any product card, featuring Hero image animations, product specs, and a wishlist toggle.
* **Enhancement 3 (Settings Page):** Created a dedicated settings screen (`SettingsScreen`) housing the Dark/Light mode switch for clean theme management.

---

## 🛒 Laboratory Activity 3: Cart Integration & Commerce Flow

### 🎯 Goal
Connect product browsing to shopping cart management by rendering cart API endpoints, dynamic navigation controls, and user-specific cart queries.

### ✨ Key Enhancements
* **Enhancement 1 (Cart Screen & Clickable Items):** Created `CartScreen` to render the DummyJSON Cart API endpoint with interactive, clickable cart items navigating to `DetailScreen`.
* **Enhancement 2 (Dynamic Chat FloatingActionButton):** Converted the chat navigation into a `FloatingActionButton` that dynamically hides when viewing the cart screen.
* **Enhancement 3 (User Cart API & Add to Cart):** Integrated cart retrieval by User ID (`GET /carts/user/{userId}`) to render a single user's cart, alongside Add to Cart API functionality (`POST /carts/add`).

---

## 👤 Laboratory Activity 4: Authentication & Personalization

### 🎯 Goal
Implement user authentication and session persistence to provide a secure, personalized e-commerce experience.

### ✨ Key Enhancements
* **Enhancement 1 (Animated Splash Screen):** Created a custom splash screen UI (`SplashScreen`) with smooth micro-animations and persistent authentication checking.
* **Enhancement 2 (Sign-in Screen):** Built a custom sign-in screen UI (`SigninScreen`) integrating form validation, `UserService`, and secure API authentication.
* **Enhancement 3 (User Model, Profile Screen & User Cart):** Created the `User` model (`user.dart`) and profile screen UI (`ProfileScreen`) to display user information and manage log out, while dynamically rendering the shopping cart based on the saved `userId`.
