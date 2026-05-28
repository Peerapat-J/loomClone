import Foundation

public enum SaveLocationAvailability: Equatable {
    case available
    case missing
    case notDirectory
    case notWritable
}

public struct SaveLocationSettings: Equatable {
    public var customFolderPath: String?

    public init(customFolderPath: String? = nil) {
        let trimmedPath = customFolderPath?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.customFolderPath = trimmedPath?.isEmpty == false ? trimmedPath : nil
    }

    public var usesDefaultFolder: Bool {
        customFolderPath == nil
    }

    public var customFolderURL: URL? {
        guard let customFolderPath else {
            return nil
        }

        return URL(fileURLWithPath: customFolderPath, isDirectory: true).standardizedFileURL
    }

    public func effectiveFolderURL(fileManager: FileManager = .default) -> URL {
        if let customFolderURL,
           Self.availability(of: customFolderURL, fileManager: fileManager) == .available {
            return customFolderURL
        }

        return Self.defaultFolderURL(fileManager: fileManager)
    }

    public static func defaultFolderURL(fileManager: FileManager = .default) -> URL {
        let moviesFolder = fileManager.urls(for: .moviesDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Movies", isDirectory: true)

        return moviesFolder.appendingPathComponent("LoomClone", isDirectory: true)
    }

    public static func createDefaultFolderIfNeeded(fileManager: FileManager = .default) throws -> URL {
        let defaultFolderURL = defaultFolderURL(fileManager: fileManager)
        try fileManager.createDirectory(at: defaultFolderURL, withIntermediateDirectories: true)
        return defaultFolderURL
    }

    public static func availability(
        of folderURL: URL,
        fileManager: FileManager = .default
    ) -> SaveLocationAvailability {
        var isDirectory = ObjCBool(false)
        let path = folderURL.standardizedFileURL.path

        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return .missing
        }

        guard isDirectory.boolValue else {
            return .notDirectory
        }

        guard fileManager.isWritableFile(atPath: path) else {
            return .notWritable
        }

        return .available
    }
}

public struct SaveLocationPreferenceStore {
    public static let defaultCustomFolderPathKey = "saveLocation.customFolderPath"

    private let userDefaults: UserDefaults
    private let customFolderPathKey: String

    public init(
        userDefaults: UserDefaults = .standard,
        customFolderPathKey: String = SaveLocationPreferenceStore.defaultCustomFolderPathKey
    ) {
        self.userDefaults = userDefaults
        self.customFolderPathKey = customFolderPathKey
    }

    public func load() -> SaveLocationSettings {
        SaveLocationSettings(customFolderPath: userDefaults.string(forKey: customFolderPathKey))
    }

    public func save(_ settings: SaveLocationSettings) {
        if let customFolderPath = settings.customFolderPath {
            userDefaults.set(customFolderPath, forKey: customFolderPathKey)
        } else {
            userDefaults.removeObject(forKey: customFolderPathKey)
        }
    }
}
