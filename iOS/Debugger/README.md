# Enhanced iOS Debugger

This module provides a comprehensive in-app debugging solution for iOS applications, integrating both custom debugging capabilities and FLEX (Flipboard Explorer) functionality.

## Features

### Core Debugging Features
- Runtime debugging with LLDB-like functionality
- Breakpoint management
- Variable inspection
- Memory monitoring
- Performance tracking
- Console output

### FLEX Integration
- Network request monitoring and inspection
- View hierarchy exploration
- Runtime object browser
- File system and database inspection
- User defaults and keychain viewing
- System logs

## Architecture

The debugger consists of several key components:

1. **DebuggerManager**: Central manager class that coordinates all debugging functionality
2. **DebuggerEngine**: Core engine for runtime debugging capabilities
3. **FLEXDebuggerAdapter**: Adapter that integrates FLEX functionality
4. **UI Components**: Various view controllers for different debugging features
5. **FloatingDebuggerButton**: Entry point for accessing the debugger

## Usage

### Initialization

Initialize the debugger in your AppDelegate:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize debugger
    initializeDebugger()
    
    return true
}
```

### Adding FLEX Framework

Add FLEX to your project using CocoaPods or Swift Package Manager:

#### CocoaPods
```ruby
pod 'FLEX', :configurations => ['Debug']
```

#### Swift Package Manager
```swift
.package(url: "https://github.com/FLEXTool/FLEX.git", from: "5.0.0")
```

### Accessing the Debugger

The debugger can be accessed via the floating button that appears on the screen. Tap it to open the debugger interface.

### Using FLEX Tools

FLEX tools can be accessed from the "FLEX Tools" tab in the debugger interface or by tapping the "FLEX" button in the navigation bar.

## Compatibility

- iOS 15.0+
- Compatible with both iPhone and iPad
- Supports both portrait and landscape orientations

## Implementation Details

### Runtime Integration

The debugger uses runtime capabilities to integrate with FLEX without creating a direct dependency. This allows for:

1. Conditional inclusion of FLEX only in debug builds
2. Graceful fallback when FLEX is not available
3. Dynamic loading of FLEX functionality

### Thread Safety

The debugger uses dedicated dispatch queues and thread-safe property access to ensure stability in multi-threaded environments.

### Memory Management

Care has been taken to avoid retain cycles and memory leaks by using weak references and proper cleanup when the debugger is dismissed.

## Customization

The debugger can be customized by modifying the following:

- **FloatingDebuggerButton**: Appearance and position
- **DebuggerViewController**: Available tabs and features
- **FLEXDebuggerAdapter**: FLEX tool integration

## License

This debugger module is part of the main application and is subject to the same license terms.
