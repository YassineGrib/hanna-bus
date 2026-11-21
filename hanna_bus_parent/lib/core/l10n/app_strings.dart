import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings(this.locale);
  final Locale locale;

  static AppStrings of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return AppStrings(locale);
  }

  String get code => locale.languageCode;
  bool get isAr => code == 'ar';
  bool get isArabic => isAr;
  bool get isFr => code == 'fr';

  String tr(String en, String ar, String fr) {
    if (isAr) return ar;
    if (isFr) return fr;
    return en;
  }

  // Brand & Core Navigation
  String get appTitle => tr('Hanna Bus Parent', 'حنّة باص للوالدين', 'Hanna Bus Parent');
  String get navHome => tr('Home', 'الرئيسية', 'Accueil');
  String get navTrack => tr('Track', 'التتبع', 'Suivi');
  String get navChildren => tr('Children', 'الأبناء', 'Enfants');
  String get navProfile => tr('Profile', 'الحساب', 'Profil');
  String get offlineBanner => tr(
        'Offline preview active: syncing live updates when backend reconnects',
        'وضع العرض المحلي نشط: ستتم المزامنة فور عودة الخادم',
        'Mode apercu hors ligne actif: synchronisation des la reconnexion',
      );

  // Language & Theme Labels
  String get langEnglish => 'English';
  String get langArabic => 'العربية';
  String get langFrench => 'Francais';
  String get paletteMustard => tr('Mustard Gold', 'الذهبي الدافئ', 'Or Moutarde');
  String get paletteTealGray => tr('Teal Gray', 'الرمادي المخضر', 'Gris Sarcelle');
  String get paletteOcean => tr('Ocean Blue', 'أزرق المحيط', 'Bleu Ocean');
  String get modeLight => tr('Light', 'فاتح', 'Clair');
  String get modeDark => tr('Dark', 'داكن', 'Sombre');

  // Common Actions & States
  String get back => tr('Back', 'رجوع', 'Retour');
  String get save => tr('Save Changes', 'حفظ التغييرات', 'Enregistrer');
  String get cancel => tr('Cancel', 'إلغاء', 'Annuler');
  String get retry => tr('Retry', 'إعادة المحاولة', 'Reessayer');
  String get close => tr('Close', 'إغلاق', 'Fermer');
  String get next => tr('Next', 'التالي', 'Suivant');
  String get skip => tr('Skip', 'تخطي', 'Passer');
  String get done => tr('Done', 'تم', 'Termine');
  String get confirm => tr('Confirm', 'تأكيد', 'Confirmer');
  String get deleteWord => tr('DELETE', 'حذف', 'SUPPRIMER');
  String get loading => tr('Loading...', 'جاري التحميل...', 'Chargement...');
  String get all => tr('All', 'الكل', 'Tout');
  String get callNow => tr('Call', 'اتصال', 'Appeler');
  String get selectChildHint => tr('Switch Child', 'تبديل الطفل', 'Changer d enfant');

  // Auth & Onboarding (Module 01)
  String get welcomeTitle1 => tr('Welcome to', 'أهلاً بك في', 'Bienvenue sur');
  String get welcomeTitle2 => tr('Hanna Bus', 'هنّا باص', 'Hanna Bus');
  String get welcomeSubtitle => tr(
        'Safe school rides, tracked live.',
        'رحلات مدرسية آمنة، وتتبّع مباشر.',
        'Trajets scolaires sûrs, suivis en direct.',
      );
  String get continueAction => tr('Continue', 'متابعة', 'Continuer');

  // Exact FigCraft Module 01 Strings
  String get signInTitle1 => tr('Welcome back', 'مرحبًا بعودتك', 'Bon retour');
  String get signInTitle2 => tr('to Hanna Bus', 'إلى هنّا باص', 'sur Hanna Bus');
  String get signInSubtitleExact => tr(
        "Track your child's bus in real time.",
        'تابع حافلة طفلك لحظة بلحظة.',
        'Suivez le bus de votre enfant en direct.',
      );
  String get emailExact => tr('Email', 'البريد الإلكتروني', 'E-mail');
  String get emailPlaceholder => 'name@example.com';
  String get passwordExact => tr('Password', 'كلمة المرور', 'Mot de passe');
  String get passwordPlaceholder => tr('Enter your password', 'أدخل كلمة المرور', 'Entrez votre mot de passe');
  String get forgotPasswordExact => tr('Forgot password?', 'نسيت كلمة المرور؟', 'Mot de passe oublié ?');
  String get signInExact => tr('Sign in', 'تسجيل الدخول', 'Se connecter');
  String get orDivider => tr('or', 'أو', 'ou');
  String get newToHannaQ => tr('New to Hanna Bus?', 'جديد في هنّا باص؟', 'Nouveau sur Hanna Bus ?');
  String get createAccountLink => tr('Create account', 'إنشاء حساب', 'Créer un compte');

  String get signUpTitle1 => tr('Create your', 'أنشئ', 'Créez votre');
  String get signUpTitle2 => tr('Hanna Bus account', 'حسابك في هنّا باص', 'compte Hanna Bus');
  String get signUpSubtitle => tr(
        'Set up your family in a minute.',
        'جهّز عائلتك في دقيقة واحدة.',
        'Configurez votre famille en une minute.',
      );
  String get parentName => tr('Parent name', 'اسم ولي الأمر', 'Nom du parent');
  String get parentNamePlaceholder => tr('Parent name', 'اسمك الكامل', 'Nom du parent');
  String get passwordPlaceholder8 => tr('At least 8 characters', '8 أحرف على الأقل', 'Au moins 8 caractères');
  String get termsNotice => tr(
        'By continuing you agree to the Terms and Privacy Policy.',
        'بالمتابعة، أنت توافق على الشروط وسياسة الخصوصية.',
        'En continuant, vous acceptez les Conditions et la Politique de confidentialité.',
      );
  String get haveAccountQ => tr('Already have an account?', 'لديك حساب بالفعل؟', 'Vous avez déjà un compte ?');

  String get recoveryTitle1 => tr('Forgot', 'هل نسيت', 'Mot de passe');
  String get recoveryTitle2 => tr('your password?', 'كلمة المرور؟', 'oublié ?');
  String get recoverySubtitle => tr(
        'Enter your email and we will send you a 6-digit verification code.',
        'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّنًا من 6 أرقام.',
        'Entrez votre e-mail et nous vous enverrons un code de vérification à 6 chiffres.',
      );
  String get sendVerificationCode => tr('Send verification code', 'إرسال رمز التحقق', 'Envoyer le code');
  String get rememberedQ => tr('Remembered it?', 'تذكّرتها؟', 'Vous vous en souvenez ?');
  String get backToSignIn => tr('Back to sign in', 'العودة لتسجيل الدخول', 'Retour à la connexion');

  String get otpTitle1 => tr('Verify your', 'تحقّق من', 'Vérifiez votre');
  String get otpTitle2 => tr('email address', 'بريدك الإلكتروني', 'adresse e-mail');
  String get otpSubtitle => tr(
        'We sent a 6-digit code to k.mansouri@mail.dz',
        'أرسلنا رمزًا من 6 أرقام إلى k.mansouri@mail.dz',
        'Nous avons envoyé un code à 6 chiffres à k.mansouri@mail.dz',
      );
  String get otpTimer => tr('Resend code in 00:45', 'إعادة إرسال الرمز خلال 00:45', 'Renvoyer le code dans 00:45');
  String get otpButton => tr('Verify & continue', 'تأكيد ومتابعة', 'Vérifier et continuer');
  String get otpWrongEmail => tr('Wrong email?', 'البريد غير صحيح؟', 'Mauvais e-mail ?');
  String get otpChangeAddress => tr('Change address', 'تغيير العنوان', 'Changer d\'adresse');

  String get resetTitle1 => tr('Create a', 'تعيين', 'Créer un');
  String get resetTitle2 => tr('new password', 'كلمة مرور جديدة', 'nouveau mot de passe');
  String get resetSubtitle => tr(
        'Choose a strong password you have not used before.',
        'اختر كلمة مرور قوية لم تستخدمها من قبل لحماية حساب عائلتك.',
        'Choisissez un mot de passe fort que vous n\'avez jamais utilisé auparavant.',
      );
  String get newPasswordLabel => tr('New password', 'كلمة المرور الجديدة', 'Nouveau mot de passe');
  String get confirmPasswordLabelExact => tr('Confirm password', 'تأكيد كلمة المرور', 'Confirmer le mot de passe');
  String get reqTitle => tr('Password requirements', 'متطلبات كلمة المرور', 'Exigences du mot de passe');
  String get req1 => tr('At least 8 characters', '8 أحرف على الأقل', 'Au moins 8 caractères');
  String get req2 => tr('Contains a number (0-9)', 'تحتوي على رقم واحد على الأقل (0-9)', 'Contient un chiffre (0-9)');
  String get req3 => tr('One uppercase & symbol', 'حرف كبير أو رمز خاص', 'Une majuscule et un symbole');
  String get resetPasswordButton => tr('Update password', 'تحديث كلمة المرور', 'Mettre à jour le mot de passe');

  String get okBadge => tr('Verified & Secured', 'حساب موثّق وآمن', 'Vérifié et sécurisé');
  String get okTitle1 => tr('You are', 'تم الإعداد', 'Tout est');
  String get okTitle2 => tr('all set!', 'بنجاح!', 'prêt !');
  String get okSubtitle => tr(
        'Your Hanna Bus parent account is ready. Start tracking your children\'s school rides live.',
        'حساب ولي الأمر في هنّا باص جاهز الآن. يمكنك متابعة رحلات أطفالك المدرسية مباشرة.',
        'Votre compte parent Hanna Bus est prêt. Commencez à suivre les trajets de vos enfants en direct.',
      );
  String get okCardTitle => tr('Linked Family Account', 'حساب العائلة المرتبط', 'Compte famille lié');
  String get okCardSubtitle => tr('k.mansouri@mail.dz · Parent Portal', 'k.mansouri@mail.dz · بوابة أولياء الأمور', 'k.mansouri@mail.dz · Portail parent');
  String get okButton => tr('Go to Hanna Bus', 'الانتقال إلى هنّا باص', 'Accéder à Hanna Bus');

  String get splashTagline => tr(
        'Safe school rides, tracked step by step.',
        'رحلات مدرسية آمنة، بتتبع لحظي وخطوة بخطوة.',
        'Trajets scolaires surs, suivis etape par etape.',
      );
  String get onboardingTitle1 => tr(
        'Live GPS School Bus Tracking',
        'تتبع مباشر لحافلة المدرسة',
        'Suivi GPS du bus en direct',
      );
  String get onboardingBody1 => tr(
        'Follow your child from home stop to school gate with live ETA and corridor progress.',
        'تابع رحلة طفلك من محطة الحي حتى بوابة المدرسة مع وقت الوصول المتوقع.',
        'Suivez votre enfant de l arret au portail avec heure d arrivee estimee.',
      );
  String get onboardingTitle2 => tr(
        'Instant QR Boarding Proof',
        'توثيق الصعود برمز QR فوري',
        'Preuve d embarquement par QR',
      );
  String get onboardingBody2 => tr(
        'Every scan at pickup and dismissal confirms exactly who handed over your child.',
        'كل مسح عند الصعود والنزول يؤكد وقت الاستلام وهوية المشرف بدقة.',
        'Chaque scan confirme l heure et la personne ayant remis votre enfant.',
      );
  String get onboardingTitle3 => tr(
        'Smart Alerts & One-Tap Absence',
        'تنبيهات ذكية وإبلاغ غياب بلمسة واحدة',
        'Alertes intelligentes et absence rapide',
      );
  String get onboardingBody3 => tr(
        'Set custom stop proximity alerts and notify drivers early if your child stays home.',
        'حدد مسافة التنبيه المفضلة وأبلغ السائق مبكرا عند غياب طفلك ليوم دراسي.',
        'Reglez le rayon d alerte et prevenez le chauffeur en un geste.',
      );
  String get getStarted => tr('Get Started', 'ابدأ الآن', 'Commencer');
  String get signInTitle => tr('Welcome back, parent', 'مرحبا بعودتك', 'Bon retour, parent');
  String get signInSubtitle => tr(
        'Sign in with your school transport account to track today runs.',
        'سجل الدخول بحساب النقل المدرسي لمتابعة رحلات اليوم.',
        'Connectez-vous pour suivre les trajets scolaires du jour.',
      );
  String get signInButton => tr('Sign In', 'تسجيل الدخول', 'Se connecter');
  String get useDemoAccount => tr('Fill Demo Credentials', 'تعبئة بيانات التجربة', 'Remplir compte demo');
  String get emailLabel => tr('Email address', 'البريد الإلكتروني', 'Adresse e-mail');
  String get passwordLabel => tr('Password', 'كلمة المرور', 'Mot de passe');
  String get fullNameLabel => tr('Full name', 'الاسم الكامل', 'Nom complet');
  String get phoneLabel => tr('Phone number', 'رقم الهاتف', 'Numero de telephone');
  String get forgotPasswordLink => tr('Forgot password?', 'نسيت كلمة المرور؟', 'Mot de passe oublie ?');
  String get noAccountPrompt => tr('New family on Hanna Bus?', 'عائلة جديدة في حنّة باص؟', 'Nouvelle famille sur Hanna Bus ?');
  String get createAccount => tr('Create Account', 'إنشاء حساب', 'Creer un compte');
  String get registerSubtitle => tr(
        'Register as a parent and link your children with school student codes.',
        'أنشئ حساب ولي الأمر واربط أبناءك برمز الطالب المرسل من المدرسة.',
        'Inscrivez-vous en tant que parent et liez vos enfants via leur code.',
      );
  String get haveAccountPrompt => tr('Already registered?', 'لديك حساب مسبقا؟', 'Deja inscrit ?');
  String get forgotTitle => tr('Reset your password', 'استعادة كلمة المرور', 'Reinitialiser le mot de passe');
  String get forgotBody => tr(
        'Enter your parent email and we will prepare a 6-digit verification code.',
        'أدخل بريدك الإلكتروني لإرسال رمز تحقق من 6 أرقام.',
        'Entrez votre e-mail parent pour recevoir un code a 6 chiffres.',
      );
  String get sendCode => tr('Send 6-Digit Code', 'إرسال رمز التحقق', 'Envoyer le code');
  String get otpTitle => tr('Verify 6-digit code', 'أدخل رمز التحقق', 'Verifier le code a 6 chiffres');
  String get otpHintDemo => tr('Demo code pre-validated: 482910', 'رمز التجربة الجاهز: 482910', 'Code demo pret: 482910');
  String get verifyCode => tr('Verify Code', 'تحقق من الرمز', 'Verifier le code');
  String get newPasswordTitle => tr('Choose new password', 'اختر كلمة مرور جديدة', 'Nouveau mot de passe');
  String get confirmPasswordLabel => tr('Confirm password', 'تأكيد كلمة المرور', 'Confirmer le mot de passe');
  String get savePassword => tr('Update Password & Enter', 'حفظ كلمة المرور والدخول', 'Enregistrer et entrer');
  String get linkChildOnboardingTitle => tr('Link a child by code', 'ربط طالب برمز المدرسة', 'Lier un enfant par code');
  String get linkChildOnboardingBody => tr(
        'Optional: enter school code HB-2026-9911 or continue straight to your home dashboard.',
        'اختياري: أدخل رمز المدرسة HB-2026-9911 أو انتقل مباشرة للرئيسية.',
        'Optionnel: entrez le code HB-2026-9911 ou continuez vers l accueil.',
      );
  String get studentCodeLabel => tr('Student code (e.g. HB-2026-9911)', 'رمز الطالب (مثال HB-2026-9911)', 'Code eleve (ex. HB-2026-9911)');
  String get linkChildAction => tr('Link Child Now', 'ربط الطالب الآن', 'Lier l enfant');
  String get continueToHome => tr('Continue to Home', 'المتابعة للرئيسية', 'Aller a l accueil');

  // Home Dashboard (Module 06)
  String get goodMorning => tr('Morning safety hub', 'مركز الأمان الصباحي', 'Tableau de securite matin');
  String get activeBusRide => tr('Live Bus 04 Run', 'رحلة الحافلة 04 المباشرة', 'Bus 04 en direct');
  String get trackLiveCta => tr('Track Live', 'تتبع مباشر', 'Suivre en direct');
  String get quickQrPass => tr('QR Gate Pass', 'بطاقة QR', 'Pass QR');
  String get quickCallDriver => tr('Call Driver', 'اتصال بالسائق', 'Appeler chauffeur');
  String get quickReportAbsence => tr('Report Absence', 'إبلاغ غياب', 'Signaler absence');
  String get quickResumeRide => tr('Resume Ride', 'استئناف الرحلة', 'Reprendre trajet');
  String get quickUpdates => tr('Updates & Help', 'الأخبار والدعم', 'Actus & Aide');
  String get todayFamilyRides => tr('Family boarding status', 'حالة أبنائك اليوم', 'Statut familial du jour');
  String get seeHistory => tr('Trip History', 'سجل الرحلات', 'Historique');
  String get alertsTitle => tr('Safety Alerts', 'تنبيهات السلامة', 'Alertes securite');
  String get markAllRead => tr('Mark all read', 'تعيين الكل مقروء', 'Tout marquer lu');
  String get qrPassTitle => tr('Parent Handover QR Pass', 'بطاقة التسليم الآمن QR', 'Pass QR de remise securisee');
  String get qrPassBody => tr(
        'Present this encrypted code at pickup or dismissal. Saved offline for low-signal gates.',
        'أبرز هذا الرمز للمشرف عند البوابة أو المحطة. محفوظ محليا للعمل دون شبكة.',
        'Presentez ce QR au chauffeur ou portail. Sauvegarde hors ligne.',
      );
  String get updatesTitle => tr('School Bulletins & Support', 'نشرات المدرسة والتواصل', 'Infos ecole & Support');
  String get messageDriverTab => tr('Driver', 'السائق', 'Chauffeur');
  String get messageCoordinatorTab => tr('Coordinator', 'المنسق', 'Coordinateur');
  String get sendMessage => tr('Send Message', 'إرسال الرسالة', 'Envoyer le message');
  String get messagePlaceholder => tr(
        'Write a quick pickup note (e.g. Grandma waits at Stop 04)...',
        'اكتب ملاحظة سريعة للسائق أو المنسق...',
        'Ecrivez un message rapide au chauffeur ou coordinateur...',
      );

  // Driver Messages Thread (Feature addition)
  String get driverThreadTitle =>
      tr('Driver Chat', 'محادثة السائق', 'Discussion Chauffeur');
  String get driverSubtitle =>
      tr('Bus Driver', 'سائق الحافلة', 'Chauffeur du bus');
  String get messageDriverAction => tr('Message', 'مراسلة', 'Message');
  String get openDriverThread => tr(
    'Open Driver Thread',
    'فتح محادثة السائق',
    'Ouvrir discussion chauffeur',
  );
  String get driverConversationCardTitle =>
      tr('Driver Messages', 'رسائل السائق', 'Messages du chauffeur');
  String get quickReplyWait => tr(
    'Please wait for me',
    'يرجى الانتظار، نحن قادمون',
    'Veuillez m’attendre',
  );
  String get quickReplyAbsent => tr(
    'My child is absent today',
    'طفلي غائب اليوم',
    'Mon enfant est absent aujourd’hui',
  );
  String get quickReplyThankYou => tr('Thank you', 'شكرا لك', 'Merci');
  String get quickReplyAtStop =>
      tr('We are at the stop', 'نحن في المحطة الآن', 'Nous sommes à l’arrêt');
  String get typeMessagePlaceholder =>
      tr('Type a message...', 'اكتب رسالة...', 'Ecrivez un message...');
  String get emptyThreadTitle =>
      tr('No messages yet', 'لا توجد رسائل بعد', 'Aucun message');
  String get emptyThreadSubtitle => tr(
    'Send a message or use quick replies below to reach the driver.',
    'أرسل رسالة أو اختر ردًا سريعًا للتواصل مع السائق.',
    'Envoyez un message ou utilisez une reponse rapide.',
  );

  String get driverMessagesLoadError => tr(
    'Could not load messages. Please try again.',
    'تعذر تحميل الرسائل. حاول مجددًا.',
    'Impossible de charger les messages. Réessayez.',
  );
  String get driverMessageSendError => tr(
    'Message could not be sent. Please try again.',
    'تعذر إرسال الرسالة. حاول مجددًا.',
    'Envoi impossible. Réessayez.',
  );
  String get driverMessageTooShort => tr(
    'Enter at least 3 characters before sending.',
    'اكتب 3 أحرف على الأقل قبل الإرسال.',
    'Écrivez au moins 3 caractères.',
  );

  // Clean Empty State for Active Trip (when no children linked)
  String get noActiveTripEmptyTitle => tr(
    'Link your child to follow the bus',
    'اربط حساب طفلك لمتابعة الحافلة',
    'Liez votre enfant pour suivre le bus',
  );
  String get noActiveTripEmptySubtitle => tr(
    'Add your child using their student code to follow the bus in real time.',
    'أضف طفلك باستخدام رمز الطالب لمتابعة الحافلة مباشرة.',
    'Ajoutez votre enfant avec son code élève pour suivre le bus en direct.',
  );

  // Tracking & Analytics (Module 05)
  String get liveTrackingTitle => tr('Live Bus Tracking', 'التتبع المباشر للحافلة', 'Suivi bus en direct');
  String get historyTab => tr('History', 'السجل', 'Historique');
  String get analyticsTab => tr('Analytics', 'التحليلات', 'Analyses');
  String get driverAndVehicle => tr('Driver & Bus Telemetry', 'السائق ومؤشرات الحافلة', 'Chauffeur & Telemetrie');
  String get routeTimeline => tr('Corridor Timeline', 'مسار المحطات', 'Chronologie du trajet');
  String get tripHistoryTitle => tr('Trip History', 'سجل الرحلات', 'Historique des trajets');
  String get periodMorning => tr('Morning', 'الصباح', 'Matin');
  String get periodReturn => tr('Return', 'العودة', 'Retour');
  String get tripReplayTitle => tr('Trip Replay & QR Audit', 'إعادة عرض الرحلة وتدقيق QR', 'Replay trajet & Audit QR');
  String get attendanceTitle => tr('Attendance & Punctuality', 'الحضور والانضباط الشهري', 'Assiduite & Ponctualite');
  String get reportAbsenceBanner => tr(
        'Will your child miss the bus today?',
        'هل سيغيب طفلك عن الحافلة اليوم؟',
        'Votre enfant manquera-t-il le bus aujourd hui ?',
      );
  String get confirmAbsenceAction => tr('Confirm Absence Today', 'تأكيد الغياب اليوم', 'Confirmer absence');
  String get cancelAbsenceAction => tr('Resume Scheduled Ride', 'إلغاء الغياب واستئناف الرحلة', 'Annuler absence');

  // Page 05 Tracking Strings (FigCraft 1:1)
  String get trMapTitle => tr('Live Tracking', 'التتبّع المباشر', 'Suivi en direct');
  String get trGpsPill => tr('LIVE GPS · 4s ago', 'مباشر GPS · منذ 4 ث', 'GPS DIRECT · il y a 4s');
  String get trEtaTitle => tr('Arriving at School in 4 min', 'الوصول للمدرسة خلال 4 دقائق', 'Arrivée à l\'école dans 4 min');
  String get trEtaSub => tr('1.2 km remaining · Moving on Blvd des Martyrs', 'المتبقي 1.2 كم · تسير في شارع الشهداء', '1.2 km restants · Sur le Blvd des Martyrs');
  String get trSt1 => tr('07:16 Boarded', '07:16 صعد', '07h16 Monté');
  String get trSt2 => tr('07:34 En Route', '07:34 في المسار', '07h34 En route');
  String get trSt3 => tr('07:40 School', '07:40 المدرسة', '07h40 École');
  String get trDrvNameDefault => tr('Bus 04 · Ahmed Benali', 'الحافلة 04 · أحمد بن علي', 'Bus 04 · Ahmed Benali');
  String get trDrvSubDefault => tr('Plate 04821-116 · Seat A2 Verified', 'لوحة 116-04821 · مقعد A2 موثّق', 'Plaque 04821-116 · Siège A2 vérifié');
  String get trBtnCall => tr('Call', 'اتصال', 'Appeler');

  // Screen 1: Live Route Timeline
  String get trRtTitle => tr('Live Route Stops', 'مسار المحطات المباشر', 'Arrêts du trajet en direct');
  String get trRtBannerT => tr('Morning Route 04', 'مسار الصباح · حافلة 04', 'Ligne 04 · Trajet Matin');
  String get trRtBannerS => tr('Hay El Nasr → El Wiam School', 'حي النصر ← ابتدائية الوئام', 'Hay El Nasr → École El Wiam');
  String get trRtOnTime => tr('On Time', 'في الموعد', 'À l\'heure');
  String get trM1K => tr('Speed', 'السرعة', 'Vitesse');
  String get trM2K => tr('Next Stop', 'المحطة القادمة', 'Prochain arrêt');
  String get trM3K => tr('Onboard', 'الركاب', 'À bord');
  String get trRtSec => tr('Stop-by-Stop Live Progress', 'تقدّم المحطات لحظة بلحظة', 'Progression arrêt par arrêt');
  String get trSp1T => tr('07:05 AM · Central Depot', '07:05 ص · المستودع المركزي', '07h05 · Dépôt central');
  String get trSp1S => tr('Departed on schedule', 'انطلقت في الموعد المحدّد', 'Parti à l\'heure');
  String get trSp2T => tr('07:16 AM · Hay El Nasr (Stop 03)', '07:16 ص · حي النصر (محطة 03)', '07h16 · Hay El Nasr (Arrêt 03)');
  String get trSp2S => tr('Youssef boarded · QR #HB-304', 'صعد يوسف · مسح البطاقة #HB-304', 'Youssef est monté · QR #HB-304');
  String get trSp3T => tr('07:28 AM · Algiers Square', '07:28 ص · ساحة الجزائر', '07h28 · Place d\'Alger');
  String get trSp3S => tr('3 students boarded', 'صعود 3 تلاميذ', '3 élèves montés');
  String get trSp4T => tr('07:34 AM · Blvd des Martyrs', '07:34 ص · شارع الشهداء', '07h34 · Blvd des Martyrs');
  String get trSp4S => tr('LIVE NOW · Bus 04 is passing here', 'الآن مباشر · الحافلة 04 تمرّ من هنا', 'EN DIRECT · Le Bus 04 passe ici');
  String get trSp5T => tr('07:40 AM · El Wiam Primary Gate', '07:40 ص · بوابة مدرسة الوئام', '07h40 · Portail Primaire El Wiam');
  String get trSp5S => tr('Destination · East Student Gate', 'الوجهة النهائية · البوابة الشرقية', 'Destination · Portail Est');
  String get trRtShare => tr('Share live trip link', 'مشاركة رابط الرحلة المباشر', 'Partager le lien du trajet');

  // Screen 2: Live Boarding Alerts
  String get trAlTitle => tr('Live Ride Alerts', 'تنبيهات الرحلة المباشرة', 'Alertes du trajet en direct');
  String get trAlGeoT => tr('School Zone Geofence Active', 'نطاق أمان المدرسة مفعّل', 'Périmètre de sécurité école actif');
  String get trAlGeoS => tr('400m safety radius · Instant arrival check-in', 'نصف قطر 400 متر · إشعار فوري عند الوصول', 'Rayon 400m · Notification instantanée');
  String get trAlSec => tr('Today\'s Live Telemetry Feed', 'سجل أحداث الرحلة الجارية اليوم', 'Flux télémétrique du jour');
  String get trEv1T => tr('Approaching School Gate (4 min)', 'اقتراب من بوابة المدرسة (4 د)', 'Approche du portail école (4 min)');
  String get trEv1S => tr('07:36 AM · Bus 04 entered El Wiam zone', '07:36 ص · دخلت الحافلة 04 نطاق مدرسة الوئام', '07h36 · Le Bus 04 est entré dans la zone El Wiam');
  String get trEv2T => tr('QR Boarding Confirmed', 'تأكيد صعود الطفل ببطاقة QR', 'Montée QR confirmée');
  String get trEv2S => tr('07:16 AM · Youssef scanned at Stop 03 (Seat A2)', '07:16 ص · مسح بطاقة يوسف في محطة 03 (مقعد A2)', '07h16 · Youssef scanné à l\'Arrêt 03 (Siège A2)');
  String get trEv3T => tr('Bus Approaching Home Stop', 'الحافلة تقترب من محطة المنزل', 'Le bus approche de votre arrêt');
  String get trEv3S => tr('07:11 AM · Driver Ahmed B. is 5 min away', '07:11 ص · السائق أحمد ب. على بُعد 5 دقائق', '07h11 · Le chauffeur Ahmed B. est à 5 min');
  String get trEv4T => tr('Morning Route 04 Started', 'بدء رحلة الصباح للمسار 04', 'Départ Ligne 04 Matin');
  String get trEv4S => tr('07:05 AM · Departed depot · Traffic clear', '07:05 ص · الانطلاق من المركز · الطريق سالك', '07h05 · Dépôt quitté · Trafic fluide');
  String get trAlBtn => tr('Configure alert radius', 'ضبط مسافة التنبيه المسبق', 'Configurer le rayon d\'alerte');

  // Screen 3: Trip History
  String get trHsTitle => tr('Trip History', 'سجل الرحلات السابقة', 'Historique des trajets');
  String get trHfAll => tr('All (42)', 'الكل (42)', 'Tous (42)');
  String get trHfAm => tr('Morning (21)', 'الصباح (21)', 'Matin (21)');
  String get trHfPm => tr('Return (21)', 'العودة (21)', 'Retour (21)');
  String get trHk1K => tr('Rides', 'رحلة مكتملة', 'Trajets');
  String get trHk2K => tr('QR Scans', 'مسح QR', 'Scans QR');
  String get trHk3K => tr('On-Time', 'انضباط الموعد', 'Ponctualité');
  String get trHsD1 => tr('Yesterday · Mon 09 Nov', 'أمس · الإثنين 09 نوفمبر', 'Hier · Lun 09 Nov');
  String get trH1T => tr('Afternoon Return · Bus 04', 'رحلة العودة · الحافلة 04', 'Retour après-midi · Bus 04');
  String get trH1S => tr('03:22 PM School → 03:46 PM Home (24m)', '03:22 م المدرسة ← 03:46 م المنزل (24 د)', '15h22 École → 15h46 Domicile (24m)');
  String get trH1B => tr('Completed', 'مكتملة', 'Complété');
  String get trH2T => tr('Morning Pickup · Bus 04', 'رحلة الصباح · الحافلة 04', 'Ramassage matin · Bus 04');
  String get trH2S => tr('07:15 AM Home → 07:39 AM School (24m)', '07:15 ص المنزل ← 07:39 ص المدرسة (24 د)', '07h15 Domicile → 07h39 École (24m)');
  String get trHsD2 => tr('Sun 08 Nov', 'الأحد 08 نوفمبر', 'Dim 08 Nov');
  String get trH3T => tr('Afternoon Return · Bus 04', 'رحلة العودة · الحافلة 04', 'Retour après-midi · Bus 04');
  String get trH3S => tr('03:20 PM School → 03:48 PM Home (28m)', '03:20 م المدرسة ← 03:48 م المنزل (28 د)', '15h20 École → 15h48 Domicile (28m)');
  String get trH3B => tr('Traffic +4m', 'ازدحام +4 د', 'Trafic +4m');
  String get trH4T => tr('Morning Pickup · Bus 04', 'رحلة الصباح · الحافلة 04', 'Ramassage matin · Bus 04');
  String get trH4S => tr('07:16 AM Home → 07:40 AM School (24m)', '07:16 ص المنزل ← 07:40 ص المدرسة (24 د)', '07h16 Domicile → 07h40 École (24m)');

  // Screen 4: Trip History Detail
  String get trHdTitle => tr('Trip Replay #9042', 'تفاصيل الرحلة #9042', 'Replay Trajet #9042');
  String get trHdDate => tr('Mon 09 Nov 2026 · Morning Pickup', 'الإثنين 09 نوفمبر 2026 · رحلة الصباح', 'Lun 09 Nov 2026 · Ramassage Matin');
  String get trHdStat => tr('6.8 km · 24 min · Avg 32 km/h', '6.8 كم · 24 دقيقة · متوسط 32 كم/س', '6.8 km · 24 min · Moy 32 km/h');
  String get trHdSecQr => tr('QR Boarding & Hand-off Log', 'سجل التحقق ومسح بطاقة QR', 'Journal de vérification QR');
  String get trHdQ1T => tr('07:15:22 AM · Pickup QR Verified', '07:15:22 ص · تأكيد الصعود من المحطة', '07h15:22 · QR Montée vérifié');
  String get trHdQ1S => tr('Hay El Nasr Stop 03 · Scanned by Driver Ahmed B.', 'محطة حي النصر 03 · مسح بواسطة السائق أحمد ب.', 'Arrêt Hay El Nasr 03 · Scanné par le chauffeur');
  String get trHdQ2T => tr('07:39:10 AM · School Gate Check-in', '07:39:10 ص · تأكيد الدخول للمدرسة', '07h39:10 · Entrée école confirmée');
  String get trHdQ2S => tr('El Wiam East Gate · Verified by Supervisor Tarek M.', 'البوابة الشرقية للوئام · استلام المشرف طارق م.', 'Portail Est El Wiam · Vérifié par Tarek M.');
  String get trHdSecDrv => tr('Vehicle & Driver Record', 'بيانات الحافلة والسائق', 'Fiche véhicule & chauffeur');
  String get trHdDrvT => tr('Bus 04 · Mercedes Sprinter', 'الحافلة 04 · مرسيدس سبرينتر', 'Bus 04 · Mercedes Sprinter');
  String get trHdDrvS => tr('Driver: Ahmed Benali · Safety Rating 4.9/5', 'السائق: أحمد بن علي · تقييم الأمان 4.9/5', 'Chauffeur: Ahmed Benali · Note sécurité 4.9/5');
  String get trHdBtn => tr('Download trip receipt (PDF)', 'تحميل تقرير الرحلة (PDF)', 'Télécharger le reçu (PDF)');

  // Screen 5: Attendance & Analytics
  String get trAnTitle => tr('Attendance Report', 'تقرير المواظبة والأمان', 'Rapport d\'assiduité');
  String get trAnSubDefault => tr('Youssef Mansouri · November 2026', 'يوسف منصوري · نوفمبر 2026', 'Youssef Mansouri · Novembre 2026');
  String get trAk1K => tr('Completed', 'رحلة مكتملة', 'Complétés');
  String get trAk2K => tr('Absence', 'غياب مُبلّغ', 'Absences');
  String get trAk3K => tr('Missed QR', 'مسح مفقود', 'Scans manqués');
  String get trAnSecChart => tr('Weekly Ride Regularity (AM + PM)', 'انتظام الرحلات الأسبوعي (صباح + مساء)', 'Régularité hebdomadaire (Matin + Soir)');
  String get trAnSecSafe => tr('Safety & Punctuality Score', 'مؤشر الانضباط والأمان', 'Score de sécurité & ponctualité');
  String get trAnS1T => tr('98.4% On-Time Pickup & Arrival', '98.4% التزام بمواعيد الوصول', '98.4% de ponctualité');
  String get trAnS1S => tr('Average morning pickup at 07:15 AM (±1 min)', 'متوسط وقت الصعود الصباحي 07:15 ص (±1 دقيقة)', 'Ramassage moyen à 07h15 (±1 min)');
  String get trAnS2T => tr('100% Guardian & School Handoff', '100% توثيق التسليم والاستلام', '100% remise sécurisée');
  String get trAnS2S => tr('Every boarding & exit verified by digital QR scan', 'كل عملية صعود ونزول موثّقة بمسح رمز QR الرقمي', 'Chaque montée/descente vérifiée par QR');
  String get trAnBtn => tr('Export monthly report', 'تصدير التقرير الشهري', 'Exporter le rapport mensuel');

  // Children (Module 04)
  String get myChildrenTitle => tr('My Children', 'أبنائي المسجلون', 'Mes enfants');
  String get addChild => tr('Add / Link Child', 'إضافة أو ربط طالب', 'Ajouter / Lier enfant');
  String get childDossierTitle => tr('Child Safety Dossier', 'ملف الطالب الآمن', 'Dossier de l enfant');
  String get manageChildTitle => tr('Manage Child & Transit', 'إدارة نقل الطالب', 'Gerer l enfant');
  String get tabOverview => tr('Overview', 'نظرة عامة', 'Apercu');
  String get tabIdentity => tr('Identity', 'الهوية', 'Identite');
  String get tabMedical => tr('Medical', 'الصحة', 'Medical');
  String get tabSchedule => tr('Schedule', 'الجدول', 'Planning');
  String get tabPermissions => tr('Permissions', 'الصلاحيات', 'Autorisations');

  // Profile & Settings (Modules 02 & 03)
  String get profileTitle => tr('Profile', 'الملف الشخصي', 'Profil');
  String get settingsTitle => tr('Settings', 'الإعدادات', 'Parametres');
  String get editProfileTitle => tr('Edit My Info', 'تعديل معلوماتي', 'Modifier mes infos');
  String get emergencyTitle => tr('Emergency Dispatch', 'اتصال الطوارئ المباشر', 'Poste d urgence');
  String get notificationPrefsTitle => tr('Notifications', 'الإشعارات', 'Notifications');
  String get appearanceTitle => tr('Appearance & Language', 'المظهر واللغة', 'Apparence & Langue');
  String get safetyHelpTitle => tr('Safety Rules & Help', 'إرشادات السلامة والمساعدة', 'Regles & Assistance');
  String get deleteAccountTitle => tr('Delete Account', 'حذف الحساب', 'Supprimer le compte');
  String get signOut => tr('Log out', 'تسجيل الخروج', 'Se deconnecter');

  // Page 02 Profile Strings
  String get profVerified => tr('Verified', 'موثّق', 'Verifie');
  String get profRoleDefault => tr('Parent · 2 Children', 'ولي أمر · طفلان', 'Parent · 2 enfants');
  String get secMyChildren => tr('My Children', 'أطفالي', 'Mes enfants');
  String get addActionChild => tr('+ Add child', '+ إضافة طفل', '+ Ajouter un enfant');
  String get secMyInfo => tr('My Info', 'معلوماتي', 'Mes infos');
  String get lblPhone => tr('Phone', 'الهاتف', 'Telephone');
  String get lblEmail => tr('Email', 'البريد', 'Email');
  String get lblHomeStop => tr('Home Stop', 'محطة المنزل', 'Arret maison');
  String get secUrgentCalls => tr('Urgent Calls', 'اتصالات الطوارئ', 'Appels d urgence');
  String get urgentDriverTitle => tr('Bus 04 Driver · Ahmed B.', 'سائق الحافلة 04 · أحمد ب.', 'Chauffeur Bus 04 · Ahmed B.');
  String get urgentDriverSub => tr('Direct route line', 'خط الرحلة المباشر', 'Ligne directe');
  String get urgentCallBtn => tr('Call', 'اتصال', 'Appeler');
  String get urgentSosTitle => tr('School Emergency Line', 'خط طوارئ المدرسة', 'Ligne d urgence ecole');
  String get urgentSosSub => tr('Emergency 24/7 Dispatch · Central safety desk', 'مكتب النقل المدرسي 24/7 · خط أولوية', 'Poste de transport 24/7');
  String get urgentSosBtn => tr('SOS', 'طوارئ', 'SOS');

  // Edit My Info Strings
  String get changePhoto => tr('Change photo', 'تغيير الصورة', 'Changer la photo');
  String get lblFullName => tr('Full name', 'الاسم الكامل', 'Nom complet');
  String get lblBackupPhone => tr('Emergency backup phone', 'هاتف طوارئ بديل', 'Telephone d urgence');
  String get saveChanges => tr('Save Changes', 'حفظ التغييرات', 'Enregistrer');

  // Child Details Strings
  String get childDetailsTitle => tr('Child Details', 'بيانات الطفل', 'Details de l enfant');
  String get cdSchoolDefault => tr('El Wiam Primary School · ID #HB-304', 'مدرسة الوئام الابتدائية · رقم #HB-304', 'Ecole El Wiam · ID #HB-304');
  String get cdSecBus => tr('Assigned Bus & Driver', 'الحافلة والسائق المخصّص', 'Bus et chauffeur assignes');
  String get cdBusName => tr('Bus 04 · Morning & Return', 'الحافلة 04 · ذهاب وعودة', 'Bus 04 · Aller & Retour');
  String get cdBusSub => tr('Driver: Ahmed Benali · Plate 04821-116', 'السائق: أحمد بن علي · لوحة 116-04821', 'Chauffeur: Ahmed Benali');
  String get cdSecSched => tr('Daily Stop Schedule', 'مواعيد المحطة اليومية', 'Horaires quotidiens');
  String get cdPickT => tr('Morning Pickup', 'صعود الصباح', 'Ramassage matin');
  String get cdPickS => tr('Hay El Nasr Stop · 07:15 AM', 'محطة حي النصر · 07:15 ص', 'Arret Hay El Nasr · 07h15');
  String get cdDropT => tr('Afternoon Drop-off', 'نزول المساء', 'Depot apres-midi');
  String get cdDropS => tr('Hay El Nasr Stop · 03:35 PM', 'محطة حي النصر · 03:35 م', 'Arret Hay El Nasr · 15h35');
  String get cdSecQr => tr('Digital Boarding Pass', 'بطاقة الصعود الرقمية', 'Carte d embarquement');
  String get cdQrTitle => tr('Student QR Badge', 'رمز QR للتلميذ', 'Badge QR eleve');
  String get cdQrSub => tr('Scanned by driver when boarding & exiting', 'يمسحه السائق عند الصعود والنزول من الحافلة', 'Scanne par le chauffeur');
  String get cdBtnAbsence => tr('Report absence today', 'إبلاغ عن غياب اليوم', 'Signaler une absence');

  // Add Child Strings
  String get addChildTitle => tr('Add Child', 'إضافة طفل', 'Ajouter un enfant');
  String get addChildSub => tr('Link a student to receive live boarding & route alerts.', 'اربط التلميذ بحسابك لتصلك تنبيهات الصعود والمسار مباشرة.', 'Liez un eleve pour recevoir les alertes.');
  String get lblStudentName => tr('Student full name', 'الاسم الكامل للتلميذ', 'Nom complet de l eleve');
  String get phStudentName => tr('e.g. Rayan Mansouri', 'مثال: ريان منصوري', 'ex. Rayan Mansouri');
  String get lblSchoolGrade => tr('School & grade', 'المدرسة والمستوى الدراسي', 'Ecole et classe');
  String get valSchoolGradeDefault => tr('El Wiam Primary · Grade 1', 'ابتدائية الوئام · السنة 1', 'El Wiam Primaire · 1ere');
  String get lblStudentId => tr('Student school code', 'الرمز المدرسي للتلميذ', 'Code scolaire eleve');
  String get phStudentId => 'HB-2026-XXXX';
  String get lblBusRoute => tr('Assigned bus route', 'مسار الحافلة', 'Ligne de bus');
  String get valBusRouteDefault => tr('Route 04 · Hay El Nasr', 'المسار 04 · حي النصر', 'Ligne 04 · Hay El Nasr');
  String get linkChildBtn => tr('Link child to account', 'ربط الطفل بالحساب', 'Lier l enfant au compte');

  // Emergency Dispatch Strings
  String get sosTitle => tr('Emergency Dispatch', 'مركز الطوارئ والدعم', 'Urgences & Assistance');
  String get sosLiveBadge => tr('LIVE BUS TELEMETRY', 'تتبّع مباشر للحافلة', 'TELEMETRIE EN DIRECT');
  String get sosBusTitle => tr('Bus 04 · Moving on Route', 'الحافلة 04 · في المسار الآن', 'Bus 04 · En route');
  String get sosBusSub => tr('Last GPS ping: 20 sec ago · Boulevard des Martyrs', 'آخر تحديث GPS: منذ 20 ثانية · شارع الشهداء', 'Dernier signal GPS: il y a 20s');
  String get sosSecDirect => tr('Immediate Voice Lines', 'خطوط الاتصال الفوري', 'Lignes d appel directes');
  String get sosDriverTitle => tr('Call Bus 04 Driver', 'اتصال بسائق الحافلة 04', 'Appeler chauffeur Bus 04');
  String get sosDriverSub => tr('Ahmed Benali · Direct cab phone', 'أحمد بن علي · هاتف المقصورة المباشر', 'Ahmed Benali · Cabine');
  String get sosSupervisorTitle => tr('Transport Supervisor', 'مشرف النقل المدرسي', 'Superviseur transport');
  String get sosSupervisorSub => tr('Central safety desk · Priority line', 'مكتب الأمان المركزي · خط أولوية', 'Poste de securite central');
  String get sosCivilTitle => tr('Civil Protection · SOS', 'الحماية المدنية / الطوارئ', 'Protection civile · SOS');
  String get sosCivilSub => tr('National emergency response · 14', 'الخط الوطني للطوارئ · 14', 'Secours national · 14');
  String get sosShareLocation => tr('Share live family location', 'مشاركة الموقع المباشر للعائلة', 'Partager position famille');

  // Page 03 Settings Strings
  String get secAppearance => tr('Appearance & Alerts', 'المظهر والتنبيهات', 'Apparence & Alertes');
  String get rowTheme => tr('Theme Palette', 'لوحة الألوان', 'Palette de couleurs');
  String get valThemeMustard => tr('Mustard', 'خردلي', 'Moutarde');
  String get rowMode => tr('Light / Dark Mode', 'الوضع الفاتح / الداكن', 'Mode clair / sombre');
  String get rowNotifications => tr('Notifications', 'الإشعارات', 'Notifications');
  String get subNotifications => tr('Bus arrival & boarding alerts', 'تنبيهات وصول الحافلة والصعود', 'Alertes de montee et d arrivee');
  String get secGeneral => tr('General', 'عام', 'General');
  String get rowLanguage => tr('Language', 'اللغة', 'Langue');
  String get valLanguage => tr('العربية / EN', 'العربية / EN', 'FR / العربية');
  String get rowTerms => tr('Terms & Privacy Policy', 'الشروط وسياسة الخصوصية', 'Conditions & Confidentialite');
  String get secAccount => tr('Account', 'الحساب', 'Compte');
  String get deleteCardSub => tr('Permanently remove your parent profile and linked children.', 'سيتم حذف حساب ولي الأمر وبيانات الأطفال المرتبطة نهائيًا.', 'Supprimer definitivement le profil parent.');
  String get appVersion => 'Hanna Bus v2.4.0';

  // Theme & Appearance Subscreen Strings
  String get thTitle => tr('Theme & Appearance', 'المظهر والألوان', 'Theme & Apparence');
  String get thSecMode => tr('Display Mode', 'وضع العرض', 'Mode d affichage');
  String get thMLight => tr('Light Mode', 'الوضع الفاتح', 'Mode clair');
  String get thMLightSub => tr('Warm cream daylight view', 'خلفية كريمية دافئة ومريحة نهارًا', 'Vue de jour chaude et cremeuse');
  String get thMDark => tr('Dark Mode', 'الوضع الداكن', 'Mode sombre');
  String get thMDarkSub => tr('Low-glare night tracking view', 'إضاءة منخفضة للتتبّع الليلي', 'Vue de nuit anti-eblouissement');
  String get thSecPal => tr('Brand Color Palette', 'لوحة ألوان الهوية', 'Palettes de marque');
  String get thP1 => tr('Mustard Gold (Active)', 'الأصفر الخردلي (نشط)', 'Moutarde dore (Actif)');
  String get thP1Sub => tr('Bold · Warm · High visibility', 'جريء · دافئ · وضوح عالٍ', 'Audacieux · Chaud');
  String get thP2 => tr('Teal / Slate Gray', 'الأزرق الرمادي (Teal / Gray)', 'Teal / Gris ardoise');
  String get thP2Sub => tr('Calm · Minimal · Professional', 'هادئ · رسمي · متوازن', 'Calme · Minimal · Pro');
  String get thP3 => tr('Ocean Blue', 'أزرق المحيط (Ocean)', 'Bleu ocean');
  String get thP3Sub => tr('Cool · Clean · Refreshing', 'نقي · عصري · مريح للعين', 'Frais · Epure');
  String get thApplyBtn => tr('Apply theme preferences', 'تطبيق إعدادات المظهر', 'Appliquer les preferences');

  // Notifications Subscreen Strings
  String get nfTitle => tr('Notifications', 'الإشعارات', 'Notifications');
  String get nfSecGeofence => tr('Geofence Proximity Alert', 'تنبيه الاقتراب من المحطة', 'Alerte de proximite de l arret');
  String get nfGeofenceTrigger => tr('Bus Stop Proximity Trigger', 'تفعيل تنبيه اقتراب الحافلة', 'Declencheur d approche de l arret');
  String get nfGeofenceDesc => tr(
    'Receive instant notification when the bus reaches this distance from your home stop.',
    'استلم إشعارًا فوريًا عند وصول الحافلة إلى هذه المسافة من محطة منزلك.',
    'Recevez une notification instantanee lorsque le bus franchit cette distance de votre arret.',
  );
  String nfDistanceMeters(int meters) {
    if (isArabic) return '$meters م';
    return '${meters}m';
  }
  String nfDistanceFormatted(int meters) {
    if (meters >= 1000) {
      final km = (meters / 1000).toStringAsFixed(1).replaceAll('.0', '');
      if (isArabic) return '$km كم ($meters م)';
      return '$km km ($meters m)';
    }
    if (isArabic) return '$meters متر';
    return '$meters meters';
  }
  String nfEstimatedTime(int meters) {
    final mins = (meters / 100).clamp(2, 15).round();
    if (isArabic) return 'حوالي $mins دقائق قبل الوصول للمحطة';
    return 'Approx. $mins min before stop arrival';
  }
  String get nfQuickPresets => tr('Quick Presets', 'مسافات سريعة', 'Distances rapides');
  String get nfSecBus => tr('Live Bus & Child Alerts', 'تنبيهات الحافلة والأطفال', 'Alertes bus & enfants');
  String get nf1Title => tr('Bus Approaching Stop', 'اقتراب الحافلة من المحطة', 'Bus approche de l arret');
  String get nf1Sub => tr('Alert when bus is 5 minutes from home', 'تنبيه قبل وصول الحافلة بـ 5 دقائق', 'Alerte a 5 min du domicile');
  String get nf2Title => tr('Child Boarded Bus', 'صعود الطفل إلى الحافلة', 'Enfant a bord du bus');
  String get nf2Sub => tr('Instant QR scan confirmation', 'تأكيد فوري عند مسح بطاقة QR', 'Confirmation par scan QR');
  String get nf3Title => tr('Arrived at School / Home', 'الوصول للمدرسة أو المنزل', 'Arrive a destination');
  String get nf3Sub => tr('Safe arrival check-in notification', 'إشعار الاطمئنان عند الوصول الآمن', 'Notification de securite');
  String get nf4Title => tr('Route Delays & Traffic', 'تأخّر المسار وحركة المرور', 'Retards et circulation');
  String get nf4Sub => tr('Driver & dispatch schedule updates', 'تحديثات السائق ومكتب الحركة', 'Mises a jour horaires');
  String get nfSecChannels => tr('Delivery Channels', 'قنوات التنبيه', 'Canaux de notification');
  String get nf5Title => tr('Critical SOS Sound & Banner', 'صوت تنبيهات الطوارئ الحرجة', 'Alerte sonore SOS critique');
  String get nf5Sub => tr('Always play sound for urgent alerts', 'تشغيل الصوت دائمًا للتنبيهات العاجلة', 'Toujours emettre un son');
  String get nf6Title => tr('SMS Backup Alerts', 'رسائل SMS الاحتياطية', 'Alertes SMS de secours');
  String get nf6Sub => tr('Send text when offline', 'إرسال رسالة نصية عند انقطاع الإنترنت', 'Envoi par SMS hors ligne');

  // Language Subscreen Strings
  String get lgTitle => tr('Language', 'اللغة', 'Langue');
  String get lgSub => tr('Choose your preferred language. Layout direction (RTL / LTR) adjusts automatically.', 'اختر لغة التطبيق المفضّلة. يتم ضبط اتجاه الواجهة (من اليمين لليسار أو العكس) تلقائيًا.', 'Choisissez votre langue. L orientation s ajuste automatiquement.');
  String get lgAr => tr('العربية (Arabic)', 'العربية', 'Arabe (العربية)');
  String get lgArSub => tr('RTL interface · IBM Plex Sans', 'واجهة عربية (RTL) · خط IBM Plex', 'Interface RTL · IBM Plex');
  String get lgEn => tr('English', 'English (الإنجليزية)', 'Anglais');
  String get lgEnSub => tr('LTR interface · Inter', 'واجهة إنجليزية (LTR) · خط Inter', 'Interface LTR · Inter');
  String get lgFr => tr('Français (French)', 'Français (الفرنسية)', 'Francais');
  String get lgFrSub => tr('LTR interface · Inter', 'واجهة فرنسية (LTR) · خط Inter', 'Interface LTR · Inter');
  String get lgSaveBtn => tr('Save language', 'حفظ اللغة', 'Enregistrer la langue');

  // Terms & Privacy Subscreen Strings
  String get tmTitle => tr('Terms & Privacy Policy', 'الشروط وسياسة الخصوصية', 'Conditions & Confidentialite');
  String get tmTabTerms => tr('Terms of Use', 'شروط الاستخدام', 'Conditions d utilisation');
  String get tmTabPrivacy => tr('Privacy Policy', 'سياسة الخصوصية', 'Politique de confidentialite');
  String get tmUpdatedDate => tr('Effective date: November 2026 · Hanna Bus Safety Charter', 'تاريخ السريان: نوفمبر 2026 · ميثاق أمان هنّا باص', 'Date d effet: Novembre 2026');
  String get tmC1Title => tr('1. Live GPS & Student Boarding Data', '1. بيانات التتبّع المباشر وبطاقات الصعود', '1. Donnees GPS et embarquement');
  String get tmC1Body => tr('Encrypted QR boarding scans and location telemetry are encrypted end-to-end and shared exclusively with verified parents and school transport supervisors.', 'تُشفَّر إحداثيات الحافلة وعمليات مسح رمز QR بالكامل، وتُشارك حصريًا مع أولياء الأمور الموثّقين ومشرفي النقل المدرسي.', 'Les coordonnees GPS et scans QR sont chiffres de bout en bout.');
  String get tmC2Title => tr('2. Parent & Guardian Responsibilities', '2. مسؤوليات ولي الأمر', '2. Responsabilites des parents');
  String get tmC2Body => tr('Parents must keep emergency phone numbers current and accompany young students at designated neighborhood pickup stops.', 'يلتزم ولي الأمر بتحديث أرقام الطوارئ ومرافقة الأطفال الصغار عند محطات التجمّع المعتمدة في الحي.', 'Les parents doivent maintenir leurs contacts a jour.');
  String get tmC3Title => tr('3. Account Deletion & Data Retention', '3. حذف الحساب والاحتفاظ بالبيانات', '3. Suppression du compte');
  String get tmC3Body => tr('When you delete your account, all parent profile records and linked student tokens are purged within 24 hours.', 'عند طلب حذف الحساب، تُمحى كافة بيانات ولي الأمر ورموز التلاميذ المرتبطة نهائيًا خلال 24 ساعة.', 'Toutes les donnees sont purgees sous 24h.');
  String get tmDownloadBtn => tr('Download PDF copy', 'تحميل نسخة PDF', 'Telecharger le PDF');

  // Account Confirmations Modal Strings
  String get cfTitle => tr('Account Actions', 'تأكيد إجراءات الحساب', 'Actions du compte');
  String get cfSecLogout => tr('Sign Out Confirmation', 'تأكيد تسجيل الخروج', 'Confirmation de deconnexion');
  String get cfLogoutTitle => tr('Log out of Hanna Bus?', 'هل تريد تسجيل الخروج؟', 'Se deconnecter de Hanna Bus ?');
  String get cfLogoutBody => tr('Live bus arrival notifications for Youssef and Amina will pause on this device until you sign back in.', 'ستتوقف إشعارات وصول الحافلة المباشرة ليوسف وأمينة على هذا الجهاز حتى تسجّل الدخول مجددًا.', 'Les alertes en direct seront suspendues jusqu a votre reconnexion.');
  String get cfCancelBtn => tr('Cancel', 'إلغاء', 'Annuler');
  String get cfSecDelete => tr('Permanent Account Deletion', 'تأكيد الحذف النهائي للحساب', 'Suppression definitive');
  String get cfDeleteTitle => tr('Delete Account Permanently?', 'حذف الحساب نهائيًا؟', 'Supprimer le compte ?');
  String get cfDeleteBody => tr('This action cannot be undone. Your parent profile, linked children, and boarding passes will be permanently erased.', 'لا يمكن التراجع عن هذا الإجراء. سيتم مسح ملف ولي الأمر وبيانات الأطفال وبطاقات الصعود نهائيًا.', 'Cette action est irreversible.');
  String get cfDeleteLabel => tr('Type DELETE to confirm', 'اكتب كلمة حذف للتأكيد', 'Tapez SUPPRIMER');
  String get cfDeleteKeyword => tr('DELETE', 'حذف', 'SUPPRIMER');
  String get cfDeleteBtn => tr('Delete permanently', 'حذف الحساب نهائيًا', 'Supprimer definitivement');

  // Page 04 My Children Strings
  String get chListTitle => tr('My Children', 'أطفالي', 'Mes enfants');
  String get chSearchPh => tr('Search child, school, or bus...', 'ابحث باسم الطفل أو المدرسة أو الحافلة...', 'Rechercher un enfant, une école ou un bus...');
  String get chFilterAll => tr('All (3)', 'الكل (3)', 'Tous (3)');
  String get chFilterBus => tr('On Bus (1)', 'في الحافلة (1)', 'En bus (1)');
  String get chFilterSch => tr('At School (1)', 'في المدرسة (1)', 'À l\'école (1)');
  String get chFilterHome => tr('At Home (1)', 'في المنزل (1)', 'À la maison (1)');
  String get chBtnAddNew => tr('Add New Child', 'إضافة طفل جديد', 'Ajouter un nouvel enfant');

  // Screen 1: Add & Edit Child
  String get chAeTitle => tr('Add / Edit Child', 'إضافة / تعديل طفل', 'Ajouter / Modifier un enfant');
  String get chAeModeEdit => tr('Editing Profile', 'تعديل ملف حالي', 'Modifier le profil');
  String get chAeModeAdd => tr('New Child', 'طفل جديد', 'Nouvel enfant');
  String get chAePhotoLbl => tr('Update student photo', 'تحديث صورة التلميذ', 'Mettre à jour la photo');
  String get chAeLblName => tr('Student full name', 'الاسم الكامل للتلميذ', 'Nom complet de l\'élève');
  String get chAeLblDob => tr('Birth date & blood type', 'تاريخ الميلاد وفصيلة الدم', 'Date de naissance & groupe sanguin');
  String get chAeLblSch => tr('School & grade level', 'المدرسة والمستوى الدراسي', 'École & niveau');
  String get chAeLblBus => tr('Assigned bus & stop', 'الحافلة ومحطة المنزل', 'Bus assigné & arrêt');
  String get chAeLblMed => tr('Medical alert tag', 'التنبيه الطبي السريع', 'Alerte médicale');
  String get chAeSave => tr('Save child profile', 'حفظ بيانات الطفل', 'Enregistrer le profil');

  // Screen 2: Delete & Manage Child
  String get chDmTitle => tr('Manage Child', 'إدارة ملف الطفل', 'Gérer l\'enfant');
  String get chDmSecAbs => tr('Temporary Absence Notice', 'إبلاغ عن غياب مؤقت', 'Avis d\'absence temporaire');
  String get chDmAbsT => tr('Pause Pickup Today?', 'إيقاف رحلة اليوم مؤقتًا؟', 'Suspendre le ramassage aujourd\'hui ?');
  String get chDmAbsS => tr(
    'Notify Bus 04 driver Ahmed B. that Youssef will not ride today. Schedule resumes tomorrow.',
    'سيتم إشعار سائق الحافلة 04 (أحمد ب.) بعدم ركوب يوسف اليوم، ويُستأنف الجدول تلقائيًا غدًا.',
    'Notifier le chauffeur du Bus 04 Ahmed B. que Youssef ne prendra pas le bus aujourd\'hui. Le planning reprend demain.',
  );
  String get chDmAbsBtn => tr('Pause today\'s ride', 'تأكيد غياب اليوم', 'Suspendre le trajet du jour');
  String get chDmSecDel => tr('Remove Child Profile', 'حذف ملف الطفل نهائيًا', 'Supprimer le profil');
  String get chDmDelT => tr('Delete Child from Account?', 'حذف الطفل من الحساب؟', 'Supprimer l\'enfant du compte ?');
  String get chDmDelS => tr(
    'Removing Youssef Mansouri (#HB-304) revokes his digital QR boarding pass and stops all live GPS alerts.',
    'يؤدي حذف ملف يوسف منصوري (#HB-304) إلى إلغاء بطاقة الصعود الرقمية QR وإيقاف كافة تنبيهات المسار.',
    'La suppression de Youssef Mansouri (#HB-304) révoque son pass QR et arrête les alertes GPS en direct.',
  );
  String get chDmDelLbl => tr('Student ID to confirm removal', 'رمز التلميذ لتأكيد الحذف', 'Code élève pour confirmer');
  String get chDmDelBtn => tr('Delete child profile', 'حذف ملف الطفل نهائيًا', 'Supprimer le profil définitivement');
  String get chDmCancel => tr('Keep profile', 'الإبقاء على الملف', 'Conserver le profil');

  // Tabs shared across detail screens (Screens 3..6)
  String get chTabPers => tr('Personal', 'الشخصية', 'Personnel');
  String get chTabEdu => tr('Educative', 'الدراسية', 'Scolaire');
  String get chTabMed => tr('Medical', 'الصحية', 'Médical');
  String get chTabTime => tr('Schedule', 'البرنامج', 'Planning');

  // Screen 3: Card Details & Personal Info
  String get chDpTitle => tr('Child Card & Info', 'بطاقة ومعلومات الطفل', 'Carte & Infos élève');
  String get chDpQrSub => tr('Scan QR when boarding Bus 04', 'يُمسح رمز QR عند صعود الحافلة 04', 'Scannez le QR à bord du Bus 04');
  String get chDpSecPers => tr('Personal & Guardian Info', 'المعلومات الشخصية والأولياء', 'Infos personnelles & tuteurs');
  String get chDpR1K => tr('Full Name', 'الاسم الكامل', 'Nom complet');
  String get chDpR2K => tr('Birth Date', 'تاريخ الميلاد', 'Date de naissance');
  String get chDpR3K => tr('Student ID', 'رمز التلميذ', 'Code élève');
  String get chDpR4K => tr('Guardians', 'الأولياء المعتمدون', 'Tuteurs autorisés');
  String get chDpR5K => tr('Home Stop', 'محطة المنزل', 'Arrêt domicile');
  String get chDpEditBtn => tr('Edit personal details', 'تعديل البيانات الشخصية', 'Modifier les données');

  // Screen 4: Educative Info
  String get chEdTitle => tr('Educative Info', 'المعلومات الدراسية', 'Infos scolaires');
  String get chEdSecSch => tr('School & Classroom', 'المدرسة والقسم الدراسي', 'École & Classe');
  String get chEdR1K => tr('Institution', 'المؤسسة', 'Établissement');
  String get chEdR2K => tr('Grade & Class', 'المستوى', 'Niveau & Classe');
  String get chEdR3K => tr('Homeroom', 'أستاذة القسم', 'Enseignant principal');
  String get chEdR4K => tr('Coordinator', 'منسّق النقل', 'Coordinateur transport');
  String get chEdSecTr => tr('Transport & Gate Rules', 'قواعد النقل والبوابة المدرسية', 'Règles de transport & portail');
  String get chEdT1T => tr('Bus 04 · Morning & Return', 'الحافلة 04 · ذهاب وعودة', 'Bus 04 · Aller & Retour');
  String get chEdT1S => tr('Assigned Seat A2 (Front Row)', 'المقعد المخصّص A2 (الصف الأمامي)', 'Siège assigné A2 (Premier rang)');
  String get chEdT2T => tr('East Student Gate Drop-off', 'البوابة الشرقية للتلاميذ', 'Portail Est des élèves');
  String get chEdT2S => tr('Supervised entry & dismissal', 'استلام وتسليم بإشراف مشرف المدرسة', 'Entrée & sortie surveillées');
  String get chEdT3T => tr('Dismissal Security Rule', 'قاعدة الأمان عند الانصراف', 'Règle de sécurité de sortie');
  String get chEdT3S => tr('Bus only · Parent PIN required for walk-out', 'بالحافلة فقط · يتطلب رمز PIN للخروج الفردي', 'Bus uniquement · PIN requis pour sortie piétonne');

  // Screen 5: Medical Info
  String get chMdTitle => tr('Medical Info', 'الملف الصحي والطبي', 'Dossier médical');
  String get chMdBlood => tr('Blood Type: O+', 'فصيلة الدم: O+', 'Groupe : O+');
  String get chMdIns => tr('CNAS #88412', 'تأمين #88412', 'CNAS n°88412');
  String get chMdSecCond => tr('Allergies & Conditions', 'الحساسية والحالات الصحية', 'Allergies & Antécédents');
  String get chMdC1T => tr('Mild Exercise Asthma', 'ربو خفيف عند المجهود', 'Asthme d\'effort léger');
  String get chMdC1S => tr('Blue Ventolin inhaler in front backpack pocket', 'بخاخ فينتولين أزرق في الجيب الأمامي للحقيبة', 'Inhalateur Ventoline bleu dans la poche avant');
  String get chMdC2T => tr('Food & Drug Allergies', 'الحساسية الغذائية والدوائية', 'Allergies alimentaires & médicamenteuses');
  String get chMdC2S => tr('None reported · Verified Oct 2026', 'لا توجد حساسية مسجّلة · موثّق أكتوبر 2026', 'Aucune signalée · Vérifié oct. 2026');
  String get chMdSecProt => tr('Driver & First-Aid Protocol', 'بروتوكول السائق والإسعاف الأولي', 'Protocole chauffeur & premiers secours');
  String get chMdProtB => tr(
    'Seat in front row near fresh air. If coughing or short of breath, assist with 2 puffs of inhaler and call parent immediately.',
    'الجلوس في الصف الأمامي قرب التهوية. عند السعال أو ضيق التنفس يُعطى بخّتان من البخاخ مع الاتصال الفوري بولي الأمر.',
    'Installer au premier rang près de l\'air frais. En cas de toux ou essoufflement, administrer 2 bouffées d\'inhalateur et appeler immédiatement les parents.',
  );
  String get chMdSecDoc => tr('Authorized Pediatrician', 'الطبيب والعيادة المعتمدة', 'Pédiatre agréé');
  String get chMdDocT => tr('Dr. Amine Boudiaf', 'د. أمين بوضياف', 'Dr Amine Boudiaf');
  String get chMdDocS => tr('El Chifa Clinic · +213 21 65 44 12', 'عيادة الشفاء · 021 65 44 12', 'Clinique El Chifa · +213 21 65 44 12');
  String get chMdCallBtn => tr('Call', 'اتصال', 'Appeler');
  String get chMdUpdBtn => tr('Update medical record', 'تحديث الملف الطبي', 'Mettre à jour le dossier');

  // Screen 6: Time Programme
  String get chTmTitle => tr('Time Programme', 'البرنامج الزمني', 'Programme horaire');
  String get chDSun => tr('Sun', 'الأحد', 'Dim');
  String get chDMon => tr('Mon', 'الإثنين', 'Lun');
  String get chDTue => tr('Tue', 'الثلاثاء', 'Mar');
  String get chDWed => tr('Wed', 'الأربعاء', 'Mer');
  String get chDThu => tr('Thu', 'الخميس', 'Jeu');
  String get chTmSecAm => tr('Morning Ride · To School', 'رحلة الصباح · الذهاب للمدرسة', 'Trajet matin · Vers l\'école');
  String get chTm1T => tr('07:05 AM · Bus 04 Departs', '07:05 ص · انطلاق الحافلة 04', '07h05 · Départ Bus 04');
  String get chTm1S => tr('Leaves central depot on schedule', 'الانطلاق من المستودع المركزي في الموعد', 'Départ du dépôt central à l\'heure');
  String get chTm2T => tr('07:15 AM · Home Pickup', '07:15 ص · الصعود من المحطة', '07h15 · Ramassage domicile');
  String get chTm2S => tr('Hay El Nasr Stop 03 · QR Check-in', 'محطة حي النصر 03 · مسح رمز QR', 'Arrêt Hay El Nasr 03 · Check-in QR');
  String get chTm3T => tr('07:40 AM · School Arrival', '07:40 ص · الوصول إلى المدرسة', '07h40 · Arrivée à l\'école');
  String get chTm3S => tr('El Wiam Primary · East Gate', 'ابتدائية الوئام · البوابة الشرقية', 'Primaire El Wiam · Portail Est');
  String get chTmSecSch => tr('School Hours', 'أوقات الدراسة', 'Horaires scolaires');
  String get chTm4T => tr('08:00 AM - 03:15 PM · Classes', '08:00 ص - 03:15 م · الحصص الدراسية', '08h00 - 15h15 · Cours');
  String get chTm4S => tr('Core lessons, lunch & supervised study', 'الدروس الأساسية، استراحة الغداء والمطالعة', 'Cours fondamentaux, déjeuner & étude surveillée');
  String get chTmSecPm => tr('Afternoon Ride · Return Home', 'رحلة المساء · العودة للمنزل', 'Trajet après-midi · Retour maison');
  String get chTm5T => tr('03:20 PM · School Boarding', '03:20 م · الصعود من المدرسة', '15h20 · Embarquement école');
  String get chTm5S => tr('Bus 04 · East Gate QR Check-in', 'الحافلة 04 · مسح QR عند البوابة الشرقية', 'Bus 04 · Check-in QR Portail Est');
  String get chTm6T => tr('03:45 PM · Home Drop-off', '03:45 م · النزول في محطة المنزل', '15h45 · Dépose à l\'arrêt');
  String get chTm6S => tr('Hay El Nasr Stop 03 · Guardian handoff', 'محطة حي النصر 03 · تسليم لولي الأمر', 'Arrêt Hay El Nasr 03 · Remise au parent');
  String get chTmBtn => tr('Request schedule change', 'طلب تعديل المواعيد', 'Demander modification d\'horaire');

  String transitLabel(String status) {
    switch (status) {
      case 'on_bus':
        return tr('On Bus', 'على متن الحافلة', 'A bord');
      case 'arrived':
        return tr('Arrived Safely', 'وصل بأمان', 'Arrive en securite');
      case 'absent':
        return tr('Absent Today', 'غائب اليوم', 'Absent aujourd hui');
      default:
        return tr('At Home Stop', 'بانتظار الحافلة', 'A l arret');
    }
  }
}
