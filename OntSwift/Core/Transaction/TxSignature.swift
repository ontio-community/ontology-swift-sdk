//
//  TxSignature.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class TxSignature {
  public private(set) var pubkeys: [PublicKey] = []
  public var m: Int = 0
  public private(set) var sigData: [Data] = []

  public required init() {}

  public static func create(data: Signable, pri: PrivateKey, scheme: SignatureScheme? = nil) throws -> Self {
    let ret = self.init()
    let ts = ret as TxSignature
    ts.pubkeys = try [pri.getPublicKey()]
    ts.sigData = try [pri.sign(msg: data.signContent(), scheme: scheme).bytes]
    return ret
  }

  public func serialize() throws -> Data {
    let invocationScript = try ProgramBuilder.from(params: sigData)
    let pubKeysCnt = pubkeys.count
    if pubKeysCnt == 0 {
      throw TxSignatureError.noPubkeysInSig
    }

    let b = NativeVmParamsBuilder()
    _ = try b.push(varbytes: invocationScript.buf)

    if pubKeysCnt == 1 {
      _ = try b.push(varbytes: ProgramBuilder.from(pubkey: pubkeys[0]).buf)
    } else {
      _ = try b.push(varbytes: ProgramBuilder.from(pubkeys: pubkeys, m: m).buf)
    }
    return b.buf
  }

  public static func deserialize(r: ProgramReader) throws -> Self {
    let ret = self.init()
    let ts = ret as TxSignature
    ts.sigData = try r.readParams()
    let info = try r.readInfo()
    ts.m = info.m
    ts.pubkeys = info.pubkeys
    return ret
  }
}

public enum TxSignatureError: Error {
  case noPubkeysInSig
}
