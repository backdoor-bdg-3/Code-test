import UIKit

/// Protocol for FLEX tools view controller delegate
protocol FLEXToolsViewControllerDelegate: AnyObject {
    /// Called when a FLEX tool is selected
    func flexToolsViewController(_ viewController: FLEXToolsViewController, didSelectTool tool: FLEXDebuggerTool)
}

/// View controller that provides access to FLEX debugging tools
class FLEXToolsViewController: UIViewController {
    // MARK: - Properties
    
    /// Delegate for handling tool selection
    weak var delegate: FLEXToolsViewControllerDelegate?
    
    /// Table view for displaying available tools
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    /// Logger instance
    private let logger = Debug.shared
    
    /// Available tools sections
    private let sections: [(title: String, tools: [(name: String, tool: FLEXDebuggerTool)])] = [
        (
            "Network",
            [
                ("Network Monitor", .networkMonitor)
            ]
        ),
        (
            "Exploration",
            [
                ("View Hierarchy", .viewHierarchy),
                ("Runtime Browser", .runtimeBrowser)
            ]
        ),
        (
            "Storage",
            [
                ("File Browser", .fileBrowser),
                ("Database Browser", .databaseBrowser),
                ("User Defaults", .userDefaults),
                ("Keychain", .keychain)
            ]
        ),
        (
            "System",
            [
                ("System Log", .systemLog)
            ]
        )
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        
        logger.log(message: "FLEXToolsViewController loaded", type: .info)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "FLEX Tools"
        view.backgroundColor = .systemBackground
    }
    
    private func setupTableView() {
        // Add table view
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ToolCell")
    }
}

// MARK: - UITableViewDataSource

extension FLEXToolsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].tools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolCell", for: indexPath)
        
        let tool = sections[indexPath.section].tools[indexPath.row]
        
        // Configure cell
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = tool.name
            
            // Add appropriate image based on tool type
            switch tool.tool {
            case .networkMonitor:
                content.image = UIImage(systemName: "network")
            case .viewHierarchy:
                content.image = UIImage(systemName: "square.3.stack.3d")
            case .systemLog:
                content.image = UIImage(systemName: "text.append")
            case .fileBrowser:
                content.image = UIImage(systemName: "folder")
            case .databaseBrowser:
                content.image = UIImage(systemName: "cylinder.split.1x2")
            case .runtimeBrowser:
                content.image = UIImage(systemName: "hammer")
            case .userDefaults:
                content.image = UIImage(systemName: "gearshape")
            case .keychain:
                content.image = UIImage(systemName: "key")
            }
            
            cell.contentConfiguration = content
        } else {
            // Fallback for iOS 13
            cell.textLabel?.text = tool.name
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - UITableViewDelegate

extension FLEXToolsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected tool
        let tool = sections[indexPath.section].tools[indexPath.row].tool
        
        // Notify delegate
        delegate?.flexToolsViewController(self, didSelectTool: tool)
        
        logger.log(message: "Selected FLEX tool: \(tool)", type: .info)
    }
}
