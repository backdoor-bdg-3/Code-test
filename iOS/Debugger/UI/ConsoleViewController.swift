import UIKit

/// View controller for the console tab in the debugger
class ConsoleViewController: BaseDebuggerViewController {
    
    // MARK: - UI Components
    
    private let textView = UITextView()
    private let clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(clearConsole))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Console"
        navigationItem.rightBarButtonItem = clearButton
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
        textView.showsVerticalScrollIndicator = true
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
    
    @objc private func clearConsole() {
        textView.text = ""
    }
}
