#!/bin/bash
# On some machines the iBridge USB device (05ac:8600) is enumerated at boot
# without a USB configuration (bConfigurationValue empty, port state
# "addressed"). No HID interfaces appear then and apple-ibridge never binds.
# Unbind/bind the device from the generic usb driver to make it re-configure.
for try in $(seq 1 30); do
  dev=""
  for d in /sys/bus/usb/devices/[0-9]*-[0-9]*; do
    [ -f "$d/idVendor" ] || continue
    if [ "$(cat "$d/idVendor")" = "05ac" ] && [ "$(cat "$d/idProduct")" = "8600" ]; then
      dev=$d; break
    fi
  done
  if [ -z "$dev" ]; then
    sleep 1; continue
  fi
  cfg=$(cat "$dev/bConfigurationValue" 2>/dev/null)
  if [ -n "$cfg" ]; then
    echo "iBridge $(basename "$dev") configured (config=$cfg) after $try tries"
    exit 0
  fi
  name=$(basename "$dev")
  echo "iBridge $name has no configuration, rebinding (try $try)"
  echo "$name" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null
  sleep 1
  echo "$name" > /sys/bus/usb/drivers/usb/bind 2>/dev/null
  sleep 1
  if [ -z "$(cat "$dev/bConfigurationValue" 2>/dev/null)" ]; then
    echo 1 > "$dev/bConfigurationValue" 2>/dev/null
    sleep 1
  fi
done
echo "iBridge still unconfigured after 30 tries" >&2
exit 1
