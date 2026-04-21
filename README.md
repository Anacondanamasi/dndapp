# 💎 Jewello — Online Jewellery Shopping App

Jewello is a **Flutter-based online jewellery shopping app** designed to deliver a **modern, luxurious, and mobile-first e-commerce experience**.  
It allows users to browse premium jewellery, add items to their wishlist or cart, place orders, and manage their profiles — all from their mobile devices.  
Admins can manage products, customers, and orders through a **mobile-friendly admin panel**.

---

## 🌟 Features

### 👩‍💻 User Features
- 🏠 **Home Screen** – Explore featured and trending jewellery
- 🔍 **Search & Filter** – Find items by name, category, or price
- 💖 **Wishlist** – Save favourite items
- 🛒 **Cart & Checkout** – Add to cart and place secure orders
- ⭐ **Product Reviews** – Rate and review jewellery
- 👤 **Profile Management** – View and update user info
- 📦 **Order History** – Track past purchases

### 🧑‍💼 Admin Features
- 📊 **Dashboard** – Overview of products, users, and orders
- 🛍️ **Product Management** – Add, update, and delete jewellery items
- 📦 **Order Management** – Track and update order statuses
- 👥 **Customer Management** – View customer list and feedback

---

## 🧭 App Flow

1. **Splash Screen** → Branding and loading animation  
2. **Onboarding Screens** → Quick app intro  
3. **Login / Register** → Firebase Authentication  
4. **Home Page** → Browse & shop  
5. **Product Details** → View details, add to wishlist/cart  
6. **Cart / Wishlist / Orders** → Manage and buy items  
7. **Profile / Settings** → Manage user details  
8. **Admin Panel** → Manage products and orders  

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase (Firestore, Auth, Storage) |
| **State Management** | GetX / Provider |
| **UI Components** | Material Design, Persistent Bottom Nav Bar |
| **Database** | Firebase Cloud Firestore |
| **Authentication** | Firebase Authentication |
| **Storage** | Firebase Storage (for images) |

---

## 🚀 Getting Started

### 🧩 Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase Project (Firestore + Authentication + Storage configured)

### 🧱 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/krishpansara/jewello.git
   cd jewello

2. Install dependencies:
   ```bash
   flutter pub get

3. Run the app:
   ```
   flutter run

---

## App Update Setup

For production APK update flow (GitHub Releases + Supabase), see:

- `APP_UPDATE_PROCESS.md`
- `supabase/app_update_setup.sql`
- `supabase/app_update_release_commands.sql`
