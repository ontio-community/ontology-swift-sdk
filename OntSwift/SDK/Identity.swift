//
//  Identity.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Identity: Codable {
  public let ontid: String
  public let label: String
  public let lock: Bool
  public let isDefault: Bool
  public var controls: [ControlData] = []
  public var extra: String?

  public init(ontid: String, label: String, lock: Bool, isDefault: Bool, extra: String? = nil) {
    self.ontid = ontid
    self.label = label
    self.lock = lock
    self.isDefault = isDefault
    self.extra = extra
  }

  public static func create(prikey: PrivateKey, pwd: String, label: String, params: ScryptParams? = nil) throws -> Identity {
    let pubkey = try prikey.getPublicKey()
    let ontid = try Address.generateOntid(pubkey: pubkey)
    let addr = try Address.from(ontid: ontid)
    let salt = try Data.random(count: 16)
    let encPrikey = try prikey.encrypt(keyphrase: pwd, addr: addr, salt: salt, params: params)

    let ctrl = ControlData(
      id: "1",
      encryptedKey: encPrikey,
      address: addr,
      publicKey: pubkey.hex(),
      salt: salt.base64EncodedString()
    )

    let ret = Identity(ontid: ontid, label: label, lock: false, isDefault: false)
    ret.controls.append(ctrl)
    return ret
  }

  public static func from(
    encrypted: PrivateKey,
    label: String,
    pwd: String,
    addr: Address,
    salt: String,
    params: ScryptParams? = nil
  ) throws -> Identity {
    let salt = Data(base64Encoded: salt)!
    let prikey = try encrypted.decrypt(keyphrase: pwd, addr: addr, salt: salt, params: params)

    let label = label == "" ? try Data.random(count: 4).hexEncoded : label
    let pubkey = try prikey.getPublicKey()
    let ontid = try Address.generateOntid(pubkey: pubkey)

    let ret = Identity(ontid: ontid, label: label, lock: false, isDefault: false)
    let ctrl = ControlData(
      id: "1",
      encryptedKey: encrypted,
      address: try Address.from(ontid: ontid),
      publicKey: pubkey.hexEncoded,
      salt: salt.base64EncodedString()
    )
    ret.controls.append(ctrl)
    return ret
  }

  public static func from(keystore: Keystore, pwd: String) throws -> Identity {
    if keystore.type != "I" {
      throw IdentityError.fromKeystoreErrDeformedType
    }

    let algo = try KeyType.from(keystore.algorithm)
    let parameters = try KeyParameters.from(curve: keystore.parameters.curve.label)
    let scrypt = keystore.scrypt

    let encrypted = try PrivateKey(raw: Data(base64Encoded: keystore.key)!, algorithm: algo, parameters: parameters, scrypt: scrypt)
    return try from(encrypted: encrypted, label: keystore.label, pwd: pwd, addr: keystore.address, salt: keystore.salt)
  }
  
  public static func from(keystore: String, pwd: String) throws -> Identity {
    let keystore = try JSONDecoder().decode(Keystore.self, from: keystore.data(using: .utf8)!)
    return try from(keystore: keystore, pwd: pwd)
  }

  public func privateKey(pwd: String, params: ScryptParams? = nil) throws -> PrivateKey {
    let encPrikey = controls[0].encryptedKey
    let addr = controls[0].address
    let salt = controls[0].salt
    return try encPrikey.decrypt(keyphrase: pwd, addr: addr, salt: Data(base64Encoded: salt)!, params: params)
  }

  public func keystore() -> Keystore {
    let ctrl = controls[0]
    return Keystore(
      type: "I",
      label: label,
      algorithm: ctrl.encryptedKey.algorithm.label,
      scrypt: ctrl.encryptedKey.scrypt,
      key: ctrl.encryptedKey.raw.base64EncodedString(),
      salt: ctrl.salt,
      address: ctrl.address,
      parameters: ctrl.encryptedKey.parameters
    )
  }

  public enum CodingKeys: String, CodingKey {
    case ontid, label, lock, isDefault, controls
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(ontid, forKey: .ontid)
    try container.encode(label, forKey: .label)
    try container.encode(lock, forKey: .lock)
    try container.encode(isDefault, forKey: .isDefault)

    var controlsContainer = container.nestedUnkeyedContainer(forKey: .controls)
    try controls.forEach {
      try controlsContainer.encode($0)
    }
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let ontid = try container.decode(String.self, forKey: .ontid)
    let label = try container.decode(String.self, forKey: .label)
    let lock = try container.decode(Bool.self, forKey: .lock)
    let isDefault = try container.decode(Bool.self, forKey: .isDefault)

    self.init(ontid: ontid, label: label, lock: lock, isDefault: isDefault)

    var controlsContainer = try container.nestedUnkeyedContainer(forKey: .controls)
    while !controlsContainer.isAtEnd {
      controls.append(try controlsContainer.decode(ControlData.self))
    }
  }
}

public enum IdentityError: Error {
  case fromKeystoreErrDeformedType
}
