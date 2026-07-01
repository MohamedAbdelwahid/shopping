import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductProvider extends ChangeNotifier {
  static const List<Map<String, String>> _defaultProducts = [
    {
      "nameAr": "طماطم طازجة 1 كيلو",
      "nameEn": "Fresh Tomatoes 1KG",
      "price": "20",
      "category": "Vegetables",
      "image": "https://images.unsplash.com/photo-1597362925123-77861d3fbac7?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "خيار بلدي 1 كيلو",
      "nameEn": "Fresh Cucumber 1KG",
      "price": "15",
      "category": "Vegetables",
      "image": "https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "بوكسر قطن مريح (طقم 5 قطع)",
      "nameEn": "Comfortable Cotton Boxers (Pack of 5)",
      "price": "220",
      "category": "Fashion",
      "image": "assets/images/cotton_boxers.png",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "تيشرت قطن كاجوال",
      "nameEn": "Casual Cotton T-Shirt",
      "price": "250",
      "category": "Fashion",
      "image": "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "حذاء رياضي مريح",
      "nameEn": "Comfortable Sneakers",
      "price": "680",
      "category": "Fashion",
      "image": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "ماوس كمبيوتر لاسلكي",
      "nameEn": "Wireless Computer Mouse",
      "price": "180",
      "category": "Computers",
      "image": "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "لوحة مفاتيح ميكانيكية",
      "nameEn": "Mechanical Keyboard",
      "price": "850",
      "category": "Computers",
      "image": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "سماعة رأس محيطية",
      "nameEn": "Gaming Headset",
      "price": "450",
      "category": "Electronics",
      "image": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "شاحن سريع 20 وات",
      "nameEn": "Fast Charger 20W",
      "price": "300",
      "category": "Electronics",
      "image": "https://images.unsplash.com/photo-1583863788434-e58a36330cf0?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "زيت عباد الشمس 1 لتر",
      "nameEn": "Sunflower Oil 1L",
      "price": "75",
      "category": "Grocery",
      "image": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "أرز مصري فاخر 5 كيلو",
      "nameEn": "Premium Egyptian Rice 5KG",
      "price": "160",
      "category": "Grocery",
      "image": "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "كرواسون شوكولاتة",
      "nameEn": "Chocolate Croissant",
      "price": "35",
      "category": "Bakery",
      "image": "https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
    {
      "nameAr": "خبز توست أبيض",
      "nameEn": "White Toast Bread",
      "price": "40",
      "category": "Bakery",
      "image": "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=300&auto=format&fit=crop",
      "seller": "سوقنا المحلي"
    },
  ];

  List<Map<String, String>> _products = [];
  bool _isSeeding = false;

  ProductProvider() {
    _initProducts();
  }

  void _initProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedProducts();
      } else {
        _products = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "nameAr": (data["nameAr"] ?? "").toString(),
            "nameEn": (data["nameEn"] ?? "").toString(),
            "price": (data["price"] ?? "").toString(),
            "category": (data["category"] ?? "").toString(),
            "image": (data["image"] ?? "").toString(),
            "seller": (data["seller"] ?? "").toString(),
          };
        }).toList();
        notifyListeners();
      }
    });
  }

  Future<void> _seedProducts() async {
    if (_isSeeding) return;
    _isSeeding = true;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var product in _defaultProducts) {
        final docRef = FirebaseFirestore.instance.collection('products').doc();
        batch.set(docRef, product);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error seeding products: $e");
    } finally {
      _isSeeding = false;
    }
  }

  List<Map<String, String>> get products => List.unmodifiable(_products);

  Future<void> addProduct(Map<String, String> product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add(product);
    } catch (e) {
      debugPrint("Error adding product: $e");
    }
  }
}
