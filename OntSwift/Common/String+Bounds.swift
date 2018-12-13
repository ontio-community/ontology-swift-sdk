//
//  String+Bounds.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public extension String {
  subscript(bounds: CountableClosedRange<Int>) -> String {
    let start = index(startIndex, offsetBy: bounds.lowerBound)
    let end = index(startIndex, offsetBy: bounds.upperBound)
    return String(self[start ... end])
  }

  subscript(bounds: CountableRange<Int>) -> String {
    let start = index(startIndex, offsetBy: bounds.lowerBound)
    let end = index(startIndex, offsetBy: bounds.upperBound)
    return String(self[start ..< end])
  }

  public func indexOf<T>(stuff: T) -> Int where T: StringProtocol {
    let r = range(of: stuff)
    guard let rr = r else {
      return -1
    }
    return rr.lowerBound.encodedOffset
  }

  public func substr(start: Int, len: Int) -> String {
    assert(len >= 0)
    if len == 0 {
      return ""
    }
    var begin = start >= 0 ? start : count + start
    begin = min(begin, endIndex.encodedOffset)
    var end = begin + len
    end = min(end, endIndex.encodedOffset)
    return self[begin ..< end]
  }
}
