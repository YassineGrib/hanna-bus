"""Build Page '05 · Profile & Vehicle' (5 screens x 2 languages = 10 frames).

Screens:
  0. Driver Profile Hub (Driver hero card, rating badge, commercial license, assigned bus capsule)
  1. Vehicle Digital Passport (Technical specs, maintenance health, fuel range, safety equipment audit)
  2. Pre-Trip Daily Inspection (Legal vehicle walkaround checklist, 24-seat safety audit, fluids check)
  3. Safety Telemetry & Performance (Eco-score 98/100, zero harsh braking, 48 parent commendations)
  4. Dispatch & Emergency Contacts (Direct line to fleet coordinator, school supervisor, heavy tow service)
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

PAGE_NAME = "05 · Profile & Vehicle"
GROUP = "Driver Profile"
SCREENS = [
    "Driver Profile Hub",
    "Vehicle Digital Passport",
    "Pre-Trip Daily Inspection",
    "Safety Telemetry",
    "Dispatch Contacts",
]
SECTIONS = {
    "en": "EN · Profile & Vehicle (LTR)",
    "ar": "AR · ملف السائق والحافلة (RTL)",
}

STR = {
 "en": dict(
  # Navigation & Shared Header
  page_title="Driver & Fleet Dossier",
  page_sub="Ahmed Benali · Senior Transit Operator",
  nav_home="Home", nav_roster="Students", nav_nav="Navigation", nav_prof="Profile",

  # Screen 0: Driver Profile Hub
  d_name="Ahmed Benali",
  d_role="Senior School Bus Operator · Fleet 04",
  d_rating="4.95 ★ (520 Trips)",
  d_lic_tag="Class D Commercial · Active",
  d_phone="+213 550 12 34 56",
  d_mail="a.benali@hannabus.dz",
  d_sec_bus="Assigned Fleet Vehicle",
  v_bus_name="Bus 04 · Mercedes Sprinter 519 CDI",
  v_bus_plate="00142-120-16 · 24 Passenger Seats",
  v_bus_stat="48,250 km · Inspected & Certified",
  d_sec_certs="Professional Certifications",
  c1_t="Commercial Driver License (Class D)", c1_s="Valid until Oct 2028 · Verified",
  c2_t="School Transport Medical Clearance", c2_s="Annual vision & physical passed (Sep 2026)",
  c3_t="First Aid & CPR Certified (Red Crescent)", c3_s="Certificate #DZ-FA-2025-88",
  btn_edit_prof="Edit Contact Information",

  # Screen 1: Vehicle Digital Passport
  v_title="Vehicle Digital Passport",
  v_sub="Bus 04 · Mercedes-Benz Sprinter 519 CDI",
  v_sec_health="Vital Diagnostic Systems",
  h1_lbl="Engine Health", h1_val="98% Optimal",
  h2_lbl="Brake Pads", h2_val="8.2 mm (Safe)",
  h3_lbl="Tire Tread", h3_val="6.5 mm (Optimal)",
  h4_lbl="Diesel Tank", h4_val="78% (~420 km)",
  v_sec_maint="Technical Inspection & Schedule",
  m1_t="Mandatory Periodic Technical Control", m1_s="Next due: 15 Dec 2026 (Green pass)",
  m2_t="Last Preventative Service (Oil & Filters)", m2_s="Completed at 45,000 km (Authorized dealer)",
  v_sec_safety="Mandatory On-Board Safety Equipment",
  eq1="2x Dry Powder Fire Extinguishers (Inspected Sep 2026)",
  eq2="School First Aid Trauma Kit (Fully replenished)",
  eq3="4x Emergency Window Hammers & 2 Reflective Triangles",
  btn_log_maint="Report Maintenance Request",

  # Screen 2: Pre-Trip Daily Inspection
  insp_title="Daily Pre-Trip Inspection",
  insp_sub="Algerian School Transport Safety Code · Complete before morning departure",
  insp_stat="All 12 Safety Checkpoints Passed",
  i_sec1="Exterior Walkaround",
  i1_t="Headlights, taillights & hazard flashers", i1_s="Tested & fully functional",
  i2_t="Tire pressures (Cold 4.2 bar) & wheel nuts", i2_s="Visual inspection complete",
  i_sec2="Interior & Passenger Cabin",
  i3_t="Seatbelts on all 24 passenger seats", i3_s="All latches clicking securely",
  i4_t="Rear emergency exit door & buzzer alarm", i4_s="Tested release mechanism",
  i_sec3="Engine Compartment & Fluids",
  i5_t="Engine oil, coolant & washer reservoir", i5_s="All levels within safe marks",
  btn_quick_pass="Quick Sign-Off (All 12 Passed)",
  btn_report_defect="Report Issue / Defect",

  # Screen 3: Safety Telemetry & Performance
  tel_title="Driver Safety & Eco Score",
  tel_sub="Official telematics score based on 520 school journeys",
  tel_score="98",
  tel_score_lbl="/ 100 Safety Score",
  tel_grade="EXCELLENT SAFETY",
  tel_zero_acc="Zero Accidents Record",
  tel_rank="Top 5% in Algiers School Fleet",
  tel_sec_kpi="Key Telematics Metrics (Last 30 Days)",
  k1_t="Harsh Braking Incidents", k1_v="0 events",
  k2_t="Speed Limit Compliance", k2_v="99.4%",
  k3_t="On-Time Departure Rate", k3_v="98.2%",
  k4_t="Smooth Cornering & Accel", k4_v="97.8%",
  tel_sec_comm="Parent Commendations",
  comm_box="48 Positive reviews: 'Always gentle over speed bumps', 'Punctual every morning', 'Takes extra care at crosswalks'.",
  btn_export_telemetry="Export Driver Telemetry Dossier",

  # Screen 4: Dispatch & Emergency Contacts
  disp_title="Dispatch & Operations Support",
  disp_sub="Direct communication lines for route coordination and mechanical support",
  disp_sec1="Transit Operations & School Dispatch",
  d1_t="Tariq Mansouri (Fleet Coordinator)", d1_s="Central Fleet Operations · 0550 88 99 00",
  d2_t="Mme. Amrani (School Dismissal Supervisor)", d2_s="El Wiam Campus · 0550 77 66 55",
  disp_sec2="Emergency & Heavy Recovery Services",
  d3_t="Fleet Roadside Assistance & Heavy Tow", d3_s="Algiers Zone 24/7 · 0550 11 22 33",
  d4_t="Protection Civile (Ambulance / Fire)", d4_s="Emergency Dial: 14",
  d5_t="Police Secours (Traffic / Accidents)", d5_s="Emergency Dial: 17",
  btn_sos_dispatch="1-Tap Emergency Alert to Dispatch",
 ),
 "ar": dict(
  # Navigation & Shared Header
  page_title="ملف السائق وبيانات الحافلة",
  page_sub="أحمد بن علي · سائق أول نقل مدرسي معتمد",
  nav_home="الرئيسية", nav_roster="الطلاب", nav_nav="الملاحة", nav_prof="حسابي",

  # Screen 0: Driver Profile Hub
  d_name="أحمد بن علي",
  d_role="سائق أول نقل مدرسي · الحافلة 04",
  d_rating="4.95 ★ (520 رحلة آمنة)",
  d_lic_tag="رخصة صنف د تجارية · سارية",
  d_phone="+213 550 12 34 56",
  d_mail="a.benali@hannabus.dz",
  d_sec_bus="الحافلة المسندة للسائق",
  v_bus_name="الحافلة 04 · مرسيدس سبرينتر 519 CDI",
  v_bus_plate="00142-120-16 · سعة 24 مقعداً",
  v_bus_stat="48,250 كم · مفحوصة ومعتمدة",
  d_sec_certs="الشهادات والرخص المهنية",
  c1_t="رخصة سياقة عمومية (صنف د)", c1_s="صالحة حتى أكتوبر 2028 · موثقة رسمياً",
  c2_t="شهادة الكفاءة الطبية للنقل المدرسي", c2_s="فحص دوري سنوي ناجح (سبتمبر 2026)",
  c3_t="شهادة الإسعافات الأولية (الهلال الأحمر)", c3_s="رقم الشهادة #DZ-FA-2025-88",
  btn_edit_prof="تعديل معلومات الاتصال",

  # Screen 1: Vehicle Digital Passport
  v_title="جواز السفر الرقمي للحافلة",
  v_sub="الحافلة 04 · مرسيدس بنز سبرينتر 519 CDI",
  v_sec_health="المؤشرات التشخيصية الحيوية",
  h1_lbl="حالة المحرك", h1_val="98% مثالية",
  h2_lbl="سماكة الفرامل", h2_val="8.2 ملم (آمنة)",
  h3_lbl="عمق مداس الإطارات", h3_val="6.5 ملم (ممتاز)",
  h4_lbl="مستوى الديزل", h4_val="78% (~420 كم)",
  v_sec_maint="الفحص التقني والصيانة الدورية",
  m1_t="المراقبة التقنية الدورية الإلزامية", m1_s="الموعد القادم: 15 ديسمبر 2026 (مؤهل)",
  m2_t="آخر صيانة وقائية (زيوت وفلاتر)", m2_s="أنجزت عند 45,000 كم (الوكيل المعتمد)",
  v_sec_safety="تجهيزات السلامة الإلزامية على المتن",
  eq1="مطفأتا حريق بودرة جافة (فحص سبتمبر 2026)",
  eq2="حقيبة إسعافات أولية متكاملة خاصة بالمدارس",
  eq3="4 مطارق طوارئ للزجاج + مثلثا تحذير عاكسان",
  btn_log_maint="طلب صيانة أو مراجعة فنية",

  # Screen 2: Pre-Trip Daily Inspection
  insp_title="الفحص اليومي قبل انطلاق الرحلة",
  insp_sub="بروتوكول السلامة الجزائري للنقل المدرسي · يُجرى إلزامياً قبل رحلة الصباح",
  insp_stat="تم فحص وتأكيد كافة النقاط الـ 12 بنجاح",
  i_sec1="الفحص الخارجي ومحيط الحافلة",
  i1_t="الأضواء الرئيسية، الخلفية والتحذير الرباعي", i1_s="تم الاختبار وتعمل بكفاءة تامة",
  i2_t="ضغط الإطارات (4.2 بار) ومسامير العجلات", i2_s="تم الفحص البصري والسلامة مؤكدة",
  i_sec2="مقصورة الركاب وسلامة المقاعد",
  i3_t="أحزمة الأمان لكافة المقاعد الـ 24", i3_s="جميع الأقفال سليمة وتغلق بإحكام",
  i4_t="باب الطوارئ الخلفي وجرس الإنذار", i4_s="تم اختبار آلية الفتح السريع والإنذار",
  i_sec3="حجرة المحرك ومستويات السوائل",
  i5_t="زيت المحرك، سائل التبريد ومياه المساحات", i5_s="جميع السوائل ضمن الحدود الآمنة",
  btn_quick_pass="تأكيد سلامة النقاط الـ 12 بنقرة واحدة",
  btn_report_defect="الإبلاغ عن خلل أو ملاحظة",

  # Screen 3: Safety Telemetry & Performance
  tel_title="مؤشر القيادة الآمنة والاقتصادية",
  tel_sub="التقييم الرقمي المعتمد وفق بيانات تتبع 520 رحلة مدرسية",
  tel_score="98",
  tel_score_lbl="/ 100 مؤشر الأمان",
  tel_grade="سجل قيادة استثنائي",
  tel_zero_acc="سجل خالٍ من الحوادث",
  tel_rank="ضمن أفضل 5% في أسطول مدارس الجزائر",
  tel_sec_kpi="مؤشرات التيليماتكس (آخر 30 يوماً)",
  k1_t="حالات الفرملة المفاجئة", k1_v="0 حالات",
  k2_t="الالتزام بحدود السرعة القانونية", k2_v="99.4%",
  k3_t="الانضباط بمواعيد الانطلاق", k3_v="98.2%",
  k4_t="سلاسة المنعطفات والتسارع", k4_v="97.8%",
  tel_sec_comm="إشادات وتقييمات أولياء الأمور",
  comm_box="48 تقييماً إيجابياً: 'قيادة هادئة فوق مطبات السرعة'، 'دقة متناهية بالمواعيد'، 'حرص استثنائي على سلامة الأطفال عند عبور الشارع'.",
  btn_export_telemetry="تصدير تقرير القيادة المعتمد",

  # Screen 4: Dispatch & Emergency Contacts
  disp_title="إدارة العمليات والاتصال الطارئ",
  disp_sub="قنوات الاتصال المباشرة للمتابعة الميدانية والدعم الميكانيكي الفوري",
  disp_sec1="إدارة النقل والمشرفون الميدانيون",
  d1_t="طارق منصوري (منسق الأسطول المركزي)", d1_s="مقر إدارة العمليات · 0550889900",
  d2_t="أ. عمراني (مشرفة استقبال وانصراف المدرسة)", d2_s="مجمع مدارس الوئام · 0550776655",
  disp_sec2="خدمات الطوارئ وسحب الحافلات الثقيلة",
  d3_t="خدمة سحب الشاحنات والحافلات (24/7)", d3_s="منطقة الجزائر الكبرى · 0550112233",
  d4_t="الحماية المدنية (الإسعاف والإطفاء)", d4_s="الرقم الأخضر للطوارئ: 14",
  d5_t="الشرطة وأمن الطرقات", d5_s="الرقم الأخضر لشرطة النجدة: 17",
  btn_sos_dispatch="نداء استغاثة عاجل لإدارة العمليات",
 ),
}


def driver_bottom_nav(sc: Screen, active: int = 3):
    """Draw the floating capsule 4-item navbar with Profile active (index 3)."""
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


def driver_profile_hub_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Driver Profile Hub", 0, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["page_title"], end_icon="gear")

    # Driver Hero Card (y=116, h=136)
    sc.rect(18, 116, 357, 136, SURF, 22, "Driver Hero", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
    # Avatar with camera icon
    sc.rect(32, 132, 60, 60, ACCENT, 30, "Driver avatar")
    sc.icon("user", 47, 147, 30, INK)

    sc.text(s["d_name"], 104, 132, 18, INK, 800, w=170)
    sc.text(s["d_role"], 104, 156, 11.5, MUTED, 500, w=170)

    # Rating Pill
    sc.rect(260, 132, 103, 26, "#FFF8E7", 13, "Rating pill", stroke=PRIMARY + "40")
    sc.text(s["d_rating"], 260, 138, 9.5, "#946A00", 800, w=103, align="center")

    # Contact Info row
    sc.rect(32, 202, 329, 36, "#F8F5EC", 12, "Contact row")
    sc.icon("phone", 42, 212, 16, PRIMARY)
    sc.text(s["d_phone"], 64, 212, 11, INK, 700, w=125, latin=True)
    sc.icon("identification-card", 195, 212, 16, MUTED)
    sc.text(s["d_lic_tag"], 216, 212, 10, INK, 600, w=140)

    # Assigned Vehicle Section (y=268)
    sc.section_label(s["d_sec_bus"], 268)
    # Bus Capsule Card (y=294, h=78)
    sc.rect(18, 294, 357, 78, "#FFFDF2", 18, "Bus card", stroke=PRIMARY,
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "20"}])
    sc.rect(30, 308, 48, 48, INK, 16, "Bus ic box")
    sc.icon("bus", 42, 320, 24, PRIMARY)

    sc.text(s["v_bus_name"], 90, 308, 13.5, INK, 800, w=210)
    sc.text(s["v_bus_plate"], 90, 328, 11, MUTED, 500, w=210)
    sc.text(s["v_bus_stat"], 90, 346, 10.5, "#1B8A4D", 700, w=210)

    sc.rect(323, 317, 36, 36, PRIMARY + "20", 18, "Bus arrow pill")
    sc.icon("caret-right", 335, 327, 16, PRIMARY)

    # Professional Certifications Section (y=388)
    sc.section_label(s["d_sec_certs"], 388)

    certs = [
        (s["c1_t"], s["c1_s"], 414),
        (s["c2_t"], s["c2_s"], 478),
        (s["c3_t"], s["c3_s"], 542),
    ]
    for ct, cs, cy in certs:
        sc.rect(18, cy, 357, 56, SURF, 16, f"Cert {ct}", stroke=BORDER)
        sc.rect(28, cy + 12, 32, 32, "#E8F8F0", 16, "Cert icon box")
        sc.icon("check", 36, cy + 20, 16, "#1B8A4D")
        sc.text(ct, 70, cy + 11, 12.5, INK, 700, w=280)
        sc.text(cs, 70, cy + 31, 10.5, MUTED, 500, w=280)

    # Edit Profile Button (y=614)
    sc.rect(18, 614, 357, 52, SURF, 18, "Edit prof btn", stroke=PRIMARY)
    sc.icon("pencil-simple", 32, 629, 20, PRIMARY)
    sc.text(s["btn_edit_prof"], 0, 630, 14, PRIMARY, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def vehicle_passport_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Vehicle Digital Passport", 1, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["v_title"], end_icon="file-text")

    # Vehicle Hero Banner (y=116, h=72)
    sc.rect(18, 116, 357, 72, INK, 18, "Veh banner", mirror=False)
    sc.rect(30, 128, 48, 48, PRIMARY, 14, "Bus box", mirror=False)
    sc.icon("bus", 42, 140, 24, ONP, mirror=False)
    sc.text(s["v_sub"], 88, 130, 13.5, SURF, 800, w=270)
    sc.text(s["v_bus_plate"], 88, 152, 11, SURF + "99", 500, w=270)

    # Vital Diagnostic 4-Grid (y=202, h=136)
    sc.section_label(s["v_sec_health"], 202)

    diag = [
        (s["h1_lbl"], s["h1_val"], "check-circle", "#1B8A4D", 18, 226),
        (s["h2_lbl"], s["h2_val"], "shield-check", "#1B8A4D", 200, 226),
        (s["h3_lbl"], s["h3_val"], "gear", "#1B8A4D", 18, 290),
        (s["h4_lbl"], s["h4_val"], "clock", PRIMARY, 200, 290),
    ]
    for lbl, val, ic, col, dx, dy in diag:
        sc.rect(dx, dy, 175, 56, SURF, 14, f"Diag {lbl}", stroke=BORDER)
        sc.icon(ic, dx + 12, dy + 18, 20, col)
        sc.text(lbl, dx + 38, dy + 11, 10.5, MUTED, 600, w=130)
        sc.text(val, dx + 38, dy + 29, 12, INK, 800, w=130)

    # Periodic Inspection Section (y=362)
    sc.section_label(s["v_sec_maint"], 362)
    sc.rect(18, 386, 357, 60, "#FFFDF2", 16, "Inspection card", stroke=PRIMARY)
    sc.icon("calendar-blank", 30, 404, 22, PRIMARY)
    sc.text(s["m1_t"], 64, 396, 12.5, INK, 800, w=280)
    sc.text(s["m1_s"], 64, 418, 10.5, "#946A00", 700, w=280)

    # Safety Equipment Checklist (y=462)
    sc.section_label(s["v_sec_safety"], 462)

    eq_items = [
        (s["eq1"], 486),
        (s["eq2"], 530),
        (s["eq3"], 574),
    ]
    for eq_t, ey in eq_items:
        sc.rect(18, ey, 357, 38, SURF, 12, f"Eq {eq_t}", stroke=BORDER)
        sc.icon("check-circle", 28, ey + 11, 16, "#1B8A4D")
        sc.text(eq_t, 52, ey + 11, 10.5, INK, 600, w=310)

    # Report Maintenance Button (y=626)
    sc.rect(18, 626, 357, 50, PRIMARY, 16, "Report maint btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 10, "color": PRIMARY + "40"}])
    sc.icon("gear", 32, 641, 20, ONP)
    sc.text(s["btn_log_maint"], 0, 642, 14, ONP, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def pre_trip_inspection_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Pre-Trip Daily Inspection", 2, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["insp_title"])
    sc.sub(s["insp_sub"], 112, w=340)

    # Status Banner (y=164, h=48)
    sc.rect(18, 164, 357, 48, "#E8F8F0", 16, "Status banner", stroke="#1B8A4D40")
    sc.icon("shield-check", 30, 178, 20, "#1B8A4D")
    sc.text(s["insp_stat"], 58, 180, 12, "#1B8A4D", 800, w=300)

    # Category 1: Exterior (y=226)
    sc.section_label(s["i_sec1"], 226)
    sc.rect(18, 248, 357, 54, SURF, 14, "Insp card 1", stroke=BORDER)
    sc.icon("check-circle", 28, 265, 18, "#1B8A4D")
    sc.text(s["i1_t"], 54, 256, 12, INK, 700, w=290)
    sc.text(s["i1_s"], 54, 274, 10.5, MUTED, 500, w=290)

    sc.rect(18, 308, 357, 54, SURF, 14, "Insp card 2", stroke=BORDER)
    sc.icon("check-circle", 28, 325, 18, "#1B8A4D")
    sc.text(s["i2_t"], 54, 316, 12, INK, 700, w=290)
    sc.text(s["i2_s"], 54, 334, 10.5, MUTED, 500, w=290)

    # Category 2: Interior (y=376)
    sc.section_label(s["i_sec2"], 376)
    sc.rect(18, 398, 357, 54, SURF, 14, "Insp card 3", stroke=BORDER)
    sc.icon("check-circle", 28, 415, 18, "#1B8A4D")
    sc.text(s["i3_t"], 54, 406, 12, INK, 700, w=290)
    sc.text(s["i3_s"], 54, 424, 10.5, MUTED, 500, w=290)

    sc.rect(18, 458, 357, 54, SURF, 14, "Insp card 4", stroke=BORDER)
    sc.icon("check-circle", 28, 475, 18, "#1B8A4D")
    sc.text(s["i4_t"], 54, 466, 12, INK, 700, w=290)
    sc.text(s["i4_s"], 54, 484, 10.5, MUTED, 500, w=290)

    # Action Row at Bottom (y=534, y=594)
    # Quick Pass Button
    sc.rect(18, 534, 357, 52, PRIMARY, 18, "Quick pass btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 12, "color": PRIMARY + "40"}])
    sc.icon("check-circle", 32, 549, 20, ONP)
    sc.text(s["btn_quick_pass"], 0, 550, 14, ONP, 700, align="center")

    # Report Defect Button
    sc.rect(18, 594, 357, 46, SURF, 16, "Defect btn", stroke=BORDER)
    sc.icon("warning-circle", 32, 608, 18, DESTR)
    sc.text(s["btn_report_defect"], 0, 609, 13, DESTR, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def safety_telemetry_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Safety Telemetry", 3, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["tel_title"])
    sc.sub(s["tel_sub"], 112, w=340)

    # Giant Telemetry Score Card (y=162, h=118)
    sc.rect(18, 162, 357, 118, INK, 22, "Score card",
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 18, "color": INK + "30"}])
    # Score circle
    sc.rect(34, 178, 86, 86, PRIMARY, 43, "Score circle")
    sc.text(s["tel_score"], 34, 198, 38, ONP, 800, w=86, align="center")
    sc.text(s["tel_score_lbl"], 34, 240, 10, ONP, 700, w=86, align="center")

    # Score details
    sc.text(s["tel_grade"], 134, 186, 12, PRIMARY, 800, w=220)
    sc.text(s["tel_rank"], 134, 208, 13.5, SURF, 700, w=220)
    sc.rect(134, 236, 180, 24, SURF + "20", 12, "Fleet badge")
    sc.icon("shield-check", 142, 241, 14, PRIMARY)
    sc.text(s["tel_zero_acc"], 162, 241, 10.5, SURF, 600, w=145)

    # Key Telematics Metrics (y=298)
    sc.section_label(s["tel_sec_kpi"], 298)

    kpis = [
        (s["k1_t"], s["k1_v"], 322),
        (s["k2_t"], s["k2_v"], 370),
        (s["k3_t"], s["k3_v"], 418),
        (s["k4_t"], s["k4_v"], 466),
    ]
    for kt, kv, ky in kpis:
        sc.rect(18, ky, 357, 42, SURF, 12, f"KPI {kt}", stroke=BORDER)
        sc.icon("check-circle", 28, ky + 13, 16, "#1B8A4D")
        sc.text(kt, 52, ky + 12, 12, INK, 600, w=220)
        sc.text(kv, 260, ky + 11, 13, INK, 800, w=100, align="center")

    # Parent Commendations Box (y=522, h=72)
    sc.rect(18, 522, 357, 72, "#FFF8E7", 16, "Commendation card", stroke="#D4A01780")
    sc.icon("heartbeat", 30, 538, 22, "#D4A017")
    sc.text(s["tel_sec_comm"], 60, 534, 12, "#946A00", 800, w=300)
    sc.text(s["comm_box"], 60, 554, 10.5, INK, 500, w=300)

    # Export Report Button (y=610)
    sc.rect(18, 610, 357, 52, PRIMARY, 18, "Export btn",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 10, "color": PRIMARY + "40"}])
    sc.icon("download-simple", 32, 626, 20, ONP)
    sc.text(s["btn_export_telemetry"], 0, 627, 14, ONP, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def dispatch_contacts_screen(lang: str) -> int:
    sc = Screen(lang, GROUP, "Dispatch Contacts", 4, STR)
    s = sc.s
    sc.status_bar()
    sc.header(s["disp_title"], end_icon="phone")
    sc.sub(s["disp_sub"], 112, w=340)

    # Transit Operations Section (y=162)
    sc.section_label(s["disp_sec1"], 162)

    ops = [
        (s["d1_t"], s["d1_s"], True, 186),
        (s["d2_t"], s["d2_s"], False, 258),
    ]
    for ot, os_, is_pri, oy in ops:
        sc.rect(18, oy, 357, 66, SURF, 16, f"Contact {ot}", stroke=PRIMARY if is_pri else BORDER)
        sc.rect(28, oy + 13, 40, 40, ACCENT, 20, "Avatar")
        sc.icon("user", 38, oy + 23, 20, INK)
        sc.text(ot, 78, oy + 10, 12, INK, 700, w=235)
        sc.text(os_, 78, oy + 32, 10.5, MUTED, 500, w=235)
        # Call pill
        sc.rect(323, oy + 15, 36, 36, PRIMARY + "20", 18, "Call pill")
        sc.icon("phone", 332, oy + 24, 18, PRIMARY)

    # Emergency Services Section (y=338)
    sc.section_label(s["disp_sec2"], 338)

    emergencies = [
        (s["d3_t"], s["d3_s"], "gear", PRIMARY, 362),
        (s["d4_t"], s["d4_s"], "first-aid", DESTR, 426),
        (s["d5_t"], s["d5_s"], "shield-check", "#1B8A4D", 490),
    ]
    for et, es_, eic, ecol, ey in emergencies:
        sc.rect(18, ey, 357, 58, SURF, 16, f"Emerg {et}", stroke=BORDER)
        sc.rect(28, ey + 10, 38, 38, ecol + "20", 14, "Em box")
        sc.icon(eic, 38, ey + 20, 18, ecol)
        sc.text(et, 76, ey + 10, 12.5, INK, 700, w=220)
        sc.text(es_, 76, ey + 30, 10.5, MUTED, 500, w=220)
        # Call pill
        sc.rect(323, ey + 11, 36, 36, ecol + "20", 18, "Em call pill")
        sc.icon("phone", 332, ey + 20, 18, ecol)

    # Giant SOS Dispatch Button (y=568)
    sc.rect(18, 568, 357, 56, DESTR, 18, "SOS btn",
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 14, "color": DESTR + "40"}])
    sc.icon("warning-circle", 32, 585, 22, SURF)
    sc.text(s["btn_sos_dispatch"], 0, 586, 15, SURF, 700, align="center")

    driver_bottom_nav(sc, active=3)
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            driver_profile_hub_screen(lang),
            vehicle_passport_screen(lang),
            pre_trip_inspection_screen(lang),
            safety_telemetry_screen(lang),
            dispatch_contacts_screen(lang),
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
    out_png = os.path.join(shots_dir, "driver-05-profile-en-ar.png")
    r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
    assert r.get("ok"), r
    print("exported:", out_png)

    # Save to dedicated driver document files
    for fname in ("hanna-bus-driver.figcraft", "hanna-bus-driver-profile.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        print(f"saved: {fpath} ({os.path.getsize(fpath)} bytes)")


if __name__ == "__main__":
    main()
