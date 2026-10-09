# iBridge re-bind at boot

On some MacBook Pro models (seen on a MacBookPro13,2 with Linux 6.8) the
iBridge USB device (`05ac:8600`) is enumerated at boot without a USB
configuration: `bConfigurationValue` in sysfs is empty and the port stays in
the "addressed" state. No HID interfaces appear, so `apple-ibridge` never
probes and the Touch Bar stays dark. Unbinding and re-binding the device from
the generic `usb` driver makes it configure properly.

Install:

    sudo install -m 755 touchbar-rebind.sh /usr/local/sbin/
    sudo install -m 644 touchbar-rebind.service /etc/systemd/system/
    sudo install -m 644 99-touchbar-ibridge.rules /etc/udev/rules.d/
    sudo systemctl daemon-reload
    sudo udevadm control --reload
    sudo systemctl enable --now touchbar-rebind.service

Check with `journalctl -b -u touchbar-rebind.service`.
