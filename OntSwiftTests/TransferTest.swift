//
//  TransferTest.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/9.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest
import SwiftyJSON

class TransferTest: XCTestCase {
  var prikey1: PrivateKey?
  var address1: Address?

  var prikey2: PrivateKey?
  var address2: Address?

  let gasPrice = "0"
  let gasLimit = "20000"

  var rpc: WebsocketRpc?

  func setupTestAccounts() throws {
    let w = try TestWallet.w()
    prikey1 = try w.accounts[0].privateKey(pwd: "123456", params: w.scrypt)
    address1 = w.accounts[0].address

    prikey2 = try w.accounts[1].privateKey(pwd: "123456", params: w.scrypt)
    address2 = w.accounts[1].address
  }

  override func setUp() {
    try! setupTestAccounts()

    rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
    rpc!.open()

    DispatchQueue.promises = .global(qos: .background)
  }

  func testTransferOnt() throws {
    let expect = XCTestExpectation(description: "testTransferOnt")

    let from = address1!
    let to = try Address(value: "AL9PtS6F8nue5MwxhzXCKaTpRb3yhtsix5")

    let ob = OntAssetTxBuilder()
    let tx = try ob.makeTransferTx(
      tokenType: "ONT",
      from: from,
      to: to,
      amount: BigInt(170),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: from
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize()).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTransferOng() throws {
    let expect = XCTestExpectation(description: "testTransferOng")

    let from = address1!
    let to = try Address(value: "AL9PtS6F8nue5MwxhzXCKaTpRb3yhtsix5")

    let ob = OntAssetTxBuilder()
    let tx = try ob.makeTransferTx(
      tokenType: "ONG",
      from: from,
      to: to,
      amount: BigInt(170),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: from
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize()).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testGetBalance() throws {
    let expect = XCTestExpectation(description: "testGetBalance")

    try! rpc!.getBalance(address: Address(value: "AL9PtS6F8nue5MwxhzXCKaTpRb3yhtsix5")).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTransferWithSm2Account() throws {
    let expect = XCTestExpectation(description: "testTransferWithSm2Account")

    let from = address2!
    let to = address1!

    let ob = OntAssetTxBuilder()
    let tx = try ob.makeTransferTx(
      tokenType: "ONT",
      from: from,
      to: to,
      amount: BigInt(100),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: from
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey2!, scheme: .sm2Sm3)

    try! rpc!.send(rawTransaction: tx.serialize()).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testWithdrawOng() throws {
    let expect = XCTestExpectation(description: "testWithdrawOng")

    let ob = OntAssetTxBuilder()
    let tx = try ob.makeWithdrawOngTx(
      from: address1!,
      to: address1!,
      amount: BigInt(1_000_000_000),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: address1!
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize()).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }
}
