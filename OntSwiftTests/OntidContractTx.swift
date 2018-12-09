//
//  OntidContractTx.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/9.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest
import SwiftyJSON

class OntidContractTx: XCTestCase {
  var prikey1: PrivateKey?
  var address1: Address?

  var prikey2: PrivateKey?
  var address2: Address?

  let gasPrice = "0"
  let gasLimit = "20000"

  var rpc: WebsocketRpc?

  var ontid: String?

  var prikey: PrivateKey?
  var pubkey: PublicKey?
  var account: Account?
  var address: Address?

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

    prikey = try! PrivateKey.random()
    pubkey = try! prikey?.getPublicKey()
    account = try! Account.create(pwd: "123456", prikey: prikey, label: "", params: nil)
    address = account!.address

    ontid = try! "did:ont:" + address!.toBase58()

    DispatchQueue.promises = .global(qos: .background)
  }

  func testRegisterOntId() throws {
    let expect = XCTestExpectation(description: "testRegisterOntId")

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

  func testGetDDO() throws {
    let expect = XCTestExpectation(description: "testGetDDO")

    let b = OntidContractTxBuilder()
    let tx = try b.buildGetDDOTx(ontid: ontid!)

    let txb = TransactionBuilder()
    try txb.sign(tx: tx, prikey: prikey1!)

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }
}
