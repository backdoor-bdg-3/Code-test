import UIKit

/// View controller for the performance tab in the debugger
class PerformanceViewController: BaseDebuggerViewController {
    
    // MARK: - UI Components
    
    private let textView = UITextView()
    private let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: #selector(refreshPerformance))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Performance"
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
    
    @objc private func refreshPerformance() {
        // Placeholder for performance refresh
        textView.text = "Performance metrics would be displayed here."
    }
}
