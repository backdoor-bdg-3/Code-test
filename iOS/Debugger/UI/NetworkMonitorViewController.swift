import UIKit

/// View controller for the network monitor tab in the debugger
class NetworkMonitorViewController: BaseDebuggerViewController {
    
    // MARK: - UI Components
    
    private let tableView = UITableView()
    private let clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: #selector(clearRequests))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Network Monitor"
        navigationItem.rightBarButtonItem = clearButton
    }
    
    override func setupUI() {
        super.setupUI()
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RequestCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func clearRequests() {
        // Clear network requests
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NetworkMonitorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // Placeholder
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        
        // Configure cell
        cell.textLabel?.text = "Network Request \(indexPath.row + 1)"
        
        return cell
    }
}
