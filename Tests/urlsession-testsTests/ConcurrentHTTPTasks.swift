import Foundation
import XCTest


class ConcurrentHTTPTasks: XCTestCase {

    let concurrentTasksDelegate = ConcurrentTasksDelegate()

    static var allTests: [(String, (ConcurrentHTTPTasks) -> () throws -> Void)] {
        return [("testConcurrentTasksWithHandlers", testConcurrentTasksWithHandlers),
                ("testConcurrentTasksWithDelegates", testConcurrentTasksWithDelegates),
               ]
    }
    
    func testConcurrentTasksWithHandlers() {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let dataTaskCompleted = expectation(description: "Data task completion")
        let downloadTaskCompleted = expectation(description: "Download task completion")
        let uploadTaskCompleted = expectation(description: "Upload task completion")

        let dataRequest = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        let dataTask = session.dataTask(with: dataRequest) { data, _, _ in 
            XCTAssertNotNil(data)
            dataTaskCompleted.fulfill()
        } 

        let downloadRequest = URLRequest(url: URL(string: "https://swift.org/LICENSE.txt")!)
        let downloadTask = session.downloadTask(with: downloadRequest) { url, _, _ in
            XCTAssertNotNil(url)
            downloadTaskCompleted.fulfill()
        }
      
        var uploadRequest = URLRequest(url: URL(string: "http://posttestserver.com/post.php")!)
        uploadRequest.httpMethod = "POST"

        let fileData = Data(count: 4096)

        let uploadTask = session.uploadTask(with: uploadRequest, from: fileData) { _, response, error in
            XCTAssertNotNil(response)
            uploadTaskCompleted.fulfill()
        }

        downloadTask.resume()
        uploadTask.resume()
        dataTask.resume()  

        waitForExpectations(timeout: 20)
    }   

    func testConcurrentTasksWithDelegates() {

        let session = URLSession(configuration: .default, delegate: concurrentTasksDelegate, delegateQueue: nil)
        let dataRequest = URLRequest(url: URL(string: "http://httpbin.org/get")!)
        let dataTask = session.dataTask(with: dataRequest)

        let downloadRequest = URLRequest(url: URL(string: "https://swift.org/LICENSE.txt")!)
        let downloadTask = session.downloadTask(with: downloadRequest)

        var uploadRequest = URLRequest(url: URL(string: "http://posttestserver.com/post.php")!)
        uploadRequest.httpMethod = "POST"

        let fileData = Data(count: 4096)
        let uploadTask = session.uploadTask(with: uploadRequest, from: fileData)

        concurrentTasksDelegate.dataCompletionExpectation = expectation(description: "Data task http://httpbin.org/get")
        concurrentTasksDelegate.downloadCompletionExpectation = expectation(description: "Downloading https://swift.org/LICENSE.txt")
        concurrentTasksDelegate.uploadCompletionExpectation = expectation(description: "Uploading to http://posttestserver.com/post.php")

        dataTask.resume()
        downloadTask.resume()
        uploadTask.resume()

        waitForExpectations(timeout: 20)
    }
}

class ConcurrentTasksDelegate: NSObject {
    var downloadCompletionExpectation: XCTestExpectation!
    var dataCompletionExpectation: XCTestExpectation!
    var uploadCompletionExpectation: XCTestExpectation!
}

extension ConcurrentTasksDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask is URLSessionUploadTask {
            uploadCompletionExpectation?.fulfill()
        } else {
            dataCompletionExpectation?.fulfill()
        }
    }  
}

extension ConcurrentTasksDelegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        downloadCompletionExpectation?.fulfill()
    }
}
