"""Build Page '04 · My Children' (7 screens x 2 languages = 14 frames).

Screens:
  0. Children List & Filter (cards with search & status filters)
  1. Add & Edit Child (form for adding/editing child details)
  2. Delete & Manage Child (temporary absence + permanent delete confirmation)
  3. Card Details & Personal (student QR pass + personal & guardian info)
  4. Educative Info (school, grade, classroom, teacher, dismissal rules)
  5. Medical Info (blood type, allergies, asthma protocol, doctor contact)
  6. Time Programme (weekly day selector + morning/school/return schedule)
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

PAGE_NAME = "04 · My Children"
GROUP = "Children"
SCREENS = [
    "Children List & Filter",
    "Add & Edit Child",
    "Delete & Manage Child",
    "Card Details & Personal",
    "Educative Info",
    "Medical Info",
    "Time Programme",
]
SECTIONS = {
    "en": "EN · My Children (LTR)",
    "ar": "AR · أطفالي والملفات التفصيلية (RTL)",
}

STR = {
 "en": dict(
  # Screen 0: Children List & Filter
  list_title="My Children",
  search_ph="Search child, school, or bus...",
  f_all="All (3)", f_bus="On Bus (1)", f_sch="At School (1)", f_home="At Home (1)",
  c1_n="Youssef Mansouri", c1_g="Grade 3 · El Wiam Primary", c1_b="Bus 04 · Seat A2",
  c1_st="On Bus · 4m", c1_tm="Boarded 07:16 AM · Hay El Nasr", c1_med="Asthma Inhaler",
  c2_n="Amina Mansouri", c2_g="Grade 6 · Ibn Khaldoun Middle", c2_b="Bus 02 · Seat B4",
  c2_st="At School", c2_tm="Checked in 07:42 AM · East Gate", c2_med="No Medical Alerts",
  c3_n="Rayan Mansouri", c3_g="KG 2 · Al Manar Preschool", c3_b="Bus 04 · Seat A1",
  c3_st="At Home", c3_tm="Morning pickup at 08:15 AM", c3_med="Peanut Allergy",
  btn_add_new="Add New Child",
  # Screen 1: Add & Edit Child
  ae_title="Add / Edit Child",
  ae_mode_edit="Editing Profile", ae_mode_add="New Child",
  ae_photo_lbl="Update student photo",
  ae_lbl_name="Student full name", ae_val_name="Youssef Karim Mansouri",
  ae_lbl_dob="Birth date & blood type", ae_val_dob="14 Mar 2018 · Blood O+",
  ae_lbl_sch="School & grade level", ae_val_sch="El Wiam Primary · Grade 3",
  ae_lbl_bus="Assigned bus & stop", ae_val_bus="Bus 04 · Hay El Nasr Stop",
  ae_lbl_med="Medical alert tag", ae_val_med="Asthma Inhaler (Front Pocket)",
  ae_save="Save child profile",
  # Screen 2: Delete & Manage Child
  dm_title="Manage Child",
  dm_sec_abs="Temporary Absence Notice",
  dm_abs_t="Pause Pickup Today?",
  dm_abs_s="Notify Bus 04 driver Ahmed B. that Youssef will not ride today. Schedule resumes tomorrow.",
  dm_abs_btn="Pause today's ride",
  dm_sec_del="Remove Child Profile",
  dm_del_t="Delete Child from Account?",
  dm_del_s="Removing Youssef Mansouri (#HB-304) revokes his digital QR boarding pass and stops all live GPS alerts.",
  dm_del_lbl="Student ID to confirm removal",
  dm_del_val="HB-304",
  dm_del_btn="Delete child profile",
  dm_cancel="Keep profile",
  # Tabs shared across detail screens
  tab_pers="Personal", tab_edu="Educative", tab_med="Medical", tab_time="Schedule",
  # Screen 3: Card Details & Personal Info
  dp_title="Child Card & Info",
  dp_qr_sub="Scan QR when boarding Bus 04",
  dp_sec_pers="Personal & Guardian Info",
  dp_r1_k="Full Name", dp_r1_v="Youssef Karim Mansouri",
  dp_r2_k="Birth Date", dp_r2_v="14 March 2018 (8 yrs)",
  dp_r3_k="Student ID", dp_r3_v="#HB-304 · Nat ID 180349",
  dp_r4_k="Guardians", dp_r4_v="Karim M. & Sara M.",
  dp_r5_k="Home Stop", dp_r5_v="Hay El Nasr, Stop 03",
  dp_edit_btn="Edit personal details",
  # Screen 4: Educative Info
  ed_title="Educative Info",
  ed_sec_sch="School & Classroom",
  ed_r1_k="Institution", ed_r1_v="El Wiam Primary School",
  ed_r2_k="Grade & Class", ed_r2_v="Grade 3 · Section B (Rm 14)",
  ed_r3_k="Homeroom", ed_r3_v="Mrs. Nadia Khelifi",
  ed_r4_k="Coordinator", ed_r4_v="Mr. Tarek M. · Transport",
  ed_sec_tr="Transport & Gate Rules",
  ed_t1_t="Bus 04 · Morning & Return", ed_t1_s="Assigned Seat A2 (Front Row)",
  ed_t2_t="East Student Gate Drop-off", ed_t2_s="Supervised entry & dismissal",
  ed_t3_t="Dismissal Security Rule", ed_t3_s="Bus only · Parent PIN required for walk-out",
  # Screen 5: Medical Info
  md_title="Medical Info",
  md_blood="Blood Type: O+", md_ins="CNAS #88412",
  md_sec_cond="Allergies & Conditions",
  md_c1_t="Mild Exercise Asthma", md_c1_s="Blue Ventolin inhaler in front backpack pocket",
  md_c2_t="Food & Drug Allergies", md_c2_s="None reported · Verified Oct 2026",
  md_sec_prot="Driver & First-Aid Protocol",
  md_prot_b="Seat in front row near fresh air. If coughing or short of breath, assist with 2 puffs of inhaler and call parent immediately.",
  md_sec_doc="Authorized Pediatrician",
  md_doc_t="Dr. Amine Boudiaf", md_doc_s="El Chifa Clinic · +213 21 65 44 12",
  md_call_btn="Call",
  md_upd_btn="Update medical record",
  # Screen 6: Time Programme
  tm_title="Time Programme",
  d_sun="Sun", d_mon="Mon", d_tue="Tue", d_wed="Wed", d_thu="Thu",
  tm_sec_am="Morning Ride · To School",
  tm_1_t="07:05 AM · Bus 04 Departs", tm_1_s="Leaves central depot on schedule",
  tm_2_t="07:15 AM · Home Pickup", tm_2_s="Hay El Nasr Stop 03 · QR Check-in",
  tm_3_t="07:40 AM · School Arrival", tm_3_s="El Wiam Primary · East Gate",
  tm_sec_sch="School Hours",
  tm_4_t="08:00 AM - 03:15 PM · Classes", tm_4_s="Core lessons, lunch & supervised study",
  tm_sec_pm="Afternoon Ride · Return Home",
  tm_5_t="03:20 PM · School Boarding", tm_5_s="Bus 04 · East Gate QR Check-in",
  tm_6_t="03:45 PM · Home Drop-off", tm_6_s="Hay El Nasr Stop 03 · Guardian handoff",
  tm_btn="Request schedule change",
 ),
 "ar": dict(
  # Screen 0: Children List & Filter
  list_title="أطفالي",
  search_ph="ابحث باسم الطفل أو المدرسة أو الحافلة...",
  f_all="الكل (3)", f_bus="في الحافلة (1)", f_sch="في المدرسة (1)", f_home="في المنزل (1)",
  c1_n="يوسف منصوري", c1_g="السنة 3 ابتدائي · مدرسة الوئام", c1_b="حافلة 04 · مقعد A2",
  c1_st="في الحافلة · 4 د", c1_tm="صعد 07:16 ص · محطة حي النصر", c1_med="بخاخ ربو",
  c2_n="أمينة منصوري", c2_g="السنة 1 متوسط · متوسطة ابن خلدون", c2_b="حافلة 02 · مقعد B4",
  c2_st="في المدرسة", c2_tm="وصلت 07:42 ص · البوابة الشرقية", c2_med="لا توجد تنبيهات طبية",
  c3_n="ريان منصوري", c3_g="تحضيري 2 · روضة المنار", c3_b="حافلة 04 · مقعد A1",
  c3_st="في المنزل", c3_tm="موعد الصعود 08:15 ص", c3_med="حساسية فول سوداني",
  btn_add_new="إضافة طفل جديد",
  # Screen 1: Add & Edit Child
  ae_title="إضافة / تعديل طفل",
  ae_mode_edit="تعديل ملف حالي", ae_mode_add="طفل جديد",
  ae_photo_lbl="تحديث صورة التلميذ",
  ae_lbl_name="الاسم الكامل للتلميذ", ae_val_name="يوسف كريم منصوري",
  ae_lbl_dob="تاريخ الميلاد وفصيلة الدم", ae_val_dob="14 مارس 2018 · فصيلة O+",
  ae_lbl_sch="المدرسة والمستوى الدراسي", ae_val_sch="ابتدائية الوئام · السنة 3",
  ae_lbl_bus="الحافلة ومحطة المنزل", ae_val_bus="الحافلة 04 · محطة حي النصر",
  ae_lbl_med="التنبيه الطبي السريع", ae_val_med="بخاخ ربو (الجيب الأمامي للحقيبة)",
  ae_save="حفظ بيانات الطفل",
  # Screen 2: Delete & Manage Child
  dm_title="إدارة ملف الطفل",
  dm_sec_abs="إبلاغ عن غياب مؤقت",
  dm_abs_t="إيقاف رحلة اليوم مؤقتًا؟",
  dm_abs_s="سيتم إشعار سائق الحافلة 04 (أحمد ب.) بعدم ركوب يوسف اليوم، ويُستأنف الجدول تلقائيًا غدًا.",
  dm_abs_btn="تأكيد غياب اليوم",
  dm_sec_del="حذف ملف الطفل نهائيًا",
  dm_del_t="حذف الطفل من الحساب؟",
  dm_del_s="يؤدي حذف ملف يوسف منصوري (#HB-304) إلى إلغاء بطاقة الصعود الرقمية QR وإيقاف كافة تنبيهات المسار.",
  dm_del_lbl="رمز التلميذ لتأكيد الحذف",
  dm_del_val="HB-304",
  dm_del_btn="حذف ملف الطفل نهائيًا",
  dm_cancel="الإبقاء على الملف",
  # Tabs shared across detail screens
  tab_pers="الشخصية", tab_edu="الدراسية", tab_med="الصحية", tab_time="البرنامج",
  # Screen 3: Card Details & Personal Info
  dp_title="بطاقة ومعلومات الطفل",
  dp_qr_sub="يُمسح رمز QR عند صعود الحافلة 04",
  dp_sec_pers="المعلومات الشخصية والأولياء",
  dp_r1_k="الاسم الكامل", dp_r1_v="يوسف كريم منصوري",
  dp_r2_k="تاريخ الميلاد", dp_r2_v="14 مارس 2018 (8 سنوات)",
  dp_r3_k="رمز التلميذ", dp_r3_v="#HB-304 · رقم 180349",
  dp_r4_k="الأولياء المعتمدون", dp_r4_v="كريم م. (الأب) · سارة م. (الأم)",
  dp_r5_k="محطة المنزل", dp_r5_v="حي النصر · المحطة 03",
  dp_edit_btn="تعديل البيانات الشخصية",
  # Screen 4: Educative Info
  ed_title="المعلومات الدراسية",
  ed_sec_sch="المدرسة والقسم الدراسي",
  ed_r1_k="المؤسسة", ed_r1_v="مدرسة الوئام الابتدائية",
  ed_r2_k="المستوى", ed_r2_v="السنة 3 ابتدائي · فوج ب (14)",
  ed_r3_k="أستاذة القسم", ed_r3_v="الأستاذة نادية خليفي",
  ed_r4_k="منسّق النقل", ed_r4_v="الأستاذ طارق م. · مكتب الحركة",
  ed_sec_tr="قواعد النقل والبوابة المدرسية",
  ed_t1_t="الحافلة 04 · ذهاب وعودة", ed_t1_s="المقعد المخصّص A2 (الصف الأمامي)",
  ed_t2_t="البوابة الشرقية للتلاميذ", ed_t2_s="استلام وتسليم بإشراف مشرف المدرسة",
  ed_t3_t="قاعدة الأمان عند الانصراف", ed_t3_s="بالحافلة فقط · يتطلب رمز PIN للخروج الفردي",
  # Screen 5: Medical Info
  md_title="الملف الصحي والطبي",
  md_blood="فصيلة الدم: O+", md_ins="تأمين #88412",
  md_sec_cond="الحساسية والحالات الصحية",
  md_c1_t="ربو خفيف عند المجهود", md_c1_s="بخاخ فينتولين أزرق في الجيب الأمامي للحقيبة",
  md_c2_t="الحساسية الغذائية والدوائية", md_c2_s="لا توجد حساسية مسجّلة · موثّق أكتوبر 2026",
  md_sec_prot="بروتوكول السائق والإسعاف الأولي",
  md_prot_b="الجلوس في الصف الأمامي قرب التهوية. عند السعال أو ضيق التنفس يُعطى بخّتان من البخاخ مع الاتصال الفوري بولي الأمر.",
  md_sec_doc="الطبيب والعيادة المعتمدة",
  md_doc_t="د. أمين بوضياف", md_doc_s="عيادة الشفاء · 021 65 44 12",
  md_call_btn="اتصال",
  md_upd_btn="تحديث الملف الطبي",
  # Screen 6: Time Programme
  tm_title="البرنامج الزمني",
  d_sun="الأحد", d_mon="الإثنين", d_tue="الثلاثاء", d_wed="الأربعاء", d_thu="الخميس",
  tm_sec_am="رحلة الصباح · الذهاب للمدرسة",
  tm_1_t="07:05 ص · انطلاق الحافلة 04", tm_1_s="الانطلاق من المستودع المركزي في الموعد",
  tm_2_t="07:15 ص · الصعود من المحطة", tm_2_s="محطة حي النصر 03 · مسح رمز QR",
  tm_3_t="07:40 ص · الوصول إلى المدرسة", tm_3_s="ابتدائية الوئام · البوابة الشرقية",
  tm_sec_sch="أوقات الدراسة",
  tm_4_t="08:00 ص - 03:15 م · الحصص الدراسية", tm_4_s="الدروس الأساسية، استراحة الغداء والمطالعة",
  tm_sec_pm="رحلة المساء · العودة للمنزل",
  tm_5_t="03:20 م · الصعود من المدرسة", tm_5_s="الحافلة 04 · مسح QR عند البوابة الشرقية",
  tm_6_t="03:45 م · النزول في محطة المنزل", tm_6_s="محطة حي النصر 03 · تسليم لولي الأمر",
  tm_btn="طلب تعديل المواعيد",
 ),
}


def child_mini_header(sc: Screen, active_tab: int):
    """Compact child banner + 4-tab bar used across screens 3..6."""
    s = sc.s
    sc.rect(18, 114, 357, 56, SURF, 18, "Child mini banner", stroke=BORDER)
    sc.rect(30, 124, 36, 36, ACCENT, 18, "Mini avatar")
    sc.icon("graduation-cap", 39, 133, 18, INK)
    sc.text(s["c1_n"], 76, 124, 15, INK, 700, name="Mini name")
    sc.text(s["c1_b"], 76, 144, 11, MUTED, 500, name="Mini bus")
    sc.rect(282, 129, 78, 26, PRIMARY, 13, "Mini status pill")
    tb = sc.text(s["c1_st"], 0, 134, 10, ONP, 700, name="Mini status txt")
    S(tb, x=sc.ax(282, 78) + (78 - width(tb)) / 2)

    # 4-Tab Bar (y=178, h=40)
    sc.rect(18, 178, 357, 40, SURF, 14, "Detail tabs bar", stroke=BORDER)
    tabs = [s["tab_pers"], s["tab_edu"], s["tab_med"], s["tab_time"]]
    for idx, tlabel in enumerate(tabs):
        tx = 22 + idx * 88
        is_act = idx == active_tab
        if is_act:
            sc.rect(tx, 182, 85, 32, PRIMARY, 10, f"Active tab {idx}")
        tt = sc.text(tlabel, 0, 190, 12, ONP if is_act else MUTED, 700 if is_act else 600, name=f"Tab {tlabel}")
        S(tt, x=sc.ax(tx, 85) + (85 - width(tt)) / 2)


def children_list_filter(lang: str) -> int:
    sc = Screen(lang, GROUP, "Children List & Filter", 0, STR); s = sc.s
    sc.status_bar()
    sc.header(s["list_title"], end_icon="plus")

    # Search input + Filter icon button (y=116)
    sc.rect(18, 116, 305, 46, SURF, 14, "Search box", stroke=BORDER)
    sc.icon("magnifying-glass", 32, 130, 18, MUTED)
    sc.text(s["search_ph"], 58, 130, 13, MUTED, 400, name="Search placeholder")
    sc.rect(331, 116, 44, 46, PRIMARY, 14, "Filter button")
    sc.icon("funnel-simple", 344, 130, 18, ONP)

    # Filter chips row (y=172)
    chips = [
        (18, 76, s["f_all"], True),
        (100, 90, s["f_bus"], False),
        (196, 92, s["f_sch"], False),
        (294, 81, s["f_home"], False),
    ]
    for cx, cw, clbl, act in chips:
        sc.rect(cx, 172, cw, 32, PRIMARY if act else SURF, 16, f"Chip {clbl}", stroke=PRIMARY if act else BORDER)
        tc = sc.text(clbl, 0, 180, 11, ONP if act else INK, 700 if act else 600, name=f"Chip txt {clbl}")
        S(tc, x=sc.ax(cx, cw) + (cw - width(tc)) / 2)

    # 3 Rich Child Cards (y=216, 382, 548; each h=154)
    cards = [
        (216, s["c1_n"], s["c1_g"], s["c1_b"], s["c1_st"], s["c1_tm"], s["c1_med"], PRIMARY, ONP, DSURF, DESTR),
        (382, s["c2_n"], s["c2_g"], s["c2_b"], s["c2_st"], s["c2_tm"], s["c2_med"], ACCENT, INK, BG, MUTED),
        (548, s["c3_n"], s["c3_g"], s["c3_b"], s["c3_st"], s["c3_tm"], s["c3_med"], BORDER, INK, DSURF, DESTR),
    ]
    for cy, cn, cg, cb, cst, ctm, cmed, st_bg, st_fg, m_bg, m_fg in cards:
        sc.rect(18, cy, 357, 154, SURF, 22, f"Card {cn}", stroke=BORDER,
                effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 14, "color": INK + "10"}])
        sc.rect(32, cy + 16, 48, 48, ACCENT, 24, f"Avatar {cn}")
        sc.icon("graduation-cap", 44, cy + 28, 24, INK)
        sc.text(cn, 90, cy + 16, 16, INK, 700, name=f"Name {cn}")
        sc.text(cg, 90, cy + 39, 12, MUTED, 500, name=f"Grade {cn}")
        # Status pill top-end
        sc.rect(272, cy + 16, 89, 28, st_bg, 14, f"Status {cst}")
        ts = sc.text(cst, 0, cy + 22, 11, st_fg, 700, name=f"Status lbl {cst}")
        S(ts, x=sc.ax(272, 89) + (89 - width(ts)) / 2)

        # Divider inside card
        sc.rect(32, cy + 74, 329, 1, BORDER, 0, "Card divider")
        # Bus & live timestamp row
        sc.icon("bus", 32, cy + 86, 16, INK)
        sc.text(cb, 54, cy + 85, 12, INK, 600, name=f"Bus {cn}")
        sc.text(ctm, 32, cy + 106, 11, MUTED, 400, name=f"Time {cn}")

        # Medical badge pill + quick actions (QR + Edit) at bottom of card
        sc.rect(32, cy + 124, 148, 22, m_bg, 11, f"Med pill {cn}")
        tm = sc.text(cmed, 0, cy + 128, 10, m_fg, 600, name=f"Med txt {cn}")
        S(tm, x=sc.ax(32, 148) + (148 - width(tm)) / 2)

        sc.rect(296, cy + 114, 30, 30, BG, 10, "Quick QR", stroke=BORDER)
        sc.icon("qr-code", 303, cy + 121, 16, INK)
        sc.rect(331, cy + 114, 30, 30, BG, 10, "Quick Edit", stroke=BORDER)
        sc.icon("pencil-simple", 338, cy + 121, 16, INK)

    sc.button(s["btn_add_new"], 742, lead_icon="plus")
    return sc.F


def add_edit_child(lang: str) -> int:
    sc = Screen(lang, GROUP, "Add & Edit Child", 1, STR); s = sc.s
    sc.status_bar()
    sc.header(s["ae_title"])

    # Mode segmented pill (Edit Existing / Add New)
    sc.rect(18, 116, 357, 38, SURF, 12, "Mode switch", stroke=BORDER)
    sc.rect(22, 120, 174, 30, PRIMARY, 9, "Active edit mode")
    t1 = sc.text(s["ae_mode_edit"], 0, 127, 12, ONP, 700, name="Mode 1")
    S(t1, x=sc.ax(22, 174) + (174 - width(t1)) / 2)
    t2 = sc.text(s["ae_mode_add"], 0, 127, 12, MUTED, 600, name="Mode 2")
    S(t2, x=sc.ax(198, 173) + (173 - width(t2)) / 2)

    # Photo avatar uploader row
    sc.rect(18, 164, 357, 68, SURF, 18, "Photo card", stroke=BORDER)
    sc.rect(32, 174, 48, 48, ACCENT, 24, "Avatar circle")
    sc.icon("camera", 44, 186, 24, INK)
    sc.text(s["ae_photo_lbl"], 92, 188, 14, LINK, 700, name="Photo label")
    sc.chevron(342, 189)

    # 5 Structured Form Fields
    sc.field(s["ae_lbl_name"], s["ae_val_name"], 244, "user", filled=True)
    sc.picker_field(s["ae_lbl_dob"], s["ae_val_dob"], 332, "calendar-blank")
    sc.picker_field(s["ae_lbl_sch"], s["ae_val_sch"], 420, "graduation-cap")
    sc.picker_field(s["ae_lbl_bus"], s["ae_val_bus"], 508, "bus")
    sc.picker_field(s["ae_lbl_med"], s["ae_val_med"], 596, "first-aid")

    sc.button(s["ae_save"], 742, lead_icon="check")
    return sc.F


def delete_manage_child(lang: str) -> int:
    sc = Screen(lang, GROUP, "Delete & Manage Child", 2, STR); s = sc.s
    sc.status_bar()
    sc.header(s["dm_title"])

    # 1. Temporary Absence Card
    sc.section_label(s["dm_sec_abs"], 120)
    sc.rect(18, 144, 357, 198, SURF, 22, "Absence card", stroke=BORDER)
    sc.rect(34, 160, 44, 44, ACCENT, 14, "Absence icon bg")
    sc.icon("calendar-blank", 45, 171, 22, INK)
    sc.text(s["dm_abs_t"], 90, 166, 16, INK, 700, name="Absence title")
    sc.text(s["dm_abs_s"], 34, 216, 12, MUTED, 400, w=325, name="Absence body")
    sc.rect(34, 280, 325, 46, PRIMARY, 14, "Absence CTA")
    sc.text(s["dm_abs_btn"], 0, 294, 14, ONP, 700, align="center", name="Absence btn lbl")

    # 2. Permanent Delete Child Card (uses action-destructive everywhere)
    sc.section_label(s["dm_sec_del"], 362)
    sc.rect(18, 386, 357, 398, DSURF, 24, "Delete child card", stroke=DBORD,
            effects=[{"type": "dropShadow", "offset": [0, 8], "radius": 24, "color": INK + "14"}])
    sc.rect(34, 404, 48, 48, DESTR, 16, "Delete child badge")
    sc.icon("trash", 46, 416, 24, OND)
    sc.text(s["dm_del_t"], 94, 410, 16, DESTR, 700, name="Delete child title")
    sc.text(s["dm_del_s"], 34, 466, 12, MUTED, 400, w=325, name="Delete child body")

    sc.text(s["dm_del_lbl"], 34, 544, 12, INK, 600, name="Delete ID label")
    sc.rect(34, 566, 325, 48, SURF, 14, "Delete ID input", stroke=DESTR)
    sc.text(s["dm_del_val"], 50, 581, 15, DESTR, 700, name="Delete ID val", latin=True)

    sc.rect(34, 632, 325, 50, DESTR, 16, "Delete child CTA")
    t_dp = sc.text(s["dm_del_btn"], 0, 647, 15, OND, 700, align="center", name="Delete child CTA lbl")
    wdp = width(t_dp); dgx = (W - (18 + 8 + wdp)) / 2
    if sc.rtl:
        S(t_dp, x=dgx); icon(sc.F, "trash", dgx + wdp + 8, 648, 18, OND)
    else:
        icon(sc.F, "trash", dgx, 648, 18, OND); S(t_dp, x=dgx + 26)

    sc.rect(34, 696, 325, 46, SURF, 14, "Keep profile btn", stroke=BORDER)
    sc.text(s["dm_cancel"], 0, 710, 14, INK, 700, align="center", name="Keep profile lbl")
    return sc.F


def card_details_personal(lang: str) -> int:
    sc = Screen(lang, GROUP, "Card Details & Personal", 3, STR); s = sc.s
    sc.status_bar()
    sc.header(s["dp_title"], end_icon="pencil-simple")
    child_mini_header(sc, active_tab=0)

    # Student ID & QR Boarding Pass Card (y=232..396)
    sc.rect(18, 232, 357, 162, SURF, 22, "Boarding pass card", stroke=BORDER,
            effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 18, "color": INK + "12"}])
    sc.rect(34, 248, 96, 96, BG, 16, "QR box", stroke=BORDER)
    sc.icon("qr-code", 48, 262, 68, INK)
    sc.text(s["c1_n"], 144, 252, 17, INK, 700, name="Pass name")
    sc.text(s["c1_g"], 144, 276, 12, MUTED, 500, name="Pass grade")
    sc.rect(144, 302, 196, 28, ACCENT + "66", 10, "Pass bus pill")
    sc.icon("bus", 154, 308, 16, INK)
    sc.text(s["c1_b"], 178, 308, 12, INK, 700, name="Pass bus txt")
    sc.text(s["dp_qr_sub"], 34, 360, 12, LINK, 600, name="QR caption")

    # Personal Info Rows Card (y=408..716)
    sc.section_label(s["dp_sec_pers"], 408)
    sc.rect(18, 432, 357, 280, SURF, 20, "Personal info card", stroke=BORDER)
    rows = [
        (432, "user", s["dp_r1_k"], s["dp_r1_v"], False),
        (488, "calendar-blank", s["dp_r2_k"], s["dp_r2_v"], False),
        (544, "identification-card", s["dp_r3_k"], s["dp_r3_v"], True),
        (600, "users", s["dp_r4_k"], s["dp_r4_v"], False),
        (656, "map-pin", s["dp_r5_k"], s["dp_r5_v"], False),
    ]
    for idx, (ry, icn, rk, rv, is_lat) in enumerate(rows):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"Pers div {idx}")
        sc.rect(32, ry + 12, 32, 32, BG, 10, f"Pers ic {idx}", stroke=BORDER)
        sc.icon(icn, 40, ry + 20, 16, INK)
        sc.text(rk, 74, ry + 19, 13, MUTED, 500, name=f"Key {rk}")
        sc.text(rv, 34, ry + 19, 13, INK, 700, align="end", name=f"Val {rk}", latin=is_lat)

    sc.secondary_button(s["dp_edit_btn"], 736, lead_icon="pencil-simple")
    return sc.F


def educative_info(lang: str) -> int:
    sc = Screen(lang, GROUP, "Educative Info", 4, STR); s = sc.s
    sc.status_bar()
    sc.header(s["ed_title"], end_icon="buildings")
    child_mini_header(sc, active_tab=1)

    # School & Classroom Card (y=232..478)
    sc.section_label(s["ed_sec_sch"], 232)
    sc.rect(18, 256, 357, 224, SURF, 20, "School info card", stroke=BORDER)
    rows = [
        (256, "buildings", s["ed_r1_k"], s["ed_r1_v"]),
        (312, "graduation-cap", s["ed_r2_k"], s["ed_r2_v"]),
        (368, "book-open", s["ed_r3_k"], s["ed_r3_v"]),
        (424, "phone-call", s["ed_r4_k"], s["ed_r4_v"]),
    ]
    for idx, (ry, icn, rk, rv) in enumerate(rows):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"Edu div {idx}")
        sc.rect(32, ry + 12, 32, 32, BG, 10, f"Edu ic {idx}", stroke=BORDER)
        sc.icon(icn, 40, ry + 20, 16, INK)
        sc.text(rk, 74, ry + 19, 13, MUTED, 500, name=f"Key {rk}")
        sc.text(rv, 34, ry + 19, 13, INK, 700, align="end", name=f"Val {rk}")

    # Transport & Gate Rules (y=496..796)
    sc.section_label(s["ed_sec_tr"], 496)
    rules = [
        (520, "bus", s["ed_t1_t"], s["ed_t1_s"], ACCENT),
        (608, "map-pin", s["ed_t2_t"], s["ed_t2_s"], BG),
        (696, "shield-check", s["ed_t3_t"], s["ed_t3_s"], ACCENT + "66"),
    ]
    for ry, icn, rt, rs, ibg in rules:
        sc.rect(18, ry, 357, 76, SURF, 18, f"Rule {rt}", stroke=BORDER)
        sc.rect(32, ry + 16, 44, 44, ibg, 14, f"Rule ic {rt}", stroke=BORDER)
        sc.icon(icn, 43, ry + 27, 22, INK)
        sc.text(rt, 88, ry + 17, 14, INK, 700, name=f"Rule title {rt}")
        sc.text(rs, 88, ry + 40, 12, MUTED, 400, name=f"Rule sub {rt}")
    return sc.F


def medical_info(lang: str) -> int:
    sc = Screen(lang, GROUP, "Medical Info", 5, STR); s = sc.s
    sc.status_bar()
    sc.header(s["md_title"], end_icon="first-aid")
    child_mini_header(sc, active_tab=2)

    # Blood Type & Insurance pills row (y=230)
    sc.rect(18, 230, 173, 44, DSURF, 14, "Blood pill", stroke=DBORD)
    sc.icon("heartbeat", 32, 242, 20, DESTR)
    sc.text(s["md_blood"], 60, 243, 14, DESTR, 700, name="Blood text")

    sc.rect(202, 230, 173, 44, SURF, 14, "Insurance pill", stroke=BORDER)
    sc.icon("shield-check", 216, 242, 20, INK)
    sc.text(s["md_ins"], 244, 243, 14, INK, 700, name="Insurance text")

    # Allergies & Conditions
    sc.section_label(s["md_sec_cond"], 288)
    conds = [
        (312, "warning-circle", s["md_c1_t"], s["md_c1_s"], DSURF, DBORD, DESTR, OND),
        (396, "check-circle", s["md_c2_t"], s["md_c2_s"], SURF, BORDER, ACCENT, INK),
    ]
    for cy, icn, ct, cs, cbg, cbord, ibg, ifg in conds:
        sc.rect(18, cy, 357, 74, cbg, 18, f"Cond {ct}", stroke=cbord)
        sc.rect(32, cy + 15, 44, 44, ibg, 14, f"Cond ic {ct}")
        sc.icon(icn, 43, cy + 26, 22, ifg)
        sc.text(ct, 88, cy + 16, 14, INK, 700, name=f"Cond title {ct}")
        sc.text(cs, 88, cy + 39, 12, MUTED, 400, name=f"Cond sub {ct}")

    # First-Aid Protocol Box
    sc.section_label(s["md_sec_prot"], 484)
    sc.rect(18, 508, 357, 94, SURF, 18, "Protocol card", stroke=BORDER)
    sc.text(s["md_prot_b"], 32, 522, 12, INK, 500, w=329, name="Protocol text")

    # Authorized Pediatrician Card
    sc.section_label(s["md_sec_doc"], 616)
    sc.rect(18, 640, 357, 74, SURF, 18, "Doctor card", stroke=BORDER)
    sc.rect(32, 655, 44, 44, ACCENT, 14, "Doc icon bg")
    sc.icon("first-aid", 43, 666, 22, INK)
    sc.text(s["md_doc_t"], 88, 656, 15, INK, 700, name="Doc name")
    sc.text(s["md_doc_s"], 88, 679, 12, MUTED, 400, name="Doc sub")
    sc.rect(294, 659, 66, 36, PRIMARY, 12, "Call doc btn")
    td = sc.text(s["md_call_btn"], 0, 668, 13, ONP, 700, name="Call doc lbl")
    S(td, x=sc.ax(294, 66) + (66 - width(td)) / 2)

    sc.secondary_button(s["md_upd_btn"], 736, lead_icon="pencil-simple")
    return sc.F


def time_programme(lang: str) -> int:
    sc = Screen(lang, GROUP, "Time Programme", 6, STR); s = sc.s
    sc.status_bar()
    sc.header(s["tm_title"], end_icon="calendar-blank")
    child_mini_header(sc, active_tab=3)

    # 5 Day Selector Pills (Sun..Thu, y=230)
    days = [s["d_sun"], s["d_mon"], s["d_tue"], s["d_wed"], s["d_thu"]]
    for idx, dlbl in enumerate(days):
        dx = 18 + idx * 73
        act = idx == 0
        sc.rect(dx, 230, 65, 36, PRIMARY if act else SURF, 12, f"Day {dlbl}", stroke=PRIMARY if act else BORDER)
        td = sc.text(dlbl, 0, 239, 12, ONP if act else INK, 700 if act else 600, name=f"Day txt {dlbl}")
        S(td, x=sc.ax(dx, 65) + (65 - width(td)) / 2)

    # Morning Timeline (y=280..480)
    sc.section_label(s["tm_sec_am"], 278)
    sc.rect(18, 302, 357, 174, SURF, 20, "Morning card", stroke=BORDER)
    am_rows = [
        (302, "bus", s["tm_1_t"], s["tm_1_s"], BG),
        (360, "map-pin", s["tm_2_t"], s["tm_2_s"], ACCENT),
        (418, "buildings", s["tm_3_t"], s["tm_3_s"], PRIMARY),
    ]
    for idx, (ry, icn, rt, rs, ibg) in enumerate(am_rows):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"AM div {idx}")
        sc.rect(32, ry + 13, 32, 32, ibg, 10, f"AM ic {idx}", stroke=BORDER)
        sc.icon(icn, 40, ry + 21, 16, ONP if ibg == PRIMARY else INK)
        sc.text(rt, 76, ry + 11, 13, INK, 700, name=f"AM t {rt}")
        sc.text(rs, 76, ry + 31, 11, MUTED, 400, name=f"AM s {rt}")

    # School Hours Band (y=490..566)
    sc.section_label(s["tm_sec_sch"], 488)
    sc.rect(18, 512, 357, 58, SURF, 18, "School hours card", stroke=BORDER)
    sc.rect(32, 525, 32, 32, ACCENT + "66", 10, "School ic")
    sc.icon("book-open", 40, 533, 16, INK)
    sc.text(s["tm_4_t"], 76, 523, 13, INK, 700, name="School hours t")
    sc.text(s["tm_4_s"], 76, 543, 11, MUTED, 400, name="School hours s")

    # Afternoon Return Timeline (y=582..724)
    sc.section_label(s["tm_sec_pm"], 582)
    sc.rect(18, 606, 357, 116, SURF, 20, "Afternoon card", stroke=BORDER)
    pm_rows = [
        (606, "qr-code", s["tm_5_t"], s["tm_5_s"], ACCENT),
        (664, "check-circle", s["tm_6_t"], s["tm_6_s"], PRIMARY),
    ]
    for idx, (ry, icn, rt, rs, ibg) in enumerate(pm_rows):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"PM div {idx}")
        sc.rect(32, ry + 13, 32, 32, ibg, 10, f"PM ic {idx}", stroke=BORDER)
        sc.icon(icn, 40, ry + 21, 16, ONP if ibg == PRIMARY else INK)
        sc.text(rt, 76, ry + 11, 13, INK, 700, name=f"PM t {rt}")
        sc.text(rs, 76, ry + 31, 11, MUTED, 400, name=f"PM s {rt}")

    sc.secondary_button(s["tm_btn"], 742, lead_icon="clock")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            children_list_filter(lang),
            add_edit_child(lang),
            delete_manage_child(lang),
            card_details_personal(lang),
            educative_info(lang),
            medical_info(lang),
            time_programme(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
