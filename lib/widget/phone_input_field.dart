import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/language_provider.dart';

class PhoneFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool isArabic;
  final String? labelText;
  final ValueChanged<String>? onCountryCodeChanged;
  final String initialCountryCode;
  final InputBorder? decorationBorder;

  const PhoneFormField({
    Key? key,
    required this.controller,
    required this.isArabic,
    this.labelText,
    this.onCountryCodeChanged,
    this.initialCountryCode = '+20',
    this.decorationBorder,
  }) : super(key: key);

  @override
  State<PhoneFormField> createState() => _PhoneFormFieldState();
}

class _PhoneFormFieldState extends State<PhoneFormField> {
  late Map<String, String> _selectedCountry;

  final List<Map<String, String>> _countries = [
    {"code": "+20", "flag": "🇪🇬", "nameAr": "مصر", "nameEn": "Egypt"},
    {"code": "+966", "flag": "🇸🇦", "nameAr": "السعودية", "nameEn": "Saudi Arabia"},
    {"code": "+971", "flag": "🇦🇪", "nameAr": "الإمارات", "nameEn": "UAE"},
    {"code": "+965", "flag": "🇰🇼", "nameAr": "الكويت", "nameEn": "Kuwait"},
    {"code": "+974", "flag": "🇶🇦", "nameAr": "قطر", "nameEn": "Qatar"},
    {"code": "+973", "flag": "🇧🇭", "nameAr": "البحرين", "nameEn": "Bahrain"},
    {"code": "+968", "flag": "🇴🇲", "nameAr": "عمان", "nameEn": "Oman"},
    {"code": "+967", "flag": "🇾🇪", "nameAr": "اليمن", "nameEn": "Yemen"},
    {"code": "+962", "flag": "🇯🇴", "nameAr": "الأردن", "nameEn": "Jordan"},
    {"code": "+964", "flag": "🇮🇶", "nameAr": "العراق", "nameEn": "Iraq"},
    {"code": "+963", "flag": "🇸🇾", "nameAr": "سوريا", "nameEn": "Syria"},
    {"code": "+961", "flag": "🇱🇧", "nameAr": "لبنان", "nameEn": "Lebanon"},
    {"code": "+970", "flag": "🇵🇸", "nameAr": "فلسطين", "nameEn": "Palestine"},
    {"code": "+218", "flag": "🇱🇾", "nameAr": "ليبيا", "nameEn": "Libya"},
    {"code": "+216", "flag": "🇹🇳", "nameAr": "تونس", "nameEn": "Tunisia"},
    {"code": "+213", "flag": "🇩🇿", "nameAr": "الجزائر", "nameEn": "Algeria"},
    {"code": "+212", "flag": "🇲🇦", "nameAr": "المغرب", "nameEn": "Morocco"},
    {"code": "+249", "flag": "🇸🇩", "nameAr": "السودان", "nameEn": "Sudan"},
    {"code": "+252", "flag": "🇸🇴", "nameAr": "الصومال", "nameEn": "Somalia"},
    {"code": "+253", "flag": "🇩🇯", "nameAr": "جيبوتي", "nameEn": "Djibouti"},
    {"code": "+222", "flag": "🇲🇷", "nameAr": "موريتانيا", "nameEn": "Mauritania"},
    {"code": "+49", "flag": "🇩🇪", "nameAr": "ألمانيا", "nameEn": "Germany"},
    {"code": "+33", "flag": "🇫🇷", "nameAr": "فرنسا", "nameEn": "France"},
    {"code": "+7", "flag": "🇷🇺", "nameAr": "روسيا", "nameEn": "Russia"},
    {"code": "+86", "flag": "🇨🇳", "nameAr": "الصين", "nameEn": "China"},
    {"code": "+1", "flag": "🇺🇸", "nameAr": "الولايات المتحدة", "nameEn": "United States"},
    {"code": "+44", "flag": "🇬🇧", "nameAr": "المملكة المتحدة", "nameEn": "United Kingdom"},
    {"code": "+1", "flag": "🇨🇦", "nameAr": "كندا", "nameEn": "Canada"},
    {"code": "+61", "flag": "🇦🇺", "nameAr": "أستراليا", "nameEn": "Australia"},
    {"code": "+81", "flag": "🇯🇵", "nameAr": "اليابان", "nameEn": "Japan"},
    {"code": "+91", "flag": "🇮🇳", "nameAr": "الهند", "nameEn": "India"},
    {"code": "+90", "flag": "🇹🇷", "nameAr": "تركيا", "nameEn": "Turkey"},
    {"code": "+39", "flag": "🇮🇹", "nameAr": "إيطاليا", "nameEn": "Italy"},
    {"code": "+34", "flag": "🇪🇸", "nameAr": "إسبانيا", "nameEn": "Spain"},
    {"code": "+55", "flag": "🇧🇷", "nameAr": "البرازيل", "nameEn": "Brazil"},
    {"code": "+54", "flag": "🇦🇷", "nameAr": "الأرجنتين", "nameEn": "Argentina"},
    {"code": "+52", "flag": "🇲🇽", "nameAr": "المكسيك", "nameEn": "Mexico"},
    {"code": "+31", "flag": "🇳🇱", "nameAr": "هولندا", "nameEn": "Netherlands"},
    {"code": "+32", "flag": "🇧🇪", "nameAr": "بلجيكا", "nameEn": "Belgium"},
    {"code": "+41", "flag": "🇨🇭", "nameAr": "سويسرا", "nameEn": "Switzerland"},
    {"code": "+46", "flag": "🇸🇪", "nameAr": "السويد", "nameEn": "Sweden"},
    {"code": "+47", "flag": "🇳🇴", "nameAr": "النرويج", "nameEn": "Norway"},
    {"code": "+45", "flag": "🇩🇰", "nameAr": "الدنمارك", "nameEn": "Denmark"},
    {"code": "+358", "flag": "🇫🇮", "nameAr": "فنلندا", "nameEn": "Finland"},
    {"code": "+48", "flag": "🇵🇱", "nameAr": "بولندا", "nameEn": "Poland"},
    {"code": "+30", "flag": "🇬🇷", "nameAr": "اليونان", "nameEn": "Greece"},
    {"code": "+380", "flag": "🇺🇦", "nameAr": "أوكرانيا", "nameEn": "Ukraine"},
    {"code": "+82", "flag": "🇰🇷", "nameAr": "كوريا الجنوبية", "nameEn": "South Korea"},
    {"code": "+27", "flag": "🇿🇦", "nameAr": "جنوب أفريقيا", "nameEn": "South Africa"},
    {"code": "+234", "flag": "🇳🇬", "nameAr": "نيجيريا", "nameEn": "Nigeria"},
    {"code": "+254", "flag": "🇰🇪", "nameAr": "كينيا", "nameEn": "Kenya"},
    {"code": "+62", "flag": "🇮🇩", "nameAr": "إندونيسيا", "nameEn": "Indonesia"},
    {"code": "+60", "flag": "🇲🇾", "nameAr": "ماليزيا", "nameEn": "Malaysia"},
    {"code": "+65", "flag": "🇸🇬", "nameAr": "سنغافورة", "nameEn": "Singapore"},
    {"code": "+92", "flag": "🇵🇰", "nameAr": "باكستان", "nameEn": "Pakistan"},
    {"code": "+880", "flag": "🇧🇩", "nameAr": "بنجلاديش", "nameEn": "Bangladesh"},
    {"code": "+94", "flag": "🇱🇰", "nameAr": "سريلانكا", "nameEn": "Sri Lanka"},
    {"code": "+84", "flag": "🇻🇳", "nameAr": "فيتنام", "nameEn": "Vietnam"},
    {"code": "+66", "flag": "🇹🇭", "nameAr": "تايلاند", "nameEn": "Thailand"},
    {"code": "+63", "flag": "🇵🇭", "nameAr": "الفلبين", "nameEn": "Philippines"},
    {"code": "+64", "flag": "🇳🇿", "nameAr": "نيوزيلندا", "nameEn": "New Zealand"},
    {"code": "+98", "flag": "🇮🇷", "nameAr": "إيران", "nameEn": "Iran"},
    {"code": "+93", "flag": "🇦🇫", "nameAr": "أفغانستان", "nameEn": "Afghanistan"},
    {"code": "+43", "flag": "🇦🇹", "nameAr": "النمسا", "nameEn": "Austria"},
    {"code": "+351", "flag": "🇵🇹", "nameAr": "البرتغال", "nameEn": "Portugal"},
    {"code": "+353", "flag": "🇮🇪", "nameAr": "أيرلندا", "nameEn": "Ireland"},
    {"code": "+420", "flag": "🇨🇿", "nameAr": "جمهورية التشيك", "nameEn": "Czech Republic"},
    {"code": "+36", "flag": "🇭🇺", "nameAr": "المجر", "nameEn": "Hungary"},
    {"code": "+40", "flag": "🇷🇴", "nameAr": "رومانيا", "nameEn": "Romania"},
    {"code": "+359", "flag": "🇧🇬", "nameAr": "بلغاريا", "nameEn": "Bulgaria"},
    {"code": "+385", "flag": "🇭🇷", "nameAr": "كرواتيا", "nameEn": "Croatia"},
    {"code": "+421", "flag": "🇸🇰", "nameAr": "سلوفاكيا", "nameEn": "Slovakia"},
    {"code": "+386", "flag": "🇸🇮", "nameAr": "سلوفينيا", "nameEn": "Slovenia"},
    {"code": "+372", "flag": "🇪🇪", "nameAr": "إستونيا", "nameEn": "Estonia"},
    {"code": "+371", "flag": "🇱🇻", "nameAr": "لاتفيا", "nameEn": "Latvia"},
    {"code": "+370", "flag": "🇱🇹", "nameAr": "ليتوانيا", "nameEn": "Lithuania"},
    {"code": "+352", "flag": "🇱🇺", "nameAr": "لوكسمبورغ", "nameEn": "Luxembourg"},
    {"code": "+357", "flag": "🇨🇾", "nameAr": "قبرص", "nameEn": "Cyprus"},
    {"code": "+356", "flag": "🇲🇹", "nameAr": "مالطا", "nameEn": "Malta"},
    {"code": "+354", "flag": "🇮🇸", "nameAr": "آيسلندا", "nameEn": "Iceland"},
    {"code": "+375", "flag": "🇧🇾", "nameAr": "بيلاروسيا", "nameEn": "Belarus"},
    {"code": "+998", "flag": "🇺🇿", "nameAr": "أوزبكستان", "nameEn": "Uzbekistan"},
    {"code": "+994", "flag": "🇦🇿", "nameAr": "أذربيجان", "nameEn": "Azerbaijan"},
    {"code": "+995", "flag": "🇬🇪", "nameAr": "جورجيا", "nameEn": "Georgia"},
    {"code": "+374", "flag": "🇦🇲", "nameAr": "أرمينيا", "nameEn": "Armenia"},
    {"code": "+57", "flag": "🇨🇴", "nameAr": "كولومبيا", "nameEn": "Colombia"},
    {"code": "+51", "flag": "🇵🇪", "nameAr": "بيرو", "nameEn": "Peru"},
    {"code": "+56", "flag": "🇨🇱", "nameAr": "تشيلي", "nameEn": "Chile"},
    {"code": "+58", "flag": "🇻🇪", "nameAr": "فنزويلا", "nameEn": "Venezuela"},
    {"code": "+593", "flag": "🇪🇨", "nameAr": "الإكوادور", "nameEn": "Ecuador"},
    {"code": "+591", "flag": "🇧🇴", "nameAr": "بوليفيا", "nameEn": "Bolivia"},
    {"code": "+595", "flag": "🇵🇾", "nameAr": "باراغواي", "nameEn": "Paraguay"},
    {"code": "+598", "flag": "🇺🇾", "nameAr": "أوروغواي", "nameEn": "Uruguay"},
    {"code": "+506", "flag": "🇨🇷", "nameAr": "كوستاريكا", "nameEn": "Costa Rica"},
    {"code": "+507", "flag": "🇵🇦", "nameAr": "بنما", "nameEn": "Panama"},
    {"code": "+53", "flag": "🇨🇺", "nameAr": "كوبا", "nameEn": "Cuba"},
    {"code": "+233", "flag": "🇬🇭", "nameAr": "غانا", "nameEn": "Ghana"},
    {"code": "+237", "flag": "🇨🇲", "nameAr": "الكاميرون", "nameEn": "Cameroon"},
    {"code": "+225", "flag": "🇨🇮", "nameAr": "ساحل العاج", "nameEn": "Ivory Coast"},
    {"code": "+221", "flag": "🇸🇳", "nameAr": "السنغال", "nameEn": "Senegal"},
    {"code": "+251", "flag": "🇪🇹", "nameAr": "إثيوبيا", "nameEn": "Ethiopia"},
    {"code": "+256", "flag": "🇺🇬", "nameAr": "أوغندا", "nameEn": "Uganda"},
    {"code": "+255", "flag": "🇹🇿", "nameAr": "تنزانيا", "nameEn": "Tanzania"},
    {"code": "+263", "flag": "🇿🇼", "nameAr": "زيمبابوي", "nameEn": "Zimbabwe"},
    {"code": "+244", "flag": "🇦🇴", "nameAr": "أنغولا", "nameEn": "Angola"},
    {"code": "+258", "flag": "🇲🇿", "nameAr": "موزمبيق", "nameEn": "Mozambique"},
    {"code": "+261", "flag": "🇲🇬", "nameAr": "مدغشقر", "nameEn": "Madagascar"},
    {"code": "+230", "flag": "🇲🇺", "nameAr": "موريشيوس", "nameEn": "Mauritius"},
    {"code": "+977", "flag": "🇳🇵", "nameAr": "نيبال", "nameEn": "Nepal"},
    {"code": "+95", "flag": "🇲🇲", "nameAr": "ميانمار", "nameEn": "Myanmar"},
    {"code": "+855", "flag": "🇰🇭", "nameAr": "كمبوديا", "nameEn": "Cambodia"},
    {"code": "+856", "flag": "🇱🇦", "nameAr": "لاوس", "nameEn": "Laos"},
    {"code": "+976", "flag": "🇲🇳", "nameAr": "منغوليا", "nameEn": "Mongolia"},
  ];

  @override
  void initState() {
    super.initState();
    // Select initial country code, defaulting to Egypt if not found
    _selectedCountry = _countries.firstWhere(
      (c) => c["code"] == widget.initialCountryCode,
      orElse: () => _countries.firstWhere((c) => c["code"] == "+20"),
    );

    // Auto-parse country code if the controller already has one prepended
    for (var country in _countries) {
      final code = country["code"]!;
      if (widget.controller.text.startsWith(code)) {
        _selectedCountry = country;
        widget.controller.text = widget.controller.text.substring(code.length);
        if (widget.onCountryCodeChanged != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCountryCodeChanged!(code);
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final String currentLang = languageProvider.currentLanguage;
    final bool isOutline = widget.decorationBorder is OutlineInputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && !isOutline) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Directionality(
          textDirection: TextDirection.ltr, // Keep country code and digits left-aligned
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: isOutline ? widget.labelText : null,
              labelStyle: const TextStyle(fontFamily: 'Cairo'),
              hintText: "101 234 5678",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, String>>(
                    value: _selectedCountry,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 350,
                    selectedItemBuilder: (BuildContext context) {
                      return _countries.map<Widget>((Map<String, String> country) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(country["flag"]!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 4),
                              Text(
                                country["code"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (Map<String, String>? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                        if (widget.onCountryCodeChanged != null) {
                          widget.onCountryCodeChanged!(newValue["code"]!);
                        }
                      }
                    },
                    items: _countries.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> country) {
                      final String countryName = currentLang == 'ar' ? country["nameAr"]! : country["nameEn"]!;
                      return DropdownMenuItem<Map<String, String>>(
                        value: country,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(country["flag"]!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              country["code"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // In the dropdown list itself, show the country name for clarity
                            Text(
                              "($countryName)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              border: widget.decorationBorder ?? const UnderlineInputBorder(),
              focusedBorder: isOutline
                  ? const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                    )
                  : const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                    ),
              contentPadding: isOutline
                  ? const EdgeInsets.symmetric(vertical: 16, horizontal: 12)
                  : const EdgeInsets.symmetric(vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return languageProvider.translate("enter_phone_error");
              }
              final cleanVal = value.trim();
              if (cleanVal.length < 7 || cleanVal.length > 15) {
                return languageProvider.translate("invalid_phone_error");
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(cleanVal)) {
                return languageProvider.translate("numbers_only_error");
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
