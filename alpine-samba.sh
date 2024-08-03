SERVICE_FILE="/etc/init.d/samba-remount"
MOUNT_POINT="/mnt/media"
SERVER="//192.168.0.13/public"
OPTIONS="credentials=guest,noperm,auto,retry=0"

# Create the OpenRC service file
echo "Creating OpenRC service file at $SERVICE_FILE"
tee $SERVICE_FILE > /dev/null <<EOL
#!/sbin/openrc-run

depend() {
    need net
}

start() {
    ebegin "Checking and remounting Samba share if disconnected"

    MOUNT_POINT="$MOUNT_POINT"
    SERVER="$SERVER"
    OPTIONS="$OPTIONS"

    if ! mountpoint -q "\$MOUNT_POINT"; then
        mount -t cifs \$SERVER \$MOUNT_POINT -o \$OPTIONS
        if [ \$? -eq 0 ]; then
            eend 0 "Samba share mounted successfully."
        else
            eend 1 "Failed to mount Samba share."
        fi
    else
        eend 0 "Samba share already mounted."
    fi
}

stop() {
    ebegin "Unmounting Samba share"

    umount $MOUNT_POINT
    eend \$?
}
EOL

# Make the service script executable
echo "Making the service script executable"
chmod +x $SERVICE_FILE

# Add the service to the default runlevel
echo "Adding the service to the default runlevel"
rc-update add samba-remount default

# Create a cron job to run the service every 5 minutes
echo "Creating a cron job to run the service every 5 minutes"
(crontab -l 2>/dev/null; echo "*/5 * * * * /etc/init.d/samba-remount start") | crontab -

echo "Setup complete. The Samba remount service and cron job have been configured."