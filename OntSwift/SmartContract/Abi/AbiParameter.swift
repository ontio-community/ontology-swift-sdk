//
//  Parameter.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class AbiParameter: Codable {
  public let name: String
  public let type: Typ
  public private(set) var value: Value

  public init(name: String, type: Typ, value: Value) {
    self.name = name
    self.type = type
    self.value = value
  }

  /// Sets the value of parameter
  ///
  /// - Parameter value: The right value of the assigment, it's type is AbiParameter to include meta info
  /// - Returns: Bool
  public func set(value: AbiParameter) -> Bool {
    if value.type == type && value.name == name {
      self.value = value.value
      return true
    }
    return false
  }

  public enum CodingKeys: String, CodingKey {
    case name, type, value
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    let typ = try container.decode(String.self, forKey: .type)
    type = try Typ.frome(name: typ)
    if let val = try? container.decode(String.self, forKey: .value) {
      value = Value.string(val)
    } else if let val = try? container.decode(Int.self, forKey: .value) {
      value = Value.int(val)
    } else if let val = try? container.decode(Data.self, forKey: .value) {
      value = Value.bytes(val)
    }
    throw AbiParameterError.unsupportedValue
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(type.name, forKey: .type)
    try container.encode(value, forKey: .value)
  }

  public enum Value: Codable {
    case string(String)
    case int(Int)
    case long(BigInt)
    case bytes(Data)
    case bool(Bool)

    var assocValue: Any {
      switch self {
      case let .string(v):
        return v
      case let .int(v):
        return v
      case let .long(v):
        return v
      case let .bool(v):
        return v
      case let .bytes(v):
        return v
      }
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let v = try? container.decode(String.self) {
        self = .string(v)
      } else if let v = try? container.decode(BigInt.self) {
        self = .long(v)
      } else if let v = try? container.decode(Int.self) {
        self = .int(v)
      } else if let v = try? container.decode(Bool.self) {
        self = .bool(v)
      } else if let v = try? container.decode(Data.self) {
        self = .bytes(v)
      }
      throw AbiParameterError.unsupportedValue
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case let .string(v):
        try container.encode(v)
      case let .int(v):
        try container.encode(v)
      case let .long(v):
        try container.encode(v)
      case let .bool(v):
        try container.encode(v)
      case let .bytes(v):
        try container.encode(v)
      }
    }
  }

  public enum Typ {
    case boolean, integer, byteArray, interface, array
    case structure, map, string, int, long, intArray, longArray
    case address

    public static func frome(name: String) throws -> Typ {
      switch name {
      case "Boolean": return .boolean
      case "Integer": return .integer
      case "ByteArray": return .byteArray
      case "Interface": return .interface
      case "Array": return .array
      case "Struct": return .structure
      case "Map": return .map
      case "String": return .string
      case "Int": return .int
      case "Long": return .long
      case "IntArray": return .intArray
      case "LongArray": return .longArray
      case "Address": return .address
      default:
        throw AbiParameterError.unsupportedTypeName
      }
    }

    var name: String {
      switch self {
      case .boolean: return "Boolean"
      case .integer: return "Integer"
      case .byteArray: return "ByteArray"
      case .interface: return "Interface"
      case .array: return "Array"
      case .structure: return "Struct"
      case .map: return "Map"
      case .string: return "String"
      case .int: return "Int"
      case .long: return "Long"
      case .intArray: return "IntArray"
      case .longArray: return "LoingArray"
      case .address: return "Address"
      }
    }

    public func value() throws -> Int {
      switch self {
      case .byteArray: return 0x00
      case .boolean: return 0x01
      case .integer: return 0x02
      case .interface: return 0x40
      case .array: return 0x80
      case .structure: return 0x81
      case .map: return 0x82
      default:
        throw AbiParameterError.unsupportedTypeValue
      }
    }
  }
}

public enum AbiParameterError: Error {
  case unsupportedTypeValue, unsupportedTypeName, unsupportedValue
}
