//
//  AccountTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest

class AccountTests: XCTestCase {
  var prikey: PrivateKey?
  var acc: Account?
  var accStr: String?
  var encPrikey: PrivateKey?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    prikey = try! PrivateKey.random()
    acc = try! Account.create(pwd: "123456", prikey: prikey, label: "mickey")
    encPrikey = acc!.encryptedKey
    accStr = try! JSONEncoder().encode(acc).utf8string
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCreate() throws {
    XCTAssertTrue(accStr != nil)
  }

  func testFromEncrypted() throws {
    let acc = try Account.from(
      encrypted: encPrikey!,
      label: "mickey",
      pwd: "123456",
      addr: self.acc!.address,
      salt: self.acc!.salt
    )
    let prikey = try acc.privateKey(pwd: "123456")
    XCTAssertTrue(prikey.raw.elementsEqual(self.prikey!.raw))
  }

  func testFromKeystore() throws {
    let str = """
    {"address":"AG9W6c7nNhaiywcyVPgW9hQKvUYQr5iLvk","key":"+UADcReBcLq0pn/2Grmz+UJsKl3ryop8pgRVHbQVgTBfT0lho06Svh4eQLSmC93j","parameters":{"curve":"P-256"},"label":"11111","scrypt":{"dkLen":64,"n":4096,"p":8,"r":8},"salt":"IfxFV0Fer5LknIyCLP2P2w==","type":"A","algorithm":"ECDSA"}
    """
    let acc = try Account.from(keystore: str, pwd: "111111")
    XCTAssertEqual("AG9W6c7nNhaiywcyVPgW9hQKvUYQr5iLvk", try acc.address.toBase58())
    XCTAssertEqual(
      "+UADcReBcLq0pn/2Grmz+UJsKl3ryop8pgRVHbQVgTBfT0lho06Svh4eQLSmC93j",
      acc.encryptedKey.raw.base64EncodedString()
    )
  }
}
