//
//  Wallet.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Wallet: Codable {
  public let name: String
  public let version: String
  public let createTime: String?
  public let scrypt: ScryptParams
  public var identities: [Identity] = []
  public var accounts: [Account] = []

  public private(set) var defaultOntid: String?
  public private(set) var defaultAccountAddress: String?
  public var extra: String?

  public init(name: String, version: String = "1.0", createTime: String? = nil, scrypt: ScryptParams? = nil) {
    self.name = name
    self.version = version
    self.createTime = createTime ?? Date().iso8601
    self.scrypt = scrypt ?? ScryptParams.defaultParams
  }

  public enum CodingKeys: String, CodingKey {
    case name, defaultOntid, defaultAccountAddress, createTime, version, scrypt, identities, accounts, extra
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(defaultOntid, forKey: .defaultOntid)
    try container.encodeIfPresent(defaultAccountAddress, forKey: .defaultAccountAddress)
    try container.encode(createTime, forKey: .createTime)
    try container.encode(version, forKey: .version)
    try container.encode(scrypt, forKey: .scrypt)
    try container.encodeIfPresent(extra, forKey: .extra)

    var identitiesContainer = container.nestedUnkeyedContainer(forKey: .identities)
    try identities.forEach { try identitiesContainer.encode($0) }

    var accountsContainer = container.nestedUnkeyedContainer(forKey: .accounts)
    try accounts.forEach { try accountsContainer.encode($0) }
  }

  public required convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let name = try container.decode(String.self, forKey: .name)
    let createTime = try container.decodeIfPresent(String.self, forKey: .createTime)
    let version = try container.decode(String.self, forKey: .version)
    let scrypt = try container.decode(ScryptParams.self, forKey: .scrypt)
    let extra = try container.decodeIfPresent(String.self, forKey: .extra)

    self.init(name: name, version: version, createTime: createTime, scrypt: scrypt)

    if let defaultOntid = try container.decodeIfPresent(String.self, forKey: .defaultOntid) {
      try set(defaultIdentity: defaultOntid)
    }

    if let defaultAccountAddress = try container.decodeIfPresent(String.self, forKey: .defaultAccountAddress) {
      try set(defaultAccount: defaultAccountAddress)
    }

    self.extra = extra

    if container.contains(.identities) {
      var identitiesContainer = try container.nestedUnkeyedContainer(forKey: .identities)
      while !identitiesContainer.isAtEnd {
        identities.append(try identitiesContainer.decode(Identity.self))
      }
    }

    var accountsContainer = try container.nestedUnkeyedContainer(forKey: .accounts)
    while !accountsContainer.isAtEnd {
      let acc = try accountsContainer.decode(Account.self)
      acc.encryptedKey.forceScrypt(params: scrypt)
      accounts.append(acc)
    }
  }

  public func add(account: Account) throws {
    if try accounts.contains(where: { try account.address.toBase58() == $0.address.toBase58() }) {
      return
    }
    accounts.append(account)
  }

  public func delete(account: Account) throws {
    if let idx = try accounts.firstIndex(where: { try account.address.toBase58() == $0.address.toBase58() }) {
      accounts.remove(at: idx)
    }
  }

  public func add(identity: Identity) {
    if identities.contains(where: { identity.ontid == $0.ontid }) {
      return
    }
    identities.append(identity)
  }

  public func delete(identity: Identity) {
    if let idx = identities.firstIndex(where: { identity.ontid == $0.ontid }) {
      identities.remove(at: idx)
    }
  }

  public func set(defaultAccount: String) throws {
    if try accounts.contains(where: { try defaultAccount == $0.address.toBase58() }) {
      defaultAccountAddress = defaultAccount
      return
    }
    throw WalletError.accountDoesNotExist
  }

  public func set(defaultIdentity: String) throws {
    if identities.contains(where: { defaultIdentity == $0.ontid }) {
      defaultOntid = defaultIdentity
      return
    }
    throw WalletError.identityDoesNotExist
  }
}

public enum WalletError: Error {
  case accountDoesNotExist, identityDoesNotExist
}
