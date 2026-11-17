"""Place Phosphor (regular) icons into FigCraft as vectors sized to a 256 box."""
import re, os, fc
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "design", "icons", "svg")
def path_of(name):
    svg = open(os.path.join(D, name + ".svg")).read()
    return " ".join(re.findall(r'<path[^>]* d="([^"]+)"', svg))
def icon(parent, name, x, y, size, color):
    r = fc.ex("vector.create", path=path_of(name), x=x, y=y, parent=parent, name=f"Icon {name}",
              select=False, props={"fill": color})
    assert r.get("ok"), r
    i = r["result"]["id"]
    g = fc.ex("node.get", id=i)["result"]
    s = size / 256.0
    ox, oy = g["x"] - x, g["y"] - y
    r = fc.ex("node.set", id=i, width=g["width"] * s, height=g["height"] * s, x=x + ox * s, y=y + oy * s)
    assert r.get("ok"), r
    return i
