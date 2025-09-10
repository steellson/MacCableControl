//  Created by Andrew Steellson on 09.09.2025.
//

import Foundation

final class Saver {
    enum Errors: Error {
        case cantSaveFile
        case cantClearDirectory
        case cantCreateDirectory
    }

    private var isDirectoryObjCBool: ObjCBool = true

    private let directory: URL
    private let fileManager: FileManager

    init(directory: String? = nil) {
        self.fileManager = FileManager.default
        self.directory = fileManager
            .homeDirectoryForCurrentUser
            .appendingPathComponent(directory ?? ".mcc_app_data")
    }
}

// MARK: - Public
extension Saver {
    func save(url: URL) throws {
        do {
            try checkDirectory()
        } catch {
            throw Errors.cantClearDirectory
        }

        let isDirectoryExists = fileManager.fileExists(
            atPath: directory.path(),
            isDirectory: &isDirectoryObjCBool
        )

        guard isDirectoryExists else {
            throw Errors.cantCreateDirectory
        }

        do {
            try fileManager.copyItem(
                at: url,
                to: directory.appending(path: url.lastPathComponent)
            )
        } catch {
            throw Errors.cantSaveFile
        }
    }

    func resetStore() {
        clearDirectory(totally: true)
    }

    func storedURL() -> URL? {
        try? fileManager
            .contentsOfDirectory(atPath: directory.path())
            .compactMap { directory.appending(path: $0) }
            .last
    }
}

// MARK: - Private
private extension Saver {
    func checkDirectory() throws {
        let isDirectoryExists = fileManager.fileExists(
            atPath: directory.path(),
            isDirectory: &isDirectoryObjCBool
        )

        isDirectoryExists
        ? clearDirectory()
        : try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: false
        )
    }

    func clearDirectory(totally: Bool = false) {
        let dir = directory.path()
        guard !totally else {
            try? fileManager.removeItem(atPath: dir)
            return
        }

        let files = try? fileManager.contentsOfDirectory(atPath: dir)
        guard let files, !files.isEmpty else { return }

        files.forEach { try? fileManager.removeItem(atPath: dir.appending("/" + $0)) }
    }
}
