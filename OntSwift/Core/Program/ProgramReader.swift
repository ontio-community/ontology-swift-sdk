//
//  ProgramReader.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/6.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ProgramReader: ScriptReader {
  public func readParams() throws -> [Data] {
    var sig: [Data] = []
    while !isEnd {
      sig.append(try readBytes())
    }
    return sig
  }

  public func readPubkey() throws -> PublicKey {
    let bytes = readVarBytes()
    return try PublicKey.from(bytes: bytes)
  }

  public func readInfo() throws -> ProgramInfo {
    let info = ProgramInfo()
    let op = readOpcode()
    if op == Opcode.CHECKSIG {
      info.m = 1
      info.pubkeys.append(try readPubkey())
      return info
    }

    if op == Opcode.CHECKMULTISIG {
      info.m = readInt().int64!
      let n = ScriptReader(buf: buf.subdata(in: buf.count - 5 ..< buf.count)).readInt().int64!

      for _ in 0 ..< n {
        info.pubkeys.append(try readPubkey())
      }
      return info
    }

    throw ProgramReaderError.unsupportedProg
  }
}

public enum ProgramReaderError: Error {
  case unsupportedProg
}
