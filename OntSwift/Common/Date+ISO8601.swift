//
//  Date+ISO8601.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public extension Date {
  public var iso8601: String {
    if #available(iOS 11.0, *) {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions.insert(.withInternetDateTime)
      formatter.formatOptions.insert(.withFractionalSeconds)
      return formatter.string(from: self)
    } else {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
      return formatter.string(from: self)
    }
  }
}
