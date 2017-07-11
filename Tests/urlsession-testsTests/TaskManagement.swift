import Foundation
import XCTest

public class TaskManagement: XCTestCase {
    
    let delegate = TaskManagementDelegate()

    static var allTests: [(String, (TaskManagement) -> () throws -> Void)] {
        return [("testFinishTasksAndInvalidate", testFinishTasksAndInvalidate)]
    }

    func testFinishTasksAndInvalidate() {

        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

        let dataRequest = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        let dataTask = session.dataTask(with: dataRequest)
        let dataTask0 = session.dataTask(with: dataRequest)

        delegate.dataCompletionExpectation = expectation(description: "Data task http://httpbin.org/get")
        delegate.finishTasksExpectation = expectation(description: "Finished tasks for current session")

        dataTask.resume()
        session.finishTasksAndInvalidate()
        dataTask0.resume()

        waitForExpectations(timeout: 20)
    }
}

class TaskManagementDelegate: NSObject {
    var dataCompletionExpectation: XCTestExpectation!
    var finishTasksExpectation: XCTestExpectation!
}

extension TaskManagementDelegate: URLSessionDelegate { 
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        finishTasksExpectation.fulfill()        
    }
}

extension TaskManagementDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataCompletionExpectation.fulfill()
    }
}
