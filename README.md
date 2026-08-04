# E-Commerce - Mobile Application

**Student Name:** Joseph Brian Natividad  
**Course Code:** INF231  
**Course Name:** CTAMOBL - Advanced Mobile Programming  

---

## 📱 Project Overview

**NUBD Exchange** is a modern Flutter mobile application designed for product discovery, marketplace exchange, and seamless user interaction. Built with **Material 3**, **Provider** for state management, and **Flutter ScreenUtil** for responsive layouts, the app delivers a fluid, premium user experience in both Light and Dark themes.

---

## 🚀 Lab Activity 2 Features (`lab-act2` Branch)

### 1. 🛍️ Modern 2-Column Product Grid & Cards (`ProductScreen`)
* **Responsive Grid Layout**: Transformed flat list views into an engaging 2-column grid (`GridView.builder`).
* **Visual Card Design**: Cards feature rounded corners (`16.r`), subtle drop shadows, and brand category tags.
* **Rating & Discount Badges**:
  * **★ Rating Badge**: Translucent dark overlay with gold star indicator.
  * **Discount Tag (`-10%`)**: Red badge highlighting promotional discounts.

### 2. 🔍 Real-Time Search Bar & Category Filter Chips
* **Integrated Sticky Search Bar**: Live debounced search by product title, brand, or description with a clear (`X`) button.
* **Dynamic Category Chips**: Horizontally scrollable `ChoiceChip` bar allowing one-tap category filtering (*All*, *Beauty*, *Fragrances*, *Furniture*, etc.).
* **Empty Search Feedback**: Designed clean fallback states when queries return zero matches.

### 3. ✨ Interactive Product Detail View (`DetailScreen`)
* **Hero Motion Animations**: Fluid image expansion transitions when navigating from product cards to detail view (`Hero` widget).
* **Collapsible Floating Header**: Featuring semi-transparent back button and interactive **Wishlist Heart Toggle (`❤️ Saved to Wishlist!`)**.
* **Stock & Price Highlights**: Highlights stock status (`In Stock` / `Out of Stock`), original price strikethrough, and net savings.
* **Selling Feature Tiles**: Visual icons for 🚚 Shipping, 🛡️ Warranty, and 🔄 Return Policies.
* **Encouraging Bottom Action Bar**: Interactive quantity selector (`- 1 +`) and primary **"Add to Cart"** button with feedback toasts.
* **Theme-Adaptive Contrast**: Fully optimized Like & Share buttons visible across both Light and Dark mode.

### 4. ⚙️ Streamlined Settings Screen (`SettingsScreen`)
* **Horizontal Theme Toggle**: Clean `SwitchListTile` card in the screen body with Sun/Moon icons for seamless theme switching between Light and Dark mode.

---

## 🛠️ Tech Stack & Packages

* **Framework:** Flutter (Dart SDK ^3.12)
* **State Management:** `provider` (^6.1.5) for `ThemeProvider`
* **Screen Responsiveness:** `flutter_screenutil` (^5.9.3)
* **Environment Config:** `flutter_dotenv` (^6.0.1)
* **API Integration:** RESTful product fetching via `http` (^1.6.0)

---

## 📁 Directory Structure

```text
natividad_mobile/
├── assets/
│   ├── fonts/           # Custom Poppins Typography
│   └── images/          # NUBD Exchange Branding Assets
├── lib/
│   ├── models/          # Product, Dimensions, Review & Meta Data Models
│   ├── provider/        # ThemeProvider (Light & Dark Hex Palettes)
│   ├── screens/         # HomeScreen, ProductScreen, DetailScreen, SettingsScreen
│   ├── services/        # ProductService API Fetching
│   ├── widgets/         # CustomText Typography Components
│   ├── constant.dart    # Theme Constants
│   └── main.dart        # Main Application Entry Point
└── pubspec.yaml         # Dependencies & Asset Registrations
```

---

## 🏃 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/njeybe/natividad-advmobprogAY2627.git
   cd natividad-advmobprogAY2627/natividad_mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
