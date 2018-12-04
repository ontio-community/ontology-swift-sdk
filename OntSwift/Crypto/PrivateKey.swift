//
//  PrivateKey.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/2.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import OpenSSL

public class PrivateKey: Key, Encodable, Decodable {
  public let scrypt: ScryptParams

  public init(raw: Data, algorithm: KeyType? = nil, parameters: KeyParameters? = nil, scrypt: ScryptParams? = nil) throws {
    self.scrypt = scrypt ?? ScryptParams.defaultParams
    try super.init(raw: raw, algorithm: algorithm, parameters: parameters)
  }

  public convenience init(hex: String, algorithm: KeyType? = nil, parameters: KeyParameters? = nil, scrypt: ScryptParams? = nil) throws {
    try self.init(raw: Data.from(hex: hex)!, algorithm: algorithm, parameters: parameters, scrypt: scrypt)
  }

  public enum CodingKeys: String, CodingKey {
    case algorithm, parameters, key, scrypt
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(raw.base64EncodedString(), forKey: .key)
    try container.encode(algorithm.label, forKey: .algorithm)
    try container.encode(parameters, forKey: .parameters)
    try container.encode(scrypt, forKey: .scrypt)
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = try container.decode(String.self, forKey: .key)
    let algo = try container.decode(String.self, forKey: .algorithm)
    let params = try container.decode(KeyParameters.self, forKey: .parameters)
    let scrypt = try container.decode(ScryptParams.self, forKey: .scrypt)
    try self.init(raw: Data(base64Encoded: key)!, algorithm: KeyType.from(algo), parameters: params, scrypt: scrypt)
  }

  public static func from(mnemonic: String) throws -> PrivateKey {
    let mnemonic = mnemonic.trimmingCharacters(in: .whitespacesAndNewlines)
    let seed = Mnemonic.seed(mnemonic: mnemonic.components(separatedBy: " "))
    let keychain = HDKeychain(seed: seed)
    let privateKey = try keychain.derivedKey(path: Constant.ontBip44Path)
    return try PrivateKey(raw: privateKey.raw)
  }

  public static func random() throws -> PrivateKey {
    var buf = Data(count: 32)
    buf.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt8>) -> Void in
      RAND_bytes(ptr, 32)
    }
    return try PrivateKey(raw: buf)
  }

  public func sign(msg: Data, scheme: SignatureScheme?, publicKeyId _: String?) throws -> Signature {
    let scheme = scheme ?? algorithm.defaultScheme
    if scheme == .eddsaSha512 {
      let pub = Eddsa.pub(pri: raw)
      return Eddsa.sign(msg: msg, pub: pub, pri: raw)
    } else {
      let pkey = Ecdsa.pkey(pri: raw, curve: parameters.curve.preset)
      return try pkey.sign(msg: msg, scheme: scheme)
    }
  }

  public func getPublicKey() throws -> PublicKey {
    if algorithm == .eddsa {
      let pub = Eddsa.pub(pri: raw)
      return try PublicKey(raw: pub, algorithm: algorithm, parameters: parameters)
    } else {
      let pkey = Ecdsa.pkey(pri: raw, curve: parameters.curve.preset)
      let pub = pkey.pub(mode: .compress)
      return try PublicKey(raw: pub, algorithm: algorithm, parameters: parameters)
    }
  }

  public func encrypt(keyphrase: Data, addr: Address, salt: Data, params: ScryptParams? = nil) throws -> PrivateKey {
    let pubkey = try getPublicKey()
    let addrExpect = try Address.from(pubkey: pubkey).toBase58()
    let addrActual = try addr.toBase58()
    if addrExpect != addrActual {
      throw PrivateKeyError.invalidAddr
    }
    let enc = try Scrypt.encryptWithGcm(
      prikey: raw,
      addr58: addrExpect.data(using: .utf8)!,
      salt: salt,
      pwd: keyphrase,
      params: params
    )
    return try PrivateKey(raw: enc, algorithm: algorithm, parameters: parameters, scrypt: params)
  }

  public func encrypt(keyphrase: String, addr: Address, salt: Data, params: ScryptParams? = nil) throws -> PrivateKey {
    return try encrypt(keyphrase: keyphrase.data(using: .utf8)!, addr: addr, salt: salt, params: params)
  }

  public func decrypt(keyphrase: Data, addr: Address, salt: Data, params: ScryptParams? = nil) throws -> PrivateKey {
    let addr58 = try addr.toBase58()
    let dec = try Scrypt.decryptWithGcm(encrypted: raw, addr58: addr58.data(using: .utf8)!, salt: salt, pwd: keyphrase, params: params)
    let key = try PrivateKey(raw: dec, algorithm: algorithm, parameters: parameters, scrypt: params)
    let addr58Act = try Address.from(pubkey: key.getPublicKey()).toBase58()
    if addr58Act != addr58 {
      throw PrivateKeyError.decryptErr
    }
    return key
  }

  public func wif() throws -> String {
    var data = Data()
    data.append(UInt8(0x80))
    data.append(raw)
    data.append(UInt8(0x01))
    let chksum = try Hash.sha256sha256(data: data)
    data.append(chksum.subdata(in: 0 ..< 4))
    return data.base58encoded
  }

  public static func from(wif: String) throws -> PrivateKey {
    guard let data = Data.decode(base58: wif) else {
      throw PrivateKeyError.deformedWif
    }
    if data.count != 38 || data[0] != 0x80 || data[33] != 0x01 {
      throw PrivateKeyError.deformedWif
    }

    let chksum = data.subdata(in: 34 ..< data.count)
    let chksum1 = try Hash.sha256sha256(data: data.subdata(in: 0 ..< 34))
    if !chksum.elementsEqual(chksum1.subdata(in: 0 ..< 4)) {
      throw PrivateKeyError.illegalWif
    }
    return try PrivateKey(raw: data.subdata(in: 1 ..< 33))
  }
}

public enum PrivateKeyError: Error {
  case invalidAddr, decryptErr, deformedWif, illegalWif
}
