import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping/cart_provider.dart';
import 'package:shopping/user_role_provider.dart';

class DeliveryDashboardScreen extends StatelessWidget {
  final bool isArabic;

  const DeliveryDashboardScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final driverName = userRoleProvider.deliveryName ?? (isArabic ? "مندوب التوصيل" : "Delivery Driver");
    final driverPhone = userRoleProvider.deliveryPhone ?? "";

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              isArabic ? "لوحة تحكم الدليفري" : "Delivery Dashboard",
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
                  icon: const Icon(Icons.list_alt),
                  text: isArabic ? "الطلبات المتاحة" : "Available Orders",
                ),
                Tab(
                  icon: const Icon(Icons.delivery_dining),
                  text: isArabic ? "شحناتي الجارية" : "My Shipments",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildAvailableOrdersTab(context, driverName, driverPhone),
              _buildMyShipmentsTab(context, driverName),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableOrdersTab(BuildContext context, String driverName, String driverPhone) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            Icons.check_circle_outline,
            isArabic ? "لا توجد طلبات معلقة حالياً!" : "No pending orders right now!",
            isArabic 
                ? "عندما يقوم العملاء بطلب منتجات، ستظهر هنا فوراً للتوصيل." 
                : "When customers place orders, they will appear here to be claimed.",
          );
        }

        final allOrders = snapshot.data!.docs;
        final availableOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data["status"] == "Preparing";
        }).toList();

        if (availableOrders.isEmpty) {
          return _buildEmptyState(
            Icons.check_circle_outline,
            isArabic ? "لا توجد طلبات معلقة حالياً!" : "No pending orders right now!",
            isArabic 
                ? "عندما يقوم العملاء بطلب منتجات، ستظهر هنا فوراً للتوصيل." 
                : "When customers place orders, they will appear here to be claimed.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: availableOrders.length,
          itemBuilder: (context, index) {
            final orderDoc = availableOrders[index];
            final order = orderDoc.data() as Map<String, dynamic>;
            final String orderId = order["id"] ?? "";
            final items = order["items"] as List<dynamic>? ?? [];

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
                        Text(
                          "${order["total"]} ${isArabic ? 'ج.م' : 'EGP'}",
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      "${isArabic ? 'العنوان:' : 'Address:'} ${order["address"]}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${isArabic ? 'المنتجات:' : 'Items:'} ${items.map((i) {
                        final map = i as Map<dynamic, dynamic>;
                        return isArabic ? map["nameAr"] : map["nameEn"];
                      }).join(', ')}",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Cairo'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cartProvider.claimOrder(orderId, driverName, driverPhone);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic ? "تم قبول الطلب وجاري التحضير للتوصيل! 🛵" : "Order claimed! Prepare for delivery. 🛵",
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.delivery_dining),
                        label: Text(
                          isArabic ? "قبول التوصيل" : "Claim Delivery",
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildMyShipmentsTab(BuildContext context, String driverName) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            Icons.motorcycle_outlined,
            isArabic ? "ليس لديك شحنات جارية!" : "No active shipments!",
            isArabic 
                ? "اذهب لتبويب الطلبات المتاحة واقبل توصيل طلب للبدء." 
                : "Go to Available Orders tab and claim a delivery to start.",
          );
        }

        final allOrders = snapshot.data!.docs;
        final myShipments = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data["status"] == "On the Way" && data["driverName"] == driverName;
        }).toList();

        if (myShipments.isEmpty) {
          return _buildEmptyState(
            Icons.motorcycle_outlined,
            isArabic ? "ليس لديك شحنات جارية!" : "No active shipments!",
            isArabic 
                ? "اذهب لتبويب الطلبات المتاحة واقبل توصيل طلب للبدء." 
                : "Go to Available Orders tab and claim a delivery to start.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myShipments.length,
          itemBuilder: (context, index) {
            final orderDoc = myShipments[index];
            final order = orderDoc.data() as Map<String, dynamic>;
            final String orderId = order["id"] ?? "";
            final items = order["items"] as List<dynamic>? ?? [];

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
                        Text(
                          "${order["total"]} ${isArabic ? 'ج.م' : 'EGP'}",
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      "${isArabic ? 'العميل:' : 'Customer:'} ${order["name"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${isArabic ? 'رقم الهاتف:' : 'Phone:'} ${order["phone"]}",
                      style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${isArabic ? 'العنوان بالتفصيل:' : 'Address:'} ${order["address"]}",
                      style: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                    ),
                    const Divider(height: 20),
                    Text(
                      isArabic ? "المنتجات المطلوب تسليمها:" : "Items to deliver:",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 6),
                    ...items.map((i) {
                      final map = i as Map<dynamic, dynamic>;
                      final title = isArabic ? map["nameAr"] : map["nameEn"];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          "- $title (x${map["quantity"]})",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontFamily: 'Cairo'),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${isArabic ? 'اتصال بـ' : 'Calling'} ${order["phone"]}...",
                                    style: const TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.blue.shade600),
                              foregroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.phone),
                            label: Text(
                              isArabic ? "اتصال بالعميل" : "Call Customer",
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              cartProvider.deliverOrder(orderId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic ? "تم تأكيد التسليم بنجاح! شكرًا لك. 🎉" : "Delivery confirmed! Thank you. 🎉",
                                    style: const TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              isArabic ? "تأكيد التسليم" : "Deliver Order",
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                          ),
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

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }
}
