# Daraz Clone (darazcl)

A Flutter e-commerce app inspired by Daraz, built with clean architecture and a feature-first folder structure.

---

## Pages

The app has a bottom navigation bar with four main tabs, plus one detail screen:

| Page | Route | Description |
|------|-------|-------------|
| **Home** | `/` | Landing feed with promo banners, category shortcuts, and a product grid |
| **Shop** | `/shop` | Full product listing with tabbed category filters and quick-links |
| **Categories** | `/categories` | Split-view category browser with a product grid per category |
| **Cart** | `/cart` | Shopping cart screen |
| **Product Details** | `/product/:id` | Individual product detail screen (pushed on top of any tab) |

---

## Widget Structure & Scroll Behavior

### Home (`/`)

The entire screen is a single `CustomScrollView` (sliver-based) wrapped in a `RefreshIndicator`.

```
Scaffold
└── Stack
    ├── RefreshIndicator
    │   └── CustomScrollView (controller: _scrollController)
    │       ├── SliverToBoxAdapter → _PromoBannerCarousel
    │       │     PageView with 3 auto-advancing banners (2 s interval)
    │       │     Each banner: full-bleed network image + gradient overlay + text
    │       ├── SliverToBoxAdapter → _CategoriesRow
    │       │     Row of 4 category icon-chips (tapping navigates to /categories)
    │       ├── SliverToBoxAdapter → "Just For You" header row
    │       └── SliverGrid (2-column) → ProductCard list
    │
    └── Positioned overlay → _HomeSearchBar (AnimatedContainer)
          Transparent while inside the banner; turns white and sticks to top
          once the user scrolls past the banner height (~260 dp + status bar).
```

**Scroll behavior:** A `ScrollController` listener compares the scroll offset against the banner height. When the offset passes `bannerHeight - 80`, the search bar overlay animates from transparent to a white background, making it sticky.

---

### Categories (`/categories`)

A fixed `Column` layout — no full-page scroll. Instead, each side scrolls independently.

```
Scaffold
└── SafeArea
    └── Column
        ├── _TopSearchBar  (pinned, never scrolls)
        └── Row
            ├── _LeftSidebar  (width: 90)
            │     ListView — scrollable list of all categories
            │     Tapping a category updates the selected state in CategoriesProvider
            └── _RightContent  (Expanded)
                  RefreshIndicator
                  └── CustomScrollView
                      ├── SliverToBoxAdapter → _PromoBanner (21:9 aspect-ratio banner)
                      ├── SliverToBoxAdapter → category title + item count header
                      └── SliverGrid (2-column) → ProductCard list for selected category
```

**Scroll behavior:** The left sidebar and right content panel each scroll independently. The top search bar never moves. Selecting a new category in the sidebar replaces the right panel's product grid.

---

### Shop (`/shop`)

A single `CustomScrollView` with a **pinned tab bar** that sticks to the top on scroll.

```
Scaffold
└── SafeArea
    └── RefreshIndicator
        └── CustomScrollView (controller: _scrollController)
            ├── SliverToBoxAdapter → _Header (logo, notifications, search bar)
            ├── SliverPersistentHeader (pinned: true) → TabBar
            │     Horizontally scrollable tabs (All, Electronics, Jewelery, etc.)
            │     Sticks to the top of the screen as the header scrolls away
            ├── SliverToBoxAdapter → _PromoBanner (140 dp tall, full-width)
            ├── SliverToBoxAdapter → _QuickLinksRow
            │     Row of 4 icon-chips: Flash Sale, Global, Vouchers, Premium
            ├── SliverToBoxAdapter → "Just For You" header row
            └── SliverGrid (2-column) → ProductCard list filtered by selected tab
```

**Scroll behavior:** The `_Header` scrolls away with the content. The `TabBar` is wrapped in a `SliverPersistentHeader` with `pinned: true`, so it locks to the top once the header is out of view. Switching tabs filters the product grid via `ProductProvider`.

---

## How to Run

### Prerequisites

- **Flutter 3.32.4** (stable channel)
- **Dart 3.8.1**

Verify your setup:

```bash
flutter --version
# Flutter 3.32.4 • channel stable
# Dart 3.8.1
```

### Steps

```bash
# 1. Clone the repo
git clone <repo-url>
cd darazcl

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

To run on a specific platform:

```bash
flutter run -d android   # Android emulator / device
flutter run -d ios       # iOS simulator / device
flutter run -d chrome    # Web
```

---

## Major Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| [`dio`](https://pub.dev/packages/dio) | `^5.7.0` | HTTP client for all API calls |
| [`go_router`](https://pub.dev/packages/go_router) | `^17.0.0` | Declarative routing and deep-link navigation |
| [`provider`](https://pub.dev/packages/provider) | `^6.1.2` | State management (ChangeNotifier-based) |
| `cupertino_icons` | `^1.0.8` | iOS-style icons |

Data is fetched from the [DummyJSON](https://dummyjson.com) public API using `dio` through a shared `ApiClient` in `lib/core/network/`.
