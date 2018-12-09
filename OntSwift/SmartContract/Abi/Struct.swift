//
//  Struct.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Struct {
  public private(set) var list: [Any] = []

  public func add(params: Any...) {
    for p in params {
      list.append(p)
    }
  }
}
