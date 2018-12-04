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
}
