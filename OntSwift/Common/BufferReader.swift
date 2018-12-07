//
//  BufferReader.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/6.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class BufferReader {
  public let buf: Data
  public private(set) var ofst: Int

  public init(buf: Data, ofst: Int = 0) {
    self.buf = buf
    self.ofst = ofst
  }

  public func readUInt8() -> UInt8 {
    let v = buf.readUInt8(ofst: ofst)
    ofst += 1
    return v
  }

  public func readUInt16LE() -> UInt16 {
    let v = buf.readUInt16(ofst: ofst, endian: .little)
    ofst += 2
    return v
  }

  public func readUInt32LE() -> UInt32 {
    let v = buf.readUInt32(ofst: ofst, endian: .little)
    ofst += 4
    return v
  }

  public func readUInt64LE() -> UInt64 {
    let v = buf.readUInt64(ofst: ofst, endian: .little)
    ofst += 8
    return v
  }

  public func forward(cnt: Int) -> Data {
    let sub = buf.subdata(in: ofst ..< (ofst + cnt))
    ofst += cnt
    return sub
  }

  public var isEnd: Bool {
    assert(ofst <= buf.count)
    return ofst == buf.count
  }
}
