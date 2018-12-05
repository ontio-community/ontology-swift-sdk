//
//  Keystore.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Keystore: Codable {
  public let type: String
  public let label: String
  public let algorithm: String
  public let scrypt: ScryptParams
  public let key: String
  public let salt: String
  public let address: Address
  public let parameters: KeyParameters

  public init(
    type: String,
    label: String,
    algorithm: String,
    scrypt: ScryptParams,
    key: String,
    salt: String,
    address: Address,
    parameters: KeyParameters
  ) {
    self.type = type
    self.label = label
    self.algorithm = algorithm
    self.scrypt = scrypt
    self.key = key
    self.salt = salt
    self.address = address
    self.parameters = parameters
  }

  public enum CodingKeys: String, CodingKey {
    case type, label, algorithm, scrypt, key, salt, address, parameters
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    let label = try container.decode(String.self, forKey: .label)
    let algorithm = try container.decode(String.self, forKey: .algorithm)
    let scrypt = try container.decode(ScryptParams.self, forKey: .scrypt)
    let key = try container.decode(String.self, forKey: .key)
    let salt = try container.decode(String.self, forKey: .salt)
    let addr58 = try container.decode(String.self, forKey: .address)
    let parameters = try container.decode(KeyParameters.self, forKey: .parameters)
    self.init(
      type: type,
      label: label,
      algorithm: algorithm,
      scrypt: scrypt,
      key: key,
      salt: salt,
      address: try Address(b58: addr58),
      parameters: parameters
    )
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(type, forKey: .type)
    try container.encode(label, forKey: .label)
    try container.encode(algorithm, forKey: .algorithm)
    try container.encode(scrypt, forKey: .scrypt)
    try container.encode(key, forKey: .key)
    try container.encode(salt, forKey: .salt)
    try container.encode(try address.toBase58(), forKey: .address)
    try container.encode(parameters, forKey: .parameters)
  }
}
