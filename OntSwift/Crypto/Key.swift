//
//  Key.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/11/30.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import OpenSSL

public class Key {
  public let algorithm: KeyType

  public let parameters: KeyParameters

  public let raw: Data

  public init(raw: Data, algorithm: KeyType?, parameters: KeyParameters?) throws {
    self.raw = raw

    self.algorithm = algorithm == nil ?
      try KeyType.from(Constant.defaultAlgorithm["algorithm"].string!) : algorithm!

    self.parameters = parameters == nil ?
      try KeyParameters.from(curve: Constant.defaultAlgorithm[["parameters", "curve"]].string!) : parameters!
  }

  public func computeHash(data: Data, scheme: SignatureScheme) throws -> Data {
    return try Hash.compute(data: data, algo: scheme.hashAlgo)
  }
}
