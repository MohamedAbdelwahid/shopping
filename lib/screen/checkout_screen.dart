import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/cart_provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'package:shopping/widget/phone_input_field.dart';

class CheckoutScreen extends StatefulWidget {
  final bool isArabic;

  const CheckoutScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _addressController = TextEditingController();
  String _paymentMethod = "cod"; // cod or card
  String _countryCode = "+20";

  @override
  void initState() {
    super.initState();
    final userRole = Provider.of<UserRoleProvider>(context, listen: false);
    _nameController = TextEditingController(text: userRole.userName);
    _phoneController = TextEditingController(text: userRole.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _processCheckout(CartProvider cartProvider) {
    if (!_formKey.currentState!.validate()) return;

    // Execute checkout logic in provider
    cartProvider.checkout(
      name: _nameController.text.trim(),
      phone: _countryCode + _phoneController.text.trim(),
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod == "cod" 
          ? (widget.isArabic ? "الدفع عند الاستلام" : "Cash on Delivery")
          : (widget.isArabic ? "بطاقة ائتمان" : "Credit Card"),
    );

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isArabic ? "طلبك تم بنجاح! 🎉" : "Order Placed Successfully! 🎉",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isArabic
                      ? "جاري تجهيز طلبك وسيتم التوصيل في أقرب وقت."
                      : "Your order is being prepared and will be delivered soon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // go back to cart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      widget.isArabic ? "الرجوع للرئيسية" : "Back to Home",
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
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final double subTotal = cartProvider.calculateTotal();
    final double shipping = 20.0;
    final double total = subTotal + shipping;

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            widget.isArabic ? "إتمام عملية الشراء" : "Checkout",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. عنوان الشحن والبيانات
                Text(
                  widget.isArabic ? "عنوان التوصيل والبيانات" : "Shipping Details",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "الاسم بالكامل" : "Full Name",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل الاسم" : "Please enter your name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        PhoneFormField(
                          controller: _phoneController,
                          isArabic: widget.isArabic,
                          labelText: widget.isArabic ? "رقم الهاتف" : "Phone Number",
                          initialCountryCode: _countryCode,
                          decorationBorder: const OutlineInputBorder(),
                          onCountryCodeChanged: (code) {
                            setState(() {
                              _countryCode = code;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "عنوان التوصيل بالتفصيل" : "Detailed Address",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل عنوان التوصيل" : "Please enter delivery address";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. طريقة الدفع
                Text(
                  widget.isArabic ? "طريقة الدفع" : "Payment Method",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          widget.isArabic ? "الدفع عند الاستلام" : "Cash on Delivery",
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                        ),
                        value: "cod",
                        groupValue: _paymentMethod,
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        title: Text(
                          widget.isArabic ? "بطاقة ائتمان (فيزا / ماستر كارد)" : "Credit / Debit Card",
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
                        ),
                        value: "card",
                        groupValue: _paymentMethod,
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. ملخص الحساب
                Text(
                  widget.isArabic ? "ملخص الطلب" : "Order Summary",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.isArabic ? "المجموع الفرعي" : "Subtotal",
                              style: const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                            ),
                            Text(
                              "$subTotal ${widget.isArabic ? 'ج.م' : 'EGP'}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.isArabic ? "رسوم الشحن" : "Shipping Fee",
                              style: const TextStyle(fontFamily: 'Cairo', color: Colors.black54),
                            ),
                            Text(
                              "$shipping ${widget.isArabic ? 'ج.م' : 'EGP'}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.isArabic ? "الإجمالي الكلي" : "Total Amount",
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$total ${widget.isArabic ? 'ج.م' : 'EGP'}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // زرار تأكيد الشراء
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _processCheckout(cartProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.isArabic ? "تأكيد الطلب والشراء" : "Confirm & Place Order",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
