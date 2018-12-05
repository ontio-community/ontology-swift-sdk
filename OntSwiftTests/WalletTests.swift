//
//  WalletTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest

class WalletTests: XCTestCase {
  var w: Wallet?
  var wStr: String?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    w = Wallet(name: "mickey")
    wStr = try! JSONEncoder().encode(w).utf8string
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testWalletCreate() {
    XCTAssertTrue(wStr != nil)
  }

  func testAddAccount() throws {
    let pk = try PrivateKey.random()
    let acc = try Account.create(pwd: "123456", prikey: pk, label: "mickey")
    try w!.add(account: acc)
    XCTAssertTrue(w!.accounts.count == 1)
  }

  func testFromJson() throws {
    let str = """
    {"name":"MyWallet","version":"1.1","scrypt":{"p":8,"n":16384,"r":8,"dkLen":64},"accounts":[{"address":"AUr5QUfeBADq6BMY6Tp5yuMsUNGpsD7nLZ","enc-alg":"aes-256-gcm","key":"KysbyR9wxnD2XpiH5Xgo4q0DTqKJxaA+Sz3I60fIvsn7wktC9Utb1XYzfHt4mjjl","algorithm":"ECDSA","salt":"dg2t+nlEDEvhP52epby/gw==","parameters":{"curve":"P-256"},"label":"","publicKey":"03f631f975560afc7bf47902064838826ec67794ddcdbcc6f0a9c7b91fc8502583","signatureScheme":"SHA256withECDSA","isDefault":true,"lock":false}]}
    """
    let w = try JSONDecoder().decode(Wallet.self, from: str.data(using: .utf8)!)
    XCTAssertTrue(w.accounts.count == 1)
    XCTAssertTrue(w.identities.count == 0)
  }
}
