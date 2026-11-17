"""Load a Hanna Bus palette and resolve semantic tokens. Pick one with HANNA_PALETTE=teal-gray|mustard (default mustard)."""
import json, os
NAME = os.environ.get("HANNA_PALETTE", "mustard")
_P = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "design", "palettes", f"hanna-bus-{NAME}.json")))
def _flat():
    d = {}
    for grp in ("palette", "derived"):
        for k, v in _P[grp].items(): d[f"{grp}.{k}"] = v["$value"]
    return d
_F = _flat()
T = {k: _F[v["$value"].strip("{}")] for k, v in _P["semantic"].items()}
def lum(h):
    c = [int(h[i:i+2], 16) / 255 for i in (1, 3, 5)]
    c = [x / 12.92 if x <= .03928 else ((x + .055) / 1.055) ** 2.4 for x in c]
    return .2126 * c[0] + .7152 * c[1] + .0722 * c[2]
def contrast(a, b):
    x, y = sorted((lum(a), lum(b)), reverse=True); return (x + .05) / (y + .05)
if __name__ == "__main__":
    for fg, bg, need in [("text", "background", 4.5), ("text-muted", "background", 4.5), ("text-muted", "surface", 4.5),
                         ("title-soft", "background", 3.0), ("on-primary", "action-primary", 4.5),
                         ("link", "background", 4.5), ("link", "surface", 4.5), ("icon", "surface", 3.0), ("on-destructive", "action-destructive", 4.5), ("action-destructive", "destructive-surface", 4.5)]:
        r = contrast(T[fg], T[bg]); print(f"{fg:11} on {bg:14} {r:5.2f} need {need} {'PASS' if r >= need else 'FAIL'}")
