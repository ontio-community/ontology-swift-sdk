//
//  Opcode.swift
//  OntSwift
//
//  Created by hsiaosiyuan on 2018/12/4.
//  Copyright © 2018 hsiaosiyuan. All rights reserved.
//

import Foundation

public struct OpCode {
  // public static letants
  public static let PUSH0: UInt8 = 0x00 // An empty array of bytes is pushed onto the stack.
  public static let PUSHF: UInt8 = 0x00
  public static let PUSHBYTES1: UInt8 = 0x01 // 0x01-0x4B The next bytes is data to be pushed onto the stack
  public static let PUSHBYTES75: UInt8 = 0x4B
  public static let PUSHDATA1: UInt8 = 0x4C // The next byte contains the number of bytes to be pushed onto the stack.
  public static let PUSHDATA2: UInt8 = 0x4D // The next two bytes contain the number of bytes to be pushed onto the stack.
  public static let PUSHDATA4: UInt8 = 0x4E // The next four bytes contain the number of bytes to be pushed onto the stack.
  public static let PUSHM1: UInt8 = 0x4F // The number -1 is pushed onto the stack.
  public static let PUSH1: UInt8 = 0x51 // The number 1 is pushed onto the stack.
  public static let PUSHT: UInt8 = 0x01
  public static let PUSH2: UInt8 = 0x52 // The number 2 is pushed onto the stack.
  public static let PUSH3: UInt8 = 0x53 // The number 3 is pushed onto the stack.
  public static let PUSH4: UInt8 = 0x54 // The number 4 is pushed onto the stack.
  public static let PUSH5: UInt8 = 0x55 // The number 5 is pushed onto the stack.
  public static let PUSH6: UInt8 = 0x56 // The number 6 is pushed onto the stack.
  public static let PUSH7: UInt8 = 0x57 // The number 7 is pushed onto the stack.
  public static let PUSH8: UInt8 = 0x58 // The number 8 is pushed onto the stack.
  public static let PUSH9: UInt8 = 0x59 // The number 9 is pushed onto the stack.
  public static let PUSH10: UInt8 = 0x5A // The number 10 is pushed onto the stack.
  public static let PUSH11: UInt8 = 0x5B // The number 11 is pushed onto the stack.
  public static let PUSH12: UInt8 = 0x5C // The number 12 is pushed onto the stack.
  public static let PUSH13: UInt8 = 0x5D // The number 13 is pushed onto the stack.
  public static let PUSH14: UInt8 = 0x5E // The number 14 is pushed onto the stack.
  public static let PUSH15: UInt8 = 0x5F // The number 15 is pushed onto the stack.
  public static let PUSH16: UInt8 = 0x60 // The number 16 is pushed onto the stack.

  // Flow control
  public static let NOP: UInt8 = 0x61 // Does nothing.
  public static let JMP: UInt8 = 0x62
  public static let JMPIF: UInt8 = 0x63
  public static let JMPIFNOT: UInt8 = 0x64
  public static let CALL: UInt8 = 0x65
  public static let RET: UInt8 = 0x66
  public static let APPCALL: UInt8 = 0x67
  public static let SYSCALL: UInt8 = 0x68
  public static let TAILCALL: UInt8 = 0x69
  public static let DUPFROMALTSTACK: UInt8 = 0x6A

  // Stack
  public static let TOALTSTACK: UInt8 = 0x6B // Puts the input onto the top of the alt stack. Removes it from the main stack.
  public static let FROMALTSTACK: UInt8 = 0x6C // Puts the input onto the top of the main stack. Removes it from the alt stack.
  public static let XDROP: UInt8 = 0x6D
  public static let XSWAP: UInt8 = 0x72
  public static let XTUCK: UInt8 = 0x73
  public static let DEPTH: UInt8 = 0x74 // Puts the number of stack items onto the stack.
  public static let DROP: UInt8 = 0x75 // Removes the top stack item.
  public static let DUP: UInt8 = 0x76 // Duplicates the top stack item.
  public static let NIP: UInt8 = 0x77 // Removes the second-to-top stack item.
  public static let OVER: UInt8 = 0x78 // Copies the second-to-top stack item to the top.
  public static let PICK: UInt8 = 0x79 // The item n back in the stack is copied to the top.
  public static let ROLL: UInt8 = 0x7A // The item n back in the stack is moved to the top.
  public static let ROT: UInt8 = 0x7B // The top three items on the stack are rotated to the left.
  public static let SWAP: UInt8 = 0x7C // The top two items on the stack are swapped.
  public static let TUCK: UInt8 = 0x7D // The item at the top of the stack is copied and inserted before the second-to-top item.

  // Splice
  public static let CAT: UInt8 = 0x7E // Concatenates two strings.
  public static let SUBSTR: UInt8 = 0x7F // Returns a section of a string.
  public static let LEFT: UInt8 = 0x80 // Keeps only characters left of the specified point in a string.
  public static let RIGHT: UInt8 = 0x81 // Keeps only characters right of the specified point in a string.
  public static let SIZE: UInt8 = 0x82 // Returns the length of the input string.

  // Bitwise logic
  public static let INVERT: UInt8 = 0x83 // Flips all of the bits in the input.
  public static let and: UInt8 = 0x84 // Boolean and between each bit in the inputs.
  public static let or: UInt8 = 0x85 // Boolean or between each bit in the inputs.
  public static let xor: UInt8 = 0x86 // Boolean exclusive or between each bit in the inputs.
  public static let EQUAL: UInt8 = 0x87 // Returns 1 if the inputs are exactly equal 0 otherwise.
  // EQUALVERIFY :UInt8 = 0x88 // Same as EQUAL but runs VERIFY afterward.
  // RESERVED1 :UInt8 = 0x89 // Transaction is invalid unless occuring in an unexecuted IF branch
  // RESERVED2 :UInt8 = 0x8A // Transaction is invalid unless occuring in an unexecuted IF branch

  // Arithmetic
  // Note: Arithmetic inputs are limited to signed 32-bit integers but may overflow their output.
  public static let INC: UInt8 = 0x8B // 1 is added to the input.
  public static let DEC: UInt8 = 0x8C // 1 is subtracted from the input.
  // SAL           :UInt8 = 0x8D // The input is multiplied by 2.
  // SAR           :UInt8 = 0x8E // The input is divided by 2.
  public static let NEGATE: UInt8 = 0x8F // The sign of the input is flipped.
  public static let ABS: UInt8 = 0x90 // The input is made positive.
  public static let NOT: UInt8 = 0x91 // If the input is 0 or 1 it is flipped. Otherwise the output will be 0.
  public static let NZ: UInt8 = 0x92 // Returns 0 if the input is 0. 1 otherwise.
  public static let ADD: UInt8 = 0x93 // a is added to b.
  public static let SUB: UInt8 = 0x94 // b is subtracted from a.
  public static let MUL: UInt8 = 0x95 // a is multiplied by b.
  public static let DIV: UInt8 = 0x96 // a is divided by b.
  public static let MOD: UInt8 = 0x97 // Returns the remainder after dividing a by b.
  public static let SHL: UInt8 = 0x98 // Shifts a left b bits preserving sign.
  public static let SHR: UInt8 = 0x99 // Shifts a right b bits preserving sign.
  public static let BOOLAND: UInt8 = 0x9A // If both a and b are not 0 the output is 1. Otherwise 0.
  public static let BOOLOR: UInt8 = 0x9B // If a or b is not 0 the output is 1. Otherwise 0.
  public static let NUMEQUAL: UInt8 = 0x9C // Returns 1 if the numbers are equal 0 otherwise.
  public static let NUMNOTEQUAL: UInt8 = 0x9E // Returns 1 if the numbers are not equal 0 otherwise.
  public static let LT: UInt8 = 0x9F // Returns 1 if a is less than b 0 otherwise.
  public static let GT: UInt8 = 0xA0 // Returns 1 if a is greater than b 0 otherwise.
  public static let LTE: UInt8 = 0xA1 // Returns 1 if a is less than or equal to b 0 otherwise.
  public static let GTE: UInt8 = 0xA2 // Returns 1 if a is greater than or equal to b 0 otherwise.
  public static let MIN: UInt8 = 0xA3 // Returns the smaller of a and b.
  public static let MAX: UInt8 = 0xA4 // Returns the larger of a and b.
  public static let WITHIN: UInt8 = 0xA5 // Returns 1 if x is within the specified range (left-inclusive) 0 otherwise.

  // Crypto
  // RIPEMD160 :UInt8 = 0xA6 // The input is hashed using RIPEMD-160.
  public static let SHA1: UInt8 = 0xA7 // The input is hashed using SHA-1.
  public static let SHA256: UInt8 = 0xA8 // The input is hashed using SHA-256.
  public static let HASH160: UInt8 = 0xA9
  public static let HASH256: UInt8 = 0xAA
  public static let CHECKSIG: UInt8 = 0xAC // The entire transaction's outputs inputs and script (from the most recently-executed CODESEPARATOR to the end) are hashed. The signature used by CHECKSIG must be a valid signature for this hash and public key. If it is 1 is returned 0 otherwise.
  public static let CHECKMULTISIG: UInt8 = 0xAE // For each signature and public key pair CHECKSIG is executed. If more public keys than signatures are listed some key/sig pairs can fail. All signatures need to match a public key. If all signatures are valid 1 is returned 0 otherwise. Due to a bug one extra unused value is removed from the stack.

  // Array
  public static let ARRAYSIZE: UInt8 = 0xC0
  public static let PACK: UInt8 = 0xC1
  public static let UNPACK: UInt8 = 0xC2
  public static let PICKITEM: UInt8 = 0xC3
  public static let SETITEM: UInt8 = 0xC4
  public static let NEWARRAY: UInt8 = 0xC5
  public static let NEWSTRUCT: UInt8 = 0xC6
  public static let NEWMAP: UInt8 = 0xC7
  public static let APPEND: UInt8 = 0xC8
  public static let REVERSE: UInt8 = 0xC9
  public static let REMOVE: UInt8 = 0xCA
  public static let HASKEY: UInt8 = 0xCB
  public static let KEYS: UInt8 = 0xCC
  public static let VALUES: UInt8 = 0xCD

  // Exceptionthrow :UInt8 = 0xF0
  public static let THROWIFNOT: UInt8 = 0xF1
}
