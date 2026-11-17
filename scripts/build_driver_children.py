"""Build Page '03 · Students Roster & Manifest' (6 screens x 2 languages = 12 frames).

Screens:
  0. Students Roster & Filter (Full list, search, filter chips, swipe hint, glanceable cards)
  1. Manifest By Stops (Grouped view by route stops in chronological order)
  2. Student Dossier - Transit Tab (Bus seat, morning/afternoon stop times, QR code ID)
  3. Student Dossier - Medical Tab (Asthma/allergy alerts, first-aid protocol, pediatrician)
  4. Student Dossier - Guardian Tab (Authorized pickup guardians, strict dismissal rule)
  5. Today's Absences & Notes (Pre-reported absences, bypassed stops, manual no-show)
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

PAGE_NAME = "03 · Students Roster & Manifest"
GROUP = "Driver Students"
SCREENS = [
    "Students Roster & Filter",
    "Manifest By Stops",
    "Student Dossier - Transit",
    "Student Dossier - Medical",
    "Student Dossier - Guardian",
    "Today's Absences & Notes",
]
SECTIONS = {
    "en": "EN · Students Roster & Manifest (LTR)",
    "ar": "AR · قائمة ركاب الحافلة والطلاب (RTL)",
}

STR = {
 "en": dict(
  # Navigation & Shared Header
  page_title="Students Manifest",
  page_sub="Bus 04 · 14 Students Enrolled",
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",
  search_ph="Search student, stop or seat...",

  # Screen 0: Students Roster & Filter
  f_all="All (14)", f_board="On Bus (9)", f_wait="Waiting (3)", f_abs="Absent (2)",
  swipe_hint="💡 Swipe right to Board · Tap for details & call",
  st1_n="Youssef Mansouri", st1_g="Grade 3 · El Wiam Primary", st1_s="Stop 03 · Seat A2",
  st1_b="BOARDED 07:16", st1_tag="QR Verified",
  st2_n="Amina Mansouri", st2_g="Grade 6 · Ibn Khaldoun Middle", st2_s="Stop 03 · Seat A3",
  st2_b="BOARDED 07:17", st2_tag="QR Verified",
  st3_n="Rayan Benali", st3_g="KG 2 · Al Manar Preschool", st3_s="Stop 03 · Seat B1",
  st3_b="WAITING", st3_tag="Asthma Inhaler",
  call_btn="Call Parent",

  # Screen 1: Grouped By Stops
  by_stops_title="Roster by Stops",
  stop1_h="Stop 03 · Hay El Nasr Gate", stop1_eta="07:16 AM · 3 Students",
  stop2_h="Stop 04 · Blvd des Martyrs 03", stop2_eta="07:22 AM · 4 Students",
  stop3_h="Stop 05 · Hydra North Gate", stop3_eta="07:28 AM · 2 Students · 1 Absent",
  b_all_boarded="All Boarded (3/3)",
  b_pending="Waiting (0/4)",
  b_skip="1 Child Absent",
  ms1_n="Youssef Mansouri", ms2_n="Amina Mansouri", ms3_n="Rayan Benali",
  txt_boarded="Boarded", txt_waiting="Waiting", txt_seat="Seat",
  stop2_sub="4 Students: Karim, Sara, Walid, Ines",
  stop2_note="Stop is on the right side across from pharmacy.",
  stop3_note="Lina Hadj is absent · Stop duration reduced",
  manifest_summary="7 Total Stops · 9 Boarded · 3 Waiting · 2 Absent",

  # Shared Student Dossier Tabs
  dossier_title="Student Transit Dossier",
  tab_transit="Transit", tab_med="Medical", tab_guard="Guardian", tab_notes="Dismissal",
  c_name="Youssef Karim Mansouri",
  c_meta="Grade 3 · El Wiam Primary · Seat A2",
  c_status="ON BUS · BOARDED 07:16",

  # Screen 2: Transit Tab
  sec_transit="Bus & Daily Schedule",
  fld_bus="Bus Assignment", val_bus="Bus 04 · Seat A2 (Left Window)",
  fld_am_stop="Morning Pickup Stop", val_am_stop="Stop 03: Hay El Nasr Gate (07:16 AM)",
  fld_pm_stop="Afternoon Drop-off", val_pm_stop="Stop 03: Hay El Nasr Gate (03:40 PM)",
  fld_qr_id="Student Digital Code", val_qr_id="#HB-2026-9911 · QR Verified",
  btn_mark="Mark Boarded / Dropped Off",

  # Screen 3: Medical Tab
  sec_med="Critical Health & First Aid",
  med_alert_badge="CRITICAL HEALTH ALERT",
  med_alert_box="Blood Type: O+ · Mild Peanut Allergy · Asthma Inhaler in Backpack",
  fld_plan="First Aid Action Plan",
  val_plan="If breathing difficulty occurs: Ventolin inhaler is in front backpack pocket. Administer 2 puffs. Pull over safely and notify school coordinator.",
  fld_doc="Pediatrician Contact", val_doc="Dr. Leila Saidi (+213 550 99 88 77)",
  fld_amb="Emergency Ambulance", val_amb="Protection Civile: 14",
  btn_call_doc="Call Pediatrician Immediately",

  # Screen 4: Guardian & Dismissal Tab
  sec_guard="Authorized Pickup Guardians",
  g1_t="Karim Mansouri (Father)", g1_s="Primary Guardian · +213 550 12 34 56",
  g2_t="Sarah Mansouri (Mother)", g2_s="Co-Guardian · +213 550 78 90 12",
  sec_rule="Strict Handover Protocol",
  rule_box="STRICT DISMISSAL RULE: Must be met at the bus door by parent or authorized adult with matching digital QR pass. Never allow child to cross Blvd des Martyrs alone.",
  btn_call_guard="Call Primary Guardian (Karim)",

  # Screen 5: Absences & Exceptions List
  abs_title="Today's Reported Absences",
  abs_sub="Parents reported absence via app · Stops updated automatically",
  abs_stat="2 Students Absent Today · 1 Stop Bypassed (Save ~8m)",
  badge_reported="REPORTED",
  a1_n="Lina Hadj", a1_g="Grade 2 · Bus 04", a1_stop="Stop 01: Hydra North Gate", a1_r="Medical appointment (Flu)",
  a1_act="Stop bypassed for morning run",
  a2_n="Sami Khelil", a2_g="Grade 5 · Bus 04", a2_stop="Stop 05: El Biar Park", a2_r="Family travel notice",
  a2_act="Schedule resumes tomorrow",
  btn_manual_abs="Report Unannounced No-Show",
 ),
 "ar": dict(
  # Navigation & Shared Header
  page_title="قائمة ركاب الحافلة",
  page_sub="حافلة 04 · 14 طالباً مسجلين",
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="حسابي",
  search_ph="ابحث بالاسم، المحطة، أو المقعد...",

  # Screen 0: Students Roster & Filter
  f_all="الكل (14)", f_board="في الحافلة (9)", f_wait="بانتظار (3)", f_abs="غياب (2)",
  swipe_hint="💡 اسحب بطاقة الطالب لليمين (➔) لتأكيد الصعود · انقر للتفاصيل",
  st1_n="يوسف منصوري", st1_g="السنة الثالثة · مدرسة الوئام", st1_s="المحطة 03 · مقعد A2",
  st1_b="صعد 07:16", st1_tag="تم مسح QR",
  st2_n="أمينة منصوري", st2_g="السنة السادسة · متوسطة ابن خلدون", st2_s="المحطة 03 · مقعد A3",
  st2_b="صعدت 07:17", st2_tag="تم مسح QR",
  st3_n="ريان بن علي", st3_g="التحضيري 2 · روضة المنار", st3_s="المحطة 03 · مقعد B1",
  st3_b="بانتظار الصعود", st3_tag="تنبيه ربو",
  call_btn="اتصال بولي الأمر",

  # Screen 1: Grouped By Stops
  by_stops_title="قائمة الطلاب حسب المحطات",
  stop1_h="المحطة 03 · بوابة حي النصر", stop1_eta="07:16 ص · 3 طلاب",
  stop2_h="المحطة 04 · شارع الشهداء 03", stop2_eta="07:22 ص · 4 طلاب",
  stop3_h="المحطة 05 · بوابة حيدرة الشمالية", stop3_eta="07:28 ص · 2 طلاب · 1 غياب",
  b_all_boarded="صعد الجميع (3/3)",
  b_pending="بانتظار (0/4)",
  b_skip="طالب غائب معتذر",
  ms1_n="يوسف منصوري", ms2_n="أمينة منصوري", ms3_n="ريان بن علي",
  txt_boarded="صعد", txt_waiting="بانتظار", txt_seat="مقعد",
  stop2_sub="4 طلاب: كريم، سارة، وليد، إيناس",
  stop2_note="المحطة على اليمين أمام الصيدلية مباشرة.",
  stop3_note="لينا حاج غائبة · تم تقليص وقت التوقف",
  manifest_summary="7 محطات إجمالية · 9 صعدوا · 3 بانتظار · 2 غياب",

  # Shared Student Dossier Tabs
  dossier_title="ملف النقل والسلامة للطالب",
  tab_transit="مسار النقل", tab_med="الملف الطبي", tab_guard="ولي الأمر", tab_notes="الانصراف",
  c_name="يوسف كريم منصوري",
  c_meta="السنة الثالثة · ابتدائية الوئام · مقعد A2",
  c_status="في الحافلة · صعد 07:16",

  # Screen 2: Transit Tab
  sec_transit="بيانات الحافلة ومواعيد المحطات",
  fld_bus="الحافلة والمقعد المسند", val_bus="الحافلة 04 · مقعد A2 (نافذة يسار)",
  fld_am_stop="محطة الصعود الصباحية", val_am_stop="المحطة 03: بوابة حي النصر (07:16 ص)",
  fld_pm_stop="محطة النزول المسائية", val_pm_stop="المحطة 03: بوابة حي النصر (03:40 م)",
  fld_qr_id="الرمز الرقمي للطالب", val_qr_id="#HB-2026-9911 · بطاقة موثقة",
  btn_mark="تأكيد الصعود / النزول",

  # Screen 3: Medical Tab
  sec_med="الملف الصحي الحرج والإسعافات",
  med_alert_badge="تنبيه صحي حرج",
  med_alert_box="فصيلة الدم: +O · حساسية خفيفة من الفول السوداني · بخاخ ربو في الحقيبة",
  fld_plan="خطة الإسعاف الأولي الطارئة",
  val_plan="عند حدوث صعوبة بالتنفس: بخاخ الفنتولين بالجيب الأمامي للحقيبة. إعطاء بخّتين، التوقف بأمان، وإشعار مشرف المدرسة فوراً.",
  fld_doc="طبيب الأطفال المعتمد", val_doc="د. ليلى سعيدي (0550998877)",
  fld_amb="الإسعاف والحماية المدنية", val_amb="الحماية المدنية: 14",
  btn_call_doc="الاتصال بطبيب الأطفال فوراً",

  # Screen 4: Guardian & Dismissal Tab
  sec_guard="الأشخاص المخولون بالاستلام",
  g1_t="كريم منصوري (الأب)", g1_s="ولي الأمر الأساسي · 0550123456",
  g2_t="سارة منصوري (الأم)", g2_s="ولي أمر مشارك · 0550789012",
  sec_rule="بروتوكول تسليم الطالب الصارم",
  rule_box="شرط تسليم صارم: يجب استقبال الطفل عند باب الحافلة من قبل ولي الأمر أو شخص مخول ببطاقة QR مطابقة. يمنع منعاً باتاً السماح للطفل بعبور شارع الشهداء بمفرده.",
  btn_call_guard="الاتصال بولي الأمر (كريم منصوري)",

  # Screen 5: Absences & Exceptions List
  abs_title="غيابات اليوم المعتذرة",
  abs_sub="سجل الأولياء الغياب عبر التطبيق مسبقاً · تم تعديل جدول المحطات تلقائياً",
  abs_stat="طالبان معتذران اليوم · تم تجاوز محطة (ربح ~8 د)",
  badge_reported="معتذر مسبقاً",
  a1_n="لينا حاج", a1_g="السنة الثانية · حافلة 04", a1_stop="المحطة 01: بوابة حيدرة", a1_r="موعد طبي (نزلة برد)",
  a1_act="تم تجاوز المحطة في رحلة الصباح",
  a2_n="سامي خليل", a2_g="السنة الخامسة · حافلة 04", a2_stop="المحطة 05: حديقة الأبيار", a2_r="إشعار سفر عائلي",
  a2_act="تستأنف الرحلة غداً صباحاً",
  btn_manual_abs="تسجيل تخلف عن الحضور يدوياً",
 ),
}


def driver_bottom_nav(sc: Screen, active: int = 1):
    """Draw the floating capsule 4-item navbar with Students active (index 1)."""
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


def dossier_hero(sc: Screen, active_tab: int):
    """Draw the shared child hero card + 4 tab pills for dossier screens."""
    s = sc.s
    # Student profile hero card
    sc.rect(18, 110, 357, 98, SURF, 22, "Student dossier hero", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
    # Avatar
    sc.rect(32, 124, 60, 60, ACCENT, 30, "Student avatar", stroke=PRIMARY)
    sc.icon("user", 46, 138, 30, INK)

    sc.text(s["c_name"], 104, 122, 17, INK, 800, name="Student name")
    sc.text(s["c_meta"], 104, 146, 12, MUTED, 500, name="Student meta")

    # Live status tag inside hero
    sc.rect(104, 168, 160, 24, "#E8F8F0", 12, "Live status pill", stroke="#A3E6C1")
    sc.icon("check-circle", 112, 172, 14, "#1B8A4D")
    sc.text(s["c_status"], 130, 173, 11, "#1B8A4D", 700, name="Live status text")

    # 4-Tab Switcher Strip (y=218, each w=85, gap 6)
    tabs = [s["tab_transit"], s["tab_med"], s["tab_guard"], s["tab_notes"]]
    for idx, tlabel in enumerate(tabs):
        tx = 18 + idx * 90
        is_act = idx == active_tab
        sc.rect(tx, 218, 86, 32, PRIMARY if is_act else SURF, 12, f"Tab {tlabel}", stroke=PRIMARY if is_act else BORDER)
        sc.text(tlabel, tx, 226, 11, ONP if is_act else INK, 700 if is_act else 600, w=86, align="center")


def students_roster_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Students Roster & Filter", 0, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["page_title"], end_icon="qr-code")

    # Search bar (y=114)
    sc.rect(18, 114, 305, 46, SURF, 14, "Search box", stroke=BORDER)
    sc.icon("magnifying-glass", 32, 128, 18, MUTED)
    sc.text(s["search_ph"], 58, 128, 13, MUTED, 400, name="Search placeholder")
    sc.rect(331, 114, 44, 46, PRIMARY, 14, "Filter button")
    sc.icon("funnel-simple", 344, 128, 18, ONP)

    # Filter chips (y=168)
    chips = [
        (18, 76, s["f_all"], True),
        (100, 94, s["f_board"], False),
        (200, 86, s["f_wait"], False),
        (292, 83, s["f_abs"], False),
    ]
    for cx, cw, clbl, act in chips:
        sc.rect(cx, 168, cw, 32, PRIMARY if act else SURF, 16, f"Chip {clbl}", stroke=PRIMARY if act else BORDER)
        sc.text(clbl, cx, 176, 11, ONP if act else INK, 700 if act else 600, w=cw, align="center")

    # Swipe UX Hint Banner (y=208)
    sc.rect(18, 208, 357, 28, "#FFF8E7", 14, "Swipe hint", stroke=BORDER)
    sc.text(s["swipe_hint"], 0, 214, 11, "#946A00", 600, align="center", name="Swipe hint text")

    # 3 Rich Student Cards (y=244, 410, 576; each h=154)
    cards = [
        (244, s["st1_n"], s["st1_g"], s["st1_s"], s["st1_b"], s["st1_tag"], "#E8F8F0", "#1B8A4D", False),
        (410, s["st2_n"], s["st2_g"], s["st2_s"], s["st2_b"], s["st2_tag"], "#E8F8F0", "#1B8A4D", False),
        (576, s["st3_n"], s["st3_g"], s["st3_s"], s["st3_b"], s["st3_tag"], "#FFF3E0", "#E67E22", True),
    ]
    for cy, cn, cg, cs, cb, ctag, bg_badge, fg_badge, show_call in cards:
        sc.rect(18, cy, 357, 154, SURF, 22, f"Student card {cn}", stroke=BORDER,
                effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
        # Avatar
        sc.rect(32, cy + 16, 48, 48, ACCENT, 24, "Student avatar")
        sc.icon("user", 44, cy + 28, 24, INK)

        sc.text(cn, 90, cy + 16, 16, INK, 700, w=170, name=f"Name {cn}")
        sc.text(cg, 90, cy + 39, 12, MUTED, 500, w=170, name=f"Grade {cn}")

        # Status badge
        sc.rect(252, cy + 16, 109, 28, bg_badge, 14, "Status badge", stroke=fg_badge + "40")
        sc.text(cb, 252, cy + 22, 10, fg_badge, 700, w=109, align="center")

        # Divider
        sc.rect(32, cy + 74, 329, 1, BORDER, 0, "Card divider")

        # Stop & Seat
        sc.icon("map-pin", 32, cy + 86, 16, INK)
        sc.text(cs, 54, cy + 86, 12, INK, 600, w=190, name=f"Stop {cn}")

        # Medical / Tag pill
        tag_is_alert = "Asthma" in ctag or "ربو" in ctag
        sc.rect(252, cy + 82, 109, 24, DSURF if tag_is_alert else ACCENT, 12, "Tag pill")
        sc.text(ctag, 252, cy + 86, 10, DESTR if tag_is_alert else INK, 700, w=109, align="center")

        if show_call:
            # One-tap call parent bar inside card
            sc.rect(32, cy + 114, 329, 30, PRIMARY + "22", 15, "Call parent bar", stroke=PRIMARY)
            sc.icon("phone", 42, cy + 120, 16, PRIMARY)
            sc.text(s["call_btn"] + " (0550123456)", 68, cy + 121, 11, INK, 700)

    driver_bottom_nav(sc, active=1)
    return sc.F


def manifest_by_stops_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Manifest By Stops", 1, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["by_stops_title"], end_icon="funnel-simple")

    # Stop 03 Section Card (Active Stop)
    sc.rect(18, 116, 357, 184, SURF, 22, "Stop 03 section", stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": PRIMARY + "20"}])
    # Header bar of Stop 03
    sc.rect(18, 116, 357, 44, INK, 22, "Stop 03 header", mirror=False)
    sc.icon("map-pin", 30, 128, 20, PRIMARY)
    sc.text(s["stop1_h"], 58, 122, 14, SURF, 700, w=190)
    sc.text(s["stop1_eta"], 58, 140, 11, SURF + "99", 500, w=190)
    sc.rect(262, 124, 101, 26, "#E8F8F0", 13, "Badge stop 1")
    sc.text(s["b_all_boarded"], 262, 130, 10, "#1B8A4D", 700, w=101, align="center")

    # Mini student rows inside Stop 03
    mini_students = [
        (s["ms1_n"], "A2", True, 172),
        (s["ms2_n"], "A3", True, 212),
        (s["ms3_n"], "B1", False, 252),
    ]
    for sname, sseat, sboard, my in mini_students:
        sc.icon("user", 34, my + 4, 16, INK)
        sc.text(f"{sname} · {s['txt_seat']} {sseat}", 58, my + 4, 12, INK, 600, w=190)
        sc.rect(270, my + 2, 93, 22, "#E8F8F0" if sboard else "#FFF3E0", 11, "Mini badge")
        sc.text(s["txt_boarded"] if sboard else s["txt_waiting"], 270, my + 6, 10, "#1B8A4D" if sboard else "#E67E22", 700, w=93, align="center")

    # Stop 04 Section Card (Next Stop)
    sc.rect(18, 312, 357, 148, SURF, 22, "Stop 04 section", stroke=BORDER)
    sc.rect(18, 312, 357, 44, "#F8F5EC", 22, "Stop 04 header", mirror=False)
    sc.icon("map-pin", 30, 324, 20, INK)
    sc.text(s["stop2_h"], 58, 318, 13, INK, 700, w=200)
    sc.text(s["stop2_eta"], 58, 336, 11, MUTED, 500, w=200)
    sc.rect(262, 320, 101, 26, BORDER, 13, "Badge stop 2")
    sc.text(s["b_pending"], 262, 326, 10, INK, 700, w=101, align="center")

    sc.icon("users", 34, 372, 16, MUTED)
    sc.text(s["stop2_sub"], 58, 372, 12, MUTED, 500, w=290)
    sc.rect(34, 404, 325, 42, SURF, 12, "Stop note box", stroke=BORDER)
    sc.icon("info", 44, 416, 16, PRIMARY)
    sc.text(s["stop2_note"], 68, 417, 11, INK, 500, w=270)

    # Stop 05 Section Card (With 1 Absent Child)
    sc.rect(18, 472, 357, 128, SURF, 22, "Stop 05 section", stroke=BORDER)
    sc.rect(18, 472, 357, 44, "#F8F5EC", 22, "Stop 05 header", mirror=False)
    sc.icon("map-pin", 30, 484, 20, INK)
    sc.text(s["stop3_h"], 58, 478, 13, INK, 700, w=200)
    sc.text(s["stop3_eta"], 58, 496, 11, MUTED, 500, w=200)
    sc.rect(262, 480, 101, 26, DSURF, 13, "Badge stop 3")
    sc.text(s["b_skip"], 262, 486, 10, DESTR, 700, w=101, align="center")

    sc.icon("warning-circle", 34, 532, 16, DESTR)
    sc.text(s["stop3_note"], 58, 532, 12, DESTR, 600, w=290)

    # Summary bar at bottom
    sc.rect(18, 616, 357, 44, PRIMARY + "20", 16, "Manifest stat", stroke=PRIMARY)
    sc.icon("bus", 32, 628, 18, PRIMARY)
    sc.text(s["manifest_summary"], 60, 629, 12, INK, 700)

    driver_bottom_nav(sc, active=1)
    return sc.F


def dossier_transit_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Student Dossier - Transit", 2, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["dossier_title"])
    dossier_hero(sc, active_tab=0)

    # Transit Details Card (y=262, h=356)
    sc.rect(18, 262, 357, 356, SURF, 22, "Transit card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])

    fields = [
        (s["fld_bus"], s["val_bus"], "bus", 278),
        (s["fld_am_stop"], s["val_am_stop"], "sun", 354),
        (s["fld_pm_stop"], s["val_pm_stop"], "moon", 430),
        (s["fld_qr_id"], s["val_qr_id"], "qr-code", 506),
    ]
    for lbl, val, ic, fy in fields:
        sc.icon(ic, 32, fy + 4, 18, PRIMARY)
        sc.text(lbl, 58, fy, 12, MUTED, 600, w=290, name=f"Label {lbl}")
        sc.text(val, 58, fy + 20, 14, INK, 700, w=290, name=f"Val {lbl}")
        if fy < 506:
            sc.rect(32, fy + 58, 329, 1, BORDER, 0, "Divider")

    # Primary Action Button: Mark Boarded
    sc.rect(18, 634, 357, 54, PRIMARY, 18, "Mark boarded button",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 10, "color": PRIMARY + "40"}])
    sc.icon("check-circle", 32, 649, 22, ONP)
    sc.text(s["btn_mark"], 0, 650, 15, ONP, 700, align="center")

    driver_bottom_nav(sc, active=1)
    return sc.F


def dossier_medical_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Student Dossier - Medical", 3, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["dossier_title"])
    dossier_hero(sc, active_tab=1)

    # Red/Amber Critical Medical Banner (y=262)
    sc.rect(18, 262, 357, 68, DSURF, 18, "Medical alert banner", stroke=DBORD)
    sc.icon("first-aid", 32, 276, 24, DESTR)
    sc.text(s["med_alert_badge"], 64, 274, 11, DESTR, 800, w=290)
    sc.text(s["med_alert_box"], 64, 292, 12, INK, 700, w=290)

    # First Aid Action Plan Card (y=342, h=160)
    sc.rect(18, 342, 357, 160, SURF, 22, "Action plan card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
    sc.icon("heartbeat", 32, 356, 20, PRIMARY)
    sc.text(s["fld_plan"], 60, 356, 14, INK, 800, w=290)
    sc.rect(32, 384, 329, 1, BORDER, 0, "Plan divider")
    sc.text(s["val_plan"], 32, 396, 12, INK, 500, w=329)

    # Emergency Medical Contacts Card (y=514, h=108)
    sc.rect(18, 514, 357, 108, SURF, 22, "Doctors card", stroke=BORDER)
    sc.icon("phone", 32, 528, 18, PRIMARY)
    sc.text(s["fld_doc"], 60, 526, 12, MUTED, 600, w=290)
    sc.text(s["val_doc"], 60, 544, 14, INK, 700, w=290)

    sc.rect(32, 572, 329, 1, BORDER, 0, "Doctor divider")

    sc.icon("shield-check", 32, 584, 18, DESTR)
    sc.text(s["fld_amb"], 60, 582, 13, DESTR, 700, w=290)

    # Call Doctor Button (y=634)
    sc.rect(18, 634, 357, 54, DESTR, 18, "Call doctor btn")
    sc.icon("phone-call", 32, 649, 22, SURF)
    sc.text(s["btn_call_doc"], 0, 650, 15, SURF, 700, align="center")

    driver_bottom_nav(sc, active=1)
    return sc.F


def dossier_guardian_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Student Dossier - Guardian", 4, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["dossier_title"])
    dossier_hero(sc, active_tab=2)

    # Guardians List Section (y=262)
    sc.section_label(s["sec_guard"], 262)

    guardians = [
        (s["g1_t"], s["g1_s"], True, 288),
        (s["g2_t"], s["g2_s"], False, 362),
    ]
    for gt, gs, is_pri, gy in guardians:
        sc.rect(18, gy, 357, 62, SURF, 18, f"Guard card {gt}", stroke=PRIMARY if is_pri else BORDER)
        sc.rect(28, gy + 11, 40, 40, ACCENT, 20, "Guard avatar")
        sc.icon("user", 38, gy + 21, 20, INK)
        sc.text(gt, 78, gy + 12, 14, INK, 700, w=210)
        sc.text(gs, 78, gy + 32, 11, MUTED, 500, w=210)
        # Call icon button
        sc.rect(323, gy + 13, 36, 36, PRIMARY + "20", 18, "Call pill")
        sc.icon("phone", 332, gy + 22, 18, PRIMARY)

    # Strict Dismissal Protocol Box (y=440, h=170)
    sc.rect(18, 440, 357, 170, "#FFFDF2", 22, "Dismissal box", stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": PRIMARY + "20"}])
    # Ribbon
    sc.rect(34, 456, 325, 28, "#FFF8E7", 12, "Rule ribbon", stroke=BORDER)
    sc.icon("warning-circle", 44, 462, 16, "#946A00")
    sc.text(s["sec_rule"], 68, 463, 11, "#946A00", 800, w=270)

    sc.text(s["rule_box"], 34, 498, 12, INK, 600, w=325)

    # Big Call Father Button (y=626)
    sc.rect(18, 626, 357, 54, PRIMARY, 18, "Call father btn")
    sc.icon("phone", 32, 641, 22, ONP)
    sc.text(s["btn_call_guard"], 0, 642, 15, ONP, 700, align="center")

    driver_bottom_nav(sc, active=1)
    return sc.F


def absences_list_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Today's Absences & Notes", 5, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["abs_title"])

    # Subtitle note
    sc.sub(s["abs_sub"], 112, w=340)

    # Summary Stat Pill (y=168)
    sc.rect(18, 168, 357, 36, "#FFF8E7", 18, "Stat pill", stroke=BORDER)
    sc.icon("warning-circle", 28, 177, 18, "#D4A017")
    sc.text(s["abs_stat"], 56, 179, 10.5, INK, 700, w=300)

    # 2 Detailed Absence Cards (y=216, 380; each h=152)
    absences = [
        (216, s["a1_n"], s["a1_g"], s["a1_stop"], s["a1_r"], s["a1_act"], True),
        (380, s["a2_n"], s["a2_g"], s["a2_stop"], s["a2_r"], s["a2_act"], False),
    ]
    for ay, an, ag, astop, ar, aact, is_bypass in absences:
        sc.rect(18, ay, 357, 152, SURF, 22, f"Absence card {an}", stroke=BORDER,
                effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
        # Avatar
        sc.rect(32, ay + 16, 48, 48, "#FEE8E6", 24, "Absent avatar")
        sc.icon("user", 44, ay + 28, 24, DESTR)

        sc.text(an, 90, ay + 16, 16, INK, 800, w=180)
        sc.text(ag, 90, ay + 39, 12, MUTED, 500, w=180)

        # Absent badge
        sc.rect(262, ay + 16, 99, 28, DSURF, 14, "Absent badge", stroke=DBORD)
        sc.text(s["badge_reported"], 262, ay + 22, 10, DESTR, 800, w=99, align="center")

        # Divider
        sc.rect(32, ay + 74, 329, 1, BORDER, 0, "Card divider")

        # Stop & Reason
        sc.icon("map-pin", 32, ay + 86, 16, INK)
        sc.text(astop + " · " + ar, 54, ay + 86, 11, INK, 600, w=300)

        # Action taken pill
        sc.rect(32, ay + 112, 329, 28, "#E8F8F0" if is_bypass else "#F8F5EC", 14, "Action pill", stroke=BORDER)
        sc.icon("check-circle" if is_bypass else "clock", 42, ay + 118, 16, "#1B8A4D" if is_bypass else MUTED)
        sc.text(aact, 66, ay + 119, 11, "#1B8A4D" if is_bypass else INK, 700, w=280)

    # Report Manual No-show Button (y=548)
    sc.rect(18, 548, 357, 56, SURF, 18, "Report no-show btn", stroke=PRIMARY)
    sc.icon("plus", 32, 565, 22, PRIMARY)
    sc.text(s["btn_manual_abs"], 0, 566, 14, PRIMARY, 700, align="center")

    driver_bottom_nav(sc, active=1)
    return sc.F

    driver_bottom_nav(sc, active=1)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            students_roster_screen(lang),
            manifest_by_stops_screen(lang),
            dossier_transit_screen(lang),
            dossier_medical_screen(lang),
            dossier_guardian_screen(lang),
            absences_list_screen(lang),
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
    out_png = os.path.join(shots_dir, "driver-03-children-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    # Save to dedicated driver document files
    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-children.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        assert res.get("ok"), res
        print("saved:", fpath, f"({res['result']['bytes']} bytes)")


if __name__ == "__main__":
    main()
