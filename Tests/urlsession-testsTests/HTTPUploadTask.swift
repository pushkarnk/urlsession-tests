import Foundation
import XCTest

//Upload a file, download it back and then delete it
//Using https://www.posttestserver.com for now!

class HTTPUploadTask: XCTestCase {

    let delegate = HTTPUploadDelegate()

    static var allTests: [(String, (HTTPUploadTask)->() throws -> Void)] {
        return [("testUploadWithCompletionHandler", testUploadWithCompletionHandler),
                ("testUploadWithDelegate", testUploadWithDelegate)]
    }

    func testUploadWithCompletionHandler() {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL(string: "http://posttestserver.com/post.php")!)    
        request.httpMethod = "POST" //the service allows only POST ;(
        
        let uploadDataExpectation = expectation(description: "Upload data to http://posttestserver.com")
        let fileData = Data(count: 2048)

        let task = session.uploadTask(with: request, from: fileData) { _, response, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200, "Unexpected status code")
            uploadDataExpectation.fulfill()
        }

        task.resume()
        waitForExpectations(timeout: 20)
    }

    func testUploadWithDelegate() {
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        var request = URLRequest(url: URL(string: "http://posttestserver.com/post.php")!)
        request.httpMethod = "POST"

        delegate.responseReceivedExpectation = expectation(description: "Upload data to http://posttestserver.com")
        delegate.uploadCompletedExpectation = expectation(description: "Upload data to http://posttestserver.com")

        let fileData = Data(count: 2048)
        let task = session.uploadTask(with: request, from: fileData)
        task.resume()
        waitForExpectations(timeout: 20)
    }
}

class HTTPUploadDelegate: NSObject {
    var responseReceivedExpectation: XCTestExpectation!
    var uploadCompletedExpectation: XCTestExpectation!
    var totalBytesSent: Int64 = 0
}

extension HTTPUploadDelegate: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.totalBytesSent = totalBytesSent
    }
}

extension HTTPUploadDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
        responseReceivedExpectation.fulfill()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        XCTAssertEqual(self.totalBytesSent, 2048)
        uploadCompletedExpectation.fulfill()
    }
}
