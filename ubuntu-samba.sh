SERVICE_FILE="/etc/systemd/system/samba-remount.service"
TIMER_FILE="/etc/systemd/system/samba-remount.timer"
MOUNT_POINT="/mnt/share"

# Create systemd service file
echo "Creating systemd service file at $SERVICE_FILE"
tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Remount Samba if disconnected
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/mount -a
ExecStop=/bin/umount $MOUNT_POINT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL

# Create systemd timer file
echo "Creating systemd timer file at $TIMER_FILE"
tee $TIMER_FILE > /dev/null <<EOL
[Unit]
Description=Timer for Samba remount

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOL

# Reload systemd daemon
echo "Reloading systemd daemon"
systemctl daemon-reload

# Enable and start the timer
echo "Enabling and starting the systemd timer"
systemctl enable samba-remount.timer
systemctl start samba-remount.timer

# Status of the timer
echo "Checking the status of the systemd timer"
systemctl status samba-remount.timer

echo "Setup complete. The Samba remount service and timer have been configured."