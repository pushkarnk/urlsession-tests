import Foundation
import XCTest


class ConcurrentHTTPTasks: XCTestCase {

    static var allTests: [(String, (ConcurrentHTTPTasks) -> () throws -> Void)] {
        return [("testConcurrentTasksWithHandlers", testConcurrentTasksWithHandlers)]
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

        var fileData: Data!
        do {
            fileData =  try Data(contentsOf: URL(fileURLWithPath: "./README.md"))
        } catch {}

        let uploadTask = session.uploadTask(with: uploadRequest, from: fileData) { _, response, error in
            XCTAssertNotNil(response)
            uploadTaskCompleted.fulfill()
        }
 
        downloadTask.resume()
        uploadTask.resume()
        dataTask.resume()  

        waitForExpectations(timeout: 20)
    }   
}
  

