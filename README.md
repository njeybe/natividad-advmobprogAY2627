# Lab Activity 4: Discussion & Implementation Guide

## 📑 Table of Contents
1. [Overview](#1-overview)
2. [How User Model, Services, and Screens Interact](#2-how-user-model-services-and-screens-interact)
3. [Updated Design Patterns in this Activity](#3-updated-design-patterns-in-this-activity)
4. [Using Saved User Data to Render Cart by User ID](#4-using-saved-user-data-to-render-cart-by-user-id)
5. [Summary of Implemented Enhancements](#5-summary-of-implemented-enhancements)

---

## 1. Overview

In **Lab Activity 4 (API Part III)**, we expanded the mobile e-commerce application by adding user authentication, session persistence using `SharedPreferences`, a dedicated user profile screen, and dynamic cart loading tailored to the logged-in user.

The design follows a **Modern Minimalist Mobile UI** with full **ThemeProvider** light/dark theme integration and icon-based components (without emojis).

---

## 2. How User Model, Services, and Screens Interact

The app uses a three-tier architecture that separates **Data Representation (Model)**, **Business Logic & Networking (Service)**, and **User Interface (Screen)**:

```
[ User Input (Sign-in) ]
         │
         ▼
[ UserService.loginUser() ] ──► [ POST /auth/login (DummyJSON API) ]
         │
         ▼
[ SharedPreferences Storage ] (Stores id, name, token, email, etc.)
         │
         ├──────────────────────────────┬──────────────────────────────┐
         ▼                              ▼                              ▼
  [ SplashScreen ]               [ ProfileScreen ]              [ HomeScreen / Cart ]
Checks if token exists;        Converts stored data into      Reads user.id and renders
redirects to Home or Sign-in.  User model & displays info.    personalized cart items.
```

### 1. The User Model (`lib/models/user.dart`)
* Defines a clear blueprint for user data with fields like `id`, `username`, `email`, `firstName`, `lastName`, `gender`, `image`, `accessToken`, and `refreshToken`.
* `User.fromJson()` takes raw dictionary/JSON data and converts it into a safe, strongly-typed Dart object.
* `toJson()` allows converting the user object back into a map when needed.

### 2. The User Service Layer (`lib/services/user_service.dart`)
* Acts as the bridge between the remote API, local disk storage (`SharedPreferences`), and the UI.
* **`loginUser(username, password)`**: Sends a POST request to `https://dummyjson.com/auth/login`. When successful, it automatically calls `saveUserData()` to cache credentials and profile data.
* **`saveUserData(userData)`**: Stores each user attribute (`id`, `username`, `email`, `firstName`, `lastName`, `gender`, `image`, tokens) into local `SharedPreferences`.
* **`getUserData()` & `getUser()`**: Reads the cached data from storage and reconstructs the `User` model for UI consumption.
* **`isLoggedIn()`**: Checks if a valid auth token is saved locally to maintain persistent login sessions.
* **`logout()`**: Clears stored preferences so the user can safely sign out.

### 3. Screen Interaction
* **`SplashScreen`**: When the app starts, it asks `UserService.isLoggedIn()`. If logged in, it automatically navigates to `/home`; otherwise, it redirects to `/signin`.
* **`SigninScreen`**: Collects the username and password, validates user input, calls `UserService.loginUser()`, and upon success navigates to `/home`.
* **`ProfileScreen`**: Fetches the user profile using `UserService.getUser()` and displays the avatar, full name, username badge, and detailed information cards (Email, Gender, User ID) along with a working Log Out button.

---

## 3. Updated Design Patterns in this Activity

### A. Repository & Service Gateway Pattern
* **What it does**: Instead of putting HTTP requests and `SharedPreferences` operations directly inside widget files, all authentication and session logic is organized inside `UserService`.
* **Benefit**: The UI code stays clean and focused purely on layout, while data management remains reusable and easy to maintain.

### B. Persistent Authentication / Session State Pattern
* **What it does**: By storing user tokens and attributes in `SharedPreferences`, the app remembers the user's login state even if the app is closed or restarted.
* **Benefit**: Users don't need to sign in every time they open the application, providing a seamless user experience.

### C. Theme Tokenization Pattern (`ThemeProvider`)
* **What it does**: All screens (`SplashScreen`, `SigninScreen`, `ProfileScreen`, `CartScreen`, `HomeScreen`) read colors directly from `Theme.of(context)` and `ThemeProvider`.
* **Benefit**: Toggling between Light Mode and Dark Mode instantly updates the entire UI cleanly without any hardcoded color glitches.

### D. Model Adapter / DTO Pattern
* **What it does**: The `User` model translates raw map keys from the DummyJSON authentication endpoint into typed properties.
* **Benefit**: Prevents runtime null pointer errors and makes autocomplete and data manipulation safe across all screens.

---

## 4. Using Saved User Data to Render Cart by User ID

In previous activities, the cart was hardcoded to a static ID. In this activity, the cart dynamically matches the authenticated user:

1. **User Signs In**: When a user logs in (for example, `emilys`), DummyJSON returns their unique `id` (e.g., `id: 1`).
2. **Local Storage**: `UserService.saveUserData()` saves this `id` into `SharedPreferences`.
3. **HomeScreen Session Load**: When `HomeScreen` opens, it reads the saved user profile (`_userService.getUser()`) and retrieves the user's `id`.
4. **Dynamic Cart Binding**: `HomeScreen` passes the active user ID directly into `CartScreen(userId: _currentUser?.id ?? 1)`.
5. **API Retrieval**: `CartScreen` calls `CartService.getCartByUserId(userId)`, querying `GET https://dummyjson.com/carts/user/{userId}` to fetch and render only that user's specific cart items, prices, quantities, and totals.

---

## 5. Summary of Implemented Enhancements

* **Enhancement 1 (Splash Screen)**: Designed a Modern Minimalist E-Commerce splash screen with smooth micro-animations (`AnimationController`), branding logo, feature chips, and persistent auth check.
* **Enhancement 2 (Sign-in Screen)**: Created a clean sign-in screen matching the `ThemeProvider` palette, utilizing vector icons (no emojis), form validation, and `UserService` authentication.
* **Enhancement 3 (Profile Screen & User Cart)**: Created `User` model and `ProfileScreen` with user details cards and logout functionality; dynamically rendered `CartScreen` based on the saved user's ID.
