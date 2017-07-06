import XCTest
@testable import urlsession_testsTests

XCTMain([
    testCase(HTTPDataTask.allTests),
    testCase(HTTPDownloadTask.allTests),
    testCase(HTTPUploadTask.allTests),
    testCase(ConcurrentHTTPTasks.allTests),
])
