import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'package:shopping/widget/phone_input_field.dart';

class SellerRegisterScreen extends StatefulWidget {
  final bool isArabic;

  const SellerRegisterScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  String _countryCode = "+20";

  @override
  void initState() {
    super.initState();
    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    _storeNameController.text = userRoleProvider.storeName ?? userRoleProvider.userName;
    _emailController.text = userRoleProvider.sellerEmail ?? userRoleProvider.userEmail;
    _phoneController.text = userRoleProvider.sellerPhone ?? userRoleProvider.userPhone;
    _addressController.text = userRoleProvider.storeAddress ?? "";
    _categoryController.text = userRoleProvider.businessCategory ?? "";
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _registerSeller() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<UserRoleProvider>(context, listen: false).registerAsSeller(
      name: _storeNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _countryCode + _phoneController.text.trim(),
      address: _addressController.text.trim(),
      category: _categoryController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? "تم التسجيل كبائع بنجاح! 🎉" : "Successfully registered as a seller! 🎉",
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            widget.isArabic ? "التسجيل كبائع" : "Register as Seller",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 80,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isArabic 
                      ? "ابدأ بيع منتجاتك معنا الآن!" 
                      : "Start selling your products with us!",
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'Cairo'
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isArabic
                      ? "املأ البيانات التالية لإنشاء متجرك المحلي مجاناً."
                      : "Fill in the details below to create your local store for free.",
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.grey.shade600, 
                    fontFamily: 'Cairo'
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _storeNameController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "اسم المتجر" : "Store Name",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.store_outlined),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل اسم المتجر" : "Please enter store name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "نوع النشاط (مثال: ملابس، خضروات)" : "Business Category (e.g., Fashion, Grocery)",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل نوع النشاط" : "Please enter activity type";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "البريد الإلكتروني للمتجر" : "Store Email Address",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل البريد الإلكتروني" : "Please enter email address";
                            }
                            final email = value.trim().toLowerCase();
                            if (!email.endsWith('@gmail.com') && !email.endsWith('@gamil.com')) {
                              return widget.isArabic 
                                  ? "يجب أن يكون حساب جوجل ينتهي بـ @gmail.com" 
                                  : "Must be a Google account ending with @gmail.com";
                            }
                            final emailRegex = RegExp(r'^[a-zA-Z0-9\._%+-]+@g[am]+il\.com$');
                            if (!emailRegex.hasMatch(email)) {
                              return widget.isArabic ? "بريد إلكتروني غير صحيح" : "Invalid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        PhoneFormField(
                          controller: _phoneController,
                          isArabic: widget.isArabic,
                          labelText: widget.isArabic ? "رقم هاتف المتجر" : "Store Phone Number",
                          initialCountryCode: _countryCode,
                          onCountryCodeChanged: (code) {
                            setState(() {
                              _countryCode = code;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "عنوان المتجر بالتفصيل" : "Detailed Store Address",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل العنوان" : "Please enter store address";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerSeller,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isArabic ? "إنشاء حساب بائع" : "Create Seller Account",
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
