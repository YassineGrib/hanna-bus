"""Build Page '06 · Driver Settings & Safety' (6 screens x 2 languages = 12 frames).

Screens:
  0. Driver Settings Hub (Grouped operational preferences, quick status, navigation, scanner, security)
  1. Navigation & Audio HUD Settings (Windshield glare mode, voice language, proximity radar radius)
  2. Scanner & Hardware Integration (Continuous optical vs Bluetooth terminal, audio chime, offline cache)
  3. Shift Security & Biometrics (Face ID shift unlock, quick glove PIN, student privacy lock timer)
  4. Trilingual Localization & Themes (Arabic, French, English, Mustard Day / Dark Night modes)
  5. Driver SOP & Incident Handbook (Standard operating procedures, emergency protocols, diagnostics)
"""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
import fc
from phosphor import icon
from ui import (
    W, H, INK, BG, SURF, BORDER, ACCENT, PRIMARY, MUTED, SOFT, LINK, ONP,
    DESTR, OND, DSURF, DBORD,
    mk, S, width, ensure_page, clear_lang_on_page, wrap_section, Screen,
)

PAGE_NAME = "06 · Driver Settings & Safety"
GROUP = "Driver Settings"
SCREENS = [
    "Driver Settings Hub",
    "Navigation & Audio Settings",
    "Scanner & Hardware Setup",
    "Shift Security & Biometrics",
    "Localization & Night Mode",
    "SOP & Safety Handbook",
]
SECTIONS = {
    "en": "EN · Settings & Safety (LTR)",
    "ar": "AR · إعدادات السائق والسلامة (RTL)",
}

STR = {
 "en": dict(
  # Navigation & Shared Header
  page_title="Driver Settings & Safety",
  page_sub="Bus 04 · Operations & Terminal Preferences",
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",

  # Screen 0: Settings Hub
  sec_ops="Operational Navigation",
  o1_t="Navigation HUD & Audio Alerts", o1_s="Voice turns, speed limit chime, night glare",
  o2_t="QR Scanner & Boarding Rules", o2_s="Continuous scan, audio chime, offline cache",
  sec_pref="Preferences & Interface",
  p1_t="App Language", p1_s="العربية (Arabic) · Trilingual support",
  p2_t="Display Theme", p2_s="Mustard Day / Automatic Night Mode",
  sec_sec="Security & Regulations",
  s1_t="Shift Biometrics & Quick PIN", s1_s="Face ID active · Screen locks on halt",
  s2_t="Safety Operating Handbook (SOP)", s2_s="Child check protocols & breakdown guide",
  btn_logout="End Shift & Sign Out",

  # Screen 1: Navigation HUD & Audio Settings
  nav_sett_title="Navigation & Radar HUD",
  nav_sett_sub="Fine-tune in-cab guidance to prevent driving distractions",
  sec_map_disp="Windshield Glare & Map Style",
  m_glare_t="High-Contrast Windshield Mode", m_glare_s="Optimized black/amber palette for bright sun glare",
  m_voice_t="Spoken Turn-by-Turn Voice", m_voice_s="Voice: Arabic (Algerian) · Loud speaker",
  sec_speed="Speed Alerts & Geofence Radius",
  spd_t="Speed Limit Over-Limit Chime", spd_s="Gentle audible ping when exceeding limit by 5 km/h",
  geo_t="Proximity Geofence Radius", geo_s="500m (Notifies parents ~3 mins before curb arrival)",
  slider_val="500 m",
  btn_save_nav="Save Navigation Preferences",

  # Screen 2: Scanner & Hardware Setup
  scan_sett_title="Scanner & Terminal Hardware",
  scan_sett_sub="Configure optical camera and Bluetooth handheld terminals",
  sec_scan_mode="Boarding Pass Detection Mode",
  sm1_t="Continuous Camera Viewfinder", sm1_s="Default on-device camera · Hands-free",
  sm2_t="External Bluetooth Scanner", sm2_s="Honeywell / Zebra industrial barcode gun",
  sec_feedback="Boarding Verification Feedback",
  fb1_t="Audio Confirmation Chime", fb1_s="Pleasant high chime on successful pass read",
  fb2_t="Vibration Haptic Pulse", fb2_s="Tactile vibration for noisy diesel engine idle",
  fb3_t="Offline Student Pass Cache", fb3_s="Encrypted 24h SQLite database for tunnel deadzones",
  btn_test_chime="Test Audio Chime",

  # Screen 3: Shift Security & Biometrics
  sec_sett_title="Shift Security & Privacy",
  sec_sett_sub="Protect student passenger data and secure vehicle terminal",
  sec_auth="Operator Authentication",
  bio_t="Biometric Shift Sign-In", bio_s="Require Face ID / Fingerprint before engine start",
  pin_t="4-Digit Glove Quick PIN", pin_s="Fast terminal access when wearing winter gloves",
  sec_auto_lock="Privacy Auto-Lock Timer",
  al_t="Lock Terminal on Station Halt", al_s="Screen blacks out after 90s idle to protect student PII",
  al_val="90 seconds",
  btn_update_pin="Change 4-Digit Quick PIN",

  # Screen 4: Localization & Night Mode
  lang_title="Language & Interface Theme",
  lang_sub="Select working language and ambient display mode",
  sec_lang="Application Language",
  l_ar="العربية (الجزائر)", l_ar_s="اللغة الافتراضية · محاذاة كاملة لليمين",
  l_fr="Français (Algérie)", l_fr_s="Langue secondaire · Support LTR",
  l_en="English (International)", l_en_s="Transit technical mode",
  sec_theme="Display Theme & Glare Mode",
  th_day="Mustard Day (Standard)", th_day_s="Optimized for daytime visibility",
  th_night="Deep Charcoal Night", th_night_s="Prevents dashboard glare on glass",
  btn_apply_lang="Apply Theme & Language",

  # Screen 5: Driver SOP & Incident Handbook
  sop_title="Safety SOP & Handbook",
  sop_sub="Official Algerian school transportation standard operating procedures",
  sec_sops="Standard Operating Procedures",
  sop1_t="Unannounced Child Absence at Stop", sop1_s="Wait 90s, call guardian, log no-show in app",
  sop2_t="Unauthorized Adult at Curb", sop2_s="Verify digital QR handover pass before child release",
  sop3_t="Mechanical Breakdown or Flat Tire", sop3_s="Evacuate to curb, hazard flashers, tap SOS button",
  sec_diag="Device & Connectivity Diagnostics",
  d_gps="GPS Satellite Signal: ±2.1m (Excellent)",
  d_sync="Cloud Sync: Real-time (WebSocket connected)",
  d_ver="Hanna Bus Driver v2.4.0 (Build 304)",
  btn_sync_logs="Export Diagnostic Logs to Fleet",
 ),
 "ar": dict(
  # Navigation & Shared Header
  page_title="إعدادات السائق والسلامة",
  page_sub="الحافلة 04 · تفضيلات العمليات وجهاز الحافلة",
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="حسابي",

  # Screen 0: Settings Hub
  sec_ops="إعدادات الملاحة والعمليات",
  o1_t="الملاحة الحية والتوجيه الصوتي", o1_s="التوجيه الصوتي، تنبيه السرعة، وضع التباين",
  o2_t="قارئ بطاقات QR وقواعد الركوب", o2_s="المسح المستمر، نغمة التأكيد، الحفظ دون إنترنت",
  sec_pref="التفضيلات ومظهر التطبيق",
  p1_t="لغة التطبيق", p1_s="العربية (الافتراضية) · دعم ثلاثي اللغات",
  p2_t="مظهر الشاشة والوضع الليلي", p2_s="الوضع النهاري الخردلي / الوضع الليلي التلقائي",
  sec_sec="الأمان واللوائح التنظيمية",
  s1_t="بصمة السائق والرمز السريع", s1_s="بصمة الوجه نشطة · قفل الشاشة عند التوقف",
  s2_t="دليل إجراءات السلامة المعتمد (SOP)", s2_s="بروتوكولات خلو الحافلة والتعامل مع الأعطال",
  btn_logout="إنهاء الوردية وتسجيل الخروج",

  # Screen 1: Navigation HUD & Audio Settings
  nav_sett_title="إعدادات الملاحة ورادار الاقتراب",
  nav_sett_sub="ضبط شاشة القيادة لتجنب أي تشتيت أثناء قيادة الحافلة",
  sec_map_disp="مقاومة الانعكاس ومظهر الخريطة",
  m_glare_t="وضع التباين العالي للشمس", m_glare_s="لوحة ألوان خردلية وداكنة تمنع انعكاس الزجاج",
  m_voice_t="التوجيه الصوتي خطوة بخطوة", m_voice_s="الصوت: العربية (الجزائر) · مكبر الصوت عالي",
  sec_speed="تنبيهات السرعة ومسافة الرادار",
  spd_t="نغمة تنبيه تجاوز السرعة", spd_s="رنين صوتي هادئ عند تجاوز السرعة القانونية بـ 5 كم/سا",
  geo_t="نطاق تنبيه الاقتراب التلقائي", geo_s="500 م (يُشعر الأولياء قبل ~3 دقائق من الوصول)",
  slider_val="500 م",
  btn_save_nav="حفظ تفضيلات الملاحة",

  # Screen 2: Scanner & Hardware Setup
  scan_sett_title="إعدادات القارئ والأجهزة المتصلة",
  scan_sett_sub="إعداد كاميرا المسح التلقائي وأجهزة الباركود الخارجية",
  sec_scan_mode="وضع مسح بطاقات صعود الطلاب",
  sm1_t="المسح البصري عبر كاميرا الهاتف", sm1_s="الكاميرا المدمجة بالجهاز · ركوب ذاتي وسلس",
  sm2_t="قارئ باركود خارجي عبر البلوتوث", sm2_s="أجهزة هانيويل / زيبرا الصناعية للحافلات",
  sec_feedback="التغذية الراجعة لتأكيد الصعود",
  fb1_t="نغمة صوتية عند نجاح المسح", fb1_s="صوت رنين لطيف وواضح عند توثيق بطاقة الطالب",
  fb2_t="اهتزاز لمسي للتأكيد", fb2_s="نبضة اهتزاز تنبه السائق وسط ضجيج محرك الديزل",
  fb3_t="حفظ البطاقات دون إنترنت", fb3_s="قاعدة بيانات محلية مشفرة لـ 24 ساعة بمناطق ضعف الشبكة",
  btn_test_chime="تجربة نغمة المسح",

  # Screen 3: Shift Security & Biometrics
  sec_sett_title="أمان الوردية وخصوصية الطلاب",
  sec_sett_sub="حماية بيانات الطلاب وسرية رحلات النقل المدرسي",
  sec_auth="التحقق من هوية السائق",
  bio_t="تسجيل الدخول بالبصمة الحيوية", bio_s="اشتراط بصمة الوجه أو الأصبع قبل تدوير المحرك",
  pin_t="رمز PIN السريع (للقفازات)", pin_s="رمز سريع من 4 أرقام لفتح الجهاز عند ارتداء قفازات",
  sec_auto_lock="مؤقت القفل التلقائي لحماية البيانات",
  al_t="قفل الشاشة تلقائياً عند التوقف", al_s="إعتام الشاشة بعد 90 ثانية لحماية خصوصية بيانات الأطفال",
  al_val="90 ثانية",
  btn_update_pin="تعديل الرمز السريع (4 أرقام)",

  # Screen 4: Localization & Night Mode
  lang_title="لغة التطبيق ومظهر الشاشة",
  lang_sub="اختيار لغة العمل ومواءمة الشاشة مع إضاءة الحافلة",
  sec_lang="لغة واجهة التطبيق",
  l_ar="العربية (الجزائر)", l_ar_s="اللغة الافتراضية · محاذاة كاملة لليمين",
  l_fr="Français (Algérie)", l_fr_s="اللغة الثانوية · محاذاة لليسار",
  l_en="English (International)", l_en_s="وضع النقل التقني الدولي",
  sec_theme="مظهر الشاشة والوضع الليلي",
  th_day="النهاري الخردلي (الافتراضي)", th_day_s="أعلى وضوح تحت أشعة الشمس المباشرة",
  th_night="الليلي الفحمي الهادئ", th_night_s="يمنع انعكاس الضوء على الزجاج الأمامي ليلاً",
  btn_apply_lang="اعتماد اللغة والمظهر",

  # Screen 5: Driver SOP & Incident Handbook
  sop_title="دليل إجراءات السلامة (SOP)",
  sop_sub="بروتوكولات النقل المدرسي المعتمدة من وزارة النقل الجزائرية",
  sec_sops="إجراءات التشغيل القياسية",
  sop1_t="غياب مفاجئ لطالب عند المحطة", sop1_s="الانتظار 90 ثانية، الاتصال بولي الأمر، تسجيل غياب",
  sop2_t="استقبال شخص غير مخول للطفل", sop2_s="منع النزول تماماً ومطابقة بطاقة QR الرقمية",
  sop3_t="عطل ميكانيكي مفاجئ أو بنشر عجلة", sop3_s="تأمين الطلاب بالرصيف، تشغيل أضواء التحذير، ضغط زر SOS",
  sec_diag="تشخيص الأجهزة وحالة الاتصال",
  d_gps="إشارة الأقمار الصناعية GPS: دقة ±2.1 م (ممتازة)",
  d_sync="المزامنة السحابية: متصل لحظياً (WebSocket)",
  d_ver="تطبيق سائق هناء باص v2.4.0 (الإصدار 304)",
  btn_sync_logs="رفع سجلات التشخيص لغرفة العمليات",
 ),
}


def driver_bottom_nav(sc: Screen, active: int = 3):
    """Draw the floating capsule 4-item navbar with Profile/Settings active (index 3)."""
    s = sc.s
    sc.rect(
        18,
        752,
        357,
        68,
        INK,
        34,
        "Bottom nav capsule",
        effects=[
            {
                "type": "dropShadow",
                "offset": [0, 8],
                "radius": 24,
                "color": INK + "30",
            }
        ],
        mirror=False,
    )
    items = [
        (s["nav_home"], "house", 0),
        (s["nav_roster"], "users", 1),
        (s["nav_nav"], "map-pin", 2),
        (s["nav_prof"], "user", 3),
    ]
    slot_w = 357 / 4.0
    for label, ic_name, idx in items:
        cx = 18 + idx * slot_w + (slot_w / 2.0)
        is_active = (idx == active)
        if is_active:
            pill_w = 92
            sc.rect(
                cx - pill_w / 2.0,
                758,
                pill_w,
                56,
                PRIMARY,
                28,
                f"Nav pill {label}",
                mirror=False,
            )
            sc.icon(ic_name, cx - 30, 770, 20, ONP, mirror=False)
            t = sc.text(label, 0, 772, 12, ONP, 700, name=f"Nav label {label}")
            S(t, x=cx - 6)
        else:
            sc.icon(ic_name, cx - 11, 774, 22, "#9E9E9E", mirror=False)


def driver_settings_hub_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Driver Settings Hub", 0, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["page_title"], end_icon="gear")

    # Group 1: Operational Navigation (y=116)
    sc.section_label(s["sec_ops"], 116)
    ops_items = [
        (s["o1_t"], s["o1_s"], "navigation-arrow", 140),
        (s["o2_t"], s["o2_s"], "qr-code", 208),
    ]
    for ot, os_, oic, oy in ops_items:
        sc.rect(18, oy, 357, 60, SURF, 16, f"Ops {ot}", stroke=BORDER)
        sc.rect(28, oy + 12, 36, 36, PRIMARY + "20", 14, "Op ic box")
        sc.icon(oic, 38, oy + 22, 18, PRIMARY)
        sc.text(ot, 74, oy + 11, 13, INK, 700, w=230)
        sc.text(os_, 74, oy + 31, 10.5, MUTED, 500, w=230)
        sc.rect(323, oy + 14, 32, 32, "#F8F5EC", 16, "Caret box")
        sc.icon("caret-right", 333, oy + 22, 16, MUTED)

    # Group 2: Preferences & Interface (y=280)
    sc.section_label(s["sec_pref"], 280)
    pref_items = [
        (s["p1_t"], s["p1_s"], "globe", 304),
        (s["p2_t"], s["p2_s"], "palette", 372),
    ]
    for pt, ps_, pic, py in pref_items:
        sc.rect(18, py, 357, 60, SURF, 16, f"Pref {pt}", stroke=BORDER)
        sc.rect(28, py + 12, 36, 36, ACCENT, 14, "Pref ic box")
        sc.icon(pic, 38, py + 22, 18, INK)
        sc.text(pt, 74, py + 11, 13, INK, 700, w=230)
        sc.text(ps_, 74, py + 31, 10.5, MUTED, 500, w=230)
        sc.rect(323, py + 14, 32, 32, "#F8F5EC", 16, "Caret box")
        sc.icon("caret-right", 333, py + 22, 16, MUTED)

    # Group 3: Security & Regulations (y=444)
    sc.section_label(s["sec_sec"], 444)
    sec_items = [
        (s["s1_t"], s["s1_s"], "lock-simple", 468),
        (s["s2_t"], s["s2_s"], "shield-check", 536),
    ]
    for st, ss_, sic, sy in sec_items:
        sc.rect(18, sy, 357, 60, SURF, 16, f"Sec {st}", stroke=BORDER)
        sc.rect(28, sy + 12, 36, 36, "#E8F8F0", 14, "Sec ic box")
        sc.icon(sic, 38, sy + 22, 18, "#1B8A4D")
        sc.text(st, 74, sy + 11, 13, INK, 700, w=230)
        sc.text(ss_, 74, sy + 31, 10.5, MUTED, 500, w=230)
        sc.rect(323, sy + 14, 32, 32, "#F8F5EC", 16, "Caret box")
        sc.icon("caret-right", 333, sy + 22, 16, MUTED)

    # End Shift & Sign Out Button (y=616)
    sc.rect(18, 616, 357, 50, DSURF, 16, "Logout btn", stroke=DBORD)
    sc.icon("sign-out", 32, 631, 20, DESTR)
    sc.text(s["btn_logout"], 0, 632, 14, DESTR, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def nav_audio_settings_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Navigation & Audio Settings", 1, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["nav_sett_title"], end_icon="navigation-arrow")
    sc.sub(s["nav_sett_sub"], 112, w=340)

    # Windshield Glare & Style Section (y=164)
    sc.section_label(s["sec_map_disp"], 164)

    # Glare Toggle Card (y=188, h=66)
    sc.rect(18, 188, 357, 66, SURF, 16, "Glare card", stroke=BORDER)
    sc.icon("sun", 30, 211, 20, PRIMARY)
    sc.text(s["m_glare_t"], 60, 198, 12.5, INK, 700, w=220)
    sc.text(s["m_glare_s"], 60, 220, 10.5, MUTED, 500, w=220)
    # Switch ON
    sc.rect(300, 206, 52, 28, PRIMARY, 14, "Switch bg")
    sc.rect(326, 208, 24, 24, ONP, 12, "Switch knob")

    # Voice Turn Guidance (y=262, h=66)
    sc.rect(18, 262, 357, 66, SURF, 16, "Voice card", stroke=BORDER)
    sc.icon("bell", 30, 285, 20, PRIMARY)
    sc.text(s["m_voice_t"], 60, 272, 12.5, INK, 700, w=220)
    sc.text(s["m_voice_s"], 60, 294, 10.5, MUTED, 500, w=220)
    # Switch ON
    sc.rect(300, 280, 52, 28, PRIMARY, 14, "Switch bg 2")
    sc.rect(326, 282, 24, 24, ONP, 12, "Switch knob 2")

    # Speed Alerts & Geofence (y=342)
    sc.section_label(s["sec_speed"], 342)

    # Over speed alert card (y=366, h=66)
    sc.rect(18, 366, 357, 66, SURF, 16, "Speed alert card", stroke=BORDER)
    sc.icon("warning-circle", 30, 389, 20, "#E67E22")
    sc.text(s["spd_t"], 60, 376, 12.5, INK, 700, w=220)
    sc.text(s["spd_s"], 60, 398, 10.5, MUTED, 500, w=220)
    # Switch ON
    sc.rect(300, 384, 52, 28, PRIMARY, 14, "Switch bg 3")
    sc.rect(326, 386, 24, 24, ONP, 12, "Switch knob 3")

    # Geofence Proximity Slider Card (y=440, h=108)
    sc.rect(18, 440, 357, 108, "#FFFDF2", 18, "Geofence slider card", stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "20"}])
    sc.icon("broadcast", 30, 458, 20, PRIMARY)
    sc.text(s["geo_t"], 60, 452, 13, INK, 800, w=210)
    sc.text(s["geo_s"], 60, 472, 10.5, MUTED, 500, w=210)

    # Value Pill on right
    sc.rect(284, 452, 75, 26, PRIMARY, 13, "Val pill")
    sc.text(s["slider_val"], 284, 458, 11, ONP, 800, w=75, align="center")

    # Interactive slider bar (y=506)
    sc.rect(34, 506, 325, 8, "#E6E1D2", 4, "Track", mirror=False)
    sc.rect(34, 506, 165, 8, PRIMARY, 4, "Fill", mirror=False)
    sc.rect(191, 498, 24, 24, INK, 12, "Thumb knob", stroke=SURF, mirror=False)

    # Save Button (y=576)
    sc.rect(18, 576, 357, 52, PRIMARY, 18, "Save nav btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("check-circle", 32, 591, 20, ONP)
    sc.text(s["btn_save_nav"], 0, 592, 14, ONP, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def scanner_hardware_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Scanner & Hardware Setup", 2, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["scan_sett_title"], end_icon="qr-code")
    sc.sub(s["scan_sett_sub"], 112, w=340)

    # Scan Detection Mode (y=164)
    sc.section_label(s["sec_scan_mode"], 164)

    # Radio 1: Continuous Camera (Selected)
    sc.rect(18, 188, 357, 62, "#FFFDF2", 16, "Mode 1 card", stroke=PRIMARY)
    sc.rect(30, 205, 22, 22, PRIMARY, 11, "Radio outer")
    sc.rect(36, 211, 10, 10, ONP, 5, "Radio inner")
    sc.text(s["sm1_t"], 64, 198, 13, INK, 800, w=290)
    sc.text(s["sm1_s"], 64, 220, 10.5, MUTED, 500, w=290)

    # Radio 2: External BT Scanner
    sc.rect(18, 258, 357, 62, SURF, 16, "Mode 2 card", stroke=BORDER)
    sc.rect(30, 275, 22, 22, SURF, 11, "Radio outer 2", stroke=BORDER)
    sc.text(s["sm2_t"], 64, 268, 13, INK, 700, w=290)
    sc.text(s["sm2_s"], 64, 290, 10.5, MUTED, 500, w=290)

    # Feedback Section (y=334)
    sc.section_label(s["sec_feedback"], 334)

    feedbacks = [
        (s["fb1_t"], s["fb1_s"], "bell", 358, True),
        (s["fb2_t"], s["fb2_s"], "heartbeat", 428, True),
        (s["fb3_t"], s["fb3_s"], "shield-check", 498, True),
    ]
    for ft, fs_, fic, fy, is_on in feedbacks:
        sc.rect(18, fy, 357, 62, SURF, 14, f"Fb {ft}", stroke=BORDER)
        sc.icon(fic, 30, fy + 21, 20, PRIMARY)
        sc.text(ft, 60, fy + 12, 12.5, INK, 700, w=220)
        sc.text(fs_, 60, fy + 32, 10.5, MUTED, 500, w=220)
        # Switch
        sc.rect(300, fy + 17, 52, 28, PRIMARY if is_on else BORDER, 14, "Sw bg")
        sc.rect(326 if is_on else 302, fy + 19, 24, 24, ONP if is_on else MUTED, 12, "Sw knob")

    # Test Chime Button (y=584)
    sc.rect(18, 584, 357, 52, SURF, 18, "Test chime btn", stroke=PRIMARY)
    sc.icon("bell", 32, 599, 20, PRIMARY)
    sc.text(s["btn_test_chime"], 0, 600, 14, PRIMARY, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def shift_security_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Shift Security & Biometrics", 3, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["sec_sett_title"], end_icon="lock-simple")
    sc.sub(s["sec_sett_sub"], 112, w=340)

    # Operator Auth Section (y=164)
    sc.section_label(s["sec_auth"], 164)

    # Face ID Toggle
    sc.rect(18, 188, 357, 66, SURF, 16, "Bio card", stroke=BORDER)
    sc.icon("user", 30, 211, 20, PRIMARY)
    sc.text(s["bio_t"], 60, 198, 12.5, INK, 700, w=220)
    sc.text(s["bio_s"], 60, 220, 10.5, MUTED, 500, w=220)
    sc.rect(300, 206, 52, 28, PRIMARY, 14, "Sw bg bio")
    sc.rect(326, 208, 24, 24, ONP, 12, "Sw knob bio")

    # 4-Digit Glove PIN Card
    sc.rect(18, 262, 357, 66, SURF, 16, "Pin card", stroke=BORDER)
    sc.icon("lock-simple", 30, 285, 20, PRIMARY)
    sc.text(s["pin_t"], 60, 272, 12.5, INK, 700, w=220)
    sc.text(s["pin_s"], 60, 294, 10.5, MUTED, 500, w=220)
    sc.rect(300, 280, 52, 28, PRIMARY, 14, "Sw bg pin")
    sc.rect(326, 282, 24, 24, ONP, 12, "Sw knob pin")

    # Privacy Auto-Lock Section (y=342)
    sc.section_label(s["sec_auto_lock"], 342)

    sc.rect(18, 366, 357, 86, "#FFFDF2", 18, "Auto lock card", stroke=PRIMARY)
    sc.icon("shield-check", 30, 396, 22, PRIMARY)
    sc.text(s["al_t"], 60, 380, 13, INK, 800, w=200)
    sc.text(s["al_s"], 60, 402, 10.5, MUTED, 500, w=200)
    # Timer badge
    sc.rect(274, 388, 87, 28, PRIMARY, 14, "Lock timer pill")
    sc.text(s["al_val"], 274, 394, 11, ONP, 800, w=87, align="center")

    # Update PIN Button (y=476)
    sc.rect(18, 476, 357, 52, SURF, 18, "Update pin btn", stroke=PRIMARY)
    sc.icon("pencil-simple", 32, 491, 20, PRIMARY)
    sc.text(s["btn_update_pin"], 0, 492, 14, PRIMARY, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def localization_theme_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Localization & Night Mode", 4, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["lang_title"], end_icon="globe")
    sc.sub(s["lang_sub"], 112, w=340)

    # Language Section (y=164)
    sc.section_label(s["sec_lang"], 164)

    languages = [
        (s["l_ar"], s["l_ar_s"], True, 188),
        (s["l_fr"], s["l_fr_s"], False, 256),
        (s["l_en"], s["l_en_s"], False, 324),
    ]
    for lt, ls_, is_sel, ly in languages:
        sc.rect(18, ly, 357, 60, "#FFFDF2" if is_sel else SURF, 16, f"Lang {lt}",
                stroke=PRIMARY if is_sel else BORDER)
        sc.rect(30, ly + 19, 22, 22, PRIMARY if is_sel else SURF, 11, "Radio outer",
                stroke=PRIMARY if is_sel else BORDER)
        if is_sel:
            sc.rect(36, ly + 25, 10, 10, ONP, 5, "Radio inner")
        sc.text(lt, 64, ly + 11, 13, INK, 800 if is_sel else 600, w=280)
        sc.text(ls_, 64, ly + 31, 10.5, MUTED, 500, w=280)

    # Theme Section (y=398)
    sc.section_label(s["sec_theme"], 398)

    themes = [
        (s["th_day"], s["th_day_s"], "sun", True, 422),
        (s["th_night"], s["th_night_s"], "moon", False, 490),
    ]
    for tt, ts_, tic, is_sel, ty in themes:
        sc.rect(18, ty, 357, 60, "#FFFDF2" if is_sel else SURF, 16, f"Theme {tt}",
                stroke=PRIMARY if is_sel else BORDER)
        sc.icon(tic, 30, ty + 20, 20, PRIMARY if is_sel else MUTED)
        sc.text(tt, 62, ty + 11, 13, INK, 800 if is_sel else 600, w=240)
        sc.text(ts_, 62, ty + 31, 10.5, MUTED, 500, w=240)
        if is_sel:
            sc.icon("check-circle", 330, ty + 20, 20, PRIMARY)

    # Apply Button (y=576)
    sc.rect(18, 576, 357, 52, PRIMARY, 18, "Apply btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("check-circle", 32, 591, 20, ONP)
    sc.text(s["btn_apply_lang"], 0, 592, 14, ONP, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def sop_handbook_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "SOP & Safety Handbook", 5, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["sop_title"], end_icon="shield-check")
    sc.sub(s["sop_sub"], 112, w=340)

    # SOPs Section (y=164)
    sc.section_label(s["sec_sops"], 164)

    sops = [
        (s["sop1_t"], s["sop1_s"], "clock", 188),
        (s["sop2_t"], s["sop2_s"], "warning-circle", 256),
        (s["sop3_t"], s["sop3_s"], "first-aid", 324),
    ]
    for st, ss_, sic, sy in sops:
        sc.rect(18, sy, 357, 60, SURF, 16, f"SOP {st}", stroke=BORDER)
        sc.rect(28, sy + 12, 36, 36, "#FFF8E7", 14, "SOP ic box")
        sc.icon(sic, 38, sy + 22, 18, "#946A00")
        sc.text(st, 74, sy + 10, 12.5, INK, 700, w=275)
        sc.text(ss_, 74, sy + 31, 10.5, MUTED, 500, w=275)

    # Diagnostics Section (y=398)
    sc.section_label(s["sec_diag"], 398)

    sc.rect(18, 422, 357, 104, "#F8F5EC", 18, "Diag box", stroke=BORDER)
    sc.icon("broadcast", 30, 436, 18, "#1B8A4D")
    sc.text(s["d_gps"], 56, 436, 11, INK, 600, w=300)
    sc.icon("arrows-clockwise", 30, 466, 18, PRIMARY)
    sc.text(s["d_sync"], 56, 466, 11, INK, 600, w=300)
    sc.icon("info", 30, 496, 18, MUTED)
    sc.text(s["d_ver"], 56, 496, 11, MUTED, 500, w=300)

    # Export Diagnostic Logs (y=554)
    sc.rect(18, 554, 357, 52, PRIMARY, 18, "Sync logs btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("download-simple", 32, 569, 20, ONP)
    sc.text(s["btn_sync_logs"], 0, 570, 14, ONP, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            driver_settings_hub_screen(lang),
            nav_audio_settings_screen(lang),
            scanner_hardware_screen(lang),
            shift_security_screen(lang),
            localization_theme_screen(lang),
            sop_handbook_screen(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


def main():
    langs = sys.argv[1:] or ["en", "ar"]

    # Open existing driver document if present
    driver_fig = os.path.join(ROOT, "output", "hanna-bus-driver.figcraft")
    if os.path.exists(driver_fig):
        res = fc.ex("file.open", path=driver_fig)
        print("opened existing:", driver_fig, res)

    build(langs)
    fc.ex("view.zoomFit")
    fc.ex("select.none")

    shots_dir = os.path.join(ROOT, "output", "screenshots")
    os.makedirs(shots_dir, exist_ok=True)
    out_png = os.path.join(shots_dir, "driver-06-settings-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    # Save to dedicated driver document files
    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-settings.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        print(f"saved: {fpath} ({os.path.getsize(fpath)} bytes)")


if __name__ == "__main__":
    main()
