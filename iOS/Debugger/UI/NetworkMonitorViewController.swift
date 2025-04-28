import UIKit

/// View controller for monitoring network activity
class NetworkMonitorViewController: UIViewController {
    // MARK: - Properties
    
    /// Table view for displaying network requests
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    /// Logger instance
    private let logger = Debug.shared
    
    /// FLEX adapter for accessing FLEX functionality
    private let flexAdapter = FLEXDebuggerAdapter.shared
    
    /// Button to launch FLEX network monitor
    private lazy var flexNetworkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open FLEX Network Monitor", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(openFLEXNetworkMonitor), for: .touchUpInside)
        return button
    }()
    
    /// Label explaining FLEX integration
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "This app integrates with FLEX for enhanced network monitoring capabilities. Tap the button below to open the FLEX network monitor."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        
        logger.log(message: "NetworkMonitorViewController loaded", type: .info)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Network Monitor"
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(infoLabel)
        view.addSubview(flexNetworkButton)
    }
    
    private func setupConstraints() {
        // Make views respect auto layout
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        flexNetworkButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Info label
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // FLEX button
            flexNetworkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flexNetworkButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 30),
            flexNetworkButton.widthAnchor.constraint(equalToConstant: 250),
            flexNetworkButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func openFLEXNetworkMonitor() {
        // Open FLEX network monitor
        flexAdapter.presentTool(.networkMonitor)
        logger.log(message: "Opening FLEX network monitor", type: .info)
    }
}
