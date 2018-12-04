//
//  BigInt.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/1.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation
import GMP

public class BigInt: CustomStringConvertible {
  public private(set) var m: mpz_t

  public init() {
    m = mpz_t()
    __gmpz_init(&m)
  }

  deinit {
    __gmpz_clear(&m)
  }

  public convenience init(_ str: String) {
    self.init()
    __gmpz_set_str(&m, (str as NSString).utf8String, 10)
  }

  public func toString(base: Int) -> String {
    let p = __gmpz_get_str(nil, CInt(base), &m)
    let s = String(cString: p!)
    return s
  }

  public var description: String {
    return toString(base: 10)
  }
}
