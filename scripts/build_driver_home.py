"""Build Page '02 · Driver Mission Control' (5 screens x 2 languages = 10 frames).

Screens:
  0. Mission Control Ready (Pre-trip vehicle check, student summary, morphing slide to start)
  1. Mission Control In Progress (Active stop arrived, boarding checklist, call parent, depart to next)
  2. Quick QR Boarding Scanner (Hands-free continuous scanning viewfinder with instant audio/haptic chime)
  3. Broadcast Route Delay Sheet (One-tap 3-pill radial delay broadcast to all parents & school)
  4. Trip Complete & Safety Walk (End-of-shift mandatory child check-off protocol)
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

PAGE_NAME = "02 · Driver Mission Control"
GROUP = "Driver Home"
SCREENS = [
    "Mission Control Ready",
    "Mission Control In Progress",
    "Quick QR Boarding Scanner",
    "Broadcast Route Delay",
    "Trip Complete & Safety Walk",
]
SECTIONS = {
    "en": "EN · Driver Mission Control (LTR)",
    "ar": "AR · لوحة تحكم ومهام السائق (RTL)",
}

STR = {
 "en": dict(
  # Header & Nav
  driver_name="Ahmed Benali",
  bus_badge="BUS 04 · Line 12",
  shift_am="Morning Route",
  shift_pm="Return Route",
  date_today="Wed, 11 Nov · School Day",
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",

  # Screen 0: Ready to Start
  pre_inspect="Vehicle Inspected · 24 Seats Safe",
  hero_ready_route="MORNING LINE 12",
  hero_ready_sub="First Stop: Hay El Nasr 01 (07:08 AM)",
  stat_total="14", stat_total_lbl="Enrolled",
  stat_abs="2", stat_abs_lbl="Reported Absent",
  stat_stops="7", stat_stops_lbl="Total Stops",
  slide_start="Slide to Start Morning Route",
  sec_actions="Quick Driver Tools",
  act_qr="Scan QR", act_qr_sub="Hands-free",
  act_delay="Delay Alert", act_delay_sub="1-tap broadcast",
  act_abs="2 Absences", act_abs_sub="Skip stops",
  sec_stops="Upcoming Stops Today",
  see_all="View map",
  st1_t="07:08 AM · Hay El Nasr 01", st1_s="3 students · 1 absent", st1_b="Next Stop",
  st2_t="07:16 AM · Martyrs Blvd 03", st2_s="4 students · Stop on right", st2_b="Stop 02",
  st3_t="07:25 AM · Hydra Commercial", st3_s="3 students · 2 on bus", st3_b="Stop 03",

  # Screen 1: Active At Stop
  active_badge="LIVE · STOP 3 OF 7",
  active_header="ARRIVED AT STOP 03",
  active_station="Hay El Nasr Central Gate",
  active_boarded="2 of 3 Boarded",
  active_depart_btn="Depart to Stop 04 ➔",
  sec_stop_kids="Students at this Stop (3)",
  k1_n="Youssef Mansouri", k1_s="Bus 04 · Seat A2", k1_b="BOARDED 07:16",
  k2_n="Amina Mansouri", k2_s="Bus 04 · Seat A3", k2_b="BOARDED 07:17",
  k3_n="Rayan Benali", k3_s="Bus 04 · Seat B1 · Not arrived", k3_b="WAITING",
  call_parent="Call: Rayan's Father (+213 550 12 34 56)",
  puck_delay="Delay Alert · Broadcast update to parents",

  # Screen 2: Hands-Free QR Scanner
  qr_title="Hands-Free QR Scanner",
  qr_sub="Hold student card inside frame · Auto confirms",
  qr_mode="Live Viewfinder · Voice Chime Active",
  qr_card_t="Youssef Mansouri",
  qr_card_sub="Grade 3 · Seat A2 · El Wiam Primary",
  qr_card_status="BOARDED · 07:16:32 AM",
  qr_counter="Boarded: 9 / 14 Students · 2 Absent",
  qr_manual="Manual check-in list",

  # Screen 3: Broadcast Delay Sheet
  delay_title="Broadcast Route Delay",
  delay_sub="Instantly recalculates ETA and notifies all 14 waiting parents and school dispatch.",
  delay_pills_title="Select Estimated Delay",
  p1_time="+5 min", p1_desc="Light Traffic Delay",
  p2_time="+10 min", p2_desc="Heavy Congestion Delay",
  p3_time="Detour", p3_desc="Road Work Ahead",
  delay_btn="Broadcast Alert to 14 Parents",
  cancel="Cancel",

  # Screen 4: Trip Complete & Safety Walk
  done_badge="SCHOOL ARRIVAL CONFIRMED",
  done_title="All 14 Students Safe",
  done_sub="Arrived at El Wiam Primary School · 07:42 AM",
  safe_proto="MANDATORY SAFETY PROTOCOL",
  safe_title="Walk Aisle to Rear Seats",
  safe_sub="Physically walk to the back of the bus to ensure no sleeping child or forgotten bag remains onboard.",
  chk1="All 14 students safely entered school gate",
  chk2="Inspected all rows & under-seat areas to the rear",
  chk3="Emergency exits and side windows closed",
  safe_btn="Confirm All Clear & Finish Shift",
  summary_t="Morning Shift Summary",
  summary_d="14.8 km driven · 42 min duration · 100% on-time",
 ),
 "ar": dict(
  # Header & Nav
  driver_name="أحمد بن علي",
  bus_badge="حافلة 04 · خط 12",
  shift_am="رحلة الصباح",
  shift_pm="رحلة العودة",
  date_today="الأربعاء 11 نوفمبر · يوم دراسي",
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="حسابي",

  # Screen 0: Ready to Start
  pre_inspect="تم فحص الحافلة · 24 مقعد جاهز وآمن",
  hero_ready_route="خط الصباح رقم 12",
  hero_ready_sub="المحطة الأولى: بوابة حي النصر 01 (07:08 ص)",
  stat_total="14", stat_total_lbl="مسجلون",
  stat_abs="2", stat_abs_lbl="غياب معتذر",
  stat_stops="7", stat_stops_lbl="محطات",
  slide_start="اسحب لبدء الرحلة الصباحية",
  sec_actions="إجراءات السائق السريعة",
  act_qr="مسح QR", act_qr_sub="بدون لمس",
  act_delay="تنبيه تأخير", act_delay_sub="إرسال فوري",
  act_abs="2 غياب", act_abs_sub="تجاوز المحطة",
  sec_stops="محطات اليوم بالترتيب",
  see_all="عرض الخريطة",
  st1_t="07:08 ص · حي النصر 01", st1_s="3 طلاب · 1 غياب معتذر مسبقاً", st1_b="المحطة التالية",
  st2_t="07:16 ص · شارع الشهداء 03", st2_s="4 طلاب · التوقف على اليمين", st2_b="المحطة 02",
  st3_t="07:25 ص · بوابة حيدرة", st3_s="3 طلاب · 2 على متن الحافلة", st3_b="المحطة 03",

  # Screen 1: Active At Stop
  active_badge="مباشر · المحطة 3 من 7",
  active_header="تم الوصول للمحطة 03",
  active_station="بوابة حي النصر المركزية",
  active_boarded="صعد 2 من 3 طلاب",
  active_depart_btn="الانطلاق للمحطة 04 ➔",
  sec_stop_kids="طلاب هذه المحطة (3)",
  k1_n="يوسف منصوري", k1_s="حافلة 04 · مقعد A2", k1_b="صعد 07:16",
  k2_n="أمينة منصوري", k2_s="حافلة 04 · مقعد A3", k2_b="صعدت 07:17",
  k3_n="ريان بن علي", k3_s="حافلة 04 · مقعد B1 · لم يصل", k3_b="بانتظار الصعود",
  call_parent="اتصال بولي الأمر: والد ريان (0550123456)",
  puck_delay="تنبيه تأخير · إرسال إشعار فوري لجميع الأولياء",

  # Screen 2: Hands-Free QR Scanner
  qr_title="ماسح الصعود التلقائي (QR)",
  qr_sub="وجّه بطاقة الطالب داخل الإطار · تأكيد فوري",
  qr_mode="كاميرا نشطة · نطق صوتي لاسم الطالب",
  qr_card_t="يوسف منصوري",
  qr_card_sub="السنة الثالثة · مقعد A2 · ابتدائية الوئام",
  qr_card_status="تم تسجيل الصعود · 07:16:32 ص",
  qr_counter="تم الصعود: 9 من 14 طالباً · 2 غياب",
  qr_manual="قائمة التسجيل اليدوي",

  # Screen 3: Broadcast Delay Sheet
  delay_title="إرسال تنبيه تأخير للرحلة",
  delay_sub="يشعر فورياً 14 ولي أمر ويعيد حساب موعد وصول الحافلة في هواتفهم تلقائياً.",
  delay_pills_title="حدد مدة التأخير المتوقعة",
  p1_time="+5 دقائق", p1_desc="ازدحام خفيف في الطريق",
  p2_time="+10 دقائق", p2_desc="ازدحام خانق غير متوقع",
  p3_time="تحويل مسار", p3_desc="أشغال طريق أو إغلاق",
  delay_btn="إرسال التنبيه لجميع الأولياء (14)",
  cancel="إلغاء",

  # Screen 4: Trip Complete & Safety Walk
  done_badge="تم تأكيد الوصول للمدرسة",
  done_title="جميع الطلاب (14) بأمان",
  done_sub="الوصول إلى بوابة مدرسة الوئام الابتدائية · 07:42 ص",
  safe_proto="بروتوكول السلامة الإلزامي",
  safe_title="تفقد المقاعد حتى نهاية الحافلة",
  safe_sub="يرجى المرور بين المقاعد للتأكد من نزول كامل الأطفال وعدم بقاء أي تلميذ نائم أو متعلقات منسية.",
  chk1="تأكيد نزول جميع الطلاب الـ 14 بسلام",
  chk2="فحص المقاعد والأرضية صفاً بصف حتى الخلف",
  chk3="إغلاق النوافذ ومخرج الطوارئ بإحكام",
  safe_btn="تأكيد خلو الحافلة وإنهاء الرحلة",
  summary_t="ملخص رحلة الصباح المكتملة",
  summary_d="14.8 كم مسافة · 42 دقيقة استغراق · 100% التزام بالمواعيد",
 ),
}


def driver_top_bar(sc: Screen):
    """Draw top bar with driver avatar, name, bus pill, and notification bell."""
    s = sc.s
    # Avatar badge
    sc.rect(18, 56, 44, 44, ACCENT, 22, "Driver avatar", stroke=PRIMARY)
    sc.icon("user", 29, 67, 22, INK)

    # Driver Name + Bus assignment pill
    sc.text(s["driver_name"], 72, 56, 17, INK, 700, name="Driver name")
    # Bus pill
    sc.rect(72, 80, 134, 22, SURF, 11, "Bus badge bg", stroke=BORDER)
    sc.icon("bus", 78, 84, 14, INK)
    sc.text(s["bus_badge"], 98, 84, 11, INK, 600, name="Bus badge text")

    # Notification bell with unread dot
    sc.rect(331, 56, 44, 44, SURF, 22, "Bell button", stroke=BORDER)
    sc.icon("bell", 343, 68, 20, INK)
    sc.rect(361, 63, 8, 8, DESTR, 4, "Bell unread dot", stroke=SURF)


def driver_bottom_nav(sc: Screen, active: int = 0):
    """Draw the floating capsule 4-item navbar: Home, Students, Navigation, Profile."""
    s = sc.s
    sc.rect(
        18,
        752,
        357,
        64,
        INK,
        32,
        "Floating bottom navbar",
        effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 24, "color": INK + "40"}],
    )
    items = [
        ("house", s["nav_home"]),
        ("users", s["nav_roster"]),
        ("navigation-arrow", s["nav_nav"]),
        ("user", s["nav_prof"]),
    ]
    for idx, (ic, lab) in enumerate(items):
        cx = 18 + 12 + idx * 83
        if idx == active:
            sc.rect(cx, 760, 80, 48, PRIMARY, 24, f"Nav active {lab}", mirror=False)
            sc.icon(ic, cx + 14, 773, 22, ONP, mirror=False)
            sc.text(lab, cx + 38, 776, 11, ONP, 700, name=f"Nav active label {lab}")
        else:
            sc.icon(ic, cx + 29, 773, 22, SURF + "99", mirror=False)


def ready_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Mission Control Ready", 0, STR)
    s = sc.s
    sc.status_bar()
    driver_top_bar(sc)

    # Shift Toggle (Morning vs Return)
    sc.rect(18, 112, 357, 40, SURF, 20, "Shift pill bg", stroke=BORDER)
    sc.rect(20, 114, 176, 36, PRIMARY, 18, "Active shift bg")
    sc.icon("sun", 42, 123, 18, ONP)
    sc.text(s["shift_am"], 66, 124, 13, ONP, 700, name="Morning shift text")
    sc.icon("moon", 220, 123, 18, MUTED)
    sc.text(s["shift_pm"], 244, 124, 13, MUTED, 600, name="Return shift text")

    # Pre-trip Vehicle Safety Inspection Pill
    sc.rect(18, 160, 357, 34, "#E8F8F0", 17, "Pre-trip inspect pill", stroke="#A3E6C1")
    sc.icon("check-circle", 28, 168, 18, "#1B8A4D")
    sc.text(s["pre_inspect"], 52, 169, 12, "#1B8A4D", 700, name="Pre-trip text")

    # Hero Mission Card (Ready state)
    hf = sc.hero_frame(18, 204, 357, 242, fill=INK, r=26, dark=True, name="Hero Ready Card")
    # Gold route badge
    sc.rect(34, 220, 165, 26, PRIMARY, 13, "Route badge")
    sc.icon("bus", 42, 225, 16, ONP)
    sc.text(s["hero_ready_route"], 64, 226, 11, ONP, 700, name="Route badge text")
    # Subtitle first pickup
    sc.text(s["hero_ready_sub"], 34, 256, 14, SURF, 600, name="First pickup text")

    # 3 Stat Columns (Total, Absent, Stops)
    sc.rect(34, 282, 325, 70, SURF + "14", 16, "Stats container")
    col_w = 100
    cols = [
        (s["stat_total"], s["stat_total_lbl"], 38),
        (s["stat_abs"], s["stat_abs_lbl"], 146),
        (s["stat_stops"], s["stat_stops_lbl"], 254),
    ]
    for num, lbl, cx in cols:
        sc.text(num, cx, 292, 22, PRIMARY, 800, w=col_w, align="center", name=f"Stat {lbl}")
        sc.text(lbl, cx, 322, 11, SURF + "CC", 500, w=col_w, align="center", name=f"Stat lbl {lbl}")

    # Morphing Slide-to-Start Button inside hero
    sc.rect(34, 368, 325, 58, PRIMARY, 18, "Slide start button",
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 14, "color": PRIMARY + "40"}])
    sc.icon("caret-right" if not sc.rtl else "caret-left", 314, 386, 22, ONP)
    sc.text(s["slide_start"], 0, 386, 16, ONP, 700, align="center", name="Slide start label")

    # Quick Driver Tools Header
    sc.section_label(s["sec_actions"], 466)

    # 3 Glanceable Action Squircle Cards
    actions = [
        (s["act_qr"], s["act_qr_sub"], "qr-code", ACCENT, 18),
        (s["act_delay"], s["act_delay_sub"], "megaphone", PRIMARY + "44", 140),
        (s["act_abs"], s["act_abs_sub"], "warning-circle", "#FEE8E6", 262),
    ]
    for title, sub, ic, bg_col, ax in actions:
        sc.rect(ax, 490, 112, 80, SURF, 18, f"Action card {title}", stroke=BORDER)
        sc.rect(ax + 12, 500, 32, 32, bg_col, 16, f"Action ic bg {title}")
        sc.icon(ic, ax + 19, 507, 18, INK)
        sc.text(title, ax + 12, 538, 12, INK, 700, name=f"Action title {title}")
        sc.text(sub, ax + 12, 554, 10, MUTED, 500, name=f"Action sub {title}")

    # Upcoming Stops Preview
    sc.section_label(s["sec_stops"], 586, s["see_all"])

    stops = [
        (s["st1_t"], s["st1_s"], s["st1_b"], PRIMARY, 610),
        (s["st2_t"], s["st2_s"], s["st2_b"], BORDER, 678),
    ]
    for title, sub, badge, bcol, sy in stops:
        sc.rect(18, sy, 357, 58, SURF, 16, f"Stop card {title}", stroke=BORDER)
        sc.rect(28, sy + 14, 30, 30, ACCENT, 15, "Stop icon circle")
        sc.icon("map-pin", 35, sy + 21, 16, INK)
        sc.text(title, 66, sy + 12, 13, INK, 700, w=200, name=f"Stop title {title}")
        sc.text(sub, 66, sy + 32, 11, MUTED, 500, w=200, name=f"Stop sub {title}")
        sc.rect(275, sy + 16, 90, 26, bcol, 13, "Stop badge")
        sc.text(badge, 275, sy + 21, 10, ONP if bcol == PRIMARY else INK, 700, w=90, align="center")

    driver_bottom_nav(sc, active=0)
    return sc.F


def in_progress_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Mission Control In Progress", 1, STR)
    s = sc.s
    sc.status_bar()
    driver_top_bar(sc)

    # Active Live Banner
    sc.rect(18, 110, 357, 30, PRIMARY + "28", 15, "Active live banner", stroke=PRIMARY)
    sc.rect(28, 120, 10, 10, "#E67E22", 5, "Live pulse dot")
    sc.text(s["active_badge"], 46, 118, 12, INK, 700, name="Active badge text")

    # Active Station Hero Card (At Stop 03)
    hf = sc.hero_frame(18, 148, 357, 206, fill=INK, r=26, dark=True, name="Hero At Stop Card")
    # Glowing arrived tag
    sc.rect(34, 164, 170, 24, "#F39C12", 12, "Arrived badge")
    sc.icon("map-pin", 42, 168, 16, ONP)
    sc.text(s["active_header"], 64, 169, 11, ONP, 800, name="Arrived text")

    sc.text(s["active_station"], 34, 196, 18, SURF, 700, name="Station name")
    sc.text(s["active_boarded"], 34, 222, 13, PRIMARY, 600, name="Boarded count")

    # Progress bar (66% filled)
    sc.rect(34, 244, 325, 8, SURF + "22", 4, "Progress track")
    sc.rect(34, 244, 215, 8, PRIMARY, 4, "Progress fill")

    # Depart to Next Stop CTA Button
    sc.rect(34, 266, 325, 62, PRIMARY, 18, "Depart button",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 10, "color": PRIMARY + "40"}])
    sc.icon("caret-right" if not sc.rtl else "caret-left", 314, 286, 22, ONP)
    sc.text(s["active_depart_btn"], 0, 286, 16, ONP, 700, align="center", name="Depart label")

    # Stop Students Checklist Section
    sc.section_label(s["sec_stop_kids"], 370)

    # 3 Student Cards at this Stop
    students = [
        (s["k1_n"], s["k1_s"], s["k1_b"], "#E8F8F0", "#1B8A4D", True, 394),
        (s["k2_n"], s["k2_s"], s["k2_b"], "#E8F8F0", "#1B8A4D", True, 474),
        (s["k3_n"], s["k3_s"], s["k3_b"], "#FFF3E0", "#E67E22", False, 554),
    ]
    for name, sub, badge, bg_badge, fg_badge, boarded, sy in students:
        sc.rect(18, sy, 357, 70, SURF, 18, f"Student card {name}", stroke=BORDER)
        # Student avatar
        sc.rect(28, sy + 13, 44, 44, ACCENT, 22, "Student avatar")
        sc.icon("user", 39, sy + 23, 22, INK)

        sc.text(name, 80, sy + 14, 15, INK, 700, name=f"Student name {name}")
        sc.text(sub, 80, sy + 38, 12, MUTED, 500, name=f"Student sub {name}")

        # Status badge
        sc.rect(248, sy + 21, 116, 28, bg_badge, 14, "Student status bg", stroke=fg_badge + "40")
        if boarded:
            sc.icon("check", 254, sy + 27, 16, fg_badge)
            sc.text(badge, 272, sy + 27, 10, fg_badge, 700, name=f"Status txt {name}")
        else:
            sc.icon("clock", 254, sy + 27, 16, fg_badge)
            sc.text(badge, 272, sy + 27, 10, fg_badge, 700, name=f"Status txt {name}")

    # Floating Call Parent pill for missing child Rayan
    sc.rect(18, 634, 357, 44, SURF, 14, "Call parent bar", stroke=PRIMARY)
    sc.icon("phone", 32, 646, 18, PRIMARY)
    sc.text(s["call_parent"], 60, 646, 12, INK, 600, w=280)

    # Delay puck on side
    sc.rect(18, 688, 357, 44, "#FFF8E7", 14, "Delay alert banner", stroke=BORDER)
    sc.icon("megaphone", 32, 700, 18, "#D4A017")
    sc.text(s["puck_delay"], 60, 700, 12, INK, 600, w=280)

    driver_bottom_nav(sc, active=0)
    return sc.F


def scanner_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Quick QR Boarding Scanner", 2, STR, bg_style=None)
    s = sc.s
    # Dark viewfinder background
    sc.rect(0, 0, W, H, "#121212", 0, "Dark viewfinder bg", mirror=False)
    sc.status_bar()

    # Scanner Top Bar
    sc.rect(18, 56, 44, 44, "#242424", 22, "Close scanner", stroke="#3A3A3A")
    sc.icon("arrow-left" if not sc.rtl else "arrow-right", 29, 67, 22, SURF)

    sc.text(s["qr_title"], 0, 66, 17, SURF, 700, align="center", name="Scanner title")

    sc.rect(331, 56, 44, 44, "#242424", 22, "Flashlight toggle", stroke="#3A3A3A")
    sc.icon("sun", 342, 67, 22, PRIMARY)

    # Viewfinder Targeting Reticle (Center box 260x260 at y=150)
    box_x = 66
    box_y = 140
    box_size = 260
    sc.rect(box_x, box_y, box_size, box_size, "#1A1A1A" + "40", 24, "Scanner box", stroke="#2ECC71", mirror=False)

    # 4 Corner brackets (Visual indicator of scanning reticle)
    sc.rect(box_x + 10, box_y + 10, 36, 4, "#2ECC71", 2, mirror=False)
    sc.rect(box_x + 10, box_y + 10, 4, 36, "#2ECC71", 2, mirror=False)

    sc.rect(box_x + box_size - 46, box_y + 10, 36, 4, "#2ECC71", 2, mirror=False)
    sc.rect(box_x + box_size - 14, box_y + 10, 4, 36, "#2ECC71", 2, mirror=False)

    sc.rect(box_x + 10, box_y + box_size - 14, 36, 4, "#2ECC71", 2, mirror=False)
    sc.rect(box_x + 10, box_y + box_size - 46, 4, 36, "#2ECC71", 2, mirror=False)

    sc.rect(box_x + box_size - 46, box_y + box_size - 14, 36, 4, "#2ECC71", 2, mirror=False)
    sc.rect(box_x + box_size - 14, box_y + box_size - 46, 4, 36, "#2ECC71", 2, mirror=False)

    # Glowing scanning laser line in middle
    sc.rect(box_x + 16, box_y + 130, box_size - 32, 3, PRIMARY, 1, "Scan laser",
            effects=[{"type": "dropShadow", "offset": [0, 0], "radius": 12, "color": PRIMARY}])

    # Mode and Chime feedback pill
    sc.rect(48, 420, 297, 34, "#1E2A22", 17, "Mode pill", stroke="#2ECC71" + "60")
    sc.icon("check-circle", 58, 428, 18, "#2ECC71")
    sc.text(s["qr_mode"], 82, 429, 11, "#2ECC71", 600, name="Scanner mode text")

    # Floating Instant Boarding Confirmation Card (Slides up upon scan)
    sc.rect(18, 474, 357, 150, SURF, 22, "Instant confirmed card",
            stroke="#2ECC71",
            effects=[{"type": "dropShadow", "offset": [0, 10], "radius": 30, "color": "#00000080"}])

    # Avatar with green check
    sc.rect(34, 492, 54, 54, ACCENT, 27, "Student scan avatar")
    sc.icon("user", 48, 506, 26, INK)
    sc.rect(68, 526, 20, 20, "#2ECC71", 10, "Check avatar badge", stroke=SURF)
    sc.icon("check", 72, 530, 12, SURF)

    # Student info
    sc.text(s["qr_card_t"], 100, 494, 18, INK, 800, name="Confirmed child name")
    sc.text(s["qr_card_sub"], 100, 522, 12, MUTED, 500, name="Confirmed child sub")

    # Timestamp badge
    sc.rect(34, 564, 325, 42, "#E8F8F0", 12, "Timestamp pill", stroke="#A3E6C1")
    sc.icon("check-circle", 48, 574, 20, "#1B8A4D")
    sc.text(s["qr_card_status"], 76, 576, 13, "#1B8A4D", 700, name="Confirmed time text")

    # Bottom Progress Counter Pill
    sc.rect(18, 642, 357, 44, "#242424", 22, "Counter bar", stroke="#3A3A3A")
    sc.icon("users", 32, 654, 20, PRIMARY)
    sc.text(s["qr_counter"], 64, 655, 13, SURF, 700, name="Counter text")

    # Manual switch button
    sc.button(s["qr_manual"], 712)
    return sc.F


def delay_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Broadcast Route Delay", 3, STR)
    s = sc.s
    sc.status_bar()

    # Dimmed background layer
    sc.rect(0, 0, W, H, "#00000066", 0, "Dim backdrop", mirror=False)

    # Elevated Bottom Sheet (y=210, h=642)
    sc.rect(0, 210, W, 642, SURF, 32, "Delay bottom sheet",
            stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, -8], "radius": 24, "color": INK + "30"}])
    # Sheet handle
    sc.rect(166, 222, 60, 5, BORDER, 3, "Sheet handle", mirror=False)

    # Icon Circle & Header
    sc.rect(168, 244, 56, 56, ACCENT, 28, "Delay icon circle")
    sc.icon("megaphone", 182, 258, 28, INK)

    sc.text(s["delay_title"], 0, 312, 20, INK, 800, align="center", name="Delay title")
    sc.sub(s["delay_sub"], 344, w=320)

    sc.section_label(s["delay_pills_title"], 424)

    # 3 Preset Delay Capsules
    pills = [
        (s["p1_time"], s["p1_desc"], "clock", SURF, BORDER, 448),
        (s["p2_time"], s["p2_desc"], "warning-circle", "#FFF8E7", PRIMARY, 518),  # Selected
        (s["p3_time"], s["p3_desc"], "arrows-clockwise", SURF, BORDER, 588),
    ]
    for time_txt, desc_txt, ic, bg_col, stroke_col, py in pills:
        sc.rect(18, py, 357, 58, bg_col, 16, f"Delay pill {time_txt}", stroke=stroke_col)
        sc.rect(30, py + 12, 34, 34, ACCENT, 17, "Pill icon circle")
        sc.icon(ic, 38, py + 20, 18, INK)
        sc.text(time_txt, 76, py + 12, 15, INK, 800, w=230, name=f"Pill time {time_txt}")
        sc.text(desc_txt, 76, py + 34, 11, MUTED, 500, w=230, name=f"Pill desc {time_txt}")
        # Radio circle
        sc.rect(332, py + 19, 20, 20, stroke_col if stroke_col == PRIMARY else SURF, 10, "Radio", stroke=stroke_col)
        if stroke_col == PRIMARY:
            sc.rect(336, py + 23, 12, 12, ONP, 6, "Radio dot")

    # Big Send Alert Button
    sc.button(s["delay_btn"], 668)

    # Cancel link
    sc.text(s["cancel"], 0, 746, 14, MUTED, 600, align="center", name="Cancel link")
    return sc.F


def safety_walk_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Trip Complete & Safety Walk", 4, STR)
    s = sc.s
    sc.status_bar()
    driver_top_bar(sc)

    # Arrival Confirmed Badge
    sc.rect(18, 112, 357, 34, "#E8F8F0", 17, "Arrival confirmed pill", stroke="#A3E6C1")
    sc.icon("check-circle", 28, 120, 18, "#1B8A4D")
    sc.text(s["done_badge"], 52, 121, 12, "#1B8A4D", 800, name="Arrival badge text")

    # Title & Subtitle
    sc.text(s["done_title"], 0, 154, 22, INK, 800, align="center", name="Done title")
    sc.sub(s["done_sub"], 184, w=320)

    # Child Safety Walk Card (Anti-Abandonment Protocol)
    sc.rect(18, 236, 357, 286, SURF, 22, "Safety walk card",
            stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 18, "color": PRIMARY + "20"}])

    # Amber warning ribbon at top of card
    sc.rect(34, 252, 325, 32, "#FFF8E7", 12, "Safety banner", stroke=BORDER)
    sc.icon("shield-check", 44, 259, 18, "#D4A017")
    sc.text(s["safe_proto"], 70, 260, 11, "#946A00", 800, name="Protocol title")

    sc.text(s["safe_title"], 34, 298, 17, INK, 800, name="Walk aisle title")
    sc.sub(s["safe_sub"], 326, w=320)

    # 3 Checkboxes
    checks = [
        (s["chk1"], 382),
        (s["chk2"], 422),
        (s["chk3"], 462),
    ]
    for chk_txt, cy in checks:
        sc.rect(34, cy, 22, 22, "#27AE60", 6, "Check box", stroke="#27AE60")
        sc.icon("check", 37, cy + 3, 16, SURF)
        sc.text(chk_txt, 66, cy + 2, 12, INK, 600, w=280, name=f"Check {chk_txt}")

    # Confirm and Finish Shift Button
    sc.button(s["safe_btn"], 542)

    # Shift Summary Box at Bottom
    sc.rect(18, 624, 357, 60, SURF, 16, "Shift summary box", stroke=BORDER)
    sc.icon("bus", 32, 638, 20, INK)
    sc.text(s["summary_t"], 62, 634, 13, INK, 700, name="Summary title")
    sc.text(s["summary_d"], 62, 654, 11, MUTED, 500, w=280, name="Summary desc")

    driver_bottom_nav(sc, active=0)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            ready_screen(lang),
            in_progress_screen(lang),
            scanner_screen(lang),
            delay_screen(lang),
            safety_walk_screen(lang),
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
    out_png = os.path.join(shots_dir, "driver-02-home-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    # Save to dedicated driver document files
    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-home.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        assert res.get("ok"), res
        print("saved:", fpath, f"({res['result']['bytes']} bytes)")


if __name__ == "__main__":
    main()
