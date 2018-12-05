//
//  ControlData.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ControlData: Codable {
  public let id: String
  public let encryptedKey: PrivateKey
  public let address: Address
  public let publicKey: String
  public let salt: String
  public let hash = "sha256"

  public init(id: String, encryptedKey: PrivateKey, address: Address, publicKey: String, salt: String) {
    self.id = id
    self.encryptedKey = encryptedKey
    self.address = address
    self.publicKey = publicKey
    self.salt = salt
  }

  public enum CodingKeys: String, CodingKey {
    case id, address, salt, encAlg = "enc-alg", hash, publicKey
    case algorithm, parameters, key, scrypt
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(String.self, forKey: .id)
    let addr58 = try container.decode(String.self, forKey: .address)
    let salt = try container.decode(String.self, forKey: .salt)
    let publicKey = try container.decode(String.self, forKey: .publicKey)

    let keyAlgo = try container.decode(String.self, forKey: .algorithm)
    let keyParams = try container.decode(KeyParameters.self, forKey: .parameters)
    let key64 = try container.decode(String.self, forKey: .key)
    let keyScrypt = try container.decode(ScryptParams.self, forKey: .scrypt)

    let addr = try Address(b58: addr58)
    let key = Data(base64Encoded: key64)!
    let pri = try PrivateKey(raw: key, algorithm: KeyType.from(keyAlgo), parameters: keyParams, scrypt: keyScrypt)

    self.init(id: id, encryptedKey: pri, address: addr, publicKey: publicKey, salt: salt)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(address.toBase58(), forKey: .address)
    try container.encode(salt, forKey: .salt)
    try container.encode(publicKey, forKey: .publicKey)
    try container.encode("aes-256-gcm", forKey: .encAlg)
    try container.encode(hash, forKey: .hash)

    try container.encode(encryptedKey.algorithm.label, forKey: .algorithm)
    try container.encode(encryptedKey.parameters, forKey: .parameters)
    try container.encode(encryptedKey.raw.base64EncodedString(), forKey: .key)
    try container.encode(encryptedKey.scrypt, forKey: .scrypt)
  }
}
