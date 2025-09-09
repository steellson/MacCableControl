//  Created by Andrew Steellson on 03.05.2025.
//

import AppKit

@MainActor
public final class Finder {
    public enum Errors: Error {
        case selectionCancelled
        case savingCancelled
        case cantSelectWithURL
        case cantSaveFileWithURL
    }

    private let openPanel: NSOpenPanel
    private let savePanel: NSSavePanel
    private let fileManager: FileManager
    private let windowLevel: CGWindowLevel

    public init() {
        openPanel = NSOpenPanel()
        savePanel = NSSavePanel()
        fileManager = FileManager.default
        windowLevel = CGWindowLevelForKey(.modalPanelWindow)

        setup()
    }
}

// MARK: - Public
public extension Finder {
    /// Choose any file from your desktop
    func selectFile() async throws -> URL {
        guard await openPanel.begin() == .OK else {
            throw Errors.selectionCancelled
        }

        openPanel.level = .popUpMenu
        openPanel.makeKeyAndOrderFront(nil)
        openPanel.becomeFirstResponder()

        guard let url = openPanel.urls.first else {
            throw Errors.cantSelectWithURL
        }

        Log.info("Selected file url: \(url)")
        return url
    }
    
    /// Save file using dialog window
    /// - Parameters:
    ///   - url: Existing file url
    /// - Returns: Saved file url
    @discardableResult
    func saveFile(with url: URL) throws -> URL {
        NSApp.activate(ignoringOtherApps: true)
        savePanel.nameFieldStringValue = url.lastPathComponent

        let response = savePanel.runModal()
        guard response == .OK else {
            throw Errors.savingCancelled
        }

        guard let selectedURL = savePanel.url else {
            throw Errors.cantSaveFileWithURL
        }

        try fileManager.moveItem(at: url, to: selectedURL)
        Log.success("File saved at \(selectedURL)")
        return selectedURL
    }
}

// MARK: - Private
private extension Finder {
    func setup() {
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.directoryURL = .desktopDirectory
        savePanel.level = NSWindow.Level(
            rawValue: Int(windowLevel)
        )
    }
}
