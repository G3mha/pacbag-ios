import Foundation

/// Launch arguments and environment names, shared by the app and the UI tests.
/// Docs: `docs/ssot-registry.md` section 2.10. In Release, every DEBUG read returns false.
enum LaunchOption {
    static let disableCloudKit = "-PacBagDisableCloudKit"
    static let disableCloudKitEnv = "PACBAG_DISABLE_CLOUDKIT"
    static let inMemoryStore = "-PacBagInMemoryStore"
    static let concurrencyDebug = ["-com.apple.CoreData.ConcurrencyDebug", "1"]

    /// Runs the app against a local store with no iCloud mirroring.
    ///
    /// Pass the launch argument, or set the environment variable to 1, to turn
    /// CloudKit off. This exists because CloudKit mirroring traps during setup
    /// when it cannot resolve its container -- a simulator with no iCloud account
    /// signed in, for instance. That trap happens on CloudKit's own queue, so
    /// `loadPersistentStores` never sees it and the app dies before any of the
    /// error handling can run. Off by default: a normal build syncs exactly as before.
    static var isCloudKitDisabled: Bool {
        ProcessInfo.processInfo.arguments.contains(disableCloudKit)
            || ProcessInfo.processInfo.environment[disableCloudKitEnv] == "1"
    }

    /// True for the argument, a hosted unit test, or a SwiftUI preview.
    static var usesInMemoryStore: Bool {
        #if DEBUG
        let environment = ProcessInfo.processInfo.environment
        return ProcessInfo.processInfo.arguments.contains(inMemoryStore)
            || environment["XCTestConfigurationFilePath"] != nil
            || environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
