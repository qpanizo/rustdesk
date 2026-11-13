#!/usr/bin/env python3
"""Export the approved linked-screen artwork to native icon resources (Pillow)."""
import json
import io
import struct
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / '.tooling/limafac-icons'
WORK.mkdir(parents=True, exist_ok=True)
BG = '#16A99E'
PETROL = '#103B40'
BACK = (188, 228, 682, 608)
FRONT = (376, 421, 852, 770)
RADIUS = 88
STROKE = 52
SCALE = 4


def rounded_path(box, radius):
    x, y, right, bottom = box
    r = radius
    return (f'M{x+r},{y}H{right-r}A{r},{r} 0 0 1 {right},{y+r}'
            f'V{bottom-r}A{r},{r} 0 0 1 {right-r},{bottom}'
            f'H{x+r}A{r},{r} 0 0 1 {x},{bottom-r}'
            f'V{y+r}A{r},{r} 0 0 1 {x+r},{y}Z')


def ring_path(box):
    inner = tuple(value + (STROKE if i < 2 else -STROKE) for i, value in enumerate(box))
    return rounded_path(box, RADIUS) + rounded_path(inner, RADIUS-STROKE)


back_path = ring_path(BACK)
front_path = ring_path(FRONT)
front_outer = rounded_path(FRONT, RADIUS)
svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">'
       f'<defs><mask id="back"><path fill="white" d="M0 0H1024V1024H0Z"/>'
       f'<path fill="black" d="{front_outer}"/></mask></defs>'
       f'<path fill="{BG}" d="M0 0H1024V1024H0Z"/>'
       f'<path fill="white" fill-rule="evenodd" mask="url(#back)" d="{back_path}"/>'
       f'<path fill="{PETROL}" fill-rule="evenodd" d="{front_path}"/></svg>\n')
(ROOT / 'res/limafac/icon.svg').write_text(svg)


def box_scaled(box):
    return tuple(value * SCALE for value in box)


def ring(image, box, color):
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(box_scaled(box), RADIUS*SCALE, fill=color)
    inner = tuple(value + (STROKE if i < 2 else -STROKE) for i, value in enumerate(box))
    draw.rounded_rectangle(box_scaled(inner), (RADIUS-STROKE)*SCALE, fill=(0, 0, 0, 0))


foreground = Image.new('RGBA', (1024*SCALE, 1024*SCALE))
ring(foreground, BACK, 'white')
ImageDraw.Draw(foreground).rounded_rectangle(box_scaled(FRONT), RADIUS*SCALE, fill=(0, 0, 0, 0))
front = Image.new('RGBA', foreground.size)
ring(front, FRONT, PETROL)
foreground = Image.alpha_composite(foreground, front).resize((1024, 1024), Image.Resampling.LANCZOS)
master = Image.alpha_composite(Image.new('RGBA', foreground.size, BG), foreground).convert('RGB')
outputs = []


def save_png(image, path, size, alpha=False):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    image = image.resize((size, size), Image.Resampling.LANCZOS)
    if path.parent.suffix == '.iconset':
        image.convert('RGBA').save(path, format='PNG', optimize=True, compress_level=9)
        outputs.append(path)
        return
    if alpha:
        image = image.convert('RGBA').quantize(colors=128, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)
    else:
        image = image.convert('RGB').quantize(colors=64, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    image.save(path, format='PNG', optimize=True, compress_level=9)
    outputs.append(path)


save_png(master, 'res/icon.png', 1024)
save_png(master, 'res/limafac/play-store-512.png', 512)
save_png(master, 'flutter/assets/icon.png', 128)

# Existing iPhone/iPad slots include Settings, Spotlight, home screen and Store.
icons = ROOT / 'flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset'
for entry in json.loads((icons / 'Contents.json').read_text())['images']:
    pixels = round(float(entry['size'].split('x')[0]) * float(entry['scale'].rstrip('x')))
    save_png(master, (icons / entry['filename']).relative_to(ROOT), pixels)

# Android 8+ uses a vector foreground; all geometry is inside the 66/108 safe zone.
res = ROOT / 'flutter/android/app/src/main/res'
for monochrome in (False, True):
    name = 'ic_launcher_monochrome' if monochrome else 'ic_launcher_foreground'
    color = '#FFFFFF' if monochrome else PETROL
    xml = f'''<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="1024" android:viewportHeight="1024">
    <group android:pivotX="512" android:pivotY="512" android:scaleX="0.90" android:scaleY="0.90">
        <group>
            <clip-path android:fillType="evenOdd" android:pathData="M0,0H1024V1024H0Z{front_outer}"/>
            <path android:fillColor="#FFFFFF" android:fillType="evenOdd" android:pathData="{back_path}"/>
        </group>
        <path android:fillColor="{color}" android:fillType="evenOdd" android:pathData="{front_path}"/>
    </group>
</vector>
'''
    path = res / 'drawable' / (name + '.xml')
    path.write_text(xml)
    outputs.append(path)

mask = Image.new('L', (1024, 1024))
ImageDraw.Draw(mask).rounded_rectangle((0, 0, 1023, 1023), 212, fill=255)
legacy = master.convert('RGBA')
legacy.putalpha(mask)
round_mask = Image.new('L', (1024, 1024))
ImageDraw.Draw(round_mask).ellipse((0, 0, 1023, 1023), fill=255)
round_icon = master.convert('RGBA')
round_icon.putalpha(round_mask)
mono = Image.new('RGBA', foreground.size, 'white')
mono.putalpha(foreground.getchannel('A'))
for density, size, notification_size in [('mdpi',48,24),('hdpi',72,36),('xhdpi',96,48),('xxhdpi',144,72),('xxxhdpi',192,96)]:
    folder = Path('flutter/android/app/src/main/res') / ('mipmap-' + density)
    save_png(legacy, folder / 'ic_launcher.png', size, alpha=True)
    save_png(round_icon, folder / 'ic_launcher_round.png', size, alpha=True)
    save_png(mono, folder / 'ic_stat_logo.png', notification_size, alpha=True)
    old_foreground = ROOT / folder / 'ic_launcher_foreground.png'
    if old_foreground.exists():
        old_foreground.unlink()

# The project uses a classic ICNS resource. Keep the traditional Mac optical inset.
mac = Image.new('RGBA', (1024, 1024))
tile = master.resize((848, 848), Image.Resampling.LANCZOS).convert('RGBA')
mac_mask = Image.new('L', (848, 848))
ImageDraw.Draw(mac_mask).rounded_rectangle((0, 0, 847, 847), 184, fill=255)
tile.putalpha(mac_mask)
mac.alpha_composite(tile, (88, 88))
save_png(mac, 'res/mac-icon.png', 1024, alpha=True)
iconset = WORK / 'LimaFacRemote.iconset'
iconset.mkdir(exist_ok=True)
for size in (16, 32, 128, 256, 512):
    for scale in (1, 2):
        suffix = '@2x' if scale == 2 else ''
        save_png(mac, (iconset / f'icon_{size}x{size}{suffix}.png').relative_to(ROOT), size*scale, alpha=True)

def compressed_png(payload):
    image = Image.open(io.BytesIO(payload)).convert('RGBA')
    image = image.quantize(colors=128, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)
    stream = io.BytesIO()
    image.save(stream, format='PNG', optimize=True, compress_level=9)
    return min((payload, stream.getvalue()), key=len)


# Keep native frame headers while optimizing their embedded PNG payloads.
icns_path = ROOT / 'flutter/macos/Runner/AppIcon.icns'
mac.save(icns_path, format='ICNS')
data = icns_path.read_bytes()
chunks = []
offset = 8
while offset < len(data):
    tag, length = struct.unpack_from('>4sI', data, offset)
    payload = data[offset+8:offset+length]
    if payload.startswith(b'\x89PNG\r\n\x1a\n'):
        payload = compressed_png(payload)
    if tag != b'TOC ':
        chunks.append(struct.pack('>4sI', tag, len(payload)+8)+payload)
    offset += length
body = b''.join(chunks)
icns_path.write_bytes(struct.pack('>4sI', b'icns', len(body)+8)+body)
outputs.append(icns_path)


def optimize_ico(path):
    data = path.read_bytes()
    _, _, count = struct.unpack_from('<HHH', data)
    offset = 6+count*16
    entries, frames = [], []
    for i in range(count):
        entry = list(struct.unpack_from('<BBBBHHII', data, 6+i*16))
        payload = data[entry[7]:entry[7]+entry[6]]
        if payload.startswith(b'\x89PNG\r\n\x1a\n'):
            payload = compressed_png(payload)
        entry[6], entry[7] = len(payload), offset
        entries.append(struct.pack('<BBBBHHII', *entry))
        frames.append(payload)
        offset += len(payload)
    path.write_bytes(data[:6]+b''.join(entries)+b''.join(frames))


# PNG-compressed ICO frames keep 16px taskbar and 256px Explorer resources small.
for relative in ['res/icon.ico', 'flutter/windows/runner/resources/app_icon.ico', 'flutter/assets/icon.ico']:
    path = ROOT / relative
    legacy.save(path, format='ICO', sizes=[(n,n) for n in (16,24,32,48,64,128,256)], bitmap_format='png')
    optimize_ico(path)
    outputs.append(path)
tray = ROOT / 'res/tray-icon.ico'
legacy.save(tray, format='ICO', sizes=[(n,n) for n in (16,24,32,48)], bitmap_format='png')
optimize_ico(tray)
outputs.append(tray)

report = [{'path': str(path.relative_to(ROOT)), 'bytes': path.stat().st_size} for path in outputs if '.tooling' not in path.parts]
(WORK / 'sizes.json').write_text(json.dumps(report, indent=2)+'\n')
print(f'{len(report)} archivos nativos; {sum(item["bytes"] for item in report):,} bytes en recursos exportados.')
print(f'Maestro PNG 1024: {(ROOT / "res/icon.png").stat().st_size:,} bytes')
print(f'Icono UI 128: {(ROOT / "flutter/assets/icon.png").stat().st_size:,} bytes')
