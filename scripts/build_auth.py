"""Build Page '01 · Auth & Onboarding' (7 screens x 2 languages = 14 frames).

Screens:
  0. Welcome
  1. Sign in
  2. Sign up
  3. Password recovery
  4. OTP Verification (sub-screen)
  5. Reset Password (sub-screen)
  6. Auth Success (sub-screen)
"""
import os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
import fc
from phosphor import icon
from ui import (
    W, H, LOGO, INK, BG, SURF, BORDER, ACCENT, PRIMARY, MUTED, SOFT, LINK, ONP,
    mk, S, width, ensure_page, clear_lang_on_page, wrap_section, Screen,
)

PAGE_NAME = "01 · Auth & Onboarding"
GROUP = "Auth"
SCREENS = [
    "Welcome",
    "Sign in",
    "Sign up",
    "Password recovery",
    "OTP Verification",
    "Reset Password",
    "Auth Success",
]
SECTIONS = {
    "en": "EN · Auth & Onboarding (LTR)",
    "ar": "AR · التسجيل والدخول (RTL)",
}

STR = {
 "en": dict(
  welcome_t1="Welcome to", welcome_t2="Hanna Bus", welcome_sub="Safe school rides, tracked live.", cont="Continue", skip="Skip",
  in_t1="Welcome back", in_t2="to Hanna Bus", in_sub="Track your child's bus in real time.",
  email="Email", password="Password", email_ph="name@example.com", pw_ph="Enter your password", forgot="Forgot password?",
  sign_in="Sign in", or_="or", new_q="New to Hanna Bus?", create_link="Create account",
  up_t1="Create your", up_t2="Hanna Bus account", up_sub="Set up your family in a minute.",
  name="Parent name", name_ph="Parent name", pw_ph2="At least 8 characters", create="Create account",
  terms="By continuing you agree to the Terms and Privacy Policy.", have_q="Already have an account?",
  rc_t1="Forgot", rc_t2="your password?", rc_sub="Enter your email and we will send you a 6-digit verification code.",
  send="Send verification code", rem_q="Remembered it?", back_link="Back to sign in",
  otp_t1="Verify your", otp_t2="email address", otp_sub="We sent a 6-digit code to k.mansouri@mail.dz",
  otp_timer="Resend code in 00:45", otp_btn="Verify & continue", otp_q="Wrong email?", otp_link="Change address",
  rst_t1="Create a", rst_t2="new password", rst_sub="Choose a strong password you have not used before.",
  new_pw="New password", conf_pw="Confirm password",
  req_title="Password requirements",
  req1="At least 8 characters", req2="Contains a number (0-9)", req3="One uppercase & symbol",
  rst_btn="Update password",
  ok_badge="Verified & Secured",
  ok_t1="You are", ok_t2="all set!", ok_sub="Your Hanna Bus parent account is ready. Start tracking your children's school rides live.",
  ok_card_t="Linked Family Account", ok_card_s="k.mansouri@mail.dz · Parent Portal",
  ok_btn="Go to Hanna Bus",
 ),
 "ar": dict(
  welcome_t1="أهلاً بك في", welcome_t2="هنّا باص", welcome_sub="رحلات مدرسية آمنة، وتتبّع مباشر.", cont="متابعة", skip="تخطي",
  in_t1="مرحبًا بعودتك", in_t2="إلى هنّا باص", in_sub="تابع حافلة طفلك لحظة بلحظة.",
  email="البريد الإلكتروني", password="كلمة المرور", email_ph="name@example.com", pw_ph="أدخل كلمة المرور", forgot="نسيت كلمة المرور؟",
  sign_in="تسجيل الدخول", or_="أو", new_q="جديد في هنّا باص؟", create_link="إنشاء حساب",
  up_t1="أنشئ", up_t2="حسابك في هنّا باص", up_sub="جهّز عائلتك في دقيقة واحدة.",
  name="اسم ولي الأمر", name_ph="اسمك الكامل", pw_ph2="8 أحرف على الأقل", create="إنشاء حساب",
  terms="بالمتابعة، أنت توافق على الشروط وسياسة الخصوصية.", have_q="لديك حساب بالفعل؟",
  rc_t1="هل نسيت", rc_t2="كلمة المرور؟", rc_sub="أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّنًا من 6 أرقام.",
  send="إرسال رمز التحقق", rem_q="تذكّرتها؟", back_link="العودة لتسجيل الدخول",
  otp_t1="تحقّق من", otp_t2="بريدك الإلكتروني", otp_sub="أرسلنا رمزًا من 6 أرقام إلى k.mansouri@mail.dz",
  otp_timer="إعادة إرسال الرمز خلال 00:45", otp_btn="تأكيد ومتابعة", otp_q="البريد غير صحيح؟", otp_link="تغيير العنوان",
  rst_t1="تعيين", rst_t2="كلمة مرور جديدة", rst_sub="اختر كلمة مرور قوية لم تستخدمها من قبل لحماية حساب عائلتك.",
  new_pw="كلمة المرور الجديدة", conf_pw="تأكيد كلمة المرور",
  req_title="متطلبات كلمة المرور",
  req1="8 أحرف على الأقل", req2="تحتوي على رقم واحد على الأقل (0-9)", req3="حرف كبير أو رمز خاص",
  rst_btn="تحديث كلمة المرور",
  ok_badge="حساب موثّق وآمن",
  ok_t1="تم الإعداد", ok_t2="بنجاح!", ok_sub="حساب ولي الأمر في هنّا باص جاهز الآن. يمكنك متابعة رحلات أطفالك المدرسية مباشرة.",
  ok_card_t="حساب العائلة المرتبط", ok_card_s="k.mansouri@mail.dz · بوابة أولياء الأمور",
  ok_btn="الانتقال إلى هنّا باص",
 ),
}


def social_row(sc: Screen, y: int):
    for k, lab in enumerate(["Apple", "Google"]):
        x = 18 + k * 184
        sc.rect(x, y, 173, 54, SURF, 16, f"Social {lab}", stroke=BORDER)
        t = mk("text.create", text=lab, x=0, y=y + 17, parent=sc.F, select=False, name=f"Social label {lab}",
               props={"fontSize": 16, "fontFamily": "Inter", "fontWeight": 600, "fill": INK})
        gw = 20 + 8 + width(t)
        bx = sc.ax(x, 173)
        x0 = bx + (173 - gw) / 2
        if sc.rtl:
            icon(sc.F, f"{lab.lower()}-logo", x0 + gw - 20, y + 17, 20, INK)
            S(t, x=x0)
        else:
            icon(sc.F, f"{lab.lower()}-logo", x0, y + 17, 20, INK)
            S(t, x=x0 + 28)


def welcome(lang: str) -> int:
    sc = Screen(lang, GROUP, "Welcome", 0, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.text(s["skip"], 18, 76, 16, LINK, 600, align="end", name="Skip")
    shadow = [{"type": "dropShadow", "offset": [0, 10], "radius": 30, "color": INK + "26"}]

    def card(x, y, w, h, rot, fill, name, op=1):
        i = mk("frame.create", x=sc.ax(x, w), y=y, width=w, height=h, parent=sc.F, name=name, select=False,
               props={"fill": fill, "clip": True, "cornerRadius": 34})
        S(i, rotation=-rot if sc.rtl else rot, opacity=op, stroke=SURF, strokeWeight=4, strokeAlign="outside", effects=shadow)
        return i

    # Hero orbital halo & rings framing the stacked cards
    mk("shape.ellipse", x=36, y=132, width=320, height=320, parent=sc.F, name="Welcome Hero Halo", select=False,
       props={"fills": [{"type": "radialGradient", "stops": [ACCENT + "55", ACCENT + "1A", ACCENT + "00"]}]})
    mk("shape.ellipse", x=56, y=152, width=280, height=280, parent=sc.F, name="Welcome Orbit 1", select=False,
       props={"fill": "none", "stroke": PRIMARY, "strokeWeight": 1.2, "opacity": 0.14})
    mk("shape.ellipse", x=26, y=122, width=340, height=340, parent=sc.F, name="Welcome Orbit 2", select=False,
       props={"fill": "none", "stroke": PRIMARY, "strokeWeight": 1.0, "opacity": 0.08})

    card(244, 150, 132, 205, 8, ACCENT, "Photo slot right", 0.55)
    card(58, 240, 168, 168, -8, BORDER, "Photo slot left", 0.9)
    c = card(98, 172, 196, 244, 0, SURF, "Logo card")
    r = fc.ex("image.place", path=LOGO, parent=c, x=14, y=72, width=168, height=100, mode="fit", name="Hanna Bus logo")
    assert r.get("ok"), r
    for k, (dx, h, col) in enumerate([(-14, 12, BORDER), (0, 20, PRIMARY), (14, 12, BORDER)]):
        sc.rect(196 + dx - 2, 508 + (20 - h) / 2, 4, h, col, 2, f"Pager {k}", mirror=False)
    sc.title(s["welcome_t1"], s["welcome_t2"], y=566)
    sc.sub(s["welcome_sub"], 672, w=330)
    sc.button(s["cont"], 744, trail_icon="caret-left" if sc.rtl else "caret-right")
    return sc.F


def signin(lang: str) -> int:
    sc = Screen(lang, GROUP, "Sign in", 1, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.title(s["in_t1"], s["in_t2"], y=142)
    sc.sub(s["in_sub"], 248)
    sc.field(s["email"], s["email_ph"], 312, "envelope-simple", latin=True)
    sc.field(s["password"], s["pw_ph"], 406, "lock-simple", trailing="eye")
    sc.text(s["forgot"], 18, 498, 14, LINK, 600, align="end", name="Forgot link")
    sc.button(s["sign_in"], 546)
    sc.rect(18, 638, 140, 1, BORDER, 0, "Divider left")
    sc.rect(235, 638, 140, 1, BORDER, 0, "Divider right")
    sc.text(s["or_"], 0, 629, 13, MUTED, align="center", name="Divider label")
    social_row(sc, 668)
    sc.footer(s["new_q"], s["create_link"], 762)
    return sc.F


def signup(lang: str) -> int:
    sc = Screen(lang, GROUP, "Sign up", 2, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.title(s["up_t1"], s["up_t2"], y=142)
    sc.sub(s["up_sub"], 248)
    sc.field(s["name"], s["name_ph"], 308, "user")
    sc.field(s["email"], s["email_ph"], 400, "envelope-simple", latin=True)
    sc.field(s["password"], s["pw_ph2"], 492, "lock-simple", trailing="eye")
    sc.button(s["create"], 608)
    sc.text(s["terms"], 0, 686, 12, MUTED, w=300, align="center", name="Terms")
    sc.footer(s["have_q"], s["sign_in"], 762)
    return sc.F


def recovery(lang: str) -> int:
    sc = Screen(lang, GROUP, "Password recovery", 3, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.rect(148, 136, 96, 96, ACCENT + "59", 48, "Icon circle", mirror=False)
    sc.icon("envelope-simple", 170, 158, 52, INK, mirror=False)
    sc.title(s["rc_t1"], s["rc_t2"], y=254)
    sc.sub(s["rc_sub"], 358, w=310)
    sc.field(s["email"], s["email_ph"], 442, "envelope-simple", latin=True)
    sc.button(s["send"], 546)
    sc.footer(s["rem_q"], s["back_link"], 636)
    return sc.F


def otp_verify(lang: str) -> int:
    sc = Screen(lang, GROUP, "OTP Verification", 4, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.rect(148, 136, 96, 96, ACCENT + "59", 48, "Icon circle", mirror=False)
    sc.icon("shield-check", 170, 158, 52, INK, mirror=False)
    sc.title(s["otp_t1"], s["otp_t2"], y=254)
    sc.sub(s["otp_sub"], 358, w=315)
    # 6 OTP digit boxes (each 50x60, gap 11)
    digits = ["4", "8", "2", "9", "", ""]
    for idx, dg in enumerate(digits):
        bx = 18 + idx * 61
        active = idx == 4
        sc.rect(bx, 434, 52, 60, SURF, 16, f"OTP box {idx+1}", stroke=PRIMARY if active else BORDER, mirror=False)
        if dg:
            t = mk("text.create", text=dg, x=0, y=451, parent=sc.F, select=False, name=f"Digit {dg}",
                   props={"fontSize": 22, "fontFamily": "Inter", "fontWeight": 700, "fill": INK})
            S(t, x=bx + (52 - width(t)) / 2)
        elif active:
            sc.rect(bx + 25, 450, 2, 28, PRIMARY, 1, "OTP Caret", mirror=False)
    # Timer row
    sc.rect(112, 514, 169, 30, SURF, 15, "Timer pill", stroke=BORDER, mirror=False)
    sc.text(s["otp_timer"], 0, 521, 12, MUTED, 600, align="center", name="Timer label")
    sc.button(s["otp_btn"], 576)
    sc.footer(s["otp_q"], s["otp_link"], 664)
    return sc.F


def reset_password(lang: str) -> int:
    sc = Screen(lang, GROUP, "Reset Password", 5, STR); s = sc.s; sc.status_bar(); sc.back()
    sc.title(s["rst_t1"], s["rst_t2"], y=136)
    sc.sub(s["rst_sub"], 240, w=315)
    sc.field(s["new_pw"], "••••••••••••", 304, "lock-simple", trailing="eye", filled=True, latin=True)
    sc.field(s["conf_pw"], "••••••••••••", 396, "lock-simple", trailing="eye", filled=True, latin=True)
    # Password checklist card
    sc.rect(18, 492, 357, 120, SURF, 18, "Requirements card", stroke=BORDER)
    sc.text(s["req_title"], 34, 506, 13, INK, 700, name="Req title")
    reqs = [(534, s["req1"], True), (560, s["req2"], True), (586, s["req3"], True)]
    for ry, rtxt, ok in reqs:
        sc.rect(34, ry, 18, 18, PRIMARY if ok else BORDER, 9, "Req check bg")
        sc.icon("check", 37, ry + 3, 12, ONP)
        sc.text(rtxt, 60, ry, 12, MUTED, 500, name=f"Req {rtxt}")
    sc.button(s["rst_btn"], 642)
    return sc.F


def auth_success(lang: str) -> int:
    sc = Screen(lang, GROUP, "Auth Success", 6, STR); s = sc.s; sc.status_bar()
    # Decorative hero halo + orbital rings
    mk("shape.ellipse", x=76, y=118, width=240, height=240, parent=sc.F, name="Success Hero Halo", select=False,
       props={"fills": [{"type": "radialGradient", "stops": [ACCENT + "55", ACCENT + "1A", ACCENT + "00"]}]})
    mk("shape.ellipse", x=110, y=152, width=172, height=172, parent=sc.F, name="Success Orbit 1", select=False,
       props={"fill": "none", "stroke": PRIMARY, "strokeWeight": 1.2, "opacity": 0.16})
    mk("shape.ellipse", x=82, y=124, width=228, height=228, parent=sc.F, name="Success Orbit 2", select=False,
       props={"fill": "none", "stroke": PRIMARY, "strokeWeight": 1.0, "opacity": 0.09})
    # Decorative hero badge
    sc.rect(136, 178, 120, 120, ACCENT + "66", 60, "Success outer ring", mirror=False)
    sc.rect(152, 194, 88, 88, PRIMARY, 44, "Success inner circle", mirror=False)
    sc.icon("check-circle", 172, 214, 48, ONP, mirror=False)
    # Verified pill
    sc.rect(126, 320, 141, 30, SURF, 15, "Verified pill", stroke=BORDER, mirror=False)
    sc.text(s["ok_badge"], 0, 327, 12, LINK, 700, align="center", name="Verified text")
    sc.title(s["ok_t1"], s["ok_t2"], y=372)
    sc.sub(s["ok_sub"], 478, w=315)
    # Summary account card
    sc.rect(18, 566, 357, 74, SURF, 20, "Account summary card", stroke=BORDER)
    sc.rect(34, 582, 42, 42, ACCENT, 21, "Account icon bg")
    sc.icon("bus", 44, 592, 22, INK)
    sc.text(s["ok_card_t"], 88, 584, 15, INK, 700, name="Summary title")
    sc.text(s["ok_card_s"], 88, 606, 12, MUTED, 400, name="Summary sub")
    sc.button(s["ok_btn"], 716, trail_icon="caret-left" if sc.rtl else "caret-right")
    return sc.F


def build(langs=None):
    langs = langs or ["en", "ar"]
    ensure_page(PAGE_NAME)
    out = {}
    for lang in langs:
        clear_lang_on_page(lang, GROUP, SCREENS, SECTIONS[lang])
        fids = [
            welcome(lang),
            signin(lang),
            signup(lang),
            recovery(lang),
            otp_verify(lang),
            reset_password(lang),
            auth_success(lang),
        ]
        wrap_section(fids, SECTIONS[lang])
        out[lang] = fids
        print(f"built {PAGE_NAME} [{lang}]: {len(fids)} screens")
    return out


if __name__ == "__main__":
    build(sys.argv[1:] or ["en", "ar"])
