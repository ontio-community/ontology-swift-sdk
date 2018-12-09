//
//  OepState.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/8.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class OepState {
  public let from: Address
  public let to: Address
  public let amount: BigInt

  public init(from: Address, to: Address, amount: BigInt) {
    self.from = from
    self.to = to
    self.amount = amount
  }
}
