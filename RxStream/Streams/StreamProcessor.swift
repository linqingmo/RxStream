//
//  StreamProcessor.swift
//  RxStream
//
//  Created by Aaron Hayman on 3/17/17.
//  Copyright © 2017 Aaron Hayman. All rights reserved.
//

import Foundation

/**
 Stream processor is a base class used to encapsulate the processing that needs to occur on an event before it is passed downstream. 
 This class also allos a stream to query down stream processors whether the processor should be pruned.
 */
class StreamProcessor<T> {
  var shouldPrune: Bool { return true }
  var streamType: StreamType { return  .base }
  func process(next: Event<T>, withKey key: EventPath) { }
}

/**
 A concrete down stream processor that takes an event, processes it with the provided processor and passes that onto the stream.
 Subclasses should override to implement custom processing logic.
 */
class DownstreamProcessor<T, U> : StreamProcessor<T> {
  var stream: Stream<U>
  var processor: StreamOp<T, U>

  override var streamType: StreamType { return stream.streamType }
  
  override var shouldPrune: Bool { return stream.shouldPrune }
  
  override func process(next: Event<T>, withKey key: EventPath) {
    stream.process(key: key, next: next, withOp: processor)
  }
  
  init(stream: Stream<U>, processor: @escaping StreamOp<T, U>) {
    self.stream = stream
    self.processor = processor
    stream.onTerminate = { processor(.terminate(reason: $0), { _ in }) }
  }
  
}
