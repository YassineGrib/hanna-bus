"""Build Page '07 · Bus Rotation & Messages' (6 screens x 2 languages = 12 frames).

Screens:
  0. Select Bus & Rotation   (current bus, available buses, weekly rotation, switch action)
  1. Parent Messages Inbox   (filter chips, threads with unread and urgent markers)
  2. Message Thread          (chat with one parent, quick replies, composer)
  3. Trip History            (period chips, totals, recent trips with on-time badges)
  4. Performance & Rating    (rating hero, KPI grid, weekday bar chart, parent quote)
  5. SOS Emergency           (hold-to-alert button, incident type, direct call shortcuts)

Only English (LTR) and Arabic (RTL), like every other page.
"""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
import fc
from ui import (
    W, H, INK, BG, SURF, BORDER, ACCENT, PRIMARY, MUTED, SOFT, LINK, ONP,
    DESTR, OND, DSURF, DBORD,
    mk, S, width, ensure_page, clear_lang_on_page, wrap_section, Screen,
)
from build_driver_settings import driver_bottom_nav

PAGE_NAME = "07 · Bus Rotation & Messages"
GROUP = "Driver Fleet"
SCREENS = [
    "Select Bus & Rotation",
    "Parent Messages Inbox",
    "Message Thread",
    "Trip History",
    "Performance & Rating",
    "SOS Emergency",
]
SECTIONS = {
    "en": "EN · Bus Rotation & Messages (LTR)",
    "ar": "AR · تدوير الحافلات والرسائل (RTL)",
}

GREEN, GREEN_BG = "#1B8A4D", "#E8F8F0"
AMBER, AMBER_BG = "#946A00", "#FFF3D1"
WHITE, WHITE_SOFT = "#FFFFFF", "#D8D2BF"

STR = {
 "en": dict(
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",
  days=["Sun", "Mon", "Tue", "Wed", "Thu"],

  # 0 Bus rotation
  f_title="Bus Rotation", f_active="CURRENT BUS", f_bus="BUS 04",
  f_line="Line 12 · Plate 16-2841-09", f_status="In service",
  f_avail="Available buses",
  b1_t="BUS 07 · Line 3", b1_s="24 seats · Inspected today", b1_c="Available",
  b2_t="BUS 11 · Line 8", b2_s="30 seats · On route", b2_c="In service",
  b3_t="BUS 02 · Spare", b3_s="18 seats · Brake service", b3_c="Workshop",
  f_week="This week's rotation", rot=["04", "04", "04", "07", "11"],
  btn_switch="Switch to Bus 07", f_note="A pre-trip inspection is required after switching",

  # 1 Inbox
  m_title="Parent Messages", chips=["All 12", "Unread 3", "Urgent 1"],
  threads=[
    ("KM", "Karima Mansouri", "Yacine · Stop 3", "Yacine will be 2 minutes late", "06:52", "2", False),
    ("SH", "Samir Haddad", "Lina · Stop 5", "Allergy reminder for today", "06:40", "1", True),
    ("NB", "Nadia Boualem", "Adam · Stop 2", "Thank you for yesterday", "Yesterday", "", False),
    ("OB", "Omar Belkacem", "Meriem · Stop 6", "Pickup moved to the main gate", "Yesterday", "", False),
    ("SK", "Sara Khelifi", "Ilyes · Stop 4", "Is the bus on time today?", "Mon", "", False),
  ],
  urgent="Urgent",

  # 2 Thread
  c_name="Karima Mansouri", c_sub="Parent of Yacine · Stop 3", c_day="Today 06:52",
  c1="Good morning, Yacine will be at the gate 2 minutes late.",
  c2="No problem, I will wait.",
  c3="Thank you, Mr. Ahmed!",
  c4="Arrived at Hay El Nasr 01. Yacine boarded at 07:09.",
  q=["On my way", "Arrived at stop", "5 min late"], c_ph="Write a message",

  # 3 History
  h_title="Trip History", periods=["Week", "Month", "All"],
  sums=[("42", "Trips"), ("1,126", "Kilometers"), ("98%", "On time")],
  h_sec="Recent trips",
  trips=[
    ("sun", "Wed 11 Nov · Morning", "07:02 to 07:58 · 14 students", "On time", True),
    ("moon", "Tue 10 Nov · Return", "13:30 to 14:24 · 13 students", "On time", True),
    ("sun", "Tue 10 Nov · Morning", "07:04 to 08:06 · 14 students", "6 min late", False),
    ("moon", "Mon 9 Nov · Return", "13:31 to 14:22 · 14 students", "On time", True),
    ("sun", "Mon 9 Nov · Morning", "07:01 to 07:55 · 14 students", "On time", True),
  ],

  # 4 Performance
  p_title="My Performance", p_rating="4.95", p_rsub="520 trips rated by parents",
  p_h1=("98%", "On time"), p_h2=("0", "Incidents"),
  kpis=[("98%", "On-time rate"), ("42", "Trips this month"), ("1,126", "Kilometers"), ("1,204", "Safe QR scans")],
  p_chart="Trips per day", chart_vals=[8, 9, 9, 8, 8],
  p_quote="Always on time and kind to the children.", p_who="Parent, Stop 3",

  # 5 SOS
  s_title="Emergency SOS", s_sub="Hold the button for 3 seconds to alert the school, the parents and rescue teams.",
  s_hold="HOLD 3 SEC", s_what="What happened?",
  s_types=[("Accident", "warning-circle"), ("Breakdown", "bus"), ("Medical", "first-aid"), ("Security", "shield-check")],
  s_call="Call now",
  s_calls=[("14", "Civil Protection"), ("17", "Police"), ("School", "Coordinator")],
  s_note="Your live location is shared with the school once the alert is sent.",
 ),
 "ar": dict(
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="الملف",
  days=["الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس"],

  f_title="تدوير الحافلات", f_active="الحافلة الحالية", f_bus="الحافلة 04",
  f_line="الخط 12 · لوحة 16-2841-09", f_status="في الخدمة",
  f_avail="الحافلات المتاحة",
  b1_t="الحافلة 07 · الخط 3", b1_s="24 مقعدًا · تم فحصها اليوم", b1_c="متاحة",
  b2_t="الحافلة 11 · الخط 8", b2_s="30 مقعدًا · في الطريق", b2_c="في الخدمة",
  b3_t="الحافلة 02 · احتياط", b3_s="18 مقعدًا · صيانة الفرامل", b3_c="في الورشة",
  f_week="تدوير هذا الأسبوع", rot=["04", "04", "04", "07", "11"],
  btn_switch="التبديل إلى الحافلة 07", f_note="يلزم فحص ما قبل الرحلة بعد التبديل",

  m_title="رسائل الأولياء", chips=["الكل 12", "غير مقروءة 3", "عاجلة 1"],
  threads=[
    ("ك م", "كريمة منصوري", "ياسين · المحطة 3", "ياسين سيتأخر دقيقتين", "06:52", "2", False),
    ("س ح", "سمير حداد", "لينا · المحطة 5", "تذكير بحساسية اليوم", "06:40", "1", True),
    ("ن ب", "نادية بوعلام", "آدم · المحطة 2", "شكرًا على الأمس", "أمس", "", False),
    ("ع ب", "عمر بلقاسم", "مريم · المحطة 6", "تغيير مكان الاستلام للبوابة", "أمس", "", False),
    ("س خ", "سارة خليفي", "إلياس · المحطة 4", "هل الحافلة في موعدها اليوم؟", "الإثنين", "", False),
  ],
  urgent="عاجل",

  c_name="كريمة منصوري", c_sub="ولية أمر ياسين · المحطة 3", c_day="اليوم 06:52",
  c1="صباح الخير، ياسين سيصل إلى البوابة متأخرًا دقيقتين.",
  c2="لا مشكلة، سأنتظره.",
  c3="شكرًا لك يا سيد أحمد!",
  c4="وصلنا حي النصر 01. صعد ياسين عند 07:09.",
  q=["في الطريق", "وصلت المحطة", "تأخر 5 دقائق"], c_ph="اكتب رسالة",

  h_title="سجل الرحلات", periods=["أسبوع", "شهر", "الكل"],
  sums=[("42", "رحلة"), ("1,126", "كيلومتر"), ("98%", "في الموعد")],
  h_sec="الرحلات الأخيرة",
  trips=[
    ("sun", "الأربعاء 11 نوفمبر · صباحًا", "07:02 إلى 07:58 · 14 طالبًا", "في الموعد", True),
    ("moon", "الثلاثاء 10 نوفمبر · عودة", "13:30 إلى 14:24 · 13 طالبًا", "في الموعد", True),
    ("sun", "الثلاثاء 10 نوفمبر · صباحًا", "07:04 إلى 08:06 · 14 طالبًا", "تأخر 6 د", False),
    ("moon", "الإثنين 9 نوفمبر · عودة", "13:31 إلى 14:22 · 14 طالبًا", "في الموعد", True),
    ("sun", "الإثنين 9 نوفمبر · صباحًا", "07:01 إلى 07:55 · 14 طالبًا", "في الموعد", True),
  ],

  p_title="أدائي", p_rating="4.95", p_rsub="520 رحلة قيّمها الأولياء",
  p_h1=("98%", "في الموعد"), p_h2=("0", "حوادث"),
  kpis=[("98%", "نسبة الالتزام بالموعد"), ("42", "رحلات هذا الشهر"), ("1,126", "كيلومتر"), ("1,204", "مسح QR آمن")],
  p_chart="الرحلات حسب اليوم", chart_vals=[8, 9, 9, 8, 8],
  p_quote="دائمًا في الموعد ولطيف مع الأطفال.", p_who="ولي أمر، المحطة 3",

  s_title="نداء الطوارئ SOS", s_sub="اضغط مطولًا لمدة 3 ثوانٍ لتنبيه المدرسة والأولياء وفرق الإنقاذ.",
  s_hold="اضغط 3 ثوانٍ", s_what="ماذا حدث؟",
  s_types=[("حادث", "warning-circle"), ("عطل", "bus"), ("طبي", "first-aid"), ("أمني", "shield-check")],
  s_call="اتصل الآن",
  s_calls=[("14", "الحماية المدنية"), ("17", "الشرطة"), ("المدرسة", "المنسّق")],
  s_note="يُشارك موقعك المباشر مع المدرسة فور إرسال النداء.",
 ),
}


# ---------- small helpers ----------
def pill(sc, x, y, w, h, label, bg, fg, size=10, weight=700, stroke=None):
    sc.rect(x, y, w, h, bg, h / 2.0, f"Pill {label}", stroke=stroke)
    sc.text(label, x, y + (h - size * 1.3) / 2.0, size, fg, weight, w=w, align="center", name=f"Pill label {label}")


def circle(sc, cx, cy, d, fill, name, stroke=None):
    return mk("shape.ellipse", x=cx - d / 2.0, y=cy - d / 2.0, width=d, height=d, parent=sc.F,
              name=name, select=False,
              props=dict(fill=fill, **({"stroke": stroke, "strokeWeight": 1} if stroke else {})))


def chips_row(sc, labels, y, widths, active=0):
    x = 18
    for i, (lab, w) in enumerate(zip(labels, widths)):
        if i == active:
            pill(sc, x, y, w, 34, lab, INK, WHITE, 11.5)
        else:
            pill(sc, x, y, w, 34, lab, SURF, INK, 11.5, 600, stroke=BORDER)
        x += w + 8


def status_chip(sc, kind, label, x, y, w=76):
    bg, fg = {"ok": (GREEN_BG, GREEN), "warn": (AMBER_BG, AMBER), "bad": (DSURF, DESTR)}[kind]
    pill(sc, x, y, w, 24, label, bg, fg, 10)


# ---------- screens ----------
def bus_rotation_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[0], 0, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["f_title"], end_icon="bus")

    # current bus hero
    sc.hero_frame(18, 124, 357, 118, INK, dark=True, name="Current bus hero")
    sc.text(s["f_active"], 36, 142, 10.5, ACCENT, 700)
    sc.text(s["f_bus"], 36, 160, 32, WHITE, 800)
    sc.text(s["f_line"], 36, 208, 11.5, WHITE_SOFT, 500, w=230)
    pill(sc, 270, 140, 88, 26, s["f_status"], GREEN_BG, GREEN, 10.5)

    # available buses
    sc.section_label(s["f_avail"], 262)
    rows = [
        (s["b1_t"], s["b1_s"], s["b1_c"], "ok", True),
        (s["b2_t"], s["b2_s"], s["b2_c"], "warn", False),
        (s["b3_t"], s["b3_s"], s["b3_c"], "bad", False),
    ]
    for i, (t, sub, chip, kind, selected) in enumerate(rows):
        y = 286 + i * 70
        sc.rect(18, y, 357, 62, PRIMARY + "14" if selected else SURF, 16, f"Bus card {i}",
                stroke=PRIMARY if selected else BORDER)
        sc.rect(30, y + 11, 40, 40, ACCENT if selected else "#F8F5EC", 14, "Bus icon box")
        sc.icon("bus", 40, y + 21, 20, INK)
        sc.text(t, 80, y + 12, 13, INK, 700, w=190)
        sc.text(sub, 80, y + 34, 10.5, MUTED, 500, w=190)
        status_chip(sc, kind, chip, 285, y + 19, 78)

    # weekly rotation
    sc.section_label(s["f_week"], 506)
    cw, gap = 64, 9.25
    for i in range(5):
        x = 18 + i * (cw + gap)
        today = i == 3
        sc.rect(x, 530, cw, 70, INK if today else SURF, 16, f"Rotation day {i}", stroke=None if today else BORDER)
        sc.text(s["days"][i], x, 541, 10.5, WHITE_SOFT if today else MUTED, 600, w=cw, align="center")
        sc.text(s["rot"][i], x, 561, 20, WHITE if today else INK, 800, w=cw, align="center", latin=True)

    sc.button(s["btn_switch"], 620, trail_icon="arrow-left" if sc.rtl else "arrow-right")
    sc.text(s["f_note"], 18, 690, 11, MUTED, 500, w=357, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def inbox_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[1], 1, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["m_title"], end_icon="magnifying-glass")
    chips_row(sc, s["chips"], 120, [78, 108, 98] if not sc.rtl else [78, 118, 98])

    for i, (ini, name, child, prev, tm, unread, urgent) in enumerate(s["threads"]):
        y = 172 + i * 92
        sc.rect(18, y, 357, 84, SURF, 18, f"Thread {i}", stroke=DESTR + "55" if urgent else BORDER)
        circle(sc, W - 52 if sc.rtl else 52, y + 42, 44, ACCENT, "Avatar")
        sc.text(ini, 30, y + 33, 14, INK, 800, w=44, align="center")
        sc.text(name, 90, y + 13, 13.5, INK, 700, w=160)
        sc.text(child, 90, y + 33, 10.5, MUTED, 600, w=160)
        sc.text(prev, 90, y + 54, 12, INK if unread else MUTED, 600 if unread else 400, w=170 if urgent else 205)
        sc.text(tm, 255, y + 14, 10.5, MUTED, 500, w=100, align="end")
        if unread:
            sc.rect(333, y + 50, 24, 24, PRIMARY, 12, "Unread badge")
            sc.text(unread, 333, y + 54, 11, ONP, 800, w=24, align="center", latin=True)
        if urgent:
            pill(sc, 266, y + 50, 58, 22, s["urgent"], DSURF, DESTR, 10)

    driver_bottom_nav(sc, active=3)
    return sc.F


def thread_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[2], 2, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["c_name"], end_icon="phone")
    sc.text(s["c_sub"], 18, 104, 11, MUTED, 500, w=357, align="center")

    pill(sc, 143, 140, 107, 24, s["c_day"], BORDER, MUTED, 10, 600)

    def bubble(x, y, w, h, text, mine, check=False):
        sc.rect(x, y, w, h, PRIMARY if mine else SURF, 18, "Bubble out" if mine else "Bubble in",
                stroke=None if mine else BORDER)
        sc.text(text, x + 14, y + 10, 12.5, ONP if mine else INK, 500, w=w - 28)
        if check:
            sc.icon("checks", x + w - 30, y + h - 22, 16, ONP)

    bubble(18, 180, 262, 58, s["c1"], False)
    bubble(153, 250, 222, 38, s["c2"], True)
    bubble(18, 300, 210, 38, s["c3"], False)
    bubble(103, 350, 272, 60, s["c4"], True, check=True)

    # quick replies
    x = 18
    for lab, w in zip(s["q"], [96, 124, 112]):
        pill(sc, x, 700, w, 34, lab, SURF, INK, 11, 600, stroke=BORDER)
        x += w + 8

    # composer
    sc.rect(18, 750, 357, 56, SURF, 28, "Composer", stroke=BORDER)
    sc.text(s["c_ph"], 40, 770, 14, MUTED, 400, w=240)
    sc.rect(321, 757, 42, 42, PRIMARY, 21, "Send button")
    sc.icon("arrow-left" if sc.rtl else "arrow-right", 332, 768, 20, ONP)
    return sc.F


def history_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[3], 3, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["h_title"], end_icon="calendar-blank")
    chips_row(sc, s["periods"], 120, [84, 84, 72])

    sc.rect(18, 172, 357, 82, SURF, 20, "Totals card", stroke=BORDER)
    colw = 357 / 3.0
    for i, (val, lab) in enumerate(s["sums"]):
        x = 18 + i * colw
        sc.text(val, x, 190, 22, INK, 800, w=colw, align="center", latin=True)
        sc.text(lab, x, 222, 11, MUTED, 500, w=colw, align="center")
        if i:
            sc.rect(x, 190, 1, 46, BORDER, 0, "Divider")

    sc.section_label(s["h_sec"], 274)
    for i, (ic, title, sub, badge, ok) in enumerate(s["trips"]):
        y = 298 + i * 84
        sc.rect(18, y, 357, 76, SURF, 16, f"Trip {i}", stroke=BORDER)
        sc.rect(30, y + 18, 40, 40, ACCENT if ic == "sun" else "#EFEBDD", 14, "Trip icon box")
        sc.icon(ic, 40, y + 28, 20, INK)
        sc.text(title, 82, y + 16, 12.5, INK, 700, w=190)
        sc.text(sub, 82, y + 40, 10.5, MUTED, 500, w=190)
        status_chip(sc, "ok" if ok else "warn", badge, 281, y + 26, 82)

    driver_bottom_nav(sc, active=3)
    return sc.F


def performance_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[4], 4, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["p_title"], end_icon="chart-bar")

    # rating hero
    sc.hero_frame(18, 124, 357, 142, INK, dark=True, name="Rating hero")
    sc.text(s["p_rating"], 38, 142, 46, WHITE, 800, latin=True)
    sc.text("★★★★★", 38, 202, 16, ACCENT, 400, latin=True)
    sc.text(s["p_rsub"], 38, 230, 11.5, WHITE_SOFT, 500, w=190)
    for i, (val, lab) in enumerate((s["p_h1"], s["p_h2"])):
        y = 146 + i * 56
        sc.rect(236, y, 120, 48, WHITE + "14", 14, "Hero stat")
        sc.text(val, 236, y + 6, 18, WHITE, 800, w=120, align="center", latin=True)
        sc.text(lab, 236, y + 29, 10, WHITE_SOFT, 500, w=120, align="center")

    # KPI grid
    for i, (val, lab) in enumerate(s["kpis"]):
        x = 18 + (i % 2) * 183
        y = 284 + (i // 2) * 88
        sc.rect(x, y, 174, 80, SURF, 18, f"KPI {i}", stroke=BORDER)
        sc.text(val, x + 14, y + 12, 24, INK, 800, w=146, latin=True)
        sc.text(lab, x + 14, y + 48, 11, MUTED, 500, w=146)

    # weekday chart
    sc.section_label(s["p_chart"], 472)
    sc.rect(18, 496, 357, 150, SURF, 18, "Chart card", stroke=BORDER)
    cw, gap = 40, 29
    x0 = 18 + (357 - (5 * cw + 4 * gap)) / 2.0
    for i, v in enumerate(s["chart_vals"]):
        bh = v * 9
        x = x0 + i * (cw + gap)
        today = i == 3
        sc.rect(x, 600 - bh, cw, bh, PRIMARY if today else ACCENT + "90", 10, f"Bar {i}")
        if today:
            sc.text(str(v), x, 600 - bh - 20, 12, INK, 800, w=cw, align="center", latin=True)
        sc.text(s["days"][i], x - 8, 610, 10, MUTED, 600, w=cw + 16, align="center")

    # parent quote
    sc.rect(18, 662, 357, 74, "#F8F5EC", 18, "Quote card", stroke=BORDER)
    sc.icon("chat-circle-text", 32, 680, 22, PRIMARY)
    sc.text(s["p_quote"], 66, 676, 12.5, INK, 600, w=290)
    sc.text(s["p_who"], 66, 704, 10.5, MUTED, 500, w=290)

    driver_bottom_nav(sc, active=3)
    return sc.F


def sos_screen(lang):
    sc = Screen(lang, GROUP, SCREENS[5], 5, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["s_title"])
    sc.text(s["s_sub"], 18, 116, 13, MUTED, 400, w=357, align="center")

    cx, cy = W / 2.0, 300
    circle(sc, cx, cy, 250, DESTR + "18", "SOS halo 3")
    circle(sc, cx, cy, 206, DESTR + "33", "SOS halo 2")
    circle(sc, cx, cy, 164, DESTR, "SOS button")
    sc.text("SOS", 0, cy - 34, 44, WHITE, 800, align="center", latin=True, name="SOS label")
    sc.text(s["s_hold"], 0, cy + 24, 11, WHITE, 700, align="center")

    sc.section_label(s["s_what"], 440)
    for i, (lab, ic) in enumerate(s["s_types"]):
        x = 18 + (i % 2) * 183
        y = 464 + (i // 2) * 62
        sel = i == 1
        sc.rect(x, y, 174, 54, DSURF if sel else SURF, 16, f"Type {lab}", stroke=DESTR if sel else BORDER)
        sc.icon(ic, x + 14, y + 17, 20, DESTR if sel else INK)
        sc.text(lab, x + 44, y + 18, 13, DESTR if sel else INK, 700, w=118)

    sc.section_label(s["s_call"], 598)
    bw, gap = 112, 10.5
    for i, (num, lab) in enumerate(s["s_calls"]):
        x = 18 + i * (bw + gap)
        sc.rect(x, 622, bw, 72, SURF, 16, f"Call {lab}", stroke=BORDER)
        sc.icon("phone-call", x + (bw - 18) / 2.0, 632, 18, GREEN)
        sc.text(num, x, 654, 13, INK, 800, w=bw, align="center")
        sc.text(lab, x, 674, 9.5, MUTED, 500, w=bw, align="center")

    sc.text(s["s_note"], 18, 710, 11, MUTED, 500, w=357, align="center")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            bus_rotation_screen(lang),
            inbox_screen(lang),
            thread_screen(lang),
            history_screen(lang),
            performance_screen(lang),
            sos_screen(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


def main():
    langs = sys.argv[1:] or ["en", "ar"]
    assert fc.is_running(), "FigCraft is not running with --control 7979"

    driver_fig = os.path.join(ROOT, "output", "hanna-bus-driver.figcraft")
    if os.path.exists(driver_fig):
        res = fc.ex("file.open", path=driver_fig)
        print("opened existing:", driver_fig, res.get("ok"))

    build(langs)
    fc.ex("view.zoomFit")
    fc.ex("select.none")

    shots_dir = os.path.join(ROOT, "output", "screenshots")
    os.makedirs(shots_dir, exist_ok=True)
    out_png = os.path.join(shots_dir, "driver-07-fleet-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-fleet.figcraft"):
        res = fc.ex("file.saveAs", path=os.path.join(ROOT, "output", fname))
        assert res.get("ok"), res
        print("saved:", fname)


if __name__ == "__main__":
    main()
