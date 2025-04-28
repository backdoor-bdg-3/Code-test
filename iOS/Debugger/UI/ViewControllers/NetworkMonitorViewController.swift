import UIKit

/// View controller for monitoring network activity
class NetworkMonitorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let debuggerEngine = DebuggerEngine.shared
    private var networkRequests: [NetworkRequest] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        loadNetworkRequests()
        
        // Register for network request notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewNetworkRequest),
            name: .newNetworkRequest,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Network Monitor"
        view.backgroundColor = .systemBackground
        
        // Add clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearRequests)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NetworkRequestCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
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
    
    private func loadNetworkRequests() {
        networkRequests = debuggerEngine.getNetworkRequests()
        tableView.reloadData()
    }
    
    @objc private func handleNewNetworkRequest(notification: Notification) {
        guard let request = notification.object as? NetworkRequest else { return }
        
        DispatchQueue.main.async {
            self.networkRequests.insert(request, at: 0)
            self.tableView.reloadData()
        }
    }
    
    @objc private func clearRequests() {
        debuggerEngine.clearNetworkRequests()
        networkRequests.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkRequestCell", for: indexPath)
        
        let request = networkRequests[indexPath.row]
        
        // Configure cell
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            
            // Set URL as main text
            content.text = request.url
            
            // Set method and status as secondary text
            let statusColor: UIColor = (200...299).contains(request.statusCode) ? .systemGreen : .systemRed
            content.secondaryText = "\(request.method) - Status: \(request.statusCode)"
            content.secondaryTextProperties.color = statusColor
            
            // Add timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timeString = dateFormatter.string(from: request.timestamp)
            content.secondaryText! += " - \(timeString)"
            
            cell.contentConfiguration = content
        } else {
            // Fallback for older iOS versions
            cell.textLabel?.text = request.url
            
            // Set method and status as detail text
            let statusColor: UIColor = (200...299).contains(request.statusCode) ? .systemGreen : .systemRed
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            let timeString = dateFormatter.string(from: request.timestamp)
            
            cell.detailTextLabel?.text = "\(request.method) - Status: \(request.statusCode) - \(timeString)"
            cell.detailTextLabel?.textColor = statusColor
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = networkRequests[indexPath.row]
        showRequestDetails(request)
    }
    
    private func showRequestDetails(_ request: NetworkRequest) {
        let detailVC = NetworkRequestDetailViewController(request: request)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

/// View controller for displaying network request details
class NetworkRequestDetailViewController: UIViewController {
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let urlLabel = UILabel()
    private let methodLabel = UILabel()
    private let statusLabel = UILabel()
    private let timestampLabel = UILabel()
    private let requestHeadersLabel = UILabel()
    private let requestBodyLabel = UILabel()
    private let responseHeadersLabel = UILabel()
    private let responseBodyLabel = UILabel()
    
    private let request: NetworkRequest
    
    // MARK: - Initialization
    
    init(request: NetworkRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLabels()
        populateData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Request Details"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupLabels() {
        // Configure labels
        let labels = [urlLabel, methodLabel, statusLabel, timestampLabel, 
                      requestHeadersLabel, requestBodyLabel, responseHeadersLabel, responseBodyLabel]
        
        for label in labels {
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 14)
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Set section titles
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        
        let requestHeadersTitle = UILabel()
        requestHeadersTitle.text = "Request Headers"
        requestHeadersTitle.font = titleFont
        
        let requestBodyTitle = UILabel()
        requestBodyTitle.text = "Request Body"
        requestBodyTitle.font = titleFont
        
        let responseHeadersTitle = UILabel()
        responseHeadersTitle.text = "Response Headers"
        responseHeadersTitle.font = titleFont
        
        let responseBodyTitle = UILabel()
        responseBodyTitle.text = "Response Body"
        responseBodyTitle.font = titleFont
        
        let titles = [requestHeadersTitle, requestBodyTitle, responseHeadersTitle, responseBodyTitle]
        
        for title in titles {
            contentView.addSubview(title)
            title.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            methodLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 10),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            methodLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timestampLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            timestampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestHeadersTitle.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 20),
            requestHeadersTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestHeadersTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestHeadersLabel.topAnchor.constraint(equalTo: requestHeadersTitle.bottomAnchor, constant: 10),
            requestHeadersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestHeadersLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestBodyTitle.topAnchor.constraint(equalTo: requestHeadersLabel.bottomAnchor, constant: 20),
            requestBodyTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestBodyTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            requestBodyLabel.topAnchor.constraint(equalTo: requestBodyTitle.bottomAnchor, constant: 10),
            requestBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requestBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            responseHeadersTitle.topAnchor.constraint(equalTo: requestBodyLabel.bottomAnchor, constant: 20),
            responseHeadersTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseHeadersTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            responseHeadersLabel.topAnchor.constraint(equalTo: responseHeadersTitle.bottomAnchor, constant: 10),
            responseHeadersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseHeadersLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            responseBodyTitle.topAnchor.constraint(equalTo: responseHeadersLabel.bottomAnchor, constant: 20),
            responseBodyTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseBodyTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            responseBodyLabel.topAnchor.constraint(equalTo: responseBodyTitle.bottomAnchor, constant: 10),
            responseBodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseBodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            responseBodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        // Format timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let timeString = dateFormatter.string(from: request.timestamp)
        
        // Set basic info
        urlLabel.text = "URL: \(request.url)"
        methodLabel.text = "Method: \(request.method)"
        
        // Set status with color
        let statusColor: UIColor = (200...299).contains(request.statusCode) ? .systemGreen : .systemRed
        statusLabel.text = "Status: \(request.statusCode)"
        statusLabel.textColor = statusColor
        
        timestampLabel.text = "Time: \(timeString)"
        
        // Set headers and body
        requestHeadersLabel.text = formatDictionary(request.requestHeaders)
        requestBodyLabel.text = request.requestBody.isEmpty ? "No body" : request.requestBody
        responseHeadersLabel.text = formatDictionary(request.responseHeaders)
        responseBodyLabel.text = request.responseBody.isEmpty ? "No body" : request.responseBody
    }
    
    private func formatDictionary(_ dict: [String: String]) -> String {
        if dict.isEmpty {
            return "No headers"
        }
        
        return dict.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
}
