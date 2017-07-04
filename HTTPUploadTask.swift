import Foundation
import XCTest

//Upload a file, download it back and then delete it
//Using https://www.posttestserver.com for now!

class HTTPUploadTask: XCTestCase {
    static var allTests: [(String, (HTTPUploadTask)->() throws -> Void)] {
        return [("testUploadWithCompletionHandler", testUploadWithCompletionHandler)]
    }

    func testUploadWithCompletionHandler() {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL(string: "http://posttestserver.com/post.php")!)    
        request.httpMethod = "POST"
        
        let uploadDataExpectation = expectation(description: "Upload data to http://posttestserver.com")
        var fileData: Data!
        do {
            fileData =  try Data(contentsOf: URL(fileURLWithPath: "./README.md"))
        } catch {} 

        let task = session.uploadTask(with: request, from: fileData) { _, response, error in
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            //TODO: assert response code is 200
            uploadDataExpectation.fulfill()
        }

        task.resume()
        waitForExpectations(timeout: 10)
    }
}

