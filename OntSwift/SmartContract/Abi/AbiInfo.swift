//
//  AbiInfo.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class AbiInfo: Decodable {
  public let hash: String?
  public let entrypoint: String?
  public private(set) var functions: [AbiFunction] = []

  public init(hash: String?, entrypoint: String?) {
    self.hash = hash
    self.entrypoint = entrypoint
  }

  public enum CodingKeys: String, CodingKey {
    case hash, entrypoint, functions
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let hash = try container.decodeIfPresent(String.self, forKey: .hash)
    let entrypoint = try container.decodeIfPresent(String.self, forKey: .entrypoint)

    self.init(hash: hash, entrypoint: entrypoint)

    var functionsContaienr = try container.nestedUnkeyedContainer(forKey: .functions)
    while !functionsContaienr.isAtEnd {
      functions.append(try functionsContaienr.decode(AbiFunction.self))
    }
  }

  public func function(name: String) -> AbiFunction? {
    for fn in functions {
      if fn.name == name {
        return fn
      }
    }
    return nil
  }
}

public class AbiFile: Decodable {
  public let contractHash: String
  public let abi: AbiInfo

  public init(contractHash: String, abi: AbiInfo) {
    self.contractHash = contractHash
    self.abi = abi
  }

  public enum CodingKeys: String, CodingKey {
    case contractHash, abi
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let contractHash = try container.decode(String.self, forKey: .contractHash)
    let abi = try container.decode(AbiInfo.self, forKey: .abi)

    self.init(contractHash: contractHash, abi: abi)
  }
}

public enum AbiInfoError: Error {
  case deformedAbi
}
