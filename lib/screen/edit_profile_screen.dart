import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'package:shopping/widget/phone_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isArabic;

  const EditProfileScreen({Key? key, required this.isArabic}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _countryCode = "+20";

  @override
  void initState() {
    super.initState();
    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    _nameController = TextEditingController(text: userRoleProvider.userName);
    _emailController = TextEditingController(text: userRoleProvider.userEmail);
    _phoneController = TextEditingController(text: userRoleProvider.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    userRoleProvider.updateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _countryCode + _phoneController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? "تم حفظ البيانات بنجاح!" : "Profile updated successfully!",
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
            widget.isArabic ? "تعديل الحساب" : "Edit Profile",
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
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.person, size: 70, color: Color(0xFF2E7D32)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                            labelText: widget.isArabic ? "الاسم" : "Name",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "الحقل مطلوب" : "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "البريد الإلكتروني" : "Email",
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isArabic ? "حفظ التغييرات" : "Save Changes",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
