//
//  KeychainTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/2.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest

class KeychainTests: XCTestCase {
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testFromPath() throws {
    let mnemonic = try Mnemonic.generate()
    let seed = Mnemonic.seed(mnemonic: mnemonic)
    let keychain = HDKeychain(seed: seed)
    let privateKey = try keychain.derivedKey(path: "m/44'/1'/0'/0/0")
    print(privateKey.raw.hex())
  }

  //
  //  func testHex() throws {
  //    XCTAssertEqual("0a00", try BigInt.from(hex: "0a", size: 1, oe: [.msw, .native]).toHex(size: 2, oe: [.lsw, .native]))
  //    XCTAssertEqual("78563412", try BigInt(i: 0x1234_5678).toHex(size: 2, oe: [.lsw, .native]))
  //  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }
}
