import UIKit

/// View controller for displaying variables
class VariablesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let debuggerEngine = DebuggerEngine.shared
    private var variables: [Variable] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadVariables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh variables when view appears
        loadVariables()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Variables"
        view.backgroundColor = .systemBackground
        
        // Add refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshVariables)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VariableCell")
        
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
    
    private func loadVariables() {
        variables = debuggerEngine.getVariables()
        tableView.reloadData()
    }
    
    @objc private func refreshVariables() {
        loadVariables()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VariableCell", for: indexPath)
        
        let variable = variables[indexPath.row]
        
        // Configure cell
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = variable.name
            content.secondaryText = "\(variable.type): \(variable.value)"
            cell.contentConfiguration = content
        } else {
            // Fallback for older iOS versions
            cell.textLabel?.text = variable.name
            cell.detailTextLabel?.text = "\(variable.type): \(variable.value)"
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let variable = variables[indexPath.row]
        
        // Show variable details
        let alert = UIAlertController(
            title: variable.name,
            message: "Type: \(variable.type)\nValue: \(variable.value)\nAddress: \(variable.address)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}
