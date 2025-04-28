import UIKit

/// View controller for displaying console logs
class ConsoleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let logger = Debug.shared
    private var logs: [LogEntry] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadLogs()
        
        // Register for log notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewLog),
            name: .newLogEntry,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Console"
        view.backgroundColor = .systemBackground
        
        // Add clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearLogs)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data
    
    private func loadLogs() {
        logs = logger.getLogs()
        tableView.reloadData()
        scrollToBottom()
    }
    
    @objc private func handleNewLog(notification: Notification) {
        guard let logEntry = notification.object as? LogEntry else { return }
        
        DispatchQueue.main.async {
            self.logs.append(logEntry)
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard !logs.isEmpty else { return }
        let indexPath = IndexPath(row: logs.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func clearLogs() {
        logger.clearLogs()
        logs.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
        
        let log = logs[indexPath.row]
        
        // Configure cell
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = log.message
            
            // Format timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
            content.secondaryText = "\(dateFormatter.string(from: log.timestamp)) [\(log.type.rawValue)]"
            
            // Set text color based on log type
            switch log.type {
            case .error:
                content.textProperties.color = .systemRed
            case .warning:
                content.textProperties.color = .systemOrange
            case .info:
                content.textProperties.color = .systemBlue
            case .debug:
                content.textProperties.color = .systemGray
            }
            
            cell.contentConfiguration = content
        } else {
            // Fallback for older iOS versions
            cell.textLabel?.text = log.message
            
            // Format timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
            cell.detailTextLabel?.text = "\(dateFormatter.string(from: log.timestamp)) [\(log.type.rawValue)]"
            
            // Set text color based on log type
            switch log.type {
            case .error:
                cell.textLabel?.textColor = .systemRed
            case .warning:
                cell.textLabel?.textColor = .systemOrange
            case .info:
                cell.textLabel?.textColor = .systemBlue
            case .debug:
                cell.textLabel?.textColor = .systemGray
            }
        }
        
        return cell
    }
}
