import XCTest

XCTMain([
    testCase(HTTPDataTask.allTests),
    testCase(HTTPDownloadTask.allTests),
    testCase(HTTPUploadTask.allTests),
    testCase(ConcurrentHTTPTasks.allTests),
])
