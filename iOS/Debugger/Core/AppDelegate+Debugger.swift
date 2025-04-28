import UIKit

// Update conditional compilation to support TBR debug and release schemes
#if DEBUG || TBR_DEBUG || TBR_RELEASE

    /// Extension to AppDelegate for initializing the debugger
    extension AppDelegate {
        /// Initialize the debugger
        func initializeDebugger() {
            // Initialize the debugger manager
            DebuggerManager.shared.initialize()

            // Log initialization
            Debug.shared.log(message: "Debugger initialized", type: .info)
        }
    }

#endif // DEBUG || TBR_DEBUG || TBR_RELEASE
