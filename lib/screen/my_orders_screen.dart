import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersScreen extends StatelessWidget {
  final bool isArabic;

  const MyOrdersScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            isArabic ? "طلباتي السابقة" : "My Orders",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('date', descending: true)
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
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          size: 80,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isArabic ? "لا توجد طلبات سابقة!" : "No orders yet!",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? "اطلب الآن لتجد طلباتك مسجلة هنا."
                            : "Order items to see them listed here.",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final ordersDocs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ordersDocs.length,
              itemBuilder: (context, index) {
                final order = ordersDocs[index].data() as Map<String, dynamic>;
                final items = (order["items"] as List<dynamic>?)?.map((i) => i as Map<String, dynamic>).toList() ?? [];
                
                final timestamp = order["date"] as Timestamp?;
                final date = timestamp?.toDate() ?? DateTime.now();

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    shape: const Border(), // remove default divider lines in flutter
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order["id"] ?? "",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              _buildStatusBadge(order["status"] ?? "Preparing"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${isArabic ? 'إجمالي الحساب:' : 'Total Amount:'} ${order["total"]} ${isArabic ? 'ج.م' : 'EGP'}",
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(date),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? "تفاصيل الشحن:" : "Shipping Details:",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${isArabic ? 'الاسم:' : 'Name:'} ${order["name"]}\n"
                              "${isArabic ? 'الهاتف:' : 'Phone:'} ${order["phone"]}\n"
                              "${isArabic ? 'العنوان:' : 'Address:'} ${order["address"]}\n"
                              "${isArabic ? 'الدفع:' : 'Payment:'} ${order["paymentMethod"]}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5, fontFamily: 'Cairo'),
                            ),
                            const Divider(height: 20),
                            Text(
                              isArabic ? "المنتجات المطلوبة:" : "Items Ordered:",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final title = isArabic ? item["nameAr"] : item["nameEn"];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "$title (x${item["quantity"]})",
                                        style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                                      ),
                                    ),
                                    Text(
                                      "${item["price"] * item["quantity"]} ${isArabic ? 'ج.م' : 'EGP'}",
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
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
