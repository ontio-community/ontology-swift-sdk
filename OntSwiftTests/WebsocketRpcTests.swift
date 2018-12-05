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
  var rpc: WebsocketRpc?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
    rpc!.open()
  }

  func testGetNodeCount() throws {
    DispatchQueue.promises = .global(qos: .background)

    let expect = XCTestExpectation(description: "get node count")

    DispatchQueue.global(qos: .background).async {
      try! self.rpc!.getNodeCount().then {
        XCTAssertEqual("SUCCESS", $0["Desc"].string!)
        expect.fulfill()
      }
    }

    wait(for: [expect], timeout: 10.0)
  }
}

enum WebsocketRpcTestsError: Error {
  case timeout
}
