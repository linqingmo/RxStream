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
    let timer = Rx.Timer(interval: 0.1)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)
    
    timer.start()
    
    wait(for: 0.11)
    XCTAssertEqual(count, 1)
    
    wait(for: 0.11)
    XCTAssertEqual(count, 2)
    
    timer.terminate(withReason: .completed)
    
    wait(for: 0.11)
    XCTAssertEqual(count, 2, "Timer should no longer be firing")
  }
  
  func testTimerActive() {
    let timer = Rx.Timer(interval: 0.1)
    
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
    
    wait(for: 0.11)
    XCTAssertEqual(count, 1, "Wait for at least 1 fire.")
    
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
    let timer = Rx.Timer(interval: 0.1)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)
    
    timer.start()
    
    wait(for: 0.11)
    XCTAssertEqual(count, 1)
    
    timer.restart(withInterval: 0.2)
    
    wait(for: 0.11)
    XCTAssertEqual(count, 1)
    
    wait(for: 0.1)
    XCTAssertEqual(count, 2)
    
    timer.terminate(withReason: .completed)
  }
  
  func testTimerWithNoFirstDelay() {
    let timer = Rx.Timer(interval: 0.1)
    
    var count: UInt = 0
    timer.count().on{
      count = $0
    }
    XCTAssertEqual(count, 0)
    
    timer.start(delayFirst: false)
    XCTAssertEqual(count, 1)
    
    wait(for: 0.11)
    XCTAssertEqual(count, 2)
    
    timer.terminate(withReason: .completed)
  }
  
  func testTimerDealloc() {
    var timer: Rx.Timer? = Rx.Timer(interval: 0.1)
    
    var count: UInt = 0
    timer?.count().on{
      count = $0
    }
    
    timer?.start()
    
    wait(for: 0.11)
    XCTAssertEqual(count, 1, "Timer should have fired")
    
    timer = nil
    
    wait(for: 0.2)
    XCTAssertEqual(count, 1, "The timer should have been deallocated and no longer firing.")
  }
    
}