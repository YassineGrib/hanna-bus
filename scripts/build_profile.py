"""Build Page '02 · Profile & Family' (5 screens x 2 languages = 10 frames).

Screens:
  0. Profile (overview)
  1. Edit My Info (sub-screen)
  2. Child Details (sub-screen)
  3. Add Child (sub-screen)
  4. Emergency Dispatch (sub-screen)
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

PAGE_NAME = "02 · Profile & Family"
GROUP = "Profile"
SCREENS = [
    "Profile",
    "Edit My Info",
    "Child Details",
    "Add Child",
    "Emergency Dispatch",
]
SECTIONS = {
    "en": "EN · Profile & Family (LTR)",
    "ar": "AR · الملف الشخصي والعائلة (RTL)",
}

STR = {
 "en": dict(
  prof_title="Profile", parent_name="Karim Mansouri", parent_role="Parent · 2 Children", verified="Verified",
  sec_children="My Children", add_child="+ Add child",
  c1_name="Youssef Mansouri", c1_sub="Grade 3 · Bus 04", c1_badge="On Bus",
  c2_name="Amina Mansouri", c2_sub="Grade 6 · Bus 02", c2_badge="At School",
  sec_info="My Info",
  lbl_phone="Phone", val_phone="+213 550 12 34 56",
  lbl_email="Email", val_email="k.mansouri@mail.dz",
  lbl_stop="Home Stop", val_stop="Hay El Nasr, Algiers",
  sec_urgent="Urgent Calls",
  u1_title="Bus 04 Driver · Ahmed B.", u1_sub="Direct route line", u1_btn="Call",
  u2_title="School Emergency Line", u2_sub="24/7 Transport Dispatch", u2_btn="SOS",
  # Edit My Info
  edit_title="Edit My Info", change_photo="Change photo",
  lbl_fullname="Full name", lbl_backup="Emergency backup phone", val_backup="+213 551 98 76 54",
  save_btn="Save changes",
  # Child Details
  cd_title="Child Details", cd_school="El Wiam Primary School · ID #HB-304",
  cd_sec_bus="Assigned Bus & Driver",
  cd_bus_name="Bus 04 · Morning & Return", cd_bus_sub="Driver: Ahmed Benali · Plate 04821-116",
  cd_sec_sched="Daily Stop Schedule",
  cd_pick_t="Morning Pickup", cd_pick_s="Hay El Nasr Stop · 07:15 AM",
  cd_drop_t="Afternoon Drop-off", cd_drop_s="Hay El Nasr Stop · 03:35 PM",
  cd_sec_qr="Digital Boarding Pass",
  cd_qr_title="Student QR Badge", cd_qr_sub="Scanned by driver when boarding & exiting",
  cd_btn_abs="Report absence today",
  # Add Child
  add_title="Add Child", add_sub="Link a student to receive live boarding & route alerts.",
  lbl_cname="Student full name", ph_cname="e.g. Rayan Mansouri",
  lbl_school="School & grade", val_school="El Wiam Primary · Grade 1",
  lbl_sid="Student school code", ph_sid="HB-2026-XXXX",
  lbl_route="Assigned bus route", val_route="Route 04 · Hay El Nasr",
  add_btn="Link child to account",
  # Emergency Dispatch
  sos_title="Emergency Dispatch",
  sos_live_badge="LIVE BUS TELEMETRY",
  sos_bus_t="Bus 04 · Moving on Route",
  sos_bus_s="Last GPS ping: 20 sec ago · Boulevard des Martyrs",
  sos_sec_direct="Immediate Voice Lines",
  sos_c1_t="Call Bus 04 Driver", sos_c1_s="Ahmed Benali · Direct cab phone",
  sos_c2_t="Transport Supervisor", sos_c2_s="Central safety desk · Priority line",
  sos_c3_t="Civil Protection · SOS", sos_c3_s="National emergency response · 14",
  sos_share_btn="Share live family location",
 ),
 "ar": dict(
  prof_title="الملف الشخصي", parent_name="كريم منصوري", parent_role="ولي أمر · طفلان", verified="موثّق",
  sec_children="أطفالي", add_child="+ إضافة طفل",
  c1_name="يوسف منصوري", c1_sub="السنة 3 ابتدائي · حافلة 04", c1_badge="في الحافلة",
  c2_name="أمينة منصوري", c2_sub="السنة 1 متوسط · حافلة 02", c2_badge="في المدرسة",
  sec_info="معلوماتي",
  lbl_phone="الهاتف", val_phone="+213 550 12 34 56",
  lbl_email="البريد", val_email="k.mansouri@mail.dz",
  lbl_stop="محطة المنزل", val_stop="حي النصر، الجزائر",
  sec_urgent="اتصالات الطوارئ",
  u1_title="سائق الحافلة 04 · أحمد ب.", u1_sub="خط الرحلة المباشر", u1_btn="اتصال",
  u2_title="خط طوارئ المدرسة", u2_sub="مكتب النقل المدرسي 24/7", u2_btn="طوارئ",
  # Edit My Info
  edit_title="تعديل معلوماتي", change_photo="تغيير الصورة",
  lbl_fullname="الاسم الكامل", lbl_backup="هاتف طوارئ بديل", val_backup="+213 551 98 76 54",
  save_btn="حفظ التغييرات",
  # Child Details
  cd_title="بيانات الطفل", cd_school="مدرسة الوئام الابتدائية · رقم #HB-304",
  cd_sec_bus="الحافلة والسائق المخصّص",
  cd_bus_name="الحافلة 04 · ذهاب وعودة", cd_bus_sub="السائق: أحمد بن علي · لوحة 116-04821",
  cd_sec_sched="مواعيد المحطة اليومية",
  cd_pick_t="صعود الصباح", cd_pick_s="محطة حي النصر · 07:15 ص",
  cd_drop_t="نزول المساء", cd_drop_s="محطة حي النصر · 03:35 م",
  cd_sec_qr="بطاقة الصعود الرقمية",
  cd_qr_title="رمز QR للتلميذ", cd_qr_sub="يمسحه السائق عند الصعود والنزول من الحافلة",
  cd_btn_abs="إبلاغ عن غياب اليوم",
  # Add Child
  add_title="إضافة طفل", add_sub="اربط التلميذ بحسابك لتصلك تنبيهات الصعود والمسار مباشرة.",
  lbl_cname="الاسم الكامل للتلميذ", ph_cname="مثال: ريان منصوري",
  lbl_school="المدرسة والمستوى الدراسي", val_school="ابتدائية الوئام · السنة 1",
  lbl_sid="الرمز المدرسي للتلميذ", ph_sid="HB-2026-XXXX",
  lbl_route="مسار الحافلة", val_route="المسار 04 · حي النصر",
  add_btn="ربط الطفل بالحساب",
  # Emergency Dispatch
  sos_title="اتصال الطوارئ المباشر",
  sos_live_badge="تتبّع مباشر للحافلة",
  sos_bus_t="الحافلة 04 · في المسار الآن",
  sos_bus_s="آخر تحديث GPS: منذ 20 ثانية · شارع الشهداء",
  sos_sec_direct="خطوط الاتصال الفوري",
  sos_c1_t="اتصال بسائق الحافلة 04", sos_c1_s="أحمد بن علي · هاتف المقصورة المباشر",
  sos_c2_t="مشرف النقل المدرسي", sos_c2_s="مكتب الأمان المركزي · خط أولوية",
  sos_c3_t="الحماية المدنية / الطوارئ", sos_c3_s="الخط الوطني للطوارئ · 14",
  sos_share_btn="مشاركة الموقع المباشر للعائلة",
 ),
}


def profile_main(lang: str) -> int:
    sc = Screen(lang, GROUP, "Profile", 0, STR); s = sc.s
    sc.status_bar()
    sc.header(s["prof_title"], end_icon="pencil-simple")

    sc.hero_frame(18, 118, 357, 94, SURF, 24, stroke=BORDER, dark=False, name="Hero card",
                  effects=[{"type": "dropShadow", "offset": [0, 6], "radius": 20, "color": INK + "12"}])
    av = mk("frame.create", x=sc.ax(34, 62), y=134, width=62, height=62, parent=sc.F, name="Avatar slot",
            select=False, props={"fill": ACCENT, "clip": True, "cornerRadius": 31, "stroke": PRIMARY, "strokeWeight": 2})
    icon(av, "user", 17, 17, 28, INK)
    sc.text(s["parent_name"], 110, 140, 18, INK, 700, name="Parent name")
    sc.text(s["parent_role"], 110, 168, 13, MUTED, 500, name="Parent role")
    sc.rect(292, 148, 68, 28, ACCENT + "66", 14, "Verified badge")
    t_ver = sc.text(s["verified"], 0, 154, 12, INK, 600, name="Verified label")
    S(t_ver, x=sc.ax(292, 68) + (68 - width(t_ver)) / 2)

    sc.section_label(s["sec_children"], 226, action=s["add_child"])
    children = [
        (250, s["c1_name"], s["c1_sub"], s["c1_badge"], ACCENT, PRIMARY),
        (316, s["c2_name"], s["c2_sub"], s["c2_badge"], BORDER, BORDER),
    ]
    for cy, cname, csub, cbadge, cfill, pfill in children:
        sc.rect(18, cy, 357, 58, SURF, 18, f"Child {cname}", stroke=BORDER)
        sc.rect(32, cy + 10, 38, 38, cfill, 19, "Child icon bg")
        sc.icon("bus", 41, cy + 19, 20, INK)
        sc.text(cname, 82, cy + 10, 15, INK, 700, name=f"Name {cname}")
        sc.text(csub, 82, cy + 31, 12, MUTED, 400, name=f"Sub {cname}")
        sc.rect(282, cy + 15, 78, 28, pfill, 14, f"Status {cbadge}")
        tb = sc.text(cbadge, 0, cy + 21, 11, ONP if pfill == PRIMARY else INK, 600, name=f"Badge {cbadge}")
        S(tb, x=sc.ax(282, 78) + (78 - width(tb)) / 2)

    sc.section_label(s["sec_info"], 388)
    sc.rect(18, 412, 357, 162, SURF, 20, "My Info card", stroke=BORDER)
    info_rows = [
        (412, "phone", s["lbl_phone"], s["val_phone"], True),
        (466, "envelope-simple", s["lbl_email"], s["val_email"], True),
        (520, "map-pin", s["lbl_stop"], s["val_stop"], False),
    ]
    for idx, (ry, ic_name, lbl, val, is_latin) in enumerate(info_rows):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, f"Info divider {idx}")
        sc.rect(32, ry + 11, 32, 32, BG, 10, f"Icon box {lbl}", stroke=BORDER)
        sc.icon(ic_name, 40, ry + 19, 16, INK)
        sc.text(lbl, 76, ry + 18, 14, MUTED, 500, name=f"Label {lbl}")
        sc.text(val, 34, ry + 18, 14, INK, 600, align="end", name=f"Value {lbl}", latin=is_latin)

    sc.section_label(s["sec_urgent"], 588)
    sc.rect(18, 612, 357, 68, SURF, 18, "Urgent Driver Card", stroke=BORDER)
    sc.rect(32, 624, 44, 44, ACCENT, 14, "Driver call icon bg")
    sc.icon("phone-call", 43, 635, 22, INK)
    sc.text(s["u1_title"], 88, 624, 15, INK, 700, name="Driver title")
    sc.text(s["u1_sub"], 88, 646, 12, MUTED, 400, name="Driver sub")
    sc.rect(294, 628, 66, 36, PRIMARY, 12, "Driver Call Button")
    t_u1 = sc.text(s["u1_btn"], 0, 637, 13, ONP, 700, name="Driver Call label")
    S(t_u1, x=sc.ax(294, 66) + (66 - width(t_u1)) / 2)

    sc.rect(18, 692, 357, 68, DSURF, 18, "Urgent SOS Card", stroke=DBORD)
    sc.rect(32, 704, 44, 44, DESTR, 14, "SOS icon bg")
    sc.icon("warning-circle", 43, 715, 22, OND)
    sc.text(s["u2_title"], 88, 704, 15, INK, 700, name="SOS title")
    sc.text(s["u2_sub"], 88, 726, 12, MUTED, 400, name="SOS sub")
    sc.rect(294, 708, 66, 36, DESTR, 12, "SOS Call Button")
    t_u2 = sc.text(s["u2_btn"], 0, 717, 13, OND, 700, name="SOS Call label")
    S(t_u2, x=sc.ax(294, 66) + (66 - width(t_u2)) / 2)
    return sc.F


def edit_my_info(lang: str) -> int:
    sc = Screen(lang, GROUP, "Edit My Info", 1, STR); s = sc.s
    sc.status_bar()
    sc.header(s["edit_title"])
    # Avatar uploader center
    av = mk("frame.create", x=152, y=126, width=88, height=88, parent=sc.F, name="Avatar edit slot",
            select=False, props={"fill": ACCENT, "clip": True, "cornerRadius": 44, "stroke": PRIMARY, "strokeWeight": 2})
    icon(av, "user", 26, 26, 36, INK)
    sc.rect(212, 184, 32, 32, PRIMARY, 16, "Camera badge", stroke=SURF, mirror=False)
    sc.icon("camera", 220, 192, 16, ONP, mirror=False)
    sc.text(s["change_photo"], 0, 224, 13, LINK, 600, align="center", name="Change photo link")

    sc.field(s["lbl_fullname"], s["parent_name"], 262, "user", filled=True)
    sc.field(s["lbl_phone"], s["val_phone"], 350, "phone", filled=True, latin=True)
    sc.field(s["lbl_backup"], s["val_backup"], 438, "phone-call", filled=True, latin=True)
    sc.field(s["lbl_email"], s["val_email"], 526, "envelope-simple", filled=True, latin=True)
    sc.picker_field(s["lbl_stop"], s["val_stop"], 614, "map-pin")
    sc.button(s["save_btn"], 742, lead_icon="check")
    return sc.F


def child_details(lang: str) -> int:
    sc = Screen(lang, GROUP, "Child Details", 2, STR); s = sc.s
    sc.status_bar()
    sc.header(s["cd_title"], end_icon="pencil-simple")

    # Child Hero Card
    sc.hero_frame(18, 118, 357, 88, SURF, 22, stroke=BORDER, dark=False, name="Child Hero")
    sc.rect(34, 134, 56, 56, ACCENT, 28, "Child Avatar")
    sc.icon("graduation-cap", 48, 148, 28, INK)
    sc.text(s["c1_name"], 104, 135, 17, INK, 700, name="Child name")
    sc.text(s["cd_school"], 104, 160, 12, MUTED, 500, name="Child school")
    sc.rect(284, 136, 74, 26, PRIMARY, 13, "Child active pill")
    tb = sc.text(s["c1_badge"], 0, 141, 11, ONP, 700, name="Child badge")
    S(tb, x=sc.ax(284, 74) + (74 - width(tb)) / 2)

    # Assigned Bus Card
    sc.section_label(s["cd_sec_bus"], 220)
    sc.rect(18, 244, 357, 74, SURF, 18, "Assigned bus card", stroke=BORDER)
    sc.rect(32, 259, 44, 44, ACCENT + "66", 14, "Bus badge")
    sc.icon("bus", 43, 270, 22, INK)
    sc.text(s["cd_bus_name"], 88, 259, 15, INK, 700, name="Bus title")
    sc.text(s["cd_bus_sub"], 88, 282, 12, MUTED, 400, name="Bus sub")
    sc.rect(322, 263, 36, 36, PRIMARY, 12, "Call driver quick")
    sc.icon("phone-call", 331, 272, 18, ONP)

    # Daily Schedule Card
    sc.section_label(s["cd_sec_sched"], 332)
    sc.rect(18, 356, 357, 124, SURF, 18, "Schedule card", stroke=BORDER)
    for idx, (ry, rt, rs) in enumerate([(356, s["cd_pick_t"], s["cd_pick_s"]), (418, s["cd_drop_t"], s["cd_drop_s"])]):
        if idx > 0:
            sc.rect(34, ry, 325, 1, BORDER, 0, "Sched divider")
        sc.rect(32, ry + 13, 36, 36, BG, 10, "Clock bg", stroke=BORDER)
        sc.icon("clock", 41, ry + 22, 18, INK)
        sc.text(rt, 80, ry + 13, 14, INK, 700, name=f"Sched {rt}")
        sc.text(rs, 80, ry + 33, 12, MUTED, 400, name=f"Sched sub {rt}")

    # Digital Boarding QR Card
    sc.section_label(s["cd_sec_qr"], 494)
    sc.rect(18, 518, 357, 190, SURF, 22, "Boarding QR card", stroke=BORDER)
    sc.rect(144, 534, 104, 104, BG, 18, "QR frame", stroke=BORDER, mirror=False)
    sc.icon("qr-code", 160, 550, 72, INK, mirror=False)
    sc.text(s["cd_qr_title"], 0, 648, 15, INK, 700, align="center", name="QR title")
    sc.text(s["cd_qr_sub"], 0, 671, 12, MUTED, 400, align="center", name="QR sub")

    # Report absence secondary button
    sc.secondary_button(s["cd_btn_abs"], 736, lead_icon="info")
    return sc.F


def add_child(lang: str) -> int:
    sc = Screen(lang, GROUP, "Add Child", 3, STR); s = sc.s
    sc.status_bar()
    sc.header(s["add_title"])
    sc.sub(s["add_sub"], 122, w=325)

    # Child photo uploader
    av = mk("frame.create", x=158, y=172, width=76, height=76, parent=sc.F, name="Child photo slot",
            select=False, props={"fill": SURF, "clip": True, "cornerRadius": 38, "stroke": BORDER, "strokeWeight": 2})
    icon(av, "camera", 24, 24, 28, MUTED)

    sc.field(s["lbl_cname"], s["ph_cname"], 266, "user")
    sc.picker_field(s["lbl_school"], s["val_school"], 356, "graduation-cap")
    sc.field(s["lbl_sid"], s["ph_sid"], 446, "qr-code", latin=True)
    sc.picker_field(s["lbl_route"], s["val_route"], 536, "bus")

    sc.button(s["add_btn"], 742, lead_icon="plus")
    return sc.F


def emergency_dispatch(lang: str) -> int:
    sc = Screen(lang, GROUP, "Emergency Dispatch", 4, STR); s = sc.s
    sc.status_bar()
    sc.header(s["sos_title"])

    # Live Bus Status Banner
    sc.rect(18, 122, 357, 112, DSURF, 22, "Live telemetry card", stroke=DBORD)
    sc.rect(34, 138, 148, 24, DESTR, 12, "Live pill")
    t_lb = sc.text(s["sos_live_badge"], 0, 143, 10, OND, 700, name="Live badge text")
    S(t_lb, x=sc.ax(34, 148) + (148 - width(t_lb)) / 2)
    sc.text(s["sos_bus_t"], 34, 172, 16, INK, 700, name="Live bus title")
    sc.text(s["sos_bus_s"], 34, 198, 12, MUTED, 500, name="Live bus sub")

    # Direct Call Cards
    sc.section_label(s["sos_sec_direct"], 252)
    cards = [
        (278, s["sos_c1_t"], s["sos_c1_s"], SURF, BORDER, PRIMARY, ONP, "phone-call", s["u1_btn"]),
        (372, s["sos_c2_t"], s["sos_c2_s"], SURF, BORDER, PRIMARY, ONP, "shield-check", s["u1_btn"]),
        (466, s["sos_c3_t"], s["sos_c3_s"], DSURF, DBORD, DESTR, OND, "warning-circle", s["u2_btn"]),
    ]
    for cy, ct, cs, cbg, cbord, bfill, bon, icn, btxt in cards:
        sc.rect(18, cy, 357, 80, cbg, 20, f"SOS row {ct}", stroke=cbord)
        sc.rect(32, cy + 16, 48, 48, bfill if bfill == DESTR else ACCENT, 16, "SOS row icon bg")
        sc.icon(icn, 44, cy + 28, 24, bon if bfill == DESTR else INK)
        sc.text(ct, 92, cy + 18, 15, INK, 700, name=f"Title {ct}")
        sc.text(cs, 92, cy + 42, 12, MUTED, 400, name=f"Sub {ct}")
        sc.rect(292, cy + 22, 68, 36, bfill, 12, f"Btn {ct}")
        tb = sc.text(btxt, 0, cy + 31, 13, bon, 700, name=f"Btn lbl {ct}")
        S(tb, x=sc.ax(292, 68) + (68 - width(tb)) / 2)

    # Share live family location CTA
    sc.button(s["sos_share_btn"], 742, lead_icon="map-pin")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            profile_main(lang),
            edit_my_info(lang),
            child_details(lang),
            add_child(lang),
            emergency_dispatch(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
