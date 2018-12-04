//
//  Address.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Address {
  public let value: Data

  public init(value: Data) {
    self.value = value
  }

  public convenience init(b58: String) throws {
    self.init(value: try Address.decode(b58: b58))
  }

  public convenience init(value: String) throws {
    if value.count == 40 {
      self.init(value: Data.from(hex: value)!)
    } else if value.count == 34 {
      try self.init(b58: value)
    } else {
      throw AddressError.invalidValue
    }
  }

  public static func from(pubkey: PublicKey) throws -> Address {
    let prog = try ProgramBuilder.from(pubkey: pubkey)
    let hash = _Hash.sha256ripemd160(prog.buf)
    return Address(value: hash)
  }

  public static func encode2b58(data: Data) throws -> String {
    var buf = Data()
    buf.append(Constant.addrVersion)
    buf.append(data)
    let hash = try Hash.sha256sha256(data: buf)
    let chksum = hash.subdata(in: 0 ..< 4)
    buf.append(chksum)
    return buf.base58encoded
  }

  public static func decode(b58: String) throws -> Data {
    let data = Data.decode(base58: b58)!
    let val = data.subdata(in: 1 ..< 21)
    let act = try Address.encode2b58(data: val)
    if b58 != act {
      throw AddressError.decodeBase58Err
    }
    return val
  }

  public func toBase58() throws -> String {
    return try Address.encode2b58(data: value)
  }

  public func serialize() throws -> String {
    return value.hexEncoded
  }

  public func toHex() throws -> String {
    return Data(value.reversed()).hexEncoded
  }

  public static func from(vmcode: Data) -> Address {
    let hash = _Hash.sha256ripemd160(vmcode)
    return Address(value: hash)
  }

  public static func generateOntid(pubkey: PublicKey) throws -> String {
    let addr = try from(pubkey: pubkey)
    let b58 = try addr.toBase58()
    return "did:ont:" + b58
  }

  public static func from(ontid: String) throws -> Address {
    let from = ontid.index(ontid.startIndex, offsetBy: 8)
    return try Address(b58: String(ontid[from...]))
  }
}

public enum AddressError: Error {
  case invalidValue, decodeBase58Err
}
