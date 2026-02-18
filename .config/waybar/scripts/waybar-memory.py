#!/usr/bin/env python3
# ----------------------------------------------------------------------------
# WAYBAR MEMORY MODULE
# ----------------------------------------------------------------------------
# A dynamic memory monitor for Waybar.
# Features:
# - Real-time RAM usage with color-coded states
# - Tooltip with detailed breakdown (Used, Cached, Buffers)
# - Auto-detects memory modules via dmidecode (requires sudo permissions)
# - Temperature monitoring (requires lm_sensors)
# ----------------------------------------------------------------------------

import json
import psutil
import subprocess
import re
import pathlib
import sys

# ---------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------
MEM_ICON = ""
TOOLTIP_WIDTH = 48

# ---------------------------------------------------
# THEME & COLORS
# ---------------------------------------------------
# Attempts to load colors from a TOML theme file.
# Defaults to a standard palette if the file is missing.
try:
    import tomllib
except ImportError:
    tomllib = None

def load_theme_colors():
    # UPDATE THIS PATH to your specific theme file if you have one
    theme_path = pathlib.Path.home() / ".config/waybar/colors.toml"
    
    defaults = {
        "black": "#000000", "red": "#ff0000", "green": "#00ff00", "yellow": "#ffff00",
        "blue": "#0000ff", "magenta": "#ff00ff", "cyan": "#00ffff", "white": "#ffffff",
        "bright_black": "#555555", "bright_red": "#ff5555", "bright_green": "#55ff55",
        "bright_yellow": "#ffff55", "bright_blue": "#5555ff", "bright_magenta": "#ff55ff",
        "bright_cyan": "#55ffff", "bright_white": "#ffffff"
    }

    if not tomllib or not theme_path.exists():
        return defaults

    try:
        data = tomllib.loads(theme_path.read_text())
        colors = data.get("colors", {})
        normal = colors.get("normal", {})
        bright = colors.get("bright", {})
        
        # Merge loaded colors with defaults
        return {**defaults, **normal, **{f"bright_{k}": v for k, v in bright.items()}}
    except Exception:
        return defaults

COLORS = load_theme_colors()

SECTION_COLORS = {
    "Memory":  {"icon": COLORS["green"],  "text": COLORS["green"]},
}

# Color thresholds for metrics
COLOR_TABLE = [
    {"color": COLORS["blue"],           "mem_storage": (0.0, 10), "mem_temp": (0, 40)},
    {"color": COLORS["cyan"],           "mem_storage": (10.0, 20), "mem_temp": (41, 50)},
    {"color": COLORS["green"],          "mem_storage": (20.0, 40), "mem_temp": (51, 60)},
    {"color": COLORS["yellow"],         "mem_storage": (40.0, 60), "mem_temp": (61, 70)},
    {"color": COLORS["bright_yellow"],  "mem_storage": (60.0, 80), "mem_temp": (71, 75)},
    {"color": COLORS["bright_red"],     "mem_storage": (80.0, 90), "mem_temp": (76, 80)},
    {"color": COLORS["red"],            "mem_storage": (90.0,100), "mem_temp": (81, 999)}
]

def get_color(value, metric_type):
    if value is None: return "#ffffff"
    try:
        value = float(value)
    except ValueError: return "#ffffff"
    
    for entry in COLOR_TABLE:
        if metric_type in entry:
            low, high = entry[metric_type]
            if low <= value <= high:
                return entry["color"]
    return COLOR_TABLE[-1]["color"]

# ---------------------------------------------------
# HARDWARE DETECTION
# ---------------------------------------------------
def get_memory_temps():
    """
    Reads memory temperatures from lm_sensors.
    Requires: lm_sensors installed and sensors-detect run.
    """
    temps = []
    try:
        output = subprocess.check_output(["sensors", "-j"], text=True, stderr=subprocess.DEVNULL)
        data = json.loads(output)
        for chip, content in data.items():
            if any(x in chip for x in ["jc42", "spd", "dram"]):
                for feature, subfeatures in content.items():
                    if isinstance(subfeatures, dict):
                        for key, val in subfeatures.items():
                            if "input" in key:
                                temps.append(int(val))
    except Exception:
        pass
    return temps

def get_memory_modules_from_dmidecode():
    """
    Fetches RAM stick details.
    NOTE: Requires sudo permissions for dmidecode without password.
    Add this to sudoers: user ALL=(root) NOPASSWD: /usr/sbin/dmidecode
    """
    detected_modules = []
    real_temps = get_memory_temps()
    try:
        output = subprocess.check_output(["sudo", "/usr/sbin/dmidecode", "--type", "memory"], text=True, stderr=subprocess.PIPE)
        
        current_module = {}
        for line in output.splitlines():
            line = line.strip()
            if line.startswith("Memory Device"):
                if current_module and current_module.get("size") and current_module["size"] != "No Module Installed":
                    detected_modules.append(current_module)
                
                t_val = real_temps[len(detected_modules)] if len(detected_modules) < len(real_temps) else 0
                current_module = {"temp": t_val}
            elif current_module:
                if line.startswith("Locator:"):
                    current_module["label"] = line.split(":", 1)[1].strip()
                elif line.startswith("Size:"):
                    size_str = line.split(":", 1)[1].strip()
                    if "MB" in size_str:
                        try:
                            size_mb = int(size_str.replace("MB", "").strip())
                            if size_mb >= 1024:
                                current_module["size"] = f"{size_mb // 1024} GB"
                            else:
                                current_module["size"] = size_str
                        except ValueError:
                            current_module["size"] = size_str
                    else:
                        current_module["size"] = size_str
                elif line.startswith("Type:"):
                    current_module["type"] = line.split(":", 1)[1].strip()
                elif line.startswith("Speed:"):
                    speed_str = line.split(":", 1)[1].strip()
                    if "MT/s" in speed_str:
                        current_module["speed"] = speed_str.replace("MT/s", "MHz")
                    else:
                        current_module["speed"] = speed_str
        
        if current_module and current_module.get("size") and current_module["size"] != "No Module Installed":
            detected_modules.append(current_module)

    except Exception:
        # Fail silently or return empty if sudo not configured
        return []
    
    return detected_modules

# ---------------------------------------------------
# MAIN LOGIC
# ---------------------------------------------------
mem = psutil.virtual_memory()
mem_used_gb = mem.used / (1024**3)
mem_total_gb = mem.total / (1024**3)
mem_percent = mem.percent
mem_available_gb = mem.available / (1024**3)
mem_cached_gb = mem.cached / (1024**3) if hasattr(mem, 'cached') else 0
mem_buffers_gb = mem.buffers / (1024**3) if hasattr(mem, 'buffers') else 0

tooltip_lines = []

# Header
tooltip_lines.append(
    f"<span foreground='{SECTION_COLORS['Memory']['icon']}'>{MEM_ICON}</span> "
    f"<span foreground='{SECTION_COLORS['Memory']['text']}'>Memory</span>"
)
tooltip_lines.append("─" * TOOLTIP_WIDTH)
tooltip_lines.append(f"󰓅 | Usage: <span foreground='{get_color(mem_percent,'mem_storage')}'>{mem_used_gb:.0f} GB</span> used / {mem_total_gb:.0f} GB Total")

memory_modules = get_memory_modules_from_dmidecode()
max_line_len = TOOLTIP_WIDTH 

# Module Table
if memory_modules:
    rows = []
    for mod in memory_modules:
        t_val = mod.get('temp', 0)
        rows.append({
            "icon": MEM_ICON,
            "label": mod.get("label", "DIMM"),
            "size": mod.get("size", "N/A"),
            "speed": mod.get("speed", "N/A"),
            "type": mod.get("type", "DDR4"),
            "temp_text": f"{t_val}°C",
            "temp_val": t_val
        })

    # Calculate column widths
    w_label = max(len(r["label"]) for r in rows)
    w_size = max(len(r["size"]) for r in rows)
    w_speed = max(len(r["speed"]) for r in rows)
    w_type = max(len(r["type"]) for r in rows)
    w_temp = max(len(r["temp_text"]) for r in rows)

    tooltip_lines.append("")
    for r in rows:
        temp_colored = f"<span foreground='{get_color(r['temp_val'], 'mem_temp')}'>{r['temp_text']:>{w_temp}}</span>"
        line = (
            f"{r['icon']} | "
            f"{r['label']:<{w_label}} | "
            f"{r['size']:<{w_size}} | "
            f"{r['type']:<{w_type}} | "
            f"{r['speed']:<{w_speed}} | "
            f"{temp_colored}"
        )
        tooltip_lines.append(line)

tooltip_lines.append("")

# Calculate max temp for connectors
max_mem_temp = 0
if memory_modules:
    max_mem_temp = max(m.get('temp', 0) for m in memory_modules)

connector_color = get_color(max_mem_temp, 'mem_temp')
frame_color = COLORS['white']

# Calculate percentages
used_pct = (mem.used / mem.total) * 100
cached_pct = (mem.cached / mem.total) * 100 if hasattr(mem, 'cached') else 0
buffers_pct = (mem.buffers / mem.total) * 100 if hasattr(mem, 'buffers') else 0
free_pct = max(0, 100.0 - used_pct - cached_pct - buffers_pct)

# Graphic Dimensions
graph_width = max_line_len - 2
inner_width = graph_width - 4
bar_len = inner_width - 2
padding = " " * int((max_line_len - graph_width) // 2)

def c(text, color):
    return f"<span foreground='{color}'>{text}</span>"

# Line 1
tooltip_lines.append(f"{padding} {c('╭' + '─'*inner_width + '╮', frame_color)}")
# Line 2
tooltip_lines.append(f"{padding}{c('╭╯', frame_color)}{c('░'*inner_width, connector_color)}{c('╰╮', frame_color)}")
# Line 3 (Bar)
c_used = int((used_pct / 100.0) * bar_len)
c_cached = int((cached_pct / 100.0) * bar_len)
c_buffers = int((buffers_pct / 100.0) * bar_len)
c_free = bar_len - c_used - c_cached - c_buffers
if c_free < 0: c_free = 0

bar_str = (
    f"<span foreground='{COLORS['red']}'>{'█' * c_used}</span>"
    f"<span foreground='{COLORS['yellow']}'>{'█' * c_cached}</span>"
    f"<span foreground='{COLORS['cyan']}'>{'█' * c_buffers}</span>"
    f"<span foreground='{COLORS['bright_black']}'>{'█' * c_free}</span>"
)
tooltip_lines.append(f"{padding}{c('╰╮', frame_color)}{c('░', connector_color)}{bar_str}{c('░', connector_color)}{c('╭╯', frame_color)}")
# Line 4
tooltip_lines.append(f"{padding} {c('│', frame_color)}{c('░'*inner_width, connector_color)}{c('│', frame_color)}")
# Line 5
tooltip_lines.append(f"{padding}{c('╭╯', frame_color)}{c('┌' + '┬'*bar_len + '┐', frame_color)}{c('╰╮', frame_color)}")
# Line 6
tooltip_lines.append(f"{padding}{c('└─', frame_color)}{c('┴'*inner_width, frame_color)}{c('─┘', frame_color)}")

tooltip_lines.append("─" * max_line_len)

legend = (
    f"<span size='11000'>"
    f"<span foreground='{COLORS['red']}'>█</span> Used {used_pct:.1f}%  "
    f"<span foreground='{COLORS['yellow']}'>█</span> Cached {cached_pct:.1f}%  "
    f"<span foreground='{COLORS['cyan']}'>█</span> Buffers {buffers_pct:.1f}%  "
    f"<span foreground='{COLORS['bright_black']}'>█</span> Free {free_pct:.1f}%"
    f"</span>"
)
tooltip_lines.append(legend)

print(json.dumps({
    "text": f"{MEM_ICON} <span foreground='{get_color(mem_percent,'mem_storage')}'>{mem_percent}%</span>",
    "tooltip": f"<span size='14000'>{'\n'.join(tooltip_lines)}</span>",
    "markup": "pango",
    "class": "memory",
}))