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

  public func verify(amount: Int) throws -> BigInt {
    return try verify(amount: BigInt(amount))
  }

  public func verify(amount: String) throws -> BigInt {
    return try verify(amount: BigInt(amount))
  }

//  public func makeTransferTx() throws -> Transfer {
//
//  }
}

public enum OntAssetTxBuilderError: Error {
  case invalidTokenType, invalidAmount
}
