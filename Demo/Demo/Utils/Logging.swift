//
//  Logging.swift
//  Demo
//
//  Created by Lshiva on 04/12/2020.
//

import Foundation

public func DLog<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
  #if DEBUG
    let queue = Thread.isMainThread ? "UI" : "BG"
    print("<\(queue)>: \(object())")
  #endif
}
