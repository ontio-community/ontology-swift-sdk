//
//  KeyParameters.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/11/29.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public final class KeyParameters: Encodable, Decodable {
  public let curve: Curve

  public init(curve: Curve) {
    self.curve = curve
  }

  public static func from(curve label: String) throws -> KeyParameters {
    return KeyParameters(curve: try Curve.from(label))
  }

  public enum CodingKeys: String, CodingKey {
    case curve
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(curve.label, forKey: .curve)
  }

  public convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let curve = try container.decode(String.self, forKey: .curve)
    self.init(curve: try Curve.from(curve))
  }
}
