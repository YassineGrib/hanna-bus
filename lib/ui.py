"""Shared screen builder and FigCraft page/section organizer for Hanna Bus."""
import os
import fc
from phosphor import icon
from theme import T

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGO = os.path.join(ROOT, "design", "assets", "brand", "hanna-bus-logo.png")

W, H = 393, 852
STEP_X = 445
YS = {"en": 0, "ar": 980}
FONT = {"en": "Inter", "ar": "IBM Plex Sans Arabic"}

INK, BG, SURF, BORDER, ACCENT = T["text"], T["background"], T["surface"], T["border"], T["accent"]
PRIMARY, MUTED, SOFT, LINK, ONP = T["action-primary"], T["text-muted"], T["title-soft"], T["link"], T["on-primary"]
DESTR, OND, DSURF, DBORD = T["action-destructive"], T["on-destructive"], T["destructive-surface"], T["destructive-border"]


def mk(cmd, **p):
    r = fc.ex(cmd, **p)
    assert r.get("ok"), (cmd, r)
    return r["result"]["id"]


def S(i, **p):
    r = fc.ex("node.set", id=i, **p)
    assert r.get("ok"), r


def width(i):
    return fc.ex("node.get", id=i)["result"]["width"]


def ensure_page(page_name: str, canvas_bg: str = "#F2EFE6") -> int:
    """Select or create `page_name` (renaming default 'Page 1' if present)."""
    pages = fc.ex("page.list")["result"]
    for p in pages:
        if p["name"] == page_name:
            fc.ex("page.select", id=p["id"])
            fc.ex("page.setBackground", id=p["id"], color=canvas_bg)
            return p["id"]
    for p in pages:
        if p["name"] == "Page 1":
            fc.ex("page.rename", id=p["id"], name=page_name)
            fc.ex("page.select", id=p["id"])
            fc.ex("page.setBackground", id=p["id"], color=canvas_bg)
            return p["id"]
    pid = fc.ex("page.add", name=page_name)["result"]["id"]
    fc.ex("page.select", id=pid)
    fc.ex("page.setBackground", id=pid, color=canvas_bg)
    return pid


def clear_lang_on_page(lang: str, group_prefix: str, screen_names: list[str], section_title: str):
    """Remove previous section and frames for `lang` on the active page before rebuilding."""
    sec_ids = fc.ex("node.find", name=section_title, type="SECTION")["result"]["ids"]
    if sec_ids:
        fc.ex("edit.delete", ids=sec_ids)
    for n in screen_names:
        for pat in (f"{lang.upper()} / {group_prefix} / {n}", f"{lang.upper()} / Auth / {n}", f"{lang.upper()} / App / {n}"):
            ids = fc.ex("node.find", name=pat, type="FRAME")["result"]["ids"]
            if ids:
                fc.ex("edit.delete", ids=ids)


def wrap_section(frame_ids: list[int], title: str):
    """Wrap a row of frames in a named FigCraft section for clean layer/canvas organization."""
    if not frame_ids:
        return None
    r = fc.ex("object.wrapInSection", ids=frame_ids, name=title)
    if r.get("ok") and "id" in r.get("result", {}):
        sid = r["result"]["id"]
        fc.ex("node.set", id=sid, fill="#E9E4D5", stroke=BORDER, strokeWeight=1, cornerRadius=28)
        return sid
    return None


class Screen:
    def __init__(self, lang: str, group: str, name: str, col_index: int, strings: dict, bg_style: str = "auto"):
        self.lang = lang
        self.rtl = lang == "ar"
        self.s = strings[lang]
        x = col_index * STEP_X
        self.F = mk(
            "frame.create",
            x=x,
            y=YS[lang],
            width=W,
            height=H,
            name=f"{lang.upper()} / {group} / {name}",
            select=False,
            props={"fill": BG, "clip": True},
        )
        if bg_style == "auto":
            bg_style = ("ambient", "sweep", "orbital", "horizon")[col_index % 4]
        if bg_style:
            self._draw_bg(bg_style)

    def _draw_bg(self, style: str):
        """Draw subtle layered abstract shapes (radial mesh glow, orbital rings, curved waves) at the back of the frame."""
        def blob(x, y, w, h, color, stops_alpha=("42", "14", "00"), name="BG Glow"):
            stops = [color + a for a in stops_alpha]
            return mk(
                "shape.ellipse",
                x=self.ax(x, w),
                y=y,
                width=w,
                height=h,
                parent=self.F,
                name=name,
                select=False,
                props={"fills": [{"type": "radialGradient", "stops": stops}]},
            )

        def ring(x, y, size, color, opacity=0.14, sw=1.0, name="BG Ring"):
            return mk(
                "shape.ellipse",
                x=self.ax(x, size),
                y=y,
                width=size,
                height=size,
                parent=self.F,
                name=name,
                select=False,
                props={"fill": "none", "stroke": color, "strokeWeight": sw, "opacity": opacity},
            )

        def wave(path_ltr, x, y, w, h, color, opacity=0.22, name="BG Wave"):
            return mk(
                "vector.create",
                path=path_ltr,
                x=x,
                y=y,
                width=w,
                height=h,
                parent=self.F,
                name=name,
                select=False,
                props={"fill": color, "opacity": opacity},
            )

        if style == "ambient":
            blob(185, -95, 290, 290, ACCENT, ("50", "1A", "00"), "BG Glow Top")
            ring(230, -55, 200, PRIMARY, opacity=0.11, name="BG Ring 1")
            ring(200, -85, 260, PRIMARY, opacity=0.07, name="BG Ring 2")
            blob(-90, 560, 260, 260, BORDER, ("70", "24", "00"), "BG Glow Bottom")
            wave("M0,85 C105,15 245,115 393,30 L393,170 L0,170 Z", 0, 682, 393, 170, ACCENT, opacity=0.14, name="BG Wave Bottom")
        elif style == "sweep":
            blob(-75, -75, 270, 270, ACCENT, ("48", "18", "00"), "BG Glow Top")
            wave("M0,0 L393,0 L393,75 C265,145 130,30 0,115 Z", 0, 0, 393, 130, BORDER, opacity=0.30, name="BG Wave Top")
            blob(195, 600, 270, 270, PRIMARY, ("1C", "08", "00"), "BG Glow Bottom")
            ring(250, 650, 170, ACCENT, opacity=0.25, name="BG Ring Bottom")
            ring(225, 625, 220, PRIMARY, opacity=0.08, name="BG Ring Bottom 2")
        elif style == "orbital":
            blob(46, -90, 300, 250, ACCENT, ("44", "16", "00"), "BG Glow Top")
            ring(56, -135, 280, PRIMARY, opacity=0.09, name="BG Orbit 1")
            ring(26, -165, 340, PRIMARY, opacity=0.06, name="BG Orbit 2")
            blob(195, 620, 260, 260, ACCENT, ("36", "12", "00"), "BG Glow Bottom")
            wave("M0,110 C130,30 270,120 393,45 L393,165 L0,165 Z", 0, 687, 393, 165, BORDER, opacity=0.35, name="BG Wave Bottom")
        elif style == "horizon":
            blob(195, -75, 260, 260, PRIMARY, ("1E", "08", "00"), "BG Glow Top")
            ring(235, -55, 190, ACCENT, opacity=0.30, name="BG Ring Top")
            blob(-85, 250, 260, 260, ACCENT, ("3C", "14", "00"), "BG Glow Mid")
            wave("M0,65 C140,120 260,10 393,65 L393,165 L0,165 Z", 0, 687, 393, 165, ACCENT, opacity=0.14, name="BG Wave Bottom")

    def hero_frame(self, x, y, w, h, fill, r=26, stroke=None, effects=None, dark=False, name="Hero card"):
        """Create a clipped hero frame with layered abstract shapes inside, mirrored for RTL."""
        p = {"fill": fill, "clip": True, "cornerRadius": r}
        if stroke:
            p.update(stroke=stroke, strokeWeight=1, strokeAlign="inside")
        if effects:
            p["effects"] = effects
        hf = mk("frame.create", x=self.ax(x, w), y=y, width=w, height=h, parent=self.F, name=name, select=False, props=p)

        def hx(lx, lw):
            return (w - lx - lw) if self.rtl else lx

        glow_col = ACCENT if dark else ACCENT
        ring_col = ACCENT if dark else PRIMARY
        # 1. Soft radial glow orb on the end side
        mk(
            "shape.ellipse",
            x=hx(w - 175, 230),
            y=-70,
            width=230,
            height=230,
            parent=hf,
            name="Hero Glow",
            select=False,
            props={"fills": [{"type": "radialGradient", "stops": [glow_col + ("48" if dark else "55"), glow_col + "18", glow_col + "00"]}]},
        )
        # 2. Translucent geometric floating sphere
        mk(
            "shape.ellipse",
            x=hx(w - 92, 128),
            y=-32,
            width=128,
            height=128,
            parent=hf,
            name="Hero Sphere",
            select=False,
            props={"fill": PRIMARY if dark else BORDER, "opacity": 0.22 if dark else 0.45},
        )
        # 3. Concentric orbital rings
        for rsize, rx_off, ry_off, op in ((170, w - 135, -48, 0.26 if dark else 0.16), (225, w - 165, -75, 0.14 if dark else 0.10)):
            mk(
                "shape.ellipse",
                x=hx(rx_off, rsize),
                y=ry_off,
                width=rsize,
                height=rsize,
                parent=hf,
                name="Hero Ring",
                select=False,
                props={"fill": "none", "stroke": ring_col, "strokeWeight": 1.2, "opacity": op},
            )
        # 4. Sweeping curved wave at bottom edge of hero
        mk(
            "vector.create",
            path=f"M0,{int(h*0.58)} C{int(w*0.32)},{int(h*0.42)} {int(w*0.64)},{int(h*0.12)} {w},{int(h*0.32)} L{w},{h} L0,{h} Z",
            x=0,
            y=int(h * 0.28),
            width=w,
            height=int(h * 0.72),
            parent=hf,
            name="Hero Wave",
            select=False,
            props={"fill": SURF if dark else ACCENT, "opacity": 0.05 if dark else 0.13},
        )
        return hf

    def ax(self, x, w=0):
        return W - x - w if self.rtl else x

    def rect(self, x, y, w, h, fill, r=0, name="Rect", stroke=None, effects=None, mirror=True):
        p = {"fill": fill, "cornerRadius": r}
        if stroke:
            p.update(stroke=stroke, strokeWeight=1, strokeAlign="inside")
        if effects:
            p["effects"] = effects
        return mk(
            "shape.rectangle",
            x=self.ax(x, w) if mirror else x,
            y=y,
            width=w,
            height=h,
            parent=self.F,
            name=name,
            select=False,
            props=p,
        )

    def icon(self, name, x, y, size, color, mirror=True):
        return icon(self.F, name, self.ax(x, size) if mirror else x, y, size, color)

    def text(self, t, x, y, size, color, weight=400, w=None, align="start", name=None, latin=False):
        if self.rtl and not latin and size <= 17:
            size += 1
        ff = "Inter" if latin else FONT[self.lang]
        p = {"fontSize": size, "fontFamily": ff, "fontWeight": weight, "fill": color}
        kw = dict(text=t, x=0, y=y, parent=self.F, props=p, select=False)
        if w:
            kw["width"] = w
            p["textAlign"] = "center" if align == "center" else ("right" if (align == "start") == self.rtl else "left")
        if name:
            kw["name"] = name
        i = mk("text.create", **kw)
        if self.rtl and not latin:
            fc.ex("text.direction", direction="rtl", ids=[i])
        if w:
            S(i, x=(W - w) / 2 if (align == "center" and x == 0) else self.ax(x, w))
        else:
            wd = width(i)
            if align == "center":
                S(i, x=(W - wd) / 2)
            else:
                at_left = (align == "start") != self.rtl
                S(i, x=x if at_left else W - x - wd)
        return i

    def status_bar(self):
        mk(
            "text.create",
            text="9:41",
            x=32,
            y=18,
            parent=self.F,
            select=False,
            name="Time",
            props={"fontSize": 17, "fontFamily": "Inter", "fontWeight": 600, "fill": INK},
        )
        for n, x, s in (("cell-signal-full", 290, 20), ("wifi-high", 315, 20), ("battery-full", 340, 24)):
            icon(self.F, n, x, 16, s, INK)
        self.rect(127, 834, 139, 5, INK, 3, "Home indicator", mirror=False)

    def back(self):
        self.rect(18, 64, 42, 42, BORDER, 21, "Back")
        self.icon("arrow-right" if self.rtl else "arrow-left", 28, 74, 22, INK)

    def header(self, title, end_icon=None):
        self.back()
        self.text(title, 0, 72, 20, INK, 700, align="center", name="Header title")
        if end_icon:
            self.rect(333, 64, 42, 42, SURF, 21, "Header action", stroke=BORDER)
            self.icon(end_icon, 344, 75, 20, INK)

    def title(self, l1, l2, y=142):
        self.text(l1, 0, y, 34, SOFT, 700, align="center", name="Title line 1")
        self.text(l2, 0, y + 46, 34, INK, 700, align="center", name="Title line 2")

    def sub(self, t, y, w=310):
        self.text(t, 0, y, 16, MUTED, 400, w=w, align="center", name="Subtitle")

    def section_label(self, label, y, action=None):
        self.text(label, 20, y, 13, SOFT, 700, name=f"Section {label}")
        if action:
            self.text(action, 20, y, 13, LINK, 600, align="end", name=f"Action {action}")

    def chevron(self, x, y):
        self.icon("caret-left" if self.rtl else "caret-right", x, y, 18, MUTED)

    def field(self, label, ph, y, lead, trailing=None, filled=False, latin=False):
        self.text(label, 18, y, 13, INK, 600, name=f"Label {label}")
        self.rect(18, y + 22, 357, 54, SURF, 16, f"Input {label}", stroke=BORDER)
        self.icon(lead, 35, y + 39, 20, INK if filled else MUTED)
        self.text(ph, 64, y + 39, 15, INK if filled else MUTED, weight=600 if filled else 400, name=f"Val {label}", latin=latin)
        if trailing:
            self.icon(trailing, 334, y + 39, 20, MUTED)

    def picker_field(self, label, val, y, lead):
        """Custom button-trigger selector with inner chevron (never a native select)."""
        self.text(label, 18, y, 13, INK, 600, name=f"Label {label}")
        self.rect(18, y + 22, 357, 54, SURF, 16, f"Picker {label}", stroke=BORDER)
        self.icon(lead, 35, y + 39, 20, INK)
        self.text(val, 64, y + 39, 15, INK, 600, name=f"Picker val {label}")
        self.icon("caret-down", 336, y + 40, 18, MUTED)

    def button(self, label, y, lead_icon=None, trail_icon=None):
        self.rect(
            18,
            y,
            357,
            58,
            PRIMARY,
            18,
            "Primary button",
            effects=[{"type": "dropShadow", "offset": [0, 4], "radius": 8, "color": INK + "28"}],
        )
        t = self.text(label, 0, y + 17, 17, ONP, 700, align="center", name="Primary label")
        if lead_icon or trail_icon:
            wt = width(t)
            ic = lead_icon or trail_icon
            gx = (W - (wt + 8 + 18)) / 2
            if trail_icon:
                if self.rtl:
                    S(t, x=gx + 26)
                    icon(self.F, ic, gx, y + 20, 18, ONP)
                else:
                    S(t, x=gx)
                    icon(self.F, ic, gx + wt + 8, y + 20, 18, ONP)
            else:
                if self.rtl:
                    S(t, x=gx)
                    icon(self.F, ic, gx + wt + 8, y + 20, 18, ONP)
                else:
                    icon(self.F, ic, gx, y + 20, 18, ONP)
                    S(t, x=gx + 26)

    def secondary_button(self, label, y, lead_icon=None):
        self.rect(18, y, 357, 54, SURF, 18, "Secondary button", stroke=BORDER)
        t = self.text(label, 0, y + 16, 16, INK, 700, align="center", name="Secondary label")
        if lead_icon:
            wt = width(t)
            gx = (W - (20 + 8 + wt)) / 2
            if self.rtl:
                S(t, x=gx)
                icon(self.F, lead_icon, gx + wt + 8, y + 17, 20, INK)
            else:
                icon(self.F, lead_icon, gx, y + 17, 20, INK)
                S(t, x=gx + 28)

    def footer(self, plain, link, y):
        a = self.text(plain, 0, y, 14, MUTED, name="Footer text")
        b = self.text(link, 0, y, 14, LINK, 600, name="Footer link")
        wa, wb = width(a), width(b)
        gap = 6
        x0 = (W - (wa + gap + wb)) / 2
        if self.rtl:
            S(a, x=x0 + wb + gap)
            S(b, x=x0)
        else:
            S(a, x=x0)
            S(b, x=x0 + wa + gap)
