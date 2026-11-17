"""Build the complete, organized Hanna Bus FigCraft document across 3 pages & 6 language sections.

Pages:
  - 01 · Auth & Onboarding   (7 screens x 2 languages = 14 frames)
  - 02 · Profile & Family    (5 screens x 2 languages = 10 frames)
  - 03 · Settings & Account  (6 screens x 2 languages = 12 frames)
Total: 18 unique screens x 2 languages (EN LTR + AR RTL) = 36 mobile frames.
"""
import os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "lib"))
sys.path.insert(0, os.path.join(ROOT, "scripts"))
import fc
import build_auth
import build_profile
import build_settings
import build_children
import build_tracking
import build_home


def clean_first_page():
    """Remove any leftover un-sectioned frames on the initial page before building."""
    pages = fc.ex("page.list")["result"]
    if pages:
        fc.ex("page.select", id=pages[0]["id"])
        for t in ("SECTION", "FRAME"):
            ids = fc.ex("node.find", type=t)["result"]["ids"]
            if ids:
                fc.ex("edit.delete", ids=ids)
        for p in pages[1:]:
            fc.ex("page.delete", id=p["id"])


def main():
    langs = sys.argv[1:] or ["en", "ar"]
    if set(langs) == {"en", "ar"}:
        clean_first_page()

    shots_dir = os.path.join(ROOT, "output", "screenshots")
    os.makedirs(shots_dir, exist_ok=True)

    modules = [
        (build_auth, "01-auth-en-ar.png"),
        (build_profile, "02-profile-en-ar.png"),
        (build_settings, "03-settings-en-ar.png"),
        (build_children, "04-children-en-ar.png"),
        (build_tracking, "05-tracking-en-ar.png"),
        (build_home, "06-home-en-ar.png"),
    ]
    for mod, png_name in modules:
        mod.build(langs)
        fc.ex("view.zoomFit")
        fc.ex("select.none")
        out_png = os.path.join(shots_dir, png_name)
        r = fc.ex("file.export", format="png", scale=1.0, path=out_png)
        assert r.get("ok"), r
        print("exported:", out_png)

    # Select first page for default view on open
    pages = fc.ex("page.list")["result"]
    fc.ex("page.select", id=pages[0]["id"])
    fc.ex("view.zoomFit")

    for fname in ("hanna-bus.figcraft", "hanna-bus-auth.figcraft"):
        fpath = os.path.join(ROOT, "output", fname)
        res = fc.ex("file.saveAs", path=fpath)
        assert res.get("ok"), res
        print("saved:", fpath, f"({res['result']['bytes']} bytes)")


if __name__ == "__main__":
    main()
