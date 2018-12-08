//
//  WebsocketRpc.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/6.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import SwiftWebSocket
import SwiftyJSON
import Promises

public struct Pending {
  public let id: String
  public let deferred: Promise<JSON>

  public init() {
    id = UUID().uuidString
    deferred = Promise<JSON>.pending()
  }
}

public class WebsocketRpc {
  public let url: String

  public let ws: WebSocket

  public private(set) var pendings: [String: Pending] = [:]

  public private(set) var writeQueue: [Data] = []

  public private(set) var isOpen = false

  public var onError: (_ err: Error) -> Void = { _ in }

  public var reconnectTimes = 3
  public var reconnectDelay = 10
  public var isReconnecting = false

  public init(url: String? = nil) {
    self.url = url == nil ? Constant.testOntUrl["SOCKET_URL"].string! : url!
    ws = WebSocket()
  }

  func sendImmediately(data: Data) {
    ws.send(data: data)
  }

  public func send(data: [String: Any]) throws -> Pending {
    let pending = Pending()

    var data = data
    data["Id"] = pending.id
    pendings[pending.id] = pending

    let raw = try JSONSerialization.data(withJSONObject: data, options: [])

    if isOpen {
      sendImmediately(data: raw)
    } else {
      writeQueue.append(raw)
    }

    return pending
  }

  public func getNodeCount() throws -> Promise<JSON> {
    let data: [String: String] = [
      "Action": "getconnectioncount",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func send(rawTransaction: Data, preExec: Bool = false) throws -> Promise<JSON> {
    var data = [
      "Action": "getconnectioncount",
      "Version": "1.0.0",
      "Data": rawTransaction.hexEncoded,
    ]
    if preExec {
      data["PreExec"] = "1"
    }
    return try send(data: data).deferred
  }

  public func getRawTransaction(txHash: String, json: Bool = false) throws -> Promise<JSON> {
    let data = [
      "Action": "gettransaction",
      "Version": "1.0.0",
      "Hash": txHash,
      "Raw": json ? "0" : "1",
    ]
    return try send(data: data).deferred
  }

  public func getBlockHeight() throws -> Promise<JSON> {
    let data = [
      "Action": "getblockheight",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func getBlock(by height: Int, json: Bool = false) throws -> Promise<JSON> {
    var data = [
      "Action": "getblockbyheight",
      "Version": "1.0.0",
      "Height": height.description,
    ]
    if !json {
      data["Raw"] = "1"
    }
    return try send(data: data).deferred
  }

  public func getBlock(by hash: String, json: Bool = false) throws -> Promise<JSON> {
    var data = [
      "Action": "getblockbyhash",
      "Version": "1.0.0",
      "Hash": hash,
    ]
    if !json {
      data["Raw"] = "1"
    }
    return try send(data: data).deferred
  }

  public func getBalance(address: Address) throws -> Promise<JSON> {
    let data = [
      "Action": "getbalance",
      "Version": "1.0.0",
      "Addr": try address.toBase58(),
    ]
    return try send(data: data).deferred
  }

  public func getUnboundOng(address: Address) throws -> Promise<JSON> {
    let data = [
      "Action": "getunboundong",
      "Version": "1.0.0",
      "Addr": try address.toBase58(),
    ]
    return try send(data: data).deferred
  }

  public func getContract(hash: String, json: Bool = false) throws -> Promise<JSON> {
    let data = [
      "Action": "getcontract",
      "Version": "1.0.0",
      "Hash": hash,
      "Raw": json ? "0" : "1",
    ]
    return try send(data: data).deferred
  }

  public func getSmartCodeEvent(by height: Int) throws -> Promise<JSON> {
    let data = [
      "Action": "getsmartcodeeventbyheight",
      "Version": "1.0.0",
      "Height": height.description,
    ]
    return try send(data: data).deferred
  }

  public func getSmartCodeEvent(by hash: String) throws -> Promise<JSON> {
    let data = [
      "Action": "getsmartcodeeventbyhash",
      "Version": "1.0.0",
      "Hash": hash,
    ]
    return try send(data: data).deferred
  }

  public func getBlockHeight(by txHash: String) throws -> Promise<JSON> {
    let data = [
      "Action": "getblockheightbytxhash",
      "Version": "1.0.0",
      "Hash": txHash,
    ]
    return try send(data: data).deferred
  }

  public func getStorage(codeHash: String, key: String) throws -> Promise<JSON> {
    let data = [
      "Action": "getstorage",
      "Version": "1.0.0",
      "Hash": codeHash,
      "Key": key,
    ]
    return try send(data: data).deferred
  }

  public func getMerkleProof(hash: String) throws -> Promise<JSON> {
    let data = [
      "Action": "getmerkleproof",
      "Version": "1.0.0",
      "Hash": hash,
    ]
    return try send(data: data).deferred
  }

  public func getAllowance(asset: String, from: Address, to _: Address) throws -> Promise<JSON> {
    let data = [
      "Action": "getallowance",
      "Version": "1.0.0",
      "Asset": asset,
      "From": try from.toBase58(),
      "To": try from.toBase58(),
    ]
    return try send(data: data).deferred
  }

  public func getBlockHash(value: Int) throws -> Promise<JSON> {
    let data = [
      "Action": "getblockhash",
      "Version": "1.0.0",
      "Height": value.description,
    ]
    return try send(data: data).deferred
  }

  public func getBlockTxsByHeight(value: Int) throws -> Promise<JSON> {
    let data = [
      "Action": "getblocktxsbyheight",
      "Version": "1.0.0",
      "Height": value.description,
    ]
    return try send(data: data).deferred
  }

  public func getGasPrice() throws -> Promise<JSON> {
    let data = [
      "Action": "getgasprice",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func getGrantOng(address: Address) throws -> Promise<JSON> {
    let data = [
      "Action": "getgrantong",
      "Version": "1.0.0",
      "Addr": try address.toBase58(),
    ]
    return try send(data: data).deferred
  }

  public func getMempoolTxCount() throws -> Promise<JSON> {
    let data = [
      "Action": "getmempooltxcount",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func getMempoolTxState(txHash: String) throws -> Promise<JSON> {
    let data = [
      "Action": "getmempooltxstate",
      "Version": "1.0.0",
      "Hash": txHash,
    ]
    return try send(data: data).deferred
  }

  public func getVersion() throws -> Promise<JSON> {
    let data = [
      "Action": "getversion",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func getNetworkId() throws -> Promise<JSON> {
    let data = [
      "Action": "getnetworkid",
      "Version": "1.0.0",
    ]
    return try send(data: data).deferred
  }

  public func open() {
    ws.event.open = webSocketOpen
    ws.event.error = webSocketError
    ws.event.close = webSocketClose
    ws.event.message = webSocketMessage
    ws.open(url)
  }

  func reconnecting() {
    if isOpen || isReconnecting || reconnectTimes == 0 {
      return
    }

    isReconnecting = true
    reconnectTimes -= 1

    let delay = reconnectDelay
    reconnectDelay = delay + 20

    Promise(0).delay(TimeInterval(delay)).then { _ in
      self.ws.open(self.url)
    }
  }

  public func webSocketOpen() {
    isOpen = true
    writeQueue.forEach { sendImmediately(data: $0) }
    writeQueue.removeAll()
  }

  public func webSocketClose(_: Int, reason _: String, wasClean _: Bool) {
    isOpen = false
    reconnecting()
  }

  public func webSocketError(_ error: Error) {
    isReconnecting = false
    ws.close()
    onError(error)
  }

  func resolve(pending id: String, result: JSON) {
    if let pending = pendings[id] {
      pending.deferred.fulfill(result)
      pendings.removeValue(forKey: id)
    }
  }

  public func webSocketMessage(_ data: Any) {
    if let json = data as? String {
      let reslut = JSON(parseJSON: json)
      if let id = reslut["Id"].string {
        resolve(pending: id, result: reslut)
      }
    }
  }
}
