//
//  HelloOntology.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/10.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest
import SwiftyJSON

class NeoVmTests: XCTestCase {
  var prikey1: PrivateKey?
  var address1: Address?

  var prikey2: PrivateKey?
  var address2: Address?

  let gasPrice = "0"
  let gasLimit = "20000"

  var rpc: WebsocketRpc?

  var codehash: String?
  var abi: AbiInfo?

  func setupTestAccounts() throws {
    let w = try TestWallet.w()
    prikey1 = try w.accounts[0].privateKey(pwd: "123456", params: w.scrypt)
    address1 = w.accounts[0].address

    prikey2 = try w.accounts[1].privateKey(pwd: "123456", params: w.scrypt)
    address2 = w.accounts[1].address
  }

  func loadCode() -> Data {
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: "NeoVmTests", ofType: "avm")!
    let codeBin = NSData(contentsOfFile: path)! as Data
    // some editor will insert new lines at the end of file so we trim them first
    let codeHex = String(bytes: codeBin, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let code = Data.from(hex: codeHex!)!
    codehash = Address.from(vmcode: code).toHex()
    return code
  }

  func loadAbi() throws {
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: "NeoVmTests.abi", ofType: "json")!
    let json = NSData(contentsOfFile: path)! as Data
    let abiFile = try JSONDecoder().decode(AbiFile.self, from: json)
    abi = abiFile.abi
  }

  func deployTestContract() throws {
    let code = loadCode()

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

  override func setUp() {
    try! setupTestAccounts()

    rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
    rpc!.open()

    DispatchQueue.promises = .global(qos: .background)

    try! deployTestContract()
    try! loadAbi()
  }

  func testName() throws {
    let fn = abi!.function(name: "name")!

    let b = TransactionBuilder()
    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [],
      contract: Address(value: codehash!),
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testName")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let name = String(hex: $0["Result", "Result"].string!)!
      XCTAssertEqual("name", name)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testHello() throws {
    let fn = abi!.function(name: "hello")!

    let b = TransactionBuilder()

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [
        "world".abiParameter(name: "msg"),
      ],
      contract: Address(value: codehash!),
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testHello")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let msg = String(hex: $0["Result", "Result"].string!)!
      XCTAssertEqual("world", msg)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testTrue() throws {
    let fn = abi!.function(name: "testTrue")!

    let b = TransactionBuilder()

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [],
      contract: Address(value: codehash!),
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testTrue")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let ret = Bool(hex: $0["Result", "Result"].string!)
      XCTAssertEqual(true, ret)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testFalse() throws {
    let fn = abi!.function(name: "testFalse")!

    let b = TransactionBuilder()

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [],
      contract: Address(value: codehash!),
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testFalse")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let ret = Bool(hex: $0["Result", "Result"].string!)
      XCTAssertEqual(false, ret)
      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testList() throws {
    let fn = abi!.function(name: "testHello")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [
        false.abiParameter(name: "msgBool"),
        300.abiParameter(name: "msgInt"),
        Data(bytes: [1, 2, 3]).abiParameter(name: "msgByteArray"),
        "string".abiParameter(name: "msgStr"),
        contract.abiParameter(name: "msgAddress"),
      ],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testList")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let bool = Bool(hex: $0["Result", "Result", 0].string!)
      let int = Int(hex: $0["Result", "Result", 1].string!)
      let data = Data.from(hex: $0["Result", "Result", 2].string!)!
      let str = String(hex: $0["Result", "Result", 3].string!)!
      let addr = Data.from(hex: $0["Result", "Result", 4].string!)!

      XCTAssertEqual(false, bool)
      XCTAssertEqual(300, int)
      XCTAssertTrue(Data(bytes: [1, 2, 3]).elementsEqual(data))
      XCTAssertEqual("string", str)
      XCTAssertTrue(contract.toHexData().elementsEqual(addr))

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testStruct() throws {
    let fn = abi!.function(name: "testStructList")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let structure = Struct()
    structure.add(params: 100, "claimid".data(using: .utf8)!)

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [
        structure.abiParameter(name: "structList"),
      ],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testStruct")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let s = Struct(hex: $0["Result", "Result"].string!)
      let f1 = s.list[0] as! Struct.RawField
      let f2 = s.list[1] as! Struct.RawField

      let int = BigInt(f1.bytes).int64!
      let str = String(bytes: f2.bytes, encoding: .utf8)!

      XCTAssertEqual(100, int)
      XCTAssertEqual("claimid", str)

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func setMap() throws {
    let fn = abi!.function(name: "testMap")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let map = [
      "key": "value".abiParameter(),
    ].abiParameter(name: "msg")

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [map],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "setMap")

    // here we want to change the storage so the `preExec` flag SHOULD be false
    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testMap() throws {
    // set map
    try setMap()

    // get map
    let fn = abi!.function(name: "testGetMap")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [
        "key".abiParameter(name: "key"),
      ],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testGetMap")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let value = String(hex: $0["Result", "Result"].string!)
      XCTAssertEqual("value", value)

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func setMapInMap() throws {
    let fn = abi!.function(name: "testMapInMap")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let map = [
      "key": [
        "key": "value".abiParameter(),
      ].abiParameter(),
    ].abiParameter(name: "msg")

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [map],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "setMapInMap")

    // here we want to change the storage so the `preExec` flag SHOULD be false
    try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }

  func testMapInMap() throws {
    // set map in map
    try setMapInMap()

    // get map
    let fn = abi!.function(name: "testGetMapInMap")!

    let b = TransactionBuilder()

    let contract = try Address(value: codehash!)

    let tx = try b.makeInvokeTransaction(
      fnName: fn.name,
      params: [
        "key".abiParameter(name: "key"),
      ],
      contract: contract,
      gasPrice: "0",
      gasLimit: "30000000",
      payer: address1
    )
    try b.sign(tx: tx, prikey: prikey1!)

    let expect = expectation(description: "testMapInMap")

    try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
      XCTAssertEqual("SUCCESS", $0["Desc"].string!)

      let value = String(hex: $0["Result", "Result"].string!)
      XCTAssertEqual("value", value)

      expect.fulfill()
    }

    wait(for: [expect], timeout: 10.0)
  }
}
