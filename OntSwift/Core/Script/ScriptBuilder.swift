//
//  ScriptBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ScriptBuilder {
  public private(set) var buf: Data = Data()

  public func push(int: Int, len: Int = 1, endian: Endian = .big) throws -> ScriptBuilder {
    switch len {
    case 1:
      buf.append(UInt8(int))
    case 2:
      buf.append(UInt16(int), endian: endian)
    case 4:
      buf.append(UInt32(int), endian: endian)
    case 8:
      buf.append(UInt64(int), endian: endian)
    default:
      throw ScriptBuilderError.invalidIntLen
    }
    return self
  }

  public func push(b: Bool) throws -> ScriptBuilder {
    return try push(int: Int(b ? OpCode.PUSHT : OpCode.PUSHF))
  }

  public func push(bytes: Data) -> ScriptBuilder {
    buf.append(bytes)
    return self
  }

  public func push(varint: Int) throws -> ScriptBuilder {
    if varint < 0xFD {
      _ = try push(int: varint)
    } else if varint < 0xFFFF {
      _ = try push(int: 0xFD)
      _ = try push(int: varint, len: 2, endian: .little)
    } else if varint < 0xFFFF_FFFF {
      _ = try push(int: 0xFE)
      _ = try push(int: varint, len: 4, endian: .little)
    } else {
      _ = try push(int: 0xFF)
      _ = try push(int: varint, len: 8, endian: .little)
    }
    return self
  }

  public func push(varbytes: Data) throws -> ScriptBuilder {
    _ = try push(varint: varbytes.count)
    return push(bytes: varbytes)
  }

  public func push(pubkey: PublicKey) throws -> ScriptBuilder {
    switch pubkey.algorithm {
    case .ecdsa:
      _ = try push(varbytes: pubkey.raw)
    case .eddsa, .sm2:
      let b = ScriptBuilder()
      _ = try b.push(int: pubkey.algorithm.value)
      _ = try b.push(int: pubkey.parameters.curve.value)
      _ = b.push(bytes: pubkey.raw)
      _ = try push(varbytes: b.buf)
    }
    return self
  }

  public func push(opcode: UInt8) throws -> ScriptBuilder {
    return try push(int: Int(opcode))
  }
}

public enum ScriptBuilderError: Error {
  case invalidIntLen
}
