import UIKit

/// View controller for the breakpoints tab in the debugger
class BreakpointsViewController: BaseDebuggerViewController {
    
    // MARK: - UI Components
    
    private let tableView = UITableView()
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: #selector(addBreakpoint))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Breakpoints"
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func setupUI() {
        super.setupUI()
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BreakpointCell")
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
    
    @objc private func addBreakpoint() {
        // Show alert to add breakpoint
        let alert = UIAlertController(title: "Add Breakpoint", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "File path"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Line number"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let filePath = alert.textFields?[0].text,
                  let lineNumberText = alert.textFields?[1].text,
                  let lineNumber = Int(lineNumberText) else {
                return
            }
            
            // Add breakpoint
            self?.debuggerEngine.addBreakpoint(file: filePath, line: lineNumber)
            self?.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BreakpointsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // Placeholder
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreakpointCell", for: indexPath)
        
        // Configure cell
        cell.textLabel?.text = "Breakpoint \(indexPath.row + 1)"
        
        return cell
    }
}
