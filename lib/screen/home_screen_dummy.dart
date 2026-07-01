import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/cart_provider.dart';
import 'package:shopping/product_provider.dart';
import 'package:shopping/language_provider.dart';
import 'package:shopping/widget/product_card.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreenDummy extends StatefulWidget {
  const HomeScreenDummy({Key? key}) : super(key: key);

  @override
  State<HomeScreenDummy> createState() => _HomeScreenDummyState();
}

class _HomeScreenDummyState extends State<HomeScreenDummy> {
  int _currentIndex = 0;
  bool _isArabic = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  String _searchQuery = "";

  void _toggleLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (languageProvider.isArabic) {
      languageProvider.changeLanguage('en');
    } else {
      languageProvider.changeLanguage('ar');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    _isArabic = languageProvider.isArabic;

    final List<Widget> _screens = [
      _buildMainHomeContent(),
      ProfileScreen(
        isArabic: _isArabic,
        onLanguageChanged: _toggleLanguage,
      ),
      CartScreen(isArabic: _isArabic),
    ];

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            _isArabic ? "سوقنا المحلي" : "Our Local Market",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: _isArabic ? "الرئيسية" : "Home",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: _isArabic ? "الحساب" : "Account",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart),
              label: _isArabic ? "العربة" : "Cart",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHomeContent() {
    final List<Map<String, dynamic>> categories = [
      {"nameAr": "الكل", "nameEn": "All", "icon": Icons.grid_view_outlined},
      {"nameAr": "خضروات", "nameEn": "Vegetables", "icon": Icons.eco_outlined},
      {"nameAr": "ملابس", "nameEn": "Fashion", "icon": Icons.checkroom_outlined}, 
      {"nameAr": "كمبيوتر", "nameEn": "Computers", "icon": Icons.computer_outlined}, 
      {"nameAr": "إلكترونيات", "nameEn": "Electronics", "icon": Icons.devices_other_outlined}, 
      {"nameAr": "بقالة", "nameEn": "Grocery", "icon": Icons.local_grocery_store_outlined},
      {"nameAr": "مخبوزات", "nameEn": "Bakery", "icon": Icons.bakery_dining_outlined},
    ];

    final productProvider = Provider.of<ProductProvider>(context);
    final productsList = productProvider.products;

    final filteredProducts = productsList.where((product) {
      final matchesCategory = _selectedCategory == "All" || product["category"] == _selectedCategory;
      final matchesSearch = _isArabic 
          ? product["nameAr"]!.contains(_searchQuery) 
          : product["nameEn"]!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _isArabic ? "بتدور على إيه؟" : "What are you looking for?",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF2E7D32), Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isArabic ? "عروض نهاية الأسبوع!" : "Weekend Offers!",
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isArabic ? "خصومات تصل إلى 50%" : "Discounts up to 50%",
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: _isArabic ? 16 : null,
                  right: _isArabic ? null : 16,
                  bottom: -10,
                  child: Icon(
                    Icons.local_offer,
                    size: 130,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                )
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 24.0, bottom: 12.0),
            child: Text(
              _isArabic ? "الأقسام" : "Categories",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 95,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final bool isSelected = _selectedCategory == cat["nameEn"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat["nameEn"]!;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                          child: Icon(
                            cat["icon"], 
                            color: isSelected ? Colors.white : const Color(0xFF2E7D32), 
                            size: 26
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isArabic ? cat["nameAr"] : cat["nameEn"],
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                            fontFamily: 'Cairo'
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 16.0, bottom: 12.0),
            child: Text(
              _isArabic ? "الأكثر مبيعاً 🔥" : "Best Sellers 🔥",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),
        ),
        filteredProducts.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _isArabic ? "لا توجد منتجات تطابق البحث!" : "No products match your search!",
                        style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredProducts[index];
                      final String productTitle = _isArabic ? product["nameAr"]! : product["nameEn"]!;
                      final String snackBarMessage = _isArabic ? "تمت إضافة المنتج للعربة" : "Product added to cart";
                      final String sellerName = product["seller"] ?? (_isArabic ? "سوقنا المحلي" : "Local Market");

                      return ProductCard(
                        title: productTitle,
                        price: product["price"]!,
                        imageUrl: product["image"] ?? "",
                        isArabic: _isArabic,
                        seller: sellerName,
                        onAddToCart: () {
                          Provider.of<CartProvider>(context, listen: false).addToCart(
                            product["nameAr"]!,
                            product["nameEn"]!,
                            double.parse(product["price"]!),
                            sellerName,
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(snackBarMessage, style: const TextStyle(fontFamily: 'Cairo')),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}