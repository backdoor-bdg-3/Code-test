import UIKit

/// Manager class for the runtime debugger
/// Handles the floating button and debugger UI
public final class DebuggerManager {
    // MARK: - Singleton

    /// Shared instance of the debugger manager
    public static let shared = DebuggerManager()

    // MARK: - Properties

    /// Logger for debugger operations
    private let logger = Debug.shared

    /// The floating debugger button
    private let floatingButton = FloatingDebuggerButton()

    /// The debugger engine
    private let debuggerEngine = DebuggerEngine.shared
    
    /// The FLEX debugger adapter
    private let flexAdapter = FLEXDebuggerAdapter.shared

    /// Current debugger view controller
    private weak var debuggerViewController: DebuggerViewController?

    /// Thread-safe state tracking with a dedicated queue
    private let stateQueue = DispatchQueue(label: "com.debugger.manager.state", qos: .userInteractive)
    private var _isDebuggerVisible = false
    private var isDebuggerVisible: Bool {
        get { stateQueue.sync { _isDebuggerVisible } }
        set { stateQueue.sync { _isDebuggerVisible = newValue } }
    }

    /// Thread-safe setup state
    private var _isSetUp = false
    private var isSetUp: Bool {
        get { stateQueue.sync { _isSetUp } }
        set { stateQueue.sync { _isSetUp = newValue } }
    }

    /// Weak references to parent views
    private weak var parentViewController: UIViewController?

    // MARK: - Initialization

    private init() {
        setupObservers()
        logger.log(message: "DebuggerManager initialized", type: .info)
    }

    // MARK: - Public Methods

    /// Initialize the debugger
    /// This should be called from the AppDelegate
    public func initialize() {
        logger.log(message: "Initializing debugger", type: .info)

        // Initialize FLEX adapter
        flexAdapter.initialize()
        
        // Enable network monitoring by default
        flexAdapter.enableNetworkMonitoring()

        // Show the floating button
        DispatchQueue.main.async { [weak self] in
            self?.showFloatingButton()
        }
    }

    /// Show the debugger UI
    public func showDebugger() {
        guard !isDebuggerVisible else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Find the top view controller to present the debugger
            guard let topVC = UIApplication.shared.topMostViewController() else {
                self.logger.log(message: "No view controller to present debugger", type: .error)
                return
            }

            // Create the debugger view controller
            let debuggerVC = DebuggerViewController()
            debuggerVC.delegate = self

            // Wrap in navigation controller
            let navController = UINavigationController(rootViewController: debuggerVC)

            // Configure presentation style
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad-specific presentation
                navController.modalPresentationStyle = .formSheet
                navController.preferredContentSize = CGSize(width: 700, height: 800)
            } else {
                // iPhone presentation
                if #available(iOS 15.0, *) {
                    if let sheet = navController.sheetPresentationController {
                        // Use sheet presentation for iOS 15+
                        sheet.detents = [.large()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24
                    }
                } else {
                    // Fallback for older iOS versions
                    navController.modalPresentationStyle = .fullScreen
                }
            }

            // Present the debugger
            topVC.present(navController, animated: true) {
                self.isDebuggerVisible = true
                self.debuggerViewController = debuggerVC
                self.logger.log(message: "Debugger presented", type: .info)
            }
        }
    }

    /// Hide the debugger UI
    public func hideDebugger() {
        guard isDebuggerVisible, let debuggerVC = debuggerViewController else { return }

        DispatchQueue.main.async {
            debuggerVC.dismiss(animated: true) {
                self.isDebuggerVisible = false
                self.logger.log(message: "Debugger dismissed", type: .info)
            }
        }
    }

    /// Show the floating button
    public func showFloatingButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Find the top view controller to add the button
            guard let topVC = UIApplication.shared.topMostViewController() else {
                self.logger.log(message: "No view controller to add floating button", type: .error)
                return
            }

            // Remove from current superview
            self.floatingButton.removeFromSuperview()

            // Add to the top view controller's view
            topVC.view.addSubview(self.floatingButton)

            self.logger.log(message: "Floating debugger button added", type: .info)
        }
    }

    /// Hide the floating button
    public func hideFloatingButton() {
        DispatchQueue.main.async { [weak self] in
            self?.floatingButton.removeFromSuperview()
            self?.logger.log(message: "Floating debugger button removed", type: .info)
        }
    }
    
    /// Show the FLEX explorer directly
    public func showFLEXExplorer() {
        flexAdapter.showExplorer()
    }
    
    /// Hide the FLEX explorer
    public func hideFLEXExplorer() {
        flexAdapter.hideExplorer()
    }
    
    /// Toggle the FLEX explorer visibility
    public func toggleFLEXExplorer() {
        flexAdapter.toggleExplorer()
    }
    
    /// Present a specific FLEX debugging tool
    /// - Parameters:
    ///   - tool: The tool to present
    ///   - completion: Completion handler called when the tool is presented
    public func presentFLEXTool(_ tool: FLEXDebuggerTool, completion: (() -> Void)? = nil) {
        flexAdapter.presentTool(tool, completion: completion)
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Listen for button taps
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowDebugger),
            name: .showDebugger,
            object: nil
        )

        // Listen for show/hide button notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowFloatingButton),
            name: .showDebuggerButton,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideFloatingButton),
            name: .hideDebuggerButton,
            object: nil
        )

        // Listen for orientation changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        // Listen for app lifecycle events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func handleShowDebugger() {
        showDebugger()
    }

    @objc private func handleShowFloatingButton() {
        showFloatingButton()
    }

    @objc private func handleHideFloatingButton() {
        hideFloatingButton()
    }

    @objc private func handleOrientationChange() {
        // Ensure the floating button is still visible after orientation change
        if floatingButton.superview != nil {
            DispatchQueue.main.async { [weak self] in
                self?.showFloatingButton()
            }
        }
    }

    @objc private func handleAppDidBecomeActive() {
        // Show the floating button when app becomes active
        if !isDebuggerVisible {
            DispatchQueue.main.async { [weak self] in
                self?.showFloatingButton()
            }
        }
    }

    @objc private func handleAppWillResignActive() {
        // No need to do anything when app resigns active
    }
}

// MARK: - DebuggerViewControllerDelegate

extension DebuggerManager: DebuggerViewControllerDelegate {
    func debuggerViewControllerDidRequestDismissal(_: DebuggerViewController) {
        hideDebugger()
    }
    
    func debuggerViewControllerDidRequestFLEXTool(_ viewController: DebuggerViewController, tool: FLEXDebuggerTool) {
        presentFLEXTool(tool) {
            // Optional: Handle completion if needed
        }
    }
}

// MARK: - UIApplication Extension

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        guard let keyWindow = keyWindow else { return nil }
        return findTopViewController(keyWindow.rootViewController)
    }
    
    private func findTopViewController(_ controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else { return nil }
        
        if let presentedController = controller.presentedViewController {
            return findTopViewController(presentedController)
        }

        if let navigationController = controller as? UINavigationController {
            if let topController = navigationController.topViewController {
                return findTopViewController(topController)
            }
            return navigationController
        }

        if let tabController = controller as? UITabBarController {
            if let selectedController = tabController.selectedViewController {
                return findTopViewController(selectedController)
            }
            return tabController
        }

        return controller
    }

    /// Get the key window
    var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })?
                .flatMap { $0 as? UIWindowScene }?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
}
