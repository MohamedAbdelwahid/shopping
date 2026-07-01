import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'package:shopping/widget/phone_input_field.dart';

class DeliveryRegisterScreen extends StatefulWidget {
  final bool isArabic;

  const DeliveryRegisterScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  State<DeliveryRegisterScreen> createState() => _DeliveryRegisterScreenState();
}

class _DeliveryRegisterScreenState extends State<DeliveryRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licensePlateController = TextEditingController();
  String _selectedVehicle = "Motorcycle";
  String _countryCode = "+20";

  @override
  void initState() {
    super.initState();
    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    _nameController.text = userRoleProvider.deliveryName ?? userRoleProvider.userName;
    _emailController.text = userRoleProvider.deliveryEmail ?? userRoleProvider.userEmail;
    _phoneController.text = userRoleProvider.deliveryPhone ?? userRoleProvider.userPhone;
    _licensePlateController.text = userRoleProvider.licensePlate ?? "";
    _selectedVehicle = userRoleProvider.vehicleType ?? "Motorcycle";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _registerDelivery() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<UserRoleProvider>(context, listen: false).registerAsDelivery(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _countryCode + _phoneController.text.trim(),
      vehicle: _selectedVehicle,
      plate: _licensePlateController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? "تم التسجيل كمندوب توصيل بنجاح! 🛵" : "Successfully registered as a delivery driver! 🛵",
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
    final List<Map<String, String>> vehicleOptions = [
      {"value": "Motorcycle", "labelAr": "دراجة نارية / موتوسيكل", "labelEn": "Motorcycle"},
      {"value": "Bicycle", "labelAr": "دراجة هوائية / عجلة", "labelEn": "Bicycle"},
      {"value": "Car", "labelAr": "سيارة", "labelEn": "Car"},
    ];

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            widget.isArabic ? "التسجيل كدليفري" : "Register as Delivery",
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
                      Icons.local_shipping_outlined,
                      size: 80,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isArabic 
                      ? "انضم لفريق التوصيل وحقق أرباحاً!" 
                      : "Join our delivery team and start earning!",
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'Cairo'
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isArabic
                      ? "املأ البيانات التالية للبدء في تلقي طلبات التوصيل بالمنطقة."
                      : "Fill in the details below to start receiving delivery orders in your area.",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "الاسم بالكامل" : "Full Name",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل الاسم" : "Please enter your name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "البريد الإلكتروني" : "Email Address",
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
                          labelText: widget.isArabic ? "رقم الهاتف" : "Phone Number",
                          initialCountryCode: _countryCode,
                          onCountryCodeChanged: (code) {
                            setState(() {
                              _countryCode = code;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.isArabic ? "وسيلة التوصيل" : "Delivery Vehicle",
                          style: const TextStyle(
                            fontFamily: 'Cairo', 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                            color: Colors.black54
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicle,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.directions_bike),
                            border: UnderlineInputBorder(),
                          ),
                          items: vehicleOptions.map((vehicle) {
                            return DropdownMenuItem<String>(
                              value: vehicle["value"],
                              child: Text(
                                widget.isArabic ? vehicle["labelAr"]! : vehicle["labelEn"]!,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicle = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedVehicle != "Bicycle")
                          TextFormField(
                            controller: _licensePlateController,
                            decoration: InputDecoration(
                              labelText: widget.isArabic ? "رقم اللوحة المعدنية" : "License Plate Number",
                              labelStyle: const TextStyle(fontFamily: 'Cairo'),
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: const UnderlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_selectedVehicle != "Bicycle" && (value == null || value.trim().isEmpty)) {
                                return widget.isArabic ? "رقم اللوحة مطلوب للمركبات الآلية" : "Plate number is required for motorized vehicles";
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
                    onPressed: _registerDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isArabic ? "إنشاء حساب مندوب" : "Create Delivery Account",
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
