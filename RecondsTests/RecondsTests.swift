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

    var sut: VideoPlaybackViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        // Arrange
        let viewController = UIStoryboard.record.instantiateViewController(
            withIdentifier: String(describing: VideoPlaybackViewController.self))
        
        // swiftlint:disable force_cast
        let sut = viewController as! VideoPlaybackViewController
        // swiftlint:enable force_cast
        
        sut.loadViewIfNeeded()
        
        self.sut = sut
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

    func test_useButton_IsInitialized() {

        // Assert
        XCTAssertNotNil(sut.useButton, "Button is not being initialized")
    }
    
    func test_IsPressed() {
        
        // Arrange
        let actions = sut.useButton.actions(forTarget: self.sut, forControlEvent: .touchUpInside)

        // Action
        let actualActionMethod = actions?.first
        
        let expectedActionMethod = "useButtonPressed:"
        
        // Assert
        XCTAssertEqual(actualActionMethod, expectedActionMethod)
    }

//    func test_useButton_DidSaveDataToDirectory() {
//
//        // Arrange
//        let unitTestDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("VideoData")
//
//        let time = Int(Date().timeIntervalSince1970)
//
//        let fileName = "\(time).mp4"
//        
//        let dataPath = unitTestDirectory.appendingPathComponent(fileName)
//
//
//
////        sut.useButton.sendActions(for: .touchUpInside)
//    }
}
