//
//  OntAssetTxBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class OntAssetTxBuilder {
  public static let ontContract = "0000000000000000000000000000000000000001"
  public static let ongContract = "0000000000000000000000000000000000000002"

  public init() {}
  
  public func tokenContract(tokenType: String) throws -> Address {
    if tokenType == Constant.tokenType["ONT"].string! {
      return try Address(value: OntAssetTxBuilder.ontContract)
    } else if tokenType == Constant.tokenType["ONG"].string! {
      return try Address(value: OntAssetTxBuilder.ongContract)
    }
    throw OntAssetTxBuilderError.invalidTokenType
  }

  public func verify(amount: BigInt) throws -> BigInt {
    if amount < BigInt(0) {
      throw OntAssetTxBuilderError.invalidAmount
    }
    return amount
  }

  public func makeTransferTx(
    tokenType: String,
    from: Address,
    to: Address,
    amount: BigInt,
    gasPrice: String = "0",
    gasLimit: String = "20000",
    payer: Address? = nil
  ) throws -> Transaction {
    let amount = try verify(amount: amount)

    let structure = Struct()
    structure.add(params: from, to, amount)
    let list: [Any] = [[structure]]

    let b = NativeVmParamsBuilder()
    _ = try b.pushNativeCodeScript(objs: list)
    let params = b.buf

    let contract = try tokenContract(tokenType: tokenType)
    let txb = TransactionBuilder()
    let tx = try txb.makeNativeContractTx(
      fnName: "transfer",
      params: params,
      contract: contract,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )

    tx.tokenType = tokenType
    tx.from = from
    tx.to = to
    tx.amount = amount
    tx.method = "transfer"

    if let payer = payer {
      tx.payer = payer
    } else {
      tx.payer = from
    }
    return tx
  }

  public func makeWithdrawOngTx(
    from: Address,
    to: Address,
    amount: BigInt,
    gasPrice: String,
    gasLimit: String,
    payer: Address
  ) throws -> Transaction {
    let amount = try verify(amount: amount)
    let structure = Struct()
    try structure.add(params: from, Address(value: OntAssetTxBuilder.ontContract), to, amount)
    let list: [Any] = [structure]

    let b = NativeVmParamsBuilder()
    _ = try b.pushNativeCodeScript(objs: list)
    let params = b.buf

    let txb = TransactionBuilder()
    let tx = try txb.makeNativeContractTx(
      fnName: "transferFrom",
      params: params,
      contract: Address(value: OntAssetTxBuilder.ongContract),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )

    tx.tokenType = "ONG"
    tx.from = from
    tx.to = to
    tx.amount = amount
    tx.method = "transferFrom"

    return tx
  }

  public func deserializeTx(r: ScriptReader) throws -> Transaction {
    let tx = try Transaction.deserialize(r: r)
    let code = try tx.payload!.serialize().hexEncoded

    let contractIdx1 = code.indexOf(stuff: "14" + "000000000000000000000000000000000000000")
    let contractIdx2 = code.indexOf(stuff: "14" + "0000000000000000000000000000000000000002")

    if contractIdx1 > 0 && code.substr(start: contractIdx1 + 41, len: 1) == "1" {
      tx.tokenType = "ONT"
    } else if contractIdx1 > 0 && code.substr(start: contractIdx1 + 41, len: 1) == "2" {
      tx.tokenType = "ONG"
    } else {
      throw OntAssetTxBuilderError.notTransferTx
    }

    let contractIdx = max(contractIdx1, contractIdx2)
    let params = code.substr(start: 0, len: contractIdx)
    let paramsEnd = code.indexOf(stuff: "6a7cc86c") + 8
    var method = ""
    if params.substr(start: paramsEnd, len: 4) == "51c1" {
      method = params.substr(start: paramsEnd + 6, len: params.count - paramsEnd - 6)
    } else {
      method = params.substr(start: paramsEnd + 2, len: params.count - paramsEnd - 2)
    }
    tx.method = Data.from(hex: method)?.utf8string!

    let r = ScriptReader(buf: Data.from(hex: params)!)
    if tx.method == "transfer" {
      r.advance(cnt: 5)
      tx.from = Address(value: r.forward(cnt: 20))
      r.advance(cnt: 4)
      tx.to = Address(value: r.forward(cnt: 20))
      r.advance(cnt: 3)
      let numTmp = r.readUInt8()
      if r.branch(ofst: r.ofst).forward(cnt: 3).hexEncoded == "6a7cc8" {
        tx.amount = BigInt(Int(numTmp) - 80)
      } else {
        tx.amount = BigInt(r.forward(cnt: Int(numTmp)))
      }
    } else if tx.method == "transferFrom" {
      r.advance(cnt: 5)
      tx.from = Address(value: r.forward(cnt: 20))
      r.advance(cnt: 28)
      tx.to = Address(value: r.forward(cnt: 20))
      r.advance(cnt: 3)
      let numTmp = r.readUInt8()
      if r.branch(ofst: r.ofst).forward(cnt: 3).hexEncoded == "6a7cc8" {
        tx.amount = BigInt(Int(numTmp) - 80)
      } else {
        tx.amount = BigInt(r.forward(cnt: Int(numTmp)))
      }
    } else {
      throw OntAssetTxBuilderError.notTransferTx
    }

    return tx
  }
}

public enum OntAssetTxBuilderError: Error {
  case invalidTokenType, invalidAmount, notTransferTx
}
