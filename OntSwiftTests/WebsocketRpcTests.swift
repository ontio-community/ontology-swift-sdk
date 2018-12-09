//
//  WebsocketRpcTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/6.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest
import SwiftyJSON

class WebsocketRpcTests: XCTestCase {
  var prikey1: PrivateKey?
  var address1: Address?

  var prikey: PrivateKey?
  var pubkey: PublicKey?
  var account: Account?
  var address: Address?

  let gasPrice = "0"
  let gasLimit = "20000"

  var rpc: WebsocketRpc?

  var ontid: String?

  func setupTestAccount1() throws {
    let w = try TestWallet.w()
    prikey1 = try w.accounts[0].privateKey(pwd: "123456", params: w.scrypt)
    address1 = w.accounts[0].address
  }

  override func setUp() {
    try! setupTestAccount1()

    prikey = try! PrivateKey.random()
    pubkey = try! prikey?.getPublicKey()
    account = try! Account.create(pwd: "123456", prikey: prikey, label: "", params: nil)
    address = account!.address

    ontid = try! "did:ont:" + address!.toBase58()

    rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
    rpc!.open()

    DispatchQueue.promises = .global(qos: .background)
  }

  func testGetNodeCount() throws {
    let expect = XCTestExpectation(description: "testGetNodeCount")

    DispatchQueue.global(qos: .background).async {
      try! self.rpc!.getNodeCount().then {
        XCTAssertEqual("SUCCESS", $0["Desc"].string!)
        expect.fulfill()
      }
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testBlockHeight() throws {
    let expect = XCTestExpectation(description: "testBlockHeight")

    try! rpc!.getBlockHeight().then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testGetBalance() throws {
    let expect = XCTestExpectation(description: "testGetBalance")

    try! rpc!.getBalance(address: address!).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testUnclaimedOng() throws {
    let expect = XCTestExpectation(description: "testUnclaimedOng")

    try! rpc!.getUnclaimedOng(address: Address(value: "ASSxYHNSsh4FdF2iNvHdh3Np2sgWU21hfp")).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testSendRawTransactoion() throws {
    let expect = XCTestExpectation(description: "testSendRawTransactoion")

    let b = OntidContractTxBuilder()
    let tx = try b.buildRegisterOntidTx(
      ontid: ontid!,
      pubkey: prikey1!.getPublicKey(),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: address1
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize()).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testSendRawTransactoionWait() throws {
    let expect = XCTestExpectation(description: "testSendRawTransactoionWait")

    let b = OntidContractTxBuilder()
    let tx = try b.buildRegisterOntidTx(
      ontid: ontid!,
      pubkey: prikey1!.getPublicKey(),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: address1
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }
}

enum WebsocketRpcTestsError: Error {
  case timeout
}
