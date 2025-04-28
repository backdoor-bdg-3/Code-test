import UIKit

/// View controller for monitoring app performance
class PerformanceViewController: UIViewController {
    // MARK: - Properties
    
    private let debuggerEngine = DebuggerEngine.shared
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Performance stats labels
    private let cpuUsageLabel = UILabel()
    private let memoryUsageLabel = UILabel()
    private let fpsLabel = UILabel()
    private let diskUsageLabel = UILabel()
    private let batteryUsageLabel = UILabel()
    
    // Performance graphs
    private let cpuGraphView = UIView()
    private let memoryGraphView = UIView()
    private let fpsGraphView = UIView()
    
    // Refresh control
    private let refreshControl = UIRefreshControl()
    
    // Timer for auto-refresh
    private var refreshTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPerformanceViews()
        updatePerformanceInfo()
        
        // Start auto-refresh timer
        startRefreshTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh when view appears
        updatePerformanceInfo()
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
        title = "Performance"
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
    
    private func setupPerformanceViews() {
        // Configure labels
        let labels = [cpuUsageLabel, memoryUsageLabel, fpsLabel, diskUsageLabel, batteryUsageLabel]
        
        for label in labels {
            label.font = UIFont.systemFont(ofSize: 16)
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Configure graph views
        let graphViews = [cpuGraphView, memoryGraphView, fpsGraphView]
        
        for graphView in graphViews {
            graphView.backgroundColor = .systemGray6
            graphView.layer.cornerRadius = 8
            contentView.addSubview(graphView)
            graphView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Configure constraints
        NSLayoutConstraint.activate([
            cpuUsageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cpuUsageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cpuUsageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cpuGraphView.topAnchor.constraint(equalTo: cpuUsageLabel.bottomAnchor, constant: 8),
            cpuGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cpuGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cpuGraphView.heightAnchor.constraint(equalToConstant: 40),
            
            memoryUsageLabel.topAnchor.constraint(equalTo: cpuGraphView.bottomAnchor, constant: 20),
            memoryUsageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            memoryUsageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            memoryGraphView.topAnchor.constraint(equalTo: memoryUsageLabel.bottomAnchor, constant: 8),
            memoryGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            memoryGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            memoryGraphView.heightAnchor.constraint(equalToConstant: 40),
            
            fpsLabel.topAnchor.constraint(equalTo: memoryGraphView.bottomAnchor, constant: 20),
            fpsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fpsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            fpsGraphView.topAnchor.constraint(equalTo: fpsLabel.bottomAnchor, constant: 8),
            fpsGraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fpsGraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fpsGraphView.heightAnchor.constraint(equalToConstant: 40),
            
            diskUsageLabel.topAnchor.constraint(equalTo: fpsGraphView.bottomAnchor, constant: 20),
            diskUsageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            diskUsageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            batteryUsageLabel.topAnchor.constraint(equalTo: diskUsageLabel.bottomAnchor, constant: 20),
            batteryUsageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            batteryUsageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            batteryUsageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Performance Info
    
    private func updatePerformanceInfo() {
        let performanceInfo = debuggerEngine.getPerformanceInfo()
        
        // Update labels
        cpuUsageLabel.text = "CPU Usage: \(String(format: "%.1f%%", performanceInfo.cpuUsage))"
        memoryUsageLabel.text = "Memory Usage: \(formatMemorySize(performanceInfo.memoryUsage))"
        fpsLabel.text = "FPS: \(String(format: "%.1f", performanceInfo.fps))"
        diskUsageLabel.text = "Disk Usage: \(formatMemorySize(performanceInfo.diskUsage)) / \(formatMemorySize(performanceInfo.diskTotal))"
        
        // Battery info
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = UIDevice.current.batteryState
        
        var batteryStateString = "Unknown"
        switch batteryState {
        case .charging:
            batteryStateString = "Charging"
        case .full:
            batteryStateString = "Full"
        case .unplugged:
            batteryStateString = "Unplugged"
        case .unknown:
            batteryStateString = "Unknown"
        @unknown default:
            batteryStateString = "Unknown"
        }
        
        if batteryLevel < 0 {
            batteryUsageLabel.text = "Battery: \(batteryStateString)"
        } else {
            batteryUsageLabel.text = "Battery: \(Int(batteryLevel * 100))% (\(batteryStateString))"
        }
        
        // Update graphs
        updateCPUGraph(cpuUsage: performanceInfo.cpuUsage)
        updateMemoryGraph(memoryUsage: performanceInfo.memoryUsage, memoryTotal: performanceInfo.memoryTotal)
        updateFPSGraph(fps: performanceInfo.fps)
        
        // End refreshing if needed
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    private func updateCPUGraph(cpuUsage: Double) {
        // Remove existing subviews
        cpuGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        // Calculate percentage
        let percentage = min(cpuUsage / 100.0, 1.0)
        
        // Create used CPU view
        let usedView = UIView()
        usedView.backgroundColor = percentage > 0.8 ? .systemRed : (percentage > 0.5 ? .systemOrange : .systemBlue)
        usedView.layer.cornerRadius = 6
        
        cpuGraphView.addSubview(usedView)
        usedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usedView.leadingAnchor.constraint(equalTo: cpuGraphView.leadingAnchor, constant: 2),
            usedView.topAnchor.constraint(equalTo: cpuGraphView.topAnchor, constant: 2),
            usedView.bottomAnchor.constraint(equalTo: cpuGraphView.bottomAnchor, constant: -2),
            usedView.widthAnchor.constraint(equalTo: cpuGraphView.widthAnchor, multiplier: CGFloat(percentage), constant: -4)
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
    
    private func updateMemoryGraph(memoryUsage: UInt64, memoryTotal: UInt64) {
        // Remove existing subviews
        memoryGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        // Calculate percentage
        let percentage = min(Double(memoryUsage) / Double(memoryTotal), 1.0)
        
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
    
    private func updateFPSGraph(fps: Double) {
        // Remove existing subviews
        fpsGraphView.subviews.forEach { $0.removeFromSuperview() }
        
        // Calculate percentage (60 FPS is considered 100%)
        let percentage = min(fps / 60.0, 1.0)
        
        // Create FPS view
        let fpsView = UIView()
        fpsView.backgroundColor = percentage < 0.5 ? .systemRed : (percentage < 0.8 ? .systemOrange : .systemGreen)
        fpsView.layer.cornerRadius = 6
        
        fpsGraphView.addSubview(fpsView)
        fpsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fpsView.leadingAnchor.constraint(equalTo: fpsGraphView.leadingAnchor, constant: 2),
            fpsView.topAnchor.constraint(equalTo: fpsGraphView.topAnchor, constant: 2),
            fpsView.bottomAnchor.constraint(equalTo: fpsGraphView.bottomAnchor, constant: -2),
            fpsView.widthAnchor.constraint(equalTo: fpsGraphView.widthAnchor, multiplier: CGFloat(percentage), constant: -4)
        ])
        
        // Add FPS label
        let fpsValueLabel = UILabel()
        fpsValueLabel.text = "\(Int(fps)) FPS"
        fpsValueLabel.textColor = .white
        fpsValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        fpsValueLabel.textAlignment = .center
        
        fpsView.addSubview(fpsValueLabel)
        fpsValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fpsValueLabel.centerXAnchor.constraint(equalTo: fpsView.centerXAnchor),
            fpsValueLabel.centerYAnchor.constraint(equalTo: fpsView.centerYAnchor)
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
        updatePerformanceInfo()
    }
    
    private func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRefresh), userInfo: nil, repeats: true)
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @objc private func timerRefresh() {
        updatePerformanceInfo()
    }
}
