import Foundation

public class ObservableDirectory {
    enum ObservableDirectoryError: Error {
        case directoryNotFound
        case notADirectory
    }
    
    // MARK: - Properties
    private let directoryPath: String
    private let debugMode: Bool
    
    private var isDirectory: ObjCBool = false
    
    private var monitoredDirectoryFileDescriptor: CInt = -1
    private var directoryMonitorSource: DispatchSourceFileSystemObject?
    private let directoryMonitorDispatchQueue = DispatchQueue(
        label: "DirectoryObserverQueue",
        attributes: .concurrent
    )
    
    private var isDirectoryObserverIdle: Bool {
        directoryMonitorSource == nil && monitoredDirectoryFileDescriptor == -1
    }
    
    public var didChange: (() -> Void)?
    
    // MARK: - Initializer
    required public init(directoryPath: String,
                         debugMode: Bool = false) throws {
        guard FileManager.default.fileExists(atPath: directoryPath,
                                             isDirectory: &isDirectory) else {
            throw ObservableDirectoryError.directoryNotFound
        }
        
        guard isDirectory.boolValue else {
            throw ObservableDirectoryError.notADirectory
        }
        
        self.directoryPath = directoryPath
        self.debugMode = debugMode
    }
    
    // MARK: - Class methods
    public func startMonitoring() {
        guard isDirectoryObserverIdle else {
            return
        }
        
        monitoredDirectoryFileDescriptor = open(directoryPath, O_EVTONLY)
        directoryMonitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: monitoredDirectoryFileDescriptor,
            eventMask: .write,
            queue: directoryMonitorDispatchQueue
        )
        directoryMonitorSource?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                self?.didChange?()
            }
        })
        directoryMonitorSource?.setCancelHandler(handler: { [weak self] in
            guard let self = self else { return }
            close(self.monitoredDirectoryFileDescriptor)
            self.monitoredDirectoryFileDescriptor = -1
            self.directoryMonitorSource = nil
            self.debugLog("[ Info ] DirectoryObserver stopped observing!")
        })
        
        self.debugLog("[ Info ] DirectoryObserver about to start observing...")
        directoryMonitorSource?.resume()
    }
    
    public func stopMonitoring() {
        directoryMonitorSource?.cancel()
    }
    
    private func debugLog(_ message: String) {
        if debugMode {
            print(message)
        }
    }
}
