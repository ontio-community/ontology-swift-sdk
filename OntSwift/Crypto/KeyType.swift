//
//  KeyType.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/11/29.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public enum KeyType: CustomStringConvertible {
  case ecdsa, sm2, eddsa

  var value: Int {
    switch self {
    case .ecdsa: return 0x12
    case .sm2: return 0x13
    case .eddsa: return 0x14
    }
  }

  var label: String {
    switch self {
    case .ecdsa: return "ECDSA"
    case .sm2: return "SM2"
    case .eddsa: return "EDDSA"
    }
  }

  var defaultScheme: SignatureScheme {
    switch self {
    case .ecdsa: return .ecdsaSha256
    case .sm2: return .sm2Sm3
    case .eddsa: return .eddsaSha512
    }
  }

  public var description: String {
    return label
  }

  public static func from(_ label: String) throws -> KeyType {
    switch label {
    case "ECDSA": return .ecdsa
    case "SM2": return .sm2
    case "EDDSA": return .eddsa
    default:
      throw KeyTypeError.invalidLabel
    }
  }

  public static func from(_ value: Int) throws -> KeyType {
    switch value {
    case 0x12: return .ecdsa
    case 0x13: return .sm2
    case 0x14: return .eddsa
    default:
      throw KeyTypeError.invalidValue
    }
  }
}

public enum KeyTypeError: Error {
  case invalidLabel
  case invalidValue
}
