import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping/product_provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'add_product_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  final bool isArabic;

  const SellerDashboardScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    
    final storeName = userRoleProvider.storeName ?? (isArabic ? "متجري" : "My Store");
    final category = userRoleProvider.businessCategory ?? "";

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              isArabic ? "لوحة تحكم البائع" : "Seller Dashboard",
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14),
              tabs: [
                Tab(
                  icon: const Icon(Icons.inventory_2_outlined),
                  text: isArabic ? "منتجاتي" : "My Products",
                ),
                Tab(
                  icon: const Icon(Icons.receipt_long_outlined),
                  text: isArabic ? "الطلبات الواردة" : "Received Orders",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildProductsTab(context, storeName, category),
              _buildReceivedOrdersTab(context, storeName),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(isArabic: isArabic, storeName: storeName),
                ),
              );
            },
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              isArabic ? "إضافة منتج" : "Add Product",
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context, String storeName, String category) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    // تصفية المنتجات المضافة بواسطة هذا البائع فقط
    final myProducts = productProvider.products.where((p) {
      return p["seller"] == storeName;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كارت معلومات المتجر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.store, size: 40, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 12),
                Text(
                  storeName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                if (category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${isArabic ? 'النشاط:' : 'Activity:'} $category",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontFamily: 'Cairo'),
                  ),
                ],
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      title: isArabic ? "منتجاتي" : "My Products",
                      value: "${myProducts.length}",
                      icon: Icons.inventory_2_outlined,
                    ),
                    // نقوم بجلب إجمالي المبيعات ديناميكياً من الطلبات المستلمة والمسلمة في Firebase
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .where('sellers', arrayContains: storeName)
                          .snapshots(),
                      builder: (context, snapshot) {
                        double salesTotal = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final items = data["items"] as List<dynamic>? ?? [];
                            for (var item in items) {
                              final itemMap = item as Map<dynamic, dynamic>;
                              if (itemMap["seller"] == storeName) {
                                final price = itemMap["price"] ?? 0.0;
                                final qty = itemMap["quantity"] ?? 1;
                                salesTotal += price * qty;
                              }
                            }
                          }
                        }
                        return _buildStatCard(
                          title: isArabic ? "إجمالي المبيعات" : "Total Sales",
                          value: "$salesTotal ${isArabic ? 'ج.م' : 'EGP'}",
                          icon: Icons.monetization_on_outlined,
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 24, bottom: 12),
            child: Text(
              isArabic ? "قائمة منتجاتي" : "My Products List",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
          ),

          myProducts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
                    child: Column(
                      children: [
                        Icon(Icons.add_shopping_cart, size: 70, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          isArabic 
                              ? "لم تقم بإضافة أي منتج بعد!" 
                              : "You haven't added any products yet!",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? "اضغط على زر الإضافة بالأسفل لإضافة منتجك الأول."
                              : "Click the add button below to list your first product.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: myProducts.length,
                  itemBuilder: (context, index) {
                    final product = myProducts[index];
                    final title = isArabic ? product["nameAr"]! : product["nameEn"]!;
                    final price = product["price"]!;
                    final categoryName = product["category"]!;
                    final imageUrl = product["image"] ?? "";

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageUrl.startsWith('http')
                                      ? Image.network(imageUrl, fit: BoxFit.cover)
                                      : Image.asset(imageUrl, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2E7D32)),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 15),
                        ),
                        subtitle: Text(
                          "${isArabic ? 'القسم:' : 'Category:'} $categoryName\n${isArabic ? 'السعر:' : 'Price:'} $price ${isArabic ? 'ج.م' : 'EGP'}",
                          style: const TextStyle(fontSize: 12, fontFamily: 'Cairo', height: 1.5),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isArabic ? "نشط" : "Active",
                            style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReceivedOrdersTab(BuildContext context, String storeName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('sellers', arrayContains: storeName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 70, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? "لا توجد طلبات واردة حالياً!" : "No received orders yet!",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic 
                        ? "عندما يقوم العملاء بطلب منتجات من متجرك، ستظهر هنا." 
                        : "When customers order products from your store, they will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final orderData = docs[index].data() as Map<String, dynamic>;
            final String orderId = orderData["id"] ?? "";
            final String clientName = orderData["name"] ?? "";
            final String clientPhone = orderData["phone"] ?? "";
            final String clientAddress = orderData["address"] ?? "";
            final String paymentMethod = orderData["paymentMethod"] ?? "";
            final String status = orderData["status"] ?? "Preparing";
            final items = orderData["items"] as List<dynamic>? ?? [];

            // تصفية المنتجات التي تنتمي لهذا المتجر فقط
            final myItems = items.where((item) {
              final itemMap = item as Map<dynamic, dynamic>;
              return itemMap["seller"] == storeName;
            }).toList();

            double myTotal = 0;
            for (var item in myItems) {
              final itemMap = item as Map<dynamic, dynamic>;
              final price = itemMap["price"] ?? 0.0;
              final qty = itemMap["quantity"] ?? 1;
              myTotal += price * qty;
            }

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      "${isArabic ? 'العميل:' : 'Customer:'} $clientName",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isArabic ? 'الهاتف:' : 'Phone:'} $clientPhone | ${isArabic ? 'الدفع:' : 'Payment:'} $paymentMethod",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isArabic ? 'العنوان:' : 'Address:'} $clientAddress",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Cairo'),
                    ),
                    const Divider(height: 20),
                    Text(
                      isArabic ? "المنتجات المطلوبة من متجري:" : "Items ordered from my store:",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    ...myItems.map((item) {
                      final itemMap = item as Map<dynamic, dynamic>;
                      final title = isArabic ? itemMap["nameAr"] : itemMap["nameEn"];
                      final price = itemMap["price"];
                      final qty = itemMap["quantity"];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$title (x$qty)",
                              style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                            ),
                            Text(
                              "${price * qty} ${isArabic ? 'ج.م' : 'EGP'}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? "إجمالي حساب متجري:" : "My store's total:",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                        ),
                        Text(
                          "$myTotal ${isArabic ? 'ج.م' : 'EGP'}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case "On the Way":
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        text = isArabic ? "جاري التوصيل" : "On the Way";
        break;
      case "Delivered":
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        text = isArabic ? "تم التوصيل" : "Delivered";
        break;
      case "Preparing":
      default:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        text = isArabic ? "جاري التجهيز" : "Preparing";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
