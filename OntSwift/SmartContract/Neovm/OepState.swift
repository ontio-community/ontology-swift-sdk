//
//  OepState.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class OepState {
  public let from: String
  public let to: String
  public let amount: BigInt

  public init(from: Address, to: Address, amount: BigInt) throws {
    self.from = try from.toBase58()
    self.to = try to.toBase58()
    self.amount = amount
  }
}
