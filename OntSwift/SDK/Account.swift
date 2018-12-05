//
//  Account.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Account: Encodable, Decodable {
  public let label: String
  public let address: Address
  public let lock: Bool
  public let encryptedKey: PrivateKey
  public let hash: String?
  public let salt: String
  public let publicKey: String
  public let isDefault: Bool
  public var extra: String?

  public init(
    label: String,
    address: Address,
    lock: Bool,
    encryptedKey: PrivateKey,
    salt: String,
    publicKey: String,
    isDefault: Bool,
    hash: String? = nil,
    extra: String? = nil
  ) {
    self.label = label
    self.address = address
    self.lock = lock
    self.encryptedKey = encryptedKey
    self.hash = hash
    self.salt = salt
    self.publicKey = publicKey
    self.isDefault = isDefault
    self.extra = extra
  }

  public static func create(
    pwd: String,
    prikey: PrivateKey? = nil,
    label: String = "",
    params: ScryptParams? = nil
  ) throws -> Account {
    let prikey = prikey == nil ? try PrivateKey.random() : prikey!
    let label = label == "" ? try Data.random(count: 4).hexEncoded : label
    let salt = try Data.random(count: 16)
    let pubkey = try prikey.getPublicKey()
    let addr = try Address.from(pubkey: pubkey)
    let encPrikey = try prikey.encrypt(keyphrase: pwd.data(using: .utf8)!, addr: addr, salt: salt, params: params)
    return Account(
      label: label,
      address: addr,
      lock: false,
      encryptedKey:
      encPrikey,
      salt: salt.base64EncodedString(),
      publicKey: pubkey.hexEncoded,
      isDefault: false
    )
  }

  public static func from(
    encrypted: PrivateKey,
    label: String,
    pwd: String,
    addr: Address,
    salt: String,
    params: ScryptParams? = nil
  ) throws -> Account {
    let salt = Data(base64Encoded: salt)!
    let prikey = try encrypted.decrypt(keyphrase: pwd, addr: addr, salt: salt, params: params)
    let label = label == "" ? try Data.random(count: 4).hexEncoded : label
    let pubkey = try prikey.getPublicKey()
    let pub = pubkey.hexEncoded
    let addr = try Address.from(pubkey: pubkey)
    return Account(
      label: label,
      address: addr,
      lock: false,
      encryptedKey: encrypted,
      salt: salt.base64EncodedString(),
      publicKey: pub,
      isDefault: false
    )
  }

  public static func from(keystore: Keystore, pwd: String) throws -> Account {
    if keystore.type != "A" {
      throw AccountError.fromKeystoreErrDeformedType
    }

    let algo = try KeyType.from(keystore.algorithm)
    let parameters = try KeyParameters.from(curve: keystore.parameters.curve.label)
    let scrypt = keystore.scrypt

    let encrypted = try PrivateKey(raw: Data(base64Encoded: keystore.key)!, algorithm: algo, parameters: parameters, scrypt: scrypt)
    return try from(encrypted: encrypted, label: keystore.label, pwd: pwd, addr: keystore.address, salt: keystore.salt)
  }
  
  public static func from(keystore: String, pwd: String) throws -> Account {
    let keystore = try JSONDecoder().decode(Keystore.self, from: keystore.data(using: .utf8)!)
    return try from(keystore: keystore, pwd: pwd)
  }

  public static func from(wif: String, pwd: String, label: String = "", params: ScryptParams? = nil) throws -> Account {
    let prikey = try PrivateKey.from(wif: wif)
    return try create(pwd: pwd, prikey: prikey, label: label, params: params)
  }

  public static func from(mnemonic: String, label: String = "", pwd: String, params: ScryptParams? = nil) throws -> Account {
    let prikey = try PrivateKey.from(mnemonic: mnemonic)
    return try create(pwd: pwd, prikey: prikey, label: label, params: params)
  }

  public func privateKey(pwd: String, params: ScryptParams? = nil) throws -> PrivateKey {
    let salt = Data(base64Encoded: self.salt)!
    return try encryptedKey.decrypt(keyphrase: pwd, addr: address, salt: salt, params: params)
  }

  public func keystore() -> Keystore {
    return Keystore(
      type: "A",
      label: label,
      algorithm: encryptedKey.algorithm.label,
      scrypt: encryptedKey.scrypt,
      key: encryptedKey.raw.base64EncodedString(),
      salt: salt,
      address: address,
      parameters: encryptedKey.parameters
    )
  }

  public enum CodingKeys: String, CodingKey {
    case label, address, lock, encAlg = "enc-alg", hash, salt, isDefault, publicKey, signatureScheme, extra
    case algorithm, parameters, key
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(address.toBase58(), forKey: .address)
    try container.encode(label, forKey: .label)
    try container.encode(lock, forKey: .lock)
    try container.encode("aes-256-gcm", forKey: .encAlg)
    try container.encode(salt, forKey: .salt)
    try container.encode(isDefault, forKey: .isDefault)
    try container.encode(publicKey, forKey: .publicKey)
    try container.encodeIfPresent(hash, forKey: .hash)
    try container.encodeIfPresent(extra, forKey: .extra)

    try container.encode(encryptedKey.algorithm.defaultScheme.label, forKey: .signatureScheme)
    try container.encode(encryptedKey.algorithm.label, forKey: .algorithm)
    try container.encode(encryptedKey.parameters, forKey: .parameters)
    try container.encode(encryptedKey.raw.base64EncodedString(), forKey: .key)
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let addr58 = try container.decode(String.self, forKey: .address)
    let label = try container.decode(String.self, forKey: .label)
    let lock = try container.decode(Bool.self, forKey: .lock)
    let salt = try container.decode(String.self, forKey: .salt)
    let isDefault = try container.decode(Bool.self, forKey: .isDefault)
    let publicKey = try container.decode(String.self, forKey: .publicKey)
    let hash = try container.decodeIfPresent(String.self, forKey: .hash)
    let extra = try container.decodeIfPresent(String.self, forKey: .extra)

    let keyAlgo = try container.decode(String.self, forKey: .algorithm)
    let keyParams = try container.decode(KeyParameters.self, forKey: .parameters)
    let key64 = try container.decode(String.self, forKey: .key)

    let addr = try Address(b58: addr58)
    let key = Data(base64Encoded: key64)!
    let pri = try PrivateKey(raw: key, algorithm: KeyType.from(keyAlgo), parameters: keyParams)
    self.init(
      label: label,
      address: addr,
      lock: lock,
      encryptedKey: pri,
      salt: salt,
      publicKey: publicKey,
      isDefault: isDefault,
      hash: hash,
      extra: extra
    )
  }
}

public enum AccountError: Error {
  case fromKeystoreErrDeformedType
}
