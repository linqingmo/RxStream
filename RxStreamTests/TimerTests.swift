//
//  TimerTests.swift
//  RxStream
//
//  Created by Aaron Hayman on 3/29/17.
//  Copyright © 2017 Aaron Hayman. All rights reserved.
//

import XCTest
import Rx

class TimerTests: XCTestCase {
  
  func testBasicTimer() {
    let timer = Rx.Timer(interval: 0.01)

    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)

    timer.start()
    
    wait(for: 0.2)

    XCTAssertGreaterThan(count, 0)
    let last = count
    
    timer.terminate(withReason: .completed)
    
    wait(for: 0.1)
    XCTAssertEqual(count, last, "Timer should no longer be firing")
  }
  
  func testTimerActive() {
    let timer = Rx.Timer(interval: 0.01)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }

    XCTAssertEqual(count, 0)
    XCTAssertTrue(timer.isActive, "The stream should be active.")
    XCTAssertFalse(timer.isTimerActive, "The Timer should not be active.")

    timer.start()
    XCTAssertTrue(timer.isActive, "The stream should be active.")
    XCTAssertTrue(timer.isTimerActive, "The Timer should now be active.")
    
    wait(for: 0.1)
    XCTAssertGreaterThan(count, 0, "Wait for at least 1 fire.")
    
    timer.stop()
    XCTAssertTrue(timer.isActive, "The stream should be active.")
    XCTAssertFalse(timer.isTimerActive, "The Timer should not be active.")
    
    timer.start()
    XCTAssertTrue(timer.isActive, "The stream should be active.")
    XCTAssertTrue(timer.isTimerActive, "The Timer should now be active.")
    
    timer.terminate(withReason: .completed)
    XCTAssertFalse(timer.isActive, "The stream should no longer be active.")
    XCTAssertFalse(timer.isTimerActive, "The Timer should not be active.")
  }
  
  func testTimerRestart() {
    let timer = Rx.Timer(interval: 0.01)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)

    timer.start()
    
    wait(for: 0.1)
    XCTAssertGreaterThan(count, 0)
    let last = count

    timer.restart(withInterval: 0.1)
    
    wait(for: 0.2)
    XCTAssertGreaterThan(count, last)
    XCTAssertLessThan(count, last + 10)
    
    timer.terminate(withReason: .completed)
  }
  
  func testTimerWithNoFirstDelay() {
    let timer = Rx.Timer(interval: 0.01)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)

    timer.start(delayFirst: false)
    XCTAssertEqual(count, 1)
    
    wait(for: 0.2)
    XCTAssertGreaterThan(count, 1)
    
    timer.terminate(withReason: .completed)
  }
  
  func testTimerDealloc() {
    var timer: Rx.Timer? = Rx.Timer(interval: 0.01)
    
    var count: UInt = 0
    timer?.count().on{
      count = $0
    }

    timer?.start()
    
    wait(for: 0.1)
    XCTAssertGreaterThan(count, 0, "Timer should have fired")
    
    timer = nil

    let last = count

    wait(for: 0.2)
    XCTAssertEqual(count, last, "The timer should have been deallocated and no longer firing.")
  }

  func testNewTimerHandler() {
    class TimerTester {
      var fired: Int = 0
      dynamic func fire() { fired += 1 }
    }

    let timer = Rx.Timer(interval: 0.1)
    let tester = TimerTester()
    XCTAssertNotNil(timer.newTimer)

    timer.newTimer = { (interval: TimeInterval, selector: Selector, repeats: Bool) -> Foundation.Timer in
      return Timer.scheduledTimer(timeInterval: interval, target: tester, selector: #selector(TimerTester.fire), userInfo: nil, repeats: false)
    }
    XCTAssertNotNil(timer.newTimer)

    timer.start()

    wait(for: 0.3)

    XCTAssertGreaterThan(tester.fired, 0)
  }

  func testMultiStart() {
    let timer = Rx.Timer(interval: 0.1)
    var fired = 0
    timer.on{ fired += 1 }

    timer.start()
    timer.start()
    timer.start()
    timer.start()

    wait(for: 0.15)

    XCTAssertLessThan(fired, 5)
  }
    
}
