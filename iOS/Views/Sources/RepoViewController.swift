import SwiftUI
import UIKit

// MARK: - Validation Status Enum

enum JSONValidationStatus {
    case notStarted
    case notValidJSON
    case validJSON
}

// MARK: - RepoViewController

struct RepoViewController: View {
    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode
    @State private var repoName: String = ""
    @State private var validationStatus: JSONValidationStatus = .notStarted
    @State private var debounceWorkItem: DispatchWorkItem?
    @State private var isVerifying: Bool = false
    @State private var isSyncing: Bool = false
    @State var sources: [Source]?

    // MARK: - Computed Properties

    private var footerText: String {
        switch validationStatus {
        case .notStarted:
            return String.localized("SOURCES_VIEW_ADD_SOURCES_FOOTER_NOTSTARTED")
        case .notValidJSON:
            return String.localized("SOURCES_VIEW_ADD_SOURCES_FOOTER_NOTVALIDJSON")
        case .validJSON:
            return String.localized("SOURCES_VIEW_ADD_SOURCES_FOOTER_VALID")
        }
    }

    private var footerTextColor: Color {
        switch validationStatus {
        case .notStarted:
            return .gray
        case .notValidJSON:
            return .red
        case .validJSON:
            return .green
        }
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            List {
                Section(footer: Text(footerText).foregroundColor(footerTextColor)) {
                    TextField(
                        String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_DESCRIPTION"),
                        text: $repoName,
                        onCommit: validateJSON
                    )
                    .onChange(of: repoName) { _ in
                        debounceRequest()
                    }
                }

                Section {
                    Button {
                        let pasteboard = UIPasteboard.general
                        if let clipboardText = pasteboard.string {
                            Debug.shared.log(message: "Pasted from clipboard")
                            self.decodeRepositories(text: clipboardText)
                        }
                    } label: {
                        Text(String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_BUTTON_IMPORT_REPO"))
                    }

                    Button {
                        Debug.shared.showSuccessAlert(
                            with: String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_BUTTON_EXPORT_REPO_ACTION_SUCCESS"),
                            subtitle: ""
                        )
                        let repoURLs = self.sources?.map { $0.sourceURL!.absoluteString }.joined(separator: "\n")
                        UIPasteboard.general.string = repoURLs
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_BUTTON_EXPORT_REPO"))
                    }
                } footer: {
                    Text("Supports importing from KravaSign and ESign")
                }
            }
            .navigationTitle(String.localized("SOURCES_VIEW_ADD_SOURCES_ALERT_TITLE"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isSyncing {
                        Button(String.localized("DISMISS")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.system(size: 17, weight: .bold, design: .default))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isVerifying || isSyncing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if validationStatus == .validJSON {
                        Button(String.localized("ADD")) {
                            // Set synchronizing flag
                            isSyncing = true

                            // Call getSourceData without try since the method isn't throwing
                            // It uses a completion handler for error handling instead
                            CoreDataManager.shared.getSourceData(urlString: repoName) { error in
                                // Reset synchronizing flag when done
                                self.isSyncing = false

                                if let error = error {
                                    Debug.shared.log(
                                        message: "SourcesViewController.sourcesAddButtonTapped: \(error)",
                                        type: .critical
                                    )
                                } else {
                                    NotificationCenter.default.post(name: Notification.Name("sfetch"), object: nil)
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Validation Methods

extension RepoViewController {
    private func debounceRequest() {
        isVerifying = true
        debounceWorkItem?.cancel()

        let workItem = DispatchWorkItem { [self] in
            validateJSON()
        }
        debounceWorkItem = workItem

        // Use normal async block instead of execute parameter to avoid type conversion issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            workItem.perform()
        }
    }

    private func validateJSON() {
        guard let url = URL(string: repoName), url.scheme == "https" else {
            validationStatus = .notValidJSON
            isVerifying = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let identifier = jsonObject["identifier"] as? String,
                       !identifier.isEmpty
                    {
                        DispatchQueue.main.async {
                            self.validationStatus = .validJSON
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.validationStatus = .notValidJSON
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.validationStatus = .notValidJSON
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.validationStatus = .notValidJSON
                }
            }
            DispatchQueue.main.async {
                isVerifying = false
            }
        }

        task.resume()
    }
}

// MARK: - Repository Decoding

extension RepoViewController {
    func decodeRepositories(text: String) {
        isSyncing = true
        let isBase64 = isValidBase64String(text)
        let repoLinks: [String]
        Debug.shared.log(message: "Trying to add repositories...")

        if text.hasPrefix("source[") {
            let decryptor = EsignDecryptor(input: text)

            guard let decodedString = decryptor.decrypt(key: esign_key, keyLength: esign_key_len) else {
                Debug.shared.log(message: "Failed to decode esign code")
                return
            }

            repoLinks = decodedString
        } else if isBase64 {
            guard let decodedString = decodeBase64String(text) else {
                Debug.shared.log(message: "Failed to decode base64 string")
                return
            }

            if decodedString.contains("[K$]") {
                repoLinks = decodedString.components(separatedBy: "[K$]")
            } else if decodedString.contains("[M$]") {
                repoLinks = decodedString.components(separatedBy: "[M$]")
            } else {
                Debug.shared.log(message: "Is this a valid Kravasign code?", type: .error)
                return
            }
        } else {
            repoLinks = text.components(separatedBy: "\n")
        }

        DispatchQueue(label: "import").async {
            var success = 0
            // Filter for http links first, then process them
            let httpLinks = repoLinks.filter { $0.starts(with: "http") }

            for str in httpLinks {
                let sem = DispatchSemaphore(value: 0)
                CoreDataManager.shared.getSourceData(urlString: str) { error in
                    if let error = error {
                        Debug.shared.log(message: "RepoImportVC.sourcesAddButtonTapped: \(error)")
                    } else {
                        success += 1
                    }
                    sem.signal()
                }
                sem.wait()
            }

            DispatchQueue.main.async {
                Debug.shared.log(message: "Successfully imported \(success) repos", type: .success)
                presentationMode.wrappedValue.dismiss()
                NotificationCenter.default.post(name: Notification.Name("sfetch"), object: nil)
            }
        }
    }

    private func isValidBase64String(_ string: String) -> Bool {
        return Data(base64Encoded: string) != nil
    }

    private func decodeBase64String(_ base64String: String) -> String? {
        guard let data = Data(base64Encoded: base64String),
              let decodedString = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return decodedString
    }
}
