import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/cart_provider.dart';
import 'package:shopping/language_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String title;
  final String price;
  final String imageUrl;
  final bool isArabic;
  final String seller;

  const ProductDetailsScreen({
    Key? key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isArabic,
    required this.seller,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final bool isArabic = languageProvider.isArabic;

    // Check if item is already in cart to show a badge or status if needed
    final int itemIndex = cartProvider.items.indexWhere((item) {
      if (isArabic) {
        return item["nameAr"] == widget.title;
      } else {
        return item["nameEn"] == widget.title;
      }
    });
    final bool isInCart = itemIndex >= 0;
    final int cartQuantity = isInCart ? cartProvider.items[itemIndex]["quantity"] : 0;

    final String description = languageProvider.translate("dummy_description");
    final String snackBarMessage = languageProvider.translate("add_to_cart_msg");

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            isArabic ? "تفاصيل المنتج" : "Product Details",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. مكان صورة المنتج التعبيرية
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: widget.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: widget.imageUrl.startsWith('http')
                                  ? Image.network(
                                      widget.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 100,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    )
                                  : Image.asset(
                                      widget.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 100,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 100, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 20),

                    // 2. الاسم والسعر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                          ),
                        ),
                        Text(
                          "${widget.price} ${languageProvider.translate('currency')}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // معلومات البائع
                    Row(
                      children: [
                        Text(
                          "${languageProvider.translate('seller_label')} ",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontFamily: 'Cairo'),
                        ),
                        Text(
                          widget.seller,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Cairo'),
                        ),
                        if (isInCart) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isArabic ? "في العربة ($cartQuantity)" : "In Cart ($cartQuantity)",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontFamily: 'Cairo'),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. الوصف
                    Text(
                      languageProvider.translate("product_description"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade600, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            ),

            // 4. زرار الإضافة للعربة والتحكم في الكمية المحددة قبل الشراء
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أزرار التحكم في الكمية المحددة قبل الإضافة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // زرار الناقص (-) لتقليل الكمية المحددة
                        GestureDetector(
                          onTap: _selectedQuantity > 1
                              ? () {
                                  setState(() {
                                    _selectedQuantity--;
                                  });
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _selectedQuantity > 1 ? Colors.grey.shade100 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: _selectedQuantity > 1 ? Colors.black87 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // النص الخاص بالكمية المحددة
                        Text(
                          "$_selectedQuantity",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 24),
                        // زرار الزائد (+) لزيادة الكمية المحددة
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuantity++;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // زرار الشراء الرئيسي (شراء / إضافة إلى العربة)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // إضافة الكمية المحددة بالكامل للعربة
                          cartProvider.addToCart(
                            isArabic ? widget.title : "Product",
                            isArabic ? "Product" : widget.title,
                            double.parse(widget.price),
                            widget.seller,
                            quantity: _selectedQuantity,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "$snackBarMessage ($_selectedQuantity)",
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                          );

                          // إعادة تعيين الكمية المحددة إلى 1 بعد الإضافة الناجحة
                          setState(() {
                            _selectedQuantity = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          // استخدام كلمة "شراء" (Buy) أو "إضافة إلى العربة"
                          languageProvider.translate("buy"),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}