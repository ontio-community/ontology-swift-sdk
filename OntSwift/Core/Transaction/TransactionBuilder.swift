//
//  TransactionBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class TransactionBuilder {
  public init() {}

  public func sign(tx: Transaction, prikey: PrivateKey, scheme: SignatureScheme? = nil) throws {
    let sig = try TxSignature.create(data: tx, pri: prikey, scheme: scheme)
    tx.sigs = [sig]
  }

  public func addSig(tx: Transaction, prikey: PrivateKey, scheme: SignatureScheme? = nil) throws {
    let sig = try TxSignature.create(data: tx, pri: prikey, scheme: scheme)
    tx.sigs.append(sig)
  }

  public func makeNativeContractTx(
    fnName: String,
    params: Data,
    contract: Address,
    gasPrice: String?,
    gasLimit: String?,
    payer: Address?
  ) throws -> Transaction {
    let b = ScriptBuilder()
    _ = b.push(rawbytes: params)
    _ = try b.push(hex: fnName.data(using: .utf8)!)
    _ = try b.push(address: contract)
    _ = try b.push(int: 0)
    _ = try b.push(opcode: Opcode.SYSCALL)
    _ = try b.push(hex: Constant.nativeInvokeName.data(using: .utf8)!)
    let payload = InvokeCode()
    payload.code = b.buf

    let tx = try Transaction()
    tx.type = TxType.invoke
    tx.payload = payload

    if let price = gasPrice {
      tx.gasPrice = BigInt(price).int64!
    }
    if let limit = gasLimit {
      tx.gasLimit = BigInt(limit).int64!
    }
    if let payer = payer {
      tx.payer = payer
    }
    return tx
  }

  public func makeDeployCodeTransaction(
    code: Data,
    name: String,
    codeVersion: String,
    author: String,
    email: String,
    desc: String,
    needStorage: Bool,
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let dc = DeployCode()
    dc.author = author
    dc.code = code
    dc.name = name
    dc.version = codeVersion
    dc.email = email
    dc.needStorage = needStorage
    dc.desc = desc

    let tx = try Transaction()
    tx.version = 0x00
    tx.payload = dc
    tx.type = TxType.deploy

    tx.gasPrice = BigInt(gasPrice).int64!
    tx.gasLimit = BigInt(gasLimit).int64!
    tx.payer = payer

    return tx
  }

  public func makeInvokeTransaction(
    params: Data,
    contract: Address,
    gasPrice: String = "0",
    gasLimit: String = "20000",
    payer: Address? = nil
  ) throws -> Transaction {
    let tx = try Transaction()
    tx.type = TxType.invoke

    let b = ScriptBuilder()
    _ = b.push(rawbytes: params)

    _ = try b.push(opcode: Opcode.APPCALL)
    _ = b.push(rawbytes: contract.toHexData())

    let payload = InvokeCode()
    payload.code = b.buf
    tx.payload = payload

    tx.gasPrice = BigInt(gasPrice).int64!
    tx.gasLimit = BigInt(gasLimit).int64!

    if let payer = payer {
      tx.payer = payer
    }

    return tx
  }

  public func makeInvokeTransaction(
    fnName: String,
    params: [AbiParameter],
    contract: Address,
    gasPrice: String = "0",
    gasLimit: String = "20000",
    payer: Address? = nil
  ) throws -> Transaction {
    let b = NativeVmParamsBuilder()
    let fn = AbiFunction(name: fnName, params: params)
    _ = try b.push(fn: fn)
    return try makeInvokeTransaction(
      params: b.buf,
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }
}
