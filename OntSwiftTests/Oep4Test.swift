//
//  Oep4Test.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/9.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest
import SwiftyJSON

class Oep4Test: XCTestCase {
  var prikey1: PrivateKey?
  var address1: Address?

  var prikey2: PrivateKey?
  var address2: Address?

  let gasPrice = "0"
  let gasLimit = "20000"

  var rpc: WebsocketRpc?

  let codehash = "cf8a3226f873bb73ed66039de4ff6a32b00693ac"

  func setupTestAccounts() throws {
    let w = try TestWallet.w()
    prikey1 = try w.accounts[0].privateKey(pwd: "123456", params: w.scrypt)
    address1 = w.accounts[0].address

    prikey2 = try w.accounts[1].privateKey(pwd: "123456", params: w.scrypt)
    address2 = w.accounts[1].address
  }

  func deployTestContract() throws {
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: "Oep4Test", ofType: "avm")!
    let code = NSData(contentsOfFile: path)!

    let b = TransactionBuilder()
    let tx = try b.makeDeployCodeTransaction(
      code: code as Data,
      name: "name",
      codeVersion: "1.0",
      author: "alice",
      email: "email",
      desc: "desc",
      needStorage: true,
      gasPrice: gasPrice,
      gasLimit: "30000000",
      payer: address1!
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "deployTestContract")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func callInit() throws {
    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeInitTx(gasPrice: gasPrice, gasLimit: gasLimit, payer: address1!)

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "callInit")
    try rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  override func setUp() {
    try! setupTestAccounts()

    rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
    rpc!.open()

    DispatchQueue.promises = .global(qos: .background)

    try! deployTestContract()
    try! callInit()
  }

  func testQueryName() throws {
    let expect = expectation(description: "testQueryName")

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQueryNameTx()

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let name = String(bytes: Data.from(hex: $0["Result", "Result"].string!)!, encoding: .utf8)!
      XCTAssertEqual("MyToken", name)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testQuerySymbol() throws {
    let expect = expectation(description: "testQuerySymbol")

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQuerySymbolTx()

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let symbol = String(bytes: Data.from(hex: $0["Result", "Result"].string!)!, encoding: .utf8)!
      XCTAssertEqual("MYT", symbol)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testQueryDecimals() throws {
    let expect = expectation(description: "testQueryDecimals")

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQueryDecimalsTx()

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let bytes = Data.from(hex: $0["Result", "Result"].string!)!
      let decimals = BigInt(bytes)
      XCTAssertEqual(BigInt(8), decimals)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testQueryTotalSupply() throws {
    let expect = expectation(description: "testQueryTotalSupply")

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQueryTotalSupplyTx()

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let bytes = Data.from(hex: $0["Result", "Result"].string!)!
      let supply = BigInt(bytes.reversed())
      XCTAssertEqual(BigInt(1_000_000_000) * BigInt(100_000_000), supply)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testQueryBalance() throws {
    let expect = expectation(description: "testQueryBalance")

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQueryBalanceOfTx(addr: address1!)

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTransfer() throws {
    let expect = expectation(description: "testTransfer")

    let from = address1!
    let to = address2!

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeTransferTx(
      from: from,
      to: to,
      amount: BigInt(10000),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: from
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testApprove() throws {
    let expect = expectation(description: "testApprove")

    let owner = address1!
    let spender = address2!

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeApproveTx(
      owner: owner,
      spender: spender,
      amount: BigInt(10000),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: owner
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testQueryAlloance() throws {
    let expect = expectation(description: "testQueryAlloance")

    let owner = address1!
    let spender = address2!

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeQueryAllowanceTx(owner: owner, spender: spender)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTransferFrom() throws {
    let expect = expectation(description: "testTransferFrom")

    let owner = address1!
    let spender = address2!

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeTransferFromTx(
      spender: spender,
      from: spender,
      to: owner,
      amount: BigInt(10000),
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      payer: spender
    )

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTransferMulti() throws {
    let expect = expectation(description: "testTransferMulti")

    let prikey3 = try PrivateKey.random()
    let addr3 = try Address.from(pubkey: prikey3.getPublicKey())

    let state1 = OepState(from: address1!, to: address2!, amount: BigInt(200))
    let state2 = OepState(from: address1!, to: addr3, amount: BigInt(300))

    let b = try Oep4TxBuilder(contract: Address(value: codehash))
    let tx = try b.makeTransferMultiTx(states: [state1, state2], gasPrice: gasPrice, gasLimit: gasLimit, payer: address1!)

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)
    try txb.addSig(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }.catch {
      XCTAssertNil($0)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }
}
