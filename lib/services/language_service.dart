import 'package:flutter/foundation.dart';

class LanguageService {
  static final ValueNotifier<String> currentLocale = ValueNotifier<String>('en');

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'tr', 'name': 'Turkish', 'native': 'Türkçe'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'id', 'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Malay', 'native': 'Bahasa Melayu'},
    {'code': 'vi', 'name': 'Vietnamese', 'native': 'Tiếng Việt'},
    {'code': 'th', 'name': 'Thai', 'native': 'ไทย'},
    {'code': 'fa', 'name': 'Persian', 'native': 'فارسی'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'login_to_continue': 'Login to continue',
      'email_or_phone': 'Email or Phone Number',
      'password': 'Password',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot password',
      'login': 'Login',
      'or': 'or',
      'create_new_account': 'Create new account',
      'select_language': 'Select Language',
      'search': 'Search',
      'your_story': 'Your Story',
      'notifications': 'Notifications',
      'new_group': 'New Group',
      'create_group_desc': 'Create a group chat with multiple friends',
      'broadcast_desc': 'Broadcast messages to unlimited subscribers',
      'just_now': 'Just now',
    },
    'bn': {
      'login_to_continue': 'চালিয়ে যেতে লগইন করুন',
      'email_or_phone': 'ইমেইল বা ফোন নম্বর',
      'password': 'পাসওয়ার্ড',
      'remember_me': 'মনে রাখুন',
      'forgot_password': 'পাসওয়ার্ড ভুলে গেছেন?',
      'login': 'লগইন',
      'or': 'অথবা',
      'create_new_account': 'নতুন অ্যাকাউন্ট তৈরি করুন',
      'select_language': 'ভাষা নির্বাচন করুন',
    },
    'ar': {
      'login_to_continue': 'تسجيل الدخول للمتابعة',
      'email_or_phone': 'البريد الإلكتروني أو الهاتف',
      'password': 'كلمة المرور',
      'remember_me': 'تذكرني',
      'forgot_password': 'هل نسيت كلمة السر؟',
      'login': 'تسجيل الدخول',
      'or': 'أو',
      'create_new_account': 'إنشاء حساب جديد',
      'select_language': 'اختر اللغة',
    },
    'hi': {
      'login_to_continue': 'जारी रखने के लिए लॉगिन करें',
      'email_or_phone': 'ईमेल या फ़ोन नंबर',
      'password': 'पासवर्ड',
      'remember_me': 'मुझे याद रखें',
      'forgot_password': 'पासवर्ड भूल गए?',
      'login': 'लॉगिन',
      'or': 'या',
      'create_new_account': 'नया खाता बनाएं',
      'select_language': 'भाषा चुनें',
    },
    'es': {
      'login_to_continue': 'Inicia sesión para continuar',
      'email_or_phone': 'Correo o número de teléfono',
      'password': 'Contraseña',
      'remember_me': 'Recordarme',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'login': 'Iniciar sesión',
      'or': 'o',
      'create_new_account': 'Crear nueva cuenta',
      'select_language': 'Seleccionar idioma',
    },
  };

  static String tr(String key) {
    final code = currentLocale.value;
    if (_localizedValues.containsKey(code) && _localizedValues[code]!.containsKey(key)) {
      return _localizedValues[code]![key]!;
    }
    // ফলব্যাক ইংরেজি
    if (_localizedValues['en']!.containsKey(key)) {
      return _localizedValues['en']![key]!;
    }
    return key;
  }

  static void changeLanguage(String code) {
    currentLocale.value = code;
  }

  static String getCurrentLanguageName() {
    final item = supportedLanguages.firstWhere(
      (element) => element['code'] == currentLocale.value,
      orElse: () => {'native': 'English'},
    );
    return item['native']!;
  }
}