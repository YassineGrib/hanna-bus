"""Build Page '06 · Home Dashboard' (5 screens x 2 languages = 10 frames).

Screens:
  0. Home Dashboard (welcome section, live active-ride hero card, quick actions, children today, updates, bottom nav)
  1. Home Afternoon State (safe-at-school hero state, afternoon pickup countdown, recent check-ins, bottom nav)
  2. Notifications Center (filterable live boarding & school alerts with mark-all-read)
  3. Quick QR Boarding Pass (high-contrast digital student bus pass + offline save)
  4. School Updates & Support (transport bulletins + direct message to driver/coordinator)
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

PAGE_NAME = "06 · Home Dashboard"
GROUP = "Home"
SCREENS = [
    "Home Dashboard",
    "Home Afternoon State",
    "Notifications Center",
    "Quick QR Boarding Pass",
    "School Updates & Support",
]
SECTIONS = {
    "en": "EN · Home Dashboard (LTR)",
    "ar": "AR · الشاشة الرئيسية (RTL)",
}

STR = {
 "en": dict(
  # Shared Welcome & Bottom Nav
  greet_am="Good morning, Karim",
  greet_pm="Good afternoon, Karim",
  date_sub="Tue, 10 Nov · School Day",
  nav_home="Home", nav_track="Tracking", nav_child="Children", nav_prof="Profile",

  # Screen 0: Home Dashboard (Active Ride Hero)
  hero_live="LIVE · BUS 04",
  hero_child="Youssef M.",
  hero_eta="4 min",
  hero_dest="Arriving at El Wiam Primary",
  hero_loc="1.2 km away · Blvd des Martyrs",
  hero_s1="Hay El Nasr 07:16",
  hero_s2="El Wiam 07:40",
  hero_btn1="Track Live",
  hero_btn2="Call Driver",
  sec_quick="Quick Actions",
  qa_qr="QR Pass", qa_abs="Absence", qa_sched="Schedule", qa_sos="SOS Call",
  sec_today="My Children Today",
  see_all="See all",
  ch1_n="Youssef Mansouri", ch1_s="Bus 04 · Boarded 07:16 AM", ch1_b="On Bus · 4m",
  ch2_n="Amina Mansouri", ch2_s="Bus 02 · Checked in 07:42 AM", ch2_b="At School",
  sec_upd="School & Route Updates",
  upd_more="All updates",
  upd_t="Afternoon Return · 03:20 PM",
  upd_s="East Gate pickup confirmed for both buses.",

  # Screen 1: Home Afternoon State (Safe at School)
  pm_badge="ALL SAFE AT SCHOOL",
  pm_title="2 of 2 Checked In",
  pm_sub="Next pickup: Bus 04 in 2h 15m (03:20 PM)",
  pm_c1="Youssef · 07:40 AM",
  pm_c2="Amina · 07:42 AM",
  pm_btn="View afternoon schedule",
  sec_next="Upcoming Afternoon Pickups",
  nx1_t="03:20 PM · Bus 04 Return", nx1_s="Youssef · El Wiam East Gate", nx1_b="In 2h 15m",
  nx2_t="04:00 PM · Bus 02 Return", nx2_s="Amina · Ibn Khaldoun Gate B", nx2_b="In 2h 55m",
  sec_act="Recent Check-ins",
  act_t="07:42 AM · Both children at school",
  act_s="QR boarding & gate entry verified with zero delays.",

  # Screen 2: Notifications Center
  nf_title="Notifications",
  nf_all="All (5)", nf_bus="Bus Alerts", nf_sch="School",
  nf_mark="Mark all read",
  nf_d1="Today",
  n1_t="Approaching El Wiam Gate", n1_s="Bus 04 is 4 min from school entrance.", n1_tm="2m ago",
  n2_t="Youssef Boarded Bus 04", n2_s="QR #HB-304 scanned at Hay El Nasr Stop 03.", n2_tm="07:16 AM",
  n3_t="Amina Arrived at School", n3_s="Checked in safely at Ibn Khaldoun Middle.", n3_tm="07:42 AM",
  nf_d2="Yesterday",
  n4_t="Thursday Early Dismissal", n4_s="Afternoon buses depart at 02:30 PM this Thursday.", n4_tm="Mon 04:10 PM",

  # Screen 3: Quick QR Boarding Pass
  qr_title="Quick QR Pass",
  qr_c1="Youssef · Bus 04", qr_c2="Amina · Bus 02",
  qr_id="Student ID: #HB-304",
  qr_seat="Bus 04 · Seat A2",
  qr_stop="Hay El Nasr Stop 03 → El Wiam Primary",
  qr_valid="Active Pass · Valid Tue 10 Nov 2026",
  qr_save="Save pass for offline use",
  qr_share="Share pass with co-guardian",

  # Screen 4: School Updates & Support
  up_title="Updates & Support",
  up_sec_bul="Official School Bulletins",
  b1_tag="SCHEDULE", b1_t="Early Dismissal This Thursday",
  b1_s="School closes at 02:15 PM. Bus 04 & Bus 02 depart at 02:30 PM.",
  b2_tag="STOP UPDATE", b2_t="New Lighting at Hay El Nasr Stop 03",
  b2_s="Solar street lamps and shaded shelter installed for morning pickups.",
  b3_tag="TERM NOTICE", b3_t="Winter Term Route Verification",
  b3_s="Confirm home drop-off stops before 20 Nov in Profile.",
  up_sec_sup="Transport Support",
  sup_t="Need a quick pickup adjustment?",
  sup_s="Message Bus 04 driver Ahmed B. or the school transport desk.",
  sup_btn="Message transport desk",
 ),
 "ar": dict(
  # Shared Welcome & Bottom Nav
  greet_am="صباح الخير، كريم",
  greet_pm="مساء الخير، كريم",
  date_sub="الثلاثاء 10 نوفمبر · يوم دراسي",
  nav_home="الرئيسية", nav_track="التتبّع", nav_child="أطفالي", nav_prof="حسابي",

  # Screen 0: Home Dashboard (Active Ride Hero)
  hero_live="مباشر · حافلة 04",
  hero_child="يوسف م.",
  hero_eta="4 دقائق",
  hero_dest="الوصول إلى ابتدائية الوئام",
  hero_loc="على بُعد 1.2 كم · شارع الشهداء",
  hero_s1="حي النصر 07:16",
  hero_s2="الوئام 07:40",
  hero_btn1="تتبّع مباشر",
  hero_btn2="اتصال بالسائق",
  sec_quick="إجراءات سريعة",
  qa_qr="بطاقة QR", qa_abs="غياب", qa_sched="البرنامج", qa_sos="طوارئ",
  sec_today="أطفالي اليوم",
  see_all="عرض الكل",
  ch1_n="يوسف منصوري", ch1_s="حافلة 04 · صعد 07:16 ص", ch1_b="في الحافلة · 4 د",
  ch2_n="أمينة منصوري", ch2_s="حافلة 02 · وصلت 07:42 ص", ch2_b="في المدرسة",
  sec_upd="تحديثات المدرسة والمسار",
  upd_more="كل الإعلانات",
  upd_t="رحلة العودة · 03:20 م",
  upd_s="موعد الصعود مؤكّد من البوابة الشرقية للحافلتين.",

  # Screen 1: Home Afternoon State (Safe at School)
  pm_badge="الجميع بأمان في المدرسة",
  pm_title="2 من 2 في المدرسة",
  pm_sub="الانطلاق القادم: حافلة 04 بعد ساعتين و 15 د (03:20 م)",
  pm_c1="يوسف · دخل 07:40 ص",
  pm_c2="أمينة · دخلت 07:42 ص",
  pm_btn="عرض جدول العودة المسائي",
  sec_next="رحلات العودة القادمة",
  nx1_t="03:20 م · عودة الحافلة 04", nx1_s="يوسف · البوابة الشرقية للوئام", nx1_b="بعد 2 س 15 د",
  nx2_t="04:00 م · عودة الحافلة 02", nx2_s="أمينة · بوابة ب لابن خلدون", nx2_b="بعد 2 س 55 د",
  sec_act="آخر التأكيدات",
  act_t="07:42 ص · وصول الطفلين للمدرسة بأمان",
  act_s="تم توثيق الصعود والدخول ببطاقة QR دون أي تأخير.",

  # Screen 2: Notifications Center
  nf_title="الإشعارات",
  nf_all="الكل (5)", nf_bus="الحافلة", nf_sch="المدرسة",
  nf_mark="تحديد الكل كمقروء",
  nf_d1="اليوم",
  n1_t="الحافلة تقترب من المدرسة", n1_s="الحافلة 04 على بُعد 4 دقائق من بوابة الوئام.", n1_tm="منذ دقيقتين",
  n2_t="صعود يوسف للحافلة 04", n2_s="تم مسح البطاقة #HB-304 في محطة حي النصر 03.", n2_tm="07:16 ص",
  n3_t="وصول أمينة للمدرسة", n3_s="تم تأكيد الدخول بأمان في متوسطة ابن خلدون.", n3_tm="07:42 ص",
  nf_d2="أمس",
  n4_t="انصراف مبكّر يوم الخميس", n4_s="تنطلق حافلات العودة الساعة 02:30 م هذا الخميس.", n4_tm="الإثنين 04:10 م",

  # Screen 3: Quick QR Boarding Pass
  qr_title="بطاقة الصعود السريعة",
  qr_c1="يوسف · حافلة 04", qr_c2="أمينة · حافلة 02",
  qr_id="رمز التلميذ: #HB-304",
  qr_seat="الحافلة 04 · مقعد A2",
  qr_stop="محطة حي النصر 03 ← ابتدائية الوئام",
  qr_valid="بطاقة فعّالة · الثلاثاء 10 نوفمبر 2026",
  qr_save="حفظ البطاقة للاستخدام دون إنترنت",
  qr_share="مشاركة البطاقة مع ولي الأمر الثاني",

  # Screen 4: School Updates & Support
  up_title="التحديثات والدعم",
  up_sec_bul="إعلانات المدرسة والنقل",
  b1_tag="المواعيد", b1_t="انصراف مبكّر يوم الخميس القادم",
  b1_s="ينتهي الدوام 02:15 م وتنطلق الحافلات الساعة 02:30 م.",
  b2_tag="تطوير", b2_t="إنارة ومظلة جديدة لمحطة حي النصر 03",
  b2_s="تم تزويد المحطة بإنارة شمسية ومظلة انتظار لرحلات الصباح.",
  b3_tag="تنبيه", b3_t="تأكيد محطات الفصل الشتوي",
  b3_s="يرجى مراجعة محطة النزول المعتمدة قبل 20 نوفمبر في ملفك.",
  up_sec_sup="مكتب دعم النقل المدرسي",
  sup_t="هل تحتاج إلى تعديل سريع للمحطة؟",
  sup_s="تواصل مباشرة مع سائق الحافلة 04 أو مشرف النقل المدرسي.",
  sup_btn="مراسلة مكتب النقل",
 ),
}


def welcome_header(sc: Screen, greeting: str):
    """Draw the top Welcome bar: parent avatar, greeting + date, and notification bell with unread dot."""
    s = sc.s
    # Avatar badge
    sc.rect(18, 56, 44, 44, ACCENT, 22, "Welcome avatar", stroke=PRIMARY)
    sc.icon("user", 29, 67, 22, INK)

    # Greeting & date
    sc.text(greeting, 72, 56, 18, INK, 700, name="Welcome greeting")
    sc.text(s["date_sub"], 72, 82, 12, MUTED, 500, name="Welcome date")

    # Notification bell with unread indicator dot
    sc.rect(331, 56, 44, 44, SURF, 22, "Bell button", stroke=BORDER)
    sc.icon("bell", 343, 68, 20, INK)
    sc.rect(361, 63, 8, 8, DESTR, 4, "Bell unread dot", stroke=SURF)


def bottom_nav(sc: Screen, active: int = 0):
    """Draw the floating capsule 4-item bottom navigation bar above the home indicator."""
    s = sc.s
    sc.rect(
        18,
        752,
        357,
        64,
        INK,
        32,
        "Floating bottom navbar",
        stroke=PRIMARY + "35",
        effects=[{"type": "dropShadow", "offset": [0, 10], "radius": 24, "color": INK + "2E"}],
        mirror=False,
    )
    items = [
        ("house", s["nav_home"]),
        ("navigation-arrow", s["nav_track"]),
        ("users", s["nav_child"]),
        ("user", s["nav_prof"]),
    ]
    cur_x = 26
    for idx, (icn, lbl) in enumerate(items):
        is_act = idx == active
        slot_w = 112 if is_act else 76
        if is_act:
            sc.rect(cur_x, 760, slot_w, 48, PRIMARY, 24, f"Nav active pill {lbl}")
            tl = sc.text(lbl, 0, 775, 12, ONP, 700, name=f"Nav lbl {lbl}")
            wt = width(tl)
            gx = sc.ax(cur_x, slot_w) + (slot_w - (18 + 6 + wt)) / 2
            if sc.rtl:
                S(tl, x=gx)
                icon(sc.F, icn, gx + wt + 6, 775, 18, ONP)
            else:
                icon(sc.F, icn, gx, 775, 18, ONP)
                S(tl, x=gx + 24)
        else:
            sc.icon(icn, cur_x + (slot_w - 20) / 2, 766, 20, BORDER)
            tl = sc.text(lbl, 0, 790, 10, BORDER, 500, name=f"Nav lbl {lbl}")
            S(tl, x=sc.ax(cur_x, slot_w) + (slot_w - width(tl)) / 2)
        cur_x += slot_w
    sc.rect(127, 834, 139, 5, INK, 3, "Home indicator", mirror=False)


def quick_actions_row(sc: Screen, y: int):
    """Draw 4 floating squircle quick-action buttons with centered labels below."""
    s = sc.s
    sc.section_label(s["sec_quick"], y)
    actions = [
        ("qr-code", s["qa_qr"], ACCENT, INK, PRIMARY),
        ("calendar-blank", s["qa_abs"], SURF, INK, BORDER),
        ("clock", s["qa_sched"], SURF, INK, BORDER),
        ("warning-circle", s["qa_sos"], DSURF, DESTR, DBORD),
    ]
    for idx, (icn, lbl, bg, fg, bord) in enumerate(actions):
        col_x = 18 + idx * 91
        sc.rect(col_x + 14, y + 26, 56, 56, bg, 18, f"QA {lbl}", stroke=bord,
                effects=[{"type": "dropShadow", "offset": [0, 3], "radius": 10, "color": INK + "10"}])
        sc.icon(icn, col_x + 30, y + 42, 24, fg)
        tl = sc.text(lbl, 0, y + 88, 11, DESTR if fg == DESTR else INK, 700 if idx in (0, 3) else 600, name=f"QA lbl {lbl}")
        S(tl, x=sc.ax(col_x, 84) + (84 - width(tl)) / 2)


def home_dashboard(lang: str) -> int:
    sc = Screen(lang, GROUP, "Home Dashboard", 0, STR); s = sc.s
    sc.status_bar()
    welcome_header(sc, s["greet_am"])

    # Hero Section: Elevated Dark Charcoal Card (dominant focal point, display ETA >= 2.5x body)
    sc.hero_frame(18, 114, 357, 204, INK, 26, dark=True, name="Hero live card",
                  effects=[{"type": "dropShadow", "offset": [0, 10], "radius": 24, "color": INK + "30"}])

    # Top row inside Hero: LIVE pill + Child pill
    sc.rect(34, 130, 114, 26, PRIMARY, 13, "Hero live pill")
    tl = sc.text(s["hero_live"], 0, 136, 10, ONP, 700, name="Hero live txt")
    S(tl, x=sc.ax(34, 114) + (114 - width(tl)) / 2)

    sc.rect(252, 130, 107, 26, SURF, 13, "Hero child pill")
    tc = sc.text(s["hero_child"], 0, 136, 11, INK, 700, name="Hero child txt")
    S(tc, x=sc.ax(252, 107) + (107 - width(tc)) / 2)

    # Display ETA & destination
    sc.text(s["hero_eta"], 34, 166, 36, SURF, 700, name="Hero ETA")
    sc.text(s["hero_dest"], 34, 212, 13, ACCENT, 700, name="Hero dest")
    sc.text(s["hero_loc"], 34, 231, 11, BORDER, 400, name="Hero loc")

    # Mini route progress bar inside Hero
    sc.rect(34, 254, 325, 4, MUTED, 2, "Hero route track", mirror=False)
    sc.rect(34, 254, 224, 4, ACCENT, 2, "Hero route fill")

    # Hero Dual CTAs (Track Live + Call Driver)
    sc.rect(34, 268, 186, 38, PRIMARY, 12, "Hero track btn")
    t_b1 = sc.text(s["hero_btn1"], 0, 278, 13, ONP, 700, name="Hero track lbl")
    S(t_b1, x=sc.ax(34, 186) + (186 - width(t_b1)) / 2)

    sc.rect(228, 268, 131, 38, SURF, 12, "Hero call btn")
    t_b2 = sc.text(s["hero_btn2"], 0, 278, 13, INK, 700, name="Hero call lbl")
    S(t_b2, x=sc.ax(228, 131) + (131 - width(t_b2)) / 2)

    # Quick Actions Section (y=332..442)
    quick_actions_row(sc, 332)

    # Suggested Section 1: My Children Today (y=452..598)
    sc.section_label(s["sec_today"], 452, action=s["see_all"])
    rows = [
        (476, s["ch1_n"], s["ch1_s"], s["ch1_b"], ACCENT, PRIMARY, ONP),
        (542, s["ch2_n"], s["ch2_s"], s["ch2_b"], BG, ACCENT, INK),
    ]
    for cy, cn, cs, cb, ibg, pbg, pfg in rows:
        sc.rect(18, cy, 357, 58, SURF, 18, f"Home child {cn}", stroke=BORDER)
        sc.rect(32, cy + 10, 38, 38, ibg, 19, f"Home child ic {cn}", stroke=BORDER)
        sc.icon("bus", 41, cy + 19, 20, INK)
        sc.text(cn, 80, cy + 10, 14, INK, 700, name=f"Home ch n {cn}")
        sc.text(cs, 80, cy + 31, 11, MUTED, 400, name=f"Home ch s {cn}")
        sc.rect(266, cy + 15, 95, 28, pbg, 14, f"Home ch b {cn}")
        tb = sc.text(cb, 0, cy + 21, 10, pfg, 700, name=f"Home ch bl {cn}")
        S(tb, x=sc.ax(266, 95) + (95 - width(tb)) / 2)

    # Suggested Section 2: School & Route Updates (y=612..732)
    sc.section_label(s["sec_upd"], 612, action=s["upd_more"])
    sc.rect(18, 636, 357, 96, SURF, 20, "Home update card", stroke=BORDER)
    sc.rect(32, 652, 44, 44, ACCENT, 14, "Update icon bg")
    sc.icon("megaphone", 43, 663, 22, INK)
    sc.text(s["upd_t"], 88, 652, 14, INK, 700, name="Home update title")
    sc.text(s["upd_s"], 88, 676, 12, MUTED, 400, w=270, name="Home update sub")

    bottom_nav(sc, active=0)
    return sc.F


def home_afternoon(lang: str) -> int:
    sc = Screen(lang, GROUP, "Home Afternoon State", 1, STR); s = sc.s
    sc.status_bar()
    welcome_header(sc, s["greet_pm"])

    # Afternoon Safe-at-School Hero Card (Warm Surface with full PRIMARY border)
    sc.hero_frame(18, 114, 357, 204, SURF, 26, stroke=PRIMARY, dark=False, name="Afternoon hero card",
                  effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 20, "color": INK + "14"}])
    sc.rect(34, 130, 160, 26, ACCENT, 13, "Safe badge")
    ts = sc.text(s["pm_badge"], 0, 136, 10, INK, 700, name="Safe badge txt")
    S(ts, x=sc.ax(34, 160) + (160 - width(ts)) / 2)
    sc.icon("shield-check", 333, 131, 24, LINK)

    sc.text(s["pm_title"], 34, 168, 30, INK, 700, name="Afternoon title")
    sc.text(s["pm_sub"], 34, 210, 12, MUTED, 500, name="Afternoon sub")

    # Child check-in pills inside hero
    sc.rect(34, 236, 158, 28, BG, 10, "Safe pill 1", stroke=BORDER)
    tp1 = sc.text(s["pm_c1"], 0, 243, 11, INK, 600, name="Safe p1 txt")
    S(tp1, x=sc.ax(34, 158) + (158 - width(tp1)) / 2)
    sc.rect(200, 236, 158, 28, BG, 10, "Safe pill 2", stroke=BORDER)
    tp2 = sc.text(s["pm_c2"], 0, 243, 11, INK, 600, name="Safe p2 txt")
    S(tp2, x=sc.ax(200, 158) + (158 - width(tp2)) / 2)

    sc.rect(34, 272, 325, 36, PRIMARY, 12, "Afternoon CTA")
    sc.text(s["pm_btn"], 0, 281, 13, ONP, 700, align="center", name="Afternoon CTA lbl")

    # Quick Actions Section
    quick_actions_row(sc, 332)

    # Upcoming Afternoon Pickups
    sc.section_label(s["sec_next"], 452)
    pickups = [
        (476, s["nx1_t"], s["nx1_s"], s["nx1_b"], ACCENT, INK),
        (542, s["nx2_t"], s["nx2_s"], s["nx2_b"], BG, MUTED),
    ]
    for py, pt, ps, pb, bbg, bfg in pickups:
        sc.rect(18, py, 357, 58, SURF, 18, f"Pickup {pt}", stroke=BORDER)
        sc.rect(32, py + 10, 38, 38, BG, 12, f"Pickup ic {pt}", stroke=BORDER)
        sc.icon("clock", 42, py + 20, 18, INK)
        sc.text(pt, 80, py + 10, 14, INK, 700, name=f"Pickup t {pt}")
        sc.text(ps, 80, py + 31, 11, MUTED, 400, name=f"Pickup s {pt}")
        sc.rect(274, py + 15, 87, 28, bbg, 14, f"Pickup badge {pt}")
        tb = sc.text(pb, 0, py + 21, 10, bfg, 700, name=f"Pickup b {pt}")
        S(tb, x=sc.ax(274, 87) + (87 - width(tb)) / 2)

    # Recent Check-ins Summary (y=612..732)
    sc.section_label(s["sec_act"], 612)
    sc.rect(18, 636, 357, 96, SURF, 20, "Recent activity card", stroke=BORDER)
    sc.rect(32, 652, 44, 44, PRIMARY, 14, "Check-in icon bg")
    sc.icon("check-circle", 43, 663, 22, ONP)
    sc.text(s["act_t"], 88, 652, 14, INK, 700, name="Activity title")
    sc.text(s["act_s"], 88, 676, 12, MUTED, 400, w=270, name="Activity sub")

    bottom_nav(sc, active=0)
    return sc.F


def notifications_center(lang: str) -> int:
    sc = Screen(lang, GROUP, "Notifications Center", 2, STR); s = sc.s
    sc.status_bar()
    sc.header(s["nf_title"], end_icon="checks")

    # Filter pills + Mark all read link (y=116)
    pills = [(18, 86, s["nf_all"], True), (112, 92, s["nf_bus"], False), (212, 82, s["nf_sch"], False)]
    for px, pw, plbl, act in pills:
        sc.rect(px, 116, pw, 32, PRIMARY if act else SURF, 16, f"NF chip {plbl}", stroke=PRIMARY if act else BORDER)
        tp = sc.text(plbl, 0, 124, 11, ONP if act else INK, 700 if act else 600, name=f"NF txt {plbl}")
        S(tp, x=sc.ax(px, pw) + (pw - width(tp)) / 2)

    # Today section
    sc.section_label(s["nf_d1"], 166, action=s["nf_mark"])
    today_cards = [
        (192, "navigation-arrow", s["n1_t"], s["n1_s"], s["n1_tm"], True, ACCENT + "55", PRIMARY),
        (308, "qr-code", s["n2_t"], s["n2_s"], s["n2_tm"], True, SURF, BORDER),
        (424, "check-circle", s["n3_t"], s["n3_s"], s["n3_tm"], False, SURF, BORDER),
    ]
    for ny, icn, nt, ns, ntm, unread, cbg, cbord in today_cards:
        sc.rect(18, ny, 357, 102, cbg, 20, f"Notif {nt}", stroke=cbord)
        sc.rect(32, ny + 18, 42, 42, PRIMARY if cbord == PRIMARY else ACCENT, 14, f"NF ic {nt}")
        sc.icon(icn, 43, ny + 29, 20, ONP if cbord == PRIMARY else INK)
        sc.text(nt, 86, ny + 18, 14, INK, 700, name=f"NF t {nt}")
        sc.text(ns, 86, ny + 42, 12, MUTED, 400, w=265, name=f"NF s {nt}")
        sc.text(ntm, 86, ny + 78, 10, LINK if unread else MUTED, 600, name=f"NF tm {nt}")
        if unread:
            sc.rect(352, ny + 22, 8, 8, PRIMARY, 4, f"Unread dot {nt}")

    # Yesterday section
    sc.section_label(s["nf_d2"], 546)
    sc.rect(18, 572, 357, 106, SURF, 20, "Notif yesterday", stroke=BORDER)
    sc.rect(32, 590, 42, 42, BG, 14, "NF yest ic", stroke=BORDER)
    sc.icon("megaphone", 43, 601, 20, INK)
    sc.text(s["n4_t"], 86, 590, 14, INK, 700, name="NF4 t")
    sc.text(s["n4_s"], 86, 614, 12, MUTED, 400, w=265, name="NF4 s")
    sc.text(s["n4_tm"], 86, 650, 10, MUTED, 600, name="NF4 tm")

    sc.rect(127, 834, 139, 5, INK, 3, "Home indicator", mirror=False)
    return sc.F


def quick_qr_pass(lang: str) -> int:
    sc = Screen(lang, GROUP, "Quick QR Boarding Pass", 3, STR); s = sc.s
    sc.status_bar()
    sc.header(s["qr_title"], end_icon="share-network")

    # Child selector pills (y=116)
    sc.rect(18, 116, 174, 36, PRIMARY, 18, "QR child 1")
    t1 = sc.text(s["qr_c1"], 0, 125, 12, ONP, 700, name="QR c1 txt")
    S(t1, x=sc.ax(18, 174) + (174 - width(t1)) / 2)

    sc.rect(201, 116, 174, 36, SURF, 18, "QR child 2", stroke=BORDER)
    t2 = sc.text(s["qr_c2"], 0, 125, 12, MUTED, 600, name="QR c2 txt")
    S(t2, x=sc.ax(201, 174) + (174 - width(t2)) / 2)

    # Hero Digital Boarding Pass Card (y=170..650)
    sc.rect(18, 170, 357, 464, SURF, 26, "QR pass card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 10], "radius": 24, "color": INK + "14"}])

    # Dark header inside pass card
    sc.hero_frame(18, 170, 357, 94, INK, 26, dark=True, name="QR pass top")
    sc.rect(36, 188, 56, 56, ACCENT, 28, "QR avatar", stroke=SURF)
    sc.icon("graduation-cap", 50, 202, 28, INK)
    sc.text(s["ch1_n"], 104, 192, 17, SURF, 700, name="QR student name")
    sc.text(s["qr_id"], 104, 218, 12, ACCENT, 600, name="QR student id")

    # Large crisp QR Matrix frame
    sc.rect(94, 288, 205, 205, BG, 24, "QR code container", stroke=BORDER, mirror=False)
    sc.icon("qr-code", 116, 310, 160, INK, mirror=False)

    # Bus, seat & validity strip
    sc.rect(36, 514, 321, 34, ACCENT + "55", 12, "QR bus pill")
    sc.text(s["qr_seat"], 0, 523, 13, INK, 700, align="center", name="QR seat txt")
    sc.text(s["qr_stop"], 0, 562, 12, INK, 600, align="center", name="QR stop txt")
    sc.text(s["qr_valid"], 0, 590, 11, LINK, 700, align="center", name="QR valid txt")

    # Bottom Actions
    sc.button(s["qr_save"], 664, lead_icon="wallet")
    sc.secondary_button(s["qr_share"], 736, lead_icon="share-network")
    sc.rect(127, 834, 139, 5, INK, 3, "Home indicator", mirror=False)
    return sc.F


def school_updates_support(lang: str) -> int:
    sc = Screen(lang, GROUP, "School Updates & Support", 4, STR); s = sc.s
    sc.status_bar()
    sc.header(s["up_title"], end_icon="megaphone")

    sc.section_label(s["up_sec_bul"], 120)
    bulletins = [
        (144, s["b1_tag"], s["b1_t"], s["b1_s"], PRIMARY, ONP),
        (264, s["b2_tag"], s["b2_t"], s["b2_s"], ACCENT, INK),
        (384, s["b3_tag"], s["b3_t"], s["b3_s"], BG, INK),
    ]
    for by, tag, bt, bs, tbg, tfg in bulletins:
        sc.rect(18, by, 357, 106, SURF, 20, f"Bulletin {bt}", stroke=BORDER)
        sc.rect(34, by + 16, 92, 22, tbg, 11, f"Tag {tag}", stroke=BORDER if tbg == BG else None)
        tt = sc.text(tag, 0, by + 20, 10, tfg, 700, name=f"Tag txt {tag}")
        S(tt, x=sc.ax(34, 92) + (92 - width(tt)) / 2)
        sc.text(bt, 34, by + 46, 15, INK, 700, name=f"Bul title {bt}")
        sc.text(bs, 34, by + 70, 12, MUTED, 400, w=325, name=f"Bul sub {bt}")

    sc.section_label(s["up_sec_sup"], 514)
    sc.rect(18, 538, 357, 178, SURF, 22, "Support card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 18, "color": INK + "12"}])
    sc.rect(34, 556, 48, 48, ACCENT, 16, "Support icon bg")
    sc.icon("chat-circle-text", 46, 568, 24, INK)
    sc.text(s["sup_t"], 94, 558, 15, INK, 700, name="Support title")
    sc.text(s["sup_s"], 94, 582, 12, MUTED, 400, w=260, name="Support sub")
    sc.rect(34, 646, 325, 50, PRIMARY, 14, "Support CTA")
    sc.text(s["sup_btn"], 0, 661, 15, ONP, 700, align="center", name="Support CTA lbl")

    sc.rect(127, 834, 139, 5, INK, 3, "Home indicator", mirror=False)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            home_dashboard(lang),
            home_afternoon(lang),
            notifications_center(lang),
            quick_qr_pass(lang),
            school_updates_support(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
