//
//  Payload.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public protocol Payload {
  func serialize() throws -> Data
  func deserialize<T>(r: T) throws -> Void where T: ScriptReader
}
