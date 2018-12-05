//
//  Constant.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/11/30.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Constant {
  public static let defaultAlgorithm = JSON([
    "algorithm": "ECDSA",
    "parameters": [
      "curve": "P-256",
    ],
  ])

  public static let defaultScrypt = JSON([
    "cost": 4096,
    "blockSize": 8,
    "parallel": 8,
    "size": 64,
  ])

  public static let ontBip44Path = "m/44'/1024'/0'/0/0"

  public static let addrVersion: UInt8 = 0x17

  public static let defaultSm2Id = "1234567812345678".data(using: .utf8)!

  public static let testNode = "polaris1.ont.io"
  public static let httpWsPort = "20335"
  
  public static let testOntUrl = JSON([
    "SOCKET_URL": "ws://\(testNode):\(httpWsPort)"
  ])
}
