//
//  Oep4TxBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class Oep4TxBuilder {
  public let contract: Address

  public init(contract: Address) {
    self.contract = contract
  }

  public func makeInitTx(gasPrice: String, gasLimit: String, payer: Address? = nil) throws -> Transaction {
    let b = TransactionBuilder()
    let fn = Oep4TxBuilder.Method.Init.rawValue
    return try b.makeInvokeTransaction(
      fnName: fn,
      params: [],
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func makeTransferTx(
    from: Address,
    to: Address,
    amount: BigInt,
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let b = TransactionBuilder()
    let fn = Oep4TxBuilder.Method.transfer.rawValue
    let v1 = try Data.from(hex: from.serialize())!
    let v2 = try Data.from(hex: to.serialize())!
    let v3 = amount
    let p1 = AbiParameter(name: "from", type: .byteArray, value: AbiParameter.Value.bytes(v1))
    let p2 = AbiParameter(name: "to", type: .byteArray, value: AbiParameter.Value.bytes(v2))
    let p3 = AbiParameter(name: "value", type: .long, value: AbiParameter.Value.long(v3))
    return try b.makeInvokeTransaction(
      fnName: fn,
      params: [p1, p2, p3],
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func makeTransferMultiTx(
    states: [OepState],
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let fn = Oep4TxBuilder.Method.transferMulti.rawValue
    var list: [Any] = [fn.data(using: .utf8)!]
    var args: [Any] = []
    states.forEach {
      args.append([$0.from, $0.to, $0.amount])
    }
    list.append(args)
    let pb = NativeVmParamsBuilder()
    let params = try pb.pushCodeParams(objs: list).buf
    let txb = TransactionBuilder()
    return try txb.makeNativeContractTx(
      fnName: "",
      params: params,
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func makeApproveTx(
    owner: Address,
    spender: Address,
    amount: BigInt,
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let fn = Oep4TxBuilder.Method.approve.rawValue
    let v1 = try Data.from(hex: owner.serialize())!
    let v2 = try Data.from(hex: spender.serialize())!
    let v3 = amount
    let p1 = AbiParameter(name: "owner", type: .byteArray, value: AbiParameter.Value.bytes(v1))
    let p2 = AbiParameter(name: "spender", type: .byteArray, value: AbiParameter.Value.bytes(v2))
    let p3 = AbiParameter(name: "amount", type: .long, value: AbiParameter.Value.long(v3))
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(
      fnName: fn,
      params: [p1, p2, p3],
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func makeTransferFromTx(
    spender: Address,
    from: Address,
    to: Address,
    amount: BigInt,
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let fn = Oep4TxBuilder.Method.transferFrom.rawValue
    let v1 = try Data.from(hex: spender.serialize())!
    let v2 = try Data.from(hex: from.serialize())!
    let v3 = try Data.from(hex: to.serialize())!
    let v4 = amount
    let b = TransactionBuilder()
    let params: [AbiParameter] = [
      AbiParameter(name: "spender", type: .byteArray, value: AbiParameter.Value.bytes(v1)),
      AbiParameter(name: "from", type: .byteArray, value: AbiParameter.Value.bytes(v2)),
      AbiParameter(name: "to", type: .byteArray, value: AbiParameter.Value.bytes(v3)),
      AbiParameter(name: "amount", type: .long, value: AbiParameter.Value.long(v4)),
    ]
    return try b.makeInvokeTransaction(
      fnName: fn,
      params: params,
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func makeQueryAllowanceTx(owner: Address, spender: Address) throws -> Transaction {
    let fn = Oep4TxBuilder.Method.allowance.rawValue
    let v1 = try Data.from(hex: owner.serialize())!
    let v2 = try Data.from(hex: spender.serialize())!
    let params: [AbiParameter] = [
      AbiParameter(name: "owner", type: .byteArray, value: AbiParameter.Value.bytes(v1)),
      AbiParameter(name: "spender", type: .byteArray, value: AbiParameter.Value.bytes(v2)),
    ]
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: params, contract: contract)
  }

  public func makeQueryBalanceOfTx(addr: Address) throws -> Transaction {
    let fn = Oep4TxBuilder.Method.balanceOf.rawValue
    let v = try Data.from(hex: addr.serialize())!
    let p = AbiParameter(name: "from", type: .byteArray, value: AbiParameter.Value.bytes(v))
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: [p], contract: contract)
  }

  public func makeQueryTotalSupplyTx() throws -> Transaction {
    let fn = Oep4TxBuilder.Method.totalSupply.rawValue
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: [], contract: contract)
  }

  public func makeQueryDecimalsTx() throws -> Transaction {
    let fn = Oep4TxBuilder.Method.decimals.rawValue
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: [], contract: contract)
  }

  public func makeQuerySymbolTx() throws -> Transaction {
    let fn = Oep4TxBuilder.Method.symbol.rawValue
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: [], contract: contract)
  }

  public func makeQueryNameTx() throws -> Transaction {
    let fn = Oep4TxBuilder.Method.name.rawValue
    let b = TransactionBuilder()
    return try b.makeInvokeTransaction(fnName: fn, params: [], contract: contract)
  }

  public enum Method: String {
    case Init = "init"
    case transfer, transferMulti, approve
    case transferFrom, allowance, balanceOf
    case totalSupply, symbol, decimals, name
  }
}
