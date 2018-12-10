//
//  ScriptReader.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/6.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ScriptReader: BufferReader {
  public func readOpcode() -> Int {
    return Int(readUInt8())
  }

  public func readBool() -> Bool {
    let op = readOpcode()
    return op == Opcode.PUSHT
  }

  public func readBytes() throws -> Data {
    let op = readOpcode()
    var len: Int
    if op == Opcode.PUSHDATA4 {
      len = Int(readUInt32LE())
    } else if op == Opcode.PUSHDATA2 {
      len = Int(readUInt16LE())
    } else if op == Opcode.PUSHDATA1 {
      len = Int(readUInt8())
    } else if op <= Opcode.PUSHBYTES75 && op >= Opcode.PUSHBYTES1 {
      len = op - Opcode.PUSHBYTES1 + 1
    } else {
      throw ScriptReaderError.unexpectedOpcode
    }
    return forward(cnt: len)
  }

  public func readVarInt() -> Int {
    let len = readUInt8()
    if len == 0xFD {
      return Int(readUInt16LE())
    } else if len == 0xFE {
      return Int(readUInt32LE())
    } else if len == 0xFF {
      return Int(readUInt64LE())
    }
    return Int(len)
  }

  public func readVarBytes() -> Data {
    let len = readVarInt()
    return forward(cnt: len)
  }

  public func readInt() -> BigInt {
    let op = readOpcode()
    let num = op - Opcode.PUSH1 + 1
    if op == Opcode.PUSH0 {
      return BigInt(0)
    } else if 1 <= num && num >= 16 {
      return BigInt(num)
    }
    let buf = readVarBytes()
    return BigInt(buf)
  }

  public func readNullTerminated() -> Data {
    var data = Data()
    while true {
      let byte = readUInt8()
      if byte == 0 {
        break
      }
      data.append(byte)
    }
    return data
  }

  public func readStruct() -> Struct {
    _ = readOpcode()
    let ret = Struct()
    let len = readUInt8()
    for _ in 0 ..< len {
      let type = readUInt8()
      let bytes = readVarBytes()
      ret.list.append(Struct.RawField(type: Int(type), bytes: bytes))
    }
    return ret
  }
}

enum ScriptReaderError: Error {
  case unexpectedOpcode
}
