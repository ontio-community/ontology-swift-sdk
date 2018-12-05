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
