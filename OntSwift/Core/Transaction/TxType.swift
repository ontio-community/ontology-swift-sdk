//
//  TxType.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public enum TxType: Int {
  case bookKeeper = 0x02
  case claim = 0x03
  case deploy = 0xD0
  case invoke = 0xD1
  case enrollment = 0x04
  case vote = 0x05

  public var name: String {
    switch self {
    case .bookKeeper: return "BookKeeper"
    case .claim: return "Claim"
    case .deploy: return "Deploy"
    case .invoke: return "Invoke"
    case .enrollment: return "Enrollment"
    case .vote: return "Vote"
    }
  }
}
