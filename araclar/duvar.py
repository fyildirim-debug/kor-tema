#!/usr/bin/env python3
# Kor Furkan duvar kagidi: Furkan'in gercek projelerinden git log --graph
import sys, subprocess, os

KOR, AMBER, YESIL, LILA, MAVI = "#EE5A36", "#F2AA3C", "#5CBE78", "#8288AE", "#6F93B8"
ZEMIN = "#111216"
MONO = "JetBrainsMono Nerd Font"

def svg(W, H):
    s = W / 2560.0
    o = []
    def X(v): return v * s
    a = o.append
    a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">')
    a('<defs>')
    a(f'<linearGradient id="zemin" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#0f1013"/><stop offset="0.55" stop-color="{ZEMIN}"/><stop offset="1" stop-color="#1b1e2b"/></linearGradient>')
    a(f'<radialGradient id="kizil" cx="{X(300)}" cy="{H}" r="{X(1100)}" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="{KOR}" stop-opacity="0.42"/><stop offset="0.45" stop-color="{KOR}" stop-opacity="0.12"/><stop offset="1" stop-color="{KOR}" stop-opacity="0"/></radialGradient>')
    a(f'<radialGradient id="head" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="{KOR}" stop-opacity="0.55"/><stop offset="0.35" stop-color="{KOR}" stop-opacity="0.18"/><stop offset="1" stop-color="{KOR}" stop-opacity="0"/></radialGradient>')
    a(f'<pattern id="nokta" width="{X(36)}" height="{X(36)}" patternUnits="userSpaceOnUse"><circle cx="{X(18)}" cy="{X(18)}" r="{X(1)}" fill="#ffffff" fill-opacity="0.035"/></pattern>')
    a('</defs>')
    a(f'<rect width="{W}" height="{H}" fill="url(#zemin)"/>')
    a(f'<rect width="{W}" height="{H}" fill="url(#nokta)"/>')
    a(f'<rect width="{W}" height="{H}" fill="url(#kizil)"/>')

    ANA = 1040
    HEADX = 2306

    def egri(x0, y0, x1, y1, renk, w=3):
        mx = (x0 + x1) / 2
        a(f'<path d="M{X(x0)},{X(y0)} C{X(mx)},{X(y0)} {X(mx)},{X(y1)} {X(x1)},{X(y1)}" fill="none" stroke="{renk}" stroke-width="{X(w)}" stroke-linecap="round"/>')
    def cizgi(x0, x1, y, renk, w=3, kesik=False):
        k = f' stroke-dasharray="{X(3)} {X(9)}"' if kesik else ''
        a(f'<line x1="{X(x0)}" y1="{X(y)}" x2="{X(x1)}" y2="{X(y)}" stroke="{renk}" stroke-width="{X(w)}" stroke-linecap="round"{k}/>')
    def dugum(x, y, renk, r=7):
        a(f'<circle cx="{X(x)}" cy="{X(y)}" r="{X(r)}" fill="{ZEMIN}" stroke="{renk}" stroke-width="{X(2.6)}"/>')
    def yazi(x, y, t, renk, boy=13, op=1, anchor="middle", agirlik=400):
        t = t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        a(f'<text x="{X(x)}" y="{X(y)}" font-family="{MONO}" font-size="{X(boy)}" font-weight="{agirlik}" fill="{renk}" fill-opacity="{op}" text-anchor="{anchor}">{t}</text>')
    def hap(x, y, t, renk, boy=17):
        g = (len(t) * 0.6 * boy + 26)
        h = boy + 14
        a(f'<rect x="{X(x - g/2)}" y="{X(y - h/2)}" width="{X(g)}" height="{X(h)}" rx="{X(h/2)}" fill="{renk}" fill-opacity="0.08" stroke="{renk}" stroke-opacity="0.75" stroke-width="{X(1.6)}"/>')
        yazi(x, y + boy * 0.36, t, renk, boy)

    # --- dallar (alttaki katman once) ---
    # arnorg: solda asagi inip geri doner
    AR = 1168
    egri(150, ANA, 330, AR, MAVI); cizgi(330, 560, AR, MAVI); egri(560, AR, 740, ANA, MAVI)
    for x in (380, 470): dugum(x, AR, MAVI)
    hap(470, AR + 44, "arnorg v0.0.10", MAVI)

    # mailhere: yukari, icinde officehere
    MH = 906
    egri(820, ANA, 1000, MH, LILA); cizgi(1000, 1640, MH, LILA); egri(1640, MH, 1820, ANA, LILA)
    OH = 806
    egri(1100, MH, 1250, OH, YESIL); cizgi(1250, 1440, OH, YESIL); egri(1440, OH, 1590, MH, YESIL)
    for x in (1300, 1390): dugum(x, OH, YESIL)
    for x in (1060, 1160, 1530, 1600): dugum(x, MH, LILA)
    hap(1345, OH - 40, "officehere v0.2.0-beta.2", YESIL)
    hap(1690, MH - 40, "mailhere v0.9.8", LILA)

    # navihere: sagda asagi iner, acik dal olarak ekranin disina gider
    NV = 1173
    egri(1930, ANA, 2110, NV, AMBER); cizgi(2110, 2560, NV, AMBER)
    for x in (2160, 2290, 2420): dugum(x, NV, AMBER)
    hap(2410, NV + 44, "navihere 1.1.1", AMBER)

    # --- ana hat ---
    cizgi(0, HEADX, ANA, KOR)
    cizgi(HEADX + 18, 2560, ANA, KOR, 2.4, kesik=True)
    # ana hat commitleri: AXConnector ve FY Sinema gecmisi (gercek hashler)
    commitler = [(80, "3badb36"), (230, None), (150, None), (420, "6636bbf"), (640, None), (740, None),
                 (820, None), (980, "71192e4"), (1220, None), (1480, "13c68dd"), (1700, None),
                 (1820, None), (1930, None), (2040, "573374b"), (2180, "99d74ec")]
    birlesme = {150, 740, 820, 1820, 1930}
    for x, h in commitler:
        dugum(x, ANA, KOR, 9 if x in birlesme else 7)
        if h: yazi(x, ANA + 32, h, "#5a5c66", 13)
    # FY Sinema kararli surumu ana hatta etiket
    hap(1480, ANA - 42, "fysinema 1.2.2", KOR, 15)

    # HEAD
    a(f'<circle cx="{X(HEADX)}" cy="{X(ANA)}" r="{X(170)}" fill="url(#head)"/>')
    a(f'<circle cx="{X(HEADX)}" cy="{X(ANA)}" r="{X(20)}" fill="none" stroke="{KOR}" stroke-opacity="0.35" stroke-width="{X(1.5)}"/>')
    a(f'<circle cx="{X(HEADX)}" cy="{X(ANA)}" r="{X(11)}" fill="{KOR}"/>')
    hap(HEADX - 100, ANA - 50, "HEAD → furkan/main", KOR)

    # imza satiri
    yazi(2508, 1395, '~/furkan ❯ git log --graph --all --author="Furkan YILDIRIM"', "#6a6c76", 15, 0.9, "end")
    yazi(52, 1395, "ankara · 39.93°N 32.86°E", "#6a6c76", 13, 0.55, "start")
    a('</svg>')
    return "\n".join(o)

hedef = sys.argv[1]
for W, H in ((1920, 1080), (2560, 1440), (3840, 2160)):
    yol = os.path.join(hedef, f"{W}x{H}")
    open(yol + ".svg", "w").write(svg(W, H))
    subprocess.run(["rsvg-convert", "-o", yol + ".png", yol + ".svg"], check=True)
    os.remove(yol + ".svg")
