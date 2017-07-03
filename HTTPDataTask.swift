import Foundation
import XCTest 

class HTTPDataTask: XCTestCase {

    static var allTests: [(String, (HTTPDataTask) -> () throws -> Void)] {
        return [
            ("testSimpleGetCallWithCompletionHandler", testSimpleGetCallWithCompletionHandler),
            ("testSimpleGetCallWithDelegate", testSimpleGetCallWithDelegate),
        ]
    }
    
    let delegate = HTTPDelegate()

    func testSimpleGetCallWithCompletionHandler() {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let request = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        let completionExpectation = expectation(description: "HTTP data task with a completion handler")
        let task = session.dataTask(with: request) { data, response, error in
            XCTAssertNil(error)
            XCTAssertEqual(200, (response as? HTTPURLResponse)?.statusCode)
            XCTAssertNotNil(data)
            completionExpectation.fulfill()
        }
        task.resume()
        waitForExpectations(timeout: 10)
    }

    func testSimpleGetCallWithDelegate() {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: nil)
        let request = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        delegate.didReceiveExpectation = expectation(description: "HTTP data task with a delegate")
        let task = session.dataTask(with: request)
        task.resume()
        waitForExpectations(timeout: 10)
    }
}

class HTTPDelegate: NSObject { 
    public var didReceiveExpectation: XCTestExpectation!    
}

extension HTTPDelegate: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didReceiveExpectation.fulfill()
    }
}
