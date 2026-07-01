import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/user_role_provider.dart';
import 'package:shopping/language_provider.dart';
import 'edit_profile_screen.dart';
import 'my_orders_screen.dart';
import 'seller_register_screen.dart';
import 'delivery_register_screen.dart';
import 'seller_dashboard_screen.dart';
import 'delivery_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageChanged;

  const ProfileScreen({
    Key? key,
    required this.isArabic,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isArabic = languageProvider.isArabic;
    final String role = userRoleProvider.role;

    final currentLangMap = languageProvider.supportedLanguages.firstWhere(
      (lang) => lang['code'] == languageProvider.currentLanguage,
      orElse: () => {'code': 'ar', 'name': 'العربية', 'flag': '🇪🇬'},
    );
    final currentLangName = currentLangMap['name']!;
    final currentLangFlag = currentLangMap['flag']!;

    String roleBadgeText = "";
    Color badgeColor = Colors.grey;
    if (role == 'seller') {
      roleBadgeText = isArabic ? "بائع محلي" : "Local Seller";
      badgeColor = Colors.teal;
    } else if (role == 'delivery') {
      roleBadgeText = isArabic ? "مندوب توصيل" : "Delivery Driver";
      badgeColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. كارت البروفايل العلوي (معلومات المستخدم)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, size: 60, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userRoleProvider.userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRoleProvider.userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  if (roleBadgeText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        roleBadgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. قائمة الخيارات والإعدادات الشيك
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileItem(
                    icon: Icons.edit_outlined,
                    title: isArabic ? "تعديل الحساب" : "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(isArabic: isArabic),
                        ),
                      );
                    },
                  ),
                  _buildProfileItem(
                    icon: Icons.local_shipping_outlined,
                    title: isArabic ? "طلباتي السابقة" : "My Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyOrdersScreen(isArabic: isArabic),
                        ),
                      );
                    },
                  ),
                  _buildProfileItem(
                    icon: Icons.location_on_outlined,
                    title: isArabic ? "عناوين الشحن" : "Shipping Addresses",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic ? "عنوان الشحن الافتراضي: القاهرة، مصر" : "Default Address: Cairo, Egypt",
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                  ),
                  _buildProfileItem(
                    icon: Icons.help_outline_rounded,
                    title: isArabic ? "مركز المساعدة" : "Help Center",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              isArabic ? "مركز المساعدة" : "Help Center", 
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              isArabic 
                                  ? "للدعم الفني، يرجى التواصل على البريد الإلكتروني support@example.com" 
                                  : "For support, please contact us at support@example.com",
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  isArabic ? "إغلاق" : "Close", 
                                  style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF2E7D32)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // خيار تبديل اللغة المربوط بالدالة التلقائية الحقيقية
                  _buildProfileItem(
                    icon: Icons.language_outlined,
                    title: isArabic 
                        ? "اللغة ($currentLangFlag $currentLangName)" 
                        : "Language ($currentLangFlag $currentLangName)",
                    trailingColor: const Color(0xFF2E7D32),
                    onTap: () => _showLanguagePicker(context, languageProvider),
                  ),
                  
                  const Divider(height: 24),

                  // لوحات التحكم والخيارات الخاصة بالبائع والتوصيل
                  if (role == 'customer') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        isArabic ? "انضم إلينا كشريك" : "Join us as a partner",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    _buildProfileItem(
                      icon: Icons.storefront_outlined,
                      title: isArabic ? "التسجيل كبائع" : "Register as Seller",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerRegisterScreen(isArabic: isArabic),
                          ),
                        );
                      },
                    ),
                    _buildProfileItem(
                      icon: Icons.delivery_dining_outlined,
                      title: isArabic ? "التسجيل كدليفري" : "Register as Delivery",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryRegisterScreen(isArabic: isArabic),
                          ),
                        );
                      },
                    ),
                  ] else if (role == 'seller') ...[
                    _buildProfileItem(
                      icon: Icons.store_outlined,
                      title: isArabic ? "لوحة تحكم البائع" : "Seller Dashboard",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerDashboardScreen(isArabic: isArabic),
                          ),
                        );
                      },
                    ),
                    _buildProfileItem(
                      icon: Icons.replay_outlined,
                      title: isArabic ? "الرجوع لحساب العميل" : "Reset to Customer Account",
                      iconColor: Colors.blue,
                      textColor: Colors.blue,
                      onTap: () {
                        userRoleProvider.resetToCustomer();
                      },
                    ),
                  ] else if (role == 'delivery') ...[
                    _buildProfileItem(
                      icon: Icons.delivery_dining,
                      title: isArabic ? "لوحة تحكم الدليفري" : "Delivery Dashboard",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryDashboardScreen(isArabic: isArabic),
                          ),
                        );
                      },
                    ),
                    _buildProfileItem(
                      icon: Icons.replay_outlined,
                      title: isArabic ? "الرجوع لحساب العميل" : "Reset to Customer Account",
                      iconColor: Colors.blue,
                      textColor: Colors.blue,
                      onTap: () {
                        userRoleProvider.resetToCustomer();
                      },
                    ),
                  ],

                  const SizedBox(height: 12),
                  
                  // زرار تسجيل الخروج باللون الأحمر المميز
                  _buildProfileItem(
                    icon: Icons.logout_rounded,
                    title: isArabic ? "تسجيل الخروج" : "Log Out",
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    showTrailing: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              isArabic ? "تسجيل الخروج" : "Log Out", 
                              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              isArabic ? "هل أنت متأكد من رغبتك في تسجيل الخروج؟" : "Are you sure you want to log out?",
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(isArabic ? "إلغاء" : "Cancel", style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isArabic ? "تم تسجيل الخروج بنجاح" : "Logged out successfully",
                                        style: const TextStyle(fontFamily: 'Cairo'),
                                      ),
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),
                                  );
                                },
                                child: Text(
                                  isArabic ? "خروج" : "Exit", 
                                  style: const TextStyle(fontFamily: 'Cairo', color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ودجت مخصصة ومصغرة لبناء سطور الإعدادات بشكل نظيف وبدون تكرار كود
  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF2E7D32),
    Color textColor = Colors.black87,
    Color? trailingColor,
    bool showTrailing = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor, fontFamily: 'Cairo'),
        ),
        trailing: showTrailing
            ? Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: trailingColor ?? Colors.grey.shade400,
              )
            : null,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LanguageProvider languageProvider) {
    final bool isArabic = languageProvider.isArabic;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                isArabic ? "اختر اللغة" : "Select Language",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: languageProvider.supportedLanguages.map((lang) {
                    final isSelected = languageProvider.currentLanguage == lang['code'];
                    return ListTile(
                      leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        lang['name']!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32))
                          : null,
                      onTap: () {
                        languageProvider.changeLanguage(lang['code']!);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}