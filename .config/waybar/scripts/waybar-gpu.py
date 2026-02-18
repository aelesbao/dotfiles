#!/usr/bin/env python3
# ----------------------------------------------------------------------------
# WAYBAR GPU MODULE
# ----------------------------------------------------------------------------
# Visualizes GPU stats including VRAM layout and Die temperature.
# Designed for Nvidia GPUs (uses nvidia-smi).
# ----------------------------------------------------------------------------

import json
import subprocess
import os
import pathlib

# ---------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------
GPU_ICON = "󰢮"
TOOLTIP_WIDTH = 31

# ---------------------------------------------------
# THEME & COLORS
# ---------------------------------------------------
try:
    import tomllib
except ImportError:
    tomllib = None

def load_theme_colors():
    theme_path = pathlib.Path.home() / ".config/waybar/colors.toml"
    defaults = {
        "black": "#000000", "red": "#ff0000", "green": "#00ff00", "yellow": "#ffff00",
        "blue": "#0000ff", "magenta": "#ff00ff", "cyan": "#00ffff", "white": "#ffffff",
        "bright_black": "#555555", "bright_red": "#ff5555", "bright_green": "#55ff55",
        "bright_yellow": "#ffff55", "bright_blue": "#5555ff", "bright_magenta": "#ff55ff",
        "bright_cyan": "#55ffff", "bright_white": "#ffffff"
    }
    if not tomllib or not theme_path.exists(): return defaults
    try:
        data = tomllib.loads(theme_path.read_text())
        colors = data.get("colors", {})
        normal = colors.get("normal", {})
        bright = colors.get("bright", {})
        return {**defaults, **normal, **{f"bright_{k}": v for k, v in bright.items()}}
    except Exception: return defaults

COLORS = load_theme_colors()

COLOR_TABLE = [
    {"color": COLORS["blue"],           "cpu_gpu_temp": (0, 35),   "gpu_power": (0.0, 20)},
    {"color": COLORS["cyan"],           "cpu_gpu_temp": (36, 45),  "gpu_power": (21, 40)},
    {"color": COLORS["green"],          "cpu_gpu_temp": (46, 54),  "gpu_power": (41, 60)},
    {"color": COLORS["yellow"],         "cpu_gpu_temp": (55, 65),  "gpu_power": (61, 75)},
    {"color": COLORS["bright_yellow"],  "cpu_gpu_temp": (66, 75),  "gpu_power": (76, 85)},
    {"color": COLORS["bright_red"],     "cpu_gpu_temp": (76, 85),  "gpu_power": (86, 95)},
    {"color": COLORS["red"],            "cpu_gpu_temp": (86, 999), "gpu_power": (96, 999)}
]

def get_color(value, metric_type):
    try: value = float(value)
    except: return "#ffffff"
    for entry in COLOR_TABLE:
        if metric_type in entry:
            low, high = entry[metric_type]
            if low <= value <= high: return entry["color"]
    return COLOR_TABLE[-1]["color"]

# ---------------------------------------------------
# DATA EXTRACTION
# ---------------------------------------------------
gpu_percent, gpu_temp, gpu_power, fan_speed = 0, 0, 0.0, 0
vram_used, vram_total = 0, 0
gpu_name = "Nvidia GPU"
gpu_tdp = 250.0 # Default fallback

try:
    # Get Name and Power Limit
    info_cmd = ["nvidia-smi", "--query-gpu=name,power.limit", "--format=csv,noheader,nounits"]
    info_out = subprocess.check_output(info_cmd, text=True).strip().split(',')
    if len(info_out) >= 2:
        gpu_name = info_out[0].strip()
        try: gpu_tdp = float(info_out[1].strip())
        except: pass

    # Get Stats
    cmd = ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,power.draw,fan.speed,memory.used,memory.total", "--format=csv,noheader,nounits"]
    output = subprocess.check_output(cmd, text=True).strip()
    m = [x.strip() for x in output.split(",")]
    
    gpu_percent = int(m[0])
    gpu_temp = int(m[1])
    gpu_power = float(m[2])
    fan_speed = int(m[3]) if m[3] != '[N/A]' else 0
    vram_used = int(m[4])
    vram_total = int(m[5])
except Exception:
    pass

vram_pct = (vram_used / vram_total * 100) if vram_total > 0 else 0
pwr_pct = (gpu_power / gpu_tdp * 100) if gpu_tdp > 0 else 0

# ---------------------------------------------------
# GRAPHIC GENERATOR
# ---------------------------------------------------
def get_vram_color(usage, level):
    if usage > (level - 1) * (100 / 6):
        return get_color(usage, 'gpu_power')
    return COLORS["white"]

def get_bar_segment(val, threshold):
    char_map = {80: "███", 60: "▅▅▅", 40: "▃▃▃", 20: "▂▂▂", 0: "───"}
    color = get_color(val, 'gpu_power') if val > threshold else "#555555"
    return f"<span foreground='{color}'>{char_map[threshold]}</span>"

die_temp_color = get_color(gpu_temp, 'cpu_gpu_temp')
f_c = COLORS["white"]
bg = lambda t: f"<span foreground='{die_temp_color}'>{t}</span>"

# VRAM Chips
vc = [get_vram_color(vram_pct, i) for i in range(1, 7)]

# Internal bars
bars = []
for thresh in [80, 60, 40, 20, 0]:
    bars.append(f"{get_bar_segment(gpu_percent, thresh)} {get_bar_segment(pwr_pct, thresh)} {get_bar_segment(fan_speed, thresh)}")

graphic = [
    f"      <span foreground='{f_c}'>╭─────────────────╮</span>",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[5]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░░░░░░░░░░░░░░░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[5]}'>███</span><span foreground='{f_c}'>=</span>",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[4]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░')}  󰓅      󰈐  {bg('░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[4]}'>███</span><span foreground='{f_c}'>=</span>",
    f"      <span foreground='{f_c}'>│</span>{bg('░░')} {bars[0]} {bg('░░')}<span foreground='{f_c}'>│</span>  ",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[3]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░')} {bars[1]} {bg('░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[3]}'>███</span><span foreground='{f_c}'>=</span>",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[2]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░')} {bars[2]} {bg('░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[2]}'>███</span><span foreground='{f_c}'>=</span>",
    f"      <span foreground='{f_c}'>│</span>{bg('░░')} {bars[3]} {bg('░░')}<span foreground='{f_c}'>│</span>  ",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[1]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░')} {bars[4]} {bg('░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[1]}'>███</span><span foreground='{f_c}'>=</span>",
    f" <span foreground='{f_c}'>=</span><span foreground='{vc[0]}'>███</span><span foreground='{f_c}'>=│</span>{bg('░░░░░░░░░░░░░░░░░')}<span foreground='{f_c}'>│=</span><span foreground='{vc[0]}'>███</span><span foreground='{f_c}'>=</span>",
    f"      <span foreground='{f_c}'>╰─────────────────╯</span>"
]

# ---------------------------------------------------
# TOOLTIP
# ---------------------------------------------------
tooltip_lines = []
tooltip_lines.extend([
    f"<span foreground='{COLORS['yellow']}'>{GPU_ICON}</span> <span foreground='{COLORS['yellow']}'>GPU</span> - {gpu_name}",
    "─" * 30,
    f" | Temperature: <span foreground='{die_temp_color}'>{gpu_temp}°C</span>",
    f"󰘚 | V-RAM: <span foreground='{get_color(vram_pct, 'gpu_power')}'>{vram_used} / {vram_total} MB</span>",
    f" | Power: <span foreground='{get_color(pwr_pct, 'gpu_power')}'>{gpu_power:.1f}W</span>",
    f"󰓅 | Utlization: <span foreground='{get_color(gpu_percent, 'gpu_power')}'>{gpu_percent}%</span>",
    f"󰈐 | Fan Speed: <span foreground='{get_color(fan_speed, 'gpu_power')}'>{fan_speed}%</span>",
    "",
    "\n".join(graphic),
    ""
])

tooltip_lines.append("Top GPU Processes:")
try:
    cmd_procs = ["nvidia-smi", "--query-compute-apps=pid,process_name,used_memory", "--format=csv,noheader,nounits"]
    output_procs = subprocess.check_output(cmd_procs, text=True).strip()
    
    procs = []
    if output_procs:
        for line in output_procs.split('\n'):
            parts = [x.strip() for x in line.split(',')]
            if len(parts) >= 3:
                name = os.path.basename(parts[1].replace('\\', '/'))
                try: mem = int(parts[2])
                except: mem = 0
                procs.append({'name': name, 'mem': mem})
    
    procs.sort(key=lambda x: x['mem'], reverse=True)
    for p in procs[:4]:
        name = p['name']
        if len(name) > 12: name = name[:11] + "…"
        mem_p = (p['mem'] / vram_total * 100) if vram_total > 0 else 0
        color = get_color(mem_p, 'gpu_power')
        tooltip_lines.append(f" • {name:<12} <span foreground='{color}'>󰘚 {p['mem']}MB</span>")
except: pass

tooltip_lines.extend([
    "",
    f"<span foreground='{COLORS['white']}'>{'┈' * TOOLTIP_WIDTH}</span>",
    "󰍽 LMB: Btop"
])

click_type = os.environ.get("WAYBAR_CLICK_TYPE")
if click_type == "right":
    # Replace with your preferred control app
    pass 

print(json.dumps({
    "text": f"<span size='16000' rise='-3000'>{GPU_ICON}</span> <span foreground='{die_temp_color}'>{gpu_temp}°C</span>",
    "tooltip": f"<span size='14000'>{"\n".join(tooltip_lines)}</span>",
    "markup": "pango",
    "class": "gpu"
}))
