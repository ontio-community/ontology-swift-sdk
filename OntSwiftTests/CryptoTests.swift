//
//  CryptoTests.swift
//  OntSwiftTests
//
//  Created by hsiaosiyuan on 2018/12/2.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

@testable import OntSwift
import XCTest

class CryptoTests: XCTestCase {
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testOpenSSL() throws {
    let hash = try Hash.compute(msg: "test", algo: SignatureScheme.ecdsaSha256.hashAlgo).hex(options: .upperCase)
    XCTAssertEqual("9F86D081884C7D659A2FEAA0C55AD015A3BF4F1B2B0B822CD15D6C15B0F00A08", hash)
  }

  func testGMP() throws {
    XCTAssertEqual("123456", BigInt("123456").description)
  }

  func testBase58() {
    XCTAssertEqual("3yZe7d", "test".data(using: .utf8)!.base58encoded)
  }

  func testMnemonic() throws {
    let mnemonic = "doll remember harbor resource desert curious fatigue nature arrest fix nation rhythm"
    XCTAssertEqual(
      "49e590700c9a28f86e00aa516cb9493c39743e0a255bae6fa51b57a7238b223a",
      try PrivateKey.from(mnemonic: mnemonic).raw.hex()
    )
  }

  func testSm() {
    let pri = "ab80a7ad086249c01e65c4d9bb6ce18de259dcfc218cd49f2455c539e9112ca3"
    let pkey = Ecdsa.pkey(
      pri: Data.from(hex: pri)!,
      curve: Curve.sm2p256v1.preset
    )
    XCTAssertEqual(
      "031220580679fda524f575ac48b39b9f74cb0a97993df4fac5798b04c702d07a39",
      pkey.pub(mode: .compress).hex()
    )
    XCTAssertEqual(
      pri,
      pkey.pri().hex()
    )
  }

  func testEc() {
    let pri = "0fdbd5d046997da9959b1931c727c96d83dff19e8ec0244952c1e72d1cdb5bf4"
    let pkey = Ecdsa.pkey(
      pri: Data.from(hex: pri)!,
      curve: Curve.p256.preset
    )
    XCTAssertEqual(
      "0205c8fff4b1d21f4b2ec3b48cf88004e38402933d7e914b2a0eda0de15e73ba61",
      pkey.pub(mode: .compress).hex()
    )
    XCTAssertEqual(
      pri,
      pkey.pri().hex()
    )
  }

  func testEcSign() throws {
    let pri = "0fdbd5d046997da9959b1931c727c96d83dff19e8ec0244952c1e72d1cdb5bf4"
    let pkey = Ecdsa.pkey(
      pri: Data.from(hex: pri)!,
      curve: Curve.p256.preset
    )
    let msg = "helloworld".data(using: .utf8)!
    let sig = try pkey.sign(msg: msg, scheme: SignatureScheme.ecdsaSha256).hexEncoded
    XCTAssertTrue(try pkey.verify(msg: msg, sig: Signature.from(hex: sig)))
  }

  func testEcJavaSign() throws {
    let pri = "0fdbd5d046997da9959b1931c727c96d83dff19e8ec0244952c1e72d1cdb5bf4"
    let prikey = try PrivateKey(raw: Data.from(hex: pri)!)
    let pubkey = try prikey.getPublicKey()
    let msg = "deviceCode=device79dd02d40eb6422bb1f7924c2a6b06af&nonce=1042961893&ontId=did:ont:AVRKWDig5TorzjCS5xphjgMnmdsT7KgsGD&timestamp=1535970123".data(using: .utf8)!
    let sig = try Signature.from(raw: Data(base64Encoded: "AYUi0ZgY7ZGN9Msr42prWjsghbcQ6yGaRL34RSUwQr949JMXuhrbjWCYIO3UV1FbFbNKG0YZByYHkffu800pNMw=")!)
    XCTAssertTrue(try pubkey.verify(msg: msg, sig: sig))
  }

  func testSm2Sign() throws {
    let pri = "0fdbd5d046997da9959b1931c727c96d83dff19e8ec0244952c1e72d1cdb5bf4"
    let pkey = Ecdsa.pkey(
      pri: Data.from(hex: pri)!,
      curve: Curve.sm2p256v1.preset
    )
    let msg = "helloworld".data(using: .utf8)!
    let sig = try pkey.sign(msg: msg, scheme: SignatureScheme.sm2Sm3)
    XCTAssertTrue(try pkey.verify(msg: msg, sig: sig))
  }

  // Verifies signature comes from typescript implementation
  func testSm2TsSigVerify() throws {
    let prikey = try PrivateKey(
      hex: "ab80a7ad086249c01e65c4d9bb6ce18de259dcfc218cd49f2455c539e9112ca3",
      algorithm: .sm2,
      parameters: KeyParameters(curve: .sm2p256v1)
    )
    let sig = try Signature.from(hex: "09313233343536373831323334353637380061f57a6006df7e8d503dcf8b3261c1309222a44f6b7a6a3184f0fd37e75879d234f38f4e47efd81d616d3ee60440be63d46e1bd75259c2042faf56f415fb7776")
    let pubkey = try prikey.getPublicKey()
    XCTAssertTrue(try pubkey.verify(msg: "test".data(using: .utf8)!, sig: sig))
  }

  func testEd() {
    let pri = Data.from(hex: "176fbdfa6eb71f06d849fdfb9b7a4b879b19d49fa963bb58ce327c417666f5a5")!
    XCTAssertEqual("e22ec1de59aefda80beb0b6397e55f4db7e0a0c4fede5cf40b1dcf9613a4d800", Eddsa.pub(pri: pri).hex())
  }

  func testEdSign() {
    let pri = Data.from(hex: "176fbdfa6eb71f06d849fdfb9b7a4b879b19d49fa963bb58ce327c417666f5a5")!
    let pub = Eddsa.pub(pri: pri)

    let msg = "helloworld".data(using: .utf8)!
    let sig = Eddsa.sign(msg: msg, pub: pub, pri: pri)
    XCTAssertTrue(Eddsa.verify(msg: msg, sig: sig, pub: pub))
  }

  func testGcm() throws {
    let salt = try Data.random(count: 16)
    let pri = Data.from(hex: "40b6b5a45bc3ba6bd4f49b0c6b024d5c6851db4cdf1a99c2c7adad9675170b07")!
    let prikey = try PrivateKey(raw: pri)
    let pubkey = try prikey.getPublicKey()
    let addr58 = try Address.from(pubkey: pubkey).toBase58().data(using: .utf8)!

    let pwd = "123456".data(using: .utf8)!
    let enc = try Scrypt.encryptWithGcm(prikey: prikey.raw, addr58: addr58, salt: salt, pwd: pwd)
    let dec = try Scrypt.decryptWithGcm(encrypted: enc, addr58: addr58, salt: salt, pwd: pwd)
    XCTAssertEqual(prikey.raw.hex(), dec.hex())
  }

  func testScrypt() throws {
    let pri = Data.from(hex: "6717c0df45159d5b5ef383521e5d8ed8857a02cdbbfdefeeeb624f9418b0895e")!
    let prikey = try PrivateKey(raw: pri)

    let salt = Data(base64Encoded: "sJwpxe1zDsBt9hI2iA2zKQ==")!
    let addr = try Address(value: "AakBoSAJapitE4sMPmW7bs8tfT4YqPeZEU")

    let pwd = "11111111".data(using: .utf8)!
    let enc = try prikey.encrypt(keyphrase: pwd, addr: addr, salt: salt)
    XCTAssertEqual("dRiHlKa16kKGuWEYWhXUxvHcPlLiJcorAN3ocZ9fQ5HBHBwf47A+MYoMg1nV6UuP", enc.raw.base64EncodedString())

    let data = Data(base64Encoded: "dRiHlKa16kKGuWEYWhXUxvHcPlLiJcorAN3ocZ9fQ5HBHBwf47A+MYoMg1nV6UuP")!
    let dec = try Scrypt.decryptWithGcm(encrypted: data, addr58: addr.toBase58().data(using: .utf8)!, salt: salt, pwd: pwd)
    XCTAssertEqual(prikey.raw.hex(), dec.hex())
  }

  func testToWif() throws {
    let pri = Data.from(hex: "e467a2a9c9f56b012c71cf2270df42843a9d7ff181934068b4a62bcdd570e8be")!
    let prikey = try PrivateKey(raw: pri)
    XCTAssertEqual("L4shZ7B4NFQw2eqKncuUViJdFRq6uk1QUb6HjiuedxN4Q2CaRQKW", try prikey.wif())
  }

  func testFromWif() throws {
    let pri = try PrivateKey.from(wif: "L4shZ7B4NFQw2eqKncuUViJdFRq6uk1QUb6HjiuedxN4Q2CaRQKW")
    XCTAssertEqual("e467a2a9c9f56b012c71cf2270df42843a9d7ff181934068b4a62bcdd570e8be", pri.raw.hexEncoded)
  }

  func testJavaGeneratedKey() throws {
    let prikey = try PrivateKey(hex: "176fbdfa6eb71f06d849fdfb9b7a4b879b19d49fa963bb58ce327c417666f5a5")
    let encPrikey = try prikey.encrypt(
      keyphrase: "123456",
      addr: try Address.from(pubkey: prikey.getPublicKey()),
      salt: Data(base64Encoded: "4vD1aBdikit9C1FNm0zE5Q==")!,
      params: ScryptParams()
    )
    XCTAssertEqual("YRUp1haBykuJvbNCPiTaAU3HunubC47n7bZXveUsAlcNkjo6KF31g+arGq2t2C0t", encPrikey.raw.base64EncodedString())
  }
}
