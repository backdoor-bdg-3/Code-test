import UIKit

/// Base class for all debugger view controllers
class BaseDebuggerViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The debugger engine
    let debuggerEngine = DebuggerEngine.shared
    
    /// Logger instance
    let logger = Debug.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up common UI elements
        setupUI()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        // Base setup - override in subclasses
        view.backgroundColor = .systemBackground
    }
}
