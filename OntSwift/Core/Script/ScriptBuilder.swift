//
//  ScriptBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ScriptBuilder {
  public internal(set) var buf: Data = Data()

  public func push(num: Int, len: Int = 1, endian: Endian = .big) throws -> Self {
    switch len {
    case 1:
      buf.append(UInt8(num))
    case 2:
      buf.append(UInt16(num), endian: endian)
    case 4:
      buf.append(UInt32(num), endian: endian)
    case 8:
      buf.append(UInt64(num), endian: endian)
    default:
      throw ScriptBuilderError.invalidIntLen
    }
    return self
  }

  public func push(b: Bool) throws -> Self {
    return try push(num: Int(b ? Opcode.PUSHT : Opcode.PUSHF))
  }

  public func push(rawbytes: Data) -> Self {
    buf.append(rawbytes)
    return self
  }

  public func push(varint: Int) throws -> Self {
    if varint < 0xFD {
      _ = try push(num: varint)
    } else if varint < 0xFFFF {
      _ = try push(num: 0xFD)
      _ = try push(num: varint, len: 2, endian: .little)
    } else if varint < UInt(0xFFFF_FFFF) {
      _ = try push(num: 0xFE)
      _ = try push(num: varint, len: 4, endian: .little)
    } else {
      _ = try push(num: 0xFF)
      _ = try push(num: varint, len: 8, endian: .little)
    }
    return self
  }

  public func push(varbytes: Data) throws -> Self {
    _ = try push(varint: varbytes.count)
    return push(rawbytes: varbytes)
  }

  public func push(int: Int) throws -> Self {
    if int == -1 {
      _ = try push(num: Opcode.PUSHM1)
    } else if int == 0 {
      _ = try push(num: Opcode.PUSH0)
    } else if int > 0 && int < 16 {
      _ = try push(num: Opcode.PUSH1 - 1 + int)
    } else {
      let bi = BigInt(int)
      _ = try push(bigint: bi)
    }
    return self
  }

  public func push(bigint: BigInt) throws -> Self {
    if bigint == BigInt(-1) {
      _ = try push(num: Opcode.PUSHM1)
    } else if bigint == BigInt(0) {
      _ = try push(num: Opcode.PUSH0)
    } else if bigint > BigInt(0) && bigint < BigInt(16) {
      _ = try push(num: Opcode.PUSH1 - 1 + bigint.int64!)
    } else {
      _ = try push(hex: bigint.bytes)
    }
    return self
  }

  public func push(hex: Data) throws -> Self {
    let len = hex.count
    if len < Opcode.PUSHBYTES75 {
      _ = try push(num: len)
    } else if len < 0x100 {
      _ = try push(num: Opcode.PUSHDATA1)
      _ = try push(num: len)
    } else if len < 0x10000 {
      _ = try push(num: Opcode.PUSHDATA2)
      _ = try push(num: len, len: 2, endian: .little)
    } else {
      _ = try push(num: Opcode.PUSHDATA4)
      _ = try push(num: len, len: 4, endian: .little)
    }
    _ = push(rawbytes: hex)
    return self
  }

  public func push(hex: String) throws -> Self {
    return try push(hex: Data.from(hex: hex)!)
  }

  public func push(address: Address) throws -> Self {
    return try push(hex: address.value)
  }

  public func push(opcode: Int) throws -> Self {
    return try push(num: opcode)
  }

  public func push(map: [String: AbiParameter]) throws -> Self {
    _ = try push(num: AbiParameter.Typ.map.value())
    _ = try push(num: map.count)

    for (key, val) in map {
      _ = try push(num: AbiParameter.Typ.byteArray.value())
      _ = try push(hex: key.data(using: .utf8)!)

      switch val.type {
      case .byteArray:
        _ = try push(num: AbiParameter.Typ.byteArray.value())
        guard let val = val.value!.assocValue as? Data else {
          throw ScriptBuilderError.invalidParams
        }
        _ = try push(hex: val)
      case .string:
        _ = try push(num: AbiParameter.Typ.byteArray.value())
        guard let val = val.value!.assocValue as? String else {
          throw ScriptBuilderError.invalidParams
        }
        _ = try push(hex: val.data(using: .utf8)!)
      case .integer:
        _ = try push(num: AbiParameter.Typ.integer.value())
        guard let val = val.value!.assocValue as? Int else {
          throw ScriptBuilderError.invalidParams
        }
        let b = ScriptBuilder()
        _ = try b.push(varint: val)
        _ = try push(hex: b.buf)
      case .long:
        _ = try push(num: AbiParameter.Typ.long.value())
        guard let val = val.value!.assocValue as? BigInt else {
          throw ScriptBuilderError.invalidParams
        }
        let b = ScriptBuilder()
        _ = try b.push(bigint: val)
        _ = try push(hex: b.buf)
      default:
        throw ScriptBuilderError.invalidParams
      }
    }
    return self
  }

  public func push(structure: Struct) throws -> Self {
    _ = try push(num: AbiParameter.Typ.structure.value())
    _ = try push(num: structure.list.count)
    for item in structure.list {
      switch item {
      case let item as String:
        _ = try push(num: AbiParameter.Typ.byteArray.value())
        _ = try push(hex: item.data(using: .utf8)!)
      case let item as Int:
        _ = try push(num: AbiParameter.Typ.byteArray.value())
        let b = ScriptBuilder()
        _ = try b.push(varint: item)
        _ = try push(hex: b.buf)
      case let item as Data:
        _ = try push(num: AbiParameter.Typ.byteArray.value())
        _ = try push(hex: item)
      default:
        throw ScriptBuilderError.invalidParams
      }
    }
    return self
  }
}

public enum ScriptBuilderError: Error {
  case invalidIntLen, invalidParams
}
