import Foundation
import XCTest
import Dispatch

public class TaskManagement: XCTestCase {
    
    let delegate = TaskManagementDelegate()

    static var allTests: [(String, (TaskManagement) -> () throws -> Void)] {
        return [("testFinishTasksAndInvalidate", testFinishTasksAndInvalidate),
                //("testInvalidateAndCancelTasks", testInvalidateAndCancelTasks)
               ]
    }

    func addTasksAndResume(_ session: URLSession) {
        let dataRequest = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        let dataTask = session.dataTask(with: dataRequest)
        let delegate = session.delegate as? TaskManagementDelegate
        let downloadRequest = URLRequest(url: URL(string: "https://swift.org/LICENSE.txt")!)
        let downloadTask = session.downloadTask(with: downloadRequest)

        delegate?.dataCompletionExpectation = expectation(description: "Data task http://httpbin.org/get")
        delegate?.downloadCompletionExpectation = expectation(description: "Downoad task GET https://swift.org/LICENSE.txt")
        delegate?.finishTasksExpectation = expectation(description: "Finished tasks for current session")

        dataTask.resume()
        downloadTask.resume()
    }

    func testFinishTasksAndInvalidate() {
        let session = URLSession(configuration: .default, delegate: TaskManagementDelegate(), delegateQueue: nil)
        addTasksAndResume(session)
        session.finishTasksAndInvalidate()
        waitForExpectations(timeout: 20)
    }

    func testInvalidateAndCancelTasks() {
        let session = URLSession(configuration: .default, delegate: TaskManagementDelegate(), delegateQueue: nil)
        addTasksAndResume(session)
        session.invalidateAndCancel()
        waitForExpectations(timeout: 20)
    }
}

class TaskManagementDelegate: NSObject {
    var dataCompletionExpectation: XCTestExpectation!
    var downloadCompletionExpectation: XCTestExpectation!
    var finishTasksExpectation: XCTestExpectation!
    var dataTask0: URLSessionDataTask!
}

extension TaskManagementDelegate: URLSessionDelegate { 
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        XCTAssertNil(error)
        finishTasksExpectation.fulfill()
    }
}

extension TaskManagementDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        dataCompletionExpectation.fulfill()
    }
}

extension TaskManagementDelegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo: URL) {
        downloadCompletionExpectation.fulfill()
    }
}
