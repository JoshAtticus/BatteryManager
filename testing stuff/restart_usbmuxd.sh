#!/bin/bash

# Script to restart usbmuxd service to fix iOS device detection issues
# This often resolves "No Device Found" errors with libimobiledevice

echo "Restarting usbmuxd service..."

# Stop the service
sudo launchctl stop com.apple.usbmuxd

# Wait a moment
sleep 1

# Start the service (it auto-starts on demand)
echo "usbmuxd service has been restarted."
echo "Please reconnect your iOS device."
echo ""
echo "You may need to:"
echo "1. Unplug your device"
echo "2. Plug it back in"
echo "3. Unlock it and tap 'Trust' if prompted"
