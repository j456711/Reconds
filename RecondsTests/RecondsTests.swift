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
        super.setUp()
    
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
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
    
    func test_FilterData_function() {
        
        // Arrange
        let mockVideoData = MockVideoData()
        mockVideoData.dataPathArray = ["", "1559048802.mp4", "1559048810.mp4", "", "1559048825.mp4", "1559048833.mp4"]
        
        let expectFilteredArray = ["1559048802.mp4", "1559048810.mp4", "1559048825.mp4", "1559048833.mp4"]
        
        // Act
        let filteredArray = mockVideoData.filterData()
        
        // Assert
        XCTAssertEqual(filteredArray, expectFilteredArray)
    }
    
    func test_FilterData_nil() {
        
        // Arrange
        let mockVideoData = MockVideoData()
        mockVideoData.dataPathArray = ["", "", "", ""]
        
        let expectFilteredArray: [String]? = []
        
        // Act
        let filteredArray = mockVideoData.filterData()
        
        // Assert
        XCTAssertEqual(filteredArray, expectFilteredArray)
    }
}

class MockVideoData {
    
    var dataPathArray: [String]?
    
    func filterData() -> [String]? {
        
        let searchToSearch = ".mp4"
        
        if dataPathArray == [] {
            
            return nil
            
        } else {
            
            let filteredArray = dataPathArray?.filter({ (element: String) -> Bool in
                
                let stringMatch = element.lowercased().range(of: searchToSearch.lowercased())
                
                return stringMatch != nil ? true : false
            })
            
            return filteredArray
        }
    }
}
