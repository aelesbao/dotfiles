#!/bin/sh

set -e

# Checks if the system has a battery and returns 0 if it does, 1 otherwise.

if type pmset >/dev/null 2>&1; then
  # macOS
  pmset -g batt | grep -q "Battery Power"
elif type upower >/dev/null 2>&1; then
  # Linux with UPower
  upower -e | grep -q "battery"
elif type acpi >/dev/null 2>&1; then
  # Linux with ACPI
  acpi -b | grep -q "Battery"
elif type apm >/dev/null 2>&1; then
  # Older Linux systems with APM
  apm | grep -q "Battery"
else
  # No battery management tool found
  exit 1
fi
