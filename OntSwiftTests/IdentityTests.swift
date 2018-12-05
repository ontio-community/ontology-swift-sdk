//
//  IdentityTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/5.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest

class IdentityTests: XCTestCase {
  var prikey: PrivateKey?
  var id: Identity?
  var encPrikey: PrivateKey?
  var addr: Address?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    prikey = try! PrivateKey.random()

    id = try! Identity.create(prikey: prikey!, pwd: "123456", label: "mickey")
    addr = id!.controls[0].address
    encPrikey = id!.controls[0].encryptedKey
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCreate() throws {
    let data = try JSONEncoder().encode(id)
    let tmp = try JSONDecoder().decode(Identity.self, from: data)

    let pri = try tmp.privateKey(pwd: "123456")
    XCTAssertTrue(pri.raw.elementsEqual(prikey!.raw))
  }

  func testFromEncrypted() throws {
    let id = try Identity.from(
      encrypted: encPrikey!,
      label: "mickey",
      pwd: "123456",
      addr: addr!,
      salt: self.id!.controls[0].salt
    )
    XCTAssertEqual("mickey", id.label)
  }

  func testFromKeystore() throws {
    let str = """
    {"address":"AG9W6c7nNhaiywcyVPgW9hQKvUYQr5iLvk","key":"+UADcReBcLq0pn/2Grmz+UJsKl3ryop8pgRVHbQVgTBfT0lho06Svh4eQLSmC93j","parameters":{"curve":"P-256"},"label":"11111","scrypt":{"dkLen":64,"n":4096,"p":8,"r":8},"salt":"IfxFV0Fer5LknIyCLP2P2w==","type":"I","algorithm":"ECDSA"}
    """
    let id = try Identity.from(keystore: str, pwd: "111111")
    XCTAssertEqual("AG9W6c7nNhaiywcyVPgW9hQKvUYQr5iLvk", try id.controls[0].address.toBase58())
    XCTAssertEqual(
      "+UADcReBcLq0pn/2Grmz+UJsKl3ryop8pgRVHbQVgTBfT0lho06Svh4eQLSmC93j",
      id.controls[0].encryptedKey.raw.base64EncodedString()
    )
  }
}
