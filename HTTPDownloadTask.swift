import Foundation
import XCTest

public class HTTPDownloadTask: XCTestCase {
    let delegate = HTTPDownloadsDelegate()

    static var allTests: [(String, (HTTPDownloadTask) -> () throws ->  Void)] {
        return [("testDownloadWithCompletionHandler", testDownloadWithCompletionHandler),
                ("testDownloadWithDelegate", testDownloadWithDelegate)]
    }
   
    func testDownloadWithCompletionHandler() {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let request = URLRequest(url: URL(string: "https://swift.org/LICENSE.txt")!)
        let downloadCompleteExpectation = expectation(description: "Downloading https://swift.org/LICENSE.txt")
        let task = session.downloadTask(with: request) { url, response, error in 
            XCTAssertNotNil(url)
            XCTAssertNotNil(response)
            XCTAssertNil(error) 
            downloadCompleteExpectation.fulfill()
        }
        task.resume()
        waitForExpectations(timeout: 10)
    } 

    func testDownloadWithDelegate() {
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let request = URLRequest(url: URL(string: "https://swift.org/LICENSE.txt")!)
        delegate.downloadCompletedExpectation = expectation(description: "Downloading https://swift.org/LICENSE.txt")
        let task = session.downloadTask(with: request)
        task.resume()
        waitForExpectations(timeout: 10)    
    }
}

class HTTPDownloadsDelegate: NSObject {
    public var downloadCompletedExpectation: XCTestExpectation!
    var totalBytesDownloaded: Int64 = 0
}

extension HTTPDownloadsDelegate: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData: Int64, 
            totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void { 
        totalBytesDownloaded = totalBytesWritten
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do { 
            let attr = try FileManager.default.attributesOfItem(atPath: location.path)
            XCTAssertEqual((attr[.size]! as? NSNumber)!.int64Value, totalBytesDownloaded, "Size of downloaded file not equal to total bytes downloaded")
        } catch { }
        downloadCompletedExpectation.fulfill()
    }
}

