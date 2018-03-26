import XCTest

import CompressionTests

var tests = [XCTestCaseEntry]()
tests += CompressionTests.__allTests()

XCTMain(tests)
