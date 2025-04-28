import UIKit

/// Adapter class that integrates FLEX debugging capabilities with the app's debugger
/// This class serves as a bridge between DebuggerManager and FLEX functionality
public final class FLEXDebuggerAdapter {
    // MARK: - Singleton
    
    /// Shared instance of the FLEX debugger adapter
    public static let shared = FLEXDebuggerAdapter()
    
    // MARK: - Properties
    
    /// Logger for debugger operations
    private let logger = Debug.shared
    
    /// Flag indicating if FLEX is available
    private var isFLEXAvailable: Bool {
        // Check if FLEX classes are available at runtime
        return NSClassFromString("FLEXManager") != nil
    }
    
    /// Flag indicating if FLEX is initialized
    private var isFLEXInitialized = false
    
    // MARK: - Initialization
    
    private init() {
        logger.log(message: "FLEXDebuggerAdapter initialized", type: .info)
    }
    
    // MARK: - Public Methods
    
    /// Initialize FLEX debugging capabilities
    public func initialize() {
        guard !isFLEXInitialized else { return }
        
        if isFLEXAvailable {
            // Initialize FLEX using runtime capabilities to avoid direct dependency
            initializeFLEX()
            isFLEXInitialized = true
            logger.log(message: "FLEX debugging capabilities initialized", type: .info)
        } else {
            logger.log(message: "FLEX framework not available", type: .warning)
        }
    }
    
    /// Show the FLEX explorer
    public func showExplorer() {
        guard isFLEXInitialized, isFLEXAvailable else {
            logger.log(message: "FLEX not available or not initialized", type: .warning)
            return
        }
        
        // Show FLEX explorer using runtime capabilities
        performFLEXSelector("showExplorer")
        logger.log(message: "FLEX explorer shown", type: .info)
    }
    
    /// Hide the FLEX explorer
    public func hideExplorer() {
        guard isFLEXInitialized, isFLEXAvailable else { return }
        
        // Hide FLEX explorer using runtime capabilities
        performFLEXSelector("hideExplorer")
        logger.log(message: "FLEX explorer hidden", type: .info)
    }
    
    /// Toggle the FLEX explorer visibility
    public func toggleExplorer() {
        guard isFLEXInitialized, isFLEXAvailable else {
            logger.log(message: "FLEX not available or not initialized", type: .warning)
            return
        }
        
        // Toggle FLEX explorer using runtime capabilities
        performFLEXSelector("toggleExplorer")
        logger.log(message: "FLEX explorer toggled", type: .info)
    }
    
    /// Present a specific FLEX tool
    /// - Parameters:
    ///   - toolName: The name of the tool to present
    ///   - completion: Completion handler called when the tool is presented
    public func presentTool(_ toolName: FLEXDebuggerTool, completion: (() -> Void)? = nil) {
        guard isFLEXInitialized, isFLEXAvailable else {
            logger.log(message: "FLEX not available or not initialized", type: .warning)
            completion?()
            return
        }
        
        // Present the specified tool
        switch toolName {
        case .networkMonitor:
            presentNetworkMonitor(completion: completion)
        case .viewHierarchy:
            presentViewHierarchy(completion: completion)
        case .systemLog:
            presentSystemLog(completion: completion)
        case .fileBrowser:
            presentFileBrowser(completion: completion)
        case .databaseBrowser:
            presentDatabaseBrowser(completion: completion)
        case .runtimeBrowser:
            presentRuntimeBrowser(completion: completion)
        case .userDefaults:
            presentUserDefaults(completion: completion)
        case .keychain:
            presentKeychain(completion: completion)
        }
    }
    
    /// Enable network monitoring
    public func enableNetworkMonitoring() {
        guard isFLEXInitialized, isFLEXAvailable else {
            logger.log(message: "FLEX not available or not initialized", type: .warning)
            return
        }
        
        // Enable network monitoring using runtime capabilities
        if let flexNetworkObserverClass = NSClassFromString("FLEXNetworkObserver") {
            _ = performClassSelector(flexNetworkObserverClass, selector: "start")
            logger.log(message: "FLEX network monitoring enabled", type: .info)
        }
    }
    
    /// Disable network monitoring
    public func disableNetworkMonitoring() {
        guard isFLEXInitialized, isFLEXAvailable else { return }
        
        // Disable network monitoring using runtime capabilities
        if let flexNetworkObserverClass = NSClassFromString("FLEXNetworkObserver") {
            _ = performClassSelector(flexNetworkObserverClass, selector: "stop")
            logger.log(message: "FLEX network monitoring disabled", type: .info)
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeFLEX() {
        // Initialize FLEX using runtime capabilities
        // This avoids direct dependency on FLEX
        
        // Register default SQLite database password if needed
        if let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
           let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") {
            
            // Set default SQLite database password if needed
            // This is optional and can be customized based on app requirements
            
            // Enable network monitoring by default
            enableNetworkMonitoring()
        }
    }
    
    private func performFLEXSelector(_ selectorName: String, withObject object: Any? = nil) -> Any? {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            return nil
        }
        
        let selector = NSSelectorFromString(selectorName)
        return perform(selector: selector, on: sharedManager, with: object)
    }
    
    private func performClassSelector(_ class: AnyClass, selector: String) -> Any? {
        let sel = NSSelectorFromString(selector)
        return perform(selector: sel, on: `class`, with: nil)
    }
    
    private func perform(selector: Selector, on target: Any, with object: Any?) -> Any? {
        var methodImplementation: IMP? = nil
        
        if let targetClass = target as? AnyClass {
            // Class method
            methodImplementation = class_getMethodImplementation(targetClass, selector)
        } else {
            // Instance method
            methodImplementation = class_getMethodImplementation(type(of: target as AnyObject), selector)
        }
        
        guard let implementation = methodImplementation else {
            return nil
        }
        
        typealias FunctionType = @convention(c) (Any, Selector, Any?) -> Any?
        let function = unsafeBitCast(implementation, to: FunctionType.self)
        
        return function(target, selector, object)
    }
    
    // MARK: - Tool Presentation Methods
    
    private func presentNetworkMonitor(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a network history view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let networkClass = NSClassFromString("FLEXNetworkMITMViewController") as! UIViewController.Type
            let networkVC = networkClass.init()
            return UINavigationController(rootViewController: networkVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentViewHierarchy(completion: (() -> Void)? = nil) {
        performFLEXSelector("toggleExplorer")
        completion?()
    }
    
    private func presentSystemLog(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a system log view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let logClass = NSClassFromString("FLEXSystemLogViewController") as! UIViewController.Type
            let logVC = logClass.init()
            return UINavigationController(rootViewController: logVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentFileBrowser(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a file browser view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let fileClass = NSClassFromString("FLEXFileBrowserController") as! UIViewController.Type
            let fileVC = fileClass.init()
            return UINavigationController(rootViewController: fileVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentDatabaseBrowser(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a database browser view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let dbClass = NSClassFromString("FLEXSQLiteDatabaseManager") as! UIViewController.Type
            let dbVC = dbClass.init()
            return UINavigationController(rootViewController: dbVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentRuntimeBrowser(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a runtime browser view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let runtimeClass = NSClassFromString("FLEXRuntimeBrowserController") as! UIViewController.Type
            let runtimeVC = runtimeClass.init()
            return UINavigationController(rootViewController: runtimeVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentUserDefaults(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a user defaults view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let userDefaultsClass = NSClassFromString("FLEXUserDefaultsExplorerViewController") as! UIViewController.Type
            let userDefaultsVC = userDefaultsClass.init()
            return UINavigationController(rootViewController: userDefaultsVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
    
    private func presentKeychain(completion: (() -> Void)? = nil) {
        guard let flexManagerClass = NSClassFromString("FLEXManager") as AnyClass?,
              let sharedManager = performClassSelector(flexManagerClass, selector: "sharedManager") else {
            completion?()
            return
        }
        
        // Create a block that returns a keychain view controller
        let viewControllerBlock: @convention(block) () -> UINavigationController = {
            let keychainClass = NSClassFromString("FLEXKeychainViewController") as! UIViewController.Type
            let keychainVC = keychainClass.init()
            return UINavigationController(rootViewController: keychainVC)
        }
        
        // Convert Swift closure to Objective-C block
        let blockObject = unsafeBitCast(viewControllerBlock, to: AnyObject.self)
        
        // Present the tool
        let presentToolSelector = NSSelectorFromString("presentTool:completion:")
        _ = perform(selector: presentToolSelector, on: sharedManager, with: blockObject)
        
        completion?()
    }
}

/// Enum representing available FLEX debugging tools
public enum FLEXDebuggerTool {
    case networkMonitor
    case viewHierarchy
    case systemLog
    case fileBrowser
    case databaseBrowser
    case runtimeBrowser
    case userDefaults
    case keychain
}
