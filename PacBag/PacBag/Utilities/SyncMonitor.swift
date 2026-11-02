import CloudKit
import CoreData
import SwiftUI

/// What CloudKit last reported. Settings shows this, so it can't say "Synced" unless it did.
final class SyncMonitor: ObservableObject {
    static let shared = SyncMonitor()

    enum State: Equatable {
        case off, notSignedIn, waiting, syncing, synced, failed
    }

    @Published private(set) var state: State = .waiting
    private var observer: NSObjectProtocol?

    private init() {
        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification, object: nil, queue: .main
        ) { [weak self] note in
            let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
            guard let event = note.userInfo?[key] as? NSPersistentCloudKitContainer.Event else { return }
            if event.endDate == nil {
                self?.state = .syncing
            } else {
                self?.state = event.error == nil ? .synced : .failed
            }
        }
    }

    /// Reads the things no sync event reports: mirroring off, or no iCloud account.
    @MainActor
    func refresh(cloudKitIsOn: Bool, containerID: String) async {
        guard cloudKitIsOn else {
            state = .off
            return
        }
        let status = try? await CKContainer(identifier: containerID).accountStatus()
        if status != .available {
            state = .notSignedIn
        }
    }

    var text: String {
        switch state {
        case .off: return "Off"
        case .notSignedIn: return "Sign in to iCloud to sync"
        case .waiting: return "Waiting to sync"
        case .syncing: return "Syncing"
        case .synced: return "Up to date"
        case .failed: return "Couldn't sync. Your data is safe on this device"
        }
    }

    var icon: String {
        switch state {
        case .synced: return "checkmark.circle.fill"
        case .syncing, .waiting: return "arrow.triangle.2.circlepath"
        case .off, .notSignedIn, .failed: return "exclamationmark.circle"
        }
    }

    var color: Color {
        switch state {
        case .synced: return .green
        case .syncing, .waiting: return .secondary
        case .off, .notSignedIn, .failed: return .orange
        }
    }
}
