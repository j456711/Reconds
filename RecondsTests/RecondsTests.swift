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

    let sut = DataManager()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        // Arrange
        
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
    
    func test_DataManager_IsInitialized() {
        
        XCTAssertNotNil(sut)
    }
    
    func test_DataManager_DidWriteDataToFileManager() {
        
        let videoUrl = Bundle.main.url(forResource: "Reconds-Music",
                                       withExtension: "bundle")!.appendingPathComponent("Ambler.mp3")
        
//        guard let videoData = try? Data(contentsOf: videoUrl) else { return }
//
//        do {
//
//            try videoData.write(to: <#T##URL#>)
//
//        } catch {
//
//        }
        
        sut.dataSaved(videoUrl: videoUrl, completionHandler: { result in
                
            let directory = try? FileManager.default.contentsOfDirectory(at: FileManager.videoDataDirectory,
                                                                         includingPropertiesForKeys: nil,
                                                                         options: [.skipsHiddenFiles,
                                                                                   .skipsSubdirectoryDescendants])
            
            let count = directory!.count
            
            switch result {
                
            case .success:
                XCTAssertEqual(count, 1)
                
            case .failure(let error):
                print(error)
            }
        })
    }
}
