class ChatLocalizations {
  final String languageCode;

  ChatLocalizations(this.languageCode);

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
      case 'search': return 'Search';
      case 'notification': return 'Notification';
      case 'qrCode': return 'QR Code';
      case 'noChats': return 'No chats yet';
      case 'startConversation': return 'Start a conversation with your friends';
      case 'searchHint': return 'Search chats';
      case 'chats': return 'Chats';
      case 'friends': return 'Friends';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getBengali(String key) {
    switch (key) {
      case 'search': return 'খুঁজুন';
      case 'notification': return 'বিজ্ঞপ্তি';
      case 'qrCode': return 'QR কোড';
      case 'noChats': return 'কোনো চ্যাট নেই';
      case 'startConversation': return 'আপনার বন্ধুদের সাথে কথোপকথন শুরু করুন';
      case 'searchHint': return 'চ্যাট খুঁজুন';
      case 'chats': return 'চ্যাট';
      case 'friends': return 'বন্ধু';
      case 'feed': return 'ফিড';
      case 'reels': return 'রিলস';
      case 'menu': return 'মেনু';
      default: return key;
    }
  }

  String _getHindi(String key) {
    switch (key) {
      case 'search': return 'खोजें';
      case 'notification': return 'सूचना';
      case 'qrCode': return 'QR कोड';
      case 'noChats': return 'अभी कोई चैट नहीं';
      case 'startConversation': return 'अपने दोस्तों के साथ बातचीत शुरू करें';
      case 'searchHint': return 'चैट खोजें';
      case 'chats': return 'चैट';
      case 'friends': return 'मित्र';
      case 'feed': return 'फीड';
      case 'reels': return 'रील्स';
      case 'menu': return 'मेनू';
      default: return key;
    }
  }

  String _getArabic(String key) {
    switch (key) {
      case 'search': return 'بحث';
      case 'notification': return 'إشعار';
      case 'qrCode': return 'رمز QR';
      case 'noChats': return 'لا توجد محادثات بعد';
      case 'startConversation': return 'ابدأ محادثة مع أصدقائك';
      case 'searchHint': return 'البحث عن محادثات';
      case 'chats': return 'المحادثات';
      case 'friends': return 'الأصدقاء';
      case 'feed': return 'التغذية';
      case 'reels': return 'ريلز';
      case 'menu': return 'القائمة';
      default: return key;
    }
  }

  String _getSpanish(String key) {
    switch (key) {
      case 'search': return 'Buscar';
      case 'notification': return 'Notificación';
      case 'qrCode': return 'Código QR';
      case 'noChats': return 'Sin chats aún';
      case 'startConversation': return 'Inicia una conversación con tus amigos';
      case 'searchHint': return 'Buscar chats';
      case 'chats': return 'Chats';
      case 'friends': return 'Amigos';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menú';
      default: return key;
    }
  }

  String _getFrench(String key) {
    switch (key) {
      case 'search': return 'Rechercher';
      case 'notification': return 'Notification';
      case 'qrCode': return 'Code QR';
      case 'noChats': return 'Pas encore de chats';
      case 'startConversation': return 'Commencez une conversation avec vos amis';
      case 'searchHint': return 'Rechercher des chats';
      case 'chats': return 'Discussions';
      case 'friends': return 'Amis';
      case 'feed': return 'Fil';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getGerman(String key) {
    switch (key) {
      case 'search': return 'Suchen';
      case 'notification': return 'Benachrichtigung';
      case 'qrCode': return 'QR-Code';
      case 'noChats': return 'Noch keine Chats';
      case 'startConversation': return 'Beginne eine Unterhaltung mit deinen Freunden';
      case 'searchHint': return 'Chats durchsuchen';
      case 'chats': return 'Chats';
      case 'friends': return 'Freunde';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menü';
      default: return key;
    }
  }

  String _getItalian(String key) {
    switch (key) {
      case 'search': return 'Cerca';
      case 'notification': return 'Notifica';
      case 'qrCode': return 'Codice QR';
      case 'noChats': return 'Ancora nessuna chat';
      case 'startConversation': return 'Inizia una conversazione con i tuoi amici';
      case 'searchHint': return 'Cerca chat';
      case 'chats': return 'Chat';
      case 'friends': return 'Amici';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getPortuguese(String key) {
    switch (key) {
      case 'search': return 'Pesquisar';
      case 'notification': return 'Notificação';
      case 'qrCode': return 'Código QR';
      case 'noChats': return 'Nenhuma conversa ainda';
      case 'startConversation': return 'Inicie uma conversa com seus amigos';
      case 'searchHint': return 'Pesquisar conversas';
      case 'chats': return 'Conversas';
      case 'friends': return 'Amigos';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getRussian(String key) {
    switch (key) {
      case 'search': return 'Поиск';
      case 'notification': return 'Уведомление';
      case 'qrCode': return 'QR-код';
      case 'noChats': return 'Чатов пока нет';
      case 'startConversation': return 'Начните разговор с друзьями';
      case 'searchHint': return 'Поиск чатов';
      case 'chats': return 'Чаты';
      case 'friends': return 'Друзья';
      case 'feed': return 'Лента';
      case 'reels': return 'Reels';
      case 'menu': return 'Меню';
      default: return key;
    }
  }

  String _getJapanese(String key) {
    switch (key) {
      case 'search': return '検索';
      case 'notification': return '通知';
      case 'qrCode': return 'QRコード';
      case 'noChats': return 'まだチャットはありません';
      case 'startConversation': return '友達と会話を始めましょう';
      case 'searchHint': return 'チャットを検索';
      case 'chats': return 'チャット';
      case 'friends': return '友達';
      case 'feed': return 'フィード';
      case 'reels': return 'リール';
      case 'menu': return 'メニュー';
      default: return key;
    }
  }

  String _getChinese(String key) {
    switch (key) {
      case 'search': return '搜索';
      case 'notification': return '通知';
      case 'qrCode': return '二维码';
      case 'noChats': return '暂无聊天';
      case 'startConversation': return '开始与朋友聊天';
      case 'searchHint': return '搜索聊天';
      case 'chats': return '聊天';
      case 'friends': return '朋友';
      case 'feed': return '动态';
      case 'reels': return 'Reels';
      case 'menu': return '菜单';
      default: return key;
    }
  }

  String _getKorean(String key) {
    switch (key) {
      case 'search': return '검색';
      case 'notification': return '알림';
      case 'qrCode': return 'QR 코드';
      case 'noChats': return '아직 채팅이 없습니다';
      case 'startConversation': return '친구와 대화를 시작하세요';
      case 'searchHint': return '채팅 검색';
      case 'chats': return '채팅';
      case 'friends': return '친구';
      case 'feed': return '피드';
      case 'reels': return '릴스';
      case 'menu': return '메뉴';
      default: return key;
    }
  }

  String _getTurkish(String key) {
    switch (key) {
      case 'search': return 'Ara';
      case 'notification': return 'Bildirim';
      case 'qrCode': return 'QR Kodu';
      case 'noChats': return 'Henüz sohbet yok';
      case 'startConversation': return 'Arkadaşlarınla sohbet başlat';
      case 'searchHint': return 'Sohbetleri ara';
      case 'chats': return 'Sohbetler';
      case 'friends': return 'Arkadaşlar';
      case 'feed': return 'Akış';
      case 'reels': return 'Reels';
      case 'menu': return 'Menü';
      default: return key;
    }
  }

  String _getVietnamese(String key) {
    switch (key) {
      case 'search': return 'Tìm kiếm';
      case 'notification': return 'Thông báo';
      case 'qrCode': return 'Mã QR';
      case 'noChats': return 'Chưa có cuộc trò chuyện nào';
      case 'startConversation': return 'Bắt đầu trò chuyện với bạn bè';
      case 'searchHint': return 'Tìm kiếm cuộc trò chuyện';
      case 'chats': return 'Trò chuyện';
      case 'friends': return 'Bạn bè';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getThai(String key) {
    switch (key) {
      case 'search': return 'ค้นหา';
      case 'notification': return 'การแจ้งเตือน';
      case 'qrCode': return 'รหัส QR';
      case 'noChats': return 'ยังไม่มีแชท';
      case 'startConversation': return 'เริ่มการสนทนากับเพื่อนของคุณ';
      case 'searchHint': return 'ค้นหาแชท';
      case 'chats': return 'แชท';
      case 'friends': return 'เพื่อน';
      case 'feed': return 'ฟีด';
      case 'reels': return 'Reels';
      case 'menu': return 'เมนู';
      default: return key;
    }
  }

  String _getTamil(String key) {
    switch (key) {
      case 'search': return 'தேடு';
      case 'notification': return 'அறிவிப்பு';
      case 'qrCode': return 'QR குறியீடு';
      case 'noChats': return 'இதுவரை அரட்டை இல்லை';
      case 'startConversation': return 'உங்கள் நண்பர்களுடன் உரையாடலைத் தொடங்குங்கள்';
      case 'searchHint': return 'அரட்டைகளைத் தேடு';
      case 'chats': return 'அரட்டைகள்';
      case 'friends': return 'நண்பர்கள்';
      case 'feed': return 'ஊட்டம்';
      case 'reels': return 'ரீல்ஸ்';
      case 'menu': return 'மெனு';
      default: return key;
    }
  }

  String _getTelugu(String key) {
    switch (key) {
      case 'search': return 'వెతకండి';
      case 'notification': return 'నోటిఫికేషన్';
      case 'qrCode': return 'QR కోడ్';
      case 'noChats': return 'ఇంకా చాట్లు లేవు';
      case 'startConversation': return 'మీ స్నేహితులతో సంభాషణ ప్రారంభించండి';
      case 'searchHint': return 'చాట్లను వెతకండి';
      case 'chats': return 'చాట్లు';
      case 'friends': return 'స్నేహితులు';
      case 'feed': return 'ఫీడ్';
      case 'reels': return 'రీల్స్';
      case 'menu': return 'మెనూ';
      default: return key;
    }
  }

  String _getMalayalam(String key) {
    switch (key) {
      case 'search': return 'തിരയുക';
      case 'notification': return 'അറിയിപ്പ്';
      case 'qrCode': return 'QR കോഡ്';
      case 'noChats': return 'ഇതുവരെ ചാറ്റുകൾ ഇല്ല';
      case 'startConversation': return 'നിങ്ങളുടെ സുഹൃത്തുക്കളുമായി സംഭാഷണം ആരംഭിക്കുക';
      case 'searchHint': return 'ചാറ്റുകൾ തിരയുക';
      case 'chats': return 'ചാറ്റുകൾ';
      case 'friends': return 'സുഹൃത്തുക്കൾ';
      case 'feed': return 'ഫീഡ്';
      case 'reels': return 'റീൽസ്';
      case 'menu': return 'മെനു';
      default: return key;
    }
  }

  String _getFilipino(String key) {
    switch (key) {
      case 'search': return 'Maghanap';
      case 'notification': return 'Abiso';
      case 'qrCode': return 'QR Code';
      case 'noChats': return 'Wala pang chats';
      case 'startConversation': return 'Magsimula ng usapan sa iyong mga kaibigan';
      case 'searchHint': return 'Maghanap ng mga chat';
      case 'chats': return 'Mga Chat';
      case 'friends': return 'Mga Kaibigan';
      case 'feed': return 'Feed';
      case 'reels': return 'Reels';
      case 'menu': return 'Menu';
      default: return key;
    }
  }

  String _getUrdu(String key) {
    switch (key) {
      case 'search': return 'تلاش کریں';
      case 'notification': return 'اطلاع';
      case 'qrCode': return 'QR کوڈ';
      case 'noChats': return 'ابھی کوئی چیٹ نہیں';
      case 'startConversation': return 'اپنے دوستوں کے ساتھ گفتگو شروع کریں';
      case 'searchHint': return 'چیٹس تلاش کریں';
      case 'chats': return 'چیٹس';
      case 'friends': return 'دوست';
      case 'feed': return 'فیڈ';
      case 'reels': return 'ریلز';
      case 'menu': return 'مینو';
      default: return key;
    }
  }

  String _getPunjabi(String key) {
    switch (key) {
      case 'search': return 'ਖੋਜੋ';
      case 'notification': return 'ਸੂਚਨਾ';
      case 'qrCode': return 'QR ਕੋਡ';
      case 'noChats': return 'ਅਜੇ ਤੱਕ ਕੋਈ ਚੈਟ ਨਹੀਂ';
      case 'startConversation': return 'ਆਪਣੇ ਦੋਸਤਾਂ ਨਾਲ ਗੱਲਬਾਤ ਸ਼ੁਰੂ ਕਰੋ';
      case 'searchHint': return 'ਚੈਟ ਖੋਜੋ';
      case 'chats': return 'ਚੈਟ';
      case 'friends': return 'ਦੋਸਤ';
      case 'feed': return 'ਫੀਡ';
      case 'reels': return 'ਰੀਲਜ਼';
      case 'menu': return 'ਮੇਨੂ';
      default: return key;
    }
  }

  String _getKannada(String key) {
    switch (key) {
      case 'search': return 'ಹುಡುಕಿ';
      case 'notification': return 'ಸೂಚನೆ';
      case 'qrCode': return 'QR ಕೋಡ್';
      case 'noChats': return 'ಇನ್ನೂ ಚಾಟ್ಗಳಿಲ್ಲ';
      case 'startConversation': return 'ನಿಮ್ಮ ಸ್ನೇಹಿತರೊಂದಿಗೆ ಸಂಭಾಷಣೆ ಪ್ರಾರಂಭಿಸಿ';
      case 'searchHint': return 'ಚಾಟ್ಗಳನ್ನು ಹುಡುಕಿ';
      case 'chats': return 'ಚಾಟ್ಗಳು';
      case 'friends': return 'ಸ್ನೇಹಿತರು';
      case 'feed': return 'ಫೀಡ್';
      case 'reels': return 'ರೀಲ್ಸ್';
      case 'menu': return 'ಮೆನು';
      default: return key;
    }
  }

  String _getGujarati(String key) {
    switch (key) {
      case 'search': return 'શોધો';
      case 'notification': return 'સૂચના';
      case 'qrCode': return 'QR કોડ';
      case 'noChats': return 'હજી સુધી કોઈ ચેટ નથી';
      case 'startConversation': return 'તમારા મિત્રો સાથે વાતચીત શરૂ કરો';
      case 'searchHint': return 'ચેટ્સ શોધો';
      case 'chats': return 'ચેટ્સ';
      case 'friends': return 'મિત્રો';
      case 'feed': return 'ફીડ';
      case 'reels': return 'રીલ્સ';
      case 'menu': return 'મેનુ';
      default: return key;
    }
  }

  String _getMarathi(String key) {
    switch (key) {
      case 'search': return 'शोधा';
      case 'notification': return 'सूचना';
      case 'qrCode': return 'QR कोड';
      case 'noChats': return 'अजून चॅट नाहीत';
      case 'startConversation': return 'तुमच्या मित्रांसोबत संभाषण सुरू करा';
      case 'searchHint': return 'चॅट शोधा';
      case 'chats': return 'चॅट';
      case 'friends': return 'मित्र';
      case 'feed': return 'फीड';
      case 'reels': return 'रील्स';
      case 'menu': return 'मेनू';
      default: return key;
    }
  }

  String _getOdia(String key) {
    switch (key) {
      case 'search': return 'ଖୋଜନ୍ତୁ';
      case 'notification': return 'ସୂଚନା';
      case 'qrCode': return 'QR କୋଡ୍';
      case 'noChats': return 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ଚାଟ୍ ନାହିଁ';
      case 'startConversation': return 'ଆପଣଙ୍କ ବନ୍ଧୁମାନଙ୍କ ସହିତ କଥାବାର୍ତ୍ତା ଆରମ୍ଭ କରନ୍ତୁ';
      case 'searchHint': return 'ଚାଟ୍ ଖୋଜନ୍ତୁ';
      case 'chats': return 'ଚାଟ୍';
      case 'friends': return 'ବନ୍ଧୁ';
      case 'feed': return 'ଫିଡ୍';
      case 'reels': return 'ରୀଲ୍ସ';
      case 'menu': return 'ମେନୁ';
      default: return key;
    }
  }

  String _getSwahili(String key) {
    switch (key) {
      case 'search': return 'Tafuta';
      case 'notification': return 'Arifa';
      case 'qrCode': return 'Msimbo wa QR';
      case 'noChats': return 'Hakuna mazungumzo bado';
      case 'startConversation': return 'Anza mazungumzo na marafiki zako';
      case 'searchHint': return 'Tafuta mazungumzo';
      case 'chats': return 'Mazungumzo';
      case 'friends': return 'Marafiki';
      case 'feed': return 'Mlisho';
      case 'reels': return 'Reels';
      case 'menu': return 'Menyu';
      default: return key;
    }
  }

  String _getGreek(String key) {
    switch (key) {
      case 'search': return 'Αναζήτηση';
      case 'notification': return 'Ειδοποίηση';
      case 'qrCode': return 'Κωδικός QR';
      case 'noChats': return 'Δεν υπάρχουν ακόμη συνομιλίες';
      case 'startConversation': return 'Ξεκινήστε μια συνομιλία με τους φίλους σας';
      case 'searchHint': return 'Αναζήτηση συνομιλιών';
      case 'chats': return 'Συνομιλίες';
      case 'friends': return 'Φίλοι';
      case 'feed': return 'Ροή';
      case 'reels': return 'Reels';
      case 'menu': return 'Μενού';
      default: return key;
    }
  }

  String _getHebrew(String key) {
    switch (key) {
      case 'search': return 'חיפוש';
      case 'notification': return 'הודעה';
      case 'qrCode': return 'קוד QR';
      case 'noChats': return 'אין עדיין צ\'אטים';
      case 'startConversation': return 'התחל שיחה עם החברים שלך';
      case 'searchHint': return 'חיפוש צ\'אטים';
      case 'chats': return 'צ\'אטים';
      case 'friends': return 'חברים';
      case 'feed': return 'פיד';
      case 'reels': return 'רילס';
      case 'menu': return 'תפריט';
      default: return key;
    }
  }

  String _getPersian(String key) {
    switch (key) {
      case 'search': return 'جستجو';
      case 'notification': return 'اعلان';
      case 'qrCode': return 'کد QR';
      case 'noChats': return 'هنوز چتی وجود ندارد';
      case 'startConversation': return 'با دوستان خود گفتگو را شروع کنید';
      case 'searchHint': return 'جستجوی چت‌ها';
      case 'chats': return 'چت‌ها';
      case 'friends': return 'دوستان';
      case 'feed': return 'فید';
      case 'reels': return 'ریلز';
      case 'menu': return 'منو';
      default: return key;
    }
  }
}