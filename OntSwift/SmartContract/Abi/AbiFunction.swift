//
//  AbiFunction.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class AbiFunction: Codable {
  public var name = ""
  public var returnType = "any"
  public var parameters: [AbiParameter] = []

  public func get(parameter: String) -> AbiParameter? {
    for p in parameters {
      if p.name == parameter {
        return p
      }
    }
    return nil
  }

  public func set(parameters: AbiParameter...) -> Bool {
    for p in parameters {
      let fp = get(parameter: p.name)
      if fp == nil {
        return false
      }
      if !fp!.set(value: p) {
        return false
      }
    }
    return true
  }

  public enum CodingKeys: String, CodingKey {
    case name, returnType, parameters
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(returnType, forKey: .returnType)

    var parametersContainer = container.nestedUnkeyedContainer(forKey: .parameters)
    try parameters.forEach {
      try parametersContainer.encode($0)
    }
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    returnType = try container.decode(String.self, forKey: .returnType)

    var parametersContainer = try container.nestedUnkeyedContainer(forKey: .parameters)
    while !parametersContainer.isAtEnd {
      parameters.append(try parametersContainer.decode(AbiParameter.self))
    }
  }
}
