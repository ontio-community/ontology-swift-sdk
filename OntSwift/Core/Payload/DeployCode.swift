//
//  DeployCode.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class DeployCode: Payload {
  public var code = Data()
  public var needStorage = false
  public var name = ""
  public var version = ""
  public var author = ""
  public var email = ""
  public var desc = ""

  public func serialize() throws -> Data {
    let builder = ScriptBuilder()
    _ = try builder.push(varbytes: code)
    _ = try builder.push(b: needStorage)
    _ = try builder.push(varbytes: name.data(using: .utf8)!)
    _ = try builder.push(varbytes: version.data(using: .utf8)!)
    _ = try builder.push(varbytes: author.data(using: .utf8)!)
    _ = try builder.push(varbytes: email.data(using: .utf8)!)
    _ = try builder.push(varbytes: desc.data(using: .utf8)!)
    return builder.buf
  }

  public func deserialize<T>(r: T) throws where T: ScriptReader {
    code = r.readVarBytes()
    needStorage = r.readBool()
    name = r.readVarBytes().utf8string!
    version = r.readVarBytes().utf8string!
    author = r.readVarBytes().utf8string!
    email = r.readVarBytes().utf8string!
    desc = r.readVarBytes().utf8string!
  }
}
