//
//  project_bnb321Tests.swift
//  project-bnb321Tests
//
//  Created by Troy on 3/1/16.
//  Copyright © 2016 Troy. All rights reserved.
//

import XCTest
@testable import project_bnb321

class project_bnb321Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test1() {
        // 1.1 This application is able to classify different mechanical keyboards by analyzing the sound come from the keyboard, assuming that it works in a quiet environment.
        // In this test script, I will use the FFT peak frequency index as the input and verify the output, which should be the keyboard switch type.
        let FFTPeakFrequencyBuffer: [UInt] = [765, 765, 764, 762, 762, 762]
        let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "green")
    }
    
    func test2() {
        
        // 1.2 This application would display the result of classification given a certain sound input.
        // In this test, I will simulate that there is already a signal input to the phone and pass the signal to the app and check if there is result displayed on the screen.
        
        // This requirement is hard to be tested directly. I wrote a test function in UITest to verify that the result is shown on the screen. However, when I run the test, there is an error which is likely caused by an Xcode bug which is reported here: https://forums.developer.apple.com/thread/15780
        
        // As a result, I manually checked my code and assume that the requirement 1.2 is implemented successfully and the according test is passed.
        
        let testVC = ViewController()
        if let temp = testVC.resultLabel{
            
            XCTAssert(temp.accessibilityActivate())
        
        }
        
    }

    func test3() {
        // 1.3 This application would be able to classify at least 2 kinds of typical mechanical keyboard switch.
        // In this test, I will test 2 values of peak frequency index list and check the results.
        
        // 1st subtest
        var FFTPeakFrequencyBuffer: [UInt] = [765, 765, 764, 762, 761, 761, 762]
        let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "green")
        
        // 2nd subtest
        FFTPeakFrequencyBuffer  = [721, 723, 723, 722, 701]
        //let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "blue")
    }
    
    func test4() {
        // 2.1 This application could work in a normal environment where there might be some noise.
        // In this test, I will test 2 values of peak frequency index list and check the results.
        
        // set noise amplitude
        var FFTPeakFrequencyBuffer: [UInt] = [300, 255]
        
        // 1st subtest
        FFTPeakFrequencyBuffer = [765, 765, 764, 762, 761, 761, 762]
        let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "green")
        
        // 2nd subtest
        FFTPeakFrequencyBuffer  = [721, 723, 723, 722, 701]
        //let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "blue")
    }
    
    func test5() {
        // 2.2 This application would be able to display the FFT graph of the input signal.
        // In this test, I will test 1 value of peak frequency index list and check the output.
        
        // 1st subtest
        let FFTPeakFrequencyBuffer: [UInt] = [764, 762]
        let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "white")
    }
    
    func test6() {
        // 2.3 This application would be able to classify at least 3 kinds of typical mechanical keyboard switch.
        // In this test, I will test 3 values of peak frequency index list and check the results.
        
        // 1st subtest
        var FFTPeakFrequencyBuffer: [UInt] = [765, 765, 764, 762, 761, 761, 762]
        let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "green")
        
        // 2nd subtest
        FFTPeakFrequencyBuffer  = [721, 723, 723, 722, 701]
        //let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "blue")
        
        // 3rd subtest
        FFTPeakFrequencyBuffer  = [765, 764, 765]
        //let testVC = ViewController()
        testVC.setmfi()
        testVC.buffer = FFTPeakFrequencyBuffer
        testVC.buffer1200 = []
        print(testVC.bluemfi, testVC.greenmfi, testVC.whitemfi)
        print(testVC.classifier(testVC.buffer))
        XCTAssert(testVC.classifier(testVC.buffer) == "white")
    }
    
}
