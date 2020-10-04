import XCTest
import DirectoryObserverKit

final class DirectoryObserverKitTests: XCTestCase {
    // MARK: - Properties
    var directoryURL: URL!

    // MARK: - Test setup
    override func setUpWithError() throws {
        try super.setUpWithError()

        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: false
        )
        self.directoryURL = directoryURL
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: directoryURL)
        try super.tearDownWithError()
    }

    // MARK: - Tests
    func testInitThrowsAnErrorIfDirectoryDoesNotExist() {
        let invalidURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString)
        XCTAssertThrowsError(try DirectoryObserver(observeAtPath: invalidURL.path))
    }

    func testInitThrowsAnErrorIfPathPointsToAFileInsteadOfDirectory() {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "\(UUID()).txt")
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        defer { try! FileManager.default.removeItem(atPath: fileURL.path) }

        XCTAssertThrowsError(try DirectoryObserver(observeAtPath: fileURL.path))
    }

    func testInitSucceedsWithCorrectPath() throws {
        XCTAssertNoThrow(try DirectoryObserver(observeAtPath: directoryURL.path))
    }

    func testCreatingAFileInTheObservedDirectoryTriggersDidChangeCallback() throws {
        let directoryObserver = try DirectoryObserver(observeAtPath: directoryURL.path)
        let promise = expectation(description: "Received didChange callback")
        // expectedFulfillmentCount needs to be set to two, due to a bug with  FileManager.default.createFile causing the observer to trigger twice. Creating a file by hand does NOT trigger the observer twice.
        promise.expectedFulfillmentCount = 2
        directoryObserver.didChange = {
            promise.fulfill()
        }
        directoryObserver.startMonitoring()

        FileManager.default.createFile(
            atPath: directoryURL.appendingPathComponent("\(UUID()).txt").path,
            contents: nil
        )

        waitForExpectations(timeout: 1.0)
    }

    func testDeletingAFileInTheObservedDirectoryTriggersChangeCallback() throws {
        let directoryObserver = try DirectoryObserver(observeAtPath: directoryURL.path)
        let fileURL = directoryURL.appendingPathComponent("\(UUID()).txt")
        FileManager.default.createFile(
            atPath: fileURL.path,
            contents: nil
        )

        let promise = expectation(description: "Received didChange callback")
        directoryObserver.didChange = {
            promise.fulfill()
        }
        directoryObserver.startMonitoring()

        try FileManager.default.removeItem(at: fileURL)

        waitForExpectations(timeout: 1.0)
    }

    func testRenamingAFileInTheObservedDirectoryTriggersChangeCallback() throws {
        let directoryObserver = try DirectoryObserver(observeAtPath: directoryURL.path)
        let fileURL = directoryURL.appendingPathComponent("\(UUID()).txt")
        FileManager.default.createFile(
            atPath: fileURL.path,
            contents: nil
        )

        let promise = expectation(description: "Received didChange callback")
        directoryObserver.didChange = {
            promise.fulfill()
        }
        directoryObserver.startMonitoring()

        try FileManager.default.moveItem(
            at: fileURL,
            to: fileURL.deletingLastPathComponent()
                .appendingPathComponent("\(UUID()).txt")
        )

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Linux compatibility
    static var allTests = [
        ("testInitThrowsAnErrorIfDirectoryDoesNotExist",
         testInitThrowsAnErrorIfDirectoryDoesNotExist),
        ("testInitThrowsAnErrorIfPathPointsToAFileInsteadOfDirectory",
         testInitThrowsAnErrorIfPathPointsToAFileInsteadOfDirectory),
        ("testInitSucceedsWithCorrectPath",
         testInitSucceedsWithCorrectPath),
        ("testCreatingAFileInTheObservedDirectoryTriggersDidChangeCallback",
         testCreatingAFileInTheObservedDirectoryTriggersDidChangeCallback),
        ("testDeletingAFileInTheObservedDirectoryTriggersChangeCallback",
         testDeletingAFileInTheObservedDirectoryTriggersChangeCallback),
        ("testRenamingAFileInTheObservedDirectoryTriggersChangeCallback",
         testRenamingAFileInTheObservedDirectoryTriggersChangeCallback)
    ]
}
