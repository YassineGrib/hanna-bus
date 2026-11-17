"""Build Page '05 · Live & History Tracking' (6 screens x 2 languages = 12 frames).

Screens:
  0. Live Bus Map (real-time GPS map + route polyline + live ETA bottom sheet)
  1. Live Route Timeline (telemetry strip + 5-stop progress tracker)
  2. Live Boarding Alerts (geofence status + real-time QR & proximity feed)
  3. Trip History (filterable past rides grouped by date + monthly stats)
  4. Trip History Detail (recorded route map replay + QR boarding audit log)
  5. Attendance & Analytics (monthly KPIs + weekly ride regularity bar chart)
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

PAGE_NAME = "05 · Live & History Tracking"
GROUP = "Tracking"
SCREENS = [
    "Live Bus Map",
    "Live Route Timeline",
    "Live Boarding Alerts",
    "Trip History",
    "Trip History Detail",
    "Attendance & Analytics",
]
SECTIONS = {
    "en": "EN · Live & History Tracking (LTR)",
    "ar": "AR · التتبّع المباشر وسجل الرحلات (RTL)",
}

STR = {
 "en": dict(
  # Screen 0: Live Bus Map
  map_title="Live Tracking",
  ch_1="Youssef · Bus 04", ch_2="Amina · Bus 02",
  gps_pill="LIVE GPS · 4s ago",
  map_stop_home="Hay El Nasr (07:16)",
  map_stop_sch="El Wiam School (ETA 07:40)",
  map_bus_lbl="Bus 04 · 38 km/h",
  eta_title="Arriving at School in 4 min",
  eta_sub="1.2 km remaining · Moving on Blvd des Martyrs",
  st_1="07:16 Boarded", st_2="07:34 En Route", st_3="07:40 School",
  drv_name="Bus 04 · Ahmed Benali", drv_sub="Plate 04821-116 · Seat A2 Verified",
  btn_call="Call",
  # Screen 1: Live Route Timeline
  rt_title="Live Route Stops",
  rt_banner_t="Morning Route 04",
  rt_banner_s="Hay El Nasr → El Wiam School",
  rt_ontime="On Time",
  m1_k="Speed", m1_v="38 km/h",
  m2_k="Next Stop", m2_v="2 min",
  m3_k="Onboard", m3_v="19 / 24",
  rt_sec="Stop-by-Stop Live Progress",
  sp1_t="07:05 AM · Central Depot", sp1_s="Departed on schedule",
  sp2_t="07:16 AM · Hay El Nasr (Stop 03)", sp2_s="Youssef boarded · QR #HB-304",
  sp3_t="07:28 AM · Algiers Square", sp3_s="3 students boarded",
  sp4_t="07:34 AM · Blvd des Martyrs", sp4_s="LIVE NOW · Bus 04 is passing here",
  sp5_t="07:40 AM · El Wiam Primary Gate", sp5_s="Destination · East Student Gate",
  rt_share="Share live trip link",
  # Screen 2: Live Boarding Alerts
  al_title="Live Ride Alerts",
  al_geo_t="School Zone Geofence Active",
  al_geo_s="400m safety radius · Instant arrival check-in",
  al_sec="Today's Live Telemetry Feed",
  ev1_t="Approaching School Gate (4 min)", ev1_s="07:36 AM · Bus 04 entered El Wiam zone",
  ev2_t="QR Boarding Confirmed", ev2_s="07:16 AM · Youssef scanned at Stop 03 (Seat A2)",
  ev3_t="Bus Approaching Home Stop", ev3_s="07:11 AM · Driver Ahmed B. is 5 min away",
  ev4_t="Morning Route 04 Started", ev4_s="07:05 AM · Departed depot · Traffic clear",
  al_btn="Configure alert radius",
  # Screen 3: Trip History
  hs_title="Trip History",
  hs_child="Youssef M.", hs_month="Nov 2026",
  hf_all="All (42)", hf_am="Morning (21)", hf_pm="Return (21)",
  hk1_v="42", hk1_k="Rides",
  hk2_v="100%", hk2_k="QR Scans",
  hk3_v="98%", hk3_k="On-Time",
  hs_d1="Yesterday · Mon 09 Nov",
  h1_t="Afternoon Return · Bus 04", h1_s="03:22 PM School → 03:46 PM Home (24m)", h1_b="Completed",
  h2_t="Morning Pickup · Bus 04", h2_s="07:15 AM Home → 07:39 AM School (24m)", h2_b="Completed",
  hs_d2="Sun 08 Nov",
  h3_t="Afternoon Return · Bus 04", h3_s="03:20 PM School → 03:48 PM Home (28m)", h3_b="Traffic +4m",
  h4_t="Morning Pickup · Bus 04", h4_s="07:16 AM Home → 07:40 AM School (24m)", h4_b="Completed",
  # Screen 4: Trip History Detail
  hd_title="Trip Replay #9042",
  hd_date="Mon 09 Nov 2026 · Morning Pickup",
  hd_stat="6.8 km · 24 min · Avg 32 km/h",
  hd_sec_qr="QR Boarding & Hand-off Log",
  hd_q1_t="07:15:22 AM · Pickup QR Verified",
  hd_q1_s="Hay El Nasr Stop 03 · Scanned by Driver Ahmed B.",
  hd_q2_t="07:39:10 AM · School Gate Check-in",
  hd_q2_s="El Wiam East Gate · Verified by Supervisor Tarek M.",
  hd_sec_drv="Vehicle & Driver Record",
  hd_drv_t="Bus 04 · Mercedes Sprinter",
  hd_drv_s="Driver: Ahmed Benali · Safety Rating 4.9/5",
  hd_btn="Download trip receipt (PDF)",
  # Screen 5: Attendance & Analytics
  an_title="Attendance Report",
  an_sub="Youssef Mansouri · November 2026",
  ak1_v="38", ak1_k="Completed",
  ak2_v="1", ak2_k="Absence",
  ak3_v="0", ak3_k="Missed QR",
  an_sec_chart="Weekly Ride Regularity (AM + PM)",
  d_sun="Sun", d_mon="Mon", d_tue="Tue", d_wed="Wed", d_thu="Thu",
  an_sec_safe="Safety & Punctuality Score",
  an_s1_t="98.4% On-Time Pickup & Arrival",
  an_s1_s="Average morning pickup at 07:15 AM (±1 min)",
  an_s2_t="100% Guardian & School Handoff",
  an_s2_s="Every boarding & exit verified by digital QR scan",
  an_btn="Export monthly report",
 ),
 "ar": dict(
  # Screen 0: Live Bus Map
  map_title="التتبّع المباشر",
  ch_1="يوسف · حافلة 04", ch_2="أمينة · حافلة 02",
  gps_pill="مباشر GPS · منذ 4 ث",
  map_stop_home="حي النصر (07:16)",
  map_stop_sch="مدرسة الوئام (07:40)",
  map_bus_lbl="حافلة 04 · 38 كم/س",
  eta_title="الوصول للمدرسة خلال 4 دقائق",
  eta_sub="المتبقي 1.2 كم · تسير في شارع الشهداء",
  st_1="07:16 صعد", st_2="07:34 في المسار", st_3="07:40 المدرسة",
  drv_name="الحافلة 04 · أحمد بن علي", drv_sub="لوحة 116-04821 · مقعد A2 موثّق",
  btn_call="اتصال",
  # Screen 1: Live Route Timeline
  rt_title="مسار المحطات المباشر",
  rt_banner_t="مسار الصباح · حافلة 04",
  rt_banner_s="حي النصر ← ابتدائية الوئام",
  rt_ontime="في الموعد",
  m1_k="السرعة", m1_v="38 كم/س",
  m2_k="المحطة القادمة", m2_v="دقيقتان",
  m3_k="الركاب", m3_v="19 / 24",
  rt_sec="تقدّم المحطات لحظة بلحظة",
  sp1_t="07:05 ص · المستودع المركزي", sp1_s="انطلقت في الموعد المحدّد",
  sp2_t="07:16 ص · حي النصر (محطة 03)", sp2_s="صعد يوسف · مسح البطاقة #HB-304",
  sp3_t="07:28 ص · ساحة الجزائر", sp3_s="صعود 3 تلاميذ",
  sp4_t="07:34 ص · شارع الشهداء", sp4_s="الآن مباشر · الحافلة 04 تمرّ من هنا",
  sp5_t="07:40 ص · بوابة مدرسة الوئام", sp5_s="الوجهة النهائية · البوابة الشرقية",
  rt_share="مشاركة رابط الرحلة المباشر",
  # Screen 2: Live Boarding Alerts
  al_title="تنبيهات الرحلة المباشرة",
  al_geo_t="نطاق أمان المدرسة مفعّل",
  al_geo_s="نصف قطر 400 متر · إشعار فوري عند الوصول",
  al_sec="سجل أحداث الرحلة الجارية اليوم",
  ev1_t="اقتراب من بوابة المدرسة (4 د)", ev1_s="07:36 ص · دخلت الحافلة 04 نطاق مدرسة الوئام",
  ev2_t="تأكيد صعود الطفل ببطاقة QR", ev2_s="07:16 ص · مسح بطاقة يوسف في محطة 03 (مقعد A2)",
  ev3_t="الحافلة تقترب من محطة المنزل", ev3_s="07:11 ص · السائق أحمد ب. على بُعد 5 دقائق",
  ev4_t="بدء رحلة الصباح للمسار 04", ev4_s="07:05 ص · الانطلاق من المركز · الطريق سالك",
  al_btn="ضبط مسافة التنبيه المسبق",
  # Screen 3: Trip History
  hs_title="سجل الرحلات السابقة",
  hs_child="يوسف م.", hs_month="نوفمبر 2026",
  hf_all="الكل (42)", hf_am="الصباح (21)", hf_pm="العودة (21)",
  hk1_v="42", hk1_k="رحلة مكتملة",
  hk2_v="100%", hk2_k="مسح QR",
  hk3_v="98%", hk3_k="انضباط الموعد",
  hs_d1="أمس · الإثنين 09 نوفمبر",
  h1_t="رحلة العودة · الحافلة 04", h1_s="03:22 م المدرسة ← 03:46 م المنزل (24 د)", h1_b="مكتملة",
  h2_t="رحلة الصباح · الحافلة 04", h2_s="07:15 ص المنزل ← 07:39 ص المدرسة (24 د)", h2_b="مكتملة",
  hs_d2="الأحد 08 نوفمبر",
  h3_t="رحلة العودة · الحافلة 04", h3_s="03:20 م المدرسة ← 03:48 م المنزل (28 د)", h3_b="ازدحام +4 د",
  h4_t="رحلة الصباح · الحافلة 04", h4_s="07:16 ص المنزل ← 07:40 ص المدرسة (24 د)", h4_b="مكتملة",
  # Screen 4: Trip History Detail
  hd_title="تفاصيل الرحلة #9042",
  hd_date="الإثنين 09 نوفمبر 2026 · رحلة الصباح",
  hd_stat="6.8 كم · 24 دقيقة · متوسط 32 كم/س",
  hd_sec_qr="سجل التحقق ومسح بطاقة QR",
  hd_q1_t="07:15:22 ص · تأكيد الصعود من المحطة",
  hd_q1_s="محطة حي النصر 03 · مسح بواسطة السائق أحمد ب.",
  hd_q2_t="07:39:10 ص · تأكيد الدخول للمدرسة",
  hd_q2_s="البوابة الشرقية للوئام · استلام المشرف طارق م.",
  hd_sec_drv="بيانات الحافلة والسائق",
  hd_drv_t="الحافلة 04 · مرسيدس سبرينتر",
  hd_drv_s="السائق: أحمد بن علي · تقييم الأمان 4.9/5",
  hd_btn="تحميل تقرير الرحلة (PDF)",
  # Screen 5: Attendance & Analytics
  an_title="تقرير المواظبة والأمان",
  an_sub="يوسف منصوري · نوفمبر 2026",
  ak1_v="38", ak1_k="رحلة مكتملة",
  ak2_v="1", ak2_k="غياب مُبلّغ",
  ak3_v="0", ak3_k="مسح مفقود",
  an_sec_chart="انتظام الرحلات الأسبوعي (صباح + مساء)",
  d_sun="الأحد", d_mon="الإثنين", d_tue="الثلاثاء", d_wed="الأربعاء", d_thu="الخميس",
  an_sec_safe="مؤشر الانضباط والأمان",
  an_s1_t="98.4% التزام بمواعيد الوصول",
  an_s1_s="متوسط وقت الصعود الصباحي 07:15 ص (±1 دقيقة)",
  an_s2_t="100% توثيق التسليم والاستلام",
  an_s2_s="كل عملية صعود ونزول موثّقة بمسح رمز QR الرقمي",
  an_btn="تصدير التقرير الشهري",
 ),
}


def draw_map_canvas(sc: Screen, y: int, h: int, replay: bool = False):
    """Draw a rich stylized vector street map with route polyline, stop pins, and bus badge."""
    s = sc.s
    # Map base container
    sc.rect(18, y, 357, h, "#EFECE1", 24, "Map container", stroke=BORDER, mirror=False)
    # Green park blocks & urban blocks
    sc.rect(30, y + 18, 95, 70, "#DDE7DC", 14, "Park block 1", mirror=False)
    sc.rect(250, y + h - 96, 110, 76, "#DDE7DC", 14, "Park block 2", mirror=False)
    sc.rect(142, y + 24, 110, 56, "#E6E1D2", 10, "City block 1", mirror=False)
    sc.rect(36, y + 114, 108, 84, "#E6E1D2", 10, "City block 2", mirror=False)
    sc.rect(170, y + 104, 184, 70, "#E6E1D2", 10, "City block 3", mirror=False)

    # White arterial roads
    sc.rect(18, y + 92, 357, 14, SURF, 0, "Road H1", mirror=False)
    sc.rect(18, y + h - 112, 357, 12, SURF, 0, "Road H2", mirror=False)
    sc.rect(128, y, 14, h, SURF, 0, "Road V1", mirror=False)
    sc.rect(258, y, 12, h, SURF, 0, "Road V2", mirror=False)

    # Route Polyline connecting Home Stop (x=66, y+h-56) -> Corner -> Bus (x=196, y+118) -> School (x=312, y+52)
    pts = [[66, y + h - 56], [135, y + h - 106], [196, y + 126], [264, y + 98], [316, y + 52]]
    mk("vector.create", points=pts, closed=False, parent=sc.F, name="Route polyline", select=False,
       props={"stroke": PRIMARY, "strokeWeight": 5, "strokeCap": "round", "strokeJoin": "round", "fill": "none"})

    # Origin Pin: Home Stop
    sc.rect(52, y + h - 70, 28, 28, SURF, 14, "Home stop pin", stroke=PRIMARY, mirror=False)
    sc.icon("map-pin", 58, y + h - 64, 16, INK, mirror=False)
    sc.rect(30, y + h - 38, 134, 22, SURF, 11, "Home stop tag", stroke=BORDER, mirror=False)
    th = sc.text(s["map_stop_home"], 0, y + h - 34, 10, INK, 600, name="Home tag txt")
    S(th, x=30 + (134 - width(th)) / 2)

    # Destination Pin: School Gate
    sc.rect(302, y + 38, 28, 28, PRIMARY, 14, "School pin", stroke=SURF, mirror=False)
    sc.icon("graduation-cap", 308, y + 44, 16, ONP, mirror=False)
    sc.rect(206, y + 12, 156, 22, SURF, 11, "School stop tag", stroke=BORDER, mirror=False)
    ts = sc.text(s["map_stop_sch"], 0, y + 16, 10, INK, 700, name="School tag txt")
    S(ts, x=206 + (156 - width(ts)) / 2)

    if not replay:
        # Live pulsing halo + Bus 04 marker in the middle of the route
        sc.rect(170, y + 100, 52, 52, PRIMARY + "38", 26, "Bus pulse halo", mirror=False)
        sc.rect(180, y + 110, 32, 32, INK, 16, "Bus live marker", stroke=SURF, mirror=False)
        sc.icon("bus", 187, y + 117, 18, SURF, mirror=False)
        sc.rect(142, y + 146, 112, 24, INK, 12, "Bus speed pill", mirror=False)
        tb = sc.text(s["map_bus_lbl"], 0, y + 151, 10, SURF, 700, name="Bus speed txt")
        S(tb, x=142 + (112 - width(tb)) / 2)

        # Live GPS badge top-left of map
        sc.rect(30, y + 14, 124, 26, SURF, 13, "GPS live pill", stroke=BORDER, mirror=False)
        sc.rect(40, y + 23, 8, 8, DESTR, 4, "Live dot", mirror=False)
        tg = sc.text(s["gps_pill"], 0, y + 20, 10, INK, 700, name="GPS live txt")
        S(tg, x=52 + (98 - width(tg)) / 2)

        # Floating recenter button bottom-right of map
        sc.rect(326, y + h - 50, 36, 36, SURF, 18, "Recenter GPS btn", stroke=BORDER, mirror=False)
        sc.icon("compass", 335, y + h - 41, 18, INK, mirror=False)
    else:
        # Replay scrubber overlay at bottom of map
        sc.rect(30, y + h - 46, 333, 34, INK, 12, "Replay player bar", mirror=False)
        sc.icon("play", 42, y + h - 37, 16, SURF, mirror=False)
        sc.rect(68, y + h - 31, 200, 4, ACCENT, 2, "Scrubber track", mirror=False)
        sc.rect(68, y + h - 31, 140, 4, PRIMARY, 2, "Scrubber fill", mirror=False)
        t_dur = mk("text.create", text="24:10", x=284, y=y + h - 36, parent=sc.F, select=False, name="Replay time",
                   props={"fontSize": 11, "fontFamily": "Inter", "fontWeight": 700, "fill": SURF})


def live_bus_map(lang: str) -> int:
    sc = Screen(lang, GROUP, "Live Bus Map", 0, STR); s = sc.s
    sc.status_bar()
    sc.header(s["map_title"], end_icon="broadcast")

    # Child selector pills (y=116)
    sc.rect(18, 116, 174, 36, PRIMARY, 18, "Child 1 pill")
    t1 = sc.text(s["ch_1"], 0, 125, 12, ONP, 700, name="Child 1 txt")
    S(t1, x=sc.ax(18, 174) + (174 - width(t1)) / 2)

    sc.rect(201, 116, 174, 36, SURF, 18, "Child 2 pill", stroke=BORDER)
    t2 = sc.text(s["ch_2"], 0, 125, 12, MUTED, 600, name="Child 2 txt")
    S(t2, x=sc.ax(201, 174) + (174 - width(t2)) / 2)

    # Interactive Map Canvas (y=162, h=350)
    draw_map_canvas(sc, 162, 350, replay=False)

    # Bottom Live Ride Sheet (y=524..812)
    sc.rect(18, 524, 357, 284, SURF, 26, "Live ETA sheet", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, -4], "radius": 20, "color": INK + "12"}])
    sc.rect(172, 534, 48, 4, BORDER, 2, "Sheet grabber", mirror=False)
    sc.text(s["eta_title"], 34, 550, 17, INK, 700, name="ETA title")
    sc.text(s["eta_sub"], 34, 575, 12, MUTED, 400, name="ETA sub")

    # 3-Step Route Progress Bar (y=608)
    sc.rect(34, 614, 325, 6, BORDER, 3, "Route track", mirror=False)
    sc.rect(34, 614, 218, 6, PRIMARY, 3, "Route active fill")
    sc.text(s["st_1"], 34, 628, 11, INK, 600, name="Step 1")
    sc.text(s["st_2"], 0, 628, 11, LINK, 700, align="center", name="Step 2")
    sc.text(s["st_3"], 34, 628, 11, MUTED, 600, align="end", name="Step 3")

    # Driver & Quick Call Box (y=660)
    sc.rect(32, 660, 329, 68, BG, 18, "Driver bar", stroke=BORDER)
    sc.rect(44, 672, 44, 44, ACCENT, 14, "Driver icon bg")
    sc.icon("bus", 55, 683, 22, INK)
    sc.text(s["drv_name"], 98, 673, 14, INK, 700, name="Driver name")
    sc.text(s["drv_sub"], 98, 695, 11, MUTED, 400, name="Driver sub")
    sc.rect(286, 676, 62, 36, PRIMARY, 12, "Call driver btn")
    tc = sc.text(s["btn_call"], 0, 685, 12, ONP, 700, name="Call driver txt")
    S(tc, x=sc.ax(286, 62) + (62 - width(tc)) / 2)

    # Bottom action buttons inside sheet (y=742)
    sc.rect(32, 742, 329, 50, INK, 16, "Open timeline CTA")
    sc.text(s["rt_title"], 0, 757, 15, SURF, 700, align="center", name="Open timeline txt")
    return sc.F


def live_route_timeline(lang: str) -> int:
    sc = Screen(lang, GROUP, "Live Route Timeline", 1, STR); s = sc.s
    sc.status_bar()
    sc.header(s["rt_title"], end_icon="navigation-arrow")

    # Route Header Banner (y=116..184)
    sc.rect(18, 116, 357, 68, SURF, 20, "Route banner", stroke=BORDER)
    sc.rect(32, 130, 40, 40, ACCENT, 12, "Route bus bg")
    sc.icon("bus", 42, 140, 20, INK)
    sc.text(s["rt_banner_t"], 82, 129, 15, INK, 700, name="Banner title")
    sc.text(s["rt_banner_s"], 82, 151, 12, MUTED, 400, name="Banner sub")
    sc.rect(292, 136, 68, 26, PRIMARY, 13, "On time pill")
    to = sc.text(s["rt_ontime"], 0, 141, 11, ONP, 700, name="On time txt")
    S(to, x=sc.ax(292, 68) + (68 - width(to)) / 2)

    # 3 Telemetry Metric Cards (y=196..258)
    metrics = [
        (18, s["m1_v"], s["m1_k"]),
        (140, s["m2_v"], s["m2_k"]),
        (262, s["m3_v"], s["m3_k"]),
    ]
    for mx, mv, mk_lbl in metrics:
        sc.rect(mx, 196, 113, 62, SURF, 16, f"Metric {mk_lbl}", stroke=BORDER)
        tv = sc.text(mv, 0, 206, 16, INK, 700, name=f"Val {mk_lbl}")
        S(tv, x=sc.ax(mx, 113) + (113 - width(tv)) / 2)
        tk = sc.text(mk_lbl, 0, 232, 11, MUTED, 500, name=f"Key {mk_lbl}")
        S(tk, x=sc.ax(mx, 113) + (113 - width(tk)) / 2)

    # 5-Stop Timeline (y=272..724)
    sc.section_label(s["rt_sec"], 272)
    stops = [
        (296, "check-circle", s["sp1_t"], s["sp1_s"], SURF, BORDER, ACCENT, INK),
        (378, "qr-code", s["sp2_t"], s["sp2_s"], SURF, BORDER, ACCENT, INK),
        (460, "check-circle", s["sp3_t"], s["sp3_s"], SURF, BORDER, ACCENT, INK),
        (542, "bus", s["sp4_t"], s["sp4_s"], ACCENT + "55", PRIMARY, PRIMARY, ONP),
        (624, "graduation-cap", s["sp5_t"], s["sp5_s"], SURF, BORDER, BG, MUTED),
    ]
    for sy, icn, st, ss, cbg, cbord, ibg, ifg in stops:
        sc.rect(18, sy, 357, 72, cbg, 18, f"Stop {st}", stroke=cbord)
        sc.rect(32, sy + 16, 40, 40, ibg, 20, f"Stop ic {st}", stroke=BORDER)
        sc.icon(icn, 42, sy + 26, 20, ifg)
        sc.text(st, 84, sy + 16, 14, INK, 700, name=f"Stop t {st}")
        sc.text(ss, 84, sy + 39, 12, LINK if cbord == PRIMARY else MUTED, 600 if cbord == PRIMARY else 400, name=f"Stop s {st}")

    sc.button(s["rt_share"], 742, lead_icon="share-network")
    return sc.F


def live_boarding_alerts(lang: str) -> int:
    sc = Screen(lang, GROUP, "Live Boarding Alerts", 2, STR); s = sc.s
    sc.status_bar()
    sc.header(s["al_title"], end_icon="bell")

    # Active Geofence Banner (y=118..198)
    sc.rect(18, 118, 357, 78, SURF, 20, "Geofence banner", stroke=PRIMARY)
    sc.rect(32, 135, 44, 44, PRIMARY, 14, "Geo icon bg")
    sc.icon("broadcast", 43, 146, 22, ONP)
    sc.text(s["al_geo_t"], 88, 136, 15, INK, 700, name="Geo title")
    sc.text(s["al_geo_s"], 88, 159, 12, MUTED, 400, name="Geo sub")

    # Live Telemetry Feed (4 events)
    sc.section_label(s["al_sec"], 214)
    events = [
        (238, "navigation-arrow", s["ev1_t"], s["ev1_s"], ACCENT + "55", PRIMARY, PRIMARY, ONP),
        (352, "qr-code", s["ev2_t"], s["ev2_s"], SURF, BORDER, ACCENT, INK),
        (466, "bell", s["ev3_t"], s["ev3_s"], SURF, BORDER, ACCENT, INK),
        (580, "bus", s["ev4_t"], s["ev4_s"], SURF, BORDER, BG, INK),
    ]
    for ey, icn, et, es, cbg, cbord, ibg, ifg in events:
        sc.rect(18, ey, 357, 100, cbg, 20, f"Event {et}", stroke=cbord)
        sc.rect(32, ey + 18, 44, 44, ibg, 14, f"Ev ic {et}", stroke=BORDER)
        sc.icon(icn, 43, ey + 29, 22, ifg)
        sc.text(et, 88, ey + 20, 15, INK, 700, name=f"Ev t {et}")
        sc.text(es, 88, ey + 46, 12, MUTED, 400, w=270, name=f"Ev s {et}")

    sc.secondary_button(s["al_btn"], 742, lead_icon="gear")
    return sc.F


def trip_history(lang: str) -> int:
    sc = Screen(lang, GROUP, "Trip History", 3, STR); s = sc.s
    sc.status_bar()
    sc.header(s["hs_title"], end_icon="calendar-blank")

    # Child & Month Selector Row (y=116)
    sc.rect(18, 116, 173, 42, SURF, 14, "Child filter picker", stroke=BORDER)
    sc.icon("user", 30, 128, 18, INK)
    sc.text(s["hs_child"], 56, 128, 13, INK, 700, name="Filter child")
    sc.icon("caret-down", 164, 130, 14, MUTED)

    sc.rect(202, 116, 173, 42, SURF, 14, "Month filter picker", stroke=BORDER)
    sc.icon("calendar-blank", 214, 128, 18, INK)
    sc.text(s["hs_month"], 240, 128, 13, INK, 700, name="Filter month")
    sc.icon("caret-down", 348, 130, 14, MUTED)

    # Filter pills (y=168)
    pills = [(18, 108, s["hf_all"], True), (134, 118, s["hf_am"], False), (260, 115, s["hf_pm"], False)]
    for px, pw, plbl, act in pills:
        sc.rect(px, 168, pw, 32, PRIMARY if act else SURF, 16, f"Hist chip {plbl}", stroke=PRIMARY if act else BORDER)
        tp = sc.text(plbl, 0, 176, 11, ONP if act else INK, 700 if act else 600, name=f"Hist chip txt {plbl}")
        S(tp, x=sc.ax(px, pw) + (pw - width(tp)) / 2)

    # 3 Summary KPI blocks (y=210..272)
    kpis = [(18, s["hk1_v"], s["hk1_k"]), (140, s["hk2_v"], s["hk2_k"]), (262, s["hk3_v"], s["hk3_k"])]
    for kx, kv, kk in kpis:
        sc.rect(kx, 210, 113, 60, SURF, 16, f"Hist KPI {kk}", stroke=BORDER)
        tv = sc.text(kv, 0, 219, 17, INK, 700, name=f"KPI v {kk}", latin=True)
        S(tv, x=sc.ax(kx, 113) + (113 - width(tv)) / 2)
        tk = sc.text(kk, 0, 245, 11, MUTED, 500, name=f"KPI k {kk}")
        S(tk, x=sc.ax(kx, 113) + (113 - width(tk)) / 2)

    # Group 1: Yesterday (y=284..518)
    sc.section_label(s["hs_d1"], 284)
    g1 = [
        (308, s["h1_t"], s["h1_s"], s["h1_b"], ACCENT, INK),
        (402, s["h2_t"], s["h2_s"], s["h2_b"], ACCENT, INK),
    ]
    for hy, ht, hs, hb, bbg, bfg in g1:
        sc.rect(18, hy, 357, 84, SURF, 18, f"Trip {ht}", stroke=BORDER)
        sc.rect(32, hy + 20, 44, 44, BG, 14, "Trip ic", stroke=BORDER)
        sc.icon("bus", 43, hy + 31, 22, INK)
        sc.text(ht, 88, hy + 18, 14, INK, 700, name=f"Trip t {ht}")
        sc.text(hs, 88, hy + 43, 11, MUTED, 400, name=f"Trip s {ht}")
        sc.rect(284, hy + 16, 76, 24, bbg, 12, f"Trip badge {hb}")
        tb = sc.text(hb, 0, hy + 21, 10, bfg, 700, name=f"Trip b {hb}")
        S(tb, x=sc.ax(284, 76) + (76 - width(tb)) / 2)

    # Group 2: Sun 08 Nov (y=502..736)
    sc.section_label(s["hs_d2"], 502)
    g2 = [
        (526, s["h3_t"], s["h3_s"], s["h3_b"], PRIMARY, ONP),
        (620, s["h4_t"], s["h4_s"], s["h4_b"], ACCENT, INK),
    ]
    for hy, ht, hs, hb, bbg, bfg in g2:
        sc.rect(18, hy, 357, 84, SURF, 18, f"Trip2 {ht}", stroke=BORDER)
        sc.rect(32, hy + 20, 44, 44, BG, 14, "Trip2 ic", stroke=BORDER)
        sc.icon("arrows-clockwise", 43, hy + 31, 22, INK)
        sc.text(ht, 88, hy + 18, 14, INK, 700, name=f"Trip2 t {ht}")
        sc.text(hs, 88, hy + 43, 11, MUTED, 400, name=f"Trip2 s {ht}")
        sc.rect(284, hy + 16, 76, 24, bbg, 12, f"Trip2 badge {hb}")
        tb = sc.text(hb, 0, hy + 21, 10, bfg, 700, name=f"Trip2 b {hb}")
        S(tb, x=sc.ax(284, 76) + (76 - width(tb)) / 2)

    sc.secondary_button(s["an_title"], 742, lead_icon="chart-bar")
    return sc.F


def trip_history_detail(lang: str) -> int:
    sc = Screen(lang, GROUP, "Trip History Detail", 4, STR); s = sc.s
    sc.status_bar()
    sc.header(s["hd_title"], end_icon="download-simple")

    sc.text(s["hd_date"], 0, 114, 13, LINK, 700, align="center", name="Replay date")
    # Recorded Route Map Replay (y=138, h=220)
    draw_map_canvas(sc, 138, 220, replay=True)

    # Route summary bar (y=368)
    sc.rect(18, 368, 357, 38, SURF, 12, "Route stats bar", stroke=BORDER)
    sc.text(s["hd_stat"], 0, 379, 12, INK, 700, align="center", name="Route stats txt")

    # QR Boarding & Hand-off Audit Log (y=420..608)
    sc.section_label(s["hd_sec_qr"], 420)
    logs = [
        (444, "qr-code", s["hd_q1_t"], s["hd_q1_s"], ACCENT),
        (528, "shield-check", s["hd_q2_t"], s["hd_q2_s"], PRIMARY),
    ]
    for ly, icn, lt, ls, ibg in logs:
        sc.rect(18, ly, 357, 74, SURF, 18, f"Audit {lt}", stroke=BORDER)
        sc.rect(32, ly + 15, 44, 44, ibg, 14, f"Audit ic {lt}")
        sc.icon(icn, 43, ly + 26, 22, ONP if ibg == PRIMARY else INK)
        sc.text(lt, 88, ly + 16, 14, INK, 700, name=f"Audit t {lt}")
        sc.text(ls, 88, ly + 39, 11, MUTED, 400, name=f"Audit s {lt}")

    # Vehicle & Driver Record (y=618..718)
    sc.section_label(s["hd_sec_drv"], 616)
    sc.rect(18, 640, 357, 74, SURF, 18, "Hist driver card", stroke=BORDER)
    sc.rect(32, 655, 44, 44, BG, 14, "Hist drv ic", stroke=BORDER)
    sc.icon("bus", 43, 666, 22, INK)
    sc.text(s["hd_drv_t"], 88, 656, 14, INK, 700, name="Hist drv t")
    sc.text(s["hd_drv_s"], 88, 679, 12, MUTED, 400, name="Hist drv s")

    sc.button(s["hd_btn"], 742, lead_icon="download-simple")
    return sc.F


def attendance_analytics(lang: str) -> int:
    sc = Screen(lang, GROUP, "Attendance & Analytics", 5, STR); s = sc.s
    sc.status_bar()
    sc.header(s["an_title"], end_icon="chart-bar")
    sc.text(s["an_sub"], 0, 114, 13, MUTED, 600, align="center", name="Analytics sub")

    # 3 KPI Cards (y=142..212)
    kpis = [
        (18, s["ak1_v"], s["ak1_k"], PRIMARY, ONP),
        (140, s["ak2_v"], s["ak2_k"], SURF, INK),
        (262, s["ak3_v"], s["ak3_k"], SURF, INK),
    ]
    for kx, kv, kk, kbg, kfg in kpis:
        sc.rect(kx, 142, 113, 68, kbg, 18, f"An KPI {kk}", stroke=PRIMARY if kbg == PRIMARY else BORDER)
        tv = sc.text(kv, 0, 152, 20, kfg, 700, name=f"An v {kk}", latin=True)
        S(tv, x=sc.ax(kx, 113) + (113 - width(tv)) / 2)
        tk = sc.text(kk, 0, 184, 11, kfg if kbg == PRIMARY else MUTED, 600, name=f"An k {kk}")
        S(tk, x=sc.ax(kx, 113) + (113 - width(tk)) / 2)

    # Weekly Ride Regularity Bar Chart Card (y=226..482)
    sc.section_label(s["an_sec_chart"], 226)
    sc.rect(18, 250, 357, 224, SURF, 22, "Chart card", stroke=BORDER)
    # Horizontal reference grid lines inside chart
    for gy in (284, 334, 384, 424):
        sc.rect(38, gy, 317, 1, BORDER, 0, "Grid line", mirror=False)

    days = [
        (s["d_sun"], 124, 120),
        (s["d_mon"], 128, 126),
        (s["d_tue"], 122, 118),
        (s["d_wed"], 128, 62),
        (s["d_thu"], 126, 124),
    ]
    for idx, (dlbl, h_am, h_pm) in enumerate(days):
        bx = 46 + idx * 64
        # Morning bar (PRIMARY) + Afternoon bar (ACCENT)
        sc.rect(bx, 424 - h_am, 16, h_am, PRIMARY, 6, f"Bar AM {dlbl}")
        sc.rect(bx + 20, 424 - h_pm, 16, h_pm, ACCENT, 6, f"Bar PM {dlbl}")
        td = sc.text(dlbl, 0, 436, 11, INK, 600, name=f"Chart day {dlbl}")
        S(td, x=sc.ax(bx, 36) + (36 - width(td)) / 2)

    # Safety & Punctuality Score Cards (y=492..718)
    sc.section_label(s["an_sec_safe"], 492)
    scores = [
        (516, "clock", s["an_s1_t"], s["an_s1_s"], ACCENT),
        (606, "shield-check", s["an_s2_t"], s["an_s2_s"], PRIMARY),
    ]
    for sy, icn, st, ss, ibg in scores:
        sc.rect(18, sy, 357, 78, SURF, 18, f"Score {st}", stroke=BORDER)
        sc.rect(32, sy + 17, 44, 44, ibg, 14, f"Score ic {st}")
        sc.icon(icn, 43, sy + 28, 22, ONP if ibg == PRIMARY else INK)
        sc.text(st, 88, sy + 18, 14, INK, 700, name=f"Score t {st}")
        sc.text(ss, 88, sy + 42, 11, MUTED, 400, name=f"Score s {st}")

    sc.button(s["an_btn"], 742, lead_icon="download-simple")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            live_bus_map(lang),
            live_route_timeline(lang),
            live_boarding_alerts(lang),
            trip_history(lang),
            trip_history_detail(lang),
            attendance_analytics(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
