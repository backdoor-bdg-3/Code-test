import UIKit

/// View controller for managing breakpoints
class BreakpointsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let debuggerEngine = DebuggerEngine.shared
    private var breakpoints: [Breakpoint] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadBreakpoints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh breakpoints when view appears
        loadBreakpoints()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Breakpoints"
        view.backgroundColor = .systemBackground
        
        // Add add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBreakpoint)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BreakpointCell")
        
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
    
    private func loadBreakpoints() {
        breakpoints = debuggerEngine.getBreakpoints()
        tableView.reloadData()
    }
    
    @objc private func addBreakpoint() {
        let alert = UIAlertController(
            title: "Add Breakpoint",
            message: "Enter file path and line number",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "File path (e.g., ViewController.swift)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Line number"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let fileText = alert.textFields?[0].text, !fileText.isEmpty,
                  let lineText = alert.textFields?[1].text, !lineText.isEmpty,
                  let lineNumber = Int(lineText) else {
                return
            }
            
            // Add breakpoint
            let breakpoint = Breakpoint(file: fileText, line: lineNumber)
            self.debuggerEngine.addBreakpoint(breakpoint)
            
            // Refresh list
            self.loadBreakpoints()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breakpoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreakpointCell", for: indexPath)
        
        let breakpoint = breakpoints[indexPath.row]
        
        // Configure cell
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = breakpoint.file
            content.secondaryText = "Line \(breakpoint.line)"
            content.image = UIImage(systemName: "pause.circle.fill")
            content.imageProperties.tintColor = .systemRed
            cell.contentConfiguration = content
        } else {
            // Fallback for older iOS versions
            cell.textLabel?.text = breakpoint.file
            cell.detailTextLabel?.text = "Line \(breakpoint.line)"
            cell.imageView?.image = UIImage(systemName: "pause.circle.fill")
            cell.imageView?.tintColor = .systemRed
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove breakpoint
            let breakpoint = breakpoints[indexPath.row]
            debuggerEngine.removeBreakpoint(breakpoint)
            
            // Update data
            breakpoints.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
