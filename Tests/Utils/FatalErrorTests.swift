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
private let timeInterval: NSTimeInterval = 2
private let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)

extension XCTestCase {

    func expectFatalError(expectedMessage: String? = nil, testcase: () -> Void) {

        dispatch_sync(lockQueue) {
            // code
            // arrange
            let expectation = expectationWithDescription("expectingFatalError")
            var assertionMessage: String? = nil

            // override fatalError. This will pause forever when fatalError is called.
            FatalErrorUtil.replaceFatalError { message, _, _ in
                assertionMessage = message
                expectation.fulfill()
            }

            // act, perform on separate thead because a call to fatalError pauses forever
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), testcase)

            waitForExpectationsWithTimeout(5) { _ in
                if let message  = expectedMessage {
                    // assert
                    XCTAssertEqual(assertionMessage, message)
                }

                // clean up
                FatalErrorUtil.restoreFatalError()
            }
        }
    }

    func _expectFatalError(expectedMessage: String? = nil, testcase: () -> Void) {

        repeat {
            if !NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: timeInterval)) {
                NSThread.sleepForTimeInterval(timeInterval)
            }
        } while(locked)

        locked = true

        // arrange
        let expectation = expectationWithDescription("expectingFatalError")
        var assertionMessage: String? = nil

        // override fatalError. This will pause forever when fatalError is called.
        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
        }

        // act, perform on separate thead because a call to fatalError pauses forever
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), testcase)

        waitForExpectationsWithTimeout(5) { _ in
            if let message  = expectedMessage {
                // assert
                XCTAssertEqual(assertionMessage, message)
            }

            // clean up
            FatalErrorUtil.restoreFatalError()
            
            locked = false
        }
    }
}
