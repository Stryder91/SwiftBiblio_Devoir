import XCTest

import biblioTests

var tests = [XCTestCaseEntry]()
tests += biblioTests.allTests()
XCTMain(tests)