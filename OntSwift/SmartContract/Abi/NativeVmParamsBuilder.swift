//
//  NativeVmParamsBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class NativeVmParamsBuilder: ScriptBuilder {
  public func pushCodeParamScript(obj: Any) throws -> Self {
    switch obj {
    case let obj as String:
      _ = try push(hex: obj)
    case let obj as Data:
      _ = try push(hex: obj)
    case let obj as Bool:
      _ = try push(b: obj)
    case let obj as Int:
      _ = try push(int: obj)
    case let obj as BigInt:
      _ = try push(bigint: obj)
    case let obj as Address:
      _ = try push(address: obj)
    case let obj as Struct:
      try obj.list.forEach {
        _ = try pushCodeParamScript(obj: $0)
        _ = try push(int: Opcode.DUPFROMALTSTACK)
        _ = try push(int: Opcode.SWAP)
        _ = try push(int: Opcode.APPEND)
      }
    default:
      throw NativeVmParamsBuilderError.unsupportedParamType
    }
    return self
  }

  public func pushNativeCodeScript(objs: [Any]) throws -> Self {
    for obj in objs {
      switch obj {
      case let obj as String:
        _ = try push(hex: obj)
      case let obj as Data:
        _ = try push(hex: obj)
      case let obj as Bool:
        _ = try push(b: obj)
      case let obj as Int:
        _ = try push(int: obj)
      case let obj as BigInt:
        _ = try push(bigint: obj)
      case let obj as Struct:
        _ = try push(int: 0)
        _ = try push(opcode: Opcode.NEWSTRUCT)
        _ = try push(opcode: Opcode.TOALTSTACK)
        for item in obj.list {
          _ = try pushCodeParamScript(obj: item)
          _ = try push(opcode: Opcode.DUPFROMALTSTACK)
          _ = try push(opcode: Opcode.SWAP)
          _ = try push(opcode: Opcode.APPEND)
        }
        _ = try push(opcode: Opcode.FROMALTSTACK)
      case let obj as [Struct]:
        _ = try push(int: 0)
        _ = try push(opcode: Opcode.NEWSTRUCT)
        _ = try push(opcode: Opcode.TOALTSTACK)
        for item in obj {
          _ = try pushCodeParamScript(obj: item)
        }
        _ = try push(opcode: Opcode.FROMALTSTACK)
        _ = try push(int: obj.count)
        _ = try push(opcode: Opcode.PACK)
      case let obj as [Any]:
        _ = try pushNativeCodeScript(objs: obj)
        _ = try push(int: obj.count)
        _ = try push(opcode: Opcode.PACK)
      default:
        throw NativeVmParamsBuilderError.unsupportedParamType
      }
    }
    return self
  }

  public func pushCodeParams(objs: [Any]) throws -> Self {
    let objs = objs.reversed()
    for obj in objs {
      switch obj {
      case let obj as String:
        _ = try push(hex: obj)
      case let obj as Data:
        _ = try push(hex: obj)
      case let obj as Int:
        _ = try push(int: obj)
      case let obj as Bool:
        _ = try push(b: obj)
      case let obj as BigInt:
        _ = try push(bigint: obj)
      case let obj as [String: AbiParameter]:
        let b = ScriptBuilder()
        _ = try b.push(map: obj)
        _ = try b.push(hex: b.buf)
      case let obj as Struct:
        let b = ScriptBuilder()
        _ = try b.push(structure: obj)
        _ = try b.push(hex: b.buf)
      case let obj as [Any]:
        _ = try pushCodeParams(objs: obj)
        _ = try push(int: obj.count)
        _ = try push(opcode: Opcode.PACK)
      default:
        throw NativeVmParamsBuilderError.unsupportedParamType
      }
    }
    return self
  }

  public func push(fn: AbiFunction) throws -> Self {
    var list: [Any] = [fn.name.data(using: .utf8)!]
    var params: [Any] = []

    for p in fn.parameters {
      switch p.type {
      case .string:
        guard let val = p.value.assocValue as? String else {
          throw NativeVmParamsBuilderError.invalidParams
        }
        params.append(val.data(using: .utf8)!)
      case .long:
        guard let val = p.value.assocValue as? BigInt else {
          throw NativeVmParamsBuilderError.invalidParams
        }
        params.append(val)
      default:
        params.append(p.value.assocValue)
      }
    }
    list.append(params)
    return try pushCodeParams(objs: list)
  }
}

public enum NativeVmParamsBuilderError: Error {
  case unsupportedParamType, invalidParams
}
