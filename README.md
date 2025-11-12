# BatteryManager

A beautiful, native macOS app for monitoring battery health on **Mac computers** and **connected iOS devices** (iPhone/iPad).

## Requirements

- macOS 12.0 or later
- For iOS device monitoring: **libimobiledevice** (installation instructions below)

## Why is this better than coconutBattery?
- Completely free
- Subjectively better design
- Cleaner layout
- Widgets
- 

## Installation

### Install the App

1. Download latest release from GitHub Releases

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

## How It Works

### Mac Battery Monitoring
Uses macOS's `ioreg` command to access the `AppleSmartBattery` service:

```bash
ioreg -rw0 -c AppleSmartBattery
```

Provides comprehensive battery metrics including real-time voltage, current, temperature, capacity, health, and lifetime statistics.

### iOS Device Monitoring
Uses `libimobiledevice` to communicate with iOS devices over USB:
1. Connects through `lockdownd` (device management daemon)
2. Opens a diagnostics session
3. Queries the `AppleSmartBattery` IORegistry on the iOS device
4. Parses battery metrics similar to coconutBattery and 3uTools

This is the same professional method used by commercial tools, in a native macOS app.

## Understanding Battery Health

### Health Percentage
```
Health % = (Current Maximum Capacity / Design Capacity) × 100
```

Example: 2028 mAh / 4382 mAh × 100 = 46.3% health

### Temperature Conversion
IORegistry stores temperatures in hundredths of Kelvin:
```
Temperature (°C) = (Raw Value - 2731.5) / 10
```

### Power Calculation
```
Power (W) = Voltage (V) × Current (A)
```
- Positive = Charging
- Negative = Discharging

### Health Status Ranges
- **Excellent**: 90-100%
- **Good**: 80-90%
- **Fair**: 70-80%
- **Poor**: 50-70%
- **Very Poor**: Below 50%

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
