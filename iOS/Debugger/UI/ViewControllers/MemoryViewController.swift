import UIKit

/// View controller for displaying memory usage
class MemoryViewController: UIViewController {
    // MARK: - Properties
    
    private let debuggerEngine = DebuggerEngine.shared
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Memory stats labels
    private let usedMemoryLabel = UILabel()
    private let freeMemoryLabel = UILabel()
    private let totalMemoryLabel = UILabel()
    private let memoryGraphView = UIView()
    
    // Refresh control
    private let refreshControl = UIRefreshControl()
    
    // Timer for auto-refresh
    private var refreshTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMemoryViews()
        updateMemoryInfo()
        
        // Start auto-refresh timer
        startRefreshTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh when view appears
        updateMemoryInfo()
        startRefreshTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop timer when view disappears
        stopRefreshTimer()
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Memory"
        view.backgroundColor = .systemBackground
        
        // Add refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(manualRefresh)
        )
        
        // Setup scroll view with refresh control
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(manualRefresh), for: .valueChanged)
        
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
    
    private func setupMemoryViews() {
        // Configure labels
        usedMemoryLabel.font = UIFont.systemFont(ofSize: 16)
        freeMemoryLabel.font = UIFont.systemFont(ofSize: 16)
        totalMemoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Configure memory graph view
        memoryGraphView.backgroundColor = .systemGray6
        memoryGraphView.layer.cornerRadius = 8
        
        // Add to content view
        contentView.addSubview(usedMemoryLabel)
        contentView.addSubview(freeMemoryLabel)
        contentView.addSubview(totalMemoryLabel)
        contentView.addSubview(memoryGraphView)
        
        // Configure constraints
        usedMemoryLabel.translatesAutoresizingMaskIntoConstraints = false
        freeMemoryLabel.translatesAutoresizingMaskIntoConstraints = false
        totalMemoryLabel.translatesAutoresizingMaskIntoConstraints = false
        memoryGraphView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalMemoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            totalMemoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            totalMemoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            usedMemoryLabel.topAnchor.constraint(equalTo: totalMemoryLabel.bottomAnchor, constant: 16),
            usedMemoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usedMemoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            freeMemoryLabel.topAnchor.constraint(equalTo: usedMemoryLabel.bottomAnchor, constant: 8),
            freeMemoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            freeMemoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            memoryGraphView.topAnchor.constraint(equalTo: freeMemoryLabel.bottomAnchor, constant: 20),
            memoryGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            memoryGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            memoryGraphView.heightAnchor.constraint(equalToConstant: 40),
            memoryGraphView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Memory Info
    
    private func updateMemoryInfo() {
        let memoryInfo = debuggerEngine.getMemoryInfo()
        
        // Update labels
        totalMemoryLabel.text = "Total Memory: \(formatMemorySize(memoryInfo.total))"
        usedMemoryLabel.text = "Used Memory: \(formatMemorySize(memoryInfo.used))"
        freeMemoryLabel.text = "Free Memory: \(formatMemorySize(memoryInfo.free))"
        
        // Update graph
        updateMemoryGraph(used: memoryInfo.used, total: memoryInfo.total)
        
        // End refreshing if needed
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    private func updateMemoryGraph(used: UInt64, total: UInt64) {
        // Remove existing subviews
        memoryGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        // Calculate percentage
        let percentage = min(Double(used) / Double(total), 1.0)
        
        // Create used memory view
        let usedView = UIView()
        usedView.backgroundColor = percentage > 0.8 ? .systemRed : (percentage > 0.6 ? .systemOrange : .systemBlue)
        usedView.layer.cornerRadius = 6
        
        memoryGraphView.addSubview(usedView)
        usedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usedView.leadingAnchor.constraint(equalTo: memoryGraphView.leadingAnchor, constant: 2),
            usedView.topAnchor.constraint(equalTo: memoryGraphView.topAnchor, constant: 2),
            usedView.bottomAnchor.constraint(equalTo: memoryGraphView.bottomAnchor, constant: -2),
            usedView.widthAnchor.constraint(equalTo: memoryGraphView.widthAnchor, multiplier: CGFloat(percentage), constant: -4)
        ])
        
        // Add percentage label
        let percentLabel = UILabel()
        percentLabel.text = "\(Int(percentage * 100))%"
        percentLabel.textColor = .white
        percentLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        percentLabel.textAlignment = .center
        
        usedView.addSubview(percentLabel)
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            percentLabel.centerXAnchor.constraint(equalTo: usedView.centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: usedView.centerYAnchor)
        ])
    }
    
    private func formatMemorySize(_ size: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(size))
    }
    
    // MARK: - Refresh
    
    @objc private func manualRefresh() {
        updateMemoryInfo()
    }
    
    private func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerRefresh), userInfo: nil, repeats: true)
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @objc private func timerRefresh() {
        updateMemoryInfo()
    }
}
