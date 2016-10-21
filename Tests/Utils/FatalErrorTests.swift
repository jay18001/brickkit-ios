//
//  FatalErrorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

private var locked = false
private let timeInterval: NSTimeInterval = 0.2
private let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
private var expectation: XCTestExpectation!
private var assertionMessage: String?

@noreturn func testFatalError(message: String = "", file: StaticString = #file, line: UInt = #line) {
    expectation.fulfill()
    assertionMessage = message
    unreachable()
}

// This is a `noreturn` function that pauses forever
@noreturn func unreachable() {
    repeat {
        NSRunLoop.currentRunLoop().run()
    } while (true)
}

extension XCTestCase {

    func unlockFatalError() {
        expectation = nil
    }

    func expectFatalError(expectedMessage: String? = nil, testcase: () -> Void) {
//        return
        
        repeat {
            if !NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: timeInterval)) {
                NSThread.sleepForTimeInterval(timeInterval)
            }
        } while(expectation != nil)

        expectation = expectationWithDescription("expectingFatalError")

        FatalErrorUtil.replaceFatalError(testFatalError)

        // act, perform on separate thead because a call to fatalError pauses forever
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), testcase)

        waitForExpectationsWithTimeout(5) { _ in
            defer {
                expectation = nil
            }

            if let message  = expectedMessage {
                // assert
                XCTAssertEqual(assertionMessage, message)
            }

            // clean up
//            FatalErrorUtil.restoreFatalError()
        }
    }
}
