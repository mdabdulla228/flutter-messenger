class LoginLocalizations {
  final String languageCode;

  LoginLocalizations(this.languageCode);

  String getText(String key) {
    switch (languageCode) {
      case 'বাংলা':
        return _getBengali(key);
      case 'हिन्दी':
        return _getHindi(key);
      case 'العربية':
        return _getArabic(key);
      case 'Español':
        return _getSpanish(key);
      case 'Français':
        return _getFrench(key);
      case 'Deutsch':
        return _getGerman(key);
      case 'Italiano':
        return _getItalian(key);
      case 'Português (Brasil)':
        return _getPortuguese(key);
      case 'Русский':
        return _getRussian(key);
      case '日本語':
        return _getJapanese(key);
      case '中文(简体)':
        return _getChinese(key);
      case '한국어':
        return _getKorean(key);
      case 'Türkçe':
        return _getTurkish(key);
      case 'Tiếng Việt':
        return _getVietnamese(key);
      case 'ภาษาไทย':
        return _getThai(key);
      case 'தமிழ்':
        return _getTamil(key);
      case 'తెలుగు':
        return _getTelugu(key);
      case 'മലയാളം':
        return _getMalayalam(key);
      case 'Filipino':
        return _getFilipino(key);
      case 'اردو':
        return _getUrdu(key);
      case 'ਪੰਜਾਬੀ':
        return _getPunjabi(key);
      case 'ಕನ್ನಡ':
        return _getKannada(key);
      case 'ગુજરાતી':
        return _getGujarati(key);
      case 'मराठी':
        return _getMarathi(key);
      case 'ଓଡ଼ିଆ':
        return _getOdia(key);
      case 'Kiswahili':
        return _getSwahili(key);
      case 'Ελληνικά':
        return _getGreek(key);
      case 'עברית':
        return _getHebrew(key);
      case 'فارسی':
        return _getPersian(key);
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

  String _getSpanish(String key) {
    switch (key) {
      case 'loginTitle': return 'Iniciar sesión para continuar';
      case 'emailOrPhone': return 'Correo electrónico o número de teléfono';
      case 'password': return 'Contraseña';
      case 'rememberMe': return 'Recordarme';
      case 'forgotPassword': return '¿Olvidaste tu contraseña?';
      case 'createAccount': return 'Crear cuenta nueva';
      case 'termsText': return 'Al continuar, aceptas nuestros\nTérminos de servicio y Política de privacidad';
      case 'or': return 'o';
      default: return key;
    }
  }

  String _getFrench(String key) {
    switch (key) {
      case 'loginTitle': return 'Connectez-vous pour continuer';
      case 'emailOrPhone': return 'E-mail ou numéro de téléphone';
      case 'password': return 'Mot de passe';
      case 'rememberMe': return 'Se souvenir de moi';
      case 'forgotPassword': return 'Mot de passe oublié ?';
      case 'createAccount': return 'Créer un nouveau compte';
      case 'termsText': return 'En continuant, vous acceptez nos\nConditions d\'utilisation et Politique de confidentialité';
      case 'or': return 'ou';
      default: return key;
    }
  }

  String _getGerman(String key) {
    switch (key) {
      case 'loginTitle': return 'Melden Sie sich an, um fortzufahren';
      case 'emailOrPhone': return 'E-Mail oder Telefonnummer';
      case 'password': return 'Passwort';
      case 'rememberMe': return 'Angemeldet bleiben';
      case 'forgotPassword': return 'Passwort vergessen?';
      case 'createAccount': return 'Neues Konto erstellen';
      case 'termsText': return 'Mit der Fortsetzung stimmen Sie unseren\nNutzungsbedingungen und Datenschutzrichtlinien zu';
      case 'or': return 'oder';
      default: return key;
    }
  }

  String _getItalian(String key) {
    switch (key) {
      case 'loginTitle': return 'Accedi per continuare';
      case 'emailOrPhone': return 'E-mail o numero di telefono';
      case 'password': return 'Password';
      case 'rememberMe': return 'Ricordami';
      case 'forgotPassword': return 'Password dimenticata?';
      case 'createAccount': return 'Crea nuovo account';
      case 'termsText': return 'Continuando, accetti i nostri\nTermini di servizio e Informativa sulla privacy';
      case 'or': return 'o';
      default: return key;
    }
  }

  String _getPortuguese(String key) {
    switch (key) {
      case 'loginTitle': return 'Faça login para continuar';
      case 'emailOrPhone': return 'E-mail ou número de telefone';
      case 'password': return 'Senha';
      case 'rememberMe': return 'Lembre-se de mim';
      case 'forgotPassword': return 'Esqueceu a senha?';
      case 'createAccount': return 'Criar nova conta';
      case 'termsText': return 'Ao continuar, você concorda com nossos\nTermos de Serviço e Política de Privacidade';
      case 'or': return 'ou';
      default: return key;
    }
  }

  String _getRussian(String key) {
    switch (key) {
      case 'loginTitle': return 'Войдите, чтобы продолжить';
      case 'emailOrPhone': return 'Электронная почта или номер телефона';
      case 'password': return 'Пароль';
      case 'rememberMe': return 'Запомнить меня';
      case 'forgotPassword': return 'Забыли пароль?';
      case 'createAccount': return 'Создать новый аккаунт';
      case 'termsText': return 'Продолжая, вы соглашаетесь с нашими\nУсловиями обслуживания и Политикой конфиденциальности';
      case 'or': return 'или';
      default: return key;
    }
  }

  String _getJapanese(String key) {
    switch (key) {
      case 'loginTitle': return '続行するにはログインしてください';
      case 'emailOrPhone': return 'メールアドレスまたは電話番号';
      case 'password': return 'パスワード';
      case 'rememberMe': return 'ログイン情報を保存';
      case 'forgotPassword': return 'パスワードをお忘れですか？';
      case 'createAccount': return '新しいアカウントを作成';
      case 'termsText': return '続行すると、利用規約とプライバシーポリシーに同意したことになります';
      case 'or': return 'または';
      default: return key;
    }
  }

  String _getChinese(String key) {
    switch (key) {
      case 'loginTitle': return '登录以继续';
      case 'emailOrPhone': return '邮箱或手机号';
      case 'password': return '密码';
      case 'rememberMe': return '记住我';
      case 'forgotPassword': return '忘记密码？';
      case 'createAccount': return '创建新账户';
      case 'termsText': return '继续即表示您同意我们的\n服务条款和隐私政策';
      case 'or': return '或';
      default: return key;
    }
  }

  String _getKorean(String key) {
    switch (key) {
      case 'loginTitle': return '계속하려면 로그인하세요';
      case 'emailOrPhone': return '이메일 또는 전화번호';
      case 'password': return '비밀번호';
      case 'rememberMe': return '로그인 정보 저장';
      case 'forgotPassword': return '비밀번호를 잊으셨나요?';
      case 'createAccount': return '새 계정 만들기';
      case 'termsText': return '계속하면 이용약관 및 개인정보처리방침에 동의하게 됩니다';
      case 'or': return '또는';
      default: return key;
    }
  }

  String _getTurkish(String key) {
    switch (key) {
      case 'loginTitle': return 'Devam etmek için giriş yapın';
      case 'emailOrPhone': return 'E-posta veya Telefon Numarası';
      case 'password': return 'Şifre';
      case 'rememberMe': return 'Beni hatırla';
      case 'forgotPassword': return 'Şifrenizi mi unuttunuz?';
      case 'createAccount': return 'Yeni hesap oluştur';
      case 'termsText': return 'Devam ederek, Hizmet Şartlarımızı ve Gizlilik Politikamızı kabul etmiş olursunuz';
      case 'or': return 'veya';
      default: return key;
    }
  }

  String _getVietnamese(String key) {
    switch (key) {
      case 'loginTitle': return 'Đăng nhập để tiếp tục';
      case 'emailOrPhone': return 'Email hoặc Số điện thoại';
      case 'password': return 'Mật khẩu';
      case 'rememberMe': return 'Ghi nhớ tôi';
      case 'forgotPassword': return 'Quên mật khẩu?';
      case 'createAccount': return 'Tạo tài khoản mới';
      case 'termsText': return 'Tiếp tục, bạn đồng ý với\nĐiều khoản Dịch vụ và Chính sách Bảo mật của chúng tôi';
      case 'or': return 'hoặc';
      default: return key;
    }
  }

  String _getThai(String key) {
    switch (key) {
      case 'loginTitle': return 'เข้าสู่ระบบเพื่อดำเนินการต่อ';
      case 'emailOrPhone': return 'อีเมลหรือหมายเลขโทรศัพท์';
      case 'password': return 'รหัสผ่าน';
      case 'rememberMe': return 'จดจำฉัน';
      case 'forgotPassword': return 'ลืมรหัสผ่าน?';
      case 'createAccount': return 'สร้างบัญชีใหม่';
      case 'termsText': return 'การดำเนินการต่อแสดงว่าคุณยอมรับ\nข้อกำหนดในการให้บริการและนโยบายความเป็นส่วนตัวของเรา';
      case 'or': return 'หรือ';
      default: return key;
    }
  }

  String _getTamil(String key) {
    switch (key) {
      case 'loginTitle': return 'தொடர உள்நுழையவும்';
      case 'emailOrPhone': return 'மின்னஞ்சல் அல்லது தொலைபேசி எண்';
      case 'password': return 'கடவுச்சொல்';
      case 'rememberMe': return 'என்னை நினைவில் கொள்';
      case 'forgotPassword': return 'கடவுச்சொல் மறந்துவிட்டதா?';
      case 'createAccount': return 'புதிய கணக்கு உருவாக்கு';
      case 'termsText': return 'தொடர்வதன் மூலம், எங்களின்\nசேவை விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்';
      case 'or': return 'அல்லது';
      default: return key;
    }
  }

  String _getTelugu(String key) {
    switch (key) {
      case 'loginTitle': return 'కొనసాగించడానికి లాగిన్ చేయండి';
      case 'emailOrPhone': return 'ఇమెయిల్ లేదా ఫోన్ నంబర్';
      case 'password': return 'పాస్వర్డ్';
      case 'rememberMe': return 'నన్ను గుర్తుంచుకో';
      case 'forgotPassword': return 'పాస్వర్డ్ మర్చిపోయారా?';
      case 'createAccount': return 'కొత్త ఖాతా సృష్టించండి';
      case 'termsText': return 'కొనసాగించడం ద్వారా, మా\nసేవా నిబంధనలు మరియు గోప్యతా విధానానికి అంగీకరిస్తున్నారు';
      case 'or': return 'లేదా';
      default: return key;
    }
  }

  String _getMalayalam(String key) {
    switch (key) {
      case 'loginTitle': return 'തുടരാൻ ലോഗിൻ ചെയ്യുക';
      case 'emailOrPhone': return 'ഇമെയിൽ അല്ലെങ്കിൽ ഫോൺ നമ്പർ';
      case 'password': return 'പാസ്വേഡ്';
      case 'rememberMe': return 'എന്നെ ഓർക്കുക';
      case 'forgotPassword': return 'പാസ്വേഡ് മറന്നോ?';
      case 'createAccount': return 'പുതിയ അക്കൗണ്ട് സൃഷ്ടിക്കുക';
      case 'termsText': return 'തുടരുന്നതിലൂടെ, ഞങ്ങളുടെ\nസേവന നിബന്ധനകളും സ്വകാര്യതാ നയവും അംഗീകരിക്കുന്നു';
      case 'or': return 'അല്ലെങ്കിൽ';
      default: return key;
    }
  }

  String _getFilipino(String key) {
    switch (key) {
      case 'loginTitle': return 'Mag-login upang magpatuloy';
      case 'emailOrPhone': return 'Email o Numero ng Telepono';
      case 'password': return 'Password';
      case 'rememberMe': return 'Tandaan ako';
      case 'forgotPassword': return 'Nakalimutan ang password?';
      case 'createAccount': return 'Gumawa ng bagong account';
      case 'termsText': return 'Sa pagpapatuloy, sumasang-ayon ka sa aming\nMga Tuntunin ng Serbisyo at Patakaran sa Privacy';
      case 'or': return 'o';
      default: return key;
    }
  }

  String _getUrdu(String key) {
    switch (key) {
      case 'loginTitle': return 'جاری رکھنے کے لیے لاگ ان کریں';
      case 'emailOrPhone': return 'ای میل یا فون نمبر';
      case 'password': return 'پاس ورڈ';
      case 'rememberMe': return 'مجھے یاد رکھیں';
      case 'forgotPassword': return 'پاس ورڈ بھول گئے؟';
      case 'createAccount': return 'نیا اکاؤنٹ بنائیں';
      case 'termsText': return 'جاری رکھنے سے، آپ ہماری\nخدمت کی شرائط اور رازداری کی پالیسی سے متفق ہیں';
      case 'or': return 'یا';
      default: return key;
    }
  }

  String _getPunjabi(String key) {
    switch (key) {
      case 'loginTitle': return 'ਜਾਰੀ ਰੱਖਣ ਲਈ ਲੌਗਿਨ ਕਰੋ';
      case 'emailOrPhone': return 'ਈਮੇਲ ਜਾਂ ਫੋਨ ਨੰਬਰ';
      case 'password': return 'ਪਾਸਵਰਡ';
      case 'rememberMe': return 'ਮੈਨੂੰ ਯਾਦ ਰੱਖੋ';
      case 'forgotPassword': return 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?';
      case 'createAccount': return 'ਨਵਾਂ ਖਾਤਾ ਬਣਾਓ';
      case 'termsText': return 'ਜਾਰੀ ਰੱਖਣ ਨਾਲ, ਤੁਸੀਂ ਸਾਡੀਆਂ\nਸੇਵਾ ਦੀਆਂ ਸ਼ਰਤਾਂ ਅਤੇ ਗੋਪਨੀਯਤਾ ਨੀਤੀ ਨਾਲ ਸਹਿਮਤ ਹੋ';
      case 'or': return 'ਜਾਂ';
      default: return key;
    }
  }

  String _getKannada(String key) {
    switch (key) {
      case 'loginTitle': return 'ಮುಂದುವರಿಸಲು ಲಾಗಿನ್ ಆಗಿ';
      case 'emailOrPhone': return 'ಇಮೇಲ್ ಅಥವಾ ಫೋನ್ ಸಂಖ್ಯೆ';
      case 'password': return 'ಪಾಸ್ವರ್ಡ್';
      case 'rememberMe': return 'ನನ್ನನ್ನು ನೆನಪಿಡು';
      case 'forgotPassword': return 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರಾ?';
      case 'createAccount': return 'ಹೊಸ ಖಾತೆಯನ್ನು ರಚಿಸಿ';
      case 'termsText': return 'ಮುಂದುವರಿಸುವ ಮೂಲಕ, ನಮ್ಮ\nಸೇವೆಯ ನಿಯಮಗಳು ಮತ್ತು ಗೌಪ್ಯತಾ ನೀತಿಗೆ ಒಪ್ಪುತ್ತೀರಿ';
      case 'or': return 'ಅಥವಾ';
      default: return key;
    }
  }

  String _getGujarati(String key) {
    switch (key) {
      case 'loginTitle': return 'ચાલુ રાખવા માટે લોગિન કરો';
      case 'emailOrPhone': return 'ઇમેઇલ અથવા ફોન નંબર';
      case 'password': return 'પાસવર્ડ';
      case 'rememberMe': return 'મને યાદ રાખો';
      case 'forgotPassword': return 'પાસવર્ડ ભૂલી ગયા?';
      case 'createAccount': return 'નવું ખાતું બનાવો';
      case 'termsText': return 'ચાલુ રાખવાથી, તમે અમારી\nસેવાની શરતો અને ગોપનીયતા નીતિ સાથે સહમત છો';
      case 'or': return 'અથવા';
      default: return key;
    }
  }

  String _getMarathi(String key) {
    switch (key) {
      case 'loginTitle': return 'सुरू ठेवण्यासाठी लॉगिन करा';
      case 'emailOrPhone': return 'ईमेल किंवा फोन नंबर';
      case 'password': return 'पासवर्ड';
      case 'rememberMe': return 'मला लक्षात ठेवा';
      case 'forgotPassword': return 'पासवर्ड विसरलात?';
      case 'createAccount': return 'नवीन खाते तयार करा';
      case 'termsText': return 'सुरू ठेवल्याने, तुम्ही आमच्या\nसेवा अटी आणि गोपनीयता धोरणाशी सहमत आहात';
      case 'or': return 'किंवा';
      default: return key;
    }
  }

  String _getOdia(String key) {
    switch (key) {
      case 'loginTitle': return 'ଜାରି ରଖିବାକୁ ଲଗିନ୍ କରନ୍ତୁ';
      case 'emailOrPhone': return 'ଇମେଲ୍ କିମ୍ବା ଫୋନ୍ ନମ୍ବର';
      case 'password': return 'ପାସୱର୍ଡ';
      case 'rememberMe': return 'ମୋତେ ମନେ ରଖ';
      case 'forgotPassword': return 'ପାସୱର୍ଡ ଭୁଲିଗଲେ?';
      case 'createAccount': return 'ନୂଆ ଆକାଉଣ୍ଟ ତିଆରି କରନ୍ତୁ';
      case 'termsText': return 'ଜାରି ରଖିବା ଦ୍ୱାରା, ଆପଣ ଆମର\nସେବା ସର୍ତ୍ତାବଳୀ ଏବଂ ଗୋପନୀୟତା ନୀତିକୁ ସହମତ ହେଉଛନ୍ତି';
      case 'or': return 'କିମ୍ବା';
      default: return key;
    }
  }

  String _getSwahili(String key) {
    switch (key) {
      case 'loginTitle': return 'Ingia ili kuendelea';
      case 'emailOrPhone': return 'Barua pepe au Nambari ya Simu';
      case 'password': return 'Nenosiri';
      case 'rememberMe': return 'Nikumbuke';
      case 'forgotPassword': return 'Umesahau nenosiri?';
      case 'createAccount': return 'Unda akaunti mpya';
      case 'termsText': return 'Kwa kuendelea, unakubali\nMasharti ya Huduma na Sera ya Faragha yetu';
      case 'or': return 'au';
      default: return key;
    }
  }

  String _getGreek(String key) {
    switch (key) {
      case 'loginTitle': return 'Συνδεθείτε για να συνεχίσετε';
      case 'emailOrPhone': return 'Email ή Αριθμός Τηλεφώνου';
      case 'password': return 'Κωδικός Πρόσβασης';
      case 'rememberMe': return 'Να με θυμάσαι';
      case 'forgotPassword': return 'Ξεχάσατε τον κωδικό πρόσβασης;';
      case 'createAccount': return 'Δημιουργία νέου λογαριασμού';
      case 'termsText': return 'Συνεχίζοντας, συμφωνείτε με τους\nΌρους Παροχής Υπηρεσιών και την Πολιτική Απορρήτου μας';
      case 'or': return 'ή';
      default: return key;
    }
  }

  String _getHebrew(String key) {
    switch (key) {
      case 'loginTitle': return 'התחבר כדי להמשיך';
      case 'emailOrPhone': return 'דוא"ל או מספר טלפון';
      case 'password': return 'סיסמה';
      case 'rememberMe': return 'זכור אותי';
      case 'forgotPassword': return 'שכחת סיסמה?';
      case 'createAccount': return 'צור חשבון חדש';
      case 'termsText': return 'בהמשך, אתה מסכים\nלתנאי השירות ולמדיניות הפרטיות שלנו';
      case 'or': return 'או';
      default: return key;
    }
  }

  String _getPersian(String key) {
    switch (key) {
      case 'loginTitle': return 'برای ادامه وارد شوید';
      case 'emailOrPhone': return 'ایمیل یا شماره تلفن';
      case 'password': return 'رمز عبور';
      case 'rememberMe': return 'مرا به خاطر بسپار';
      case 'forgotPassword': return 'رمز عبور را فراموش کرده‌اید؟';
      case 'createAccount': return 'ایجاد حساب کاربری جدید';
      case 'termsText': return 'با ادامه، شما با\nشرایط خدمات و سیاست حفظ حریم خصوصی ما موافقت می‌کنید';
      case 'or': return 'یا';
      default: return key;
    }
  }
}