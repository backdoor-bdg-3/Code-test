import UIKit

/// View controller for the memory tab in the debugger
class MemoryViewController: BaseDebuggerViewController {
    
    // MARK: - UI Components
    
    private let textView = UITextView()
    private let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: #selector(refreshMemory))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Memory"
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    override func setupUI() {
        super.setupUI()
        
        // Configure text view
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func refreshMemory() {
        // Placeholder for memory refresh
        textView.text = "Memory information would be displayed here."
    }
}
