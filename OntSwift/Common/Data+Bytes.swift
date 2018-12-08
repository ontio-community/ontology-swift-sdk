//
//  Data+Bytes.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public enum Endian {
  case big, little, native
}

extension Data {
  public mutating func append(_ newElement: UInt16, endian: Endian = .big) {
    if endian == .little {
      append(UInt8(newElement & 0xFF))
      append(UInt8((newElement >> 8) & 0xFF))
    } else {
      append(UInt8((newElement >> 8) & 0xFF))
      append(UInt8(newElement & 0xFF))
    }
  }

  public mutating func append(_ newElement: UInt32, endian: Endian = .big) {
    if endian == .little {
      append(UInt8(newElement & 0xFF))
      append(UInt8((newElement >> 8) & 0xFF))
      append(UInt8((newElement >> 16) & 0xFF))
      append(UInt8((newElement >> 24) & 0xFF))
    } else {
      append(UInt8((newElement >> 24) & 0xFF))
      append(UInt8((newElement >> 16) & 0xFF))
      append(UInt8((newElement >> 8) & 0xFF))
      append(UInt8(newElement & 0xFF))
    }
  }

  public mutating func append(_ newElement: UInt64, endian: Endian = .big) {
    if endian == .little {
      append(UInt8(newElement & 0xFF))
      append(UInt8((newElement >> 8) & 0xFF))
      append(UInt8((newElement >> 16) & 0xFF))
      append(UInt8((newElement >> 24) & 0xFF))
      append(UInt8((newElement >> 32) & 0xFF))
      append(UInt8((newElement >> 40) & 0xFF))
      append(UInt8((newElement >> 48) & 0xFF))
      append(UInt8((newElement >> 56) & 0xFF))
    } else {
      append(UInt8((newElement >> 56) & 0xFF))
      append(UInt8((newElement >> 48) & 0xFF))
      append(UInt8((newElement >> 40) & 0xFF))
      append(UInt8((newElement >> 32) & 0xFF))
      append(UInt8((newElement >> 24) & 0xFF))
      append(UInt8((newElement >> 16) & 0xFF))
      append(UInt8((newElement >> 8) & 0xFF))
      append(UInt8(newElement & 0xFF))
    }
  }

  public func readUInt8(ofst: Int) -> UInt8 {
    return self[ofst]
  }

  public func readUInt16(ofst: Int, endian: Endian = .big) -> UInt16 {
    return withUnsafeBytes { (ptr: UnsafePointer<UInt16>) -> UInt16 in
      let ptr = ptr.advanced(by: ofst)
      return endian == .big ? UInt16(bigEndian: ptr.pointee) : UInt16(littleEndian: ptr.pointee)
    }
  }

  public func readUInt32(ofst: Int, endian: Endian = .big) -> UInt32 {
    return withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> UInt32 in
      let ptr = ptr.advanced(by: ofst)
      return endian == .big ? UInt32(bigEndian: ptr.pointee) : UInt32(littleEndian: ptr.pointee)
    }
  }

  public func readUInt64(ofst: Int, endian: Endian = .big) -> UInt64 {
    return withUnsafeBytes { (ptr: UnsafePointer<UInt64>) -> UInt64 in
      let ptr = ptr.advanced(by: ofst)
      return endian == .big ? UInt64(bigEndian: ptr.pointee) : UInt64(littleEndian: ptr.pointee)
    }
  }

  public static func random(count: Int) throws -> Data {
    var buf = Data(count: count)
    let res = buf.withUnsafeMutableBytes {
      SecRandomCopyBytes(kSecRandomDefault, count, $0)
    }
    if res == errSecSuccess {
      return buf
    }
    throw DataBytesError.fail2genRandom
  }

  public var utf8string: String? {
    return String(bytes: self, encoding: .utf8)
  }
}

public enum DataBytesError: Error {
  case fail2genRandom
}
