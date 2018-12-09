//
//  Transaction.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Transaction: Signable {
  public var type = TxType.invoke
  public var version = 0x00
  public var nonce: String
  public var gasPrice: Int = 0
  public var gasLimit: Int = 0
  public var payer: Address
  public var sigs: [TxSignature] = []
  public var payload: Payload?

  public var amount: BigInt?
  public var tokenType: String?
  public var from: Address?
  public var to: Address?
  public var method: String?

  public required init() throws {
    payer = try Address(value: "0000000000000000000000000000000000000000")
    nonce = try Data.random(count: 4).hexEncoded
  }

  public static func deserialize(r: ScriptReader) throws -> Self {
    let ret = try self.init()

    let tx = ret as Transaction
    tx.version = Int(r.readUInt8())
    tx.type = TxType(rawValue: Int(r.readUInt32LE()))!
    tx.nonce = r.forward(cnt: 4).hexEncoded
    tx.gasPrice = Int(r.readUInt64LE())
    tx.gasLimit = Int(r.readUInt64LE())
    tx.payer = Address(value: r.forward(cnt: 20))

    switch tx.type {
    case .invoke:
      let payload = InvokeCode()
      try payload.deserialize(r: r)
      tx.payload = payload
    case .deploy:
      let payload = DeployCode()
      try payload.deserialize(r: r)
      tx.payload = payload
    default:
      let payload = InvokeCode()
      try payload.deserialize(r: r)
      tx.payload = payload
    }

    _ = r.readUInt8()
    let sigLen = r.readVarInt()

    let buf = r.buf.subdata(in: r.ofst ..< r.buf.count)
    let pr = ProgramReader(buf: buf)
    for _ in 0 ..< sigLen {
      try tx.sigs.append(TxSignature.deserialize(r: pr))
    }
    return ret
  }

  public func signContent() throws -> Data {
    let data = try serializeUnsignedData()
    return try Hash.sha256sha256(data: data)
  }

  public func serialize() throws -> Data {
    var us = try serializeUnsignedData()
    let ss = try serializeSignedData()
    us.append(ss)
    return us
  }

  public func serializeUnsignedData() throws -> Data {
    let b = ScriptBuilder()
    _ = try b.push(num: version)
    _ = try b.push(num: type.rawValue)

    _ = b.push(rawbytes: Data.from(hex: nonce)!)
    _ = try b.push(num: gasPrice, len: 8, endian: .little)
    _ = try b.push(num: gasLimit, len: 8, endian: .little)
    _ = b.push(rawbytes: payer.value)

    guard let payload = payload else {
      throw TransactionError.emptyPayload
    }
    _ = try b.push(rawbytes: payload.serialize())
    b.buf.append(UInt8(0))
    return b.buf
  }

  public func serializeSignedData() throws -> Data {
    let b = ScriptBuilder()
    _ = try b.push(num: sigs.count)
    for sig in sigs {
      _ = try b.push(rawbytes: sig.serialize())
    }
    return b.buf
  }
}

public enum TransactionError: Error {
  case emptyPayload
}
