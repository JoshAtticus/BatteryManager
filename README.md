# BatteryManager

A beautiful, native macOS app for monitoring battery health on **Mac computers** and **connected iOS devices** (iPhone/iPad).

## Requirements

- macOS 12.4 or later
- For iOS device monitoring: **libimobiledevice** (installation instructions below)

## Installation
### Get the latest release from [here](https://github.com/JoshAtticus/BatteryManager/releases/latest)

### Install libimobiledevice (for iOS Device features)

To read battery information from connected iPhones and iPads:

```bash
# Install Homebrew if you haven't already
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install libimobiledevice
brew install libimobiledevice
```

Verify installation:
```bash
which ideviceinfo
# Should output: /opt/homebrew/bin/ideviceinfo (or similar)
```
## Why is this better than coconutBattery?
- Completely free
- Subjectively better design
- Cleaner layout
- Smaller size, less RAM usage

### Troubleshooting iOS Device Connection

If your iOS device is not detected:

1. **Ensure libimobiledevice is installed**:
   ```bash
   brew install libimobiledevice
   ```

2. **Check if your device is detected**:
   ```bash
   idevice_id -l
   ```
   This should show your device's UDID.

3. **Verify trust status**:
   - Unlock your iOS device
   - When "Trust This Computer?" appears, tap "Trust"
   - Disconnect and reconnect if necessary

4. **Test manually**:
   ```bash
   # Check basic device info
   ideviceinfo
   
   # Check battery info
   idevicediagnostics ioreg AppleSmartBattery
   ```
Please open a GitHub Issue once you've completed all of these steps and it still doesn't work

## Known Limitations

- iOS device monitoring requires device to be unlocked and trusted
- Cannot monitor iOS devices wirelessly (Apple limitation)
- App Store distribution cannot include iOS features (uses private APIs via libimobiledevice and will never happen because it's expensive)

## Credits

Built with SwiftUI for macOS.

Inspired by coconutBattery

Uses [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) for iOS device communication.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.
