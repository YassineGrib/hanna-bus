"""Build Page '03 · Settings & Account' (6 screens x 2 languages = 12 frames).

Screens:
  0. Settings (overview)
  1. Theme & Appearance (sub-screen: palette & light/dark mode)
  2. Notifications (sub-screen)
  3. Language (sub-screen)
  4. Terms & Privacy (sub-screen)
  5. Account Confirmations (sub-screen: Logout & Delete Account modals)
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

PAGE_NAME = "03 · Settings & Account"
GROUP = "Settings"
SCREENS = [
    "Settings",
    "Theme & Appearance",
    "Notifications",
    "Language",
    "Terms & Privacy",
    "Account Confirmations",
]
SECTIONS = {
    "en": "EN · Settings & Account (LTR)",
    "ar": "AR · الإعدادات والحساب (RTL)",
}

STR = {
 "en": dict(
  set_title="Settings",
  sec_appear="Appearance & Alerts",
  row_theme="Theme Palette", val_theme="Mustard",
  row_mode="Light / Dark Mode", mode_light="Light", mode_dark="Dark",
  row_notif="Notifications", sub_notif="Bus arrival & boarding alerts",
  sec_gen="General",
  row_lang="Language", val_lang="العربية / EN",
  row_terms="Terms & Privacy Policy",
  sec_acc="Account",
  btn_logout="Log out",
  del_title="Delete Account", del_sub="Permanently remove your parent profile and linked children.",
  btn_delete="Delete account",
  version="Hanna Bus v2.4.0",
  # Sub-screen 1: Theme & Appearance
  th_title="Theme & Appearance",
  th_sec_mode="Display Mode",
  th_m_light="Light Mode", th_m_light_s="Warm cream daylight view",
  th_m_dark="Dark Mode", th_m_dark_s="Low-glare night tracking view",
  th_sec_pal="Brand Color Palette",
  th_p1="Mustard Gold (Active)", th_p1_s="Bold · Warm · High visibility",
  th_p2="Teal / Slate Gray", th_p2_s="Calm · Minimal · Professional",
  th_p3="Ocean Blue", th_p3_s="Cool · Clean · Refreshing",
  th_apply="Apply theme preferences",
  # Sub-screen 2: Notifications
  nf_title="Notifications",
  nf_sec_bus="Live Bus & Child Alerts",
  nf_1_t="Bus Approaching Stop", nf_1_s="Alert when bus is 5 minutes from home",
  nf_2_t="Child Boarded Bus", nf_2_s="Instant QR scan confirmation",
  nf_3_t="Arrived at School / Home", nf_3_s="Safe arrival check-in notification",
  nf_4_t="Route Delays & Traffic", nf_4_s="Driver & dispatch schedule updates",
  nf_sec_ch="Delivery Channels",
  nf_5_t="Critical SOS Sound & Banner", nf_5_s="Always play sound for urgent alerts",
  nf_6_t="SMS Backup Alerts", nf_6_s="Send text when offline",
  # Sub-screen 3: Language
  lg_title="Language",
  lg_sub="Choose your preferred language. Layout direction (RTL / LTR) adjusts automatically.",
  lg_ar="العربية (Arabic)", lg_ar_s="RTL interface · IBM Plex Sans",
  lg_en="English", lg_en_s="LTR interface · Inter",
  lg_fr="Français (French)", lg_fr_s="LTR interface · Inter",
  lg_btn="Save language",
  # Sub-screen 4: Terms & Privacy
  tm_title="Terms & Privacy",
  tm_tab1="Terms of Use", tm_tab2="Privacy Policy",
  tm_updated="Effective date: November 2026 · Hanna Bus Safety Charter",
  tm_c1_t="1. Live GPS & Student Boarding Data",
  tm_c1_b="Location telemetry and QR boarding scans are encrypted end-to-end and shared exclusively with verified parents and school transport supervisors.",
  tm_c2_t="2. Parent & Guardian Responsibilities",
  tm_c2_b="Parents must keep emergency phone numbers current and accompany young students at designated neighborhood pickup stops.",
  tm_c3_t="3. Account Deletion & Data Retention",
  tm_c3_b="When you delete your account, all parent profile records and linked student tokens are purged within 24 hours.",
  tm_btn="Download PDF copy",
  # Sub-screen 5: Account Confirmations
  cf_title="Account Actions",
  cf_sec_lo="Sign Out Confirmation",
  cf_lo_t="Log out of Hanna Bus?",
  cf_lo_b="Live bus arrival notifications for Youssef and Amina will pause on this device until you sign back in.",
  cf_cancel="Cancel",
  cf_sec_del="Permanent Account Deletion",
  cf_del_t="Delete Account Permanently?",
  cf_del_b="This action cannot be undone. Your parent profile, linked children, and boarding passes will be permanently erased.",
  cf_del_lbl="Type DELETE to confirm",
  cf_del_val="DELETE",
  cf_del_btn="Delete permanently",
 ),
 "ar": dict(
  set_title="الإعدادات",
  sec_appear="المظهر والتنبيهات",
  row_theme="لوحة الألوان", val_theme="خردلي",
  row_mode="الوضع الفاتح / الداكن", mode_light="فاتح", mode_dark="داكن",
  row_notif="الإشعارات", sub_notif="تنبيهات وصول الحافلة والصعود",
  sec_gen="عام",
  row_lang="اللغة", val_lang="العربية / EN",
  row_terms="الشروط وسياسة الخصوصية",
  sec_acc="الحساب",
  btn_logout="تسجيل الخروج",
  del_title="حذف الحساب", del_sub="سيتم حذف حساب ولي الأمر وبيانات الأطفال المرتبطة نهائيًا.",
  btn_delete="حذف الحساب",
  version="هنّا باص الإصدار 2.4.0",
  # Sub-screen 1: Theme & Appearance
  th_title="المظهر ولوحة الألوان",
  th_sec_mode="وضع العرض",
  th_m_light="الوضع الفاتح", th_m_light_s="خلفية كريمية دافئة ومريحة نهارًا",
  th_m_dark="الوضع الداكن", th_m_dark_s="إضاءة منخفضة للتتبّع الليلي",
  th_sec_pal="لوحة ألوان الهوية",
  th_p1="الأصفر الخردلي (نشط)", th_p1_s="جريء · دافئ · وضوح عالٍ",
  th_p2="الأزرق الرمادي (Teal / Gray)", th_p2_s="هادئ · رسمي · متوازن",
  th_p3="أزرق المحيط (Ocean)", th_p3_s="نقي · عصري · مريح للعين",
  th_apply="تطبيق إعدادات المظهر",
  # Sub-screen 2: Notifications
  nf_title="إعدادات الإشعارات",
  nf_sec_bus="تنبيهات الحافلة والأطفال",
  nf_1_t="اقتراب الحافلة من المحطة", nf_1_s="تنبيه قبل وصول الحافلة بـ 5 دقائق",
  nf_2_t="صعود الطفل إلى الحافلة", nf_2_s="تأكيد فوري عند مسح بطاقة QR",
  nf_3_t="الوصول للمدرسة أو المنزل", nf_3_s="إشعار الاطمئنان عند الوصول الآمن",
  nf_4_t="تأخّر المسار وحركة المرور", nf_4_s="تحديثات السائق ومكتب الحركة",
  nf_sec_ch="قنوات التنبيه",
  nf_5_t="صوت تنبيهات الطوارئ الحرجة", nf_5_s="تشغيل الصوت دائمًا للتنبيهات العاجلة",
  nf_6_t="رسائل SMS الاحتياطية", nf_6_s="إرسال رسالة نصية عند انقطاع الإنترنت",
  # Sub-screen 3: Language
  lg_title="اللغة",
  lg_sub="اختر لغة التطبيق المفضّلة. يتم ضبط اتجاه الواجهة (من اليمين لليسار أو العكس) تلقائيًا.",
  lg_ar="العربية", lg_ar_s="واجهة عربية (RTL) · خط IBM Plex",
  lg_en="English (الإنجليزية)", lg_en_s="واجهة إنجليزية (LTR) · خط Inter",
  lg_fr="Français (الفرنسية)", lg_fr_s="واجهة فرنسية (LTR) · خط Inter",
  lg_btn="حفظ اللغة",
  # Sub-screen 4: Terms & Privacy
  tm_title="الشروط والخصوصية",
  tm_tab1="شروط الاستخدام", tm_tab2="سياسة الخصوصية",
  tm_updated="تاريخ السريان: نوفمبر 2026 · ميثاق أمان هنّا باص",
  tm_c1_t="1. بيانات التتبّع المباشر وبطاقات الصعود",
  tm_c1_b="تُشفَّر إحداثيات الحافلة وعمليات مسح رمز QR بالكامل، وتُشارك حصريًا مع أولياء الأمور الموثّقين ومشرفي النقل المدرسي.",
  tm_c2_t="2. مسؤوليات ولي الأمر",
  tm_c2_b="يلتزم ولي الأمر بتحديث أرقام الطوارئ ومرافقة الأطفال الصغار عند محطات التجمّع المعتمدة في الحي.",
  tm_c3_t="3. حذف الحساب والاحتفاظ بالبيانات",
  tm_c3_b="عند طلب حذف الحساب، تُمحى كافة بيانات ولي الأمر ورموز التلاميذ المرتبطة نهائيًا خلال 24 ساعة.",
  tm_btn="تحميل نسخة PDF",
  # Sub-screen 5: Account Confirmations
  cf_title="تأكيد إجراءات الحساب",
  cf_sec_lo="تأكيد تسجيل الخروج",
  cf_lo_t="هل تريد تسجيل الخروج؟",
  cf_lo_b="ستتوقف إشعارات وصول الحافلة المباشرة ليوسف وأمينة على هذا الجهاز حتى تسجّل الدخول مجددًا.",
  cf_cancel="إلغاء",
  cf_sec_del="تأكيد الحذف النهائي للحساب",
  cf_del_t="حذف الحساب نهائيًا؟",
  cf_del_b="لا يمكن التراجع عن هذا الإجراء. سيتم مسح ملف ولي الأمر وبيانات الأطفال وبطاقات الصعود نهائيًا.",
  cf_del_lbl="اكتب كلمة حذف للتأكيد",
  cf_del_val="حذف",
  cf_del_btn="حذف الحساب نهائيًا",
 ),
}


def switch_control(sc: Screen, x: int, y: int, on: bool = True):
    sc.rect(x, y, 48, 28, PRIMARY if on else BORDER, 14, "Switch track")
    tx = (x + 23) if on else (x + 3)
    sc.rect(tx, y + 3, 22, 22, SURF, 11, "Switch thumb")


def settings_main(lang: str) -> int:
    sc = Screen(lang, GROUP, "Settings", 0, STR); s = sc.s
    sc.status_bar()
    sc.header(s["set_title"], end_icon="gear")

    sc.section_label(s["sec_appear"], 118)
    sc.rect(18, 142, 357, 198, SURF, 20, "Appearance card", stroke=BORDER)

    sc.rect(32, 156, 36, 36, BG, 10, "Theme icon bg", stroke=BORDER)
    sc.icon("palette", 41, 165, 18, INK)
    sc.text(s["row_theme"], 80, 165, 15, INK, 600, name="Row Theme")
    sc.rect(236, 165, 18, 18, "#D4A017", 9, "Swatch Mustard", stroke=INK)
    sc.rect(258, 165, 18, 18, "#455A64", 9, "Swatch Teal", stroke=BORDER)
    sc.text(s["val_theme"], 52, 166, 13, LINK, 600, align="end", name="Theme value")
    sc.chevron(342, 165)

    sc.rect(34, 206, 325, 1, BORDER, 0, "Settings divider 1")
    sc.rect(32, 222, 36, 36, BG, 10, "Mode icon bg", stroke=BORDER)
    sc.icon("sun", 41, 231, 18, INK)
    sc.text(s["row_mode"], 80, 231, 15, INK, 600, name="Row Mode")
    sc.rect(236, 223, 122, 34, BG, 12, "Mode segmented bg", stroke=BORDER)
    sc.rect(239, 226, 58, 28, PRIMARY, 9, "Mode Light active")
    tl = sc.text(s["mode_light"], 0, 232, 12, ONP, 700, name="Mode Light text")
    S(tl, x=sc.ax(239, 58) + (58 - width(tl)) / 2)
    td = sc.text(s["mode_dark"], 0, 232, 12, MUTED, 600, name="Mode Dark text")
    S(td, x=sc.ax(299, 56) + (56 - width(td)) / 2)

    sc.rect(34, 274, 325, 1, BORDER, 0, "Settings divider 2")
    sc.rect(32, 289, 36, 36, BG, 10, "Notif icon bg", stroke=BORDER)
    sc.icon("bell", 41, 298, 18, INK)
    sc.text(s["row_notif"], 80, 288, 15, INK, 600, name="Row Notif")
    sc.text(s["sub_notif"], 80, 309, 12, MUTED, 400, name="Sub Notif")
    switch_control(sc, 310, 293, True)

    sc.section_label(s["sec_gen"], 356)
    sc.rect(18, 380, 357, 124, SURF, 20, "General card", stroke=BORDER)
    sc.rect(32, 393, 36, 36, BG, 10, "Lang icon bg", stroke=BORDER)
    sc.icon("translate", 41, 402, 18, INK)
    sc.text(s["row_lang"], 80, 402, 15, INK, 600, name="Row Lang")
    sc.rect(254, 397, 82, 28, BG, 10, "Lang pill", stroke=BORDER)
    t_lg = sc.text(s["val_lang"], 0, 403, 12, INK, 600, name="Lang val")
    S(t_lg, x=sc.ax(254, 82) + (82 - width(t_lg)) / 2)
    sc.chevron(342, 402)

    sc.rect(34, 442, 325, 1, BORDER, 0, "General divider")
    sc.rect(32, 455, 36, 36, BG, 10, "Terms icon bg", stroke=BORDER)
    sc.icon("file-text", 41, 464, 18, INK)
    sc.text(s["row_terms"], 80, 464, 15, INK, 600, name="Row Terms")
    sc.chevron(342, 464)

    sc.section_label(s["sec_acc"], 520)
    sc.secondary_button(s["btn_logout"], 544, lead_icon="sign-out")

    sc.rect(18, 614, 357, 142, DSURF, 20, "Delete account card", stroke=DBORD)
    sc.icon("trash", 34, 630, 20, DESTR)
    sc.text(s["del_title"], 62, 629, 15, DESTR, 700, name="Delete title")
    sc.text(s["del_sub"], 34, 654, 12, MUTED, 400, w=325, name="Delete sub")
    sc.rect(34, 696, 325, 46, DESTR, 14, "Delete CTA button")
    t_del = sc.text(s["btn_delete"], 0, 709, 15, OND, 700, align="center", name="Delete CTA label")
    w_del = width(t_del); dgx = (W - (18 + 8 + w_del)) / 2
    if sc.rtl:
        S(t_del, x=dgx); icon(sc.F, "trash", dgx + w_del + 8, 710, 18, OND)
    else:
        icon(sc.F, "trash", dgx, 710, 18, OND); S(t_del, x=dgx + 26)

    sc.text(s["version"], 0, 782, 12, MUTED, 500, align="center", name="Version")
    return sc.F


def theme_appearance(lang: str) -> int:
    sc = Screen(lang, GROUP, "Theme & Appearance", 1, STR); s = sc.s
    sc.status_bar()
    sc.header(s["th_title"])

    # Display Mode (Light / Dark cards side by side)
    sc.section_label(s["th_sec_mode"], 122)
    modes = [
        (18, s["th_m_light"], s["th_m_light_s"], "sun", True, "#FFFDF5", INK),
        (202, s["th_m_dark"], s["th_m_dark_s"], "moon", False, "#263238", "#FFFFFF"),
    ]
    for mx, mt, ms, mic, active, pbg, pfg in modes:
        sc.rect(mx, 148, 173, 148, SURF, 20, f"Mode card {mt}", stroke=PRIMARY if active else BORDER)
        # Mini preview window inside card
        sc.rect(mx + 14, 162, 145, 58, pbg, 12, f"Preview {mt}", stroke=BORDER)
        sc.icon(mic, mx + 26, 179, 22, pfg)
        sc.rect(mx + 58, 182, 84, 8, "#D4A017", 4, "Mini bar 1")
        sc.rect(mx + 58, 196, 56, 6, MUTED, 3, "Mini bar 2")
        sc.text(mt, mx + 14, 232, 14, INK, 700, name=f"Title {mt}")
        sc.text(ms, mx + 14, 254, 11, MUTED, 400, w=145, name=f"Sub {mt}")

    # Brand Color Palettes
    sc.section_label(s["th_sec_pal"], 314)
    palettes = [
        (340, s["th_p1"], s["th_p1_s"], ["#2B2B2B", "#D4A017", "#F0C94C", "#F7E7B5"], True),
        (434, s["th_p2"], s["th_p2_s"], ["#263238", "#455A64", "#80CBC4", "#CFD8DC"], False),
        (528, s["th_p3"], s["th_p3_s"], ["#0D1B2A", "#1B4965", "#29ADB2", "#A8DADC"], False),
    ]
    for py, pt, ps, cols, active in palettes:
        sc.rect(18, py, 357, 82, SURF, 20, f"Palette {pt}", stroke=PRIMARY if active else BORDER)
        sc.text(pt, 34, py + 16, 15, INK, 700, name=f"Pal title {pt}")
        sc.text(ps, 34, py + 40, 12, MUTED, 400, name=f"Pal sub {pt}")
        for ci, c_hex in enumerate(cols):
            sc.rect(240 + ci * 22, py + 28, 18, 26, c_hex, 6, f"Swatch {ci}", stroke=BORDER)
        sc.rect(338, py + 30, 22, 22, PRIMARY if active else BG, 11, "Radio circle", stroke=PRIMARY if active else BORDER)
        if active:
            sc.icon("check", 343, py + 35, 12, ONP)

    sc.button(s["th_apply"], 742, lead_icon="check")
    return sc.F


def notifications_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Notifications", 2, STR); s = sc.s
    sc.status_bar()
    sc.header(s["nf_title"])

    sc.section_label(s["nf_sec_bus"], 122)
    sc.rect(18, 146, 357, 304, SURF, 20, "Bus alerts card", stroke=BORDER)
    rows1 = [
        (146, "bus", s["nf_1_t"], s["nf_1_s"], True),
        (222, "qr-code", s["nf_2_t"], s["nf_2_s"], True),
        (298, "shield-check", s["nf_3_t"], s["nf_3_s"], True),
        (374, "clock", s["nf_4_t"], s["nf_4_s"], False),
    ]
    for idx, (ry, icn, rt, rs, on) in enumerate(rows1):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"Notif div {idx}")
        sc.rect(32, ry + 18, 38, 38, ACCENT if on else BG, 12, f"Notif icon {idx}", stroke=BORDER)
        sc.icon(icn, 42, ry + 28, 18, INK)
        sc.text(rt, 82, ry + 17, 14, INK, 700, name=f"Title {rt}")
        sc.text(rs, 82, ry + 39, 12, MUTED, 400, name=f"Sub {rt}")
        switch_control(sc, 310, ry + 24, on)

    sc.section_label(s["nf_sec_ch"], 470)
    sc.rect(18, 494, 357, 152, SURF, 20, "Channels card", stroke=BORDER)
    rows2 = [
        (494, "bell", s["nf_5_t"], s["nf_5_s"], True),
        (570, "phone", s["nf_6_t"], s["nf_6_s"], True),
    ]
    for idx, (ry, icn, rt, rs, on) in enumerate(rows2):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"Ch div {idx}")
        sc.rect(32, ry + 18, 38, 38, ACCENT if on else BG, 12, f"Ch icon {idx}", stroke=BORDER)
        sc.icon(icn, 42, ry + 28, 18, INK)
        sc.text(rt, 82, ry + 17, 14, INK, 700, name=f"Title {rt}")
        sc.text(rs, 82, ry + 39, 12, MUTED, 400, name=f"Sub {rt}")
        switch_control(sc, 310, ry + 24, on)
    return sc.F


def language_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Language", 3, STR); s = sc.s
    sc.status_bar()
    sc.header(s["lg_title"])
    sc.sub(s["lg_sub"], 124, w=325)

    langs_list = [
        (196, s["lg_ar"], s["lg_ar_s"], "AR", lang == "ar"),
        (292, s["lg_en"], s["lg_en_s"], "EN", lang == "en"),
        (388, s["lg_fr"], s["lg_fr_s"], "FR", False),
    ]
    for ly, lt, ls, code, active in langs_list:
        sc.rect(18, ly, 357, 82, SURF, 20, f"Lang card {code}", stroke=PRIMARY if active else BORDER)
        sc.rect(32, ly + 18, 46, 46, ACCENT if active else BG, 14, f"Lang badge {code}", stroke=BORDER)
        t_cd = mk("text.create", text=code, x=0, y=ly + 31, parent=sc.F, select=False, name=f"Code {code}",
                  props={"fontSize": 15, "fontFamily": "Inter", "fontWeight": 700, "fill": INK})
        S(t_cd, x=sc.ax(32, 46) + (46 - width(t_cd)) / 2)
        sc.text(lt, 90, ly + 18, 15, INK, 700, name=f"Lang title {code}")
        sc.text(ls, 90, ly + 42, 12, MUTED, 400, name=f"Lang sub {code}")
        sc.rect(334, ly + 29, 24, 24, PRIMARY if active else BG, 12, f"Radio {code}", stroke=PRIMARY if active else BORDER)
        if active:
            sc.icon("check", 339, ly + 34, 14, ONP)

    sc.button(s["lg_btn"], 742, lead_icon="globe")
    return sc.F


def terms_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Terms & Privacy", 4, STR); s = sc.s
    sc.status_bar()
    sc.header(s["tm_title"])

    # Segmented tabs
    sc.rect(18, 120, 357, 44, SURF, 14, "Terms tabs bg", stroke=BORDER)
    sc.rect(22, 124, 174, 36, PRIMARY, 10, "Active tab")
    t1 = sc.text(s["tm_tab1"], 0, 133, 13, ONP, 700, name="Tab 1")
    S(t1, x=sc.ax(22, 174) + (174 - width(t1)) / 2)
    t2 = sc.text(s["tm_tab2"], 0, 133, 13, MUTED, 600, name="Tab 2")
    S(t2, x=sc.ax(198, 173) + (173 - width(t2)) / 2)

    sc.text(s["tm_updated"], 0, 178, 11, LINK, 600, align="center", name="Effective date")

    clauses = [
        (206, s["tm_c1_t"], s["tm_c1_b"]),
        (368, s["tm_c2_t"], s["tm_c2_b"]),
        (530, s["tm_c3_t"], s["tm_c3_b"]),
    ]
    for cy, ct, cb in clauses:
        sc.rect(18, cy, 357, 148, SURF, 20, f"Clause {ct}", stroke=BORDER)
        sc.text(ct, 34, cy + 18, 15, INK, 700, name=f"Clause title {ct}")
        sc.text(cb, 34, cy + 48, 12, MUTED, 400, w=325, name=f"Clause body {ct}")

    sc.secondary_button(s["tm_btn"], 736, lead_icon="download-simple")
    return sc.F


def account_confirmations(lang: str) -> int:
    sc = Screen(lang, GROUP, "Account Confirmations", 5, STR); s = sc.s
    sc.status_bar()
    sc.header(s["cf_title"])

    # 1. Logout Confirmation Modal Card
    sc.section_label(s["cf_sec_lo"], 120)
    sc.rect(18, 144, 357, 212, SURF, 24, "Logout modal card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 24, "color": INK + "14"}])
    sc.rect(34, 162, 44, 44, ACCENT, 14, "Logout icon badge")
    sc.icon("sign-out", 45, 173, 22, INK)
    sc.text(s["cf_lo_t"], 90, 166, 16, INK, 700, name="Logout modal title")
    sc.text(s["cf_lo_b"], 34, 218, 12, MUTED, 400, w=325, name="Logout modal body")
    # Two horizontal buttons: Cancel (neutral) & Log out (primary)
    sc.rect(34, 292, 156, 46, BG, 14, "Logout cancel btn", stroke=BORDER)
    tc1 = sc.text(s["cf_cancel"], 0, 306, 14, INK, 700, name="Logout cancel lbl")
    S(tc1, x=sc.ax(34, 156) + (156 - width(tc1)) / 2)
    sc.rect(203, 292, 156, 46, PRIMARY, 14, "Logout confirm btn")
    tc2 = sc.text(s["btn_logout"], 0, 306, 14, ONP, 700, name="Logout confirm lbl")
    S(tc2, x=sc.ax(203, 156) + (156 - width(tc2)) / 2)

    # 2. Delete Account Confirmation Modal Card (strictly uses action-destructive everywhere)
    sc.section_label(s["cf_sec_del"], 378)
    sc.rect(18, 402, 357, 386, DSURF, 24, "Delete modal card", stroke=DBORD,
            effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 24, "color": INK + "14"}])
    sc.rect(34, 420, 48, 48, DESTR, 16, "Delete warning badge")
    sc.icon("warning-circle", 46, 432, 24, OND)
    sc.text(s["cf_del_t"], 94, 424, 16, DESTR, 700, name="Delete modal title")
    sc.text(s["cf_del_b"], 34, 480, 12, MUTED, 400, w=325, name="Delete modal body")

    # Confirmation keyword input field
    sc.text(s["cf_del_lbl"], 34, 558, 12, INK, 600, name="Delete input label")
    sc.rect(34, 580, 325, 48, SURF, 14, "Delete confirm input", stroke=DESTR)
    sc.text(s["cf_del_val"], 50, 595, 15, DESTR, 700, name="Delete input val")

    # Destructive primary button + neutral cancel button
    sc.rect(34, 646, 325, 50, DESTR, 16, "Delete permanent CTA")
    t_dp = sc.text(s["cf_del_btn"], 0, 661, 15, OND, 700, align="center", name="Delete permanent lbl")
    wdp = width(t_dp); dgx = (W - (18 + 8 + wdp)) / 2
    if sc.rtl:
        S(t_dp, x=dgx); icon(sc.F, "trash", dgx + wdp + 8, 662, 18, OND)
    else:
        icon(sc.F, "trash", dgx, 662, 18, OND); S(t_dp, x=dgx + 26)

    sc.rect(34, 710, 325, 46, SURF, 14, "Delete cancel btn", stroke=BORDER)
    sc.text(s["cf_cancel"], 0, 724, 14, INK, 700, align="center", name="Delete cancel lbl")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            settings_main(lang),
            theme_appearance(lang),
            notifications_screen(lang),
            language_screen(lang),
            terms_screen(lang),
            account_confirmations(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
