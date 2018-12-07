//
//  PublicKey.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class PublicKey: Key {
  public func verify(msg: Data, sig: Signature) throws -> Bool {
    if sig.algorithm == .eddsaSha512 {
      return Eddsa.verify(msg: msg, sig: sig, pub: raw)
    } else {
      let pkey = Ecdsa.pkey(pub: raw, curve: parameters.curve.preset)
      return try pkey.verify(msg: msg, sig: sig)
    }
  }

  public var hexEncoded: String {
    return hex()
  }

  public func hex() -> String {
    var buf = Data()
    switch algorithm {
    case .ecdsa:
      buf.append(raw)
    case .eddsa, .sm2:
      buf.append(UInt8(algorithm.value))
      buf.append(UInt8(parameters.curve.value))
      buf.append(raw)
    }
    return buf.base64EncodedString()
  }

  public static func from(bytes: Data, len: Int = 33) throws -> PublicKey {
    let buf = BufferReader(buf: bytes)
    if len == 33 {
      // ecdsa
      let raw = buf.forward(cnt: 33)
      return try PublicKey(raw: raw, algorithm: KeyType.ecdsa, parameters: KeyParameters(curve: .p256))
    }
    let algo = try KeyType.from(Int(buf.readUInt8()))
    let curve = try Curve.from(Int(buf.readUInt8()))
    let raw = buf.forward(cnt: len - 2)
    return try PublicKey(raw: raw, algorithm: algo, parameters: KeyParameters(curve: curve))
  }
}
