import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider extends ChangeNotifier {
  // القائمة الحقيقية للمنتجات في العربة
  final List<Map<String, dynamic>> _items = [];
  // قائمة الطلبات السابقة
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> get orders => _orders;

  // دالة إضافة منتج جديد أو زيادة كميته لو موجود
  void addToCart(String titleAr, String titleEn, double price, String seller, {int quantity = 1}) {
    // التأكد لو المنتج موجود قبل كده
    int index = _items.indexWhere((item) => item["nameAr"] == titleAr);
    
    if (index >= 0) {
      _items[index]["quantity"] += quantity;
    } else {
      _items.add({
        "nameAr": titleAr,
        "nameEn": titleEn,
        "price": price,
        "quantity": quantity,
        "seller": seller,
      });
    }
    notifyListeners(); // تحديث كل الشاشات فوراً
  }

  void incrementQuantity(int index) {
    _items[index]["quantity"]++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index]["quantity"] > 1) {
      _items[index]["quantity"]--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  double calculateTotal() {
    double total = 0;
    for (var item in _items) {
      total += item["price"] * item["quantity"];
    }
    return total;
  }

  // إتمام عملية الشراء وحفظ الطلب في قائمة الطلبات السابقة و Firebase
  void checkout({
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    if (_items.isEmpty) return;

    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final date = DateTime.now();

    // استخراج أسماء المحلات الفريدة في هذا الطلب
    final sellers = _items
        .map((item) => item["seller"] as String? ?? "سوقنا المحلي")
        .toSet()
        .toList();

    final orderData = {
      "id": orderId,
      "date": Timestamp.fromDate(date),
      "items": List<Map<String, dynamic>>.from(_items),
      "total": calculateTotal(),
      "name": name,
      "phone": phone,
      "address": address,
      "paymentMethod": paymentMethod,
      "status": "Preparing", // Preparing, On the Way, Delivered
      "driverName": null,
      "driverPhone": null,
      "sellers": sellers,
    };

    // حفظ في Firebase
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);
    } catch (e) {
      debugPrint("Error saving order to Firestore: $e");
    }

    _orders.insert(0, {
      "id": orderId,
      "date": date,
      "items": List<Map<String, dynamic>>.from(_items),
      "total": calculateTotal(),
      "name": name,
      "phone": phone,
      "address": address,
      "paymentMethod": paymentMethod,
      "status": "Preparing",
      "driverName": null,
      "driverPhone": null,
      "sellers": sellers,
    });

    _items.clear();
    notifyListeners();
  }

  // قبول التوصيل بواسطة عامل التوصيل وتحديث Firebase
  void claimOrder(String orderId, String driverName, String driverPhone) async {
    final index = _orders.indexWhere((order) => order["id"] == orderId);
    if (index >= 0) {
      _orders[index]["status"] = "On the Way";
      _orders[index]["driverName"] = driverName;
      _orders[index]["driverPhone"] = driverPhone;
      notifyListeners();
    }

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        "status": "On the Way",
        "driverName": driverName,
        "driverPhone": driverPhone,
      });
    } catch (e) {
      debugPrint("Error claiming order in Firestore: $e");
    }
  }

  // تأكيد تسليم الطلب وتحديث Firebase
  void deliverOrder(String orderId) async {
    final index = _orders.indexWhere((order) => order["id"] == orderId);
    if (index >= 0) {
      _orders[index]["status"] = "Delivered";
      notifyListeners();
    }

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        "status": "Delivered",
      });
    } catch (e) {
      debugPrint("Error delivering order in Firestore: $e");
    }
  }
}