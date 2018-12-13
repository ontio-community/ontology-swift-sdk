//
//  ProgramBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ProgramBuilder: ScriptBuilder {
  public static func from(pubkey: PublicKey) throws -> ProgramBuilder {
    let prog = ProgramBuilder()
    _ = try prog.push(pubkey: pubkey)
    _ = try prog.push(opcode: Opcode.CHECKSIG)
    return prog
  }

  public static func from(params: [String]) throws -> ProgramBuilder {
    let prog = ProgramBuilder()
    let params = params.sorted()
    try params.forEach { try _ = prog.push(bytes: Data.from(hex: $0)!) }
    return prog
  }

  public static func from(params: [Data]) throws -> ProgramBuilder {
    let params = params.map { $0.hexEncoded }
    return try from(params: params)
  }

  public static func comparePublicKeys(a: PublicKey, b: PublicKey) -> Int {
    if a.algorithm.value != b.algorithm.value {
      return a.algorithm.value - b.algorithm.value
    }

    switch a.algorithm {
    case .ecdsa, .sm2:
      let pa = Ecdsa.pkey(pub: a.raw, curve: a.parameters.curve.preset)
      let pb = Ecdsa.pkey(pub: b.raw, curve: b.parameters.curve.preset)
      let (ax, ay) = pa.pubxy
      let (bx, by) = pb.pubxy
      if ax != bx {
        return BN.cmp(ax, bx)
      }
      return BN.cmp(ay, by)
    case .eddsa:
      let ai = a.raw.readUInt64(ofst: 0)
      let bi = b.raw.readUInt64(ofst: 0)
      if ai == bi {
        return 0
      } else if ai > bi {
        return 1
      }
      return -1
    }
  }

  public static func from(pubkeys: [PublicKey], m: Int) throws -> ProgramBuilder {
    let prog = ProgramBuilder()
    let n = pubkeys.count
    if !(1 <= m && m <= n && n <= 1024) {
      throw ProgramBuilderError.wrongMultiSigParams
    }

    let pubkeys = pubkeys.sorted(by: { comparePublicKeys(a: $0, b: $1) == 1 })
    _ = try prog.push(int: m)
    pubkeys.forEach { _ = prog.push(rawbytes: $0.raw) }
    _ = try prog.push(int: n)
    _ = try prog.push(opcode: Opcode.CHECKMULTISIG)
    return prog
  }

  public func push(pubkey: PublicKey) throws -> Self {
    switch pubkey.algorithm {
    case .ecdsa:
      _ = try push(varbytes: pubkey.raw)
    case .eddsa, .sm2:
      let b = ScriptBuilder()
      _ = try b.push(num: pubkey.algorithm.value)
      _ = try b.push(num: pubkey.parameters.curve.value)
      _ = b.push(rawbytes: pubkey.raw)
      _ = try push(varbytes: b.buf)
    }
    return self
  }

  public func push(bytes: Data) throws -> Self {
    let len = bytes.count
    if len == 0 {
      throw ProgramBuilderError.emptyBytes
    }

    if len <= Opcode.PUSHBYTES75 + 1 - Opcode.PUSHBYTES1 {
      _ = try push(num: len + Opcode.PUSHBYTES1 - 1)
    } else if len < 0x100 {
      _ = try push(num: Opcode.PUSHDATA1).push(num: len)
    } else if len < 0x10000 {
      _ = try push(num: Opcode.PUSHDATA2).push(num: len, len: 2, endian: .little)
    } else if len < (0x1_0000_0000 as Int64) {
      _ = try push(num: Opcode.PUSHDATA4).push(num: len, len: 4, endian: .little)
    } else {
      throw ProgramBuilderError.invalidBytesLen
    }
    _ = push(rawbytes: bytes)
    return self
  }
}

public enum ProgramBuilderError: Error {
  case emptyBytes, invalidBytesLen, wrongMultiSigParams
}
