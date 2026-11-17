"""Build Page '04 · Live Navigation & Stations' (6 screens x 2 languages = 12 frames).

Screens:
  0. Turn By Turn HUD (Maneuver bar, vector map canvas, bus speed, next stop drawer)
  1. Approaching Stop Radar (Geofence automated ping, 4 parent alerts delivered, curb student chips)
  2. Station Docking & Boarding (Docked station HUD, optical QR scanning viewfinder, multi-student manifest)
  3. One Tap Incident Detour (Zero-typing incident reporting, auto-recalculated detour, broadcast banner)
  4. Stations Route Timeline (7-stop vertical transit spine, completion checkmarks, skipped absence pill)
  5. Anti Abandonment Child Check (Mandatory rear-row safety walk, NFC/QR scan, signed shift completion)
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

PAGE_NAME = "04 · Live Navigation & Stations"
GROUP = "Driver Navigation"
SCREENS = [
    "Turn By Turn HUD",
    "Approaching Stop Radar",
    "Station Docking & Boarding",
    "One Tap Incident Detour",
    "Stations Route Timeline",
    "Anti Abandonment Child Check",
]
SECTIONS = {
    "en": "EN · Live Navigation & Stations (LTR)",
    "ar": "AR · الملاحة الحية وإدارة المحطات (RTL)",
}

STR = {
 "en": dict(
  # Navigation & Shared Header
  page_title="Live Route Navigation",
  page_sub="Bus 04 · Morning Line 12 · 7 Stops",
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",

  # Screen 0: Turn By Turn HUD
  maneuver_dist="350 m",
  maneuver_turn="Turn Right onto Blvd des Martyrs",
  maneuver_next="Then in 600m · Stop 04 (Martyrs Gate)",
  map_speed="38 km/h",
  map_limit="Limit 50",
  hud_next_stop="Stop 04 · Blvd des Martyrs 03",
  hud_eta="ETA 07:22 AM · 4 min · 4 Students",
  btn_detour="Detour",
  btn_arrived="Arrived at Stop",

  # Screen 1: Approaching Stop Radar
  app_title="Approaching Stop 04",
  app_sub="Radar Active · 320m to station curb",
  geo_title="Proximity Geofence Active (500m)",
  geo_sub="4 parent apps notified automatically: 'Bus 04 arriving in ~3 mins'.",
  geo_status="4/4 Delivered · 0 Manual Calls Needed",
  sec_curb_students="Expected Students at Stop 04 (4)",
  st_k1="Karim Hadj", st_k1_s="Seat B2 · Father at curb",
  st_k2="Sara Benali", st_k2_s="Seat B3 · Mother at curb",
  st_k3="Walid Khelil", st_k3_s="Seat A4 · Digital pass ready",
  st_k4="Ines Mansouri", st_k4_s="Seat A5 · Self-walker pass",
  curb_caution="School drop-off zone: Hazard flashers required on halt.",
  btn_dock_open="Confirm Docking & Open Doors",

  # Screen 2: Station Docking & Boarding
  dock_title="Stop 04 · Docked (07:21 AM)",
  dock_timer="Dwell Time: 01:15 / 02:00",
  scan_active="Optical QR Viewfinder Active",
  scan_last="Last Verified: Walid Khelil · Seat A4",
  b_boarded="BOARDED 07:21",
  b_waiting="WAITING AT CURB",
  txt_seat="Seat",
  qr_verified="QR Pass Verified",
  noshow_hint="Ines Mansouri not at curb (90s elapsed)",
  btn_call_ines="Call Mother (0550...)",
  btn_depart_stop="Depart Stop 04 (3/4 Boarded)",
  next_stop_strip="Next: Stop 05 Hydra North Gate · 6 mins",

  # Screen 3: One Tap Incident Detour
  inc_title="Report Route Incident",
  inc_sub="1-Tap detour recalculation · Alerts school dispatch & parents",
  inc_1_t="Heavy Traffic Jam", inc_1_d="+8 min delay",
  inc_2_t="Road Construction", inc_2_d="Lane closed ahead",
  inc_3_t="Vehicle Issue", inc_3_d="Flat tire / check engine",
  inc_4_t="Weather / Flooding", inc_4_d="Water ponding on avenue",
  detour_box_title="Alternate Detour Recalculated",
  detour_box_path="Via Blvd des Martyrs ➔ Rue Didouche Mourad",
  detour_box_impact="+4 min delay · Stops 05 & 06 ETAs updated automatically",
  detour_box_bcast="Immediate push alert queued for 11 remaining parents.",
  btn_apply_detour="Apply Detour & Broadcast Alert",
  btn_cancel_detour="Cancel · Maintain Current Route",

  # Screen 4: Stations Route Timeline
  tl_title="Morning Route 04 · Stations",
  tl_progress="3 of 7 Stops Done (57%) · On-time (+1 min ahead)",
  s1_name="Stop 01 · Hay El Nasr North", s1_time="07:08 AM · 3 Boarded",
  s2_name="Stop 02 · El Biar Central", s2_time="07:14 AM · 3 Boarded",
  s3_name="Stop 03 · Hay El Nasr Gate", s3_time="07:16 AM · 3 Boarded",
  s4_name="Stop 04 · Blvd des Martyrs 03", s4_time="CURRENT · 07:22 AM · 4 Students",
  s5_name="Stop 05 · Hydra North Gate", s5_time="07:28 AM · 1 Student · 1 Absent",
  s6_name="Stop 06 · El Mouradia Park", s6_time="07:34 AM · 1 Student Waiting",
  s7_name="Stop 07 · El Wiam Campus Gate", s7_time="07:45 AM · Terminus Disembark",
  badge_bypassed="ABSENT BYPASSED",

  # Screen 5: Anti Abandonment Child Check
  chk_title="Mandatory Child Check-Mate",
  chk_sub="Algerian School Transport Protocol · Never leave a child behind",
  chk_term_t="Terminus Reached: El Wiam Campus (07:45 AM)",
  chk_term_s="All 14 students disembarked to school supervisors.",
  chk_sec="3-Step Physical Inspection Protocol",
  chk_s1_t="Walk down central aisle to rear row", chk_s1_s="Completed at 07:46 AM",
  chk_s2_t="Inspect under seats & floor for sleeping children", chk_s2_s="Completed at 07:47 AM",
  chk_s3_t="Scan physical NFC badge at rear bus wall", chk_s3_s="Pending driver tap at rear row",
  chk_dec="I certify under penalty of safety regulations that the bus interior is 100% inspected and empty.",
  btn_certify="Certify Bus Empty & Lock Shift",
 ),
 "ar": dict(
  # Navigation & Shared Header
  page_title="الملاحة الحية للمسار",
  page_sub="حافلة 04 · خط الصباح 12 · 7 محطات",
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="حسابي",

  # Screen 0: Turn By Turn HUD
  maneuver_dist="350 م",
  maneuver_turn="انعطف يميناً نحو شارع الشهداء",
  maneuver_next="ثم بعد 600 م · المحطة 04 (بوابة الشهداء)",
  map_speed="38 كم/سا",
  map_limit="الحد 50",
  hud_next_stop="المحطة 04 · شارع الشهداء 03",
  hud_eta="الوصول 07:22 ص · 4 دقائق · 4 طلاب",
  btn_detour="تحويلة",
  btn_arrived="وصلت للمحطة",

  # Screen 1: Approaching Stop Radar
  app_title="رادار الاقتراب من المحطة 04",
  app_sub="الرادار نشط · 320 م تفصلك عن رصيف المحطة",
  geo_title="تفعيل تنبيه الاقتراب التلقائي (500 م)",
  geo_sub="تم إرسال إشعار فوري لـ 4 أولياء أمور: الحافلة تصل خلال ~3 دقائق.",
  geo_status="4/4 تم التسليم · 0 مكالمات مطلوبة",
  sec_curb_students="الطلاب المتوقعون في المحطة 04 (4)",
  st_k1="كريم حاج", st_k1_s="مقعد B2 · الأب عند الرصيف",
  st_k2="سارة بن علي", st_k2_s="مقعد B3 · الأم عند الرصيف",
  st_k3="وليد خليل", st_k3_s="مقعد A4 · البطاقة الرقمية جاهزة",
  st_k4="إيناس منصوري", st_k4_s="مقعد A5 · ركوب ذاتي موثق",
  curb_caution="منطقة مدارس: تشغيل أضواء التحذير الرباعية إلزامي عند التوقف.",
  btn_dock_open="تأكيد التوقف وفتح الأبواب",

  # Screen 2: Station Docking & Boarding
  dock_title="المحطة 04 · متوقف (07:21 ص)",
  dock_timer="عداد التوقف: 01:15 / 02:00",
  scan_active="المسح البصري لبطاقات QR نشط",
  scan_last="آخر مسح موثق: وليد خليل · مقعد A4",
  b_boarded="صعد 07:21",
  b_waiting="بانتظار عند الرصيف",
  txt_seat="مقعد",
  qr_verified="تم توثيق الرمز الرقمي QR",
  noshow_hint="إيناس منصوري لم تصعد بعد (انقضت 90 ثانية)",
  btn_call_ines="اتصال بالأم (0550...)",
  btn_depart_stop="مغادرة المحطة (صعد 3/4)",
  next_stop_strip="التالي: المحطة 05 بوابة حيدرة · 6 دقائق",

  # Screen 3: One Tap Incident Detour
  inc_title="إبلاغ فوري عن طارئ بالمسار",
  inc_sub="إعادة حساب المسار بنقرة واحدة · إشعار المدرسة والأولياء فوراً",
  inc_1_t="ازدحام مروري خانق", inc_1_d="تأخير +8 دقائق",
  inc_2_t="أشغال وإغلاق طريق", inc_2_d="المسار مغلق أمام الحافلة",
  inc_3_t="عطل ميكانيكي بالحافلة", inc_3_d="بنشر عجلة / مؤشر المحرك",
  inc_4_t="طقس سيء وتجمع مياه", inc_4_d="مياه أمطار تعيق العبور",
  detour_box_title="تم احتساب مسار تحويلة بديل تلقائياً",
  detour_box_path="عبر شارع الشهداء ➔ شارع ديدوش مراد",
  detour_box_impact="تأخير +4 دقائق · تم تحديث مواعيد المحطتين 05 و06 تلقائياً",
  detour_box_bcast="تم تجهيز إشعار فوري لـ 11 ولي أمر باقين وإدارة المدرسة.",
  btn_apply_detour="اعتماد التحويلة وبث التنبيه",
  btn_cancel_detour="إلغاء · البقاء بالمسار الأصلي",

  # Screen 4: Stations Route Timeline
  tl_title="محطات خط الصباح 04",
  tl_progress="تم إنجاز 3 من أصل 7 محطات (57%) · في الموعد (+1 د)",
  s1_name="المحطة 01 · حي النصر شمال", s1_time="07:08 ص · 3 صعدوا",
  s2_name="المحطة 02 · الأبيار وسط", s2_time="07:14 ص · 3 صعدوا",
  s3_name="المحطة 03 · بوابة حي النصر", s3_time="07:16 ص · 3 صعدوا",
  s4_name="المحطة 04 · شارع الشهداء 03", s4_time="الحالية · 07:22 ص · 4 طلاب",
  s5_name="المحطة 05 · بوابة حيدرة", s5_time="07:28 ص · طالب 1 · 1 غياب",
  s6_name="المحطة 06 · حديقة المرادية", s6_time="07:34 ص · طالب بانتظار",
  s7_name="المحطة 07 · مجمع مدارس الوئام", s7_time="07:45 ص · نهاية الرحلة والنزول",
  badge_bypassed="تم تجاوز الغائب",

  # Screen 5: Anti Abandonment Child Check
  chk_title="بروتوكول التحقق الإلزامي من خلو الحافلة",
  chk_sub="بروتوكول السلامة المعتمد للنقل المدرسي · منع نسيان أي طفل",
  chk_term_t="تم الوصول لنهاية الخط: مجمع الوئام (07:45 ص)",
  chk_term_s="تم نزول جميع الطلاب الـ 14 وتسليمهم لمشرفي المدرسة.",
  chk_sec="بروتوكول الفحص الفيزيائي من 3 خطوات",
  chk_s1_t="المشي بالممر المركزي حتى الصف الأخير", chk_s1_s="تم الإنجاز في 07:46 ص",
  chk_s2_t="فحص أسفل المقاعد والأرضية للتأكد من عدم نوم أي طفل", chk_s2_s="تم الإنجاز في 07:47 ص",
  chk_s3_t="مسح شريحة NFC الفيزيائية المثبتة بالجدار الخلفي", chk_s3_s="بانتظار تمرير الهاتف بالصف الأخير",
  chk_dec="أقر بموجب لوائح الأمان المدرسية أنني قمت بفحص مقاعد الحافلة بالكامل والتأكد من خلوها 100%.",
  btn_certify="توثيق خلو الحافلة بالكامل وإغلاق الوردية",
 ),
}


def driver_bottom_nav(sc: Screen, active: int = 2):
    """Draw the floating capsule 4-item navbar with Navigation active (index 2)."""
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


def draw_nav_map_canvas(sc: Screen, y: int, h: int):
    """Draw a vector navigation street map with live route path, bus halo, and stop markers."""
    s = sc.s
    # Map base container
    sc.rect(18, y, 357, h, "#EAE5D9", 22, "Map container", stroke=BORDER, mirror=False)

    # Green park zones
    sc.rect(28, y + 16, 92, 64, "#DDE8DC", 12, "Park 1", mirror=False)
    sc.rect(248, y + h - 88, 114, 70, "#DDE8DC", 12, "Park 2", mirror=False)

    # City building blocks
    sc.rect(136, y + 20, 112, 54, "#E2DDD0", 8, "Block 1", mirror=False)
    sc.rect(34, y + 98, 104, 78, "#E2DDD0", 8, "Block 2", mirror=False)
    sc.rect(164, y + 94, 196, 68, "#E2DDD0", 8, "Block 3", mirror=False)

    # White arterial roads
    sc.rect(18, y + 84, 357, 14, SURF, 0, "Road H1", mirror=False)
    sc.rect(18, y + h - 100, 357, 12, SURF, 0, "Road H2", mirror=False)
    sc.rect(124, y, 14, h, SURF, 0, "Road V1", mirror=False)
    sc.rect(254, y, 12, h, SURF, 0, "Road V2", mirror=False)

    # Route polyline connecting Stop 03 -> Bus -> Stop 04 -> Next Stop 05
    pts = [
        [54, y + h - 50],
        [130, y + h - 94],
        [186, y + 116],
        [260, y + 90],
        [312, y + 46],
    ]
    mk(
        "vector.create",
        points=pts,
        closed=False,
        parent=sc.F,
        name="Route Polyline",
        select=False,
        props={
            "stroke": PRIMARY,
            "strokeWeight": 6,
            "strokeCap": "round",
            "strokeJoin": "round",
            "fill": "none",
        },
    )

    # Stop 03 (Passed - Green checkmark)
    sc.rect(42, y + h - 62, 24, 24, "#E8F8F0", 12, "Stop 03 pin", stroke="#1B8A4D", mirror=False)
    sc.icon("check", 47, y + h - 57, 14, "#1B8A4D", mirror=False)

    # Stop 04 (Next Stop - Pulsing Golden Pin)
    sc.rect(248, y + 78, 28, 28, PRIMARY, 14, "Stop 04 pin", stroke=SURF, mirror=False)
    sc.icon("map-pin", 254, y + 84, 16, ONP, mirror=False)
    # Stop 04 Tooltip badge
    sc.rect(204, y + 54, 116, 20, INK, 10, "Stop 04 tag", mirror=False)
    t_s4 = sc.text("Stop 04 · 4 Students", 0, y + 58, 9.5, SURF, 700, latin=True)
    S(t_s4, x=212)

    # Live Bus Marker (with golden pulsing halo)
    sc.rect(168, y + 100, 40, 40, PRIMARY + "33", 20, "Bus halo", mirror=False)
    sc.rect(174, y + 106, 28, 28, INK, 14, "Bus marker", stroke=SURF, mirror=False)
    sc.icon("bus", 180, y + 112, 16, SURF, mirror=False)

    # Floating Telemetry: Speedometer Pill (top right)
    sc.rect(254, y + 14, 106, 28, SURF, 14, "Speed pill", stroke=BORDER, mirror=False)
    sc.icon("navigation-arrow", 262, y + 21, 14, PRIMARY, mirror=False)
    t_sp = sc.text(f"{s['map_speed']}", 0, y + 20, 11, INK, 700, latin=(sc.lang == "en"))
    S(t_sp, x=280)

    # Floating Controls: Sound toggle & Recenter (bottom right of map)
    sc.rect(323, y + h - 86, 36, 36, SURF, 18, "Sound btn", stroke=BORDER, mirror=False)
    sc.icon("bell", 332, y + h - 77, 18, INK, mirror=False)
    sc.rect(323, y + h - 44, 36, 36, SURF, 18, "Recenter btn", stroke=BORDER, mirror=False)
    sc.icon("navigation-arrow", 332, y + h - 35, 18, PRIMARY, mirror=False)


def turn_by_turn_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Turn By Turn HUD", 0, STR)
    s = sc.s
    sc.status_bar()

    # Maneuver Banner (y=56, h=98)
    sc.rect(18, 56, 357, 98, INK, 22, "Maneuver card",
            effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 20, "color": INK + "30"}])
    # Maneuver Icon Box
    sc.rect(32, 70, 48, 48, PRIMARY, 16, "Maneuver icon box")
    sc.icon("arrow-right", 44, 82, 24, ONP)

    # Distance & Instruction
    sc.text(s["maneuver_dist"], 92, 68, 22, SURF, 800, w=260)
    sc.text(s["maneuver_turn"], 92, 94, 12.5, SURF, 600, w=260)

    # Next preview ribbon
    sc.rect(92, 118, 265, 22, SURF + "18", 8, "Next ribbon")
    sc.icon("caret-right", 98, 123, 12, PRIMARY)
    sc.text(s["maneuver_next"], 116, 122, 10, SURF + "CC", 500, w=235)

    # Vector Map View (y=164, h=416)
    draw_nav_map_canvas(sc, 164, 416)

    # Bottom Sheet HUD (y=590, h=148)
    sc.rect(18, 590, 357, 148, SURF, 22, "Bottom HUD sheet", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 16, "color": INK + "12"}])

    # Next Stop Title & ETA
    sc.icon("map-pin", 32, 606, 20, PRIMARY)
    sc.text(s["hud_next_stop"], 58, 604, 15, INK, 700, w=240)
    sc.text(s["hud_eta"], 58, 626, 11.5, MUTED, 500, w=240)

    # ETA Pill on right
    sc.rect(280, 604, 80, 26, ACCENT, 13, "ETA pill")
    sc.text("4 min", 280, 610, 11, INK, 800, w=80, align="center")

    # Action Row inside bottom sheet
    # Detour Secondary Button (w=112)
    sc.rect(32, 660, 108, 48, "#F8F5EC", 16, "Detour btn", stroke=BORDER)
    sc.icon("warning-circle", 44, 674, 20, INK)
    sc.text(s["btn_detour"], 70, 676, 13, INK, 700)

    # Arrived at Stop Primary Button (w=200)
    sc.rect(150, 660, 210, 48, PRIMARY, 16, "Arrived btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 10, "color": PRIMARY + "40"}])
    sc.icon("map-pin", 164, 674, 20, ONP)
    sc.text(s["btn_arrived"], 192, 676, 13.5, ONP, 700)

    driver_bottom_nav(sc, active=2)
    return sc.F


def approaching_radar_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Approaching Stop Radar", 1, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["app_title"], end_icon="broadcast")

    # Geofence Trigger Banner (y=116, h=90)
    sc.rect(18, 116, 357, 90, "#E8F8F0", 20, "Geofence card", stroke="#1B8A4D40",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": "#1B8A4D15"}])
    sc.rect(30, 134, 44, 44, "#1B8A4D", 14, "Geo icon box")
    sc.icon("broadcast", 41, 145, 22, SURF)

    sc.text(s["geo_title"], 84, 124, 13.5, "#1B8A4D", 800, w=275)
    sc.text(s["geo_sub"], 84, 144, 11, INK, 500, w=275)
    sc.text(s["geo_status"], 84, 178, 10.5, "#1B8A4D", 700, w=275)

    # Mini Zoomed Curb Map Strip (y=218, h=114)
    sc.rect(18, 218, 357, 114, "#EAE5D9", 18, "Curb map", stroke=BORDER, mirror=False)
    sc.rect(18, 266, 357, 18, SURF, 0, "Road curb", mirror=False)
    # Target curb station marker
    sc.rect(260, 256, 36, 36, PRIMARY, 18, "Target curb", stroke=SURF, mirror=False)
    sc.icon("map-pin", 269, 265, 18, ONP, mirror=False)
    # Bus approaching
    sc.rect(90, 260, 30, 30, INK, 15, "Bus curb", stroke=SURF, mirror=False)
    sc.icon("bus", 96, 266, 18, SURF, mirror=False)
    # Distance indicator pill
    sc.rect(130, 262, 116, 26, INK, 13, "Distance pill", mirror=False)
    t_dc = sc.text("320 m to curb", 0, 268, 11, SURF, 700, latin=True)
    S(t_dc, x=144)

    # Expected Students at Curb Section (y=344)
    sc.section_label(s["sec_curb_students"], 344)

    # 4 Students 2x2 Grid (y=370, 442; h=64 each)
    students = [
        (s["st_k1"], s["st_k1_s"], 18, 370),
        (s["st_k2"], s["st_k2_s"], 200, 370),
        (s["st_k3"], s["st_k3_s"], 18, 442),
        (s["st_k4"], s["st_k4_s"], 200, 442),
    ]
    for sn, ss, cx, cy in students:
        sc.rect(cx, cy, 175, 64, SURF, 16, f"Student {sn}", stroke=BORDER)
        sc.rect(cx + 10, cy + 12, 38, 38, ACCENT, 19, "Student avatar")
        sc.icon("user", cx + 19, cy + 21, 20, INK)
        sc.text(sn, cx + 54, cy + 13, 12.5, INK, 700, w=115)
        sc.text(ss, cx + 54, cy + 33, 10, MUTED, 500, w=115)

    # Curb Safety Caution Box (y=518, h=52)
    sc.rect(18, 518, 357, 52, "#FFF8E7", 16, "Curb caution box", stroke="#D4A01780")
    sc.icon("warning-circle", 30, 533, 22, "#946A00")
    sc.text(s["curb_caution"], 60, 534, 11, "#946A00", 600, w=300)

    # Big CTA Button (y=580)
    sc.rect(18, 580, 357, 54, PRIMARY, 18, "Dock CTA btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("map-pin", 32, 596, 22, ONP)
    sc.text(s["btn_dock_open"], 0, 597, 15, ONP, 700, align="center")

    driver_bottom_nav(sc, active=2)
    return sc.F


def station_docking_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Station Docking & Boarding", 2, STR)
    s = sc.s
    sc.status_bar()

    # Station Docked Header (y=56, h=52)
    sc.rect(18, 56, 357, 52, INK, 18, "Dock header", mirror=False)
    sc.icon("map-pin", 30, 71, 20, PRIMARY)
    sc.text(s["dock_title"], 58, 65, 14, SURF, 700)
    sc.text(s["dock_timer"], 58, 83, 11, PRIMARY, 600)
    # Stop duration pill
    sc.rect(266, 68, 96, 26, SURF + "22", 13, "Timer pill", mirror=False)
    t_tm = sc.text("01:15", 0, 74, 11, SURF, 700, latin=True)
    S(t_tm, x=298)

    # Continuous QR Viewfinder Card (y=116, h=164)
    sc.rect(18, 116, 357, 164, "#161616", 20, "QR Scanner card",
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 18, "color": INK + "40"}])
    # Target brackets
    sc.rect(136, 132, 120, 96, "#222222", 12, "Scanner box", stroke=PRIMARY, mirror=False)
    sc.icon("qr-code", 176, 160, 40, PRIMARY, mirror=False)
    # Laser bar
    sc.rect(142, 178, 108, 2, PRIMARY, 0, "Laser line", mirror=False)

    # Top scanner status
    sc.rect(32, 126, 92, 22, "#2A2A2A", 11, "Scan mode pill")
    sc.text("LIVE CAMERA", 32, 131, 9, "#1B8A4D", 800, w=92, align="center")

    # Bottom scan feedback pill
    sc.rect(32, 240, 329, 28, PRIMARY + "25", 14, "Last scan pill", stroke=PRIMARY)
    sc.icon("check-circle", 42, 246, 16, PRIMARY)
    sc.text(s["scan_last"], 66, 247, 11, PRIMARY, 700)

    # Boarding Roster at this Stop (y=290)
    sc.section_label(s["sec_curb_students"], 290)

    board_list = [
        (s["st_k1"], "B2", True, s["b_boarded"], 316),
        (s["st_k2"], "B3", True, s["b_boarded"], 372),
        (s["st_k3"], "A4", True, s["b_boarded"], 428),
        (s["st_k4"], "A5", False, s["b_waiting"], 484),
    ]
    for cname, cseat, is_boarded, bstatus, by in board_list:
        sc.rect(18, by, 357, 50, SURF, 16, f"Board card {cname}", stroke=BORDER)
        sc.rect(28, by + 9, 32, 32, "#E8F8F0" if is_boarded else "#FFF3E0", 16, "Avatar")
        sc.icon("check" if is_boarded else "user", 36, by + 17, 16, "#1B8A4D" if is_boarded else "#E67E22")

        sc.text(f"{cname} · {s['txt_seat']} {cseat}", 70, by + 11, 13, INK, 700, w=170)
        sc.text(s["qr_verified"] if is_boarded else s["noshow_hint"], 70, by + 29, 10, "#1B8A4D" if is_boarded else MUTED, 500, w=170)

        # Status badge
        sc.rect(248, by + 12, 115, 26, "#E8F8F0" if is_boarded else "#FFF3E0", 13, "Badge",
                stroke="#1B8A4D40" if is_boarded else "#E67E2240")
        sc.text(bstatus, 248, by + 18, 9.5, "#1B8A4D" if is_boarded else "#E67E22", 800, w=115, align="center")

    # Quick Ines Call button row (y=544)
    sc.rect(18, 544, 357, 36, "#FFF8E7", 14, "Ines call row", stroke=BORDER)
    sc.icon("phone", 30, 553, 16, "#D4A017")
    sc.text(s["btn_call_ines"], 54, 554, 11, INK, 700)

    # Depart Stop CTA (y=590)
    sc.rect(18, 590, 357, 54, PRIMARY, 18, "Depart stop btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("arrow-right", 32, 606, 22, ONP)
    sc.text(s["btn_depart_stop"], 0, 607, 15, ONP, 700, align="center")

    driver_bottom_nav(sc, active=2)
    return sc.F

    driver_bottom_nav(sc, active=2)
    return sc.F


def incident_detour_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "One Tap Incident Detour", 3, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["inc_title"], end_icon="warning-circle")
    sc.sub(s["inc_sub"], 112, w=340)

    # 4 Instant Incident Cards (2x2 Grid, y=166)
    incidents = [
        (s["inc_1_t"], s["inc_1_d"], "warning-circle", 18, 166, True, PRIMARY),
        (s["inc_2_t"], s["inc_2_d"], "shield-check", 200, 166, False, "#E67E22"),
        (s["inc_3_t"], s["inc_3_d"], "gear", 18, 260, False, DESTR),
        (s["inc_4_t"], s["inc_4_d"], "warning-circle", 200, 260, False, "#3498DB"),
    ]
    for it, idesc, ic, ix, iy, is_sel, icol in incidents:
        sc.rect(ix, iy, 175, 84, "#FFFDF5" if is_sel else SURF, 18, f"Incident {it}",
                stroke=PRIMARY if is_sel else BORDER,
                effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": (PRIMARY if is_sel else INK) + "18"}])
        sc.rect(ix + 12, iy + 12, 36, 36, icol + "22", 14, "Inc icon box")
        sc.icon(ic, ix + 20, iy + 20, 20, icol)
        if is_sel:
            sc.icon("check-circle", ix + 144, iy + 14, 18, PRIMARY)

        sc.text(it, ix + 12, iy + 52, 12.5, INK, 700, w=150)
        sc.text(idesc, ix + 12, iy + 68, 10, MUTED, 500, w=150)

    # Detour Recalculated Card (y=358, h=152)
    sc.rect(18, 358, 357, 152, SURF, 22, "Detour box", stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 16, "color": PRIMARY + "20"}])
    # Ribbon
    sc.rect(34, 372, 325, 28, "#FFF8E7", 12, "Detour ribbon", stroke=BORDER)
    sc.icon("compass", 44, 378, 16, "#946A00")
    sc.text(s["detour_box_title"], 68, 379, 11, "#946A00", 800, w=270)

    sc.icon("navigation-arrow", 34, 412, 18, PRIMARY)
    sc.text(s["detour_box_path"], 58, 410, 13, INK, 800, w=300)
    sc.text(s["detour_box_impact"], 58, 430, 11, INK, 600, w=300)

    sc.rect(34, 458, 325, 40, "#E8F8F0", 12, "Bcast pill", stroke="#1B8A4D40")
    sc.icon("broadcast", 44, 470, 16, "#1B8A4D")
    sc.text(s["detour_box_bcast"], 68, 466, 10.5, "#1B8A4D", 700, w=275)

    # Primary Action: Apply Detour
    sc.rect(18, 524, 357, 52, PRIMARY, 18, "Apply detour btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("navigation-arrow", 32, 539, 20, ONP)
    sc.text(s["btn_apply_detour"], 0, 540, 14.5, ONP, 700, align="center")

    # Secondary Action: Cancel
    sc.rect(18, 584, 357, 48, SURF, 16, "Cancel detour btn", stroke=BORDER)
    sc.text(s["btn_cancel_detour"], 0, 599, 13, MUTED, 600, align="center")

    driver_bottom_nav(sc, active=2)
    return sc.F


def stations_timeline_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Stations Route Timeline", 4, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["tl_title"], end_icon="arrows-clockwise")

    # Route Progress Banner (y=116, h=52)
    sc.rect(18, 116, 357, 52, INK, 18, "Progress banner")
    sc.icon("bus", 30, 132, 20, PRIMARY)
    sc.text(s["tl_progress"], 58, 125, 12, SURF, 700, w=300)
    # Micro progress bar
    sc.rect(58, 148, 290, 6, "#3A3A3A", 3, "Track", mirror=False)
    sc.rect(58, 148, 165, 6, PRIMARY, 3, "Fill", mirror=False)

    # Vertical Transit Spine (7 Stops, y=182 to y=642)
    stops = [
        (s["s1_name"], s["s1_time"], "done", 182),
        (s["s2_name"], s["s2_time"], "done", 244),
        (s["s3_name"], s["s3_time"], "done", 306),
        (s["s4_name"], s["s4_time"], "current", 368),
        (s["s5_name"], s["s5_time"], "skip", 436),
        (s["s6_name"], s["s6_time"], "pending", 504),
        (s["s7_name"], s["s7_time"], "school", 566),
    ]

    # Spine line
    sc.rect(38, 194, 2, 386, BORDER, 0, "Spine line")

    for sname, stime, stype, sy in stops:
        if stype == "done":
            sc.rect(28, sy + 6, 22, 22, "#E8F8F0", 11, f"Pin {sname}", stroke="#1B8A4D")
            sc.icon("check", 33, sy + 11, 12, "#1B8A4D")
            sc.text(sname, 62, sy + 2, 13, INK, 600, w=280)
            sc.text(stime, 62, sy + 22, 11, MUTED, 500, w=280)

        elif stype == "current":
            # Active Stop Highlight Card
            sc.rect(18, sy - 4, 357, 62, "#FFFDF2", 16, "Current stop card", stroke=PRIMARY,
                    effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "20"}])
            sc.rect(26, sy + 4, 26, 26, PRIMARY, 13, f"Pin {sname}", stroke=SURF)
            sc.icon("map-pin", 31, sy + 9, 16, ONP)
            sc.text(sname, 62, sy + 2, 13.5, INK, 800, w=220)
            sc.text(stime, 62, sy + 24, 11, "#946A00", 700, w=220)
            sc.rect(296, sy + 6, 68, 22, PRIMARY, 11, "Now pill")
            sc.text("NOW", 296, sy + 10, 9.5, ONP, 800, w=68, align="center")

        elif stype == "skip":
            sc.rect(28, sy + 6, 22, 22, DSURF, 11, f"Pin {sname}", stroke=DBORD)
            sc.icon("warning-circle", 33, sy + 11, 12, DESTR)
            sc.text(sname, 62, sy + 2, 13, INK, 600, w=190)
            sc.text(stime, 62, sy + 22, 11, MUTED, 500, w=190)
            sc.rect(254, sy + 6, 112, 22, DSURF, 11, "Bypass pill", stroke=DBORD)
            sc.text(s["badge_bypassed"], 254, sy + 10, 9, DESTR, 700, w=112, align="center")

        elif stype == "pending":
            sc.rect(28, sy + 6, 22, 22, SURF, 11, f"Pin {sname}", stroke=BORDER)
            sc.icon("clock", 33, sy + 11, 12, MUTED)
            sc.text(sname, 62, sy + 2, 13, INK, 600, w=280)
            sc.text(stime, 62, sy + 22, 11, MUTED, 500, w=280)

        elif stype == "school":
            sc.rect(28, sy + 6, 22, 22, INK, 11, f"Pin {sname}", stroke=SURF)
            sc.icon("graduation-cap", 33, sy + 11, 12, SURF)
            sc.text(sname, 62, sy + 2, 13.5, INK, 800, w=280)
            sc.text(stime, 62, sy + 24, 11, MUTED, 600, w=280)

    # Route summary at bottom (y=636)
    sc.rect(18, 636, 357, 44, SURF, 16, "Timeline stat", stroke=BORDER)
    sc.icon("info", 32, 648, 18, PRIMARY)
    sc.text("Total distance: 12.4 km · All 7 stops monitored live", 60, 650, 11.5, INK, 600)

    driver_bottom_nav(sc, active=2)
    return sc.F


def anti_abandonment_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Anti Abandonment Child Check", 5, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["chk_title"], end_icon="shield-check")
    sc.sub(s["chk_sub"], 112, w=340)

    # Terminus Status Card (y=160, h=82)
    sc.rect(18, 160, 357, 82, "#E8F8F0", 20, "Terminus card", stroke="#1B8A4D40")
    sc.rect(30, 178, 44, 44, "#1B8A4D", 14, "Term icon")
    sc.icon("graduation-cap", 41, 189, 22, SURF)
    sc.text(s["chk_term_t"], 84, 170, 13, "#1B8A4D", 800, w=275)
    sc.text(s["chk_term_s"], 84, 196, 11, INK, 500, w=275)

    # 3-Step Protocol Section (y=254)
    sc.section_label(s["chk_sec"], 254)

    steps = [
        (s["chk_s1_t"], s["chk_s1_s"], True, 278),
        (s["chk_s2_t"], s["chk_s2_s"], True, 350),
        (s["chk_s3_t"], s["chk_s3_s"], False, 422),
    ]
    for stitle, sdesc, is_done, sy in steps:
        sc.rect(18, sy, 357, 64, SURF, 18, f"Step card {stitle}",
                stroke="#1B8A4D" if is_done else PRIMARY)
        sc.rect(28, sy + 14, 36, 36, "#E8F8F0" if is_done else PRIMARY + "20", 14, "Step ic box")
        sc.icon("check" if is_done else "broadcast", 38, sy + 24, 18, "#1B8A4D" if is_done else PRIMARY)

        sc.text(stitle, 74, sy + 12, 12, INK, 700, w=200)
        sc.text(sdesc, 74, sy + 36, 10, "#1B8A4D" if is_done else PRIMARY, 600, w=200)

        if not is_done:
            # Active NFC tap pill
            sc.rect(270, sy + 17, 95, 30, PRIMARY, 15, "Scan NFC pill")
            sc.text("TAP NFC", 270, sy + 23, 10, ONP, 800, w=95, align="center")

    # Legal Sign-Off Declaration (y=498, h=74)
    sc.rect(18, 498, 357, 74, "#FFFDF2", 18, "Declaration card", stroke=BORDER)
    sc.icon("shield-check", 30, 514, 20, PRIMARY)
    sc.text(s["chk_dec"], 58, 512, 11, INK, 600, w=300)

    # Final CTA: Certify & Lock Shift (y=584)
    sc.rect(18, 584, 357, 56, PRIMARY, 18, "Certify CTA btn",
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 14, "color": PRIMARY + "40"}])
    sc.icon("lock-simple", 32, 601, 22, ONP)
    sc.text(s["btn_certify"], 0, 602, 15, ONP, 700, align="center")
    sc.icon("lock-simple", 32, 601, 22, ONP)
    sc.text(s["btn_certify"], 0, 602, 15, ONP, 700, align="center")

    driver_bottom_nav(sc, active=2)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            turn_by_turn_screen(lang),
            approaching_radar_screen(lang),
            station_docking_screen(lang),
            incident_detour_screen(lang),
            stations_timeline_screen(lang),
            anti_abandonment_screen(lang),
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
    out_png = os.path.join(shots_dir, "driver-04-navigation-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    # Save to dedicated driver document files
    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-navigation.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        print(f"saved: {fpath} ({os.path.getsize(fpath)} bytes)")


if __name__ == "__main__":
    main()
