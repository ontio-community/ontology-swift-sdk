//
//  Struct.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Struct {
  public var list: [Any] = []

  public func add(params: Any...) {
    for p in params {
      list.append(p)
    }
  }

  public class RawField {
    public let type: Int
    public let bytes: Data

    public init(type: Int, bytes: Data) {
      self.type = type
      self.bytes = bytes
    }
  }
}
