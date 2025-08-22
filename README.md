# Confirm - macOS Command Line Confirmation Dialog

A Swift command line utility that displays native macOS confirmation dialogs with optional Touch ID/password authentication. Perfect for scripts that need user confirmation before executing critical operations.

## Features

- 🔐 **Authentication Support**: Optional Touch ID or password authentication
- 🖼️ **Custom Icons**: Support for custom dialog icons
- 🎯 **Focused Display**: Dialogs appear in front of other windows
- 📝 **Custom Messages**: Full control over dialog text
- 🔄 **Exit Codes**: Returns proper exit codes for scripting
- 🍎 **Native macOS**: Uses native Cocoa APIs for authentic look and feel

## Requirements

- macOS 10.14 or later
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.0 or later

## Usage

### Basic Confirmation
```bash
swift confirm.swift "Do you want to proceed?"
```

### With Authentication
```bash
swift confirm.swift --auth "Delete important files?"
```

### With Custom Icon
```bash
swift confirm.swift --icon /path/to/icon.png "Custom dialog"
```

### Full Example
```bash
swift confirm.swift --auth --icon /Applications/Trash.app/Contents/Resources/FullTrashIcon.icns "Empty trash permanently?"
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `--auth` | Require Touch ID or password authentication |
| `--icon <path>` | Path to custom icon file (PNG, ICNS, etc.) |
| `--help` | Show usage information |

## Exit Codes

- `0`: User accepted (clicked "Accept" or authenticated successfully)
- `1`: User declined (clicked "Decline" or authentication failed)

## Usage in Scripts

### Shell Script Example
```bash
#!/bin/bash

if swift confirm.swift "Delete all log files?"; then
    echo "Deleting log files..."
    rm -f /var/log/*.log
    echo "Done!"
else
    echo "Operation cancelled."
fi
```

### With Authentication
```bash
#!/bin/bash

if swift confirm.swift --auth "Install system update?"; then
    echo "Installing update..."
    sudo softwareupdate -i -a
else
    echo "Update cancelled."
fi
```

### Advanced Script Usage
```bash
#!/bin/bash

# Function to confirm dangerous operations
confirm_dangerous() {
    local message="$1"
    local icon="${2:-/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns}"
    
    swift confirm.swift --auth --icon "$icon" "$message"
}

# Usage
if confirm_dangerous "Format disk /dev/disk2?"; then
    echo "Formatting disk..."
    # diskutil eraseDisk JHFS+ "Backup" /dev/disk2
else
    echo "Format cancelled."
fi
```

## Authentication Modes

When using `--auth`, the utility will:

1. **Touch ID First**: If available, prompt for Touch ID
2. **Password Fallback**: If Touch ID fails or unavailable, fall back to system password
3. **No Dialog**: Authentication replaces the confirmation dialog entirely

## Icon Support

Supported icon formats:
- PNG
- ICNS (macOS icon files)
- JPEG
- TIFF
- GIF

Common system icon locations:
```bash
# Alert icons
/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns
/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertCautionIcon.icns

# Application icons
/Applications/AppName.app/Contents/Resources/AppIcon.icns

# Custom icons
~/Desktop/my-icon.png
```

## Integration Examples

### Git Hooks
```bash
#!/bin/bash
# pre-push hook
if swift confirm.swift "Push to production branch?"; then
    exit 0
else
    echo "Push cancelled by user"
    exit 1
fi
```

### Deployment Scripts
```bash
#!/bin/bash
ENVIRONMENT="${1:-staging}"

if [[ "$ENVIRONMENT" == "production" ]]; then
    if ! swift confirm.swift --auth "Deploy to PRODUCTION?"; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

echo "Deploying to $ENVIRONMENT..."
```

### System Maintenance
```bash
#!/bin/bash
# Weekly maintenance script

if swift confirm.swift --icon /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarInfo.icns "Run weekly maintenance tasks?"; then
    echo "Running maintenance..."
    
    # Clean caches
    sudo periodic daily weekly monthly
    
    # Update Homebrew
    brew update && brew upgrade
    
    echo "Maintenance complete!"
fi
```

## Troubleshooting

### Dialog Not Appearing
- Ensure your terminal has accessibility permissions
- Try running from Terminal.app instead of other terminal emulators
- Check that the process isn't running in the background

### Authentication Not Working
- Verify Touch ID is set up in System Preferences
- Ensure the app has permission to use Touch ID
- Try running with `--auth` flag to test authentication

### Swift Not Found
```bash
# Install Xcode Command Line Tools if Swift is not found:
xcode-select --install

# Verify Swift installation:
swift --version
```

### Icon Not Loading
- Verify the icon file exists and is readable
- Use absolute paths for icon files
- Supported formats: PNG, ICNS, JPEG, TIFF, GIF

## License

MIT License - feel free to use in your projects.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Changelog

### v1.0.0
- Initial release
- Basic confirmation dialogs
- Touch ID/password authentication
- Custom icon support
- Proper exit codes