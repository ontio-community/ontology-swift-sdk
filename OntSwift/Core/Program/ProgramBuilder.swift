//
//  ProgramBuilder.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public class ProgramBuilder: ScriptBuilder {
  public static func from(pubkey: PublicKey) throws -> ProgramBuilder {
    let prog = ProgramBuilder()
    _ = try prog.push(pubkey: pubkey)
    _ = try prog.push(opcode: OpCode.CHECKSIG)
    return prog
  }
}
