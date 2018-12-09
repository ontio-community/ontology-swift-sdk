//
//  Signable.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public protocol Signable {
  func signContent() throws -> Data

  func serializeUnsignedData() throws -> Data
}
