//
//  Scrypt.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/1.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import Scrypt

public final class ScryptParams: Encodable, Decodable {
  public let n: Int
  public let r: Int
  public let p: Int
  public let dkLen: Int

  public static let defaultParams = ScryptParams(
    n: Constant.defaultScrypt["cost"].int!,
    r: Constant.defaultScrypt["blockSize"].int!,
    p: Constant.defaultScrypt["parallel"].int!,
    dkLen: Constant.defaultScrypt["size"].int!
  )

  public init(n: Int = 16384, r: Int = 8, p: Int = 8, dkLen: Int = 64) {
    self.n = n
    self.r = r
    self.p = p
    self.dkLen = dkLen
  }

  public enum CodingKeys: String, CodingKey {
    case n, r, p, dkLen
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(n, forKey: .n)
    try container.encode(r, forKey: .r)
    try container.encode(p, forKey: .p)
    try container.encode(dkLen, forKey: .dkLen)
  }

  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let n = try container.decode(Int.self, forKey: .n)
    let r = try container.decode(Int.self, forKey: .r)
    let p = try container.decode(Int.self, forKey: .p)
    let dkLen = try container.decode(Int.self, forKey: .dkLen)
    self.init(n: n, r: r, p: p, dkLen: dkLen)
  }
}

public final class Scrypt {
  public static func encrypt(password: Data, salt: Data, params: ScryptParams = ScryptParams.defaultParams) throws -> Data {
    var buf = [UInt8](repeating: 0, count: Int(params.dkLen))
    let pass = password as NSData
    let salt = salt as NSData
    let ret = libscrypt_scrypt(
      pass.bytes.assumingMemoryBound(to: UInt8.self),
      pass.length,
      salt.bytes.assumingMemoryBound(to: UInt8.self),
      salt.length,
      UInt64(params.n),
      UInt32(params.r),
      UInt32(params.p),
      &buf,
      params.dkLen
    )
    if ret != 0 {
      throw ScryptError.fail2Encrypt
    }
    return Data(bytes: buf)
  }

  public static func encryptWithGcm(prikey: Data, addr58: Data, salt: Data, pwd: Data, params: ScryptParams? = nil) throws -> Data {
    let params = params ?? ScryptParams.defaultParams
    let derived = try Scrypt.encrypt(password: pwd, salt: salt, params: params)

    let iv = derived.subdata(in: 0 ..< 12)
    let key = derived.subdata(in: 32 ..< derived.count)

    return try Aes256Gcm.encrypt(msg: prikey, key: key, iv: iv, auth: addr58)
  }

  public static func decryptWithGcm(encrypted: Data, addr58: Data, salt: Data, pwd: Data, params: ScryptParams? = nil) throws -> Data {
    let params = params ?? ScryptParams.defaultParams
    let derived = try Scrypt.encrypt(password: pwd, salt: salt, params: params)

    let iv = derived.subdata(in: 0 ..< 12)
    let key = derived.subdata(in: 32 ..< derived.count)

    return try Aes256Gcm.decrypt(encrypted: encrypted, key: key, iv: iv, auth: addr58)
  }
}

public enum ScryptError: Error {
  case fail2Encrypt
}
