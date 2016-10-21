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

extension XCTestCase {

    func expectFatalError(expectedMessage: String? = nil, testcase: () -> Void) {

        repeat {
            sleep(1)
//            NSRunLoop.currentRunLoop().runMode(NSRunLoopCommonModes, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
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
