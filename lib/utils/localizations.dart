// ignore_for_file: unused_element
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  String getText(String key) {
    switch (languageCode) {
      case 'বাংলা':
        return _getBengali(key);
      case 'हिन्दी':
        return _getHindi(key);
      default:
        return _getEnglish(key);
    }
  }

  String _getEnglish(String key) {
    switch (key) {
      case 'loginTitle': return 'Login to continue';
      case 'emailOrPhone': return 'Email or Phone Number';
      case 'password': return 'Password';
      case 'rememberMe': return 'Remember me';
      case 'forgotPassword': return 'Forgot password?';
      case 'createAccount': return 'Create new account';
      case 'termsText': return 'By continuing, you agree to our\nTerms of Service and Privacy Policy';
      case 'or': return 'or';
      default: return key;
    }
  }

  String _getBengali(String key) {
    switch (key) {
      case 'loginTitle': return 'লগইন করতে চালিয়ে যান';
      case 'emailOrPhone': return 'ইমেইল বা ফোন নম্বর';
      case 'password': return 'পাসওয়ার্ড';
      case 'rememberMe': return 'আমাকে মনে রাখুন';
      case 'forgotPassword': return 'পাসওয়ার্ড ভুলে গেছেন?';
      case 'createAccount': return 'নতুন অ্যাকাউন্ট তৈরি করুন';
      case 'termsText': return 'চালিয়ে যাওয়ার মাধ্যমে, আপনি আমাদের\nসেবার শর্তাবলী এবং গোপনীয়তা নীতিতে সম্মতি দিচ্ছেন';
      case 'or': return 'অথবা';
      default: return key;
    }
  }

  String _getHindi(String key) {
    switch (key) {
      case 'loginTitle': return 'जारी रखने के लिए लॉगिन करें';
      case 'emailOrPhone': return 'ईमेल या फोन नंबर';
      case 'password': return 'पासवर्ड';
      case 'rememberMe': return 'मुझे याद रखें';
      case 'forgotPassword': return 'पासवर्ड भूल गए?';
      case 'createAccount': return 'नया खाता बनाएं';
      case 'termsText': return 'जारी रखने से, आप हमारी\nसेवा की शर्तों और गोपनीयता नीति से सहमत हैं';
      case 'or': return 'या';
      default: return key;
    }
  }
}

  String _getArabic(String key) {
    switch (key) {
      case 'loginTitle': return 'تسجيل الدخول للمتابعة';
      case 'emailOrPhone': return 'البريد الإلكتروني أو رقم الهاتف';
      case 'password': return 'كلمة المرور';
      case 'rememberMe': return 'تذكرني';
      case 'forgotPassword': return 'نسيت كلمة المرور؟';
      case 'createAccount': return 'إنشاء حساب جديد';
      case 'termsText': return 'بالمتابعة، أنت توافق على\nشروط الخدمة وسياسة الخصوصية';
      case 'or': return 'أو';
      default: return key;
    }
  }