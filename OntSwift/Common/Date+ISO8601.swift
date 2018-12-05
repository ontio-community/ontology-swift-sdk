//
//  Date+ISO8601.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

extension Date {
  var iso8601: String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withInternetDateTime)
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter.string(from: self)
  }
}
