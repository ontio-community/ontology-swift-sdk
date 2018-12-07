//
//  InvokeCode.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/7.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class InvokeCode: Payload {
  public var code = Data()

  public func serialize() throws -> Data {
    let builder = ScriptBuilder()
    return try builder.push(varbytes: code).buf
  }

  public func deserialize<T>(r: T) throws where T: ScriptReader {
    code = r.readVarBytes()
  }
}
