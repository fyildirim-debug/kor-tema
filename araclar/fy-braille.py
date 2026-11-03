# FY grafiti gorselini renkli Braille noktalarina cevirir (hucre basi 2x4 nokta)
import sys
from PIL import Image
kaynak, gen, hedef = sys.argv[1], int(sys.argv[2]), sys.argv[3]
im = Image.open(kaynak).convert("RGB")
im = im.crop(im.point(lambda v: 255 if v > 45 else 0).convert("L").getbbox())
W, H = im.size
pw = gen * 2
ph = round(pw * H / W / 4 * 0.94) * 4      # hucre en/boy orani ~ 1:2.1
k = im.resize((pw, ph), Image.LANCZOS)
BIT = [[0x01, 0x08], [0x02, 0x10], [0x04, 0x20], [0x40, 0x80]]
def lum(p): return 0.299*p[0] + 0.587*p[1] + 0.114*p[2]
satirlar = []
for cy in range(0, ph, 4):
    s = ""
    for cx in range(0, pw, 2):
        kod, top, n = 0, [0, 0, 0], 0
        for dy in range(4):
            for dx in range(2):
                p = k.getpixel((cx + dx, cy + dy))
                if lum(p) >= 48:
                    kod |= BIT[dy][dx]; n += 1
                    for i in range(3): top[i] += p[i]
        if not kod: s += " "; continue
        r, g, b = (t // n for t in top)
        s += f"\033[38;2;{r};{g};{b}m" + chr(0x2800 + kod)
    satirlar.append(s.rstrip() + "\033[0m")
satirlar += ["", "\033[38;2;138;139;147m" + "furkan · yıldırım".center(gen).rstrip() + "\033[0m"]
open(hedef, "w").write("\n".join(satirlar) + "\n")
print(gen, len(satirlar))
