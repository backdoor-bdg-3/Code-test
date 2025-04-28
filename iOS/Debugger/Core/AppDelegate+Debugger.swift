import UIKit

/// Extension for AppDelegate to initialize the debugger
extension AppDelegate {
    /// Initialize the debugger
    func initializeDebugger() {
        // Initialize the debugger manager
        DebuggerManager.shared.initialize()
        
        // Log initialization
        Debug.shared.log(message: "Debugger initialized", type: .info)
    }
    
    /// Add FLEX framework to the project
    /// This method should be called in the Podfile or SPM dependencies
    /// Example for Podfile:
    /// ```
    /// pod 'FLEX', :configurations => ['Debug']
    /// ```
    /// 
    /// Example for SPM:
    /// ```
    /// .package(url: "https://github.com/FLEXTool/FLEX.git", from: "5.0.0")
    /// ```
    func addFLEXFramework() {
        // This is just a placeholder method to document how to add FLEX to the project
        // The actual integration happens through CocoaPods or Swift Package Manager
        Debug.shared.log(message: "FLEX framework should be added via CocoaPods or SPM", type: .info)
    }
}
