import XCTest
@testable import MGImageView
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Serves canned bytes for any request so tests never touch the network.
// Not private: NSStringFromClass traps on Linux for nested/private classes.
class StubImageProtocol: URLProtocol {
    static var responses: [String: Data] = [:]
    static var requestCount = 0

    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        StubImageProtocol.requestCount += 1
        let key = request.url?.absoluteString ?? ""
        if let body = StubImageProtocol.responses[key] {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "image/png"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        } else {
            client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
        }
    }

    override func stopLoading() {}
}

final class MGImageViewTests: XCTestCase {

    // 1x1 PNG, the smallest valid image payload.
    static let pngBytes = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")!

    override class func setUp() {
        super.setUp()
        // Point the download session at the stub so no test reaches the network.
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubImageProtocol.self]
        MGImageDownloadOparation.session = URLSession(configuration: config)
    }

    override func setUp() {
        super.setUp()
        StubImageProtocol.responses = [:]
        StubImageProtocol.requestCount = 0
    }

    func testCacheRoundTrip() {
        let key = "https://example.org/roundtrip.png"
        MGImageCacheManager.shared.cacheImage(imageData: Self.pngBytes, key: key)
        XCTAssertEqual(MGImageCacheManager.shared.getImageData(for: key), Self.pngBytes)
    }

    func testCacheMissIsNil() {
        XCTAssertNil(MGImageCacheManager.shared.getImageData(for: "https://example.org/never-stored.png"))
    }

    func testDownloadOperationStoresBytesInCache() {
        let url = "https://example.org/op-download.png"
        StubImageProtocol.responses[url] = Self.pngBytes

        let op = MGImageDownloadOparation(url: url)
        let done = expectation(description: "operation finished")
        op.completionBlock = { done.fulfill() }
        MGImageDownloadOparation.queue.addOperation(op)

        wait(for: [done], timeout: 5)
        XCTAssertEqual(MGImageCacheManager.shared.getImageData(for: url), Self.pngBytes)
        XCTAssertEqual(StubImageProtocol.requestCount, 1)
        XCTAssertTrue(op.isFor(url: url))
        XCTAssertFalse(op.isFor(url: "https://example.org/other.png"))
    }

    func testDownloadFailureLeavesCacheEmpty() {
        let url = "https://example.org/op-missing.png"
        // no stub response registered, protocol fails the request

        let op = MGImageDownloadOparation(url: url)
        let done = expectation(description: "operation finished")
        op.completionBlock = { done.fulfill() }
        MGImageDownloadOparation.queue.addOperation(op)

        wait(for: [done], timeout: 5)
        XCTAssertNil(MGImageCacheManager.shared.getImageData(for: url))
    }
}
