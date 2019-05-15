//
//  RecondsTests.swift
//  RecondsTests
//
//  Created by YU HSIN YEH on 2019/5/13.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import XCTest
@testable import Reconds

class RecondsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
        
    }

    // swiftlint:disable identifier_name
    
//    func fibonacci(n: Int) -> Int {
//
//        if n <= 1 {
//
//            return 1
//
//        } else if n < 0 {
//
//            return 0
//        }
//
//        var array: [Int] = Array(repeating: 1, count: n + 1)
//
//        print("------", array)
//
//        for i in 0...n {
//
//            if i <= 1 {
//
//                array[i] = 1
//
//            } else {
//
//                array[i] = array[i - 1] + array[i - 2]
//            }
//        }
//
//        print(array)
//
//        return array[n]
//    }
//
//    func testFibonacci() {
//
//        let expectResult = 0
//
//        let actualResult = fibonacci(n: 1)
//
//        XCTAssertEqual(actualResult, expectResult)
//    }
//
//    func testCorrect() {
//
//        let n8 = fibonacci(n: 8)
//        let n9 = fibonacci(n: 9)
//        let n10 = fibonacci(n: 10)
//
//        XCTAssertEqual(n10, n8 + n9)
//    }
//
//    func testNegative() {
//
//        let expectResult = 1
//
//        let actualResult = fibonacci(n: -1)
//
//        XCTAssertEqual(actualResult, expectResult)
//    }
    
    // swiftlint:enable identifier_name
    
}
