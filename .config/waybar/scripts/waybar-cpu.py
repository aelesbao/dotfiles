#!/usr/bin/env python3
# ----------------------------------------------------------------------------
# WAYBAR CPU MODULE
# ----------------------------------------------------------------------------
# CPU monitoring script for waybar.
# Features:
# - Per-core usage visualization (Die layout)
# - Power usage (RAPL)
# - Temperature monitoring
# - Top processes consuming CPU
# ----------------------------------------------------------------------------

import json
import psutil
import subprocess
import re
import os
import time
import shutil
import pickle
from collections import deque
import math
import pathlib
import glob

# ---------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------
CPU_ICON_GENERAL = ""
HISTORY_FILE = "/tmp/waybar_cpu_history.pkl"
TOOLTIP_WIDTH = 50

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
SECTION_COLORS = {"CPU": {"icon": COLORS["red"], "text": COLORS["red"]}}

COLOR_TABLE = [
    {"color": COLORS["blue"],           "cpu_gpu_temp": (0, 35),   "cpu_power": (0.0, 30)},
    {"color": COLORS["cyan"],           "cpu_gpu_temp": (36, 45),  "cpu_power": (31.0, 60)},
    {"color": COLORS["green"],          "cpu_gpu_temp": (46, 54),  "cpu_power": (61.0, 90)},
    {"color": COLORS["yellow"],         "cpu_gpu_temp": (55, 65),  "cpu_power": (91.0, 120)},
    {"color": COLORS["bright_yellow"],  "cpu_gpu_temp": (66, 75),  "cpu_power": (121.0,150)},
    {"color": COLORS["bright_red"],     "cpu_gpu_temp": (76, 85),  "cpu_power": (151.0,180)},
    {"color": COLORS["red"],            "cpu_gpu_temp": (86, 999), "cpu_power": (181.0,999)}
]

def get_color(value, metric_type):
    if value is None: return "#ffffff"
    try: value = float(value)
    except ValueError: return "#ffffff"
    for entry in COLOR_TABLE:
        if metric_type in entry:
            low, high = entry[metric_type]
            if low <= value <= high: return entry["color"]
    return COLOR_TABLE[-1]["color"]

# ---------------------------------------------------
# HARDWARE DETECTION
# ---------------------------------------------------
def get_cpu_name():
    try:
        with open("/proc/cpuinfo", "r") as f:
            for line in f:
                if "model name" in line:
                    return line.split(":")[1].strip()
    except:
        pass
    return "Unknown CPU"

def get_rapl_path():
    # Find the energy_uj file for package-0 (CPU)
    base = "/sys/class/powercap"
    if not os.path.exists(base): return None
    
    # Search for intel-rapl or similar directories
    # Usually intel-rapl:0 is the package
    paths = glob.glob(f"{base}/*/energy_uj")
    for p in paths:
        if "intel-rapl:0" in p or "package" in p:
            return p
    # Fallback to first found
    return paths[0] if paths else None

# ---------------------------------------------------
# HISTORY
# ---------------------------------------------------
def load_history():
    try:
        with open(HISTORY_FILE, 'rb') as f:
            return pickle.load(f)
    except:
        return {'cpu': deque(maxlen=TOOLTIP_WIDTH), 'per_core': {}}

def save_history(cpu_hist, per_core_hist):
    try:
        with open(HISTORY_FILE, 'wb') as f:
            pickle.dump({'cpu': cpu_hist, 'per_core': per_core_hist}, f)
    except: pass

# ---------------------------------------------------
# MAIN LOGIC
# ---------------------------------------------------
history = load_history()
cpu_history = history.get('cpu', deque(maxlen=TOOLTIP_WIDTH))
per_core_history = history.get('per_core', {})

cpu_name = get_cpu_name()
max_cpu_temp = 0

# Temperature
try:
    temps = psutil.sensors_temperatures() or {}
    # Try common labels
    for label in ["k10temp", "coretemp", "zenpower"]:
        if label in temps:
            for t in temps[label]:
                if t.current > max_cpu_temp:
                    max_cpu_temp = int(t.current)
except: pass

# Frequency
current_freq = max_freq = 0
try:
    cpu_info = psutil.cpu_freq(percpu=False)
    if cpu_info:
        current_freq = cpu_info.current or 0
        max_freq = cpu_info.max or 0
except: pass

# Power (RAPL)
cpu_power = 0.0
rapl_path = get_rapl_path()
if rapl_path:
    try:
        with open(rapl_path, "r") as f: energy1 = int(f.read().strip())
        time.sleep(0.05)
        with open(rapl_path, "r") as f: energy2 = int(f.read().strip())
        
        delta = energy2 - energy1
        # Handle overflow
        if delta < 0: 
            # Try to find max range
            max_f = os.path.join(os.path.dirname(rapl_path), "max_energy_range_uj")
            if os.path.exists(max_f):
                with open(max_f, "r") as f: max_e = int(f.read().strip())
                delta = (max_e + energy2) - energy1
            else:
                delta = (2**32 + energy2) - energy1
                
        cpu_power = (delta / 1_000_000) / 0.05
    except: pass

cpu_percent = psutil.cpu_percent(interval=0.1)
cpu_history.append(cpu_percent)

# Per Core
per_core = psutil.cpu_percent(interval=0.1, percpu=True)
decay_factor = 0.95
for i, usage in enumerate(per_core):
    if i not in per_core_history:
        per_core_history[i] = usage
    else:
        per_core_history[i] = (per_core_history[i] * decay_factor) + (usage * (1 - decay_factor))

def get_core_color(usage):
    if usage < 20: return "#81c8be"
    elif usage < 40: return "#a6d189"
    elif usage < 60: return "#e5c890"
    elif usage < 80: return "#ef9f76"
    elif usage < 95: return "#ea999c"
    else: return "#e78284"

# ---------------------------------------------------
# TOOLTIP
# ---------------------------------------------------
tooltip_lines = []

tooltip_lines.append(
    f"<span foreground='{SECTION_COLORS['CPU']['icon']}'>{CPU_ICON_GENERAL}</span> "
    f"<span foreground='{SECTION_COLORS['CPU']['text']}'>CPU</span> - {cpu_name}"
)

cpu_rows = [
    ("󱎫", f"Clock Speed: <span foreground='{get_color((current_freq/max_freq*100) if max_freq > 0 else 0, 'cpu_power')}'>{current_freq/1000:.2f} GHz</span> / {max_freq/1000:.2f} GHz"),
    ("", f"Temperature: <span foreground='{get_color(max_cpu_temp,'cpu_gpu_temp')}'>{max_cpu_temp}°C</span>"),
    ("", f"Power: <span foreground='{get_color(cpu_power,'cpu_power')}'>{cpu_power:.1f} W</span>"),
    ("󰓅", f"Utilization: <span foreground='{get_color(cpu_percent,'cpu_power')}'>{cpu_percent:.0f}%</span>")
]

max_line_len = max(len(re.sub(r'<.*?>','',line_text)) for _, line_text in cpu_rows) + 5
max_line_len = max(max_line_len, 29)
tooltip_lines.append("─" * max_line_len)
for icon, text_row in cpu_rows:
    tooltip_lines.append(f"{icon} | {text_row}")

# CPU Die Visualization
cpu_viz_width = 25
center_padding = " " * int((max_line_len - cpu_viz_width) // 2)
substrate_color = get_color(max_cpu_temp, 'cpu_gpu_temp')
border_color = COLORS['white']

tooltip_lines.append("")
tooltip_lines.append(f"{center_padding}  <span foreground='{border_color}'>╭──┘└────┘⠿└─────┘└─╮</span>")
tooltip_lines.append(f"{center_padding}  <span foreground='{border_color}'>┘</span><span foreground='{substrate_color}'>░░░░░░░░░░░░░░░░░░░</span><span foreground='{border_color}'>└</span>")

# Grid layout for cores (adjust rows/cols based on core count if needed, fixed 6x4 here)
row_patterns = [("┐", "┌"), ("│", "│"), ("┘", "└")] * 2
for row in range(6):
    start_char, end_char = row_patterns[row]
    line_parts = [f"{center_padding}  <span foreground='{border_color}'>{start_char}</span><span foreground='{substrate_color}'>░░</span>"]
    for col in range(4):
        core_idx = row * 4 + col
        if core_idx < len(per_core):
            usage = per_core[core_idx]
            color = get_core_color(usage)
            circle = "●" if usage >= 10 else "○"
            line_parts.append(f"<span foreground='{border_color}'>[</span><span foreground='{color}'>{circle}</span><span foreground='{border_color}'>]</span>")
        else:
            line_parts.append(f"<span foreground='{substrate_color}'>░░░</span>")
        if col < 3: line_parts.append(f"<span foreground='{substrate_color}'>░</span>")
    line_parts.append(f"<span foreground='{substrate_color}'>░░</span><span foreground='{border_color}'>{end_char}</span>")
    tooltip_lines.append("".join(line_parts))

tooltip_lines.append(f"{center_padding}  <span foreground='{border_color}'>┐</span><span foreground='{substrate_color}'>░░░░░░░░░░░░░░░░░░░</span><span foreground='{border_color}'>┌</span>")
tooltip_lines.append(f"{center_padding}  <span foreground='{border_color}'>╰──┐┌────┐⣶┌─────┐┌─╯</span>")

# Top Processes
tooltip_lines.append("")
tooltip_lines.append("Top Current Processes:")
try:
    ps_cmd = ["ps", "-eo", "pcpu,comm,args", "--sort=-pcpu", "--no-headers"]
    ps_output = subprocess.check_output(ps_cmd, text=True).strip()
    count = 0
    for line in ps_output.split('\n'):
        if count >= 3: break
        parts = line.strip().split(maxsplit=2)
        if len(parts) >= 2:
            try:
                usage = float(parts[0])
                name = parts[1]
                if "waybar" in parts[2] if len(parts)>2 else "": continue
                if len(name) > 15: name = name[:14] + "…"
                color = get_core_color(usage)
                tooltip_lines.append(f" • {name:<15} <span foreground='{color}'> {usage:>5.1f}%</span>")
                count += 1
            except: continue
except: pass

tooltip_lines.append("")
tooltip_lines.append(f"<span foreground='{COLORS['white']}'>{'┈' * max_line_len}</span>")
tooltip_lines.append("󰍽 LMB: Btop")

save_history(cpu_history, per_core_history)

TERMINAL = os.environ.get("TERMINAL") or shutil.which("alacritty") or "xterm"
if os.environ.get("WAYBAR_CLICK_TYPE") == "left":
    subprocess.Popen([TERMINAL, "-e", "btop"])

print(json.dumps({
    "text": f"{CPU_ICON_GENERAL} <span foreground='{get_color(max_cpu_temp,'cpu_gpu_temp')}'>{max_cpu_temp}°C</span>",
    "tooltip": f"<span size='14000'>{'\n'.join(tooltip_lines)}</span>",
    "markup": "pango",
    "class": "cpu",
    "click-events": True
}))
