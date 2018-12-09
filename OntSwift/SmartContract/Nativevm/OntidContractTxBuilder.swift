//
//  OntidContractTxBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class OntidContractTxBuilder {
  public static let ontidContract = "0000000000000000000000000000000000000003"

  public func buildRegisterOntidTx(
    ontid: Data,
    pubkey: PublicKey,
    gasPrice: String,
    gasLimit: String,
    payer: Address? = nil
  ) throws -> Transaction {
    let method = OntidContractTxBuilder.Method.regIDWithPublicKey

    let structure = Struct()
    structure.add(params: ontid, pubkey.hex())
    let list: [Any] = [structure]

    let pb = NativeVmParamsBuilder()
    _ = try pb.pushNativeCodeScript(objs: list)

    let txb = TransactionBuilder()
    return try txb.makeNativeContractTx(
      fnName: method.rawValue,
      params: pb.buf,
      contract: Address(value: OntidContractTxBuilder.ontidContract),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func buildRegisterOntidTx(
    ontid: String,
    pubkey: PublicKey,
    gasPrice: String,
    gasLimit: String,
    payer: Address? = nil
  ) throws -> Transaction {
    return try buildRegisterOntidTx(
      ontid: ontid.data(using: .utf8)!,
      pubkey: pubkey,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: payer
    )
  }

  public func buildGetDDOTx(ontid: Data) throws -> Transaction {
    let method = OntidContractTxBuilder.Method.getDDO

    let structure = Struct()
    structure.add(params: ontid)

    let pb = NativeVmParamsBuilder()
    _ = try pb.pushNativeCodeScript(objs: [structure])

    let txb = TransactionBuilder()
    return try txb.makeNativeContractTx(
      fnName: method.rawValue,
      params: pb.buf,
      contract: Address(value: OntidContractTxBuilder.ontidContract),
      gasPrice: nil,
      gasLimit: nil,
      payer: nil
    )
  }

  public func buildGetDDOTx(ontid: String) throws -> Transaction {
    return try buildGetDDOTx(ontid: ontid.data(using: .utf8)!)
  }

  public enum Method: String {
    case regIDWithPublicKey, regIDWithAttributes, addAttributes, removeAttribute
    case getAttributes, getDDO, addKey, removeKey, getPublicKeys, addRecovery
    case changeRecovery, getKeyState
  }
}
