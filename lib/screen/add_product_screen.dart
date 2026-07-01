import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final bool isArabic;
  final String storeName;

  const AddProductScreen({
    Key? key,
    required this.isArabic,
    required this.storeName,
  }) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = "Vegetables";

  // روابط افتراضية للصور بناءً على القسم المختار لتسهيل التعبئة على المستخدم
  final Map<String, String> _categoryDefaultImages = {
    "Vegetables": "https://images.unsplash.com/photo-1597362925123-77861d3fbac7?q=80&w=300&auto=format&fit=crop",
    "Fashion": "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=300&auto=format&fit=crop",
    "Computers": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?q=80&w=300&auto=format&fit=crop",
    "Electronics": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300&auto=format&fit=crop",
    "Grocery": "https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=300&auto=format&fit=crop",
    "Bakery": "https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=300&auto=format&fit=crop",
  };

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    // تحديد الصورة النهائية: إما المدخلة من البائع أو الافتراضية للقسم
    String finalImageUrl = _imageUrlController.text.trim();
    if (finalImageUrl.isEmpty) {
      finalImageUrl = _categoryDefaultImages[_selectedCategory] ?? "";
    }

    final newProduct = {
      "nameAr": _nameArController.text.trim(),
      "nameEn": _nameEnController.text.trim(),
      "price": _priceController.text.trim(),
      "category": _selectedCategory,
      "image": finalImageUrl,
      "description": _descriptionController.text.trim(),
      "seller": widget.storeName,
    };

    Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? "تمت إضافة المنتج بنجاح! 🚀" : "Product added successfully! 🚀",
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
    final List<Map<String, String>> categories = [
      {"value": "Vegetables", "labelAr": "خضروات", "labelEn": "Vegetables"},
      {"value": "Fashion", "labelAr": "ملابس", "labelEn": "Fashion"},
      {"value": "Computers", "labelAr": "كمبيوتر", "labelEn": "Computers"},
      {"value": "Electronics", "labelAr": "إلكترونيات", "labelEn": "Electronics"},
      {"value": "Grocery", "labelAr": "بقالة", "labelEn": "Grocery"},
      {"value": "Bakery", "labelAr": "مخبوزات", "labelEn": "Bakery"},
    ];

    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            widget.isArabic ? "إضافة منتج جديد" : "Add New Product",
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
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isArabic ? "تفاصيل المنتج" : "Product Details",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _nameArController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "الاسم بالعربية" : "Name in Arabic",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.label_outline),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل الاسم العربي" : "Please enter Arabic name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameEnController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "الاسم بالإنجليزية" : "Name in English",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.label_outline),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل الاسم الإنجليزي" : "Please enter English name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "السعر (ج.م)" : "Price (EGP)",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.attach_money),
                            border: const UnderlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return widget.isArabic ? "من فضلك أدخل السعر" : "Please enter price";
                            }
                            if (double.tryParse(value) == null) {
                              return widget.isArabic ? "من فضلك أدخل رقماً صحيحاً" : "Please enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        Text(
                          widget.isArabic ? "قسم المنتج" : "Product Category",
                          style: const TextStyle(
                            fontFamily: 'Cairo', 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14, 
                            color: Colors.black54
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.grid_view),
                            border: UnderlineInputBorder(),
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat["value"],
                              child: Text(
                                widget.isArabic ? cat["labelAr"]! : cat["labelEn"]!,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isArabic ? "الوسائط والوصف" : "Media & Description",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "رابط صورة المنتج (اختياري)" : "Product Image URL (Optional)",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.image_outlined),
                            helperText: widget.isArabic 
                                ? "إذا تركته فارغاً، سنستخدم صورة افتراضية رائعة للقسم المحدد." 
                                : "If left empty, we'll use a beautiful category default image.",
                            helperStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: widget.isArabic ? "وصف ومواصفات المنتج" : "Product Description & Specs",
                            labelStyle: const TextStyle(fontFamily: 'Cairo'),
                            prefixIcon: const Icon(Icons.description_outlined),
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isArabic ? "حفظ وعرض المنتج" : "Save & Publish Product",
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
